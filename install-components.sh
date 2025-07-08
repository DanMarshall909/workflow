#!/bin/bash
# Universal Workflow Library Component Installer
# Installs git hooks, scripts, and configurations for any project

set -euo pipefail

# Detect if running as submodule or standalone
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/.workflow" ]]; then
    # Running as submodule
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    IS_SUBMODULE=true
else
    # Running standalone
    PROJECT_ROOT="${1:-$(pwd)}"
    IS_SUBMODULE=false
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Parse command line arguments
install_git_hooks=true
install_scripts=true
install_workflows=true
install_config=true
target_project="$PROJECT_ROOT"

while [[ $# -gt 0 ]]; do
    case $1 in
        --target=*)
            target_project="${1#*=}"
            shift
            ;;
        --no-hooks)
            install_git_hooks=false
            shift
            ;;
        --no-scripts)
            install_scripts=false
            shift
            ;;
        --no-workflows)
            install_workflows=false
            shift
            ;;
        --no-config)
            install_config=false
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --target=PATH      Install to specific project path"
            echo "  --no-hooks         Skip git hooks installation"
            echo "  --no-scripts       Skip development scripts"
            echo "  --no-workflows     Skip GitHub Actions workflows"
            echo "  --no-config        Skip configuration setup"
            echo "  --help             Show this help"
            exit 0
            ;;
        *)
            target_project="$1"
            shift
            ;;
    esac
done

print_info "Installing workflow components to: $target_project"

# Verify target is a git repository
if [[ ! -d "$target_project/.git" ]]; then
    print_error "Target is not a git repository: $target_project"
    print_info "Initialize with: git init"
    exit 1
fi

# Detect project type
project_type="generic"
if [[ -f "$target_project/package.json" ]]; then
    project_type="nodejs"
