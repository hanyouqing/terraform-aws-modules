# Terraform AWS Modules Makefile
# Provides common tasks for all modules and examples

.PHONY: help
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Configuration
TERRAFORM_VERSION := 1.14.2
TF_DOCS_VERSION := v0.16.0
TFLINT_VERSION := v0.51.0
TFSEC_VERSION := v1.28.1
CHECKOV_VERSION := 3.1.0

# Find all modules (directories with versions.tf, excluding .terraform and examples)
MODULES := $(shell find . -name "versions.tf" -not -path "*/.terraform/*" -not -path "*/examples/*" -not -path "*/.terraform" | xargs dirname | sort | uniq | grep -v "^\./\.terraform")

# Find all examples (directories with main.tf in examples/)
EXAMPLES := $(shell find . -path "*/examples/*/main.tf" -not -path "*/.terraform/*" | xargs dirname | sort | uniq)

# Terraform files pattern
TF_FILES := $(shell find . -name "*.tf" -not -path "./.terraform/*" -not -path "./examples/*")

# ==============================================================================
# Help
# ==============================================================================

help: ## Show this help message
	@echo "$(BLUE)Terraform AWS Modules - Makefile$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Modules found:$(NC) $(words $(MODULES))"
	@echo "$(GREEN)Examples found:$(NC) $(words $(EXAMPLES))"

# ==============================================================================
# Formatting
# ==============================================================================

fmt: ## Format all Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	@terraform fmt -recursive
	@echo "$(GREEN)✓ Formatting complete$(NC)"

fmt-check: ## Check if Terraform files are formatted
	@echo "$(BLUE)Checking Terraform formatting...$(NC)"
	@terraform fmt -check -recursive || (echo "$(RED)✗ Some files need formatting. Run 'make fmt' to fix.$(NC)" && exit 1)
	@echo "$(GREEN)✓ All files are properly formatted$(NC)"

fmt-module: ## Format a specific module (usage: make fmt-module MODULE=vpc)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE variable is required$(NC)"; \
		echo "Usage: make fmt-module MODULE=vpc"; \
		exit 1; \
	fi
	@echo "$(BLUE)Formatting module: $(MODULE)$(NC)"
	@terraform fmt -recursive $(MODULE)
	@echo "$(GREEN)✓ Formatting complete$(NC)"

fmt-example: ## Format a specific example (usage: make fmt-example EXAMPLE=vpc/examples/basic)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make fmt-example EXAMPLE=vpc/examples/basic"; \
		exit 1; \
	fi
	@echo "$(BLUE)Formatting example: $(EXAMPLE)$(NC)"
	@terraform fmt -recursive $(EXAMPLE)
	@echo "$(GREEN)✓ Formatting complete$(NC)"

# ==============================================================================
# Validation
# ==============================================================================

validate: ## Validate all modules and examples
	@echo "$(BLUE)Validating Terraform configurations...$(NC)"
	@$(MAKE) validate-modules
	@$(MAKE) validate-examples

validate-modules: ## Validate all modules
	@echo "$(BLUE)Validating modules...$(NC)"
	@for module in $(MODULES); do \
		echo "$(YELLOW)Validating $$module...$(NC)"; \
		cd $$module && terraform init -backend=false > /dev/null 2>&1 && terraform validate || (echo "$(RED)✗ Validation failed for $$module$(NC)" && exit 1); \
	done
	@echo "$(GREEN)✓ All modules validated successfully$(NC)"

validate-examples: ## Validate all examples
	@echo "$(BLUE)Validating examples...$(NC)"
	@for example in $(EXAMPLES); do \
		echo "$(YELLOW)Validating $$example...$(NC)"; \
		cd $$example && terraform init -backend=false > /dev/null 2>&1 && terraform validate || echo "$(YELLOW)⚠ Skipping $$example (may require backend configuration)$(NC)"; \
	done
	@echo "$(GREEN)✓ Examples validation complete$(NC)"

validate-module: ## Validate a specific module (usage: make validate-module MODULE=vpc)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE variable is required$(NC)"; \
		echo "Usage: make validate-module MODULE=vpc"; \
		exit 1; \
	fi
	@echo "$(BLUE)Validating module: $(MODULE)$(NC)"
	@cd $(MODULE) && terraform init -backend=false && terraform validate

