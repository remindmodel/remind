"""Draw flow graphs for tutorials/19_RegionalEmissionTargets.md with labeled straight connectors, zero overlaps, and automatic box border snapping.

Regenerate with:  python regiCarbonPrice_targets_graph.py
Requires: matplotlib, networkx.

Outputs:
  regiCarbonPrice_loop.png       - per-iteration search loop (Section 2.1)
  regiCarbonPrice_held.png       - decision graph, target WAS FROZEN (Section 2.4 & 2.5)
  regiCarbonPrice_steering.png   - decision graph, target IS STEERING (Section 2.4 & 2.8)
"""

import os

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

HERE = os.path.dirname(os.path.abspath(__file__))

# Design system palette (Fill, Border, Text Color)
THEME = {
    "model":   {"fc": "#EFF6FF", "ec": "#2563EB", "tc": "#1E3A8A"},  # REMIND Model solve (Blue)
    "measure": {"fc": "#F8FAFC", "ec": "#64748B", "tc": "#0F172A"},  # Measurement / Fit (Slate)
    "decide":  {"fc": "#FFFBEB", "ec": "#D97706", "tc": "#78350F"},  # Decision / Branch (Amber)
    "act":     {"fc": "#ECFDF5", "ec": "#059669", "tc": "#064E3B"},  # Steering Action (Emerald)
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

        formatted_text = f"$\\mathbf{{{header}}}$\n{body}" if body else f"$\\mathbf{{{header}}}$"

        txt_artist = ax.text(
            x, y, formatted_text,
            fontsize=fontsize,
            ha="center", va="center",
            fontfamily="sans-serif",
            color=cfg["tc"],
            linespacing=1.2,
            zorder=4,
            bbox=dict(
                boxstyle="round,pad=0.42,rounding_size=0.18",
                fc=cfg["fc"],
                ec=cfg["ec"],
                linewidth=1.25,
            ),
        )
        box_patches[node] = txt_artist.get_bbox_patch()

    # Force a canvas draw so bbox locations are computed accurately for patch clipping
    fig.canvas.draw()

    # 2. Draw Straight Arrows using patchA/patchB auto-snapping
    for edge in edges:
        u, v, label, lx, ly = edge[:5]

        # Always straight connector (rad=0.0)
        arrow = FancyArrowPatch(
            pos[u], pos[v],
            connectionstyle="arc3,rad=0.0",
            arrowstyle="-|>",
            mutation_scale=12,
            color=EDGE_COLOR,
            linewidth=1.2,
            patchA=box_patches[u],
            patchB=box_patches[v],
            shrinkA=2,
            shrinkB=2,
            zorder=2,
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
                zorder=5,
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
    print("wrote", path)


def loop_graph():
    """Figure 1: High-level per-iteration search loop (Section 2.1) - Fully Labeled Straight Connectors."""
    boxes = {
        "solve": ("REMIND Nash Iteration\nSolves one global iteration", "model"),
        "dev": ("Measure Deviation |dev|\ndev = (emissions - target) / reference\n(Section 2.3)", "measure"),
        "check": ("Inside Tolerance?\n|dev| <= enterFrac x tol\nfor persist=2 iterations (Section 2.4)", "decide"),
        "slope": ("Learn Response\nLeast-squares slope fit over last\nmaxWindow=8 steered iterations (Sec 2.6)", "measure"),
        "step": ("Compute Price Step\nTrust region [0.5, 2.0] & damping\n(Section 2.6 & 2.7)", "act"),
        "ramp": ("Redraw Price Path\nLinearly interpolate & anchor ramps\n(Section 2.2)", "act"),

        "reopen_node": ("Drifted Out?\nRE-OPEN (budget reopenMax=3)\n(Section 2.5)", "act"),
        "frozen": ("Target FROZEN\nCarbon price stops moving", "done"),
        "giveup": ("Give-Up\nFreeze price & report residual\n(Section 2.8)", "giveup"),
        "end": ("Run Termination\nAll regional targets frozen\n(met or given up)", "done"),
    }

    pos = {
        "solve": (0.0, 5.0),
        "dev": (0.0, 3.6),
        "check": (0.0, 2.0),
        "slope": (0.0, 0.4),
        "step": (0.0, -1.2),
        "ramp": (0.0, -2.8),

        "reopen_node": (3.2, 3.6),
        "frozen": (5.5, 2.0),
        "giveup": (4, 0.4),
        "end": (5.5, -2.8),
    }

    # Straight line edges with explicit labels for every path
    edges = [
        ("solve", "dev", "solver\noutput", 0.1, 4.4),
        ("dev", "check", "evaluate\ndeviation", 0.1, 2.8),
        ("check", "slope", "no\n(keep steering)", 0.1, 1.2),
        ("slope", "step", "response\nslope", 0.1, -0.4),
        ("step", "ramp", "new price factor", 0.1, -2.0),

        ("check", "frozen", "yes\n(in-band)", 2.7, 2),
        ("frozen", "reopen_node", "emissions\ndrift out", 3.5, 2.8),
        ("reopen_node", "check", "un-freeze\n& steer", 2.1, 2.8),

        ("slope", "giveup", "stuck /\nno response", 1.9, 0.6),
        ("frozen", "end", "all targets\nfrozen & met", 5.6, -0.4),
        ("giveup", "end", "given up &\nreported", 3.9, -1.2),
    ]

    return _draw_straight_graph(
        pos, boxes, edges,
        xlim=(-2, 7), ylim=(-3.8, 6.5), figsize=(10, 10),
        title="Section 2.1: Per-Target Search Loop (One Nash Iteration)",
        outfile="regiCarbonPrice_loop.png"
    )


def held_graph():
    """Figure 2: Decision graph for target FROZEN last iteration (Section 2.4 & 2.5) - Fully Labeled."""
    boxes = {
        "start": ("Measure Deviation |dev|\nTarget evaluation (Section 2.3)", "measure"),
        "small": ("Non-Binding Floor?\nPrice at floor & emissions below target?\n(Section 2.4)", "decide"),
        "smallP": ("smallPrice Market\nFrozen & Met (non-binding market)", "done"),
        "was": ("Target Status?\nWas it frozen last iteration?", "decide"),
        "steering": ("no -> Target STEERING\nSee Decision Graph 2 (Section 2.4)", "act"),

        "hold": ("Hold Condition?\n|dev| > exitFrac x tol\nfor persist=2 iterations (Sec 2.4)", "decide"),
        "keep": ("Stay FROZEN\nRide out iteration wobble", "done"),
        "refresh": ("Settlement Refresh\nSettled for reopenRefresh (24 iter)?\nRe-open budget earned back\n(Section 2.5)", "act"),
        "parked": ("PARKED STOP\nHeld full window outside tol\n-> Give up (Section 2.8)", "giveup"),

        "reopen": ("Re-Open Budget?\n|dev| <= reopenMaxDev\n& budget left? (Section 2.5)", "decide"),
        "reopened": ("RE-OPEN (Charged)\nSteer again (first step\ncapped at reopenStepCap=5%)", "act"),
        "release": ("RELEASE (Uncharged)\nToo far out to be drift", "act"),
        "budgetOut": ("BUDGET SPENT\n(reopenMax=3 exhausted)\n-> Give up", "giveup"),
        "roll": ("PRICE ROLLBACK\nRestore best-so-far or knee price\n(Section 2.9)", "act"),
    }

    pos = {
        "start": (0.0, 6.4),
        "small": (0.0, 4.8),
        "smallP": (14, 4.8),
        "was": (0.0, 3.2),
        "steering": (14, 3.2),

        "hold": (0.0, 1.4),
        "keep": (-12, 1.4),
        "refresh": (-17, -0.6),
        "parked": (-6.5, -0.6),

        "reopen": (6.2, -0.6),
        "budgetOut": (-3, -2.8),
        "reopened": (6.6, -2.8),
        "release": (16, -2.8),
        "roll": (-15, -2.8),
    }

    edges = [
        ("start", "small", "check\nmarket price", 0.4, 5.6),
        ("small", "smallP", "yes\n(slack\nmarket)", 6.6, 5.1),
        ("small", "was", "no", 0.4, 4.0),
        ("was", "hold", "yes\n(was frozen)", 0.4, 2.3),
        ("was", "steering", "no\n(was steering)", 5, 3.5),

        ("hold", "keep", "no\n(ride out\nwobble)", -7, 1.8),
        ("keep", "refresh", "and met\n(24 iters)", -17.4, 0.4),
        ("keep", "parked", "full window\noutside tol", -8.4, 0.4),
        ("hold", "reopen", "yes\n(exits band)", 3.8, 0.4),

        ("reopen", "budgetOut", "no:\nbudget spent", 0.0, -1.6),
        ("reopen", "reopened", "yes\n(budget left)", 5, -1.6),
        ("reopen", "release", "no:\n|dev| too large", 10, -1.6),

        ("parked", "roll", "rollback\nprice", -13, -1.6),
        ("budgetOut", "roll", "rollback\nprice", -9.3, -2.5),
    ]

    return _draw_straight_graph(
        pos, boxes, edges,
        xlim=(-20, 20.0), ylim=(-4, 8.0), figsize=(10, 10),
        title="Decision Graph 1 of 2: Target FROZEN Last Iteration (Section 2.4 & 2.5)",
        outfile="regiCarbonPrice_held.png"
    )


def steering_graph():
    """Figure 3: Decision graph for target STEERING price (Section 2.4 - 2.8) - Fully Labeled."""
    boxes = {
        "enter": ("Target Status\nTarget is STEERING its carbon price", "measure"),
        "aim": ("AIM Band Check\n|dev| <= enterFrac x tol\nfor persist=2 iterations? (Sec 2.4)", "decide"),
        "conv": ("CONVERGED\nFreeze price, label lowerThanTolerance", "done"),
        "accept": ("ACCEPT Band Check\n|dev| <= tol & aim budget\n(aimMaxTries=3) spent? (Sec 2.4)", "decide"),
        "steer": ("Active Price Steering\nSlope fit -> Capped price step\n(Section 2.6 & 2.7)", "act"),

        "noise": ("NOISE FLOOR STOP (Sec 2.8)\nPrice settled & |dev| trapped\nin narrow band outside tol", "giveup"),
        "infeas": ("INFEASIBLE TARGET STOP (Sec 2.8)\nStep pinned at cap, dev stalled\n& one-sided over window", "giveup"),
        "diverge": ("DIVERGENT PATH? (Sec 2.8)\nArmed, dev > divergeFactor x best\nfor 2 iterations, not recovering", "decide"),
        "brake": ("DIVERGENCE BRAKE (Reversible)\nRestore window-best price\n& cap step at 5%", "act"),
        "divstop": ("DIVERGENCE STOP (Sec 2.8)\nBrakes (divergeBrakeMax=2)\nspent -> Give up", "giveup"),
        "roll": ("PRICE ROLLBACK (Section 2.9)\nRestore best price path (verified next iteration by rollbackVerify)", "act"),
    }

    pos = {
        "enter": (0.0, 6.0),
        "aim": (0.0, 4.0),
        "conv": (14.0, 3.0),
        "accept": (0.0, 2.0),
        "steer": (0.0, 0.0),

        "noise": (-12.0, -2),
        "infeas": (0.0, -2),
        "diverge": (12.0, -2),
        "brake": (17, -4.0),
        "divstop": (7, -4.0),
        "roll": (0.0, -6.0),
    }

    edges = [
        ("enter", "aim", "check\nAIM band", 0.4, 5.2),
        ("aim", "conv", "yes\n(|dev| <= 0.75x tol)", 6.2, 3.9),
        ("aim", "accept", "no", 0.4, 3.2),
        ("accept", "conv", "yes\n(|dev| <= 1.0x tol)", 6.3, 2.1),
        ("accept", "steer", "no\n(keep steering)", 0.4, 1.2),

        ("steer", "noise", "trapped\nin noise", -8.2, -0.8),
        ("steer", "infeas", "pinned\nat cap", 0.4, -0.8),
        ("steer", "diverge", "excursion\n> 10x", 8, -0.8),
        ("diverge", "brake", "brakes\nleft", 7.4, -2.9),
        ("diverge", "divstop", "brakes\nspent", 15.2, -2.9),

        ("noise", "roll", "rollback\nprice", -6, -5),
        ("infeas", "roll", "rollback\nprice", -0.8, -5),
        ("divstop", "roll", "rollback\nprice", 5, -5),
    ]

    return _draw_straight_graph(
        pos, boxes, edges,
        xlim=(-20, 20.0), ylim=(-8, 8), figsize=(10, 10),
        title="Decision Graph 2 of 2: Target STEERING Its Price (Section 2.4 - 2.8)",
        outfile="regiCarbonPrice_steering.png"
    )


if __name__ == "__main__":
    loop_graph()
    held_graph()
    steering_graph()
