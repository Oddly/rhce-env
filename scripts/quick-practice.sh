#!/bin/bash
# RHCE Quick Practice Scenarios Script

SCENARIO="${1:-menu}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_scenario() {
    echo -e "${BLUE}=== $1 ===${NC}"
    echo -e "${CYAN}$2${NC}"
    echo ""
}

print_command() {
    echo -e "${YELLOW}Command:${NC} $1"
}

print_tip() {
    echo -e "${GREEN}💡 Tip:${NC} $1"
}

execute_in_vm() {
    local command="$1"
    local description="$2"
    
    echo -e "${YELLOW}Executing:${NC} $description"
    echo -e "${CYAN}$command${NC}"
    echo ""
    
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && $command"
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ Command completed successfully${NC}"
    else
        echo -e "${RED}✗ Command failed with exit code $exit_code${NC}"
    fi
    echo ""
}

show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           RHCE Quick Practice Menu           ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Select a practice scenario:"
    echo ""
    echo -e "${CYAN}1.${NC} User Management Practice"
    echo -e "${CYAN}2.${NC} Storage & LVM Practice"
    echo -e "${CYAN}3.${NC} Web Services Practice"
    echo -e "${CYAN}4.${NC} Security & Firewall Practice"
    echo -e "${CYAN}5.${NC} Package Management Practice"
    echo -e "${CYAN}6.${NC} Ansible Ad-hoc Commands Practice"
    echo -e "${CYAN}7.${NC} Network Configuration Practice"
    echo -e "${CYAN}8.${NC} System Services Practice"
    echo ""
    echo -e "${YELLOW}0.${NC} Exit"
    echo ""
    read -p "Enter your choice (0-8): " choice
    
    case $choice in
        1) user_management_practice ;;
        2) storage_practice ;;
        3) web_services_practice ;;
        4) security_practice ;;
        5) package_practice ;;
        6) ansible_practice ;;
        7) network_practice ;;
        8) services_practice ;;
        0) echo "Goodbye! Happy practicing! 🎓"; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}"; sleep 2; show_menu ;;
    esac
}

