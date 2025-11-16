#!/usr/bin/env bash

# speckit.analyze - Cross-artifact consistency and quality analysis
#
# This script performs read-only analysis across spec.md, plan.md, and tasks.md
# to identify inconsistencies, ambiguities, and underspecified items before implementation.
#
# Usage: speckit-analyze.sh [OPTIONS]
#
# OPTIONS:
#   --help, -h          Show help message
#   --verbose, -v       Show detailed analysis information
#
# Output: Markdown analysis report printed to stdout

set -e

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse command line arguments
VERBOSE=false

for arg in "$@"; do
    case "$arg" in
        --verbose|-v)
            VERBOSE=true
            ;;
        --help|-h)
            cat << 'EOF'
speckit.analyze - Cross-artifact consistency and quality analysis

Performs read-only analysis across spec.md, plan.md, and tasks.md to identify
inconsistencies, ambiguities, and underspecified items before implementation.

USAGE:
    speckit-analyze.sh [OPTIONS]

OPTIONS:
    --verbose, -v       Show detailed analysis information
    --help, -h          Show this help message

OUTPUT:
    Markdown analysis report printed to stdout

EXAMPLES:
    speckit-analyze.sh                           # Standard analysis
    speckit-analyze.sh --verbose                 # Detailed output

EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Initialize analysis context
init_analysis_context() {
    echo "## Specification Analysis Report" >&2
    echo "" >&2

    # Run prerequisites check
    if $VERBOSE; then
        echo "🔍 Running prerequisite checks..." >&2
    fi

    # Use JSON mode forPrerequisites script
    local prereq_output
    prereq_output=$(bash "$SCRIPT_DIR/check-prerequisites.sh" --json --require-tasks --include-tasks 2>/dev/null || {
        echo "ERROR: Prerequisites check failed:" >&2
        bash "$SCRIPT_DIR/check-prerequisites.sh" --json --require-tasks --include-tasks >&2
        exit 1
    })

    # Parse JSON output
    FEATURE_DIR=$(echo "$prereq_output" | jq -r '.FEATURE_DIR // empty')
    if [[ -z "$FEATURE_DIR" ]]; then
        echo "ERROR: Could not determine FEATURE_DIR from prerequisites" >&2
        exit 1
    fi

    SPEC_FILE="$FEATURE_DIR/spec.md"
    PLAN_FILE="$FEATURE_DIR/plan.md"
    TASKS_FILE="$FEATURE_DIR/tasks.md"
    CONSTITUTION_FILE="$SCRIPT_DIR/../../memory/constitution.md"

    # Validate required files exist
    if [[ ! -f "$SPEC_FILE" ]]; then
        echo "ERROR: spec.md not found at $SPEC_FILE" >&2
        echo "Run /speckit.specify first to create the specification." >&2
        exit 1
    fi

    if [[ ! -f "$PLAN_FILE" ]]; then
        echo "ERROR: plan.md not found at $PLAN_FILE" >&2
        echo "Run /speckit.plan first to create the implementation plan." >&2
        exit 1
    fi

    if [[ ! -f "$TASKS_FILE" ]]; then
        echo "ERROR: tasks.md not found at $TASKS_FILE" >&2
        echo "Run /speckit.tasks first to create the task list." >&2
        exit 1
    fi

    if [[ ! -f "$CONSTITUTION_FILE" ]]; then
        echo "ERROR: constitution.md not found at $CONSTITUTION_FILE" >&2
        exit 1
    fi

    if $VERBOSE; then
        echo "📂 Using:" >&2
        echo "   SPEC: $SPEC_FILE" >&2
        echo "   PLAN: $PLAN_FILE" >&2
        echo "   TASKS: $TASKS_FILE" >&2
        echo "   CONSTITUTION: $CONSTITUTION_FILE" >&2
        echo "" >&2
    fi
}

