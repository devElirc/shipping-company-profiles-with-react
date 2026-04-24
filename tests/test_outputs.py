"""On-disk unit checks for the shipping company profiles task.

These run after ``npm run build`` in ``/app`` and before Playwright end-to-end tests.
They scan the agent's source tree and production artifacts for the behaviors described
in ``instruction.md`` (structure, copy, motion hooks, accessibility hooks, Vite React
plugin wiring, and the ``createRoot`` mount on ``#root``). They do not replace Playwright;
they catch missing wiring before the browser suite runs.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

EXPECTED_COMPANY_DATA = """const companies = [
  {
    id: "atlas-freight",
    name: "Atlas Freight Lines International",
    logoUrl: "/atlas-logo.svg",
    verifiedIconUrl: "/verified-badge.svg",
    averageRating: 4.7,
    reviewCount: 214,
    metrics: {
      pricingAccuracy: 92,
      communication: 88,
      vehicleCondition: 95,
    },
  },
  {
    id: "nova-transport",
    name: "Nova Transport Partners",
    logoUrl: "",
    verifiedIconUrl: "/verified-badge.svg",
    averageRating: 4.2,
    reviewCount: 87,
    metrics: {
      pricingAccuracy: 82,
      communication: 91,
      vehicleCondition: 86,
    },
  },
  {
    id: "echo-logistics",
    name: "Echo Logistics Group",
    logoUrl: "",
    verifiedIconUrl: "/verified-badge.svg",
    averageRating: null,
    reviewCount: null,
    metrics: {
      pricingAccuracy: 70,
      communication: 75,
      vehicleCondition: 68,
    },
  },
];

export default companies;
"""


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _collect_under(root: Path, suffixes: tuple[str, ...]) -> str:
    if not root.is_dir():
        return ""
    chunks: list[str] = []
    for path in sorted(root.rglob("*")):
        if path.is_file() and path.suffix.lower() in suffixes:
            chunks.append(_read_text(path))
    return "\n".join(chunks)


def _app_workspace_text() -> str:
    pieces: list[str] = []
    for rel in ("index.html", "vite.config.js", "vite.config.ts", "vite.config.mjs"):
        p = Path("/app") / rel
        if p.is_file():
            pieces.append(_read_text(p))
    pieces.append(_collect_under(Path("/app/src"), (".js", ".jsx", ".ts", ".tsx", ".css")))
    return "\n".join(pieces)


def _dist_workspace_text() -> str:
    root = Path("/app/dist")
    if not root.is_dir():
        return ""
    chunks: list[str] = []
    for path in sorted(root.rglob("*")):
        if path.is_file() and path.suffix.lower() in {".html", ".js", ".css"}:
            chunks.append(_read_text(path))
    return "\n".join(chunks)


def test_company_data_source_is_unchanged():
    """Verify /app/src/companyData.js still matches the seeded benchmark payload."""
    path = Path("/app/src/companyData.js")
    assert path.is_file()
    assert _read_text(path) == EXPECTED_COMPANY_DATA


def test_public_seed_assets_exist():
    """Verify logo and verified badge assets shipped in the image are still present."""
    assert Path("/app/public/atlas-logo.svg").is_file()
    assert Path("/app/public/verified-badge.svg").is_file()


def test_production_build_emitted_html_shell():
    """Verify Vite wrote /app/dist/index.html referencing the client bundle after build."""
    path = Path("/app/dist/index.html")
    assert path.is_file()
    text = _read_text(path)
    assert "root" in text
    assert "/assets/" in text or "assets/" in text


def test_production_build_emitted_javascript_bundle():
    """Verify the production build produced at least one non-empty JS asset."""
    assets = Path("/app/dist/assets")
    assert assets.is_dir()
    bundles = sorted(assets.glob("*.js"))
    assert len(bundles) >= 1
    assert bundles[0].stat().st_size > 100


def test_package_json_declares_app_tooling():
    """Verify /app/package.json lists react, react-dom, and vite so the tree is a Vite React app."""
    data = json.loads(_read_text(Path("/app/package.json")))
    deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
    assert "react" in deps
    assert "react-dom" in deps
    assert "vite" in deps


def test_workspace_imports_company_catalog():
    """Verify application source imports the seeded catalog module."""
    text = _app_workspace_text()
    assert re.search(r'from\s+["\']\./companyData(\.js)?["\']', text) or re.search(
        r'from\s+["\']/src/companyData(\.js)?["\']', text
    ), "Expected an ES module import of ./companyData (or equivalent) in /app sources."


def test_workspace_mounts_react_root():
    """Verify the client entry calls createRoot against the #root container."""
    text = _app_workspace_text()
    assert "createRoot" in text, "Expected React createRoot in the client entry."
    assert re.search(r'getElementById\s*\(\s*["\']root["\']\s*\)', text), (
        "Expected document.getElementById('root') (or equivalent) in the client entry."
    )


def test_workspace_references_vite_react_plugin():
    """Verify Vite config wires the official React plugin."""
    text = _app_workspace_text()
    assert "@vitejs/plugin-react" in text or "plugin-react" in text
    assert "defineConfig" in text or "vite" in text.lower()


def test_sources_model_company_cards_and_headings():
    """Verify JSX/TSX sources render company cards with article landmarks and title headings."""
    text = _app_workspace_text()
    assert "<article" in text or "React.createElement(\"article\"" in text or "createElement('article'" in text, (
        "Expected an <article> element (or createElement('article')) for each company card."
    )
    assert "<h2" in text or 'createElement("h2"' in text or "createElement('h2'" in text


def test_sources_include_verified_trust_and_badge_copy():
    """Verify user-visible strings for verification, trust label, and the three badge chips."""
    text = _app_workspace_text()
    assert "Verified company" in text, "Expected verified badge alt text 'Verified company'."
    assert "Trust Score" in text
    for label in ("Verified", "Top Reviewed", "Customer Favorite"):
        assert label in text, f"Expected badge copy {label!r} in application sources."


def test_sources_use_html_list_for_badges():
    """Verify badge chips are modeled as a list (native ul/li or explicit list roles)."""
    text = _app_workspace_text()
    list_markup = "<ul" in text and "<li" in text
    list_roles = 'role="list"' in text or "role='list'" in text
    assert list_markup or list_roles, (
        "Expected badge row to use a real list (e.g. ul/li) or role='list' with listitem children."
    )


def test_sources_reference_progressbar_and_metric_labels():
    """Verify metric rows expose progressbar semantics and the three metric names."""
    text = _app_workspace_text()
    lowered = text.lower()
    assert "progressbar" in lowered
    assert "aria-valuenow" in lowered
    for label in ("Pricing Accuracy", "Communication", "Vehicle Condition"):
        assert label in text


def test_sources_include_css_motion_and_layout_hooks():
    """Verify styles define the required keyframes, mobile breakpoint, and reduced-motion guard."""
    text = _app_workspace_text()
    assert "@keyframes ring-fill" in text
    assert "@keyframes metric-grow" in text
    assert "@keyframes stripes" in text
    assert "@media (max-width: 640px)" in text
    assert "prefers-reduced-motion" in text


def test_bundled_assets_retain_user_facing_strings():
    """Verify the production JS/CSS payload still embeds critical UI copy (minifiers keep literals)."""
    blob = _dist_workspace_text()
    assert "Trust Score" in blob
    assert "Pricing Accuracy" in blob
    assert "Verified company" in blob