user_management_practice() {
    print_scenario "User Management Practice" "Practice creating users, groups, and managing permissions with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible managed_nodes -m user -a 'name=testuser uid=2001 groups=wheel'"
    print_command "ansible managed_nodes -m group -a 'name=developers state=present'"
    print_command "ansible managed_nodes -m shell -a 'getent passwd testuser'"
    print_command "ansible managed_nodes -m file -a 'path=/home/testuser/.ssh state=directory mode=0700 owner=testuser'"
    echo ""
    
    print_tip "Always specify UIDs for consistency across systems"
    print_tip "Use 'become: yes' for user management tasks"
    echo ""
    
    read -p "Run interactive practice? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m user -a \"name=testuser uid=2001 groups=wheel\"'" "Creating test user"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m group -a \"name=developers state=present\"'" "Creating developers group"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"getent passwd testuser\"'" "Verifying user creation"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

storage_practice() {
    print_scenario "Storage & LVM Practice" "Practice disk management, partitioning, and LVM with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible managed_nodes -m shell -a 'lsblk'"
    print_command "ansible managed_nodes -m shell -a 'pvdisplay'"
    print_command "ansible managed_nodes -m shell -a 'vgdisplay'"
    print_command "ansible managed_nodes -m shell -a 'lvdisplay'"
    print_command "ansible managed_nodes -m shell -a 'df -h'"
    echo ""
    
    print_tip "Always check existing storage before making changes"
    print_tip "Use 'fstype' parameter carefully - wrong filesystem can cause data loss"
    echo ""
    
    read -p "Run storage inspection? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"lsblk\"'" "Listing block devices"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"df -h\"'" "Checking filesystem usage"
        execute_in_vm "vagrant ssh control -c 'ansible node1 -m shell -a \"pvdisplay 2>/dev/null || echo No LVM detected\"'" "Checking LVM on node1"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

web_services_practice() {
    print_scenario "Web Services Practice" "Practice configuring Apache and web services with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible web_servers -m yum -a 'name=httpd state=present'"
    print_command "ansible web_servers -m systemd -a 'name=httpd state=started enabled=yes'"
    print_command "ansible web_servers -m firewalld -a 'service=http permanent=yes state=enabled'"
    print_command "ansible web_servers -m uri -a 'url=http://{{ ansible_host }}'"
    echo ""
    
    print_tip "Always enable services AND start them"
    print_tip "Don't forget firewall rules for web services"
    echo ""
    
    read -p "Run web services setup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible web_servers -m yum -a \"name=httpd state=present\"'" "Installing Apache"
        execute_in_vm "vagrant ssh control -c 'ansible web_servers -m systemd -a \"name=httpd state=started enabled=yes\"'" "Starting Apache service"
        execute_in_vm "vagrant ssh control -c 'ansible web_servers -m firewalld -a \"service=http permanent=yes state=enabled immediate=yes\"'" "Configuring firewall"
        sleep 2
        execute_in_vm "vagrant ssh control -c 'ansible web_servers -m uri -a \"url=http://{{ ansible_host }}\"'" "Testing web service"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

security_practice() {
    print_scenario "Security & Firewall Practice" "Practice firewall rules and SELinux with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible managed_nodes -m shell -a 'getenforce'"
    print_command "ansible managed_nodes -m firewalld -a 'service=ssh permanent=yes state=enabled'"
    print_command "ansible managed_nodes -m shell -a 'firewall-cmd --list-all'"
    print_command "ansible managed_nodes -m selinux -a 'policy=targeted state=enforcing'"
    echo ""
    
    print_tip "Always check SELinux status before making changes"
    print_tip "Use 'immediate=yes' for firewall changes to take effect immediately"
    echo ""
    
    read -p "Run security checks? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"getenforce\"'" "Checking SELinux status"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"firewall-cmd --list-all\"'" "Listing firewall rules"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m systemd -a \"name=firewalld state=started enabled=yes\"'" "Ensuring firewalld is running"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

package_practice() {
    print_scenario "Package Management Practice" "Practice YUM/DNF operations with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible managed_nodes -m yum -a 'name=tree state=present'"
    print_command "ansible managed_nodes -m yum -a 'name=htop state=present'"
    print_command "ansible managed_nodes -m shell -a 'rpm -qa | grep tree'"
    print_command "ansible managed_nodes -m yum -a 'name=tree state=absent'"
    echo ""
    
    print_tip "Use 'state=latest' to update packages to newest version"
    print_tip "Always verify package installation with rpm or which commands"
    echo ""
    
    read -p "Run package management demo? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m yum -a \"name=tree state=present\"'" "Installing tree package"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"which tree\"'" "Verifying tree installation"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"tree --version\"'" "Checking tree version"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

ansible_practice() {
    print_scenario "Ansible Ad-hoc Commands Practice" "Practice various Ansible modules and commands"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible all -m ping"
    print_command "ansible managed_nodes -m setup -a 'filter=ansible_os_family'"
    print_command "ansible managed_nodes -m shell -a 'uptime'"
    print_command "ansible managed_nodes -m copy -a 'content=\"Hello RHCE\" dest=/tmp/test.txt'"
    print_command "ansible managed_nodes -m file -a 'path=/tmp/test.txt state=absent'"
    echo ""
    
    print_tip "Use -o flag for one-line output"
    print_tip "Use --limit to target specific hosts"
    echo ""
    
    read -p "Run Ansible connectivity tests? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible all -m ping -o'" "Testing connectivity to all hosts"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m setup -a \"filter=ansible_os_family\" -o'" "Gathering OS facts"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"uptime\" -o'" "Checking system uptime"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

network_practice() {
    print_scenario "Network Configuration Practice" "Practice network-related tasks with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible managed_nodes -m shell -a 'ip addr show'"
    print_command "ansible managed_nodes -m shell -a 'ss -tuln'"
    print_command "ansible managed_nodes -m shell -a 'ping -c 3 192.168.56.200'"
    print_command "ansible managed_nodes -m lineinfile -a 'path=/etc/hosts line=\"192.168.56.200 control.lab.example.com\"'"
    echo ""
    
    print_tip "Always test network connectivity after configuration changes"
    print_tip "Use 'ss' instead of 'netstat' on modern systems"
    echo ""
    
    read -p "Run network diagnostics? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"ip addr show | grep inet\"'" "Checking IP addresses"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"ss -tuln | head -10\"'" "Checking listening ports"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"ping -c 2 192.168.56.200\"'" "Testing connectivity to control node"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

services_practice() {
    print_scenario "System Services Practice" "Practice systemd service management with Ansible"
    
    echo "Available commands to practice:"
    echo ""
    print_command "ansible managed_nodes -m systemd -a 'name=chronyd state=started enabled=yes'"
    print_command "ansible managed_nodes -m shell -a 'systemctl status chronyd'"
    print_command "ansible managed_nodes -m shell -a 'systemctl list-units --failed'"
    print_command "ansible managed_nodes -m shell -a 'journalctl -u chronyd --no-pager -n 5'"
    echo ""
    
    print_tip "Always enable services that should start at boot"
    print_tip "Use journalctl to check service logs for troubleshooting"
    echo ""
    
    read -p "Run services management demo? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m systemd -a \"name=chronyd state=started enabled=yes\"'" "Managing chronyd service"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"systemctl is-enabled chronyd\"'" "Checking service enable status"
        execute_in_vm "vagrant ssh control -c 'ansible managed_nodes -m shell -a \"systemctl list-units --failed --no-pager\"'" "Checking for failed services"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..." -r
    show_menu
}

# Direct scenario execution (non-interactive mode)
run_scenario() {
    case "$SCENARIO" in
        "user") user_management_practice ;;
        "storage") storage_practice ;;
        "web") web_services_practice ;;
        "security") security_practice ;;
        "package") package_practice ;;
        "ansible") ansible_practice ;;
        "network") network_practice ;;
        "services") services_practice ;;
        *)
            echo "Unknown scenario: $SCENARIO"
            echo "Available scenarios: user, storage, web, security, package, ansible, network, services"
            exit 1
            ;;
    esac
}

# Main execution
if [[ "$SCENARIO" == "menu" || "$SCENARIO" == "" ]]; then
    show_menu
else
    run_scenario
fi
