#!/usr/bin/env python3
"""Standalone tool to render DimOS Blueprint graphs as Mermaid diagrams in the browser.

Usage:
    dimos_graph <python_file> [--no-disconnected] [--port PORT]

The Python file should contain Blueprint instances as module-level variables.
"""

from __future__ import annotations

import argparse
import importlib.util
import os
import sys
from collections import defaultdict
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import TYPE_CHECKING
import json
import webbrowser

if TYPE_CHECKING:
    from dimos.core.blueprints import Blueprint
    from dimos.core.module import Module

# ---------------------------------------------------------------------------
# Colour themes
# ---------------------------------------------------------------------------

THEMES: dict[str, dict[str, list[str]]] = {
    "tailwind": {
        "nodes": [
            "#3b82f6", "#ef4444", "#22c55e", "#8b5cf6", "#f97316",
            "#06b6d4", "#ec4899", "#6366f1", "#eab308", "#14b8a6",
            "#f43f5e", "#84cc16", "#0ea5e9", "#d946ef", "#10b981",
            "#a855f7", "#f59e0b", "#38bdf8", "#fb7185", "#a3e635",
        ],
        "edges": [
            "#60a5fa", "#f87171", "#4ade80", "#a78bfa", "#fb923c",
            "#22d3ee", "#f472b6", "#818cf8", "#facc15", "#2dd4bf",
            "#fb7185", "#a3e635", "#38bdf8", "#e879f9", "#34d399",
            "#c084fc", "#fbbf24", "#67e8f9", "#fda4af", "#bef264",
        ],
    },
}

DEFAULT_THEME = "tailwind"

# Connections to ignore (too noisy)
DEFAULT_IGNORED_CONNECTIONS: set[tuple[str, str]] = set()
DEFAULT_IGNORED_MODULES = {"WebsocketVisModule"}
_COMPACT_ONLY_IGNORED_MODULES = {"WebsocketVisModule"}


class _ColorAssigner:
    def __init__(self, palette: list[str]) -> None:
        self._palette = palette
        self._assigned: dict[str, str] = {}
        self._next = 0

    def __call__(self, key: str) -> str:
        if key not in self._assigned:
            self._assigned[key] = self._palette[self._next % len(self._palette)]
            self._next += 1
        return self._assigned[key]


def _mermaid_id(name: str) -> str:
    return name.replace(" ", "_").replace("-", "_")


def _find_package_root(filepath: str) -> str | None:
    d = os.path.dirname(filepath)
    root = None
    while os.path.isfile(os.path.join(d, "__init__.py")):
        root = d
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    if root is not None:
        return os.path.dirname(root)
    return None


def _load_blueprints(python_file: str) -> list[tuple[str, Blueprint]]:
    filepath = os.path.abspath(python_file)
    if not os.path.isfile(filepath):
        raise FileNotFoundError(filepath)

    pkg_root = _find_package_root(filepath)
    if pkg_root and pkg_root not in sys.path:
        sys.path.insert(0, pkg_root)

    spec = importlib.util.spec_from_file_location("_render_target", filepath)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {filepath}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    from dimos.core.blueprints import Blueprint

    blueprints: list[tuple[str, Blueprint]] = []
    for name, obj in vars(mod).items():
        if name.startswith("_"):
            continue
        if isinstance(obj, Blueprint):
            blueprints.append((name, obj))

    if not blueprints:
        raise RuntimeError("No Blueprint instances found in module globals.")

    blueprints.reverse()
    print(f"Found {len(blueprints)} blueprint(s): {', '.join(n for n, _ in blueprints)}")
    return blueprints


