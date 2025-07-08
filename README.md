# Development Workflow Library

**Enterprise-grade development workflow tools with ADHD-friendly design and comprehensive configuration system.**

## 🎯 Features

- **🧠 ADHD Support**: Break reminders, TDD enforcement, progress tracking
- **🔧 Configurable**: Project-specific settings via JSON configuration
- **🛡️ Quality Gates**: Coverage thresholds, mutation testing, code analysis
- **🔐 Privacy First**: PII detection, data minimization controls
- **⚡ Free-Tier Optimized**: GitHub Actions cost-efficient workflows
- **🎨 Customizable**: Themes, notifications, and enforcement levels

## 🚀 Quick Start

### Add as Git Submodule
```bash
# Add workflow library to your project
git submodule add https://github.com/DanMarshall909/workflow.git .workflow
git submodule update --init --recursive

# Install components
./.workflow/install-components.sh

# Configure for your project
./.workflow/configure.sh
```

### Direct Installation
```bash
# Clone and install
git clone https://github.com/DanMarshall909/workflow.git
cd workflow
./install-components.sh --target=/path/to/your/project
```

## 📁 Repository Structure

```
workflow/
├── config.json                 # Default configuration template
├── config-loader.sh           # Configuration management system
├── configure.sh               # Interactive configuration tool
├── install-components.sh      # Component installer
├── git-hooks/                 # Git hooks with ADHD support
│   ├── pre-commit             # Safe-commit enforcement
│   ├── pre-push               # Quality gates and CI monitoring
│   └── post-commit            # Progress tracking
├── scripts/                   # Development automation
│   ├── safe-commit.sh         # ADHD-friendly commit workflow
│   ├── local-ci.sh           # 30-second quality validation
│   ├── break-enforcer.sh     # ADHD break management
│   └── privacy-guard.sh      # PII detection and removal
├── workflows/                 # GitHub Actions templates
│   ├── dotnet-ci.yml         # .NET free-tier optimized CI
│   ├── node-ci.yml           # Node.js free-tier optimized CI
│   └── branch-protection.yml # Branch protection enforcement
└── docs/                     # Documentation and guides
    ├── configuration.md       # Configuration reference
    ├── adhd-support.md       # ADHD developer support guide
    └── project-integration.md # Integration instructions
```

## 🔧 Configuration System

The workflow library uses a powerful JSON-based configuration system that adapts to different project types and team preferences.

### Configuration File: `config.json`

```json
{
  "project": {
    "name": "MyProject",
    "type": "dotnet-web-api",
    "language": "csharp"
  },
  "git": {
    "developmentBranch": "dev",
    "requireSafeCommit": true,
    "enforceConventionalCommits": true
  },
  "adhd": {
    "breakReminders": {
      "enabled": true,
      "intervalMinutes": 25,
      "enforceBreaks": true
    },
    "tddEnforcement": {
      "enabled": true,
      "requireRedGreenRefactor": true
    }
  },
  "quality": {
    "testCoverage": {
      "minimumBranch": 95,
      "minimumLine": 90
    },
    "mutationTesting": {
      "enabled": true,
      "minimumKillRate": 85
    }
  }
}
```

### Configuration Commands

```bash
# Interactive configuration menu
./.workflow/configure.sh

# Show current configuration
./.workflow/configure.sh --show

# Validate configuration
./.workflow/configure.sh --validate

# Apply presets
./.workflow/configure.sh --preset=minimal     # Basic settings
./.workflow/configure.sh --preset=standard    # Balanced settings  
./.workflow/configure.sh --preset=enterprise  # Full features
```

## 🧠 ADHD Developer Support

### Break Reminder System
- **Configurable intervals**: 25/50/90 minute options
- **Progressive nudging**: Gentle → Firm → Insistent
- **Hyperfocus detection**: Smart break skipping
- **Progress celebration**: Motivational completion messages

