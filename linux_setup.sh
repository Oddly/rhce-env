#!/bin/bash
# Linux Setup Script for Multipass Vagrant Environment
# Supports Ubuntu, Debian, CentOS, RHEL, Fedora, openSUSE

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        print_status "Detected: $PRETTY_NAME"
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
}

# Update package manager based on distribution
update_packages() {
    print_header "Updating System Packages"
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get upgrade -y
            ;;
        centos|rhel|rocky|almalinux)
            if command_exists dnf; then
                sudo dnf update -y
            else
                sudo yum update -y
            fi
            ;;
        fedora)
            sudo dnf update -y
            ;;
        opensuse*|sles)
            sudo zypper refresh
            sudo zypper update -y
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm
            ;;
        *)
            print_warning "Unsupported distribution: $DISTRO"
            print_warning "Please install packages manually"
            ;;
    esac
}

# Install base dependencies
install_base_dependencies() {
    print_header "Installing Base Dependencies"
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get install -y \
                curl \
                wget \
                git \
                vim \
                htop \
                tree \
                unzip \
                software-properties-common \
                apt-transport-https \
                ca-certificates \
                gnupg \
                lsb-release \
                snapd
            ;;
        centos|rhel|rocky|almalinux)
            if command_exists dnf; then
                sudo dnf install -y \
                    curl \
                    wget \
                    git \
                    vim \
                    htop \
                    tree \
                    unzip \
                    ca-certificates \
                    snapd
                sudo dnf groupinstall -y "Development Tools"
            else
                sudo yum install -y \
                    curl \
                    wget \
                    git \
                    vim \
                    htop \
                    tree \
                    unzip \
                    ca-certificates \
                    snapd
                sudo yum groupinstall -y "Development Tools"
            fi
            ;;
        fedora)
            sudo dnf install -y \
                curl \
                wget \
                git \
                vim \
                htop \
                tree \
                unzip \
                ca-certificates \
                snapd
            sudo dnf groupinstall -y "Development Tools"
            ;;
        opensuse*|sles)
            sudo zypper install -y \
                curl \
                wget \
                git \
                vim \
                htop \
                tree \
                unzip \
                ca-certificates \
                snapd
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm \
                curl \
                wget \
                git \
                vim \
                htop \
                tree \
                unzip \
                ca-certificates \
                snapd
            ;;
    esac
}

# Install Multipass
install_multipass() {
    print_header "Installing Multipass"
    
    if command_exists multipass; then
        print_status "Multipass already installed"
        return 0
    fi
    
    case $DISTRO in
        ubuntu|debian)
            # Install via snap
            sudo snap install multipass
            ;;
        centos|rhel|rocky|almalinux|fedora)
            # Enable snapd and install via snap
            sudo systemctl enable --now snapd.socket
            sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
            sudo snap install multipass
            ;;
        opensuse*|sles)
            sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_15.4 snappy
            sudo zypper --gpg-auto-import-keys refresh
            sudo zypper dup --from snappy
            sudo zypper install snapd
            sudo systemctl enable --now snapd
            sudo systemctl enable --now snapd.apparmor
            sudo snap install multipass
            ;;
        arch|manjaro)
            # Install from AUR or snap
            if command_exists yay; then
                yay -S multipass
            elif command_exists paru; then
                paru -S multipass
            else
                # Install via snap
                sudo systemctl enable --now snapd.socket
                sudo ln -sf /var/lib/snapd/snap /snap
                sudo snap install multipass
            fi
            ;;
        *)
            print_error "Automatic Multipass installation not supported for $DISTRO"
            print_status "Please install Multipass manually from: https://multipass.run/"
            exit 1
            ;;
    esac
    
    # Add user to multipass group if it exists
    if getent group multipass >/dev/null 2>&1; then
        sudo usermod -aG multipass $USER
        print_status "Added user to multipass group"
    fi
}

# Install Vagrant
install_vagrant() {
    print_header "Installing Vagrant"
    
    if command_exists vagrant; then
        print_status "Vagrant already installed"
        return 0
    fi
    
    case $DISTRO in
        ubuntu|debian)
            # Add HashiCorp GPG key and repository
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
            sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
            sudo apt-get update
            sudo apt-get install -y vagrant
            ;;
        centos|rhel|rocky|almalinux|fedora)
            # Add HashiCorp repository
            sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 2>/dev/null || \
            sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
            
            if command_exists dnf; then
                sudo dnf install -y vagrant
            else
                sudo yum install -y vagrant
            fi
            ;;
        opensuse*|sles)
            # Download and install RPM
            VAGRANT_VERSION="2.4.0"
            wget "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}-1_x86_64.rpm"
            sudo zypper install -y "./vagrant_${VAGRANT_VERSION}-1_x86_64.rpm"
            rm "./vagrant_${VAGRANT_VERSION}-1_x86_64.rpm"
            ;;
        arch|manjaro)
            sudo pacman -S vagrant
            ;;
        *)
            print_error "Automatic Vagrant installation not supported for $DISTRO"
            print_status "Please install Vagrant manually from: https://www.vagrantup.com/"
            exit 1
            ;;
    esac
}