validate-example: ## Validate a specific example (usage: make validate-example EXAMPLE=vpc/examples/basic)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make validate-example EXAMPLE=vpc/examples/basic"; \
		exit 1; \
	fi
	@echo "$(BLUE)Validating example: $(EXAMPLE)$(NC)"
	@cd $(EXAMPLE) && terraform init -backend=false && terraform validate

# ==============================================================================
# Linting
# ==============================================================================

lint: ## Run tflint on all modules
	@echo "$(BLUE)Running tflint...$(NC)"
	@if ! command -v tflint > /dev/null; then \
		echo "$(YELLOW)tflint not found. Install with: make install-tflint$(NC)"; \
		exit 1; \
	fi
	@for module in $(MODULES); do \
		echo "$(YELLOW)Linting $$module...$(NC)"; \
		cd $$module && tflint --init > /dev/null 2>&1 && tflint || echo "$(YELLOW)⚠ Linting issues found in $$module$(NC)"; \
	done
	@echo "$(GREEN)✓ Linting complete$(NC)"

lint-module: ## Lint a specific module (usage: make lint-module MODULE=vpc)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE variable is required$(NC)"; \
		echo "Usage: make lint-module MODULE=vpc"; \
		exit 1; \
	fi
	@if ! command -v tflint > /dev/null; then \
		echo "$(YELLOW)tflint not found. Install with: make install-tflint$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Linting module: $(MODULE)$(NC)"
	@cd $(MODULE) && tflint --init && tflint

# ==============================================================================
# Security Scanning
# ==============================================================================

security: ## Run security scans (tfsec and checkov)
	@echo "$(BLUE)Running security scans...$(NC)"
	@$(MAKE) tfsec
	@$(MAKE) checkov

tfsec: ## Run tfsec security scanner
	@echo "$(BLUE)Running tfsec...$(NC)"
	@if ! command -v tfsec > /dev/null; then \
		echo "$(YELLOW)tfsec not found. Install with: make install-tfsec$(NC)"; \
		exit 1; \
	fi
	@tfsec . --exclude-downloaded-modules || echo "$(YELLOW)⚠ Security issues found$(NC)"
	@echo "$(GREEN)✓ tfsec scan complete$(NC)"

checkov: ## Run checkov security scanner
	@echo "$(BLUE)Running checkov...$(NC)"
	@if ! command -v checkov > /dev/null; then \
		echo "$(YELLOW)checkov not found. Install with: make install-checkov$(NC)"; \
		exit 1; \
	fi
	@checkov -d . --framework terraform --quiet || echo "$(YELLOW)⚠ Security issues found$(NC)"
	@echo "$(GREEN)✓ checkov scan complete$(NC)"

# ==============================================================================
# Documentation
# ==============================================================================

docs: ## Generate documentation for all modules
	@echo "$(BLUE)Generating documentation...$(NC)"
	@if ! command -v terraform-docs > /dev/null; then \
		echo "$(YELLOW)terraform-docs not found. Install with: make install-terraform-docs$(NC)"; \
		exit 1; \
	fi
	@for module in $(MODULES); do \
		echo "$(YELLOW)Generating docs for $$module...$(NC)"; \
		terraform-docs markdown table --output-file README.md --output-mode inject $$module || echo "$(YELLOW)⚠ Failed to generate docs for $$module$(NC)"; \
	done
	@echo "$(GREEN)✓ Documentation generation complete$(NC)"

docs-module: ## Generate documentation for a specific module (usage: make docs-module MODULE=vpc)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE variable is required$(NC)"; \
		echo "Usage: make docs-module MODULE=vpc"; \
		exit 1; \
	fi
	@if ! command -v terraform-docs > /dev/null; then \
		echo "$(YELLOW)terraform-docs not found. Install with: make install-terraform-docs$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Generating documentation for module: $(MODULE)$(NC)"
	@terraform-docs markdown table --output-file README.md --output-mode inject $(MODULE)

# ==============================================================================
# Terraform Operations
# ==============================================================================

init: ## Initialize Terraform in current directory
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	@terraform init
	@echo "$(GREEN)✓ Initialization complete$(NC)"

