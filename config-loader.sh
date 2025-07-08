#!/bin/bash
# Configuration loader for workflow library
# Loads project-specific configuration from .workflow/config.json

set -euo pipefail

# Default configuration file path
CONFIG_FILE="${WORKFLOW_CONFIG_FILE:-.workflow/config.json}"

# Colors for output
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }

# Load configuration value
# Usage: get_config "path.to.value" "default_value"
get_config() {
    local path="$1"
    local default="${2:-}"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        if [[ -n "$default" ]]; then
            echo "$default"
            return 0
        else
            print_error "Configuration file not found: $CONFIG_FILE"
            return 1
        fi
    fi
    
    # Use jq to extract configuration value
    if command -v jq >/dev/null 2>&1; then
        local value
        value=$(jq -r ".$path // empty" "$CONFIG_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
        elif [[ -n "$default" ]]; then
            echo "$default"
        else
            print_error "Configuration value not found: $path"
            return 1
        fi
    else
        print_warning "jq not installed, using default values"
        if [[ -n "$default" ]]; then
            echo "$default"
        else
            return 1
        fi
    fi
}

# Get boolean configuration value
# Usage: get_config_bool "path.to.bool" "true"
get_config_bool() {
    local path="$1"
    local default="${2:-false}"
    local value
    
    value=$(get_config "$path" "$default")
    
    case "$value" in
        true|1|yes|on) echo "true" ;;
        false|0|no|off) echo "false" ;;
        *) echo "$default" ;;
    esac
}

# Get numeric configuration value
# Usage: get_config_number "path.to.number" "30"
get_config_number() {
    local path="$1"
    local default="${2:-0}"
    local value
    
    value=$(get_config "$path" "$default")
    
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Load all ADHD-related configuration
load_adhd_config() {
    export ADHD_BREAKS_ENABLED=$(get_config_bool "adhd.breakReminders.enabled" "true")
    export ADHD_BREAK_INTERVAL=$(get_config_number "adhd.breakReminders.intervalMinutes" "25")
    export ADHD_ENFORCE_BREAKS=$(get_config_bool "adhd.breakReminders.enforceBreaks" "true")
    export ADHD_SKIP_ON_HYPERFOCUS=$(get_config_bool "adhd.breakReminders.skipOnHyperfocus" "true")
    export ADHD_TDD_ENABLED=$(get_config_bool "adhd.tddEnforcement.enabled" "true")
    export ADHD_REQUIRE_RED_GREEN=$(get_config_bool "adhd.tddEnforcement.requireRedGreenRefactor" "true")
    export ADHD_ALLOW_SKIP_DOCS=$(get_config_bool "adhd.tddEnforcement.allowSkipForDocs" "true")
    export ADHD_PROGRESS_TRACKING=$(get_config_bool "adhd.progressTracking.enabled" "true")
    export ADHD_SHOW_STATS=$(get_config_bool "adhd.progressTracking.showCycleStats" "true")
    export ADHD_MOTIVATIONAL=$(get_config_bool "adhd.progressTracking.motivationalMessages" "true")
}

# Load git configuration
load_git_config() {
    export GIT_DEFAULT_BRANCH=$(get_config "git.defaultBranch" "main")
    export GIT_DEV_BRANCH=$(get_config "git.developmentBranch" "dev")
    export GIT_ALLOW_FEATURE_BRANCHES=$(get_config_bool "git.allowFeatureBranches" "false")
    export GIT_ENFORCE_CONVENTIONAL=$(get_config_bool "git.enforceConventionalCommits" "true")
    export GIT_REQUIRE_SAFE_COMMIT=$(get_config_bool "git.requireSafeCommit" "true")
    export GIT_AUTO_COMMIT_COVERAGE=$(get_config_bool "git.autoCommitOnCoverage" "true")
    export GIT_MAX_COMMIT_LENGTH=$(get_config_number "git.maxCommitMessageLength" "72")
}

# Load quality configuration
load_quality_config() {
    export QUALITY_MIN_BRANCH_COVERAGE=$(get_config_number "quality.testCoverage.minimumBranch" "95")
    export QUALITY_MIN_LINE_COVERAGE=$(get_config_number "quality.testCoverage.minimumLine" "90")
    export QUALITY_FAIL_BELOW_MIN=$(get_config_bool "quality.testCoverage.failBelowMinimum" "true")
    export QUALITY_MUTATION_ENABLED=$(get_config_bool "quality.mutationTesting.enabled" "true")
    export QUALITY_MIN_MUTATION_KILL=$(get_config_number "quality.mutationTesting.minimumKillRate" "85")
    export QUALITY_MUTATION_FAIL_BELOW=$(get_config_bool "quality.mutationTesting.failBelowMinimum" "true")
    export QUALITY_CODE_ANALYSIS=$(get_config_bool "quality.codeAnalysis.enabled" "true")
    export QUALITY_MAX_ISSUES=$(get_config_number "quality.codeAnalysis.maxIssues" "10")
    export QUALITY_ENFORCE_FORMAT=$(get_config_bool "quality.formatting.enforceOnCommit" "true")
}

# Load privacy configuration
load_privacy_config() {
    export PRIVACY_PII_DETECTION=$(get_config_bool "privacy.piiDetection.enabled" "true")
    export PRIVACY_SCAN_COMMITS=$(get_config_bool "privacy.piiDetection.scanCommits" "true")
    export PRIVACY_SCAN_CODE=$(get_config_bool "privacy.piiDetection.scanCode" "true")
    export PRIVACY_BLOCK_ON_PII=$(get_config_bool "privacy.piiDetection.blockOnDetection" "true")
}

# Load CI configuration
load_ci_config() {
    export CI_LOCAL_FIRST=$(get_config_bool "ci.localFirst" "true")
    export CI_RUN_BEFORE_COMMIT=$(get_config_bool "ci.runBeforeCommit" "true")
    export CI_TIMEOUT_SECONDS=$(get_config_number "ci.timeoutSeconds" "30")
    export CI_FREE_TIER_OPTIMIZED=$(get_config_bool "ci.freeTierOptimized" "true")
    export CI_CACHE_RESULTS=$(get_config_bool "ci.cacheResults" "true")
}

# Load notification preferences
load_notification_config() {
    export NOTIF_EMOJI=$(get_config_bool "notifications.emoji" "true")
    export NOTIF_COLORS=$(get_config_bool "notifications.colors" "true")
    export NOTIF_SOUND=$(get_config_bool "notifications.sound" "false")
    export NOTIF_DESKTOP=$(get_config_bool "notifications.desktop" "false")
}

# Load custom commands
load_custom_commands() {
    export CUSTOM_TEST_CMD=$(get_config "customCommands.test" "dotnet test")
    export CUSTOM_BUILD_CMD=$(get_config "customCommands.build" "dotnet build")
    export CUSTOM_FORMAT_CMD=$(get_config "customCommands.format" "dotnet format")
    export CUSTOM_LINT_CMD=$(get_config "customCommands.lint" "dotnet format --verify-no-changes")
    export CUSTOM_COVERAGE_CMD=$(get_config "customCommands.coverage" "dotnet test --collect:\"XPlat Code Coverage\"")
    export CUSTOM_LOCAL_CI_CMD=$(get_config "customCommands.localCi" "./scripts/local-ci.sh")
    export CUSTOM_QUALITY_CMD=$(get_config "customCommands.qualityCheck" "./scripts/pr-quality-check.sh")
}

# Load all configuration
load_all_config() {
    print_info "Loading workflow configuration from $CONFIG_FILE"
    
    load_adhd_config
    load_git_config
    load_quality_config
    load_privacy_config
    load_ci_config
    load_notification_config
    load_custom_commands
    
    # Project info
    export PROJECT_NAME=$(get_config "project.name" "Unknown")
    export PROJECT_TYPE=$(get_config "project.type" "generic")
    
    print_success "Configuration loaded for project: $PROJECT_NAME"
}

# Validate configuration file
validate_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        print_info "Creating default configuration..."
        create_default_config
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        print_warning "jq not installed - configuration validation limited"
        return 0
    fi
    
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        print_error "Invalid JSON in configuration file: $CONFIG_FILE"
        return 1
    fi
    
    print_success "Configuration file is valid"
    return 0
}

