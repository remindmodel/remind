"""Draw flow graphs for tutorials/19_RegionalEmissionTargets.md with labeled straight connectors, zero overlaps, and automatic box border snapping.

Regenerate with:  python regiCarbonPrice_targets_graph.py
Requires: matplotlib (which brings Pillow, used to keep the pngs under the 220 kB repo file-size limit).

Outputs:
  git-19-loop.png               - per-iteration search loop (Section 2.1)
  git-19-held.png               - decision graph, target WAS FROZEN (Section 2.4 & 2.5)
  git-19-steering.png           - decision graph, target IS STEERING (Section 2.4 & 2.8)

THESE FIGURES ASSERT THINGS ABOUT postsolve.gms, so they go stale silently. When editing, re-check against the
code rather than against the previous figure. Three claims were wrong until 2026-08-05:
  * the PARKED stop had a rollback edge - it is the ONLY give-up branch that never sets wantRoll;
  * the noise-floor / infeasible / divergence stops were labelled bestAchievable - all three fire outside the
    tolerance, so the HONESTY RE-LABEL demotes them to unmetFrozen at the shipped exitFrac = 1.0;
  * the give-up branches were unnumbered - they now carry their p47_slopeTrace_iter("giveUpBy") code.
Every constant quoted below is a datainput.gms default; verify with
`grep -oE 'p47_slopeParam\\("[a-zA-Z]+"\\)=[0-9.e-]+' datainput.gms`.
"""

import os

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))

# REMIND rejects files above 220 kB. matplotlib writes 32-bit RGBA, which costs ~330 kB for a 2000x2000
# figure. These are flat-fill diagrams of a few dozen distinct colours, so a 256-entry palette holds every
# fill, border and antialiased text edge exactly: the shrink is ~70% with no visible loss. Do NOT dither,
# it adds noise to the flat fills and makes the file BIGGER.
MAX_KB = 220


def _shrink(path):
    """Rewrite a matplotlib RGBA png as an 8-bit palette png, and refuse to leave one over the repo limit."""
    with Image.open(path) as img:
        img.convert("RGB").quantize(colors=256, dither=Image.Dither.NONE).save(path, optimize=True)
    kb = os.path.getsize(path) / 1024
    if kb > MAX_KB:
        raise SystemExit(f"{os.path.basename(path)} is {kb:.0f} kB, over the {MAX_KB} kB repo limit. "
                         f"Lower the savefig dpi or split the figure.")
    print(f"wrote {path} ({kb:.0f} kB)")

# Design system palette (Fill, Border, Text Color)
THEME = {
    "model":   {"fc": "#F5F3FF", "ec": "#7C3AED", "tc": "#4C1D95"},  # REMIND Model solve (Purple)
    "measure": {"fc": "#FFFFFF", "ec": "#475569", "tc": "#0F172A"},  # Measurement / Fit (White / Slate)
    "decide":  {"fc": "#FFFBEB", "ec": "#D97706", "tc": "#78350F"},  # Decision / Branch (Orange)
    "act":     {"fc": "#ECFEFF", "ec": "#0891B2", "tc": "#164E63"},  # Steering Action (Cyan)
    "done":    {"fc": "#F0FDF4", "ec": "#16A34A", "tc": "#14532D"},  # Settled / Frozen (Green)
    "giveup":  {"fc": "#FEF2F2", "ec": "#DC2626", "tc": "#7F1D1D"},  # Give-up Branch (Red)
}

EDGE_COLOR = "#475569"
EDGE_LABEL_BG = "#FFFFFF"
EDGE_LABEL_BORDER = "#CBD5E1"