init-module: ## Initialize a specific module (usage: make init-module MODULE=vpc)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE variable is required$(NC)"; \
		echo "Usage: make init-module MODULE=vpc"; \
		exit 1; \
	fi
	@echo "$(BLUE)Initializing module: $(MODULE)$(NC)"
	@cd $(MODULE) && terraform init

init-example: ## Initialize a specific example (usage: make init-example EXAMPLE=vpc/examples/basic)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make init-example EXAMPLE=vpc/examples/basic"; \
		exit 1; \
	fi
	@echo "$(BLUE)Initializing example: $(EXAMPLE)$(NC)"
	@cd $(EXAMPLE) && terraform init

plan: ## Run terraform plan in current directory
	@echo "$(BLUE)Running terraform plan...$(NC)"
	@terraform plan

plan-example: ## Plan a specific example (usage: make plan-example EXAMPLE=vpc/examples/basic)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make plan-example EXAMPLE=vpc/examples/basic"; \
		exit 1; \
	fi
	@echo "$(BLUE)Planning example: $(EXAMPLE)$(NC)"
	@cd $(EXAMPLE) && terraform plan

apply: ## Run terraform apply in current directory (use with caution)
	@echo "$(YELLOW)⚠ WARNING: This will apply changes to your infrastructure$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ==============================================================================
# Cleanup
# ==============================================================================

