#!/usr/bin/env python3
"""Extraordinary control-plane integrity audit for the framework repo and adopted workspaces.

This tool is intentionally outside the normal flow of work. Use it for
publication checks, suspicious migrations, or structural drift audits.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


VALID_VALUES = {
    "adoption mode": {"greenfield", "migration", "code_first", "unknown"},
    "adoption procedure": {"starter_guided", "unknown"},
    "manual bootstrap status": {
        "pending",
        "in-progress",
        "completed",
        "skipped_by_user",
        "unknown",
    },
    "manual readiness level": {"not_started", "basic", "operational", "unknown"},
    "manual override acknowledged": {"yes", "no", "unknown"},
    "code bootstrap mode": {
        "not_required",
        "local_code_first_derivation",
        "external_source_integration",
        "unknown",
    },
    "code bootstrap status": {
        "not_required",
        "pending",
        "in-progress",
        "completed",
        "unknown",
    },
    "code bootstrap source type": {
        "local_project",
        "filesystem_repo",
        "git_repo",
        "url",
        "web_research",
        "archive",
        "pasted_code",
        "none",
        "unknown",
    },
    "code bootstrap requested output": {
        "not_required",
        "bootstrap_docs_only",
        "understanding_only",
        "integration_recommendation",
        "new_impl_required",
        "implementation_candidate",
        "unknown",
    },
    "procedure completed": {"yes", "no", "in-progress"},
}

OVERLAY_LOCATION_ROWS = {
    "Requirements baseline",
    "Interactions",
    "Requirement diffs",
    "Implementation packets",
    "Implementation packet index",
    "Test campaigns",
    "Traceability matrix",
}


@dataclass
class Issue:
    severity: str
    code: str
    message: str


class LintResult:
    def __init__(self, mode: str, root: Path) -> None:
        self.mode = mode
        self.root = root
        self.issues: list[Issue] = []

    def error(self, code: str, message: str) -> None:
        self.issues.append(Issue("error", code, message))

    def warning(self, code: str, message: str) -> None:
        self.issues.append(Issue("warning", code, message))

    def ok(self, message: str) -> None:
        print(f"OK: {message}")

    def has_errors(self) -> bool:
        return any(issue.severity == "error" for issue in self.issues)

    def emit(self) -> int:
        for issue in self.issues:
            print(f"{issue.severity.upper()}: [{issue.code}] {issue.message}")
        errors = sum(1 for issue in self.issues if issue.severity == "error")
        warnings = sum(1 for issue in self.issues if issue.severity == "warning")
        print(
            f"SUMMARY: mode={self.mode} root={self.root} "
            f"errors={errors} warnings={warnings}"
        )
        return 1 if errors else 0


def read_text(result: LintResult, path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        result.error("missing-file", f"Missing file: {path}")
    except OSError as exc:
        result.error("read-failed", f"Cannot read {path}: {exc}")
    return ""


def require_exists(result: LintResult, root: Path, relpath: str) -> Path:
    path = root / relpath
    if not path.exists():
        result.error("missing-file", f"Expected path not found: {relpath}")
    return path


def normalize_label(label: str) -> str:
    return " ".join(label.strip().lower().split())


def extract_section(text: str, heading: str) -> str:
    pattern = re.compile(
        rf"(?ms)^{re.escape(heading)}\n(.*?)(?=^##\s|\Z)"
    )
    match = pattern.search(text)
    return match.group(1) if match else ""


def parse_strong_fields(text: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for match in re.finditer(r"(?m)^\*\*(.+?):\*\*\s*(.+?)\s*$", text):
        fields[normalize_label(match.group(1))] = match.group(2).strip()
    return fields


def parse_markdown_table(section_text: str) -> list[list[str]]:
    rows: list[list[str]] = []
    for raw_line in section_text.splitlines():
        line = raw_line.strip()
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if all(re.fullmatch(r"[:\- ]+", cell) for cell in cells):
            continue
        rows.append(cells)
    return rows


def parse_overlay_map(section_text: str) -> dict[str, tuple[str, str]]:
    table_rows = parse_markdown_table(section_text)
    entries: dict[str, tuple[str, str]] = {}
    for row in table_rows[1:]:
        if len(row) != 3:
            continue
        doc_type, default_location, actual_location = row
        entries[doc_type] = (default_location, actual_location)
    return entries


def resolve_declared_path(
    result: LintResult,
    root: Path,
    default_location: str,
    actual_location: str,
    row_name: str,
) -> Path | None:
    actual = actual_location.strip().strip("`")
    default = default_location.strip().strip("`")
    if actual.lower() == "default":
        chosen = default
    else:
        chosen = actual
    if not chosen or "[" in chosen or "]" in chosen:
        result.error(
            "overlay-map-placeholder",
            f"Document location map row '{row_name}' is still placeholder-like: {actual_location}",
        )
        return None
    path = Path(chosen)
    if not path.is_absolute():
        path = root / path
    return path


def check_allowed_value(
    result: LintResult,
    fields: dict[str, str],
    key: str,
) -> None:
    value = fields.get(key)
    if value is None:
        result.error("missing-overlay-field", f"Missing overlay field: {key}")
        return
    if value not in VALID_VALUES[key]:
        result.error(
            "invalid-overlay-value",
            f"Invalid value for '{key}': {value}",
        )


def check_substring_order(
    result: LintResult,
    text: str,
    first: str,
    second: str,
    code: str,
    message: str,
) -> None:
    first_index = text.find(first)
    second_index = text.find(second)
    if first_index == -1 or second_index == -1 or first_index > second_index:
        result.error(code, message)


def check_framework_mode(result: LintResult) -> None:
    root = result.root
    required_files = [
        "README.md",
        "STARTER.md",
        "CODE-BOOTSTRAP.md",
        "WHY.md",
        "tools/CONTROL-PLANE-LINT-SPEC.md",
        "templates/AGENT-TEMPLATE.md",
        "templates/PROJECT-OVERLAY.md",
        "templates/IMPL-INDEX.md",
        "templates/TRACEABILITY_MATRIX.md",
        "templates/REQUIREMENTS-DIFF-TEMPLATE.md",
        "templates/IMPL-TEMPLATE.md",
        "templates/TEST-CAMPAIGN-TEMPLATE.md",
        "manual/MANUAL-BOOTSTRAP.md",
        "manual/REACHING-THE-LLMS.md",
        "flow-of-work-contract/00-INDEX.md",
        "flow-of-work-contract/01-LLM-SESSION-CONTRACT.md",
        "flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md",
        "flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md",
        "flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md",
        "flow-of-work-contract/05-PROJECT-STRUCTURE.md",
    ]
    for relpath in required_files:
        require_exists(result, root, relpath)

    if (root / "MANUAL-STARTER.md").exists():
        result.error(
            "legacy-manual-starter",
            "MANUAL-STARTER.md still exists in the framework repo",
        )

    core_docs = [
        "README.md",
        "STARTER.md",
        "CODE-BOOTSTRAP.md",
        "WHY.md",
        "templates/AGENT-TEMPLATE.md",
        "templates/PROJECT-OVERLAY.md",
        "templates/IMPL-INDEX.md",
        "templates/TRACEABILITY_MATRIX.md",
        "templates/REQUIREMENTS-DIFF-TEMPLATE.md",
        "templates/IMPL-TEMPLATE.md",
        "templates/TEST-CAMPAIGN-TEMPLATE.md",
        "manual/MANUAL-BOOTSTRAP.md",
        "manual/REACHING-THE-LLMS.md",
        "flow-of-work-contract/00-INDEX.md",
        "flow-of-work-contract/01-LLM-SESSION-CONTRACT.md",
        "flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md",
        "flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md",
        "flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md",
        "flow-of-work-contract/05-PROJECT-STRUCTURE.md",
    ]
    forbidden_refs = {
        "MANUAL-STARTER.md": "legacy-manual-starter-ref",
        "starter_manual": "legacy-starter-manual-value",
        "templates/AGENT.md": "old-agent-template-path",
        "AGENT-TEMPORARY-COMPACT.md": "temporary-agent-ref",
        "PROJECT-OVERLAY-TEMPORARY-CODE-BOOTSTRAP.md": "temporary-overlay-ref",
        "CODE-BOOTSTRAP-TEMPORARY-INTEGRATION.md": "temporary-bootstrap-ref",
    }
    for relpath in core_docs:
        text = read_text(result, root / relpath)
        for forbidden, code in forbidden_refs.items():
            if forbidden in text:
                result.error(
                    code,
                    f"Forbidden reference '{forbidden}' still present in {relpath}",
                )

    readme = read_text(result, root / "README.md")
    if "`manual/MANUAL-BOOTSTRAP.md`" not in readme:
        result.error(
            "missing-readme-manual-bootstrap",
            "README.md does not point to manual/MANUAL-BOOTSTRAP.md",
        )
    if "`STARTER.md`" not in readme:
        result.error("missing-readme-starter", "README.md does not point to STARTER.md")

    agent_template = read_text(result, root / "templates/AGENT-TEMPLATE.md")
    check_substring_order(
        result,
        agent_template,
        "overlay sec. 8",
        "overlay sec. 9",
        "agent-ordering",
        "AGENT-TEMPLATE.md must inspect overlay sec. 8 before sec. 9",
    )
    if "authorities/manual/MANUAL-BOOTSTRAP.md" not in agent_template:
        result.error(
            "agent-manual-bootstrap",
            "AGENT-TEMPLATE.md does not route to authorities/manual/MANUAL-BOOTSTRAP.md",
        )
    if "CODE-BOOTSTRAP.md" not in agent_template:
        result.error(
            "agent-code-bootstrap",
            "AGENT-TEMPLATE.md does not route to CODE-BOOTSTRAP.md",
        )

    overlay_template = read_text(result, root / "templates/PROJECT-OVERLAY.md")
    for required_heading in (
        "## 8. Manual Onboarding State",
        "## 9. Code Bootstrap State",
        "## 10. Document Location Map",
    ):
        if required_heading not in overlay_template:
            result.error(
                "overlay-missing-section",
                f"PROJECT-OVERLAY.md missing section: {required_heading}",
            )
    for required_field in (
        "Manual bootstrap status",
        "Manual readiness level",
        "Manual override acknowledged",
        "Code bootstrap mode",
        "Code bootstrap status",
        "Code bootstrap source type",
        "Code bootstrap requested output",
    ):
        if f"**{required_field}:**" not in overlay_template:
            result.error(
                "overlay-missing-field",
                f"PROJECT-OVERLAY.md missing field template: {required_field}",
            )

    starter = read_text(result, root / "STARTER.md")
    if "- `authorities/manual/*`" not in starter:
        result.error(
            "starter-install-set-manual",
            "STARTER.md required install set does not include authorities/manual/*",
        )
    for template_name in (
        "REQUIREMENTS-DIFF-TEMPLATE.md",
        "IMPL-TEMPLATE.md",
        "TEST-CAMPAIGN-TEMPLATE.md",
    ):
        if template_name not in starter:
            result.error(
                "starter-install-set-category-template",
                f"STARTER.md required install set does not include {template_name}",
            )
    if "- `STARTER.md`" not in starter:
        result.error(
            "starter-non-install-set",
            "STARTER.md non-install set does not include STARTER.md",
        )
    check_substring_order(
        result,
        starter,
        "overlay sec. 8",
        "overlay sec. 9",
        "starter-handoff-ordering",
        "STARTER.md must describe overlay sec. 8 routing before overlay sec. 9 routing",
    )

    structure_doc = read_text(result, root / "flow-of-work-contract/05-PROJECT-STRUCTURE.md")
    if "`authorities/manual/`" not in structure_doc:
        result.error(
            "structure-manual-folder",
            "05-PROJECT-STRUCTURE.md does not declare authorities/manual/",
        )
    for template_name in (
        "REQUIREMENTS-DIFF-TEMPLATE.md",
        "IMPL-TEMPLATE.md",
        "TEST-CAMPAIGN-TEMPLATE.md",
    ):
        if template_name not in structure_doc:
            result.error(
                "structure-category-template",
                f"05-PROJECT-STRUCTURE.md does not declare {template_name}",
            )
    if "Temporary adoption-only root files" not in structure_doc or "`STARTER.md`" not in structure_doc:
        result.error(
            "structure-temporary-root",
            "05-PROJECT-STRUCTURE.md does not describe STARTER.md as the temporary adoption-only root file",
        )


def check_workspace_mode(result: LintResult) -> None:
    root = result.root
    required_paths = [
        "AGENT.md",
        "CODE-BOOTSTRAP.md",
        "authorities/PROJECT-OVERLAY.md",
        "authorities/TRACEABILITY_MATRIX.md",
        "authorities/flow-of-work-contract/00-INDEX.md",
        "authorities/manual/MANUAL-BOOTSTRAP.md",
        "authorities/manual/REACHING-THE-LLMS.md",
    ]
    for relpath in required_paths:
        require_exists(result, root, relpath)

    agent_path = root / "AGENT.md"
    agent_text = read_text(result, agent_path)
    if "## 1. Initialization Check" in agent_text:
        result.error(
            "runtime-agent-template-leak",
            "AGENT.md still contains the template-only Initialization Check section",
        )
    if "route the user to the framework repo" in agent_text or "STARTER.md" in agent_text:
        result.error(
            "runtime-agent-adoption-fallback",
            "AGENT.md still contains adoption fallback text or STARTER.md references",
        )
    if "[Project Name]" in agent_text:
        result.error(
            "runtime-agent-placeholder",
            "AGENT.md still contains [Project Name] placeholder text",
        )

    overlay_path = root / "authorities/PROJECT-OVERLAY.md"
    overlay_text = read_text(result, overlay_path)
    if "[Project Name]" in overlay_text:
        result.error(
            "overlay-placeholder",
            "PROJECT-OVERLAY.md still contains [Project Name] placeholder text",
        )
    overlay_fields = parse_strong_fields(overlay_text)
    for key in (
        "adoption mode",
        "adoption procedure",
        "manual bootstrap status",
        "manual readiness level",
        "manual override acknowledged",
        "code bootstrap mode",
        "code bootstrap status",
        "code bootstrap source type",
        "code bootstrap requested output",
        "procedure completed",
    ):
        check_allowed_value(result, overlay_fields, key)

    manual_status = overlay_fields.get("manual bootstrap status")
    manual_level = overlay_fields.get("manual readiness level")
    manual_override = overlay_fields.get("manual override acknowledged")
    adoption_mode = overlay_fields.get("adoption mode")
    code_mode = overlay_fields.get("code bootstrap mode")
    code_status = overlay_fields.get("code bootstrap status")
    code_source = overlay_fields.get("code bootstrap source type")
    code_output = overlay_fields.get("code bootstrap requested output")

    if manual_status == "skipped_by_user" and manual_override != "yes":
        result.error(
            "manual-skip-override",
            "manual bootstrap status is skipped_by_user but manual override acknowledged is not yes",
        )
    if manual_status == "completed" and manual_level not in {"basic", "operational"}:
        result.error(
            "manual-completed-level",
            "manual bootstrap status is completed but readiness level is not basic or operational",
        )
    if manual_status == "pending" and manual_level == "operational":
        result.warning(
            "manual-pending-operational",
            "manual bootstrap is pending but readiness is already operational",
        )

    if code_mode == "not_required" and code_status not in {"not_required", "unknown"}:
        result.error(
            "code-bootstrap-state-mismatch",
            "code bootstrap mode is not_required but status is still active",
        )
    if code_status == "not_required" and code_mode not in {"not_required", "unknown"}:
        result.error(
            "code-bootstrap-status-mismatch",
            "code bootstrap status is not_required but mode still declares an active bootstrap type",
        )
    if code_mode == "local_code_first_derivation" and adoption_mode != "code_first":
        result.error(
            "code-first-mode-mismatch",
            "local_code_first_derivation is declared outside adoption mode = code_first",
        )
    if code_mode == "local_code_first_derivation" and code_source not in {
        "local_project",
        "unknown",
    }:
        result.error(
            "code-source-mismatch",
            "local_code_first_derivation must use code bootstrap source type local_project",
        )
    if code_mode == "external_source_integration" and code_source in {"none", "local_project"}:
        result.error(
            "external-source-mismatch",
            "external_source_integration must not use source type none or local_project",
        )
    if code_mode == "not_required" and code_output not in {"not_required", "unknown"}:
        result.warning(
            "code-output-stale",
            "code bootstrap mode is not_required but requested output is still specific",
        )
    if adoption_mode == "code_first" and code_mode == "not_required" and code_status == "not_required":
        result.ok("code_first project appears to have completed or reset its code bootstrap state")

    if overlay_fields.get("procedure completed") == "yes":
        for key in (
            "adoption mode",
            "adoption procedure",
            "manual bootstrap status",
            "manual readiness level",
            "manual override acknowledged",
            "code bootstrap mode",
            "code bootstrap status",
        ):
            if overlay_fields.get(key) == "unknown":
                result.error(
                    "unknown-post-adoption",
                    f"Overlay field '{key}' is still unknown after procedure completed = yes",
                )

    map_section = extract_section(overlay_text, "## 10. Document Location Map")
    if not map_section:
        result.error(
            "overlay-map-missing",
            "PROJECT-OVERLAY.md does not contain section 10 Document Location Map",
        )
        return
    location_map = parse_overlay_map(map_section)
    for row_name in OVERLAY_LOCATION_ROWS:
        if row_name not in location_map:
            result.error(
                "overlay-map-row-missing",
                f"Document location map missing row: {row_name}",
            )
    for row_name, (default_location, actual_location) in location_map.items():
        path = resolve_declared_path(
            result,
            root,
            default_location,
            actual_location,
            row_name,
        )
        if path is None:
            continue
        if not path.exists():
            result.error(
                "overlay-map-path-missing",
                f"Declared path for '{row_name}' does not exist: {path}",
            )

    required_category_templates = {
        "Requirement diffs": "REQUIREMENTS-DIFF-TEMPLATE.md",
        "Implementation packets": "IMPL-TEMPLATE.md",
        "Test campaigns": "TEST-CAMPAIGN-TEMPLATE.md",
    }
    for row_name, template_name in required_category_templates.items():
        if row_name not in location_map:
            continue
        default_location, actual_location = location_map[row_name]
        category_path = resolve_declared_path(
            result,
            root,
            default_location,
            actual_location,
            row_name,
        )
        if category_path is None:
            continue
        template_path = category_path / template_name
        if not template_path.exists():
            result.error(
                "category-template-missing",
                f"Missing category template at resolved '{row_name}' location: {template_path}",
            )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate the flow-of-work control plane structure."
    )
    parser.add_argument(
        "mode",
        choices=("framework", "workspace"),
        help="Validate the framework repo itself or an adopted workspace.",
    )
    parser.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Path to the framework repo or adopted workspace. Defaults to the current directory.",
    )
    args = parser.parse_args()

    root = Path(args.target).resolve()
    result = LintResult(args.mode, root)

    if not root.exists():
        result.error("target-missing", f"Target path does not exist: {root}")
        return result.emit()

    if args.mode == "framework":
        check_framework_mode(result)
    else:
        check_workspace_mode(result)

    return result.emit()


if __name__ == "__main__":
    sys.exit(main())