### TDD Cycle Enforcement
- **Red-Green-Refactor**: Enforced cycle progression
- **Coverage requirements**: Configurable thresholds
- **Safe commits**: Only allow commits with passing tests
- **Break integration**: Automatic breaks between cycles

### Focus Management
- **Session tracking**: Monitor work periods and interruptions
- **Task breakdown**: ADHD-friendly task decomposition
- **Progress visualization**: Clear completion indicators

## 🛡️ Quality Standards

### Configurable Thresholds
- **Code Coverage**: Branch and line coverage minimums
- **Mutation Testing**: Kill rate requirements
- **Code Analysis**: Issue count limits
- **Security Scanning**: PII detection and secrets prevention

### Enforcement Levels
- **Minimal**: Basic quality checks (60% coverage)
- **Standard**: Balanced development (80% coverage)
- **Enterprise**: Maximum quality (95% coverage, 85% mutation)

## 📊 Supported Project Types

### .NET Projects
- **Web APIs**: FastEndpoints, ASP.NET Core
- **Console Apps**: Worker services, CLI tools
- **Libraries**: Class libraries, NuGet packages
- **Blazor**: Server and WebAssembly applications

### Node.js Projects
- **React**: Next.js, Create React App, Vite
- **Express**: REST APIs, GraphQL servers
- **TypeScript**: Strict type checking and validation
- **Testing**: Jest, Vitest, Playwright

### Generic Projects
- **Python**: Django, Flask, FastAPI
- **Go**: CLI tools, web services
- **Rust**: Systems programming, WebAssembly
- **Any Language**: Basic git workflow and quality gates

## 🚀 GitHub Actions Integration

### Free-Tier Optimization
- **Efficient workflows**: <500 minutes/month usage
- **Smart caching**: Dependencies and build artifacts
- **Parallel execution**: Optimized job scheduling
- **Cost monitoring**: Usage tracking and alerts

### Available Workflows
- **CI/CD**: Build, test, deploy pipelines
- **Quality Gates**: Coverage, security, performance
- **Branch Protection**: Enforce workflow compliance
- **Release Automation**: Semantic versioning, changelog generation

## 📖 Getting Started Guides

### For New Projects
1. **Initialize**: `git init && git submodule add https://github.com/DanMarshall909/workflow.git .workflow`
2. **Configure**: `./.workflow/configure.sh --preset=standard`
3. **Install**: `./.workflow/install-components.sh`
4. **Develop**: Use `./scripts/safe-commit.sh` for commits

### For Existing Projects
1. **Add Submodule**: `git submodule add https://github.com/DanMarshall909/workflow.git .workflow`
2. **Assess Current Setup**: `./.workflow/configure.sh --show`
3. **Gradual Migration**: Enable features incrementally
4. **Team Training**: Review ADHD support and quality standards

### For Teams
1. **Standardize**: Use enterprise preset for consistency
2. **Customize**: Adjust for team preferences and project needs
3. **Document**: Record team-specific configuration decisions
4. **Iterate**: Regular review and improvement of workflow

## 🔗 Integration Examples

### Anchor Project Integration
```bash
# Current Anchor setup
git submodule add https://github.com/DanMarshall909/workflow.git .workflow
./.workflow/configure.sh --preset=enterprise
```

### Simple Library Project
```bash
# Minimal setup for a library
./.workflow/configure.sh --preset=minimal
# Disables ADHD breaks, reduces quality thresholds
```

### Startup MVP
```bash
# Fast iteration setup
./.workflow/configure.sh --preset=standard
# Balanced between speed and quality
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch from `main`
3. **Follow** the workflow standards (dogfooding!)
4. **Test** with multiple project types
5. **Document** new features and configuration options
6. **Submit** a pull request with clear description

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Report bugs and feature requests on GitHub
- **Documentation**: Comprehensive guides in `/docs` directory
- **Community**: Share configurations and best practices
- **Professional**: Enterprise support available

---

**Built with ❤️ for developers with ADHD and teams that value quality.**