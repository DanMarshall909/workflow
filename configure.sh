#!/bin/bash
# Workflow Configuration Manager
# Interactive configuration tool for project-specific settings

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() { echo -e "${CYAN}🔧 $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Load configuration loader
source "$SCRIPT_DIR/config-loader.sh"

show_main_menu() {
    clear
    print_header "Workflow Library Configuration"
    echo ""
    print_info "Project: $(get_config "project.name" "Unknown")"
    print_info "Type: $(get_config "project.type" "Unknown")"
    echo ""
    echo "Configuration Options:"
    echo "  1. ADHD Support Settings"
    echo "  2. Git Workflow Rules"
    echo "  3. Quality Standards"
    echo "  4. Privacy Controls"
    echo "  5. CI/Local Development"
    echo "  6. Notification Preferences"
    echo "  7. Custom Commands"
    echo "  8. Project Information"
    echo ""
    echo "  s. Show current configuration"
    echo "  v. Validate configuration"
    echo "  r. Reset to defaults"
    echo "  q. Quit"
    echo ""
    echo -n "Select option: "
}

configure_adhd_settings() {
    clear
    print_header "ADHD Support Configuration"
    echo ""
    
    local current_enabled=$(get_config_bool "adhd.breakReminders.enabled")
    local current_interval=$(get_config_number "adhd.breakReminders.intervalMinutes")
    local current_enforce=$(get_config_bool "adhd.breakReminders.enforceBreaks")
    local current_tdd=$(get_config_bool "adhd.tddEnforcement.enabled")
    
    echo "Current ADHD Settings:"
    echo "  Break reminders: $current_enabled"
    echo "  Break interval: $current_interval minutes"
    echo "  Enforce breaks: $current_enforce"
    echo "  TDD enforcement: $current_tdd"
    echo ""
    
    echo "1. Toggle break reminders (currently: $current_enabled)"
    echo "2. Change break interval (currently: $current_interval min)"
    echo "3. Toggle break enforcement (currently: $current_enforce)"
    echo "4. Toggle TDD enforcement (currently: $current_tdd)"
    echo "5. Configure progress tracking"
    echo "b. Back to main menu"
    echo ""
    echo -n "Select option: "
    
    read -r choice
    case $choice in
        1) toggle_config "adhd.breakReminders.enabled" ;;
        2) set_number_config "adhd.breakReminders.intervalMinutes" "Break interval in minutes" ;;
        3) toggle_config "adhd.breakReminders.enforceBreaks" ;;
        4) toggle_config "adhd.tddEnforcement.enabled" ;;
        5) configure_progress_tracking ;;
        b) return ;;
        *) print_error "Invalid option"; sleep 1; configure_adhd_settings ;;
    esac
    
    configure_adhd_settings
}

configure_git_workflow() {
    clear
    print_header "Git Workflow Configuration"
    echo ""
    
    local current_dev_branch=$(get_config "git.developmentBranch")
    local current_safe_commit=$(get_config_bool "git.requireSafeCommit")
    local current_conventional=$(get_config_bool "git.enforceConventionalCommits")
    
    echo "Current Git Settings:"
    echo "  Development branch: $current_dev_branch"
    echo "  Require safe-commit: $current_safe_commit"
    echo "  Conventional commits: $current_conventional"
    echo ""
    
    echo "1. Change development branch (currently: $current_dev_branch)"
    echo "2. Toggle safe-commit requirement (currently: $current_safe_commit)"
    echo "3. Toggle conventional commits (currently: $current_conventional)"
    echo "4. Configure feature branch policy"
    echo "b. Back to main menu"
    echo ""
    echo -n "Select option: "
    
    read -r choice
    case $choice in
        1) set_string_config "git.developmentBranch" "Development branch name" ;;
        2) toggle_config "git.requireSafeCommit" ;;
        3) toggle_config "git.enforceConventionalCommits" ;;
        4) toggle_config "git.allowFeatureBranches" ;;
        b) return ;;
        *) print_error "Invalid option"; sleep 1; configure_git_workflow ;;
    esac
    
    configure_git_workflow
}

configure_quality_standards() {
    clear
    print_header "Quality Standards Configuration"
    echo ""
    
    local current_branch_cov=$(get_config_number "quality.testCoverage.minimumBranch")
    local current_mutation=$(get_config_number "quality.mutationTesting.minimumKillRate")
    local current_format=$(get_config_bool "quality.formatting.enforceOnCommit")
    
    echo "Current Quality Settings:"
    echo "  Minimum branch coverage: $current_branch_cov%"
    echo "  Minimum mutation kill rate: $current_mutation%"
    echo "  Enforce formatting: $current_format"
    echo ""
    
    echo "1. Set minimum branch coverage (currently: $current_branch_cov%)"
    echo "2. Set minimum mutation kill rate (currently: $current_mutation%)"
    echo "3. Toggle format enforcement (currently: $current_format)"
    echo "4. Configure code analysis"
    echo "b. Back to main menu"
    echo ""
    echo -n "Select option: "
    
    read -r choice
    case $choice in
        1) set_percentage_config "quality.testCoverage.minimumBranch" "Minimum branch coverage percentage" ;;
        2) set_percentage_config "quality.mutationTesting.minimumKillRate" "Minimum mutation kill rate percentage" ;;
        3) toggle_config "quality.formatting.enforceOnCommit" ;;
        4) configure_code_analysis ;;
        b) return ;;
        *) print_error "Invalid option"; sleep 1; configure_quality_standards ;;
    esac
    
    configure_quality_standards
}