# Create default configuration
create_default_config() {
    local project_name
    project_name=$(basename "$(pwd)")
    
    cat > "$CONFIG_FILE" << 'EOF'
{
  "project": {
    "name": "PROJECT_NAME_PLACEHOLDER",
    "type": "generic",
    "language": "unknown"
  },
  "git": {
    "defaultBranch": "main",
    "developmentBranch": "dev",
    "requireSafeCommit": true
  },
  "adhd": {
    "breakReminders": {
      "enabled": true,
      "intervalMinutes": 25
    },
    "tddEnforcement": {
      "enabled": true,
      "requireRedGreenRefactor": true
    }
  },
  "quality": {
    "testCoverage": {
      "minimumBranch": 80
    }
  },
  "features": {
    "tddCycleEnforcement": true,
    "adhdBreakSystem": true,
    "privacyGuards": true
  }
}
EOF
    
    # Replace placeholder with actual project name
    if command -v sed >/dev/null 2>&1; then
        sed -i "s/PROJECT_NAME_PLACEHOLDER/$project_name/g" "$CONFIG_FILE"
    fi
    
    print_success "Created default configuration: $CONFIG_FILE"
}

# Show current configuration
show_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    print_info "Current Configuration ($CONFIG_FILE):"
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        jq '.' "$CONFIG_FILE"
    else
        cat "$CONFIG_FILE"
    fi
}

# Main function - only run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-load}" in
        "load"|"")
            load_all_config
            ;;
        "validate")
            validate_config
            ;;
        "show")
            show_config
            ;;
        "create-default")
            create_default_config
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  load (default)    Load all configuration"
            echo "  validate          Validate configuration file"
            echo "  show             Show current configuration"
            echo "  create-default    Create default configuration"
            echo "  help             Show this help"
            ;;
        *)
            print_error "Unknown command: $1"
            exit 1
            ;;
    esac
fi