#!/bin/bash
# Core VM Setup Script for RHCE Lab Environment
# This script runs inside the Multipass Ubuntu VM to set up the Vagrant environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Update system packages
update_system() {
    print_header "Updating System Packages"
    sudo apt-get update
    sudo apt-get upgrade -y
}

# Install essential packages
install_dependencies() {
    print_header "Installing Dependencies"
    sudo apt-get install -y \
        curl \
        wget \
        git \
        vim \
        htop \
        tree \
        unzip \
        build-essential \
        linux-headers-$(uname -r) \
        dkms \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
}

# Install VirtualBox
install_virtualbox() {
    print_header "Installing VirtualBox"
    
    # Add Oracle VirtualBox repository
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    
    sudo apt-get update
    sudo apt-get install -y virtualbox-7.0
    
    # Add user to vboxusers group
    sudo usermod -aG vboxusers ubuntu
    
    print_status "VirtualBox installed successfully"
}

# Install Vagrant
install_vagrant() {
    print_header "Installing Vagrant"
    
    # Add HashiCorp GPG key and repository
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update
    sudo apt-get install -y vagrant
    
    print_status "Vagrant installed successfully"
}

# Install Ansible
install_ansible() {
    print_header "Installing Ansible"
    
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
    
    print_status "Ansible installed successfully"
}

# Create lab directory structure
create_lab_structure() {
    print_header "Creating Lab Directory Structure"
    
    LAB_DIR="$HOME/vagrant-projects/rhel-lab"
    mkdir -p "$LAB_DIR"
    mkdir -p "$LAB_DIR/playbooks"
    mkdir -p "$LAB_DIR/roles"
    mkdir -p "$LAB_DIR/group_vars"
    mkdir -p "$LAB_DIR/host_vars"
    
    cd "$LAB_DIR"
    
    print_status "Lab directory created at: $LAB_DIR"
}

# Create Vagrantfile
create_vagrantfile() {
    print_header "Creating Vagrantfile"
    
    cat > "$LAB_DIR/Vagrantfile" << 'EOF'
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Common configuration
  config.vm.box_check_update = false
  
  # Repository server
  config.vm.define "repo" do |repo|
    repo.vm.box = "rdbreak/rhel8node"
    repo.vm.hostname = "repo.lab.example.com"
    repo.vm.network "private_network", ip: "192.168.56.199"
    repo.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    repo.vm.provision "shell", inline: <<-SHELL
      echo "192.168.56.199 repo.lab.example.com repo" >> /etc/hosts
      echo "192.168.56.200 control.lab.example.com control" >> /etc/hosts
      echo "192.168.56.201 node1.lab.example.com node1" >> /etc/hosts
      echo "192.168.56.202 node2.lab.example.com node2" >> /etc/hosts
      echo "192.168.56.203 node3.lab.example.com node3" >> /etc/hosts
      echo "192.168.56.204 node4.lab.example.com node4" >> /etc/hosts
      echo "192.168.56.205 node5.lab.example.com node5" >> /etc/hosts
    SHELL
  end

  # Control node (Ansible controller)
  config.vm.define "control" do |control|
    control.vm.box = "rdbreak/rhel8node"
    control.vm.hostname = "control.lab.example.com"
    control.vm.network "private_network", ip: "192.168.56.200"
    control.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    control.vm.provision "shell", inline: <<-SHELL
      echo "192.168.56.199 repo.lab.example.com repo" >> /etc/hosts
      echo "192.168.56.200 control.lab.example.com control" >> /etc/hosts
      echo "192.168.56.201 node1.lab.example.com node1" >> /etc/hosts
      echo "192.168.56.202 node2.lab.example.com node2" >> /etc/hosts
      echo "192.168.56.203 node3.lab.example.com node3" >> /etc/hosts
      echo "192.168.56.204 node4.lab.example.com node4" >> /etc/hosts
      echo "192.168.56.205 node5.lab.example.com node5" >> /etc/hosts
      
      # Install Ansible
      yum install -y epel-release
      yum install -y ansible git vim
      
      # Setup SSH keys for vagrant user
      sudo -u vagrant ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
    SHELL
  end

  # Managed nodes (node1-node5)
  (1..5).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "rdbreak/rhel8node"
      node.vm.hostname = "node#{i}.lab.example.com"
      node.vm.network "private_network", ip: "192.168.56.20#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
        
        # Add secondary disk for storage practice
        disk_size = case i
        when 1, 5 then "5120"  # 5GB for advanced scenarios
        when 2, 4 then "200"   # 200MB for small scenarios
        when 3 then "500"      # 500MB for partition practice
        end
        
        disk_path = "./disk-node#{i}.vdi"
        unless File.exist?(disk_path)
          vb.customize ['createhd', '--filename', disk_path, '--size', disk_size]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk_path]
      end
      
      node.vm.provision "shell", inline: <<-SHELL
        echo "192.168.56.199 repo.lab.example.com repo" >> /etc/hosts
        echo "192.168.56.200 control.lab.example.com control" >> /etc/hosts
        echo "192.168.56.201 node1.lab.example.com node1" >> /etc/hosts
        echo "192.168.56.202 node2.lab.example.com node2" >> /etc/hosts
        echo "192.168.56.203 node3.lab.example.com node3" >> /etc/hosts
        echo "192.168.56.204 node4.lab.example.com node4" >> /etc/hosts
        echo "192.168.56.205 node5.lab.example.com node5" >> /etc/hosts
      SHELL
    end
  end