def _render_mermaid(
    blueprint_set: Blueprint,
    *,
    ignored_streams: set[tuple[str, str]] | None = None,
    ignored_modules: set[str] | None = None,
    show_disconnected: bool = False,
    theme: str = DEFAULT_THEME,
) -> tuple[str, dict[str, str], set[str]]:
    """Generate a Mermaid flowchart from a Blueprint.

    Returns (mermaid_code, label_color_map, disconnected_labels).
    """
    if ignored_streams is None:
        ignored_streams = DEFAULT_IGNORED_CONNECTIONS
    if ignored_modules is None:
        if show_disconnected:
            ignored_modules = DEFAULT_IGNORED_MODULES - _COMPACT_ONLY_IGNORED_MODULES
        else:
            ignored_modules = DEFAULT_IGNORED_MODULES

    producers: dict[tuple[str, type], list[type[Module]]] = defaultdict(list)
    consumers: dict[tuple[str, type], list[type[Module]]] = defaultdict(list)
    module_names: set[str] = set()

    for bp in blueprint_set.blueprints:
        if bp.module.__name__ in ignored_modules:
            continue
        module_names.add(bp.module.__name__)
        for conn in bp.streams:
            remapped_name = blueprint_set.remapping_map.get((bp.module, conn.name), conn.name)
            key = (remapped_name, conn.type)
            if conn.direction == "out":
                producers[key].append(bp.module)
            else:
                consumers[key].append(bp.module)

    active_keys: list[tuple[str, type]] = []
    for key in producers:
        name, type_ = key
        if key not in consumers:
            continue
        if (name, type_.__name__) in ignored_streams:
            continue
        valid_p = [m for m in producers[key] if m.__name__ not in ignored_modules]
        valid_c = [m for m in consumers[key] if m.__name__ not in ignored_modules]
        if valid_p and valid_c:
            active_keys.append(key)

    disconnected_keys: list[tuple[str, type]] = []
    if show_disconnected:
        all_keys = set(producers.keys()) | set(consumers.keys())
        for key in all_keys:
            if key in active_keys:
                continue
            name, type_ = key
            if (name, type_.__name__) in ignored_streams:
                continue
            relevant = producers.get(key, []) + consumers.get(key, [])
            if all(m.__name__ in ignored_modules for m in relevant):
                continue
            disconnected_keys.append(key)

    palette = THEMES.get(theme, THEMES[DEFAULT_THEME])
    node_color = _ColorAssigner(palette["nodes"])
    edge_color = _ColorAssigner(palette["edges"])

    lines = ["graph LR"]

    sorted_modules = sorted(module_names)
    for mod_name in sorted_modules:
        mid = _mermaid_id(mod_name)
        lines.append(f"    {mid}([{mod_name}]):::moduleNode")

    lines.append("")

    edge_idx = 0
    edge_colors: list[str] = []
    label_color_map: dict[str, str] = {}
    stream_node_ids: dict[str, str] = {}
    disconnected_labels: set[str] = set()

    lines.append("    %% Stream nodes and edges")
    for key in sorted(active_keys, key=lambda k: f"{k[0]}:{k[1].__name__}"):
        name, type_ = key
        label = f"{name}:{type_.__name__}"
        color = edge_color(label)
        label_color_map[label] = color

        valid_producers = [m for m in producers[key] if m.__name__ not in ignored_modules]
        valid_consumers = [m for m in consumers[key] if m.__name__ not in ignored_modules]

        for prod in valid_producers:
            sn_id = _mermaid_id(f"{prod.__name__}_{name}_{type_.__name__}")
            if sn_id not in stream_node_ids:
                lines.append(f"    {sn_id}[{label}]:::streamNode")
                stream_node_ids[sn_id] = color

            pid = _mermaid_id(prod.__name__)
            lines.append(f"    {pid} --- {sn_id}")
            edge_colors.append(node_color(prod.__name__))
            edge_idx += 1

            for cons in valid_consumers:
                cid = _mermaid_id(cons.__name__)
                lines.append(f"    {sn_id} --> {cid}")
                edge_colors.append(color)
                edge_idx += 1

    if disconnected_keys:
        lines.append("")
        lines.append("    %% Disconnected streams")
        for key in sorted(disconnected_keys, key=lambda k: f"{k[0]}:{k[1].__name__}"):
            name, type_ = key
            label = f"{name}:{type_.__name__}"
            color = edge_color(label)
            label_color_map[label] = color
            disconnected_labels.add(label)

            for prod in producers.get(key, []):
                if prod.__name__ in ignored_modules:
                    continue
                sn_id = _mermaid_id(f"{prod.__name__}_{name}_{type_.__name__}")
                if sn_id not in stream_node_ids:
                    lines.append(f"    {sn_id}[{label}]:::streamNode")
                    stream_node_ids[sn_id] = color
                pid = _mermaid_id(prod.__name__)
                lines.append(f"    {pid} -.- {sn_id}")
                edge_colors.append(node_color(prod.__name__))
                edge_idx += 1

            for cons in consumers.get(key, []):
                if cons.__name__ in ignored_modules:
                    continue
                sn_id = _mermaid_id(f"dangling_{name}_{type_.__name__}")
                if sn_id not in stream_node_ids:
                    lines.append(f"    {sn_id}[{label}]:::streamNode")
                    stream_node_ids[sn_id] = color
                cid = _mermaid_id(cons.__name__)
                lines.append(f"    {sn_id} -.-> {cid}")
                edge_colors.append(color)
                edge_idx += 1

    lines.append("")
    for mod_name in sorted_modules:
        mid = _mermaid_id(mod_name)
        c = node_color(mod_name)
        lines.append(f"    style {mid} fill:{c}bf,stroke:{c},color:#eee,stroke-width:2px")

    for sn_id, color in stream_node_ids.items():
        lines.append(
            f"    style {sn_id} fill:transparent,stroke:{color},color:{color},stroke-width:1px"
        )

    if edge_colors:
        lines.append("")
        for i, c in enumerate(edge_colors):
            lines.append(f"    linkStyle {i} stroke:{c},stroke-width:2px")

    return "\n".join(lines), label_color_map, disconnected_labels