elif [[ -f "$target_project"/*.csproj ]] || [[ -f "$target_project"/*.sln ]]; then
    project_type="dotnet"
elif [[ -f "$target_project/requirements.txt" ]] || [[ -f "$target_project/pyproject.toml" ]]; then
    project_type="python"
elif [[ -f "$target_project/go.mod" ]]; then
    project_type="go"
elif [[ -f "$target_project/Cargo.toml" ]]; then
    project_type="rust"
fi

print_info "Detected project type: $project_type"

# Install git hooks
if [[ "$install_git_hooks" == "true" ]]; then
    print_info "Installing git hooks..."
    
    if [[ -f "$SCRIPT_DIR/git-hooks/pre-commit" ]]; then
        cp "$SCRIPT_DIR/git-hooks/pre-commit" "$target_project/.git/hooks/"
        chmod +x "$target_project/.git/hooks/pre-commit"
        print_success "Pre-commit hook installed"
    fi
    
    if [[ -f "$SCRIPT_DIR/git-hooks/pre-push" ]]; then
        cp "$SCRIPT_DIR/git-hooks/pre-push" "$target_project/.git/hooks/"
        chmod +x "$target_project/.git/hooks/pre-push"
        print_success "Pre-push hook installed"
    fi
    
    if [[ -f "$SCRIPT_DIR/git-hooks/post-commit" ]]; then
        cp "$SCRIPT_DIR/git-hooks/post-commit" "$target_project/.git/hooks/"
        chmod +x "$target_project/.git/hooks/post-commit"
        print_success "Post-commit hook installed"
    fi
fi

# Install development scripts
if [[ "$install_scripts" == "true" ]]; then
    print_info "Installing development scripts..."
    
    mkdir -p "$target_project/scripts"
    
    # Copy workflow scripts
    for script in safe-commit.sh local-ci.sh break-enforcer.sh privacy-guard.sh; do
        if [[ -f "$SCRIPT_DIR/scripts/$script" ]]; then
            cp "$SCRIPT_DIR/scripts/$script" "$target_project/scripts/"
            chmod +x "$target_project/scripts/$script"
        fi
    done
    
    print_success "Development scripts installed"
fi

# Install GitHub Actions workflows
if [[ "$install_workflows" == "true" ]]; then
    print_info "Installing GitHub Actions workflows..."
    
    mkdir -p "$target_project/.github/workflows"
    
    case "$project_type" in
        "dotnet")
            if [[ -f "$SCRIPT_DIR/workflows/dotnet-ci.yml" ]]; then
                cp "$SCRIPT_DIR/workflows/dotnet-ci.yml" "$target_project/.github/workflows/ci.yml"
                print_success ".NET CI workflow installed"
            fi
            ;;
        "nodejs")
            if [[ -f "$SCRIPT_DIR/workflows/node-ci.yml" ]]; then
                cp "$SCRIPT_DIR/workflows/node-ci.yml" "$target_project/.github/workflows/ci.yml"
                print_success "Node.js CI workflow installed"
            fi
            ;;
        *)
            if [[ -f "$SCRIPT_DIR/workflows/generic-ci.yml" ]]; then
                cp "$SCRIPT_DIR/workflows/generic-ci.yml" "$target_project/.github/workflows/ci.yml"
                print_success "Generic CI workflow installed"
            fi
            ;;
    esac
fi

# Setup configuration
if [[ "$install_config" == "true" ]]; then
    print_info "Setting up configuration..."
    
    if [[ "$IS_SUBMODULE" == "true" ]]; then
        # Already have config in .workflow directory
        config_path="$target_project/.workflow"
    else
        # Create .workflow directory and copy config files
        mkdir -p "$target_project/.workflow"
        cp "$SCRIPT_DIR/config.json" "$target_project/.workflow/"
        cp "$SCRIPT_DIR/config-loader.sh" "$target_project/.workflow/"
        cp "$SCRIPT_DIR/configure.sh" "$target_project/.workflow/"
        chmod +x "$target_project/.workflow/config-loader.sh"
        chmod +x "$target_project/.workflow/configure.sh"
        config_path="$target_project/.workflow"
    fi
    
    # Initialize configuration with project-specific defaults
    if [[ -f "$config_path/config-loader.sh" ]]; then
        cd "$target_project"
        if [[ ! -f "$config_path/config.json" ]]; then
            "$config_path/config-loader.sh" create-default
            print_success "Default configuration created"
        fi
        
        # Update project name in config
        project_name=$(basename "$target_project")
        if command -v jq >/dev/null 2>&1; then
            temp_file=$(mktemp)
            jq ".project.name = \"$project_name\" | .project.type = \"$project_type\"" "$config_path/config.json" > "$temp_file" && mv "$temp_file" "$config_path/config.json"
            print_success "Configuration updated for $project_name ($project_type)"
        fi
        
        # Validate configuration
        if "$config_path/config-loader.sh" validate; then
            print_success "Configuration is valid"
        else
            print_warning "Configuration has issues - using defaults"
        fi
    fi
fi

echo ""
print_success "🎉 Workflow library installation complete!"
print_info "📋 Available commands:"

if [[ "$install_scripts" == "true" ]]; then
    echo "  • Local CI: ./scripts/local-ci.sh"
    echo "  • Safe commit: ./scripts/safe-commit.sh"
    echo "  • ADHD breaks: ./scripts/break-enforcer.sh"
    echo "  • Privacy guard: ./scripts/privacy-guard.sh"
fi

if [[ "$install_config" == "true" ]]; then
    echo ""
    print_info "🔧 Configuration management:"
    if [[ "$IS_SUBMODULE" == "true" ]]; then
        echo "  • Configure workflow: ./.workflow/configure.sh"
        echo "  • Show config: ./.workflow/configure.sh --show"
        echo "  • Validate config: ./.workflow/configure.sh --validate"
    else
        echo "  • Configure workflow: ./.workflow/configure.sh"
        echo "  • Show config: ./.workflow/configure.sh --show"
        echo "  • Validate config: ./.workflow/configure.sh --validate"
    fi
fi

echo ""
print_info "📖 Next steps:"
echo "  1. Review configuration: ./.workflow/configure.sh --show"
echo "  2. Customize settings: ./.workflow/configure.sh"
echo "  3. Start developing with: ./scripts/safe-commit.sh \"your message\""

if [[ "$project_type" != "generic" ]]; then
    echo ""
    print_info "🎯 Project-specific setup for $project_type:"
    case "$project_type" in
        "dotnet")
            echo "  • Quality standards: 95% coverage, 85% mutation testing"
            echo "  • Local CI includes: build, test, format, security scan"
            ;;
        "nodejs")
            echo "  • Package.json scripts integration available"
            echo "  • TypeScript support enabled"
            ;;
        "python")
            echo "  • Virtual environment detection"
            echo "  • pytest and coverage integration"
            ;;
    esac
fi