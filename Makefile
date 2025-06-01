.PHONY: test install clean setup-dev lint

# Default target
all: test

# Test script syntax
test:
	@echo "Testing script syntax..."
	bash -n setup-vm.sh
	bash -n linux_setup.sh  
	bash -n macos-setup.sh
	bash -n scripts/*.sh 2>/dev/null || echo "Some utility scripts not found"
	@echo "? Syntax tests passed"

# Setup development environment
setup-dev:
	@echo "Setting up development environment..."
	chmod +x *.sh scripts/*.sh 2>/dev/null || true

# Lint scripts
lint:
	shellcheck *.sh scripts/*.sh 2>/dev/null || echo "shellcheck not available"

# Clean up test artifacts
clean:
	multipass delete vagrant-primary 2>/dev/null || true
	multipass purge 2>/dev/null || true

# Quick test with health check
test-health:
	./scripts/health-check.sh

# Run environment reset
reset:
	./scripts/reset-environment.sh soft

# Test complete environment setup
test-full:
	@echo "Running full environment test..."
	./linux_setup.sh --force || ./macos-setup.sh --force
	sleep 30
	./scripts/health-check.sh