def _draw_straight_graph(pos, boxes, edges, xlim, ylim, figsize, title, outfile, fontsize=9.0):
    fig, ax = plt.subplots(figsize=figsize, facecolor="#F8FAFC")
    ax.set_facecolor("#F8FAFC")

    # 1. Draw Text Boxes first and keep reference to their text patch artist
    box_patches = {}
    for node, (text, category) in boxes.items():
        x, y = pos[node]
        cfg = THEME.get(category, THEME["measure"])

        lines = text.split("\n")
        header = lines[0]
        body = "\n".join(lines[1:]) if len(lines) > 1 else ""

        # The header is set in mathtext to get bold inside a mixed-weight box. Mathtext treats "-" and "=" as
        # BINARY OPERATORS and pads them, so "Non-Binding" came out "Non - Binding" and "giveUpBy=5" as
        # "giveUpBy = 5". Bracing forces them to render as ordinary symbols at their natural width.
        header_escaped = (header.replace(" ", "\\ ")
                                .replace("-", "{-}")
                                .replace("=", "{=}"))
        formatted_text = f"$\\mathbf{{{header_escaped}}}$\n{body}" if body else f"$\\mathbf{{{header_escaped}}}$"

        is_terminal = category in ("done", "giveup")
        is_dashed = (node == "brake")

        if category == "decide":
            boxstyle = "square,pad=0.42"
        else:
            boxstyle = "round,pad=0.42,rounding_size=0.50"

        txt_artist = ax.text(
            x, y, formatted_text,
            fontsize=fontsize,
            ha="center", va="center",
            fontfamily="sans-serif",
            color=cfg["tc"],
            linespacing=1.2,
            zorder=4,
            bbox=dict(
                boxstyle=boxstyle,
                fc=cfg["fc"],
                ec=cfg["ec"],
                linewidth=1.25,
                linestyle="--" if is_dashed else "-",
            ),
        )
        box_patches[node] = txt_artist.get_bbox_patch()

        # Draw a double-border style for boxes that terminate the target running
        if is_terminal:
            if category == "decide":
                outer_boxstyle = "square,pad=0.74"
            else:
                outer_boxstyle = "round,pad=0.74,rounding_size=0.75"

            outer_artist = ax.text(
                x, y, formatted_text,
                fontsize=fontsize,
                ha="center", va="center",
                fontfamily="sans-serif",
                color="none",
                linespacing=1.2,
                zorder=3,
                bbox=dict(
                    boxstyle=outer_boxstyle,
                    fc="none",
                    ec=cfg["ec"],
                    linewidth=0.9,
                ),
            )
            box_patches[node] = outer_artist.get_bbox_patch()

    # Force a canvas draw so bbox locations are computed accurately for patch clipping
    fig.canvas.draw()

    # 2. Draw Arrows using patchA/patchB auto-snapping. Straight (rad=0.0) unless the edge supplies a 6th
    #    element: the loop-closing feedback edge has to bow around the column it would otherwise pass through.
    for edge in edges:
        u, v, label, lx, ly = edge[:5]
        rad = edge[5] if len(edge) > 5 else 0.0
        conn_style = rad if isinstance(rad, str) else f"arc3,rad={rad}"
        arrow_style = "->" if (isinstance(rad, str) and "bar" in rad) else "-|>"

        arrow = FancyArrowPatch(
            pos[u], pos[v],
            connectionstyle=conn_style,
            arrowstyle=arrow_style,
            mutation_scale=12,
            color=EDGE_COLOR,
            linewidth=1.2,
            patchA=box_patches[u],
            patchB=box_patches[v],
            shrinkA=2,
            shrinkB=2,
            zorder=5,
        )
        ax.add_patch(arrow)

        # Edge label badge (white card with subtle border, no overlap)
        if label:
            if lx is None:
                lx = (pos[u][0] + pos[v][0]) / 2
            if ly is None:
                ly = (pos[u][1] + pos[v][1]) / 2
            ax.text(
                lx, ly, label,
                fontsize=fontsize - 1.5,
                fontweight="medium",
                color="#334155",
                ha="left", va="center",
                multialignment="center",
                fontfamily="sans-serif",
                bbox=dict(
                    boxstyle="round,pad=0.22,rounding_size=0.12",
                    fc=EDGE_LABEL_BG,
                    ec=EDGE_LABEL_BORDER,
                    lw=0.8,
                    alpha=0.95
                ),
                zorder=6,
            )

    # 3. Figure Title Banner
    ax.text(
        0.5, 0.97, title,
        transform=ax.transAxes,
        fontsize=12.5,
        fontweight="bold",
        color="#0F172A",
        ha="center", va="top",
        fontfamily="sans-serif",
        bbox=dict(
            boxstyle="round,pad=0.35,rounding_size=0.15",
            fc="#FFFFFF",
            ec="#E2E8F0",
            lw=1.0
        )
    )

    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.axis("off")
    plt.tight_layout()

    path = os.path.join(HERE, outfile)
    plt.savefig(path, dpi=200, facecolor="#F8FAFC", bbox_inches="tight")
    plt.close(fig)
    _shrink(path)