clean: ## Clean Terraform files (.terraform directories, .tfstate files)
	@echo "$(BLUE)Cleaning Terraform files...$(NC)"
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.tfstate" -delete 2>/dev/null || true
	@find . -type f -name "*.tfstate.backup" -delete 2>/dev/null || true
	@find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -type f -name "crash.log" -delete 2>/dev/null || true
	@find . -type f -name "crash.*.log" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-module: ## Clean a specific module (usage: make clean-module MODULE=vpc)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE variable is required$(NC)"; \
		echo "Usage: make clean-module MODULE=vpc"; \
		exit 1; \
	fi
	@echo "$(BLUE)Cleaning module: $(MODULE)$(NC)"
	@rm -rf $(MODULE)/.terraform $(MODULE)/*.tfstate $(MODULE)/*.tfstate.backup $(MODULE)/.terraform.lock.hcl
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-example: ## Clean a specific example (usage: make clean-example EXAMPLE=vpc/examples/basic)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make clean-example EXAMPLE=vpc/examples/basic"; \
		exit 1; \
	fi
	@echo "$(BLUE)Cleaning example: $(EXAMPLE)$(NC)"
	@rm -rf $(EXAMPLE)/.terraform $(EXAMPLE)/*.tfstate $(EXAMPLE)/*.tfstate.backup $(EXAMPLE)/.terraform.lock.hcl
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

# ==============================================================================
# Information
# ==============================================================================

list-modules: ## List all modules
	@echo "$(BLUE)Modules:$(NC)"
	@for module in $(MODULES); do \
		echo "  - $$module"; \
	done
	@echo ""
	@echo "$(GREEN)Total: $(words $(MODULES)) modules$(NC)"

list-examples: ## List all examples
	@echo "$(BLUE)Examples:$(NC)"
	@for example in $(EXAMPLES); do \
		echo "  - $$example"; \
	done
	@echo ""
	@echo "$(GREEN)Total: $(words $(EXAMPLES)) examples$(NC)"

info: ## Show project information
	@echo "$(BLUE)=== Terraform AWS Modules Information ===$(NC)"
	@echo ""
	@echo "$(GREEN)Modules:$(NC) $(words $(MODULES))"
	@echo "$(GREEN)Examples:$(NC) $(words $(EXAMPLES))"
	@echo "$(GREEN)Terraform Files:$(NC) $(words $(TF_FILES))"
	@echo ""
	@echo "$(GREEN)Required Tools:$(NC)"
	@command -v terraform > /dev/null && echo "  ✓ terraform: $$(terraform version | head -n1)" || echo "  ✗ terraform: not installed"
	@command -v terraform-docs > /dev/null && echo "  ✓ terraform-docs: $$(terraform-docs version)" || echo "  ✗ terraform-docs: not installed (install with: make install-terraform-docs)"
	@command -v tflint > /dev/null && echo "  ✓ tflint: $$(tflint --version)" || echo "  ✗ tflint: not installed (install with: make install-tflint)"
	@command -v tfsec > /dev/null && echo "  ✓ tfsec: $$(tfsec --version)" || echo "  ✗ tfsec: not installed (install with: make install-tfsec)"
	@command -v checkov > /dev/null && echo "  ✓ checkov: $$(checkov --version)" || echo "  ✗ checkov: not installed (install with: make install-checkov)"
	@echo ""

# ==============================================================================
# Pre-commit Checks
# ==============================================================================

pre-commit: ## Run all pre-commit checks (fmt-check, validate-modules, lint)
	@echo "$(BLUE)Running pre-commit checks...$(NC)"
	@$(MAKE) fmt-check
	@$(MAKE) validate-modules
	@$(MAKE) lint
	@echo "$(GREEN)✓ All pre-commit checks passed$(NC)"

ci: ## Run CI checks (fmt-check, validate, lint, security)
	@echo "$(BLUE)Running CI checks...$(NC)"
	@$(MAKE) fmt-check
	@$(MAKE) validate-modules
	@$(MAKE) lint
	@$(MAKE) security
	@echo "$(GREEN)✓ All CI checks passed$(NC)"

# ==============================================================================
# Tool Installation
# ==============================================================================

install-tools: ## Install all recommended tools
	@echo "$(BLUE)Installing Terraform tools...$(NC)"
	@$(MAKE) install-terraform-docs
	@$(MAKE) install-tflint
	@$(MAKE) install-tfsec
	@$(MAKE) install-checkov
	@echo "$(GREEN)✓ All tools installed$(NC)"

install-terraform-docs: ## Install terraform-docs
	@echo "$(BLUE)Installing terraform-docs...$(NC)"
	@if command -v brew > /dev/null; then \
		brew install terraform-docs; \
	elif command -v go > /dev/null; then \
		go install github.com/terraform-docs/terraform-docs@$(TF_DOCS_VERSION); \
	else \
		echo "$(RED)Error: Please install terraform-docs manually$(NC)"; \
		echo "See: https://terraform-docs.io/user-guide/installation/"; \
		exit 1; \
	fi

install-tflint: ## Install tflint
	@echo "$(BLUE)Installing tflint...$(NC)"
	@if command -v brew > /dev/null; then \
		brew install tflint; \
	else \
		echo "$(RED)Error: Please install tflint manually$(NC)"; \
		echo "See: https://github.com/terraform-linters/tflint#installation"; \
		exit 1; \
	fi

install-tfsec: ## Install tfsec
	@echo "$(BLUE)Installing tfsec...$(NC)"
	@if command -v brew > /dev/null; then \
		brew install tfsec; \
	else \
		echo "$(RED)Error: Please install tfsec manually$(NC)"; \
		echo "See: https://aquasecurity.github.io/tfsec/latest/getting-started/installation/"; \
		exit 1; \
	fi

install-checkov: ## Install checkov
	@echo "$(BLUE)Installing checkov...$(NC)"
	@if command -v pip3 > /dev/null; then \
		pip3 install checkov==$(CHECKOV_VERSION); \
	elif command -v brew > /dev/null; then \
		brew install checkov; \
	else \
		echo "$(RED)Error: Please install checkov manually$(NC)"; \
		echo "See: https://www.checkov.io/2.Basics/Installing%20Checkov.html"; \
		exit 1; \
	fi

# ==============================================================================
# Version Check
# ==============================================================================

check-versions: ## Check Terraform and tool versions
	@echo "$(BLUE)Checking versions...$(NC)"
	@echo "$(GREEN)Terraform:$(NC)"
	@terraform version || echo "$(RED)✗ Terraform not installed$(NC)"
	@echo ""
	@echo "$(GREEN)Tools:$(NC)"
	@command -v terraform-docs > /dev/null && echo "terraform-docs: $$(terraform-docs version)" || echo "$(RED)✗ terraform-docs not installed$(NC)"
	@command -v tflint > /dev/null && echo "tflint: $$(tflint --version)" || echo "$(RED)✗ tflint not installed$(NC)"
	@command -v tfsec > /dev/null && echo "tfsec: $$(tfsec --version)" || echo "$(RED)✗ tfsec not installed$(NC)"
	@command -v checkov > /dev/null && echo "checkov: $$(checkov --version)" || echo "$(RED)✗ checkov not installed$(NC)"
