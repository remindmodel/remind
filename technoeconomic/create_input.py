# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
"""Write the REMIND input csv file computed from POSTED by content.py.

This is what scripts/input/create_input_for_technoeconomic.R calls. It writes
core/input/f_technoeconomic.csv, which core/datainput.gms reads to replace
values from generisdata_tech.prn: one char,te,value line per property, the
shape of fm_dataglob, grouped under comments naming their unit, which GAMS
ignores inside a data definition. The file is committed, and its header records
the uv.lock and the md5 of these scripts that produced it; --check compares
both with technoeconomic/uv.lock and these files and attributes the values to
the package commits the lock pins. The exit code tells what to do with the csv:
0 it is up to date, 3 regenerate and commit it, 1 this script failed, 2 is what
argparse and uv exit with. scripts/input/create_input_for_technoeconomic.R uses
these same codes, adding 2 for environments without uv or its .venv.

    uv run --project technoeconomic python technoeconomic/create_input.py [--out PATH]
    uv run --project technoeconomic python technoeconomic/create_input.py --check
"""

import argparse
import hashlib
import json
import math
import sys
import tomllib
from importlib import metadata
from pathlib import Path

REMIND_FOLDER = Path(__file__).resolve().parent.parent
DEFAULT_OUT = REMIND_FOLDER / "core" / "input" / "f_technoeconomic.csv"
# the values depend on the queries and on how they are formatted here
SOURCE_FILES = [Path(__file__), Path(__file__).with_name("content.py")]
# the resolved environment the values were computed in, committed next to the
# scripts and recorded in the csv header under its sha256, so that both the
# data and the code computing them, down to numpy and pandas, can be attributed
LOCK_FILE = Path(__file__).resolve().with_name("uv.lock")


def lock_sha256():
    """sha256 of uv.lock, the identity of the whole resolved environment."""
    return hashlib.sha256(LOCK_FILE.read_bytes()).hexdigest()


def lock_resolutions():
    """The git-sourced packages of uv.lock, name to resolved commit: the
    packages whose content the values are numbers of, unlike the registry ones
    uv run reinstates from the lock anyway."""
    with LOCK_FILE.open("rb") as lock:
        packages = tomllib.load(lock)["package"]
    return {package["name"]: package["source"]["git"].rsplit("#", 1)[-1]
            for package in packages
            if isinstance(package.get("source"), dict) and package["source"].get("git")}


def commit_text(path):
    """How to commit a csv, core/input being git-ignored: its values belong to
    the commit which changes the scripts or the environment which produced them."""
    if path.is_relative_to(REMIND_FOLDER):
        path = path.relative_to(REMIND_FOLDER)
    return (f"Commit it with 'git add -f {path}' and commit the scripts and uv.lock "
            "of technoeconomic/ together with it.")


def editable_text(installations, path):
    """Why a csv which an editable install wrote must not be committed."""
    editable = [package for package, here in installations.items()
                if here and here["editable"]]
    return (f"{', '.join(editable)} installed in editable mode from "
            f"{', '.join(installations[package]['url'] for package in editable)}, "
            f"so {path} is rebuilt on every run and must not be committed.")


def has_editable(installations):
    """Whether any package the lock resolves from git is editable-installed."""
    return any(here and here["editable"] for here in installations.values())


def sources_md5():
    """md5 over both scripts, identical to a concatenation of tools::md5sum()."""
    digest = hashlib.md5()
    for source in SOURCE_FILES:
        digest.update(source.read_bytes())
    return digest.hexdigest()


def installed(package):
    """Installed package as version, url, commit and editable, from the PEP 610
    direct_url.json that pip and uv write; None if not installed."""
    try:
        dist = metadata.distribution(package)
    except metadata.PackageNotFoundError:
        return None
    direct = json.loads(dist.read_text("direct_url.json") or "{}")
    return {"version": dist.version, "url": direct.get("url"),
            "commit": (direct.get("vcs_info") or {}).get("commit_id"),
            "editable": bool((direct.get("dir_info") or {}).get("editable"))}


def identity(installation):
    """What the values of an installation are attributed to: its commit, its
    version, or the folder of an editable install that has no commit."""
    if installation is None:
        return None
    return (f"editable {installation['url']}" if installation["editable"]
            else installation["commit"] or installation["version"])


def mismatch(installations):
    """Installations that are not the commits the lock resolves, editable
    installs excepted: their values are attributed to their folder."""
    expected = lock_resolutions()
    return [f"{package} should be {expected[package]}, {sys.executable} has "
            f"{identity(installations[package]) or 'nothing'}"
            for package in expected
            if not (installations[package] and installations[package]["editable"])
            and identity(installations[package]) != expected[package]]