def loop_graph():
    """Figure 1: High-level per-iteration search loop (Section 2.1) - Fully Labeled Straight Connectors."""
    boxes = {
        "solve": ("REMIND Nash Iteration\nSolves one global iteration", "model"),
        "dev": ("Measure Deviation |dev|\ndev = (emissions - target) / reference\n(Section 2.3)", "measure"),
        "check": ("Inside Tolerance?\n|dev| <= enterFrac x tol\nfor persist=2 iterations\n(Section 2.4)", "decide"),
        "slope": ("Learn Response\nLeast-squares slope fit over last\nmaxWindow=8 steered iterations\n(Section 2.6)", "measure"),
        "step": ("Compute Price Step\nTrust region [0.5, 2.0] & damping\n(Section 2.6 & 2.7)", "act"),
        "ramp": ("Redraw Price Path\nLinearly interpolate & anchor ramps\n(Section 2.2)", "act"),

        # An ACT node, so it must not be phrased as a question: the drift decision is taken at `frozen`, this
        # box is the un-freezing itself. Decisions are the square orange boxes.
        "reopen_node": ("RE-OPEN\nUn-freeze and steer again\n(budget reopenMax=3)\n(Section 2.5)", "act"),
        "frozen": ("Target FROZEN\nCarbon price stops moving\nlabel: lowerThanTolerance / smallPrice", "done"),
        "giveup": ("Give-Up (1 of 5 branches)\nFreeze price & report residual\np47_slopeTrace_iter(\"giveUpBy\")\nnames which one (Section 2.8)\nlabel: unmetFrozen / bestAchievable", "giveup"),
        "end": ("Run Termination\nAll regional targets frozen\n(met or given up)", "done"),
    }

    pos = {
        "solve": (0.0, 5.0),
        "dev": (0.0, 3.6),
        "check": (0.0, 2.0),
        "slope": (0.0, 0.4),
        "step": (0.0, -1.2),
        "ramp": (-0.01, -2.8),

        "reopen_node": (4, 3.6),
        "frozen": (7, 2.0),
        "giveup": (5, 0.4),
        "end": (7, -2.8),
    }

    # Straight line edges with explicit labels for every path
    edges = [
        ("solve", "dev", "solver\noutput", 0.1, 4.4),
        ("dev", "check", "evaluate\ndeviation", 0.1, 2.8),
        ("check", "slope", "no\n(keep steering)", 0.1, 1.2),
        ("slope", "step", "response\nslope", 0.1, -0.4),
        ("step", "ramp", "new price factor", 0.1, -2.0),

        ("check", "frozen", "yes\n(in-band)", 2.7, 2),
        ("frozen", "reopen_node", "emissions\ndrift out", 4.3, 2.8),
        ("reopen_node", "check", "un-freeze\n& steer", 2.6, 2.8),

        ("slope", "giveup", "stuck /\nno response", 1.9, 0.6),
        ("frozen", "end", "all targets\nfrozen & met", 7.2, -0.4),
        ("giveup", "end", "given up &\nreported", 5, -1.2),

        ("ramp", "solve", "price path\nfeeds the next\nNash iteration", -3.7, 1.05, "bar,armA=-336,armB=-336,fraction=0"),
    ]

    return _draw_straight_graph(
        pos, boxes, edges,
        xlim=(-4, 9), ylim=(-3.5, 6.5), figsize=(10, 10),
        title="Section 2.1: Per-Target Search Loop (One Nash Iteration)",
        outfile="git-19-loop.png"
    )