# Load and analyze artifacts
load_artifacts() {
    # Load core text content (minimal for analysis)
    SPEC_CONTENT=$(cat "$SPEC_FILE")
    PLAN_CONTENT=$(cat "$PLAN_FILE")
    TASKS_CONTENT=$(cat "$TASKS_FILE")
    CONSTITUTION_CONTENT=$(cat "$CONSTITUTION_FILE")
}

# Build semantic models for analysis
build_semantic_models() {
    if $VERBOSE; then
        echo "🔧 Building semantic models..." >&2
    fi

    # Extract requirements inventory from spec.md
    REQUIREMENTS=()
    while IFS= read -r line; do
        if [[ "$line" =~ -\ \*\*[A-Z][A-Z]-[0-9]+\*\* ]]; then
            # Extract requirement ID and description
            req_id=$(echo "$line" | sed 's/.*\*\*\([A-Z][A-Z]-[0-9]*\)\*\*.*/\1/')
            req_text=$(echo "$line" | sed 's/.*\*\*[A-Z][A-Z]-[0-9]*\*\*\s*:\s*//')
            if [[ -n "$req_text" ]]; then
                REQUIREMENTS+=("$req_id:$req_text")
            fi
        fi
    done <<< "$SPEC_CONTENT"

    # Extract user stories from spec.md
    USER_STORIES=()
    local in_story=false
    local current_story=""
    local story_content=""

    while IFS= read -r line; do
        # Find User Story sections
        if [[ "$line" =~ ^\#\#\#\ User\ Story\ ([0-9]+)\ - ]]; then
            if [[ -n "$current_story" ]]; then
                USER_STORIES+=("$current_story:$story_content")
            fi
            current_story="${BASH_REMATCH[1]}"
            story_content=""
            in_story=true
        elif [[ "$in_story" =~ true ]] && [[ "$line" =~ ^\#\#\#\  ]]; then
            # End of current story
            if [[ -n "$current_story" ]]; then
                USER_STORIES+=("$current_story:$story_content")
            fi
            in_story=false
        elif [[ "$in_story" = true ]]; then
            # Accumulate story content
            if [[ -n "$story_content" ]]; then
                story_content="$story_content"$'\n'"$line"
            else
                story_content="$line"
            fi
        fi
    done <<< "$SPEC_CONTENT"

    if [[ -n "$current_story" ]]; then
        USER_STORIES+=("$current_story:$story_content")
    fi

    # Extract tasks mapping from tasks.md
    TASKS_MAPPING=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^-\ \[.\]\ ([A-Z]{3}[0-9]+)\  ]]; then
            task_id="${BASH_REMATCH[1]}"
            task_desc=$(echo "$line" | sed 's/^- \[.\]\ [A-Z]\{3\}[0-9]\+\ \[[^]]*\]\? *\[US[0-9]\+\]\? *//')
            TASKS_MAPPING+=("$task_id:$task_desc")
        elif [[ "$line" =~ ^-\ \[.\]\ ([A-Z]{3}[0-9]+)\  ]]; then
            # Tasks without story marker
            task_id="${BASH_REMATCH[1]}"
            task_desc=$(echo "$line" | sed 's/^- \[.\]\ [A-Z]\{3\}[0-9]\+\ \[[^]]*\]\? *//')
            TASKS_MAPPING+=("$task_id:$task_desc")
        fi
    done <<< "$TASKS_CONTENT"

    # Extract constitution principles
    CONSTITUTION_PRINCIPLES=()
    local principle_text=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^\#\#\#\ ([IVX]+\.\ ) ]]; then
            if [[ -n "$principle_text" ]]; then
                CONSTITUTION_PRINCIPLES+=("$principle_text")
            fi
            # Start new principle
            principle_text="$line"
        elif [[ -n "$principle_text" ]]; then
            # Continue accumulating principle
            principle_text="$principle_text"$'\n'"$line"
        fi
    done <<< "$CONSTITUTION_CONTENT"

    if [[ -n "$principle_text" ]]; then
        CONSTITUTION_PRINCIPLES+=("$principle_text")
    fi

    if $VERBOSE; then
        echo "   Found ${#REQUIREMENTS[@]} requirements" >&2
        echo "   Found ${#USER_STORIES[@]} user stories" >&2
        echo "   Found ${#TASKS_MAPPING[@]} tasks" >&2
        echo "   Loaded ${#CONSTITUTION_PRINCIPLES[@]} constitution principles" >&2
        echo "" >&2
    fi
}

# Detect duplication issues
detect_duplications() {
    local findings=()

    if $VERBOSE; then
        echo "🔍 Detecting duplications..." >&2
    fi

    # Check for duplicate requirement descriptions
    local req_texts=()
    local duplicates=()

    for req_entry in "${REQUIREMENTS[@]}"; do
        local req_text="${req_entry#*:}"
        for existing in "${req_texts[@]}"; do
            # Simple fuzzy match - check if requirements are very similar
            if [[ "${req_text,,}" = "${existing,,}" ]] || [[ "${existing,,}" = *"${req_text,,}"* ]] || [[ "${req_text,,}" = *"${existing,,}"* ]]; then
                if [[ " ${duplicates[*]} " != *" $req_text "* ]]; then
                    duplicates+=("$req_text")
                fi
            fi
        done
        req_texts+=("$req_text")
    done

    for duplicate in "${duplicates[@]}"; do
        findings+=("Duplication|HIGH|spec.md|Near-duplicate requirement: $duplicate|Consider consolidating to reduce complexity")
    done

    echo "${findings[@]}"
}

# Detect ambiguity issues
detect_ambiguities() {
    local findings=()

    if $VERBOSE; then
        echo "🔍 Detecting ambiguities..." >&2
    fi

    local vague_terms=("fast" "quick" "intuitive" "user-friendly" "robust" "scalable" "secure" "reliable" "performant" "efficient" "not bad" "okay" "decent")

    # Check requirements for vague terms
    for req_entry in "${REQUIREMENTS[@]}"; do
        local req_id="${req_entry%%:*}"
        local req_text="${req_entry#*:}"

        for vague_term in "${vague_terms[@]}"; do
            if [[ "${req_text,,}" = *"$vague_term"* ]] && [[ ! "${req_text,,}" = *"with specific "* ]]; then
                findings+=("Ambiguity|HIGH|spec.md|$req_id uses vague term '$vague_term'|$req_id lacks measurable criteria")
                break
            fi
        done
    done

    # Check for unresolved placeholders
    local placeholders=("TODO" "TKTK" "???" "<placeholder>" "[NEEDS CLARIFICATION]" "XXX")
    for content_source in "SPEC:$SPEC_CONTENT" "PLAN:$PLAN_CONTENT" "TASKS:$TASKS_CONTENT"; do
        local source_name="${content_source%%:*}"
        local source_content="${content_source#*:}"

        for placeholder in "${placeholders[@]}"; do
            if [[ "$source_content" = *"$placeholder"* ]]; then
                findings+=("Ambiguity|CRITICAL|$source_name.md|Contains '$placeholder' placeholder|Replace with concrete implementation details")
            fi
        done
    done

    echo "${findings[@]}"
}

# Detect underspecification issues
detect_underspecification() {
    local findings=()

    if $VERBOSE; then
        echo "🔍 Detecting underspecification..." >&2
    fi

    # Check requirements for incomplete verbs (verbs without objects)
    for req_entry in "${REQUIREMENTS[@]}"; do
        local req_id="${req_entry%%:*}"
        local req_text="${req_entry#*:}"

        # Check for lone verbs like "MUST be" or "MUST handle"
        if [[ "$req_text" =~ MUST\ (be|handle|support|provide|display|store|calculate|allow|enable|include)[^a-zA-Z0-9_] ]]; then
            findings+=("Underspecification|MEDIUM|spec.md|$req_id incomplete: lacks specific object|Specify what should be/be have/be supported")
        fi
    done

    # Check user stories missing acceptance criteria
    for story_entry in "${USER_STORIES[@]}"; do
        local story_id="${story_entry%%:*}"
        local story_content="${story_entry#*:}"

        if [[ ! "$story_content" = *"Acceptance Scenarios"* ]]; then
            findings+=("Underspecification|HIGH|spec.md|User Story $story_id missing acceptance scenarios|Add measurable test scenarios")
        fi
    done

    # Check tasks referencing undefined components
    for task_entry in "${TASKS_MAPPING[@]}"; do
        local task_id="${task_entry%%:*}"
        local task_desc="${task_entry#*:}"

        # Extract file paths from task descriptions
        if [[ "$task_desc" =~ in\ ([A-Z][^/]*\.swift|[a-z]+/[A-Z][^/]*\.swift) ]]; then
            local file_ref="${BASH_REMATCH[1]}"
            # If the file path doesn't match known patterns, flag it
            if [[ ! "$file_ref" =~ ^MIGASK/Core/Models/ ]] &&
               [[ ! "$file_ref" =~ ^MIGASK/Core/Services/ ]] &&
               [[ ! "$file_ref" =~ ^MIGASK/Core/Utilities/ ]] &&
               [[ ! "$file_ref" =~ ^MIGASK/Features/ ]] &&
               [[ ! "$file_ref" =~ ^MIGASK/App/ ]]; then
                findings+=("Underspecification|MEDIUM|tasks.md|Task $task_id references unknown component path '$file_ref'|Verify component location or add to spec")
            fi
        fi
    done

    echo "${findings[@]}"
}

# Check constitution alignment
check_constitution_alignment() {
    local findings=()

    if $VERBOSE; then
        echo "⚖️ Checking constitution alignment..." >&2
    fi

    # Principle I: Mindful by Design
    if [[ "$SPEC_CONTENT $PLAN_CONTENT" = *"punitive"* ]] ||
       [[ "$SPEC_CONTENT $PLAN_CONTENT" = *"restrict"* ]] ||
       [[ "$SPEC_CONTENT $PLAN_CONTENT" = *"block"* ]]; then
        findings+=("Constitution Violation|CRITICAL|spec.md/plan.md|Uses punitive language conflicting with Mindful by Design|Replace with empowering language")
    fi

    # Principle II: Privacy-First Architecture
    if [[ "$PLAN_CONTENT" = *"remote"* ]] && [[ ! "$PLAN_CONTENT" = *"local-only"* ]]; then
        findings+=("Constitution Violation|CRITICAL|plan.md|Data storage not confirmed local-only|AFFIRM: All user data stored locally only")
    fi

    # Principle IV: Performance Standards
    if [[ ! "$PLAN_CONTENT $SPEC_CONTENT" = *"main screen load time"* ]]; then
        findings+=("Constitution Violation|HIGH|plan.md|< 1 second load time requirement not documented|Add performance target specification")
    fi

    # Principle V: Offline-First Design
    if [[ ! "$PLAN_CONTENT" = *"offline"* ]] && [[ ! "$PLAN_CONTENT" = *"pre-bundled"* ]]; then
        findings+=("Constitution Violation|HIGH|plan.md|Offline capability not documented|Specify pre-bundled content strategy")
    fi

    # Principle VII: Intentional Friction
    if [[ ! "$SPEC_CONTENT" = *"configurable 15-45"* ]]; then
        findings+=("Constitution Violation|CRITICAL|spec.md|Configurable 15-45s timer not specified|REQUIREMENT: Timer must be 15-45s configurable")
    fi

    echo "${findings[@]}"
}

# Detect coverage gaps
detect_coverage_gaps() {
    local findings=()

    if $VERBOSE; then
        echo "🔍 Detecting coverage gaps..." >&2
    fi

    local mapped_tasks_count=0
    local task_count=${#TASKS_MAPPING[@]}

    # Count requirements with at least one task
    local requirements_with_tasks=()

    for req_entry in "${REQUIREMENTS[@]}"; do
        local req_text="${req_entry#*:}"
        local found_task=false

        for task_entry in "${TASKS_MAPPING[@]}"; do
            local task_desc="${task_entry#*:}"
            if [[ "${task_desc,,}" = *"${req_text,,}"* ]] ||
               [[ "${task_desc,,}" =~ ${req_text,,} ]] ||
               [[ "${req_text,,}" = *"${task_desc,,}"* ]]; then
                found_task=true
                ((mapped_tasks_count++))
                if [[ ! " ${requirements_with_tasks[*]} " = *" $req_entry "* ]]; then
                    requirements_with_tasks+=("$req_entry")
                fi
                break
            fi
        done

        if [[ "$found_task" != true ]]; then
            findings+=("Coverage Gap|HIGH|spec.md|${req_entry%%:*} has zero associated tasks|Add tasks covering this requirement")
        fi
    done

    # Check for tasks without requirement mapping
    for task_entry in "${TASKS_MAPPING[@]}"; do
        local task_id="${task_entry%%:*}"
        local found_mapping=false

        for req_entry in "${REQUIREMENTS[@]}"; do
            local req_text="${req_entry#*:}"
            local task_desc="${task_entry#*:}"
            if [[ "${task_desc,,}" = *"${req_text,,}"* ]] ||
               [[ "${task_desc,,}" =~ ${req_text,,} ]] ||
               [[ "${req_text,,}" = *"${task_desc,,}"* ]]; then
                found_mapping=true
                break
            fi
        done

        if [[ "$found_mapping" != true ]]; then
            # This is a setup task - that's expected
            if [[ "$task_id" =~ ^T[0-2][0-9]$ ]] || [[ "$task_desc" = *"project structure"* ]]; then
                continue
            fi
            findings+=("Coverage Gap|MEDIUM|tasks.md|Task $task_id not mapped to any spec requirement|Verify this task implements documented requirements")
        fi
    done

    echo "${findings[@]}"
}

# Detect consistency issues
detect_inconsistencies() {
    local findings=()

    if $VERBOSE; then
        echo "🔍 Detecting inconsistencies..." >&2
    fi

    # Check for conflicting data model concepts
    local data_entities=("UsageEvent" "Streak" "SelectedApp" "MindfulnessContent" "UserProfile")
    local plan_data=$(echo "$PLAN_CONTENT" | grep -i -A5 -B5 "data model\|entity\|table")
    local spec_data=$(echo "$SPEC_CONTENT" | grep -i -A5 -B5 "entity")

    for entity in "${data_entities[@]}"; do
        if [[ "$spec_data" = *"$entity"* ]] && [[ "$plan_data" != *"$entity"* ]]; then
            findings+=("Inconsistency|MEDIUM|spec.md|Uses entity $entity not defined in plan|Add to plan data model or consolidate terminology")
        elif [[ "$plan_data" = *"$entity"* ]] && [[ "$spec_data" != *"$entity"* ]]; then
            findings+=("Inconsistency|MEDIUM|plan.md|References $entity not defined in spec|Add to spec or remove from plan")
        fi
    done

    # Check for conflicting terminology
    local key_terms=("Gateway Screen" "First Run Experience" "MIGA Hub")
    local term_variants=()

    for term in "${key_terms[@]}"; do
        local lower_term=$(echo "$term" | tr '[:upper:]' '[:lower:]')
        local variants=()

        # Find all appearances of similar terms across documents
        local spec_term=$(echo "$SPEC_CONTENT" | grep -oi "$term\|${term/ /}\|<[^>]*${lower_term}[^>]*>" | sort | uniq)
        local plan_term=$(echo "$PLAN_CONTENT" | grep -oi "$term\|${term/ /}\|<[^>]*${lower_term}[^>]*>" | sort | uniq)

        if [[ -n "$spec_term" ]] && [[ -n "$plan_term" ]] && [[ "$spec_term" != "$plan_term" ]]; then
            findings+=("Inconsistency|MEDIUM|spec.md/plan.md|Terminology drift: $term used differently|Use consistent canonical term")
        fi
    done

    echo "${findings[@]}"
}

# Generate the analysis report
generate_report() {
    local all_findings=()

    # Run all detection passes
    local duplications
    local ambiguities
    local underspec
    local constitution
    local coverage_gaps
    local inconsistencies

    duplications=$(detect_duplications)
    ambiguities=$(detect_ambiguities)
    underspec=$(detect_underspecification)
    constitution=$(check_constitution_alignment)
    coverage_gaps=$(detect_coverage_gaps)
    inconsistencies=$(detect_inconsistencies)

    # Combine all findings
    IFS=$'\n'
    for finding in $duplications $ambiguities $underspec $constitution $coverage_gaps $inconsistencies; do
        IFS='|' read -ra parts <<< "$finding"
        if [[ ${#parts[@]} -eq 5 ]]; then
            all_findings+=("$finding")
        fi
    done
    unset IFS

    # Generate coverage summary table
    local total_req=${#REQUIREMENTS[@]}
    local unique_mapped=()
    for req_entry in "${REQUIREMENTS[@]}"; do
        local req_text="${req_entry#*:}"
        for task_entry in "${TASKS_MAPPING[@]}"; do
            local task_desc="${task_entry#*:}"
            if [[ "${task_desc,,}" = *"${req_text,,}"* ]] ||
               [[ "${req_text,,}" = *"${task_desc,,}"* ]]; then
                if [[ ! " ${unique_mapped[*]} " = *" $req_entry "* ]]; then
                    unique_mapped+=("$req_entry")
                    break
                fi
            fi
        done
    done

    local coverage_pct=$(( total_req > 0 ? (${#unique_mapped[@]} * 100) / total_req : 0 ))
    local total_tasks=${#TASKS_MAPPING[@]}

    # Count issues by type
    local crit_count=0 med_count=0 high_count=0 low_count=0
    local amb_count=0 dup_count=0

    for finding in "${all_findings[@]}"; do
        IFS='|' read -ra parts <<< "$finding"
        case "${parts[1]}" in
            "CRITICAL") ((crit_count++)) ;;
            "HIGH") ((high_count++)) ;;
            "MEDIUM") ((med_count++)) ;;
            "LOW") ((low_count++)) ;;
        esac
        case "${parts[0]}" in
            "Ambiguity") ((amb_count++)) ;;
            "Duplication") ((dup_count++)) ;;
        esac
    done

    if $VERBOSE; then
        echo "📊 Generating report..." >&2
        echo "   Total findings: ${#all_findings[@]}" >&2
        echo "   Coverage: $coverage_pct% ($total_req requirements)" >&2
    fi

    # Output the report

    # Findings table
    if [[ ${#all_findings[@]} -gt 0 ]]; then
        echo "| ID | Category | Severity | Location(s) | Summary | Recommendation |"
        echo "|----|----------|----------|-------------|---------|----------------|"
        local finding_id=1
        for finding in "${all_findings[@]}"; do
            IFS='|' read -ra parts <<< "$finding"
            printf "| %s%d | %s | %s | %s | %s | %s |\n" \
                "${parts[0]:0:1}" "$finding_id" "${parts[0]}" "${parts[1]}" "${parts[2]}" "${parts[3]}" "${parts[4]}"
            ((finding_id++))
        done
    fi

    # Coverage Summary Table
    echo ""
    echo "**Coverage Summary Table:**"
    echo ""
    echo "| Requirement Key | Has Task? | Task IDs | Notes |"
    echo "|-----------------|-----------|----------|-------|"
    for req_entry in "${REQUIREMENTS[@]}"; do
        local req_key="${req_entry%%:*}"
        local has_task="No"
        local task_ids=""
        local notes=""

        # Check if requirement has associated tasks
        for task_entry in "${TASKS_MAPPING[@]}"; do
            local task_id="${task_entry%%:*}"
            local task_desc="${task_entry#*:}"
            local req_text="${req_entry#*:}"

            if [[ "${task_desc,,}" = *"${req_text,,}"* ]] ||
               [[ "${req_text,,}" = *"${task_desc,,}"* ]]; then
                has_task="Yes"
                if [[ -z "$task_ids" ]]; then
                    task_ids="$task_id"
                else
                    task_ids="$task_ids, $task_id"
                fi
            fi
        done

        if [[ "$has_task" = "No" ]]; then
            notes="Missing task coverage"
        fi

        echo "| $req_key | $has_task | $task_ids | $notes |"
    done

    # Constitution Alignment Issues
    echo ""
    echo "**Constitution Alignment Issues:** (if any)"
    echo ""

    local const_issues=0
    for finding in "${all_findings[@]}"; do
        IFS='|' read -ra parts <<< "$finding"
        if [[ "${parts[0]}" = "Constitution Violation" ]]; then
            echo "- **${parts[1]}**: ${parts[3]} (${parts[2]})"
            ((const_issues++))
        fi
    done

    if [[ $const_issues -eq 0 ]]; then
        echo "(No constitution violations detected)"
    fi

    # Unmapped Tasks
    echo ""
    echo "**Unmapped Tasks:** (if any)"
    echo ""

    local unmapped_tasks=()
    for task_entry in "${TASKS_MAPPING[@]}"; do
        local task_id="${task_entry%%:*}"
        local task_desc="${task_entry#*:}"
        local has_mapping=false

        # Skip setup tasks
        if [[ "$task_id" =~ ^T[0-2][0-9]$ ]] || [[ "$task_desc" = *"project structure"* ]]; then
            continue
        fi

        for req_entry in "${REQUIREMENTS[@]}"; do
            local req_text="${req_entry#*:}"
            if [[ "${task_desc,,}" = *"${req_text,,}"* ]] ||
               [[ "${req_text,,}" = *"${task_desc,,}"* ]]; then
                has_mapping=true
                break
            fi
        done

        if [[ "$has_mapping" != true ]]; then
            unmapped_tasks+=("$task_id: $task_desc")
        fi
    done

    if [[ ${#unmapped_tasks[@]} -eq 0 ]]; then
        echo "(All tasks aligned with spec requirements)"
    else
        for task in "${unmapped_tasks[@]}"; do
            echo "- $task"
        done
    fi

    # Metrics
    echo ""
    echo "**Metrics:**"
    echo ""
    echo "- Total Requirements: $total_req"
    echo "- Total Tasks: $total_tasks"
    echo "- Coverage %: ${coverage_pct}%"
    echo "- Ambiguity Count: $amb_count"
    echo "- Duplication Count: $dup_count"
    echo "- Critical Issues Count: $crit_count"

    # Next Actions
    echo ""
    echo "## Next Actions"
    echo ""

    if [[ $crit_count -gt 0 ]]; then
        echo "- **🚨 CRITICAL issues detected** - Resolve before proceeding to implementation"
        echo "  - Fix constitution violations to ensure project compliance"
        if [[ $amb_count -gt 0 ]]; then
            echo "  - Resolve ambiguities with clarification updates"
        fi
    elif [[ $high_count -gt 0 ]] || [[ $coverage_pct -lt 80 ]]; then
        echo "- **⚠️ HIGH priority issues detected** - Consider resolving before implementation"
        if [[ $coverage_pct -lt 80 ]]; then
            echo "  - Improve requirement-task coverage (currently ${coverage_pct}%)"
        fi
        echo "  - Review high-priority findings for implementation impact"
    else
        echo "- Requirements quality acceptable for implementation"
        if [[ $med_count -gt 0 ]] || [[ $low_count -gt 0 ]]; then
            echo "  - Optional: Address medium/low priority items for improved clarity"
        fi
    fi

    echo ""
    if [[ $crit_count -gt 0 ]]; then
        echo "**Recommended:** Fix critical issues before `/speckit.implement`"
    elif [[ $high_count -gt 0 ]]; then
        echo "**Recommended:** Review high-priority issues before `/speckit.implement`"
    else
        echo "**Ready:** Proceed to `/speckit.implement` when ready"
    fi

    if $VERBOSE; then
        echo "" >&2
        echo "✅ Analysis complete with ${#all_findings[@]} findings" >&2
    fi
}

# Main execution
init_analysis_context
load_artifacts
build_semantic_models
generate_report
