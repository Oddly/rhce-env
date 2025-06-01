#!/bin/bash
# RHCE Lab Environment Health Check Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FAILED_CHECKS=0

print_check() {
    local status=$1
    local message=$2
    
    if [[ $status -eq 0 ]]; then
        echo -e "${GREEN}✓${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
        ((FAILED_CHECKS++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check 1: Multipass installation and VM
check_multipass() {
    print_header "Multipass Environment"
    
    command -v multipass >/dev/null 2>&1
    print_check $? "Multipass installed"
    
    multipass list | grep -q "vagrant-primary"
    print_check $? "vagrant-primary VM exists"
    
    multipass list | grep "vagrant-primary" | grep -q "Running"
    print_check $? "vagrant-primary VM running"
}

# Check 2: Lab VMs
check_lab_vms() {
    print_header "Lab Virtual Machines"
    
    local vms=("repo" "control" "node1" "node2" "node3" "node4" "node5")
    
    for vm in "${vms[@]}"; do
        multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant status $vm | grep -q 'running'" 2>/dev/null
        print_check $? "$vm VM running"
    done
}

# Check 3: Network connectivity
check_network() {
    print_header "Network Connectivity"
    
    # Check if control node can reach all managed nodes
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant ssh control -c 'ansible all -m ping -o'" 2>/dev/null | grep -q "SUCCESS"
    print_check $? "Ansible connectivity to all nodes"
    
    # Check specific connections
    local nodes=("repo" "node1" "node2" "node3" "node4" "node5")
    for node in "${nodes[@]}"; do
        local ip=""
        case $node in
            "repo") ip="192.168.56.199" ;;
            "node1") ip="192.168.56.201" ;;
            "node2") ip="192.168.56.202" ;;
            "node3") ip="192.168.56.203" ;;
            "node4") ip="192.168.56.204" ;;
            "node5") ip="192.168.56.205" ;;
        esac
        
        multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant ssh control -c 'ping -c 1 $ip >/dev/null 2>&1'"
        print_check $? "Network connectivity to $node ($ip)"
    done
}

# Check 4: Services
check_services() {
    print_header "Essential Services"
    
    # Check SSH service on all nodes
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant ssh control -c 'ansible all -m shell -a \"systemctl is-active sshd\" -o'" 2>/dev/null | grep -q "active"
    print_check $? "SSH service running on all nodes"
    
    # Check firewalld
    multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant ssh control -c 'ansible managed_nodes -m shell -a \"systemctl is-active firewalld\" -o'" 2>/dev/null | grep -q "active"
    print_check $? "Firewalld running on managed nodes"
}

# Check 5: Storage configuration
check_storage() {
    print_header "Storage Configuration"
    
    # Check if secondary disks are attached
    local nodes=("node1" "node2" "node3" "node4" "node5")
    for node in "${nodes[@]}"; do
        multipass exec vagrant-primary -- bash -c "cd ~/vagrant-projects/rhel-lab && vagrant ssh $node -c 'lsblk | grep -q sdb'" 2>/dev/null
        print_check $? "Secondary disk attached to $node"
    done
}

# Check 6: Ansible configuration
check_ansible() {
    print_header "Ansible Configuration"
    
    # Check ansible.cfg exists
    multipass exec vagrant-primary -- bash -c "test -f ~/vagrant-projects/rhel-lab/ansible.cfg" 2>/dev/null
    print_check $? "ansible.cfg file exists"
    
    # Check inventory file
    multipass exec vagrant-primary -- bash -c "test -f ~/vagrant-projects/rhel-lab/inventory" 2>/dev/null
    print_check $? "inventory file exists"
    
    # Check playbooks directory
    multipass exec vagrant-primary -- bash -c "test -d ~/vagrant-projects/rhel-lab/playbooks" 2>/dev/null
    print_check $? "playbooks directory exists"
}

# Check 7: Resource usage
check_resources() {
    print_header "Resource Usage"
    
    # Get VM memory usage
    local memory_info=$(multipass info vagrant-primary | grep "Memory usage:" 2>/dev/null)
    if [[ -n "$memory_info" ]]; then
        echo "VM $memory_info"
    fi
    
    # Check host resources (simplified)
    if [[ "$(uname)" == "Darwin" ]]; then
        print_warning "Check Activity Monitor for host resource usage"
    else
        local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}' 2>/dev/null)
        if [[ -n "$memory_usage" ]] && (( $(echo "$memory_usage > 80" | bc -l 2>/dev/null || echo 0) )); then
            print_warning "Host memory usage high: ${memory_usage}%"
        elif [[ -n "$memory_usage" ]]; then
            print_check 0 "Host memory usage acceptable: ${memory_usage}%"
        fi
    fi
}

# Run all checks
main() {
    echo "RHCE Lab Environment Health Check"
    echo "================================="
    echo ""
    
    check_multipass
    echo ""
    check_lab_vms
    echo ""
    check_network
    echo ""
    check_services
    echo ""
    check_storage
    echo ""
    check_ansible
    echo ""
    check_resources
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All checks passed! Environment is healthy.${NC}"
        exit 0
    else
        echo -e "${RED}❌ $FAILED_CHECKS check(s) failed. Please review the issues above.${NC}"
        echo ""
        echo "Common solutions:"
        echo "- Run './reset-environment.sh soft' to restart VMs"
        echo "- Run './reset-environment.sh hard' to recreate lab VMs"
        echo "- Check system resources and close other applications"
        exit 1
    fi
}

main "$@"