# Setup project directory
setup_project_directory() {
    print_header "Setting Up Project Directory"
    
    PROJECT_DIR="$HOME/vagrant-multipass-lab"
    
    if [[ ! -d "$PROJECT_DIR" ]]; then
        mkdir -p "$PROJECT_DIR"
        print_status "Created project directory: $PROJECT_DIR"
    else
        print_status "Project directory already exists: $PROJECT_DIR"
    fi
    
    # Create the VM setup script
    SETUP_SCRIPT="$PROJECT_DIR/setup-vm.sh"
    print_status "Creating VM setup script..."
    
    # Download the actual setup script content
    cat > "$SETUP_SCRIPT" << 'EOF'
#!/bin/bash
# VM setup script - this should be replaced with the actual content
echo "VM setup script placeholder - replace with actual setup-vm.sh content"
EOF
    
    chmod +x "$SETUP_SCRIPT"
}

# Launch and configure Multipass VM
setup_multipass_vm() {
    local vm_name="vagrant-primary"
    local force_recreate=${1:-false}
    
    print_header "Setting Up Multipass VM"
    
    # Check if VM already exists
    if multipass list --format csv | grep -q "$vm_name"; then
        if [[ "$force_recreate" == "true" ]]; then
            print_warning "Recreating existing VM..."
            multipass stop "$vm_name" 2>/dev/null || true
            multipass delete "$vm_name"
            multipass purge
        else
            print_warning "VM '$vm_name' already exists. Skipping creation."
            return 0
        fi
    fi
    
    # Launch VM with appropriate resources
    print_status "Launching Multipass VM with Ubuntu 20.04..."
    multipass launch 20.04 \
        --name "$vm_name" \
        --cpus 4 \
        --memory 4G \
        --disk 20G
    
    # Wait for VM to be ready
    print_status "Waiting for VM to be ready..."
    sleep 10
    
    # Transfer and execute setup script
    print_status "Transferring setup script to VM..."
    multipass transfer "$PROJECT_DIR/setup-vm.sh" "$vm_name:/tmp/setup-vm.sh"
    
    print_status "Executing setup script in VM..."
    multipass exec "$vm_name" -- chmod +x /tmp/setup-vm.sh
    multipass exec "$vm_name" -- /tmp/setup-vm.sh
}

# Create helper scripts
create_helper_scripts() {
    print_header "Creating Helper Scripts"
    
    PROJECT_DIR="$HOME/vagrant-multipass-lab"
    
    # Create VM access script
    cat > "$PROJECT_DIR/access-vm.sh" << 'EOF'
#!/bin/bash
# Script to access the Multipass VM

VM_NAME="vagrant-primary"

echo "Accessing Multipass VM: $VM_NAME"
echo "Use 'exit' to return to host system"
echo ""

multipass shell "$VM_NAME"
EOF
    chmod +x "$PROJECT_DIR/access-vm.sh"
    
    # Create VM management script
    cat > "$PROJECT_DIR/manage-vm.sh" << 'EOF'
#!/bin/bash
# VM Management Script

VM_NAME="vagrant-primary"

case "$1" in
    start)
        echo "Starting VM: $VM_NAME"
        multipass start "$VM_NAME"
        ;;
    stop)
        echo "Stopping VM: $VM_NAME"
        multipass stop "$VM_NAME"
        ;;
    restart)
        echo "Restarting VM: $VM_NAME"
        multipass restart "$VM_NAME"
        ;;
    status)
        echo "VM Status:"
        multipass list
        ;;
    info)
        echo "VM Information:"
        multipass info "$VM_NAME"
        ;;
    shell)
        echo "Accessing VM shell:"
        multipass shell "$VM_NAME"
        ;;
    mount)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 mount <local-path>"
            exit 1
        fi
        echo "Mounting $2 to VM..."
        multipass mount "$2" "$VM_NAME:/mnt/host"
        ;;
    unmount)
        echo "Unmounting host directories..."
        multipass umount "$VM_NAME"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|info|shell|mount <path>|unmount}"
        echo ""
        echo "Commands:"
        echo "  start    - Start the VM"
        echo "  stop     - Stop the VM"
        echo "  restart  - Restart the VM"
        echo "  status   - Show VM status"
        echo "  info     - Show VM information"
        echo "  shell    - Access VM shell"
        echo "  mount    - Mount local directory to VM"
        echo "  unmount  - Unmount host directories"
        exit 1
        ;;
