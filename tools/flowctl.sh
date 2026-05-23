#!/usr/bin/env bash
# Run 'bash tools/flowctl.sh --help' before using this tool.
#
# flowctl — deterministic flow-of-work governance CLI
# Validates document structure and gate records.
# Does not call models, judge product merit, or accept work.

set -uo pipefail

# ── issue tracking ─────────────────────────────────────────────────────────────

ERR_COUNT=0
WARN_COUNT=0
ISSUE_LOG=""

emit_error() {
  local code="$1" msg="$2"
  ISSUE_LOG="${ISSUE_LOG}ERROR: [${code}] ${msg}\n"
  ERR_COUNT=$(( ERR_COUNT + 1 ))
}

emit_warning() {
  local code="$1" msg="$2"
  ISSUE_LOG="${ISSUE_LOG}WARNING: [${code}] ${msg}\n"
  WARN_COUNT=$(( WARN_COUNT + 1 ))
}

emit_ok() { printf 'OK: %s\n' "$1"; }

print_issues() {
  local mode="$1" root="$2"
  printf '%b' "$ISSUE_LOG"
  printf 'SUMMARY: mode=%s root=%s errors=%d warnings=%d\n' \
    "$mode" "$root" "$ERR_COUNT" "$WARN_COUNT"
}

reset_issues() {
  ERR_COUNT=0; WARN_COUNT=0; ISSUE_LOG=""
}

# ── portable path resolution ───────────────────────────────────────────────────

resolve_dir() {
  local p="$1"
  ( cd "$p" 2>/dev/null && pwd ) || printf '%s' "$p"
}

resolve_target_dir() {
  local p="$1"
  [[ -d "$p" ]] || return 1
  resolve_dir "$p"
}

resolve_file_path() {
  local p="$1"
  local d b
  d=$(dirname "$p")
  b=$(basename "$p")
  printf '%s/%s' "$(resolve_dir "$d")" "$b"
}

resolve_workspace_file() {
  local root="$1" p="$2"
  case "$p" in
    /*) printf '%s' "$p" ;;
    *)  printf '%s/%s' "$root" "$p" ;;
  esac
}

# ── string helpers ─────────────────────────────────────────────────────────────

normalize_label() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -s ' \t' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

clean_cell() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^`//;s/`$//'
}

is_placeholder() {
  local v
  v=$(clean_cell "$1")
  case "$v" in
    "") return 0 ;;
    *"["*"]"*) return 0 ;;
    *) return 1 ;;
  esac
}

require_exists() {
  local root="$1" relpath="$2"
  [[ -e "$root/$relpath" ]] || emit_error "missing-file" "Expected path not found: $relpath"
}

# ── frontmatter ────────────────────────────────────────────────────────────────

get_frontmatter_field() {
  local text="$1" key="$2"
  printf '%s\n' "$text" | awk -v key="$key" '
    /^---$/ { if (in_fm) exit; in_fm=1; next }
    in_fm && /^---$/ { exit }
    in_fm {
      n = index($0, ":")
      if (n > 0) {
        k = substr($0, 1, n-1)
        v = substr($0, n+1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
        if (k == key) { print v; exit }
      }
    }
  '
}

metadata_status() {
  local path="$1"
  local text status
  text=$(cat "$path" 2>/dev/null || printf '')
  status=$(get_frontmatter_field "$text" "status")
  if [[ -z "$status" ]]; then
    status=$(get_strong_field "$text" "status")
  fi
  printf '%s' "${status:-unknown}"
}

# ── strong fields: **key:** value ──────────────────────────────────────────────

get_strong_field() {
  local text="$1" key="$2"
  local nkey
  nkey=$(normalize_label "$key")
  printf '%s\n' "$text" | awk -v nkey="$nkey" '
    /^\*\*[^:]+:\*\*/ {
      k = $0; v = $0
      gsub(/^\*\*/, "", k); gsub(/:\*\*.*$/, "", k)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)
      k = tolower(k); gsub(/[[:space:]]+/, " ", k)
      if (k == nkey) {
        gsub(/^\*\*[^:]*:\*\*[[:space:]]*/, "", v)
        gsub(/[[:space:]]+$/, "", v)
        print v; exit
      }
    }
  '
}

has_strong_field() {
  local text="$1" key="$2"
  local val
  val=$(get_strong_field "$text" "$key")
  [[ -n "$val" ]]
}

# ── section extraction ─────────────────────────────────────────────────────────

extract_section() {
  local text="$1" heading="$2"
  printf '%s\n' "$text" | awk -v h="$heading" '
    $0 == h   { found=1; next }
    found && /^## / { exit }
    found     { print }
  '
}

# ── markdown table helpers ─────────────────────────────────────────────────────

table_rows() {
  local text="$1"
  printf '%s\n' "$text" | grep '^|' | grep -v '^|[-: |]*$'
}

get_cell() {
  local row="$1" n="$2"
  printf '%s' "$row" | sed 's/^|//;s/|$//' | awk -F'|' -v n="$n" '{ gsub(/^[[:space:]]+|[[:space:]]+$/, "", $n); print $n }'
}

count_cells() {
  local row="$1"
  printf '%s' "$row" | sed 's/^|//;s/|$//' | awk -F'|' '{ print NF }'
}

# ── mode detection ─────────────────────────────────────────────────────────────

detect_mode() {
  local root="$1"
  if [[ -d "$root/flow-of-work-contract" && -d "$root/templates" ]]; then
    printf 'framework'
  elif [[ -d "$root/authorities/flow-of-work-contract" ]]; then
    printf 'workspace'
  else
    printf 'unknown'
  fi
}

# ── overlay location map ───────────────────────────────────────────────────────

# outputs lines of: doc_type TAB default_loc TAB actual_loc
parse_overlay_map() {
  local section="$1"
  table_rows "$section" | tail -n +2 | while IFS= read -r row; do
    local n
    n=$(count_cells "$row")
    [[ "$n" -lt 3 ]] && continue
    local dt dl al
    dt=$(get_cell "$row" 1)
    dl=$(get_cell "$row" 2)
    al=$(get_cell "$row" 3)
    printf '%s\t%s\t%s\n' "$dt" "$dl" "$al"
  done
}