end
EOF
    
    print_status "Vagrantfile created"
}

# Create Ansible configuration
create_ansible_config() {
    print_header "Creating Ansible Configuration"
    
    # Create ansible.cfg
    cat > "$LAB_DIR/ansible.cfg" << 'EOF'
[defaults]
inventory = inventory
remote_user = vagrant
ask_pass = false
host_key_checking = false
gathering = smart
fact_caching = memory
stdout_callback = yaml
callback_whitelist = timer, profile_tasks

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
EOF

    # Create inventory file
    cat > "$LAB_DIR/inventory" << 'EOF'
[control]
192.168.56.200 ansible_host=192.168.56.200

[repo]
192.168.56.199 ansible_host=192.168.56.199

[managed_nodes]
node1 ansible_host=192.168.56.201
node2 ansible_host=192.168.56.202
node3 ansible_host=192.168.56.203
node4 ansible_host=192.168.56.204
node5 ansible_host=192.168.56.205

[web_servers]
node1 ansible_host=192.168.56.201
node2 ansible_host=192.168.56.202

[database_servers]
node3 ansible_host=192.168.56.203
node4 ansible_host=192.168.56.204

[file_servers]
node5 ansible_host=192.168.56.205

[nodes:children]
managed_nodes

[all:vars]
ansible_user=vagrant
ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

    print_status "Ansible configuration created"
}

# Create sample playbooks
create_playbooks() {
    print_header "Creating Sample Playbooks"
    
    # Master playbook
    cat > "$LAB_DIR/playbooks/master.yml" << 'EOF'
---
- name: RHCE Lab Environment Setup
  hosts: all
  become: yes
  gather_facts: yes
  
  tasks:
    - name: Update system packages
      yum:
        name: "*"
        state: latest
      when: ansible_os_family == "RedHat"
    
    - name: Install essential packages
      yum:
        name:
          - vim
          - git
          - htop
          - tree
          - net-tools
          - bind-utils
          - wget
          - curl
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Configure firewalld
      service:
        name: firewalld
        state: started
        enabled: yes
    
    - name: Configure SELinux to enforcing
      selinux:
        policy: targeted
        state: enforcing
EOF

    print_status "Sample playbooks created"
}

# Create lab management scripts
create_lab_scripts() {
    print_header "Creating Lab Management Scripts"
    
    # Start lab script
    cat > "$LAB_DIR/start-lab.sh" << 'EOF'
#!/bin/bash
echo "Starting RHCE Lab Environment..."
echo "This may take several minutes on first run..."

vagrant up

echo ""
echo "Lab VMs Status:"
vagrant status

echo ""
echo "To access VMs:"
echo "  vagrant ssh control  # Ansible control node"
echo "  vagrant ssh repo     # Repository server"
echo "  vagrant ssh node1    # Managed node 1"
echo "  vagrant ssh node2    # Managed node 2"
echo "  vagrant ssh node3    # Managed node 3"
echo "  vagrant ssh node4    # Managed node 4"
echo "  vagrant ssh node5    # Managed node 5"
EOF
    chmod +x "$LAB_DIR/start-lab.sh"
    
    # Stop lab script
    cat > "$LAB_DIR/stop-lab.sh" << 'EOF'
#!/bin/bash
echo "Stopping RHCE Lab Environment..."
vagrant halt
echo "All VMs stopped."
EOF
    chmod +x "$LAB_DIR/stop-lab.sh"
    
    print_status "Lab management scripts created"
}

# Verify installation
verify_installation() {
    print_header "Verifying Installation"
    
    echo "VirtualBox version:"
    VBoxManage --version
    
    echo "Vagrant version:"
    vagrant --version
    
    echo "Ansible version:"
    ansible --version
    
    print_status "Installation verification complete"
}

# Main execution
main() {
    print_header "RHCE Lab Environment Setup"
    
    update_system
    install_dependencies
    install_virtualbox
    install_vagrant
    install_ansible
    create_lab_structure
    create_vagrantfile
    create_ansible_config
    create_playbooks
    create_lab_scripts
    verify_installation
    
    print_header "Setup Complete!"
    echo ""
    echo -e "${GREEN}RHCE Lab Environment Setup Completed Successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. cd ~/vagrant-projects/rhel-lab"
    echo "2. ./start-lab.sh"
    echo "3. Wait for all VMs to start (this may take 10-15 minutes)"
    echo "4. Test with: vagrant ssh control"
    echo ""
    echo "Lab Details:"
    echo "  ? repo: 192.168.56.199 (Repository server)"
    echo "  ? control: 192.168.56.200 (Ansible control node)"
    echo "  ? node1-5: 192.168.56.201-205 (Managed nodes)"
    echo ""
    echo "Happy RHCE practicing! ?"
}

# Run main function
main "$@"