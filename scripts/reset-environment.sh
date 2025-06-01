#!/bin/bash
# RHCE Environment Reset Script

RESET_TYPE="${1:-soft}"
FORCE_RESET="${2:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

confirm_action() {
    if [[ "$FORCE_RESET" != "true" && "$FORCE_RESET" != "force" ]]; then
        echo -e "${YELLOW}$1${NC}"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Reset cancelled."
            exit 0
        fi
    fi
}

soft_reset() {
    print_header "Soft Reset - Restarting Lab VMs"
    print_status "This will restart all Vagrant VMs in the lab environment"
    print_status "All data and configurations will be preserved"
    
    print_status "Stopping all lab VMs..."
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant halt" 2>/dev/null
    
    print_status "Starting all lab VMs..."
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant up" 2>/dev/null
    
    print_status "Soft reset completed!"
    print_status "Run './health-check.sh' to verify environment health"
}

hard_reset() {
    print_header "Hard Reset - Destroying and Recreating Lab VMs"
    confirm_action "This will destroy all lab VMs and their data (but preserve Multipass VM)."
    
    print_warning "Destroying all lab VMs..."
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant destroy -f" 2>/dev/null
    
    print_status "Cleaning up VM disk files..."
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && rm -f disk-*.vdi" 2>/dev/null
    
    print_status "Recreating lab VMs from scratch..."
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant up" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        print_status "Hard reset completed successfully!"
        print_status "All VMs have been recreated with fresh configurations"
    else
        print_error "Hard reset encountered issues. Check VM status manually."
        exit 1
    fi
}

complete_reset() {
    print_header "Complete Reset - Destroying Everything"
    confirm_action "This will destroy the entire Multipass VM and recreate everything from scratch."
    
    print_warning "Stopping and deleting Multipass VM..."
    multipass stop vagrant-primary 2>/dev/null || true
    multipass delete vagrant-primary 2>/dev/null || true
    multipass purge 2>/dev/null || true
    
    print_status "Recreating entire environment..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Try to find the original setup script
    local setup_script=""
    if [[ "$(uname)" == "Darwin" ]]; then
        # Try to find macOS setup script
        if [[ -f "$SCRIPT_DIR/../macos-setup.sh" ]]; then
            setup_script="$SCRIPT_DIR/../macos-setup.sh"
        elif [[ -f "$SCRIPT_DIR/macos-setup.sh" ]]; then
            setup_script="$SCRIPT_DIR/macos-setup.sh"
        fi
    else
        # Try to find Linux setup script
        if [[ -f "$SCRIPT_DIR/../linux-setup.sh" ]]; then
            setup_script="$SCRIPT_DIR/../linux-setup.sh"
        elif [[ -f "$SCRIPT_DIR/linux-setup.sh" ]]; then
            setup_script="$SCRIPT_DIR/linux-setup.sh"
        fi
    fi
    
    if [[ -n "$setup_script" && -f "$setup_script" ]]; then
        print_status "Running setup script: $setup_script"
        "$setup_script" --force
    else
        print_error "Cannot find original setup script to recreate environment"
        print_error "Please run the setup script manually from the repository directory"
        exit 1
    fi
    
    print_status "Complete reset finished!"
}

show_status() {
    print_header "Current Environment Status"
    
    # Check Multipass VM
    echo "Multipass VM Status:"
    multipass list 2>/dev/null || echo "Multipass not available"
    echo ""
    
    # Check Lab VMs if Multipass VM is running
    if multipass list 2>/dev/null | grep -q "vagrant-primary.*Running"; then
        echo "Lab VMs Status:"
        multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant status" 2>/dev/null || echo "Lab VMs not accessible"
    else
        echo "Lab VMs: Not accessible (Multipass VM not running)"
    fi
}

show_help() {
    echo "RHCE Environment Reset Script"
    echo "============================"
    echo ""
    echo "Usage: $0 [reset_type] [force]"
    echo ""
    echo "Reset Types:"
    echo "  soft      Restart lab VMs only (preserves data) - Default"
    echo "  hard      Destroy and recreate lab VMs (preserves Multipass VM)"
    echo "  complete  Destroy everything and recreate from scratch"
    echo "  status    Show current environment status"
    echo ""
    echo "Options:"
    echo "  force     Skip confirmation prompts"
    echo ""
    echo "Examples:"
    echo "  $0                    # Soft reset with confirmation"
    echo "  $0 soft force         # Soft reset without confirmation"
    echo "  $0 hard               # Hard reset with confirmation"
    echo "  $0 complete force     # Complete reset without confirmation"
    echo "  $0 status             # Show current status"
    echo ""
    echo "Reset Descriptions:"
    echo ""
    echo "SOFT RESET:"
    echo "  • Fastest option (2-5 minutes)"
    echo "  • Restarts all lab VMs"
    echo "  • Preserves all data and configurations"
    echo "  • Use for: temporary network issues, VM freezes"
    echo ""
    echo "HARD RESET:"
    echo "  • Medium option (10-15 minutes)"
    echo "  • Destroys and recreates all lab VMs"
    echo "  • Preserves Multipass VM and setup"
    echo "  • Use for: corrupted VMs, major configuration issues"
    echo ""
    echo "COMPLETE RESET:"
    echo "  • Slowest option (20-30 minutes)"
    echo "  • Destroys everything and recreates from scratch"
    echo "  • Downloads fresh VM images"
    echo "  • Use for: major system issues, starting completely fresh"
}

# Main execution
print_header "RHCE Environment Reset Script"

case "$RESET_TYPE" in
    "soft")
        print_status "Reset Type: Soft (restart VMs)"
        soft_reset
        ;;
    "hard")
        print_status "Reset Type: Hard (recreate lab VMs)"
        hard_reset
        ;;
    "complete")
        print_status "Reset Type: Complete (recreate everything)"
        complete_reset
        ;;
    "status")
        show_status
        ;;
    "-h"|"--help"|"help")
        show_help
        ;;
    *)
        print_error "Invalid reset type: $RESET_TYPE"
        echo ""
        echo "Valid options: soft, hard, complete, status"
        echo "Run '$0 --help' for detailed information"
        exit 1
        ;;
esac