resolve_declared_path() {
  local root="$1" default_loc="$2" actual_loc="$3" row_name="$4"
  local chosen
  actual_loc=$(clean_cell "$actual_loc")
  default_loc=$(clean_cell "$default_loc")
  if [[ "$(printf "%s" "$actual_loc" | tr '[:upper:]' '[:lower:]')" == "default" ]]; then
    chosen="$default_loc"
  else
    chosen="$actual_loc"
  fi
  if [[ -z "$chosen" ]] || is_placeholder "$chosen"; then
    emit_error "overlay-map-placeholder" \
      "Document location map row '$row_name' is still placeholder-like: $actual_loc"
    printf ''; return
  fi
  case "$chosen" in
    /*) printf '%s' "$chosen" ;;
    *)  printf '%s/%s' "$root" "$chosen" ;;
  esac
}

# ── diff index ─────────────────────────────────────────────────────────────────

find_overlay_diff_index() {
  local root="$1"
  local overlay="$root/authorities/PROJECT-OVERLAY.md"
  [[ ! -f "$overlay" ]] && return
  local text map_section
  text=$(cat "$overlay")
  map_section=$(extract_section "$text" "## 10. Document Location Map")
  [[ -z "$map_section" ]] && return
  while IFS=$'\t' read -r dt dl al; do
    local nt
    nt=$(normalize_label "$dt")
    if [[ "$nt" == "requirement diff index" ]]; then
      resolve_declared_path "$root" "$dl" "$al" "Requirement diff index"
      return
    fi
  done < <(parse_overlay_map "$map_section")
}

overlay_location() {
  local root="$1" row_name="$2"
  local overlay="$root/authorities/PROJECT-OVERLAY.md"
  [[ ! -f "$overlay" ]] && return
  local text map_section nrow
  text=$(cat "$overlay")
  map_section=$(extract_section "$text" "## 10. Document Location Map")
  [[ -z "$map_section" ]] && return
  nrow=$(normalize_label "$row_name")
  while IFS=$'\t' read -r dt dl al; do
    [[ "$(normalize_label "$dt")" == "$nrow" ]] || continue
    resolve_declared_path "$root" "$dl" "$al" "$row_name"
    return
  done < <(parse_overlay_map "$map_section")
}

diff_dir_for_index() {
  local root="$1" index_path="$2"
  local diff_dir
  diff_dir=$(overlay_location "$root" "Requirement diffs" 2>/dev/null || printf '')
  if [[ -n "$diff_dir" ]]; then
    printf '%s' "${diff_dir%/}"
  else
    dirname "$index_path"
  fi
}

find_diff_index() {
  local root="$1"
  local overlay_path
  overlay_path=$(find_overlay_diff_index "$root" 2>/dev/null || printf '')
  local c
  for c in "$overlay_path" \
            "$root/authorities/diffs/REQUIREMENTS_DIFF_INDEX.md"; do
    [[ -n "$c" && -f "$c" ]] && printf '%s' "$c" && return
  done
}

# outputs key=value lines: active_diff=..., active_state=...
active_diff_info() {
  local index_path="$1"
  local text section
  text=$(cat "$index_path")
  section=$(extract_section "$text" "## 3. Current Active Diff")
  local active_diff="" active_state=""
  if [[ -n "$section" ]]; then
    while IFS= read -r row; do
      local k v nk
      k=$(get_cell "$row" 1); v=$(get_cell "$row" 2)
      nk=$(normalize_label "$k")
      case "$nk" in
        "active diff")  active_diff=$(clean_cell "$v") ;;
        "active state") active_state=$(clean_cell "$v") ;;
      esac
    done < <(table_rows "$section" | tail -n +2)
  fi
  [[ -z "$active_diff" ]] && active_diff=$(clean_cell "$(get_strong_field "$text" "current active diff")")
  printf 'active_diff=%s\nactive_state=%s\n' "$active_diff" "$active_state"
}

# ── substring order ────────────────────────────────────────────────────────────

check_substring_order() {
  local text="$1" first="$2" second="$3" code="$4" msg="$5"
  local fi si
  fi=$(printf '%s\n' "$text" | grep -nF "$first"  | head -1 | cut -d: -f1)
  si=$(printf '%s\n' "$text" | grep -nF "$second" | head -1 | cut -d: -f1)
  if [[ -z "$fi" || -z "$si" ]] || [[ "$fi" -gt "$si" ]]; then
    emit_error "$code" "$msg"
  fi
}

# ── overlay field validation ───────────────────────────────────────────────────

valid_values_for() {
  local key="$1"
  case "$key" in
    "adoption mode")
      printf 'greenfield migration code_first unknown' ;;
    "adoption procedure")
      printf 'starter_guided unknown' ;;
    "manual bootstrap status")
      printf 'pending in-progress completed skipped_by_user unknown' ;;
    "manual readiness level")
      printf 'not_started basic operational unknown' ;;
    "manual override acknowledged")
      printf 'yes no unknown' ;;
    "code bootstrap mode")
      printf 'not_required local_code_first_derivation external_source_integration unknown' ;;
    "code bootstrap status")
      printf 'not_required pending in-progress completed unknown' ;;
    "code bootstrap source type")
      printf 'local_project filesystem_repo git_repo url web_research archive pasted_code none unknown' ;;
    "code bootstrap requested output")
      printf 'not_required bootstrap_docs_only understanding_only integration_recommendation new_impl_required implementation_candidate unknown' ;;
  esac
}

check_allowed_value() {
  local text="$1" key="$2"
  local value
  value=$(get_strong_field "$text" "$key")
  value=$(clean_cell "$value")
  if [[ -z "$value" ]]; then
    emit_error "missing-overlay-field" "Missing overlay field: $key"
    return
  fi
  local valid found=0
  valid=$(valid_values_for "$key")
  local v
  for v in $valid; do
    [[ "$v" == "$value" ]] && found=1 && break
  done
  [[ "$found" -eq 0 ]] && emit_error "invalid-overlay-value" "Invalid value for '$key': $value"
}

# ── validate diff index ────────────────────────────────────────────────────────

validate_diff_index() {
  local index_path="$1" diff_dir="$2"
  [[ ! -f "$index_path" ]] && return
  local fname
  fname=$(basename "$index_path")
  [[ "$fname" != "REQUIREMENTS_DIFF_INDEX.md" ]] && \
    emit_error "diff-index-wrong-name" \
      "Requirement diff index must be named REQUIREMENTS_DIFF_INDEX.md: $index_path"

  local text
  text=$(cat "$index_path")
  local f
  for f in "current active diff" "current implementation family"; do
    has_strong_field "$text" "$f" && \
      emit_error "diff-index-duplicate-state" \
        "REQUIREMENTS_DIFF_INDEX.md duplicates active state in header field: $f"
  done

  local active_section
  active_section=$(extract_section "$text" "## 3. Current Active Diff")
  if [[ -z "$active_section" ]]; then
    emit_error "diff-index-active-section-missing" \
      "REQUIREMENTS_DIFF_INDEX.md missing section: ## 3. Current Active Diff"
    return
  fi

  local active_diff="" active_state=""
  while IFS= read -r row; do
    local k v nk
    k=$(get_cell "$row" 1); v=$(get_cell "$row" 2)
    nk=$(normalize_label "$k")
    case "$nk" in
      "active diff")  active_diff=$(clean_cell "$v") ;;
      "active state") active_state=$(clean_cell "$v") ;;
    esac
  done < <(table_rows "$active_section" | tail -n +2)

  [[ -z "$active_diff" ]] && \
    emit_error "diff-index-active-diff-missing" \
      "Current Active Diff table does not define Active diff" && return
  [[ -z "$active_state" ]] && \
    emit_error "diff-index-active-state-missing" \
      "Current Active Diff table does not define Active state" && return

  local ad_lower as_lower
  ad_lower=$(printf "%s" "$active_diff" | tr '[:upper:]' '[:lower:]')
  as_lower=$(printf "%s" "$active_state" | tr '[:upper:]' '[:lower:]')

  [[ "$ad_lower" == "none" && "$as_lower" != "none" ]] && \
    emit_error "diff-index-state-mismatch" "Active state must be none when Active diff is none"
  [[ "$ad_lower" != "none" && "$as_lower" != "active head" ]] && \
    emit_error "diff-index-state-mismatch" "Active state must be active head when Active diff names a diff"

  if [[ "$ad_lower" != "none" ]]; then
    if is_placeholder "$active_diff"; then
      emit_error "diff-index-active-placeholder" \
        "Active diff is still placeholder-like: $active_diff"
    else
      local active_path
      case "$active_diff" in
        /*) active_path="$active_diff" ;;
        *)  active_path="$diff_dir/$active_diff" ;;
      esac
      [[ ! -f "$active_path" ]] && \
        emit_error "diff-index-active-missing" \
          "Active diff declared by REQUIREMENTS_DIFF_INDEX.md does not exist: $active_path"
    fi
  fi

  local ledger_section
  ledger_section=$(extract_section "$text" "## 4. Diff Ledger")
  if [[ -z "$ledger_section" ]]; then
    emit_error "diff-index-ledger-missing" \
      "REQUIREMENTS_DIFF_INDEX.md missing section: ## 4. Diff Ledger"
    return
  fi

  local active_head_count=0
  while IFS= read -r row; do
    local n
    n=$(count_cells "$row")
    [[ "$n" -lt 3 ]] && continue
    local st
    st=$(clean_cell "$(get_cell "$row" 3)")
    [[ "$(printf "%s" "$st" | tr '[:upper:]' '[:lower:]')" == "active head" ]] && active_head_count=$(( active_head_count + 1 ))
  done < <(table_rows "$ledger_section" | tail -n +2)

  [[ "$active_head_count" -gt 1 ]] && \
    emit_error "diff-index-multiple-active-heads" \
      "Diff ledger declares more than one active head"

  if [[ "$ad_lower" != "none" ]]; then
    local active_name has_active_ledger=0
    active_name=$(basename "$active_diff")
    while IFS= read -r row; do
      local n
      n=$(count_cells "$row")
      [[ "$n" -lt 3 ]] && continue
      local c1 st
      c1=$(clean_cell "$(get_cell "$row" 1)")
      st=$(clean_cell "$(get_cell "$row" 3)")
      if [[ "$(printf "%s" "$st" | tr '[:upper:]' '[:lower:]')" == "active head" ]] && \
         [[ "$c1" == "$active_diff" || "$c1" == "$active_name" ]]; then
        has_active_ledger=1; break
      fi
    done < <(table_rows "$ledger_section" | tail -n +2)
    [[ "$has_active_ledger" -eq 0 ]] && \
      emit_error "diff-index-ledger-mismatch" \
        "Active diff is not registered as active head in the diff ledger"
  fi
}

# ── check framework mode ───────────────────────────────────────────────────────

check_framework_mode() {
  local root="$1"

  local f
  for f in \
    "README.md" "STARTER.md" "CODE-BOOTSTRAP.md" "CODE-WORKFLOW-CONTRACT.md" "WHY.md" \
    "tools/CONTROL-PLANE-LINT-SPEC.md" "tools/flowctl.sh" "tools/flowctl.py" \
    "tools/control_plane_lint.py" \
    "templates/AGENT-TEMPLATE.md" "templates/PROJECT-OVERLAY.md" \
    "templates/IMPL-INDEX.md" "templates/TRACEABILITY_MATRIX.md" \
    "templates/REQUIREMENTS-DIFF-INDEX-TEMPLATE.md" \
    "templates/REQUIREMENTS-DIFF-TEMPLATE.md" \
    "templates/IMPL-TEMPLATE.md" "templates/REVIEW-INDEX-TEMPLATE.md" \
    "templates/REVIEW-TEMPLATE.md" "templates/TEST-CAMPAIGN-INDEX-TEMPLATE.md" \
    "templates/TEST-CAMPAIGN-TEMPLATE.md" \
    "templates/TEST-ENVIRONMENT-STARTUP-TEMPLATE.md" \
    "manual/MANUAL-BOOTSTRAP.md" "manual/REACHING-THE-LLMS.md" \
    "flow-of-work-contract/00-INDEX.md" \
    "flow-of-work-contract/01-LLM-SESSION-CONTRACT.md" \
    "flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md" \
    "flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md" \
    "flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md" \
    "flow-of-work-contract/05-PROJECT-STRUCTURE.md" \
    "flow-of-work-contract/06-VALIDATION-EXECUTION-CONTRACT.md"
  do
    require_exists "$root" "$f"
  done

  [[ -f "$root/MANUAL-STARTER.md" ]] && \
    emit_error "legacy-manual-starter" "MANUAL-STARTER.md still exists in the framework repo"

  local core_docs=(
    "README.md" "STARTER.md" "CODE-BOOTSTRAP.md" "CODE-WORKFLOW-CONTRACT.md" "WHY.md"
    "templates/AGENT-TEMPLATE.md" "templates/PROJECT-OVERLAY.md"
    "templates/IMPL-INDEX.md" "templates/TRACEABILITY_MATRIX.md"
    "templates/REQUIREMENTS-DIFF-INDEX-TEMPLATE.md"
    "templates/REQUIREMENTS-DIFF-TEMPLATE.md"
    "templates/IMPL-TEMPLATE.md" "templates/REVIEW-INDEX-TEMPLATE.md"
    "templates/REVIEW-TEMPLATE.md" "templates/TEST-CAMPAIGN-INDEX-TEMPLATE.md"
    "templates/TEST-CAMPAIGN-TEMPLATE.md"
    "templates/TEST-ENVIRONMENT-STARTUP-TEMPLATE.md"
    "manual/MANUAL-BOOTSTRAP.md" "manual/REACHING-THE-LLMS.md"
    "flow-of-work-contract/00-INDEX.md"
    "flow-of-work-contract/01-LLM-SESSION-CONTRACT.md"
    "flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md"
    "flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md"
    "flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md"
    "flow-of-work-contract/05-PROJECT-STRUCTURE.md"
    "flow-of-work-contract/06-VALIDATION-EXECUTION-CONTRACT.md"
  )

  local relpath text
  for relpath in "${core_docs[@]}"; do
    [[ ! -f "$root/$relpath" ]] && continue
    text=$(cat "$root/$relpath")
    local forbidden code
    for forbidden in \
      "MANUAL-STARTER.md:legacy-manual-starter-ref" \
      "starter_manual:legacy-starter-manual-value" \
      "templates/AGENT.md:old-agent-template-path" \
      "AGENT-TEMPORARY-COMPACT.md:temporary-agent-ref" \
      "PROJECT-OVERLAY-TEMPORARY-CODE-BOOTSTRAP.md:temporary-overlay-ref" \
      "CODE-BOOTSTRAP-TEMPORARY-INTEGRATION.md:temporary-bootstrap-ref"
    do
      local fstr="${forbidden%%:*}" fcode="${forbidden##*:}"
      printf '%s\n' "$text" | grep -qF "$fstr" && \
        emit_error "$fcode" "Forbidden reference '$fstr' still present in $relpath"
    done
  done

  local readme
  readme=$(cat "$root/README.md" 2>/dev/null || printf '')
  printf '%s\n' "$readme" | grep -qF -- '`manual/MANUAL-BOOTSTRAP.md`' || \
    emit_error "missing-readme-manual-bootstrap" \
      "README.md does not point to manual/MANUAL-BOOTSTRAP.md"
  printf '%s\n' "$readme" | grep -qF -- '`STARTER.md`' || \
    emit_error "missing-readme-starter" "README.md does not point to STARTER.md"

  local agent_template
  agent_template=$(cat "$root/templates/AGENT-TEMPLATE.md" 2>/dev/null || printf '')
  check_substring_order "$agent_template" "overlay sec. 8" "overlay sec. 9" \
    "agent-ordering" "AGENT-TEMPLATE.md must inspect overlay sec. 8 before sec. 9"
  printf '%s\n' "$agent_template" | grep -qF "authorities/manual/MANUAL-BOOTSTRAP.md" || \
    emit_error "agent-manual-bootstrap" \
      "AGENT-TEMPLATE.md does not route to authorities/manual/MANUAL-BOOTSTRAP.md"
  printf '%s\n' "$agent_template" | grep -qF "CODE-BOOTSTRAP.md" || \
    emit_error "agent-code-bootstrap" "AGENT-TEMPLATE.md does not route to CODE-BOOTSTRAP.md"
  printf '%s\n' "$agent_template" | grep -qF "CODE-WORKFLOW-CONTRACT.md" || \
    emit_error "agent-code-workflow-contract" \
      "AGENT-TEMPLATE.md does not reference CODE-WORKFLOW-CONTRACT.md"
  printf '%s\n' "$agent_template" | grep -qF "REQUIREMENTS_DIFF_INDEX.md" || \
    emit_error "agent-diff-index" \
      "AGENT-TEMPLATE.md does not reference active diff selection through REQUIREMENTS_DIFF_INDEX.md"
  printf '%s\n' "$agent_template" | grep -qF "authorities/diffs/REQUIREMENTS_DIFF_INDEX.md" && \
    emit_error "agent-hardcoded-diff-index" \
      "AGENT-TEMPLATE.md hardcodes the diff index path instead of resolving it from the overlay"

  local overlay_template
  overlay_template=$(cat "$root/templates/PROJECT-OVERLAY.md" 2>/dev/null || printf '')
  local heading
  for heading in \
    "## 8. Manual Onboarding State" \
    "## 9. Code Bootstrap State" \
    "## 10. Document Location Map" \
    "## 11. Operational Tooling"
  do
    printf '%s\n' "$overlay_template" | grep -qF "$heading" || \
      emit_error "overlay-missing-section" "PROJECT-OVERLAY.md missing section: $heading"
  done
  local field
  for field in \
    "Manual bootstrap status" "Manual readiness level" "Manual override acknowledged" \
    "Code bootstrap mode" "Code bootstrap status" \
    "Code bootstrap source type" "Code bootstrap requested output"
  do
    printf '%s\n' "$overlay_template" | grep -qF "**${field}:**" || \
      emit_error "overlay-missing-field" "PROJECT-OVERLAY.md missing field template: $field"
  done
  local tooling_spec required command
  for tooling_spec in \
    "runtime state command:state" \
    "route command:route" \
    "location command:where" \
    "governance status command:status" \
    "active diff command:active-diff" \
    "workspace doctor command:doctor" \
    "handoff command:handoff" \
    "impl check command:check impl" \
    "traceability check command:check matrix" \
    "diff check command:check diff" \
    "campaign check command:check campaign" \
    "sync check command:sync-check"
  do
    field="${tooling_spec%%:*}"
    required="${tooling_spec#*:}"
    command=$(clean_cell "$(get_strong_field "$overlay_template" "$field")")
    if [[ -z "$command" ]]; then
      emit_error "overlay-missing-field" \
        "PROJECT-OVERLAY.md missing operational tooling field template: $field"
      continue
    fi
    [[ "$command" != *"flowctl.sh"* ]] && \
      emit_error "operational-tool-command-invalid" \
        "Operational tooling command '$field' must use flowctl.sh"
    [[ "$command" != *"$required"* ]] && \
      emit_error "operational-tool-command-invalid" \
        "Operational tooling command '$field' must contain '$required'"
  done

  local starter
  starter=$(cat "$root/STARTER.md" 2>/dev/null || printf '')
  printf '%s\n' "$starter" | grep -qF -- '- `authorities/manual/*`' || \
    emit_error "starter-install-set-manual" \
      "STARTER.md required install set does not include authorities/manual/*"
  printf '%s\n' "$starter" | grep -qF "CODE-WORKFLOW-CONTRACT.md" || \
    emit_error "starter-install-set-code-workflow" \
      "STARTER.md required install set does not include CODE-WORKFLOW-CONTRACT.md"
  printf '%s\n' "$starter" | grep -qF "tools/flowctl.sh" || \
    emit_error "starter-install-set-flowctl-sh" \
      "STARTER.md required install set does not include tools/flowctl.sh"
  printf '%s\n' "$starter" | grep -qF "chmod +x tools/flowctl.sh" || \
    emit_error "starter-flowctl-chmod" \
      "STARTER.md does not activate tools/flowctl.sh with chmod +x during filesystem adoption"
  printf '%s\n' "$starter" | grep -qF "REQUIREMENTS_DIFF_INDEX.md" || \
    emit_error "starter-install-set-diff-index" \
      "STARTER.md required install set does not include REQUIREMENTS_DIFF_INDEX.md"
  printf '%s\n' "$starter" | grep -qF "REQUIREMENTS-DIFF-INDEX-TEMPLATE.md" || \
    emit_error "starter-install-set-diff-index-template" \
      "STARTER.md required install set does not include REQUIREMENTS-DIFF-INDEX-TEMPLATE.md"
  local tname
  for tname in \
    "REQUIREMENTS-DIFF-TEMPLATE.md" "IMPL-TEMPLATE.md" \
    "REVIEW-INDEX-TEMPLATE.md" "REVIEW-TEMPLATE.md" \
    "TEST-CAMPAIGN-INDEX-TEMPLATE.md" "TEST-CAMPAIGN-TEMPLATE.md" \
    "TEST-ENVIRONMENT-STARTUP-TEMPLATE.md"
  do
    printf '%s\n' "$starter" | grep -qF "$tname" || \
      emit_error "starter-install-set-category-template" \
        "STARTER.md required install set does not include $tname"
  done
  printf '%s\n' "$starter" | grep -qF -- '- `STARTER.md`' || \
    emit_error "starter-non-install-set" \
      "STARTER.md non-install set does not include STARTER.md"
  check_substring_order "$starter" "overlay sec. 8" "overlay sec. 9" \
    "starter-handoff-ordering" \
    "STARTER.md must describe overlay sec. 8 routing before overlay sec. 9 routing"

  local structure_doc
  structure_doc=$(cat "$root/flow-of-work-contract/05-PROJECT-STRUCTURE.md" 2>/dev/null || printf '')
  printf '%s\n' "$structure_doc" | grep -qF -- '`authorities/manual/`' || \
    emit_error "structure-manual-folder" \
      "05-PROJECT-STRUCTURE.md does not declare authorities/manual/"
  printf '%s\n' "$structure_doc" | grep -qF "CODE-WORKFLOW-CONTRACT.md" || \
    emit_error "structure-code-workflow-contract" \
      "05-PROJECT-STRUCTURE.md does not declare CODE-WORKFLOW-CONTRACT.md"
  printf '%s\n' "$structure_doc" | grep -qF "REQUIREMENTS_DIFF_INDEX.md" || \
    emit_error "structure-diff-index" \
      "05-PROJECT-STRUCTURE.md does not declare REQUIREMENTS_DIFF_INDEX.md"
  printf '%s\n' "$structure_doc" | grep -qF "06-VALIDATION-EXECUTION-CONTRACT.md" || \
    emit_error "structure-validation-contract" \
      "05-PROJECT-STRUCTURE.md does not declare 06-VALIDATION-EXECUTION-CONTRACT.md"
  for tname in \
    "REQUIREMENTS-DIFF-TEMPLATE.md" "IMPL-TEMPLATE.md" \
    "REVIEW-INDEX.md" "REVIEW-TEMPLATE.md" \
    "TEST-CAMPAIGN-INDEX.md" "TEST-CAMPAIGN-TEMPLATE.md" \
    "TEST-ENVIRONMENT-STARTUP.md"
  do
    printf '%s\n' "$structure_doc" | grep -qF "$tname" || \
      emit_error "structure-category-template" \
        "05-PROJECT-STRUCTURE.md does not declare $tname"
  done
  { printf '%s\n' "$structure_doc" | grep -qF "Temporary adoption-only root files" && \
    printf '%s\n' "$structure_doc" | grep -qF -- '`STARTER.md`'; } || \
    emit_error "structure-temporary-root" \
      "05-PROJECT-STRUCTURE.md does not describe STARTER.md as the temporary adoption-only root file"

  local diff_index_template
  diff_index_template=$(cat "$root/templates/REQUIREMENTS-DIFF-INDEX-TEMPLATE.md" 2>/dev/null || printf '')
  for f in "current active diff" "current implementation family"; do
    has_strong_field "$diff_index_template" "$f" && \
      emit_error "diff-index-template-duplicate-state" \
        "REQUIREMENTS-DIFF-INDEX-TEMPLATE.md duplicates active state in header field: $f"
  done
}

# ── check workspace mode ───────────────────────────────────────────────────────

check_workspace_mode() {
  local root="$1"

  local relpath
  for relpath in \
    "AGENT.md" "CODE-BOOTSTRAP.md" "CODE-WORKFLOW-CONTRACT.md" \
    "tools/flowctl.sh" \
    "authorities/PROJECT-OVERLAY.md" "authorities/TRACEABILITY_MATRIX.md" \
    "authorities/flow-of-work-contract/00-INDEX.md" \
    "authorities/flow-of-work-contract/01-LLM-SESSION-CONTRACT.md" \
    "authorities/flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md" \
    "authorities/flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md" \
    "authorities/flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md" \
    "authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md" \
    "authorities/flow-of-work-contract/06-VALIDATION-EXECUTION-CONTRACT.md" \
    "authorities/manual/MANUAL-BOOTSTRAP.md" \
    "authorities/manual/REACHING-THE-LLMS.md"
  do
    require_exists "$root" "$relpath"
  done

  local agent_text
  agent_text=$(cat "$root/AGENT.md" 2>/dev/null || printf '')
  printf '%s\n' "$agent_text" | grep -qF "## 1. Initialization Check" && \
    emit_error "runtime-agent-template-leak" \
      "AGENT.md still contains the template-only Initialization Check section"
  { printf '%s\n' "$agent_text" | grep -qF "route the user to the framework repo" || \
    printf '%s\n' "$agent_text" | grep -qF "STARTER.md"; } && \
    emit_error "runtime-agent-adoption-fallback" \
      "AGENT.md still contains adoption fallback text or STARTER.md references"
  printf '%s\n' "$agent_text" | grep -qF "[Project Name]" && \
    emit_error "runtime-agent-placeholder" \
      "AGENT.md still contains [Project Name] placeholder text"
  printf '%s\n' "$agent_text" | grep -qF "CODE-WORKFLOW-CONTRACT.md" || \
    emit_error "runtime-agent-code-workflow-contract" \
      "AGENT.md does not reference CODE-WORKFLOW-CONTRACT.md"

  local overlay_text
  overlay_text=$(cat "$root/authorities/PROJECT-OVERLAY.md" 2>/dev/null || printf '')
  printf '%s\n' "$overlay_text" | grep -qF "[Project Name]" && \
    emit_error "overlay-placeholder" \
      "PROJECT-OVERLAY.md still contains [Project Name] placeholder text"

  local key
  for key in \
    "adoption mode" "adoption procedure" \
    "manual bootstrap status" "manual readiness level" "manual override acknowledged" \
    "code bootstrap mode" "code bootstrap status" \
    "code bootstrap source type" "code bootstrap requested output"
  do
    check_allowed_value "$overlay_text" "$key"
  done

  local tooling_spec key required command
  for tooling_spec in \
    "runtime state command:state" \
    "route command:route" \
    "location command:where" \
    "governance status command:status" \
    "active diff command:active-diff" \
    "workspace doctor command:doctor" \
    "handoff command:handoff" \
    "impl check command:check impl" \
    "traceability check command:check matrix" \
    "diff check command:check diff" \
    "campaign check command:check campaign" \
    "sync check command:sync-check"
  do
    key="${tooling_spec%%:*}"
    required="${tooling_spec#*:}"
    command=$(clean_cell "$(get_strong_field "$overlay_text" "$key")")
    if [[ -z "$command" ]]; then
      emit_error "operational-tool-command-missing" \
        "PROJECT-OVERLAY.md missing operational tooling command: $key"
      continue
    fi
    [[ "$command" != *"flowctl.sh"* ]] && \
      emit_error "operational-tool-command-invalid" \
        "Operational tooling command '$key' must use flowctl.sh"
    [[ "$command" != *"$required"* ]] && \
      emit_error "operational-tool-command-invalid" \
        "Operational tooling command '$key' must contain '$required'"
  done

  local manual_status manual_level manual_override adoption_mode
  local code_mode code_status code_source code_output
  manual_status=$(clean_cell "$(get_strong_field "$overlay_text" "manual bootstrap status")")
  manual_level=$(clean_cell "$(get_strong_field "$overlay_text" "manual readiness level")")
  manual_override=$(clean_cell "$(get_strong_field "$overlay_text" "manual override acknowledged")")
  adoption_mode=$(clean_cell "$(get_strong_field "$overlay_text" "adoption mode")")
  code_mode=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap mode")")
  code_status=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap status")")
  code_source=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap source type")")
  code_output=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap requested output")")

  [[ "$manual_status" == "skipped_by_user" && "$manual_override" != "yes" ]] && \
    emit_error "manual-skip-override" \
      "manual bootstrap status is skipped_by_user but manual override acknowledged is not yes"
  [[ "$manual_status" == "completed" && "$manual_level" != "basic" && \
     "$manual_level" != "operational" ]] && \
    emit_error "manual-completed-level" \
      "manual bootstrap status is completed but readiness level is not basic or operational"
  [[ "$manual_status" == "pending" && "$manual_level" == "operational" ]] && \
    emit_warning "manual-pending-operational" \
      "manual bootstrap is pending but readiness is already operational"

  [[ "$code_mode" == "not_required" && \
     "$code_status" != "not_required" && "$code_status" != "unknown" ]] && \
    emit_error "code-bootstrap-state-mismatch" \
      "code bootstrap mode is not_required but status is still active"
  [[ "$code_status" == "not_required" && \
     "$code_mode" != "not_required" && "$code_mode" != "unknown" ]] && \
    emit_error "code-bootstrap-status-mismatch" \
      "code bootstrap status is not_required but mode still declares an active bootstrap type"
  [[ "$code_mode" == "local_code_first_derivation" && "$adoption_mode" != "code_first" ]] && \
    emit_error "code-first-mode-mismatch" \
      "local_code_first_derivation is declared outside adoption mode = code_first"
  [[ "$code_mode" == "local_code_first_derivation" && \
     "$code_source" != "local_project" && "$code_source" != "unknown" ]] && \
    emit_error "code-source-mismatch" \
      "local_code_first_derivation must use code bootstrap source type local_project"
  [[ "$code_mode" == "external_source_integration" && \
     ( "$code_source" == "none" || "$code_source" == "local_project" ) ]] && \
    emit_error "external-source-mismatch" \
      "external_source_integration must not use source type none or local_project"
  [[ "$code_mode" == "not_required" && \
     "$code_output" != "not_required" && "$code_output" != "unknown" ]] && \
    emit_warning "code-output-stale" \
      "code bootstrap mode is not_required but requested output is still specific"
  [[ "$adoption_mode" == "code_first" && "$code_mode" == "not_required" && \
     "$code_status" == "not_required" ]] && \
    emit_ok "code_first project appears to have completed or reset its code bootstrap state"

  local map_section
  map_section=$(extract_section "$overlay_text" "## 10. Document Location Map")
  if [[ -z "$map_section" ]]; then
    emit_error "overlay-map-missing" \
      "PROJECT-OVERLAY.md does not contain section 10 Document Location Map"
    return
  fi

  local row_name
  for row_name in \
    "Requirements baseline" "Interactions" "Requirement diffs" "Requirement diff index" \
    "Implementation packets" "Implementation packet index" \
    "Review records" "Review index" "Test campaigns" "Test campaign index" \
    "Test environment startup helper" "Traceability matrix"
  do
    local found=0
    local nrow
    nrow=$(normalize_label "$row_name")
    while IFS=$'\t' read -r dt _ _; do
      [[ "$(normalize_label "$dt")" == "$nrow" ]] && found=1 && break
    done < <(parse_overlay_map "$map_section")
    [[ "$found" -eq 0 ]] && \
      emit_error "overlay-map-row-missing" "Document location map missing row: $row_name"
  done

  while IFS=$'\t' read -r dt _ al; do
    [[ "$(normalize_label "$dt")" == "traceability matrix" ]] || continue
    local actual
    actual=$(clean_cell "$al")
    [[ "$(printf "%s" "$actual" | tr '[:upper:]' '[:lower:]')" != "default" ]] && \
      emit_error "traceability-location-not-fixed" \
        "Traceability matrix must remain at authorities/TRACEABILITY_MATRIX.md with Actual location = default"
    break
  done < <(parse_overlay_map "$map_section")

  while IFS=$'\t' read -r dt dl al; do
    local path
    path=$(resolve_declared_path "$root" "$dl" "$al" "$dt")
    [[ -z "$path" ]] && continue
    [[ ! -e "$path" ]] && \
      emit_error "overlay-map-path-missing" "Declared path for '$dt' does not exist: $path"
  done < <(parse_overlay_map "$map_section")

  local required_template
  for required_template in \
    "Requirement diffs:REQUIREMENTS-DIFF-TEMPLATE.md" \
    "Implementation packets:IMPL-TEMPLATE.md" \
    "Review records:REVIEW-TEMPLATE.md" \
    "Test campaigns:TEST-CAMPAIGN-TEMPLATE.md"
  do
    local rrow="${required_template%%:*}" tfile="${required_template##*:}"
    local nrrow
    nrrow=$(normalize_label "$rrow")
    while IFS=$'\t' read -r dt dl al; do
      [[ "$(normalize_label "$dt")" != "$nrrow" ]] && continue
      local cat_path
      cat_path=$(resolve_declared_path "$root" "$dl" "$al" "$rrow")
      [[ -z "$cat_path" ]] && break
      [[ ! -f "$cat_path/$tfile" ]] && \
        emit_error "category-template-missing" \
          "Missing category template at resolved '$rrow' location: $cat_path/$tfile"
      break
    done < <(parse_overlay_map "$map_section")
  done

  local index_path=""
  while IFS=$'\t' read -r dt dl al; do
    [[ "$(normalize_label "$dt")" == "requirement diff index" ]] || continue
    index_path=$(resolve_declared_path "$root" "$dl" "$al" "Requirement diff index")
    break
  done < <(parse_overlay_map "$map_section")

  if [[ -n "$index_path" ]]; then
    [[ ! -f "$index_path" ]] && \
      emit_error "diff-index-missing" \
        "Missing REQUIREMENTS_DIFF_INDEX.md at resolved location: $index_path"
    local diff_dir
    diff_dir=$(dirname "$index_path")
    while IFS=$'\t' read -r dt dl al; do
      [[ "$(normalize_label "$dt")" == "requirement diffs" ]] || continue
      local dpath
      dpath=$(resolve_declared_path "$root" "$dl" "$al" "Requirement diffs")
      [[ -n "$dpath" ]] && diff_dir="$dpath"
      break
    done < <(parse_overlay_map "$map_section")
    validate_diff_index "$index_path" "$diff_dir"
  fi
}

# ── check impl ─────────────────────────────────────────────────────────────────

AUTHORITY_TYPES="requirements_diff use_case sequence user_instruction working_code_reference not_applicable"

check_impl_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    emit_error "impl-missing" "IMPL file does not exist: $path"
    return
  fi

  local text section
  text=$(cat "$path")
  section=$(extract_section "$text" "## 4. Behavioral Definition Gate")
  if [[ -z "$section" ]]; then
    emit_error "impl-behavior-gate-missing" "Missing section: ## 4. Behavioral Definition Gate"
    return
  fi

  local field
  for field in \
    "gate status" "authority type" "authority reference" \
    "runtime/user-visible behavior affected" "fallback/error behavior affected"
  do
    local val
    val=$(get_strong_field "$section" "$field")
    [[ -z "$val" ]] && emit_error "impl-gate-field-missing" "Missing gate field: $field"
  done
  [[ "$ERR_COUNT" -gt 0 ]] && return

  local doc_status
  doc_status=$(get_frontmatter_field "$text" "status")
  [[ -z "$doc_status" ]] && doc_status=$(get_strong_field "$text" "status")
  doc_status=$(clean_cell "$doc_status")
  printf '%s' "$doc_status" | grep -qi "template" && return

  local gate_status authority_type authority_reference runtime_affected fallback_affected
  gate_status=$(clean_cell "$(get_strong_field "$section" "gate status")")
  gate_status=$(printf "%s" "$gate_status" | tr '[:upper:]' '[:lower:]')
  authority_type=$(clean_cell "$(get_strong_field "$section" "authority type")")
  authority_type=$(printf "%s" "$authority_type" | tr '[:upper:]' '[:lower:]')
  authority_reference=$(clean_cell "$(get_strong_field "$section" "authority reference")")
  runtime_affected=$(clean_cell "$(get_strong_field "$section" "runtime/user-visible behavior affected")")
  runtime_affected=$(printf "%s" "$runtime_affected" | tr '[:upper:]' '[:lower:]')
  fallback_affected=$(clean_cell "$(get_strong_field "$section" "fallback/error behavior affected")")
  fallback_affected=$(printf "%s" "$fallback_affected" | tr '[:upper:]' '[:lower:]')

  [[ "$gate_status" != "clear" && "$gate_status" != "blocked" ]] && \
    emit_error "impl-gate-status-invalid" "Gate status must be clear or blocked"

  if [[ "$gate_status" == "clear" ]]; then
    local found_at=0 at
    for at in $AUTHORITY_TYPES; do
      [[ "$at" == "$authority_type" ]] && found_at=1 && break
    done
    [[ "$found_at" -eq 0 ]] && \
      emit_error "impl-authority-type-invalid" "Authority type is missing or invalid"

    if [[ "$authority_type" == "not_applicable" ]]; then
      [[ "$runtime_affected" == "yes" || "$fallback_affected" == "yes" ]] && \
        emit_error "impl-authority-not-applicable-invalid" \
          "Authority type cannot be not_applicable when behavior is affected"
    else
      is_placeholder "$authority_reference" && \
        emit_error "impl-authority-reference-missing" "Clear gate requires authority reference"
    fi

    [[ "$runtime_affected" != "yes" && "$runtime_affected" != "no" ]] && \
      emit_error "impl-runtime-affected-invalid" \
        "Runtime/user-visible behavior affected must be yes or no"
    [[ "$fallback_affected" != "yes" && "$fallback_affected" != "no" && \
       "$fallback_affected" != "out_of_scope" ]] && \
      emit_error "impl-fallback-affected-invalid" \
        "Fallback/error behavior affected must be yes, no, or out_of_scope"
  fi

  if [[ "$gate_status" == "blocked" ]]; then
    local data_rows=0
    while IFS= read -r row; do
      local n
      n=$(count_cells "$row")
      [[ "$n" -lt 3 ]] && continue
      local c1 c2 c3
      c1=$(clean_cell "$(get_cell "$row" 1)")
      c2=$(clean_cell "$(get_cell "$row" 2)")
      c3=$(clean_cell "$(get_cell "$row" 3)")
      if ! { is_placeholder "$c1" && is_placeholder "$c2" && is_placeholder "$c3"; }; then
        data_rows=$(( data_rows + 1 ))
      fi
    done < <(table_rows "$section" | tail -n +2)
    [[ "$data_rows" -eq 0 ]] && \
      emit_error "impl-blocked-missing-decision" \
        "Blocked gate requires at least one concrete missing-behavior row"
  fi
}

# ── check matrix ───────────────────────────────────────────────────────────────

check_matrix_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    emit_error "matrix-missing" "Traceability matrix does not exist: $path"
    return
  fi

  local text section
  text=$(cat "$path")
  section=$(extract_section "$text" "## 2. Functional Traceability")
  if [[ -z "$section" ]]; then
    emit_error "matrix-functional-section-missing" \
      "Missing section: ## 2. Functional Traceability"
    return
  fi

  local all_rows
  all_rows=$(table_rows "$section")
  if [[ -z "$all_rows" ]]; then
    emit_error "matrix-table-missing" "Functional traceability table is missing"
    return
  fi

  local header_row
  header_row=$(printf '%s\n' "$all_rows" | head -1)
  local n_cols
  n_cols=$(count_cells "$header_row")

  local idx_id=0 idx_impl=0 idx_gate=0 idx_evidence=0 idx_status=0 i
  for (( i=1; i<=n_cols; i++ )); do
    local cell
    cell=$(normalize_label "$(get_cell "$header_row" "$i")")
    case "$cell" in
      "id(s)")            idx_id=$i ;;
      "impl packet(s)")   idx_impl=$i ;;
      "behavior gate")    idx_gate=$i ;;
      "primary evidence") idx_evidence=$i ;;
      "status")           idx_status=$i ;;
    esac
  done

  local cname cvar
  for cname in "id(s):$idx_id" "impl packet(s):$idx_impl" "behavior gate:$idx_gate" \
               "primary evidence:$idx_evidence" "status:$idx_status"
  do
    local cn="${cname%%:*}" cv="${cname##*:}"
    [[ "$cv" -eq 0 ]] && emit_error "matrix-column-missing" "Missing matrix column: $cn"
  done
  [[ "$ERR_COUNT" -gt 0 ]] && return

  local row_number=2
  while IFS= read -r row; do
    local n
    n=$(count_cells "$row")
    if [[ "$n" -lt "$n_cols" ]]; then
      emit_error "matrix-row-short" "Row $row_number has too few columns"
      row_number=$(( row_number + 1 ))
      continue
    fi
    local req_id gate evidence status
    req_id=$(clean_cell "$(get_cell "$row" "$idx_id")")
    gate=$(clean_cell "$(get_cell "$row" "$idx_gate")"); gate=$(printf "%s" "$gate" | tr '[:upper:]' '[:lower:]')
    evidence=$(clean_cell "$(get_cell "$row" "$idx_evidence")")
    status=$(clean_cell "$(get_cell "$row" "$idx_status")"); status=$(printf "%s" "$status" | tr '[:upper:]' '[:lower:]')

    [[ "$gate" != "clear" && "$gate" != "blocked" && "$gate" != "not_applicable" ]] && \
      emit_error "matrix-behavior-gate-invalid" \
        "Row $row_number ($req_id) has invalid behavior gate: $gate"
    [[ "$status" == "implemented" && "$gate" == "blocked" ]] && \
      emit_error "matrix-implemented-blocked" \
        "Row $row_number ($req_id) is Implemented but behavior gate is blocked"
    if [[ "$status" == "implemented" || "$status" == "partial" ]]; then
      [[ -z "$evidence" || "$evidence" == "—" || "$evidence" == "-" ]] && \
        emit_error "matrix-evidence-missing" \
          "Row $row_number ($req_id) is $status but primary evidence is missing"
    fi
    row_number=$(( row_number + 1 ))
  done < <(printf '%s\n' "$all_rows" | tail -n +2)
}

# ── check diff ─────────────────────────────────────────────────────────────────

check_diff_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    emit_error "diff-missing" "Requirements diff file does not exist: $path"
    return
  fi

  local text
  text=$(cat "$path")

  local heading
  for heading in \
    "## 1. Purpose" \
    "## 2. Authority And Succession" \
    "## 3. Scope" \
    "## 4. Requirement Changes" \
    "## 5. Interaction And Sequence Impact" \
    "## 6. Concept Closure" \
    "## 7. Behavioral Definition" \
    "## 8. Propagation Impact" \
    "## 9. Acceptance Criteria" \
    "## 10. Open Questions"
  do
    [[ -z "$(extract_section "$text" "$heading")" ]] && \
      emit_error "diff-section-missing" "Missing section: $heading"
  done

  local doc_status
  doc_status=$(metadata_status "$path")
  printf '%s' "$doc_status" | grep -qi "template" && return

  local open_questions
  open_questions=$(extract_section "$text" "## 10. Open Questions")
  while IFS= read -r row; do
    local n question blocking
    n=$(count_cells "$row")
    [[ "$n" -lt 3 ]] && continue
    question=$(clean_cell "$(get_cell "$row" 1)")
    blocking=$(clean_cell "$(get_cell "$row" 3)")
    blocking=$(printf '%s' "$blocking" | tr '[:upper:]' '[:lower:]')
    if [[ "$blocking" == "yes" || "$blocking" == "true" || "$blocking" == "blocking" ]]; then
      emit_error "diff-blocking-open-question" \
        "Blocking open question remains in diff: $question"
    fi
  done < <(table_rows "$open_questions" | tail -n +2)
}

# ── check campaign ─────────────────────────────────────────────────────────────

check_campaign_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    emit_error "campaign-missing" "Test campaign file does not exist: $path"
    return
  fi

  local text
  text=$(cat "$path")

  local heading
  for heading in \
    "## 2. Readiness And Constructibility" \
    "## 5.1 Adversarial Validation Design" \
    "## 6. Test Matrix" \
    "## 7. Evidence Log" \
    "## 8. Failure Triage" \
    "## 8.1 Blocker Ledger" \
    "## 9. Result" \
    "## 10. Traceability Recommendation" \
    "## 11. Acceptance Record"
  do
    [[ -z "$(extract_section "$text" "$heading")" ]] && \
      emit_error "campaign-section-missing" "Missing section: $heading"
  done

  local readiness_section validation_section result_section acceptance_section
  readiness_section=$(extract_section "$text" "## 2. Readiness And Constructibility")
  validation_section=$(extract_section "$text" "## 5.1 Adversarial Validation Design")
  result_section=$(extract_section "$text" "## 9. Result")
  acceptance_section=$(extract_section "$text" "## 11. Acceptance Record")

  local field
  for field in "readiness for validation handoff" "campaign constructibility"; do
    [[ -z "$(get_strong_field "$readiness_section" "$field")" ]] && \
      emit_error "campaign-readiness-field-missing" "Missing campaign field: $field"
  done
  for field in \
    "pass-bias guard completed" \
    "worst-case path included" \
    "negative/error path included" \
    "regression path included" \
    "real acceptance surface used"
  do
    [[ -z "$(get_strong_field "$validation_section" "$field")" ]] && \
      emit_error "campaign-validation-field-missing" "Missing campaign validation field: $field"
  done
  [[ -z "$(get_strong_field "$result_section" "campaign result")" ]] && \
    emit_error "campaign-result-field-missing" "Missing campaign field: campaign result"
  for field in "acceptance authority" "decision"; do
    [[ -z "$(get_strong_field "$acceptance_section" "$field")" ]] && \
      emit_error "campaign-acceptance-field-missing" "Missing campaign field: $field"
  done

  local doc_status
  doc_status=$(metadata_status "$path")
  printf '%s' "$doc_status" | grep -qi "template" && return

  local campaign_result decision must_have_blockers=0
  campaign_result=$(clean_cell "$(get_strong_field "$result_section" "campaign result")")
  campaign_result=$(printf '%s' "$campaign_result" | tr '[:upper:]' '[:lower:]')
  decision=$(clean_cell "$(get_strong_field "$acceptance_section" "decision")")
  decision=$(printf '%s' "$decision" | tr '[:upper:]' '[:lower:]')

  local pass_bias real_surface
  pass_bias=$(clean_cell "$(get_strong_field "$validation_section" "pass-bias guard completed")")
  pass_bias=$(printf '%s' "$pass_bias" | tr '[:upper:]' '[:lower:]')
  real_surface=$(clean_cell "$(get_strong_field "$validation_section" "real acceptance surface used")")
  real_surface=$(printf '%s' "$real_surface" | tr '[:upper:]' '[:lower:]')
  [[ "$pass_bias" != "yes" ]] && \
    emit_error "campaign-pass-bias-guard-not-complete" \
      "Campaign must complete the pass-bias guard before it can be authoritative"
  [[ "$real_surface" == "no" ]] && \
    emit_warning "campaign-real-surface-not-used" \
      "Campaign does not use the real acceptance surface; result may be support evidence only"

  case "$campaign_result" in
    fail|partial) must_have_blockers=1 ;;
  esac
  case "$decision" in
    *constraint*|rejected|deferred) must_have_blockers=1 ;;
  esac

  if [[ "$must_have_blockers" -eq 1 ]]; then
    local blocker_section concrete=0
    blocker_section=$(extract_section "$text" "## 8.1 Blocker Ledger")
    while IFS= read -r row; do
      local n c1 c2 c3 c4 c5
      n=$(count_cells "$row")
      [[ "$n" -lt 5 ]] && continue
      c1=$(clean_cell "$(get_cell "$row" 1)")
      c2=$(clean_cell "$(get_cell "$row" 2)")
      c3=$(clean_cell "$(get_cell "$row" 3)")
      c4=$(clean_cell "$(get_cell "$row" 4)")
      c5=$(clean_cell "$(get_cell "$row" 5)")
      if ! { is_placeholder "$c1" && is_placeholder "$c2" && is_placeholder "$c3" && is_placeholder "$c4" && is_placeholder "$c5"; }; then
        concrete=1
        break
      fi
    done < <(table_rows "$blocker_section" | tail -n +2)
    [[ "$concrete" -eq 0 ]] && \
      emit_error "campaign-blocker-ledger-missing" \
        "FAIL/PARTIAL/constrained campaign requires a concrete blocker ledger row"
  fi
}

# ── sync check ─────────────────────────────────────────────────────────────────

sync_compare_file() {
  local framework="$1" workspace="$2" fw_rel="$3" ws_rel="$4"
  local fw_path="$framework/$fw_rel" ws_path="$workspace/$ws_rel"
  if [[ ! -f "$fw_path" ]]; then
    emit_error "sync-framework-file-missing" "Framework reference file missing: $fw_rel"
    return
  fi
  if [[ ! -f "$ws_path" ]]; then
    emit_error "sync-workspace-file-missing" "Workspace installed file missing: $ws_rel"
    return
  fi
  if ! cmp -s "$fw_path" "$ws_path"; then
    emit_warning "sync-file-drift" "Installed file differs from framework: $ws_rel"
  fi
}

check_workspace_sync() {
  local workspace="$1" framework="$2"
  if [[ ! -d "$workspace" ]]; then
    emit_error "sync-workspace-missing" "Workspace path does not exist: $workspace"
    return
  fi
  if [[ ! -d "$framework" ]]; then
    emit_error "sync-framework-missing" "Framework path does not exist: $framework"
    return
  fi
  if [[ "$workspace" == "$framework" ]]; then
    emit_warning "sync-self-compare" \
      "Workspace and framework paths are identical; pass --framework when running sync-check from an adopted workspace"
    return
  fi

  sync_compare_file "$framework" "$workspace" "tools/flowctl.sh" "tools/flowctl.sh"
  sync_compare_file "$framework" "$workspace" "tools/CONTROL-PLANE-LINT-SPEC.md" "tools/CONTROL-PLANE-LINT-SPEC.md"
  sync_compare_file "$framework" "$workspace" "CODE-WORKFLOW-CONTRACT.md" "CODE-WORKFLOW-CONTRACT.md"
  sync_compare_file "$framework" "$workspace" "CODE-BOOTSTRAP.md" "CODE-BOOTSTRAP.md"
  sync_compare_file "$framework" "$workspace" "manual/MANUAL-BOOTSTRAP.md" "authorities/manual/MANUAL-BOOTSTRAP.md"
  sync_compare_file "$framework" "$workspace" "manual/REACHING-THE-LLMS.md" "authorities/manual/REACHING-THE-LLMS.md"

  local name
  for name in \
    "00-INDEX.md" "01-LLM-SESSION-CONTRACT.md" "02-DOCSET-GOVERNANCE-CONTRACT.md" \
    "03-BEHAVIORAL-DEFINITION-GATE.md" "04-TEST-AND-HANDOFF-CONTRACT.md" \
    "05-PROJECT-STRUCTURE.md" "06-VALIDATION-EXECUTION-CONTRACT.md"
  do
    sync_compare_file "$framework" "$workspace" \
      "flow-of-work-contract/$name" "authorities/flow-of-work-contract/$name"
  done

  sync_compare_file "$framework" "$workspace" \
    "templates/IMPL-TEMPLATE.md" "authorities/impl/IMPL-TEMPLATE.md"
  sync_compare_file "$framework" "$workspace" \
    "templates/REQUIREMENTS-DIFF-TEMPLATE.md" "authorities/diffs/REQUIREMENTS-DIFF-TEMPLATE.md"
  sync_compare_file "$framework" "$workspace" \
    "templates/REVIEW-TEMPLATE.md" "authorities/reviews/REVIEW-TEMPLATE.md"
  sync_compare_file "$framework" "$workspace" \
    "templates/TEST-CAMPAIGN-TEMPLATE.md" "authorities/campaigns/TEST-CAMPAIGN-TEMPLATE.md"

  if [[ ! -f "$workspace/AGENT.md" && -f "$workspace/AGENTS.md" ]]; then
    emit_warning "sync-agent-entrypoint-legacy" \
      "Workspace uses AGENTS.md while the current framework standard is AGENT.md"
  fi

  local overlay="$workspace/authorities/PROJECT-OVERLAY.md"
  if [[ -f "$overlay" ]]; then
    local overlay_text
    overlay_text=$(cat "$overlay")
    printf '%s\n' "$overlay_text" | grep -qF "## 11. Operational Tooling" || \
      emit_warning "sync-overlay-tooling-old" \
        "Workspace overlay does not use current sec. 11 Operational Tooling shape"
  else
    emit_error "sync-overlay-missing" "Workspace overlay missing: authorities/PROJECT-OVERLAY.md"
  fi
}

# ── commands ───────────────────────────────────────────────────────────────────

cmd_doctor() {
  local target="${1:-.}" mode="${2:-auto}"
  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }

  [[ "$mode" == "auto" ]] && mode=$(detect_mode "$root")

  case "$mode" in
    framework) check_framework_mode "$root" ;;
    workspace) check_workspace_mode "$root" ;;
    *) emit_error "mode-undetected" "Could not detect framework or workspace mode" ;;
  esac

  print_issues "$mode" "$root"
  [[ "$ERR_COUNT" -eq 0 ]]
}

cmd_status() {
  local target="${1:-.}"
  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }
  local mode
  mode=$(detect_mode "$root")

  printf 'Mode: %s\n' "$mode"
  printf 'Target: %s\n' "$root"

  if [[ "$mode" == "framework" ]]; then
    printf 'Contracts:\n'
    local name
    for name in \
      "00-INDEX.md" "01-LLM-SESSION-CONTRACT.md" "02-DOCSET-GOVERNANCE-CONTRACT.md" \
      "03-BEHAVIORAL-DEFINITION-GATE.md" "04-TEST-AND-HANDOFF-CONTRACT.md" \
      "05-PROJECT-STRUCTURE.md" "06-VALIDATION-EXECUTION-CONTRACT.md"
    do
      local p="$root/flow-of-work-contract/$name" status
      [[ -f "$p" ]] && status=$(metadata_status "$p") || status="missing"
      printf '%s\n' "- ${name}: ${status}"
    done
    return 0
  fi

  local index_path
  index_path=$(find_diff_index "$root" 2>/dev/null || printf '')
  if [[ -n "$index_path" ]]; then
    local active_diff="" active_state=""
    while IFS= read -r line; do
      case "$line" in
        active_diff=*)  active_diff="${line#active_diff=}" ;;
        active_state=*) active_state="${line#active_state=}" ;;
      esac
    done < <(active_diff_info "$index_path")
    printf 'Requirement diff index: %s\n' "$index_path"
    printf 'Active diff: %s\n' "${active_diff:-unknown}"
    printf 'Active state: %s\n' "${active_state:-unknown}"
  else
    printf 'Requirement diff index: not found\n'
  fi

  [[ "$mode" != "unknown" ]]
}

cmd_state() {
  local target="${1:-.}"
  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }
  local mode
  mode=$(detect_mode "$root")

  printf 'Mode: %s\n' "$mode"
  printf 'Target: %s\n' "$root"

  if [[ "$mode" != "workspace" ]]; then
    printf 'ERROR: state requires an adopted workspace target\n'
    return 1
  fi

  local overlay="$root/authorities/PROJECT-OVERLAY.md"
  if [[ ! -f "$overlay" ]]; then
    printf 'ERROR: PROJECT-OVERLAY.md not found under %s\n' "$root"
    return 1
  fi

  local overlay_text
  overlay_text=$(cat "$overlay")
  local manual_status manual_level code_mode code_status code_source code_output
  manual_status=$(clean_cell "$(get_strong_field "$overlay_text" "manual bootstrap status")")
  manual_level=$(clean_cell "$(get_strong_field "$overlay_text" "manual readiness level")")
  code_mode=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap mode")")
  code_status=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap status")")
  code_source=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap source type")")
  code_output=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap requested output")")

  printf 'Manual bootstrap status: %s\n' "${manual_status:-unknown}"
  printf 'Manual readiness level: %s\n' "${manual_level:-unknown}"
  printf 'Code bootstrap mode: %s\n' "${code_mode:-unknown}"
  printf 'Code bootstrap status: %s\n' "${code_status:-unknown}"
  printf 'Code bootstrap source type: %s\n' "${code_source:-unknown}"
  printf 'Code bootstrap requested output: %s\n' "${code_output:-unknown}"

  local index_path
  index_path=$(find_diff_index "$root" 2>/dev/null || printf '')
  if [[ -n "$index_path" ]]; then
    local active_diff="" active_state=""
    while IFS= read -r line; do
      case "$line" in
        active_diff=*)  active_diff="${line#active_diff=}" ;;
        active_state=*) active_state="${line#active_state=}" ;;
      esac
    done < <(active_diff_info "$index_path")
    printf 'Requirement diff index: %s\n' "$index_path"
    printf 'Active diff: %s\n' "${active_diff:-unknown}"
    printf 'Active state: %s\n' "${active_state:-unknown}"
    if [[ -n "$active_diff" && "$(printf '%s' "$active_diff" | tr '[:upper:]' '[:lower:]')" != "none" ]]; then
      local diff_dir resolved
      diff_dir=$(diff_dir_for_index "$root" "$index_path")
      case "$active_diff" in
        /*) resolved="$active_diff" ;;
        *)  resolved="$diff_dir/$active_diff" ;;
      esac
      printf 'Active diff resolved path: %s\n' "$resolved"
      [[ -f "$resolved" ]] && printf 'Active diff exists: yes\n' || printf 'Active diff exists: no\n'
    fi
  else
    printf 'Requirement diff index: not found\n'
  fi

  printf 'Route: '
  if [[ "$manual_status" == "pending" || "$manual_status" == "in-progress" ]]; then
    printf 'manual-bootstrap\n'
  elif [[ "$code_mode" != "not_required" && ( "$code_status" == "pending" || "$code_status" == "in-progress" ) ]]; then
    printf 'code-bootstrap\n'
  else
    printf 'normal-work\n'
  fi
}

cmd_active_diff_show() {
  local target="${1:-.}"
  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }

  local index_path
  index_path=$(find_diff_index "$root" 2>/dev/null || printf '')
  if [[ -z "$index_path" ]]; then
    printf 'ERROR: no REQUIREMENTS_DIFF_INDEX.md found under %s\n' "$root"
    return 1
  fi

  local active_diff="" active_state=""
  while IFS= read -r line; do
    case "$line" in
      active_diff=*)  active_diff="${line#active_diff=}" ;;
      active_state=*) active_state="${line#active_state=}" ;;
    esac
  done < <(active_diff_info "$index_path")

  if [[ -z "$active_diff" && -z "$active_state" ]]; then
    printf 'ERROR: %s has no Current Active Diff data\n' "$index_path"
    return 1
  fi

  printf 'Index: %s\n' "$index_path"
  printf 'Active diff: %s\n' "${active_diff:-unknown}"
  printf 'Active state: %s\n' "${active_state:-unknown}"

  if [[ -n "$active_diff" && "$(printf '%s' "$active_diff" | tr '[:upper:]' '[:lower:]')" != "none" ]]; then
    local resolved diff_dir
    diff_dir=$(diff_dir_for_index "$root" "$index_path")
    case "$active_diff" in
      /*) resolved="$active_diff" ;;
      *)  resolved="$diff_dir/$active_diff" ;;
    esac
    printf 'Resolved path: %s\n' "$resolved"
    [[ -f "$resolved" ]] && printf 'Exists: yes\n' || printf 'Exists: no\n'
  fi
}

where_row_for_alias() {
  local alias
  alias=$(normalize_label "$1")
  case "$alias" in
    baseline|"requirements baseline") printf 'Requirements baseline' ;;
    interactions) printf 'Interactions' ;;
    diffs|"requirement diffs") printf 'Requirement diffs' ;;
    diff-index|"requirement diff index") printf 'Requirement diff index' ;;
    impl|"implementation packets") printf 'Implementation packets' ;;
    impl-index|"implementation packet index") printf 'Implementation packet index' ;;
    reviews|"review records") printf 'Review records' ;;
    review-index|"review index") printf 'Review index' ;;
    campaigns|"test campaigns") printf 'Test campaigns' ;;
    campaign-index|"test campaign index") printf 'Test campaign index' ;;
    startup-helper|"test environment startup helper") printf 'Test environment startup helper' ;;
    traceability|"traceability matrix") printf 'Traceability matrix' ;;
    *) printf '' ;;
  esac
}

cmd_where() {
  local target="${1:-.}" alias="${2:-}"
  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }
  [[ "$(detect_mode "$root")" == "workspace" ]] || {
    printf 'ERROR: where requires an adopted workspace target\n'
    return 1
  }
  if [[ -z "$alias" ]]; then
    printf 'Known keys: baseline, interactions, diffs, diff-index, impl, impl-index, reviews, review-index, campaigns, campaign-index, startup-helper, traceability\n'
    return 0
  fi
  local row path
  row=$(where_row_for_alias "$alias")
  if [[ -z "$row" ]]; then
    printf 'ERROR: unknown location key: %s\n' "$alias"
    return 1
  fi
  path=$(overlay_location "$root" "$row" 2>/dev/null || printf '')
  if [[ -z "$path" ]]; then
    printf 'ERROR: could not resolve overlay location for: %s\n' "$row"
    return 1
  fi
  printf '%s\n' "$path"
}

cmd_route() {
  local target="${1:-.}"
  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }
  [[ "$(detect_mode "$root")" == "workspace" ]] || {
    printf 'ERROR: route requires an adopted workspace target\n'
    return 1
  }
  local overlay="$root/authorities/PROJECT-OVERLAY.md"
  [[ -f "$overlay" ]] || { printf 'ERROR: PROJECT-OVERLAY.md not found under %s\n' "$root"; return 1; }
  local overlay_text manual_status code_mode code_status
  overlay_text=$(cat "$overlay")
  manual_status=$(clean_cell "$(get_strong_field "$overlay_text" "manual bootstrap status")")
  code_mode=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap mode")")
  code_status=$(clean_cell "$(get_strong_field "$overlay_text" "code bootstrap status")")

  if [[ "$manual_status" == "pending" || "$manual_status" == "in-progress" ]]; then
    printf 'Route: manual-bootstrap\n'
    printf 'Reason: manual bootstrap status = %s\n' "$manual_status"
    printf 'Document: authorities/manual/MANUAL-BOOTSTRAP.md\n'
  elif [[ "$code_mode" != "not_required" && ( "$code_status" == "pending" || "$code_status" == "in-progress" ) ]]; then
    printf 'Route: code-bootstrap\n'
    printf 'Reason: code bootstrap mode = %s, status = %s\n' "$code_mode" "$code_status"
    printf 'Document: CODE-BOOTSTRAP.md\n'
  else
    printf 'Route: normal-work\n'
  fi
}

cmd_check_impl() {
  local path="$1"
  local abs_path
  abs_path=$(resolve_file_path "$path")
  check_impl_file "$abs_path"
  print_issues "impl" "$abs_path"
  [[ "$ERR_COUNT" -eq 0 ]]
}

cmd_check_matrix() {
  local path="$1"
  local abs_path
  abs_path=$(resolve_file_path "$path")
  check_matrix_file "$abs_path"
  print_issues "matrix" "$abs_path"
  [[ "$ERR_COUNT" -eq 0 ]]
}

cmd_check_diff() {
  local path="$1"
  local abs_path
  abs_path=$(resolve_file_path "$path")
  check_diff_file "$abs_path"
  print_issues "diff" "$abs_path"
  [[ "$ERR_COUNT" -eq 0 ]]
}

cmd_check_campaign() {
  local path="$1"
  local abs_path
  abs_path=$(resolve_file_path "$path")
  check_campaign_file "$abs_path"
  print_issues "campaign" "$abs_path"
  [[ "$ERR_COUNT" -eq 0 ]]
}

cmd_sync_check() {
  local workspace="${1:-.}" framework="${2:-}"
  if [[ -z "$framework" ]]; then
    framework=$(resolve_dir "$(dirname "$0")/..")
  fi
  local workspace_root framework_root
  workspace_root=$(resolve_target_dir "$workspace") || { printf 'ERROR: workspace path does not exist: %s\n' "$workspace"; exit 1; }
  framework_root=$(resolve_target_dir "$framework") || { printf 'ERROR: framework path does not exist: %s\n' "$framework"; exit 1; }
  check_workspace_sync "$workspace_root" "$framework_root"
  print_issues "sync-check" "$workspace_root"
  [[ "$ERR_COUNT" -eq 0 ]]
}

cmd_handoff() {
  local target="." matrix_path="" impl_paths=() diff_paths=() campaign_paths=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --impl)
        shift
        [[ $# -eq 0 ]] && { printf 'ERROR: --impl requires a path\n'; return 1; }
        impl_paths+=("$1")
        shift
        ;;
      --impl=*)
        impl_paths+=("${1#--impl=}")
        shift
        ;;
      --matrix)
        shift
        [[ $# -eq 0 ]] && { printf 'ERROR: --matrix requires a path\n'; return 1; }
        matrix_path="$1"
        shift
        ;;
      --matrix=*)
        matrix_path="${1#--matrix=}"
        shift
        ;;
      --diff)
        shift
        [[ $# -eq 0 ]] && { printf 'ERROR: --diff requires a path\n'; return 1; }
        diff_paths+=("$1")
        shift
        ;;
      --diff=*)
        diff_paths+=("${1#--diff=}")
        shift
        ;;
      --campaign)
        shift
        [[ $# -eq 0 ]] && { printf 'ERROR: --campaign requires a path\n'; return 1; }
        campaign_paths+=("$1")
        shift
        ;;
      --campaign=*)
        campaign_paths+=("${1#--campaign=}")
        shift
        ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  local root
  root=$(resolve_target_dir "$target") || { printf 'ERROR: target path does not exist: %s\n' "$target"; exit 1; }
  check_workspace_mode "$root"

  local impl_path
  for impl_path in "${impl_paths[@]}"; do
    check_impl_file "$(resolve_workspace_file "$root" "$impl_path")"
  done

  local diff_path
  for diff_path in "${diff_paths[@]}"; do
    check_diff_file "$(resolve_workspace_file "$root" "$diff_path")"
  done

  local campaign_path
  for campaign_path in "${campaign_paths[@]}"; do
    check_campaign_file "$(resolve_workspace_file "$root" "$campaign_path")"
  done

  if [[ -n "$matrix_path" ]]; then
    check_matrix_file "$(resolve_workspace_file "$root" "$matrix_path")"
  fi

  print_issues "handoff" "$root"
  [[ "$ERR_COUNT" -eq 0 ]]
}

# ── help ───────────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
flowctl — deterministic flow-of-work governance CLI

USAGE
  bash tools/flowctl.sh <command> [options]

COMMANDS
  doctor [target] [--mode auto|framework|workspace]
      Run structural control-plane lint.
      Auto-detects framework or workspace mode from directory layout.
      Returns exit code 1 if errors are found.

  status [target]
      Show governance status: mode, target, contract states (framework)
      or active diff info (workspace).

  state [target]
      Show workspace runtime state: bootstrap flags, active diff, and route.

  route [target]
      Show the deterministic next route from overlay sec. 8 and sec. 9.

  where [target] <key>
      Resolve a document location from overlay sec. 10.

  active-diff show [target]
      Show the active requirement diff from REQUIREMENTS_DIFF_INDEX.md.

  handoff [target] [--impl path] [--diff path] [--campaign path] [--matrix path]
      Run workspace handoff checks, optionally including IMPL/diff/campaign/matrix artifacts.

  check impl <path>
      Validate the behavioral definition gate of an IMPL packet.

  check matrix <path>
      Validate the structure and consistency of a traceability matrix.

  check diff <path>
      Validate requirements-diff structure and blocking open questions.

  check campaign <path>
      Validate campaign readiness/result/acceptance and blocker-ledger structure.

  sync-check [workspace] [--framework path]
      Compare an adopted workspace's installed flow files against this framework.

OPTIONS
  --help, -h    Show this help message.

EXAMPLES
  bash tools/flowctl.sh doctor .
  bash tools/flowctl.sh doctor . --mode workspace
  bash tools/flowctl.sh status .
  bash tools/flowctl.sh state /path/to/adopted/project
  bash tools/flowctl.sh route /path/to/adopted/project
  bash tools/flowctl.sh where /path/to/adopted/project diff-index
  bash tools/flowctl.sh active-diff show /path/to/adopted/project
  bash tools/flowctl.sh handoff /path/to/adopted/project --impl authorities/impl/IMPL-1.md --campaign authorities/campaigns/TestCampaign-1.md --matrix authorities/TRACEABILITY_MATRIX.md
  bash tools/flowctl.sh check impl authorities/impl/IMPL-1.md
  bash tools/flowctl.sh check matrix authorities/TRACEABILITY_MATRIX.md
  bash tools/flowctl.sh check diff authorities/diffs/REQUIREMENTS_DIFF-1.md
  bash tools/flowctl.sh check campaign authorities/campaigns/TestCampaign-1.md
  bash tools/flowctl.sh sync-check /path/to/adopted/project --framework /path/to/flow-of-work

NOTES
  STARTER.md activates this file with: chmod +x tools/flowctl.sh
  Requires bash and standard POSIX tools (awk, grep, sed).
  Works on macOS, Linux, and Windows via Git Bash.
  The canonical invocation remains: bash tools/flowctl.sh ...
EOF
}

# ── main ───────────────────────────────────────────────────────────────────────

main() {
  [[ $# -eq 0 ]] && usage && exit 0

  case "$1" in
    --help|-h) usage; exit 0 ;;
    doctor)
      shift
      local target="." mode="auto"
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --mode)
            shift
            [[ $# -eq 0 ]] && { printf 'ERROR: --mode requires a value\n'; exit 1; }
            mode="$1"; shift ;;
          --mode=*) mode="${1#--mode=}"; shift ;;
          *)        target="$1"; shift ;;
        esac
      done
      cmd_doctor "$target" "$mode"
      ;;
    status)
      shift; cmd_status "${1:-.}"
      ;;
    state)
      shift; cmd_state "${1:-.}"
      ;;
    route)
      shift; cmd_route "${1:-.}"
      ;;
    where)
      shift
      case "$#" in
        0) cmd_where "." "" ;;
        1) cmd_where "." "$1" ;;
        *) cmd_where "$1" "$2" ;;
      esac
      ;;
    active-diff)
      shift
      [[ "${1:-}" == "show" ]] && shift
      cmd_active_diff_show "${1:-.}"
      ;;
    handoff)
      shift; cmd_handoff "$@"
      ;;
    check)
      shift
      case "${1:-}" in
        impl)
          shift
          [[ -z "${1:-}" ]] && { printf 'ERROR: check impl requires a path\n'; exit 1; }
          cmd_check_impl "$1"
          ;;
        matrix)
          shift
          [[ -z "${1:-}" ]] && { printf 'ERROR: check matrix requires a path\n'; exit 1; }
          cmd_check_matrix "$1"
          ;;
        diff)
          shift
          [[ -z "${1:-}" ]] && { printf 'ERROR: check diff requires a path\n'; exit 1; }
          cmd_check_diff "$1"
          ;;
        campaign)
          shift
          [[ -z "${1:-}" ]] && { printf 'ERROR: check campaign requires a path\n'; exit 1; }
          cmd_check_campaign "$1"
          ;;
        *)
          printf 'ERROR: unknown check subcommand: %s\n' "${1:-}"
          usage; exit 1
          ;;
      esac
      ;;
    sync-check)
      shift
      local workspace="${1:-.}" framework=""
      [[ $# -gt 0 ]] && shift
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --framework)
            shift
            [[ $# -eq 0 ]] && { printf 'ERROR: --framework requires a path\n'; exit 1; }
            framework="$1"
            shift
            ;;
          --framework=*)
            framework="${1#--framework=}"
            shift
            ;;
          *)
            printf 'ERROR: unknown sync-check option: %s\n' "$1"
            exit 1
            ;;
        esac
      done
      cmd_sync_check "$workspace" "$framework"
      ;;
    *)
      printf 'ERROR: unknown command: %s\n' "$1"
      usage; exit 1
      ;;
  esac
}

main "$@"