def csv_header(path):
    """The uv.lock sha256 and technoeconomic md5 recorded in a GAMS csv header,
    missing ones as "none"."""
    found = {"lock": "none", "md5": "none"}
    if not path.is_file():
        return found
    keys = {"uv.lock sha256": "lock", "technoeconomic md5": "md5"}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("*"):
            break
        for key, name in keys.items():
            if line.startswith(f"* {key}:"):
                found[name] = line.split(":", 1)[1].strip()
    return found


def check(path):
    """Whether the csv at path was written under the current uv.lock and by
    these scripts. Returns an exit code and a message: 0 up to date, 3
    regenerate it, be it outdated, missing or written by an editable install
    which then must not be committed."""
    installations = {package: installed(package) for package in lock_resolutions()}
    if has_editable(installations):
        return 3, editable_text(installations, path)
    found, md5, sha = csv_header(path), sources_md5(), lock_sha256()
    differences = []
    if found["lock"] != sha:
        differences.append(f"uv.lock {found['lock']}, expected {sha}")
    if found["md5"] != md5:
        differences.append(f"technoeconomic md5 {found['md5']}, expected {md5}")
    if differences:
        return 3, (f"{path} is outdated ({'; '.join(differences)}). Regenerate it "
                   "with 'Rscript scripts/input/create_input_for_technoeconomic.R'. "
                   + commit_text(path))
    commits = ", ".join(f"{package} {commit}"
                        for package, commit in lock_resolutions().items())
    return 0, f"{path} is up to date with uv.lock {sha} ({commits})."


def format_value(value):
    """Format a value for GAMS. Exact zeros become EPS so that GAMS stores
    them and the overwrite in core/datainput.gms applies to them as well."""
    if not math.isfinite(value):
        raise ValueError(f"non-finite value {value}")
    return "EPS" if value == 0 else f"{value:.6g}"


def unit_lines(selected):
    """Value lines, grouped by property and unit, each group introduced by the
    comment naming its unit."""
    grouped: dict[tuple[str, str], list[str]] = {}
    for (prop, tech), (_, value, unit) in sorted(selected.items()):
        grouped.setdefault((prop, unit), []).append(f"{prop},{tech},{format_value(value)}")
    for (prop, unit), values in grouped.items():
        yield f"* unit {prop} -> {unit}"
        yield from values


def write_gams(path, selected, sha, md5):
    lines = [
        "* description: techno-economic data from POSTED, averaged across "
        "sources; replaces fm_dataglob values from generisdata_tech.prn",
        "* origin: technoeconomic/create_input.py and content.py, regenerate "
        "with scripts/input/create_input_for_technoeconomic.R and commit",
        f"* uv.lock sha256: {sha}",
        f"* technoeconomic md5: {md5}",
        "* columns: char,te,value; a comment gives the unit of the rows below "
        "it, up to the next comment",
    ]
    # GAMS ignores comment lines inside a data definition, which is where the
    # units of the values can go; blank lines there are not ignored
    lines.extend(unit_lines(selected))
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def run(args):
    if args.check:
        code, text = check(args.out)
        print(text)
        return code
    installations = {package: installed(package) for package in lock_resolutions()}
    wrong = mismatch(installations)
    if wrong:
        print(f"{' and '.join(wrong)}. Run 'uv --directory technoeconomic sync "
              "--locked', after 'uv lock' if you changed pyproject.toml.",
              file=sys.stderr)
        return 1
    # only the fetch needs POSTED, so --check runs without it
    import content

    selected = content.fetch()
    sha, md5 = lock_sha256(), sources_md5()
    write_gams(args.out, selected, sha, md5)
    commits = ", ".join(f"{package} {commit}"
                        for package, commit in lock_resolutions().items())
    print(f"Wrote {len(selected)} values to {args.out} "
          f"(uv.lock {sha}, {commits}, technoeconomic md5 {md5})")
    # an editable install may have written this file, in which case it is not
    # reproducible and must not be committed
    print(editable_text(installations, args.out) if has_editable(installations)
          else commit_text(args.out))
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT,
                        help="GAMS input file in fm_dataglob shape")
    parser.add_argument("--check", action="store_true",
                        help="report whether --out is up to date and exit")
    args = parser.parse_args(argv)
    return run(args)


if __name__ == "__main__":
    raise SystemExit(main())