def _build_html(python_file: str, *, show_disconnected: bool = True) -> str:
    blueprints = _load_blueprints(python_file)

    # Build per-blueprint label color maps so each tab colours its own edges
    per_bp_label_colors: list[dict[str, str]] = []
    per_bp_disconnected: list[set[str]] = []

    tab_buttons = []
    tab_panels = []
    for idx, (name, bp) in enumerate(blueprints):
        mermaid_code, label_colors, disconnected = _render_mermaid(
            bp, show_disconnected=show_disconnected
        )
        per_bp_label_colors.append(label_colors)
        per_bp_disconnected.append(disconnected)

        active_cls = " active" if idx == 0 else ""
        tab_buttons.append(
            f'<button class="tab-btn{active_cls}" data-idx="{idx}">{name}</button>'
        )
        tab_panels.append(
            f'<div class="tab-panel{active_cls}" data-idx="{idx}">'
            f'<div class="viewport"><div class="canvas">'
            f'<pre class="mermaid">\n{mermaid_code}\n</pre>'
            f"</div></div></div>"
        )

    all_label_colors_json = json.dumps(per_bp_label_colors)
    all_disconnected_json = json.dumps([sorted(d) for d in per_bp_disconnected])

    # Only show the tab bar when there are multiple blueprints
    tab_bar_html = ""
    if len(blueprints) > 1:
        tab_bar_html = f'<div class="tab-bar">{"".join(tab_buttons)}</div>'

    return f"""\
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<title>Blueprint Diagrams</title>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{ background: #1e1e1e; color: #ccc; font-family: sans-serif; overflow: hidden; height: 100vh; }}
.tab-bar {{
    display: flex; gap: 0; border-bottom: 1px solid #444; background: #252525;
    position: relative; z-index: 2;
}}
.tab-btn {{
    background: transparent; color: #888; border: none; border-bottom: 2px solid transparent;
    padding: 0.6em 1.4em; font-size: 0.95em; cursor: pointer; white-space: nowrap;
}}
.tab-btn:hover {{ color: #ccc; background: #2a2a2a; }}
.tab-btn.active {{ color: #eee; border-bottom-color: #60a5fa; background: #1e1e1e; }}
.tab-panel.hidden {{ display: none; }}
.viewport {{
    width: 100%; height: calc(100vh - 2.6em);
    overflow: hidden; cursor: grab; position: relative;
}}
.viewport.grabbing {{ cursor: grabbing; }}
.canvas {{
    transform-origin: 0 0;
    position: absolute;
    padding: 2em;
}}
.controls {{
    position: fixed; bottom: 1.2em; right: 1.2em; z-index: 10;
    display: flex; gap: 0.4em; background: #2a2a2a; border-radius: 6px;
    padding: 0.3em; border: 1px solid #444;
}}
.controls button {{
    background: #333; color: #ccc; border: 1px solid #555; border-radius: 4px;
    width: 2.2em; height: 2.2em; font-size: 1em; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
}}
.controls button:hover {{ background: #444; }}
.edgeLabel rect, .edgeLabel polygon {{ fill: rgba(30,30,30,0.7) !important; stroke: none !important; rx: 6; ry: 6; }}
.edgeLabel .label-container {{ background: rgba(30,30,30,0.7) !important; border-radius: 6px; }}
.edgeLabel foreignObject div, .edgeLabel foreignObject span, .edgeLabel foreignObject p {{
    background: rgba(30,30,30,0.7) !important; background-color: rgba(30,30,30,0.7) !important;
    border-radius: 6px; padding: 2px 6px;
}}
.moduleNode .nodeLabel {{ font-size: 38px !important; font-weight: 600 !important; display: block !important; transform: scale(0.7) !important; }}
.streamNode .nodeLabel {{ font-size: 18px !important; }}
</style>
</head><body>
{tab_bar_html}
{"".join(tab_panels)}
<div class="controls">
    <button id="zoomIn" title="Zoom in">+</button>
    <button id="zoomOut" title="Zoom out">&minus;</button>
    <button id="resetView" title="Reset view">&#8634;</button>
</div>
<script type="module">
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
mermaid.initialize({{
    startOnLoad: true,
    theme: 'dark',
    flowchart: {{
        curve: 'basis',
        padding: 8,
        nodeSpacing: 60,
        rankSpacing: 80,
    }},
}});

await mermaid.run();

const allLabelColors = {all_label_colors_json};
const allDisconnected = {all_disconnected_json};

function setupViewport(vp, labelColors, disconnectedList) {{
    const canvas = vp.querySelector('.canvas');
    const svg = canvas.querySelector('svg');
    if (!svg) return;
    let scale, panX, panY;
    let dragging = false, startX, startY;

    svg.querySelectorAll('.node').forEach(node => {{
        const rect = node.querySelector('rect');
        if (!rect) return;
        const w = parseFloat(rect.getAttribute('width'));
        const h = parseFloat(rect.getAttribute('height'));
        const x = parseFloat(rect.getAttribute('x'));
        const y = parseFloat(rect.getAttribute('y'));
        if (!w || !h) return;
        const isStream = rect.getAttribute('style')?.includes('fill: transparent') ||
                         rect.style.fill === 'transparent';
        if (isStream) {{
            const gx = 4, gy = 2;
            rect.setAttribute('width', w + gx * 2);
            rect.setAttribute('height', h + gy * 2);
            rect.setAttribute('x', x - gx);
            rect.setAttribute('y', y - gy);
            node.querySelectorAll('span, text, div').forEach(el => {{
                el.style.fontSize = '14px';
            }});
        }} else {{
            const gx = 30, gy = 18;
            rect.setAttribute('width', w + gx * 2);
            rect.setAttribute('height', h + gy * 2);
            rect.setAttribute('x', x - gx);
            rect.setAttribute('y', y - gy);
        }}
    }});

    svg.querySelectorAll('.edgeLabel').forEach(label => {{
        const fo = label.querySelector('foreignObject');
        if (fo) {{
            fo.setAttribute('height', '35');
            const div = fo.querySelector('div');
            if (div) {{
                const span = document.createElement('span');
                span.textContent = div.textContent;
                span.style.cssText = div.querySelector('span')?.style.cssText || '';
                span.style.display = 'inline-flex';
                span.style.alignItems = 'center';
                span.style.height = '100%';
                div.replaceWith(span);
            }}
        }}
        const rect = label.querySelector('rect');
        if (rect) {{ rect.setAttribute('rx', '6'); rect.setAttribute('ry', '6'); }}
    }});

    const disconnectedLabels = new Set(disconnectedList);
    svg.querySelectorAll('.edgeLabel').forEach(label => {{
        const text = (label.textContent || '').trim();
        const color = labelColors[text];
        if (!color) return;
        label.querySelectorAll('span, p, text').forEach(el => {{
            if (el.tagName === 'text') el.setAttribute('fill', color);
            else el.style.color = color;
        }});
        if (disconnectedLabels.has(text)) {{
            label.querySelectorAll('span').forEach(span => {{
                span.style.border = `dashed ${{color}} 1px`;
                span.style.borderRadius = '4px';
                span.style.padding = '2px 6px';
            }});
        }}
    }});

    function fitToView() {{
        const vpRect = vp.getBoundingClientRect();
        canvas.style.transform = 'none';
        const svgRect = svg.getBoundingClientRect();
        const svgW = svgRect.width;
        const svgH = svgRect.height;
        const pad = 40;
        scale = Math.min((vpRect.width - pad) / svgW, (vpRect.height - pad) / svgH);
        scale = Math.max(scale * 2, 0.2);
        panX = (vpRect.width - svgW * scale) / 2;
        panY = (vpRect.height - svgH * scale) / 2;
        apply();
    }}

    function apply() {{
        canvas.style.transform = `translate(${{panX}}px, ${{panY}}px) scale(${{scale}})`;
    }}

    fitToView();

    vp.addEventListener('wheel', e => {{
        e.preventDefault();
        const rect = vp.getBoundingClientRect();
        const mx = e.clientX - rect.left;
        const my = e.clientY - rect.top;
        const factor = e.deltaY < 0 ? 1.12 : 1 / 1.12;
        const newScale = Math.min(Math.max(scale * factor, 0.05), 50);
        panX = mx - (mx - panX) * (newScale / scale);
        panY = my - (my - panY) * (newScale / scale);
        scale = newScale;
        apply();
    }}, {{ passive: false }});

    vp.addEventListener('mousedown', e => {{
        if (e.button !== 0) return;
        dragging = true; startX = e.clientX - panX; startY = e.clientY - panY;
        vp.classList.add('grabbing');
    }});
    window.addEventListener('mousemove', e => {{
        if (!dragging) return;
        panX = e.clientX - startX; panY = e.clientY - startY;
        apply();
    }});
    window.addEventListener('mouseup', () => {{
        dragging = false;
        vp.classList.remove('grabbing');
    }});

    // Expose fitToView so tab switch can re-fit
    vp._fitToView = fitToView;

    document.getElementById('zoomIn').addEventListener('click', () => {{
        const rect = vp.getBoundingClientRect();
        const cx = rect.width / 2, cy = rect.height / 2;
        const newScale = Math.min(scale * 1.3, 50);
        panX = cx - (cx - panX) * (newScale / scale);
        panY = cy - (cy - panY) * (newScale / scale);
        scale = newScale; apply();
    }});
    document.getElementById('zoomOut').addEventListener('click', () => {{
        const rect = vp.getBoundingClientRect();
        const cx = rect.width / 2, cy = rect.height / 2;
        const newScale = Math.max(scale / 1.3, 0.05);
        panX = cx - (cx - panX) * (newScale / scale);
        panY = cy - (cy - panY) * (newScale / scale);
        scale = newScale; apply();
    }});
    document.getElementById('resetView').addEventListener('click', () => {{
        fitToView();
    }});
}}

// All panels are visible right now — set up every viewport
document.querySelectorAll('.tab-panel').forEach((panel, idx) => {{
    const vp = panel.querySelector('.viewport');
    if (vp) setupViewport(vp, allLabelColors[idx] || {{}}, allDisconnected[idx] || []);
}});

// Now hide the non-active panels
document.querySelectorAll('.tab-panel:not(.active)').forEach(p => p.classList.add('hidden'));

// Tab switching
document.querySelectorAll('.tab-btn').forEach(btn => {{
    btn.addEventListener('click', () => {{
        const idx = btn.dataset.idx;
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-panel').forEach(p => {{
            p.classList.remove('active');
            p.classList.add('hidden');
        }});
        btn.classList.add('active');
        const panel = document.querySelector(`.tab-panel[data-idx="${{idx}}"]`);
        panel.classList.add('active');
        panel.classList.remove('hidden');
        const vp = panel.querySelector('.viewport');
        if (vp && vp._fitToView) setTimeout(() => vp._fitToView(), 0);
    }});
}});
</script>
</body></html>"""


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Render DimOS Blueprint graphs as Mermaid diagrams in the browser."
    )
    parser.add_argument("python_file", help="Python file containing Blueprint globals")
    parser.add_argument(
        "--no-disconnected",
        action="store_true",
        help="Hide disconnected streams",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=0,
        help="HTTP server port (0 = random free port)",
    )
    parser.add_argument(
        "--markdown",
        action="store_true",
        help="Print Mermaid markdown to stdout and exit",
    )
    args = parser.parse_args()

    show_disconnected = not args.no_disconnected

    if args.markdown:
        blueprints = _load_blueprints(args.python_file)
        sections: list[str] = []
        for name, bp in blueprints:
            mermaid_code, _, _ = _render_mermaid(bp, show_disconnected=show_disconnected)
            sections.append(f"## {name}\n\n```mermaid\n{mermaid_code}\n```")
        print("\n\n".join(sections))
        return

    html = _build_html(args.python_file, show_disconnected=show_disconnected)
    html_bytes = html.encode("utf-8")

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self) -> None:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(html_bytes)))
            self.end_headers()
            self.wfile.write(html_bytes)

        def log_message(self, format: str, *args: object) -> None:
            pass

    server = HTTPServer(("0.0.0.0", args.port), Handler)
    actual_port = server.server_address[1]
    url = f"http://localhost:{actual_port}"
    print(f"Serving at {url}  (will exit after first request)")
    webbrowser.open(url)
    server.handle_request()
    print("Served. Exiting.")


if __name__ == "__main__":
    main()
