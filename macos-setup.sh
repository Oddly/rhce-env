#!/bin/bash
# macOS Setup Script for Multipass Vagrant Environment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}=== $1 ===${NC}"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

install_homebrew() {
    print_header "Installing Homebrew"
    if command_exists brew; then
        print_status "Homebrew already installed"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

install_multipass() {
    print_header "Installing Multipass"
    if command_exists multipass; then
        print_status "Multipass already installed"
    else
        brew install multipass
    fi
}

setup_project_directory() {
    print_header "Setting Up Project Directory"
    PROJECT_DIR="$HOME/vagrant-multipass-lab"
    mkdir -p "$PROJECT_DIR"
    
    # Check for local setup script
    if [[ ! -f "./setup-vm.sh" ]]; then
        print_error "setup-vm.sh not found in current directory!"
        exit 1
    fi
    print_status "Found local setup-vm.sh script"
}

setup_multipass_vm() {
    print_header "Setting Up Multipass VM"
    vm_name="vagrant-primary"
    
    # Check if VM exists
    if multipass list --format csv | grep -q "$vm_name"; then
        if [[ "$1" == "--force" ]]; then
            print_warning "Recreating existing VM..."
            multipass stop "$vm_name" 2>/dev/null || true
            multipass delete "$vm_name"
            multipass purge
        else
            print_warning "VM '$vm_name' already exists. Use --force to recreate."
            return 0
        fi
    fi
    
    # Launch VM
    print_status "Launching Ubuntu 20.04 VM..."
    multipass launch 20.04 --name "$vm_name" --cpus 4 --memory 4G --disk 20G
    
    # Setup VM
    print_status "Setting up VM environment..."
    multipass transfer "./setup-vm.sh" "$vm_name:/tmp/setup-vm.sh"
    multipass exec "$vm_name" -- chmod +x /tmp/setup-vm.sh
    multipass exec "$vm_name" -- /tmp/setup-vm.sh
}

create_helper_scripts() {
    print_header "Creating Helper Scripts"
    PROJECT_DIR="$HOME/vagrant-multipass-lab"
    
    # Access script
    cat > "$PROJECT_DIR/access-vm.sh" << 'EOF'
#!/bin/bash
echo "Accessing Multipass VM..."
multipass shell vagrant-primary
EOF
    chmod +x "$PROJECT_DIR/access-vm.sh"
    
    # Management script
    cat > "$PROJECT_DIR/manage-vm.sh" << 'EOF'
#!/bin/bash
VM_NAME="vagrant-primary"

case "$1" in
    start) multipass start "$VM_NAME" ;;
    stop) multipass stop "$VM_NAME" ;;
    restart) multipass restart "$VM_NAME" ;;
    status) multipass list ;;
    info) multipass info "$VM_NAME" ;;
    shell) multipass shell "$VM_NAME" ;;
    mount) multipass mount "$2" "$VM_NAME:/mnt/host" ;;
    unmount) multipass umount "$VM_NAME" ;;
    *) echo "Usage: $0 {start|stop|restart|status|info|shell|mount <path>|unmount}" ;;
esac
EOF
    chmod +x "$PROJECT_DIR/manage-vm.sh"
}

main() {
    print_header "macOS Vagrant Multipass Environment Setup"
    
    if [[ "$EUID" -eq 0 ]]; then
        print_error "Do not run as root"
        exit 1
    fi
    
    install_homebrew
    install_multipass
    setup_project_directory
    setup_multipass_vm "$1"
    create_helper_scripts
    
    print_header "Setup Complete!"
    echo "Next steps:"
    echo "1. cd ~/vagrant-multipass-lab"
    echo "2. ./access-vm.sh"
    echo "3. cd ~/vagrant-projects/rhel-lab && ./start-lab.sh"
}

main "$@"