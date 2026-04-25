#!/usr/bin/env python3
# Run 'python3 tools/flowctl.py --help' before using this tool.
"""Deterministic CLI for flow-of-work governance checks.

`flowctl` is intentionally boring: it validates document structure and gate
records. It does not call models, judge product merit, or accept work.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from control_plane_lint import (
    LintResult,
    check_framework_mode,
    check_workspace_mode,
    clean_cell,
    extract_section,
    normalize_label,
    parse_field_value_table,
    parse_markdown_table,
    parse_overlay_map,
    parse_strong_fields,
    read_text,
    resolve_declared_path,
)


CONTRACT_FILES = [
    "00-INDEX.md",
    "01-LLM-SESSION-CONTRACT.md",
    "02-DOCSET-GOVERNANCE-CONTRACT.md",
    "03-BEHAVIORAL-DEFINITION-GATE.md",
    "04-TEST-AND-HANDOFF-CONTRACT.md",
    "05-PROJECT-STRUCTURE.md",
]

AUTHORITY_TYPES = {
    "requirements_diff",
    "use_case",
    "sequence",
    "user_instruction",
    "working_code_reference",
    "not_applicable",
}

REQUIRED_IMPL_GATE_FIELDS = [
    "gate status",
    "authority type",
    "authority reference",
    "runtime/user-visible behavior affected",
    "fallback/error behavior affected",
]


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        return {}
    _, rest = text.split("---\n", 1)
    if "---\n" not in rest:
        return {}
    raw, _ = rest.split("---\n", 1)
    fields: dict[str, str] = {}
    for line in raw.splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        fields[normalize_label(key)] = value.strip()
    return fields


def metadata_status(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    frontmatter = parse_frontmatter(text)
    if "status" in frontmatter:
        return frontmatter["status"]
    fields = parse_strong_fields(text)
    return fields.get("status", "unknown")


def detect_mode(root: Path) -> str:
    if (root / "flow-of-work-contract").is_dir() and (root / "templates").is_dir():
        return "framework"
    if (root / "authorities" / "flow-of-work-contract").is_dir():
        return "workspace"
    return "unknown"


def find_overlay_diff_index(root: Path) -> Path | None:
    overlay = root / "authorities" / "PROJECT-OVERLAY.md"
    if not overlay.exists():
        return None
    result = LintResult("workspace", root)
    text = read_text(result, overlay)
    map_section = extract_section(text, "## 10. Document Location Map")
    if not map_section:
        return None
    location_map = parse_overlay_map(map_section)
    row = location_map.get("Requirement diff index")
    if not row:
        return None
    return resolve_declared_path(result, root, row[0], row[1], "Requirement diff index")


def find_diff_index(root: Path) -> Path | None:
    overlay_path = find_overlay_diff_index(root)
    candidates = [
        overlay_path,
        root / "authorities" / "diffs" / "REQUIREMENTS_DIFF_INDEX.md",
        root / "docs" / "REQUIREMENTS_DIFF_INDEX.md",
        root / "REQUIREMENTS_DIFF_INDEX.md",
    ]
    for candidate in candidates:
        if candidate and candidate.exists() and candidate.is_file():
            return candidate
    return None


def active_diff_info(index_path: Path) -> dict[str, str]:
    text = index_path.read_text(encoding="utf-8")
    section = ""
    for heading in ("## 3. Current Active Diff", "## Current Active Diff"):
        section = extract_section(text, heading)
        if section:
            break

    fields = parse_field_value_table(section) if section else {}
    strong_fields = parse_strong_fields(text)
    if "active diff" not in fields and "current active diff" in strong_fields:
        fields["active diff"] = clean_cell(strong_fields["current active diff"])
    if "implementation family" not in fields and "current implementation family" in strong_fields:
        fields["implementation family"] = clean_cell(
            strong_fields["current implementation family"]
        )
    return fields


def is_placeholder(value: str | None) -> bool:
    if value is None:
        return True
    stripped = clean_cell(value)
    return not stripped or ("[" in stripped and "]" in stripped)


def emit_issues(result: LintResult) -> int:
    return result.emit()


def command_doctor(args: argparse.Namespace) -> int:
    root = Path(args.target).resolve()
    mode = args.mode
    if mode == "auto":
        mode = detect_mode(root)
    result = LintResult(mode, root)
    if not root.exists():
        result.error("target-missing", f"Target path does not exist: {root}")
        return emit_issues(result)
    if mode == "framework":
        check_framework_mode(result)
    elif mode == "workspace":
        check_workspace_mode(result)
    else:
        result.error("mode-undetected", "Could not detect framework or workspace mode")
    return emit_issues(result)


def command_status(args: argparse.Namespace) -> int:
    root = Path(args.target).resolve()
    mode = detect_mode(root)
    print(f"Mode: {mode}")
    print(f"Target: {root}")

    if mode == "framework":
        contract_dir = root / "flow-of-work-contract"
        print("Contracts:")
        for name in CONTRACT_FILES:
            path = contract_dir / name
            status = metadata_status(path) if path.exists() else "missing"
            print(f"- {name}: {status}")
        return 0

    index_path = find_diff_index(root)
    if index_path:
        fields = active_diff_info(index_path)
        print(f"Requirement diff index: {index_path}")
        print(f"Active diff: {fields.get('active diff', 'unknown')}")
        print(f"Active state: {fields.get('active state', 'unknown')}")
    else:
        print("Requirement diff index: not found")
    return 0 if mode != "unknown" else 1


def command_active_diff_show(args: argparse.Namespace) -> int:
    root = Path(args.target).resolve()
    index_path = find_diff_index(root)
    if not index_path:
        print(f"ERROR: no REQUIREMENTS_DIFF_INDEX.md found under {root}")
        return 1
    fields = active_diff_info(index_path)
    if not fields:
        print(f"ERROR: {index_path} has no Current Active Diff data")
        return 1

    active_diff = fields.get("active diff", "unknown")
    active_state = fields.get("active state", "unknown")
    print(f"Index: {index_path}")
    print(f"Active diff: {active_diff}")
    print(f"Active state: {active_state}")
    if active_diff and active_diff.lower() != "none":
        path = Path(active_diff)
        resolved = path if path.is_absolute() else index_path.parent / path
        print(f"Resolved path: {resolved}")
        print(f"Exists: {'yes' if resolved.exists() else 'no'}")
    return 0


def check_impl_file(path: Path) -> LintResult:
    result = LintResult("impl", path)
    if not path.exists():
        result.error("impl-missing", f"IMPL file does not exist: {path}")
        return result

    text = read_text(result, path)
    section = extract_section(text, "## 4. Behavioral Definition Gate")
    if not section:
        result.error("impl-behavior-gate-missing", "Missing section: ## 4. Behavioral Definition Gate")
        return result

    doc_fields = parse_strong_fields(text)
    fields = parse_strong_fields(section)
    for field in REQUIRED_IMPL_GATE_FIELDS:
        if field not in fields:
            result.error("impl-gate-field-missing", f"Missing gate field: {field}")
    if result.has_errors():
        return result

    is_template = "template" in clean_cell(doc_fields.get("status", "")).lower()
    if is_template:
        return result

    gate_status = clean_cell(fields.get("gate status", "")).lower()
    authority_type = clean_cell(fields.get("authority type", "")).lower()
    authority_reference = clean_cell(fields.get("authority reference", ""))
    runtime_affected = clean_cell(fields.get("runtime/user-visible behavior affected", "")).lower()
    fallback_affected = clean_cell(fields.get("fallback/error behavior affected", "")).lower()

    if gate_status not in {"clear", "blocked"}:
        result.error("impl-gate-status-invalid", "Gate status must be clear or blocked")

    if gate_status == "clear":
        if authority_type not in AUTHORITY_TYPES:
            result.error("impl-authority-type-invalid", "Authority type is missing or invalid")
        if authority_type == "not_applicable":
            if runtime_affected == "yes" or fallback_affected == "yes":
                result.error(
                    "impl-authority-not-applicable-invalid",
                    "Authority type cannot be not_applicable when behavior is affected",
                )
        elif is_placeholder(authority_reference):
            result.error("impl-authority-reference-missing", "Clear gate requires authority reference")
        if runtime_affected not in {"yes", "no"}:
            result.error(
                "impl-runtime-affected-invalid",
                "Runtime/user-visible behavior affected must be yes or no",
            )
        if fallback_affected not in {"yes", "no", "out_of_scope"}:
            result.error(
                "impl-fallback-affected-invalid",
                "Fallback/error behavior affected must be yes, no, or out_of_scope",
            )

    if gate_status == "blocked":
        rows = parse_markdown_table(section)
        data_rows = [
            row for row in rows[1:]
            if len(row) >= 3 and not all(is_placeholder(cell) for cell in row[:3])
        ]
        if not data_rows:
            result.error(
                "impl-blocked-missing-decision",
                "Blocked gate requires at least one concrete missing-behavior row",
            )

    return result


def command_check_impl(args: argparse.Namespace) -> int:
    return emit_issues(check_impl_file(Path(args.path).resolve()))


def check_matrix_file(path: Path) -> LintResult:
    result = LintResult("matrix", path)
    if not path.exists():
        result.error("matrix-missing", f"Traceability matrix does not exist: {path}")
        return result

    text = read_text(result, path)
    section = extract_section(text, "## 2. Functional Traceability")
    if not section:
        result.error("matrix-functional-section-missing", "Missing section: ## 2. Functional Traceability")
        return result

    rows = parse_markdown_table(section)
    if not rows:
        result.error("matrix-table-missing", "Functional traceability table is missing")
        return result

    headers = [normalize_label(cell) for cell in rows[0]]
    required = {"id(s)", "impl packet(s)", "behavior gate", "primary evidence", "status"}
    missing = required - set(headers)
    for header in sorted(missing):
        result.error("matrix-column-missing", f"Missing matrix column: {header}")
    if missing:
        return result

    index = {name: headers.index(name) for name in required}
    for row_number, row in enumerate(rows[1:], start=2):
        if len(row) < len(headers):
            result.error("matrix-row-short", f"Row {row_number} has too few columns")
            continue
        req_id = clean_cell(row[index["id(s)"]])
        gate = clean_cell(row[index["behavior gate"]]).lower()
        evidence = clean_cell(row[index["primary evidence"]])
        status = clean_cell(row[index["status"]]).lower()

        if gate not in {"clear", "blocked", "not_applicable"}:
            result.error(
                "matrix-behavior-gate-invalid",
                f"Row {row_number} ({req_id}) has invalid behavior gate: {gate}",
            )
        if status == "implemented" and gate == "blocked":
            result.error(
                "matrix-implemented-blocked",
                f"Row {row_number} ({req_id}) is Implemented but behavior gate is blocked",
            )
        if status in {"implemented", "partial"} and evidence in {"", "—", "-"}:
            result.error(
                "matrix-evidence-missing",
                f"Row {row_number} ({req_id}) is {status} but primary evidence is missing",
            )

    return result


def command_check_matrix(args: argparse.Namespace) -> int:
    return emit_issues(check_matrix_file(Path(args.path).resolve()))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="flowctl",
        description="Deterministic flow-of-work governance CLI.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    doctor = sub.add_parser("doctor", help="Run structural control-plane lint")
    doctor.add_argument("target", nargs="?", default=".")
    doctor.add_argument(
        "--mode",
        choices=("auto", "framework", "workspace"),
        default="auto",
        help="Lint mode. Defaults to auto-detection.",
    )
    doctor.set_defaults(func=command_doctor)

    status = sub.add_parser("status", help="Show target governance status")
    status.add_argument("target", nargs="?", default=".")
    status.set_defaults(func=command_status)

    active = sub.add_parser("active-diff", help="Inspect active requirement diff")
    active_sub = active.add_subparsers(dest="active_command", required=True)
    active_show = active_sub.add_parser("show", help="Show active diff from REQUIREMENTS_DIFF_INDEX.md")
    active_show.add_argument("target", nargs="?", default=".")
    active_show.set_defaults(func=command_active_diff_show)

    check = sub.add_parser("check", help="Run focused artifact checks")
    check_sub = check.add_subparsers(dest="check_command", required=True)
    check_impl = check_sub.add_parser("impl", help="Check an IMPL behavioral gate")
    check_impl.add_argument("path")
    check_impl.set_defaults(func=command_check_impl)
    check_matrix = check_sub.add_parser("matrix", help="Check a traceability matrix")
    check_matrix.add_argument("path")
    check_matrix.set_defaults(func=command_check_matrix)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