esac
EOF
    chmod +x "$PROJECT_DIR/manage-vm.sh"
    
    # Copy utility scripts from repository if they exist
    print_status "Copying utility scripts from repository..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    local utility_scripts=(
        "scripts/health-check.sh"
        "scripts/exam-timer.sh" 
        "scripts/reset-environment.sh"
        "scripts/quick-practice.sh"
        "scripts/snapshot-manager.sh"
        "scripts/backup-lab.sh"
        "scripts/status-check.sh"
        "scripts/monitor-performance.sh"
        "scripts/collect-logs.sh"
        "scripts/optimize-resources.sh"
    )
    
    for script in "${utility_scripts[@]}"; do
        local script_name=$(basename "$script")
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            cp "$SCRIPT_DIR/$script" "$PROJECT_DIR/$script_name"
            chmod +x "$PROJECT_DIR/$script_name"
            print_status "  ✓ Copied $script_name"
        else
            print_warning "  ⚠ $script not found in repository"
        fi
    done
    
    print_status "Helper scripts created"
}

# Verify installations
verify_installations() {
    print_header "Verifying Installations"
    
    local errors=0
    
    if command_exists multipass; then
        MULTIPASS_VERSION=$(multipass version)
        print_status "Multipass: $MULTIPASS_VERSION"
    else
        print_error "Multipass installation failed"
        ((errors++))
    fi
    
    if command_exists vagrant; then
        VAGRANT_VERSION=$(vagrant --version)
        print_status "Vagrant: $VAGRANT_VERSION"
    else
        print_error "Vagrant installation failed"
        ((errors++))
    fi
    
    # Check VM status if it exists
    if multipass list --format csv | grep -q "vagrant-primary"; then
        VM_STATUS=$(multipass list --format csv | grep vagrant-primary | cut -d, -f2)
        print_status "VM Status: $VM_STATUS"
    fi
    
    return $errors
}

# Display final instructions
display_final_instructions() {
    print_header "Setup Complete!"
    
    echo ""
    echo -e "${GREEN}Linux Vagrant Multipass Environment Setup Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Project Directory:${NC} $HOME/vagrant-multipass-lab"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    echo "  cd ~/vagrant-multipass-lab"
    echo "  ./access-vm.sh                    # Access the VM"
    echo "  ./manage-vm.sh status             # Check VM status"
    echo ""
    echo -e "${YELLOW}VM Management:${NC}"
    echo "  ./manage-vm.sh start              # Start VM"
    echo "  ./manage-vm.sh stop               # Stop VM"
    echo "  ./manage-vm.sh shell              # Access VM shell"
    echo "  ./manage-vm.sh info               # Show VM info"
    echo ""
    echo -e "${YELLOW}Inside the VM:${NC}"
    echo "  cd ~/vagrant-projects/rhel-lab    # Go to lab directory"
    echo "  ./start-lab.sh                    # Start all Vagrant VMs"
    echo "  vagrant status                    # Check Vagrant VM status"
    echo ""
    echo -e "${YELLOW}Mounting Host Directories:${NC}"
    echo "  ./manage-vm.sh mount /path/to/your/project"
    echo "  # Then access at /mnt/host inside VM"
    echo ""
    echo -e "${BLUE}Note:${NC} You may need to log out and log back in for group changes to take effect."
    echo -e "${BLUE}Distribution:${NC} $PRETTY_NAME"
    echo ""
}

# Main execution function
main() {
    print_header "Linux Vagrant Multipass Environment Setup"
    
    # Parse command line arguments
    FORCE_RECREATE=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE_RECREATE=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [--force]"
                echo "  --force    Recreate VM if it already exists"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        print_error "Please run as a regular user (the script will use sudo when needed)"
        exit 1
    fi
    
    # Detect distribution
    detect_distro
    
    # Run setup steps
    update_packages
    install_base_dependencies
    install_multipass
    install_vagrant
    setup_project_directory
    setup_multipass_vm "$FORCE_RECREATE"
    create_helper_scripts
    
    # Verify installations
    if ! verify_installations; then
        print_error "Some installations failed. Please check the errors above."
        exit 1
    fi
    
    display_final_instructions
    
    print_status "Setup completed successfully!"
    print_status "Please log out and log back in, then run: cd ~/vagrant-multipass-lab && ./access-vm.sh"
}

# Run main function
main "$@"