def held_graph():
    """Figure 2: Decision graph for target FROZEN last iteration (Section 2.4 & 2.5) - Fully Labeled."""
    boxes = {
        "start": ("Measure Deviation |dev|\nTarget evaluation\n(Section 2.3)", "measure"),
        "small": ("Non-Binding Floor?\nPrice at floor & emissions below target?\n(Section 2.4)", "decide"),
        "smallP": ("smallPrice Market\nFrozen & Met\n(non-binding market)\nlabel: smallPrice", "done"),
        "was": ("Target Status?\nWas it frozen last iteration?", "decide"),
        # A hand-off to the other figure, not an action taken here - so it carries the same neutral "measure"
        # styling as that figure's entry node rather than the cyan of a steering action.
        "steering": ("Target STEERING\nSee Decision Graph 2\n(Section 2.4)", "measure"),

        "hold": ("Hold Condition?\n|dev| > exitFrac x tol\nfor persist=2 iterations\n(Section 2.4)", "decide"),
        "keep": ("Stay FROZEN\nRide out iteration wobble", "done"),
        "refresh": ("Settlement Refresh\nSettled for reopenRefresh (24 iter)?\nRe-open budget earned back\n(Section 2.5)", "act"),
        "parked": ("PARKED STOP\nHeld full window outside tol\n-> Give up, NO rollback\n(price constant, giveUpBy=5)\nlabel: bestAchievable", "giveup"),

        "reopen": ("Re-Open Budget?\n|dev| <= reopenMaxDev\n& budget left?\n(Section 2.5)", "decide"),
        "reopened": ("RE-OPEN (Charged)\nSteer again (first step\ncapped at reopenStepCap=5%)", "act"),
        "release": ("RELEASE (Uncharged)\nToo far out to be drift", "act"),
        # Keep every body line short: these boxes are auto-sized from their text, so one long line widens the
        # box until it collides with its neighbour (this one ran into "RE-OPEN (Charged)").
        "budgetOut": ("BUDGET SPENT\n(reopenMax=3 exhausted)\n-> Give up (giveUpBy=4)\nlabel: unmetFrozen", "giveup"),
        "roll": ("PRICE ROLLBACK\nRestore best-so-far or knee price\n(Section 2.9)", "act"),
    }

    pos = {
        "start": (0.0, 6.4),
        "small": (0.0, 4.8),
        "smallP": (16.0, 4.8),
        "was": (0.0, 3.2),
        "steering": (16.0, 3.2),

        "hold": (0.0, 1.4),
        "keep": (-12, 1.4),
        "refresh": (-18, -0.6),
        "parked": (-6.5, -0.6),

        "reopen": (6.2, -0.6),
        "budgetOut": (-3.5, -2.8),
        "reopened": (6.6, -2.8),
        "release": (16, -2.8),
        "roll": (-15, -4.8),
    }

    edges = [
        ("start", "small", "check\nmarket price", 0.4, 5.7),
        ("small", "smallP", "yes\n(slack\nmarket)", 8.2, 5.2),
        ("small", "was", "no", 0.4, 4.0),
        ("was", "hold", "yes\n(was frozen)", 0.4, 2.3),
        ("was", "steering", "no\n(was steering)", 6.2, 3.5),

        ("hold", "keep", "no\n(ride out\nwobble)", -6.2, 1.8),
        ("keep", "refresh", "and met\n(24 iters)", -17.6, 0.6),
        ("keep", "parked", "full window\noutside tol", -8.4, 0.6),
        ("hold", "reopen", "yes\n(exits band)", 4, 0.5),

        ("reopen", "budgetOut", "no:\nbudget spent", 0.0, -1.6),
        ("reopen", "reopened", "yes\n(budget left)", 5, -1.6),
        ("reopen", "release", "no:\n|dev| too large", 10, -1.6),

        ("budgetOut", "roll", "rollback\nprice", -12.4, -3.6),
    ]

    return _draw_straight_graph(
        pos, boxes, edges,
        xlim=(-24, 22.0), ylim=(-5.8, 8.0), figsize=(10, 10),
        title="Decision Graph 1 of 2: Target FROZEN Last Iteration (Section 2.4 & 2.5)",
        outfile="git-19-held.png"
    )


