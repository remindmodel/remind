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
ignores inside a data definition. The file is not committed, it is generated
input like everything else in core/input, but its header still records the
sha256 of uv.lock and of these scripts that produced it; --check compares both
with technoeconomic/uv.lock and these files.

Exit codes of --check:
    0  the csv is up to date
    3  regenerate it, outdated or missing
    1  this script crashed, 2 what argparse and uv exit with, both failures
The posted pin in pyproject.toml is not checked here,
scripts/input/create_input_for_technoeconomic.R syncs it from config/default.cfg.

    uv run --project technoeconomic python technoeconomic/create_input.py [--out PATH]
    uv run --project technoeconomic python technoeconomic/create_input.py --check
"""

import argparse
import hashlib
import itertools
import math
import sys
import tomllib
from pathlib import Path

REMIND_FOLDER = Path(__file__).resolve().parent.parent
DEFAULT_OUT = REMIND_FOLDER / "core" / "input" / "f_technoeconomic.csv"
# the values depend on the queries and on how they are formatted here
SOURCE_FILES = [Path(__file__), Path(__file__).with_name("content.py")]
# the resolved environment the values were computed in; its sha256 in the csv
# header attributes them, down to numpy and pandas, to a commit
LOCK_FILE = Path(__file__).resolve().with_name("uv.lock")


def provenance():
    """The header lines recording the environment and the scripts a csv was
    written with, in the order they are written in."""
    digest = hashlib.sha256()
    for source in SOURCE_FILES:
        digest.update(source.read_bytes())
    return {"uv.lock sha256": hashlib.sha256(LOCK_FILE.read_bytes()).hexdigest(),
            "technoeconomic sha256": digest.hexdigest()}


def lock_commits():
    """The git-sourced packages of uv.lock, name to resolved commit: the
    packages whose content determines the values, the registry ones uv
    reinstates from the lock anyway."""
    with LOCK_FILE.open("rb") as lockfile:
        packages = tomllib.load(lockfile)["package"]
    return {package["name"]: package["source"]["git"].rsplit("#", 1)[-1]
            for package in packages if package["source"].get("git")}


def commits_text():
    """The lock's git resolutions as one line, for messages."""
    return ", ".join(f"{package} {commit}"
                     for package, commit in lock_commits().items())


def csv_header(path):
    """The provenance values recorded in a GAMS csv header, missing ones as "none"."""
    found = dict.fromkeys(provenance(), "none")
    if not path.is_file():
        return found
    # the header block ends with the first value line, unit comments below it
    # are no provenance lines
    lines = itertools.takewhile(lambda line: line.startswith("*"),
                                path.read_text(encoding="utf-8").splitlines())
    for line in lines:
        key, _, value = line.partition(":")
        if (key := key.removeprefix("* ").strip()) in found:
            found[key] = value.strip()
    return found


def check(path):
    """Whether the csv at path was written under the current uv.lock and by
    these scripts, as (exit code, message)."""
    found, want = csv_header(path), provenance()
    differences = [f"{key} {found[key]}, expected {value}"
                   for key, value in want.items() if found[key] != value]
    if differences:
        return 3, (f"{path} is missing or outdated ({'; '.join(differences)}). "
                   "Regenerate it with "
                   "'Rscript scripts/input/create_input_for_technoeconomic.R'.")
    return 0, (f"{path} is up to date with uv.lock {want['uv.lock sha256']} "
               f"({commits_text()}).")


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


def write_gams(path, selected, prov):
    lines = [
        "* description: techno-economic data from POSTED, averaged across "
        "sources; replaces fm_dataglob values from generisdata_tech.prn",
        "* origin: technoeconomic/create_input.py and content.py, regenerate "
        "with scripts/input/create_input_for_technoeconomic.R",
        *(f"* {key}: {value}" for key, value in prov.items()),
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
    # only the fetch needs POSTED, so --check runs without it
    import content

    selected = content.fetch()
    prov = provenance()
    write_gams(args.out, selected, prov)
    written = ", ".join(f"{key} {value}" for key, value in prov.items())
    print(f"Wrote {len(selected)} values to {args.out} "
          f"({written}, {commits_text()})")
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