toggle_config() {
    local path="$1"
    local current=$(get_config_bool "$path")
    local new_value
    
    if [[ "$current" == "true" ]]; then
        new_value="false"
    else
        new_value="true"
    fi
    
    update_config_value "$path" "$new_value"
    print_success "Updated $path to $new_value"
    sleep 1
}

set_string_config() {
    local path="$1"
    local prompt="$2"
    local current=$(get_config "$path")
    
    echo ""
    echo "Current value: $current"
    echo -n "$prompt: "
    read -r new_value
    
    if [[ -n "$new_value" ]]; then
        update_config_value "$path" "\"$new_value\""
        print_success "Updated $path to $new_value"
    else
        print_warning "No change made"
    fi
    sleep 1
}

set_number_config() {
    local path="$1"
    local prompt="$2"
    local current=$(get_config_number "$path")
    
    echo ""
    echo "Current value: $current"
    echo -n "$prompt: "
    read -r new_value
    
    if [[ "$new_value" =~ ^[0-9]+$ ]]; then
        update_config_value "$path" "$new_value"
        print_success "Updated $path to $new_value"
    else
        print_error "Invalid number: $new_value"
    fi
    sleep 1
}

set_percentage_config() {
    local path="$1"
    local prompt="$2"
    local current=$(get_config_number "$path")
    
    echo ""
    echo "Current value: $current%"
    echo -n "$prompt (0-100): "
    read -r new_value
    
    if [[ "$new_value" =~ ^[0-9]+$ ]] && [[ "$new_value" -ge 0 ]] && [[ "$new_value" -le 100 ]]; then
        update_config_value "$path" "$new_value"
        print_success "Updated $path to $new_value%"
    else
        print_error "Invalid percentage: $new_value (must be 0-100)"
    fi
    sleep 1
}

update_config_value() {
    local path="$1"
    local value="$2"
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".$path = $value" "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
    else
        print_error "jq not available - cannot update configuration"
        return 1
    fi
}

show_current_config() {
    clear
    print_header "Current Configuration"
    echo ""
    
    if [[ -f "$CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.' "$CONFIG_FILE"
    else
        print_error "Cannot display configuration (missing jq or config file)"
    fi
    
    echo ""
    echo "Press Enter to continue..."
    read -r
}

validate_current_config() {
    clear
    print_header "Configuration Validation"
    echo ""
    
    if validate_config; then
        print_success "Configuration is valid"
    else
        print_error "Configuration has issues"
    fi
    
    echo ""
    echo "Press Enter to continue..."
    read -r
}

reset_to_defaults() {
    clear
    print_header "Reset Configuration"
    echo ""
    print_warning "This will reset ALL configuration to defaults!"
    echo "Current configuration will be backed up."
    echo ""
    echo -n "Are you sure? (type 'yes' to confirm): "
    read -r confirm
    
    if [[ "$confirm" == "yes" ]]; then
        # Backup current config
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Create new default config
        create_default_config
        print_success "Configuration reset to defaults"
        print_info "Backup saved as: $CONFIG_FILE.backup.*"
    else
        print_info "Reset cancelled"
    fi
    
    sleep 2
}

# Quick setup presets
setup_preset() {
    local preset="$1"
    
    case "$preset" in
        "minimal")
            print_info "Setting up minimal configuration..."
            update_config_value "adhd.breakReminders.enabled" "false"
            update_config_value "git.requireSafeCommit" "false"
            update_config_value "quality.testCoverage.minimumBranch" "60"
            ;;
        "standard")
            print_info "Setting up standard configuration..."
            update_config_value "adhd.breakReminders.enabled" "true"
            update_config_value "git.requireSafeCommit" "true"
            update_config_value "quality.testCoverage.minimumBranch" "80"
            ;;
        "enterprise")
            print_info "Setting up enterprise configuration..."
            update_config_value "adhd.breakReminders.enabled" "true"
            update_config_value "git.requireSafeCommit" "true"
            update_config_value "quality.testCoverage.minimumBranch" "95"
            update_config_value "quality.mutationTesting.minimumKillRate" "85"
            ;;
    esac
    
    print_success "Preset '$preset' applied"
    sleep 1
}

# Main menu loop
main() {
    # Ensure config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_info "Creating default configuration..."
        create_default_config
    fi
    
    # Handle command line arguments
    case "${1:-}" in
        "--preset="*)
            local preset="${1#--preset=}"
            setup_preset "$preset"
            exit 0
            ;;
        "--show")
            show_current_config
            exit 0
            ;;
        "--validate")
            validate_current_config
            exit 0
            ;;
        "--help")
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  --preset=minimal|standard|enterprise  Apply configuration preset"
            echo "  --show                                 Show current configuration"
            echo "  --validate                            Validate configuration"
            echo "  --help                                Show this help"
            echo ""
            echo "Interactive mode (default):"
            echo "  Run without arguments for interactive configuration menu"
            exit 0
            ;;
    esac
    
    # Interactive mode
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1) configure_adhd_settings ;;
            2) configure_git_workflow ;;
            3) configure_quality_standards ;;
            4) echo "Privacy configuration coming soon..."; sleep 1 ;;
            5) echo "CI configuration coming soon..."; sleep 1 ;;
            6) echo "Notification configuration coming soon..."; sleep 1 ;;
            7) echo "Custom commands configuration coming soon..."; sleep 1 ;;
            8) echo "Project information configuration coming soon..."; sleep 1 ;;
            s) show_current_config ;;
            v) validate_current_config ;;
            r) reset_to_defaults ;;
            q) print_success "Configuration saved"; exit 0 ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

# Run main function
main "$@"