def steering_graph():
    """Figure 3: Decision graph for target STEERING price (Section 2.4 - 2.8) - Fully Labeled."""
    boxes = {
        "enter": ("Target Status\nTarget is STEERING\nits carbon price", "measure"),
        "aim": ("AIM Band Check\n|dev| <= enterFrac x tol\nfor persist=2 iterations?\n(Section 2.4)", "decide"),
        "conv": ("CONVERGED\nFreeze price\nlabel: lowerThanTolerance", "done"),
        "accept": ("ACCEPT Band Check\n|dev| <= tol & aim budget\n(aimMaxTries=3) spent?\n(Section 2.4)", "decide"),
        "steer": ("Active Price Steering\nSlope fit -> Capped price step\n(Section 2.6 & 2.7)", "act"),

        # Every stop assigns bestAchievable, but the HONESTY RE-LABEL demotes a frozen, unmet target whose
        # |dev| exceeds exitFrac x tolerance to unmetFrozen. All three of these fire strictly OUTSIDE the
        # tolerance, so at the shipped exitFrac = 1.0 they always end up unmetFrozen. Only the parked stop
        # (Decision Graph 1) leaves bestAchievable standing, because it fires from inside the exit band.
        # The giveUpBy code goes in the BODY, not the header: the header is set in mathtext, which pads "=" as
        # a relation ("giveUpBy = 1") and bracing does not suppress that in matplotlib's implementation.
        "noise": ("NOISE FLOOR STOP\nPrice settled & |dev| trapped\nin narrow band outside tol\n(Section 2.8, giveUpBy=1)\nlabel: unmetFrozen", "giveup"),
        "infeas": ("INFEASIBLE TARGET STOP\nStep pinned at cap, dev stalled\n& one-sided over window\n(Section 2.8, giveUpBy=2)\nlabel: unmetFrozen", "giveup"),
        "diverge": ("DIVERGENT PATH?\nArmed, dev > divergeFactor x best\nfor 2 iterations, not recovering\n(Section 2.8)", "decide"),
        "brake": ("DIVERGENCE BRAKE\n(Reversible)\nRestore window-best price\n& cap step at 5%", "act"),
        "divstop": ("DIVERGENCE STOP\nBrakes (divergeBrakeMax=2)\nspent -> Give up\n(Section 2.8, giveUpBy=3)\nlabel: unmetFrozen", "giveup"),
        "roll": ("PRICE ROLLBACK\nRestore best price path\n(verified next iteration by rollbackVerify)\n(Section 2.9)", "act"),
    }

    pos = {
        "enter": (0.0, 6.0),
        "aim": (0.0, 4.0),
        "conv": (14.0, 3.0),
        "accept": (0.0, 2.0),
        "steer": (0.0, 0.0),

        "noise": (-12.0, -2),
        "infeas": (0.0, -2),
        "diverge": (11.5, -2),
        "brake": (16, -4.0),
        "divstop": (7, -4.0),
        "roll": (0.0, -6.0),
    }

    edges = [
        ("enter", "aim", "check\nAIM band", 0.4, 5.1),
        ("aim", "conv", "yes\n(|dev| <= 0.75x tol)", 6.2, 3.9),
        ("aim", "accept", "no", 0.4, 3.1),
        ("accept", "conv", "yes\n(|dev| <= 1.0x tol)", 6.3, 2.1),
        ("accept", "steer", "no\n(keep steering)", 0.4, 1.1),

        ("steer", "noise", "trapped\nin noise", -8.2, -0.8),
        ("steer", "infeas", "pinned\nat cap", 0.4, -0.8),
        ("steer", "diverge", "excursion\n> 10x", 6.8, -0.8),
        # `brake` sits to the RIGHT (x=16) and `divstop` to the LEFT (x=7), so the label x-coordinates have to
        # follow: these two were swapped, putting "brakes left" on the arrow into the STOP and vice versa.
        ("diverge", "brake", "brakes\nleft", 14.7, -2.9),
        ("diverge", "divstop", "brakes\nspent", 7.4, -2.9),

        ("noise", "roll", "rollback\nprice", -6, -5),
        ("infeas", "roll", "rollback\nprice", -0.8, -4.8),
        ("divstop", "roll", "rollback\nprice", 5, -5),
    ]

    return _draw_straight_graph(
        pos, boxes, edges,
        xlim=(-20, 20.0), ylim=(-7, 8), figsize=(10, 10),
        title="Decision Graph 2 of 2: Target STEERING Its Price (Section 2.4 - 2.8)",
        outfile="git-19-steering.png"
    )


if __name__ == "__main__":
    loop_graph()
    held_graph()
    steering_graph()
