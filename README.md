RHCE Practice Environment - Cross-Platform Setup
This repository provides cross-platform scripts to set up a comprehensive RHCE (Red Hat Certified Engineer) practice environment using Multipass and Vagrant. Perfect for preparing for RHCE8 exams and future RHCE9 certification.
🎯 Purpose
Create a realistic RHCE exam simulation environment with:

Multiple RHEL 8 systems for hands-on practice
Ansible control node for automation tasks
Repository server for package management
Storage configuration for system administration tasks
Network isolation mimicking exam conditions

📋 RHCE Environment Overview
The practice environment includes 7 virtual machines configured specifically for RHCE exam scenarios:
VM Configuration
VMHostnameIP AddressRoleRAMPurposereporepo.lab.example.com192.168.56.199Repository Server1GBYUM/DNF repository, HTTP/FTP servicescontrolcontrol.lab.example.com192.168.56.200Ansible Control2GBAnsible automation, exam control nodenode1node1.lab.example.com192.168.56.201Managed Node1GBTarget for automation tasksnode2node2.lab.example.com192.168.56.202Managed Node1GBTarget for automation tasksnode3node3.lab.example.com192.168.56.203Managed Node1GBTarget for automation tasksnode4node4.lab.example.com192.168.56.204Managed Node1GBTarget for automation tasksnode5node5.lab.example.com192.168.56.205Managed Node1GBTarget for automation tasks
RHCE Exam Skills Covered
🔧 System Administration Tasks

User and group management
File permissions and ACLs
System services and systemd
Process management
Log file analysis
System monitoring and performance tuning
Network configuration
Firewall management (firewalld)
SELinux configuration

📦 Package Management

YUM/DNF repository configuration
Package installation and updates
Local repository creation
Software management automation

🔧 Storage Management

Disk partitioning and formatting
LVM (Logical Volume Management)
File system creation and mounting
Swap configuration
Storage automation with Ansible

🤖 Ansible Automation (Core RHCE Focus)

Playbook creation and execution
Inventory management
Variable usage and templating
Conditional tasks and loops
Role creation and management
Vault for sensitive data
Error handling and debugging

🌐 Network Services

HTTP/HTTPS configuration
FTP services
NFS shares
SSH configuration and key management
Time synchronization (chronyd)

🛡️ Security

Firewall rules automation
SELinux policy management
User authentication and sudo
SSH security hardening
File and directory permissions

Architecture
Host System (Windows/macOS/Linux)
└── Multipass VM (Ubuntu 20.04)
    └── VirtualBox + Vagrant
        ├── repo (192.168.56.199)
        ├── control (192.168.56.200)
        ├── node1 (192.168.56.201)
        ├── node2 (192.168.56.202)
        ├── node3 (192.168.56.203)
        ├── node4 (192.168.56.204)
        └── node5 (192.168.56.205)
Quick Start
Windows 10/11

Download all scripts to the same directory:

windows-setup.ps1
setup-vm.sh


Run PowerShell as Administrator
Execute the setup script:
powershell# Navigate to the directory containing the scripts
cd C:\path\to\scripts
.\windows-setup.ps1

Access your environment:
powershellcd $env:USERPROFILE\vagrant-multipass-lab
.\access-vm.ps1


macOS (Intel & Apple Silicon)

Download all scripts to the same directory:

macos-setup.sh
setup-vm.sh


Run the setup script:
bashchmod +x macos-setup.sh
./macos-setup.sh

Access your environment:
bashcd ~/vagrant-multipass-lab
./access-vm.sh


Linux (Ubuntu/Debian/CentOS/RHEL/Fedora/openSUSE)

Download all scripts to the same directory:

linux-setup.sh
setup-vm.sh


Run the setup script:
bashchmod +x linux-setup.sh
./linux-setup.sh

Access your environment:
bashcd ~/vagrant-multipass-lab
./access-vm.sh


What Gets Installed
Host System

Multipass: VM management platform
Vagrant: VM orchestration tool
Platform-specific package managers (Chocolatey/Homebrew/distro packages)

Inside Multipass VM

Ubuntu 20.04 LTS
VirtualBox: Virtualization platform
Vagrant: VM orchestration
Ansible: Configuration management
Development tools: Git, Python, build essentials
Lab environment: Pre-configured Vagrantfile and scripts

Usage
Starting the Lab Environment

Access the Multipass VM:
bash# Windows
multipass shell vagrant-primary

# macOS
multipass shell vagrant-primary

# Linux
./access-vm.sh

Navigate to the lab directory:
bashcd ~/vagrant-projects/rhel-lab

Start all VMs:
bash./start-lab.sh
Or start individual VMs:
bashvagrant up repo
vagrant up control
vagrant up node1
# etc.


Managing VMs
bash# Check status of all VMs
vagrant status

# SSH into specific VMs
vagrant ssh repo
vagrant ssh control
vagrant ssh node1

# Stop all VMs
./stop-lab.sh
# or
vagrant halt

# Destroy all VMs (careful!)
vagrant destroy
Managing the Multipass VM
bash# Check Multipass VM status
multipass list

# Start/stop the Multipass VM
multipass start vagrant-primary
multipass stop vagrant-primary

# Mount host directory into VM
multipass mount /path/to/your/files vagrant-primary:/mnt/host

# Get VM information
multipass info vagrant-primary
Network Configuration
All VMs are connected via a private network (192.168.56.0/24):
VMIP AddressRolerepo192.168.56.199Repository/Package servercontrol192.168.56.200Ansible control nodenode1192.168.56.201Worker nodenode2192.168.56.202Worker nodenode3192.168.56.203Worker nodenode4192.168.56.204Worker nodenode5192.168.56.205Worker node
Storage Configuration
Each node VM includes an additional disk for storage exercises:
VMPrimary DiskSecondary DiskSizenode1/dev/sda/dev/sdb5GBnode2/dev/sda/dev/sdb200MBnode3/dev/sda/dev/sdb500MBnode4/dev/sda/dev/sdb200MBnode5/dev/sda/dev/sdb5GB
Repository Structure
project-directory/
├── windows-setup.ps1              # Windows setup script
├── macos-setup.sh                 # macOS setup script  
├── linux-setup.sh                 # Linux setup script
├── setup-vm.sh                    # General VM setup script
├── README.md                      # This file
└── original-Vagrantfile           # Your original Vagrantfile

# After running setup scripts:
~/vagrant-multipass-lab/           # User project directory
├── access-vm.ps1/.sh              # Quick VM access scripts
├── manage-vm.ps1/.sh              # VM management scripts
└── (Windows users: see %USERPROFILE%\vagrant-multipass-lab\)

# Inside Multipass VM:
~/vagrant-projects/rhel-lab/       # Lab environment
├── Vagrantfile                    # Main Vagrant configuration
├── ansible.cfg                    # Ansible configuration
├── inventory                      # Ansible inventory
├── start-lab.sh                   # Start all VMs
├── stop-lab.sh                    # Stop all VMs
├── playbooks/                     # Ansible playbooks
│   └── master.yml                # Main playbook
└── disk-*.vdi                    # VM disk files (created automatically)
Prerequisites
Before running any setup script, ensure you have:

All required scripts downloaded in the same directory:

Platform-specific setup script (windows-setup.ps1, macos-setup.sh, or linux-setup.sh)
General VM setup script (setup-vm.sh)


Administrative privileges (Windows) or sudo access (Linux/macOS)
Adequate system resources (see Resource Requirements section)
Internet connection for downloading packages (setup scripts work offline after initial setup)

Ansible Integration
The environment includes pre-configured Ansible setup:
Inventory File
ini[control]
192.168.56.200

[repo]
192.168.56.199

[nodes]
192.168.56.201
192.168.56.202
192.168.56.203
192.168.56.204
192.168.56.205

[all:vars]
ansible_user=vagrant
ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
Running Ansible Playbooks
bash# From the control VM
vagrant ssh control

# Test connectivity
ansible all -m ping

# Run the main playbook
ansible-playbook playbooks/master.yml

# Run ad-hoc commands
ansible nodes -m shell -a "uptime"
Troubleshooting
Common Issues
1. VM Won't Start
bash# Check Multipass VM status
multipass list

# Restart Multipass VM
multipass restart vagrant-primary

# Check VirtualBox inside VM
multipass exec vagrant-primary -- vboxmanage list vms
2. Network Connectivity Issues
bash# Check VM network configuration
vagrant ssh control
ip addr show

# Test connectivity between VMs
ping 192.168.56.199  # repo
ping 192.168.56.201  # node1
3. Storage Issues
bash# Check available space in Multipass VM
multipass exec vagrant-primary -- df -h

# Check VirtualBox disk usage
multipass exec vagrant-primary -- ls -la ~/vagrant-projects/rhel-lab/disk-*.vdi
4. Performance Issues

Increase Multipass VM resources:
bashmultipass stop vagrant-primary
multipass set vagrant-primary --cpus 6
multipass set vagrant-primary --memory 8G
multipass start vagrant-primary


Platform-Specific Issues
Windows

PowerShell Execution Policy: Run Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Chocolatey Issues: Restart PowerShell as Administrator after installation
Hyper-V Conflicts: Disable Hyper-V if using VirtualBox

macOS

Homebrew Permissions: Check ownership of /opt/homebrew (M1/M2) or /usr/local (Intel)
Security Permissions: Allow Multipass in System Preferences > Security & Privacy
Rosetta 2: May be needed for some Intel-based tools on Apple Silicon

Linux

Snap Installation: Some distributions require manual snapd setup
Group Membership: Log out and back in after installation for group changes
SELinux: May need configuration on RHEL/CentOS systems

Resource Requirements
Minimum System Requirements

CPU: 4 cores (8 cores recommended)
RAM: 8GB (16GB recommended)
Storage: 50GB free space (100GB recommended)
Network: Internet connection for downloads

Resource Allocation

Multipass VM: 4 CPUs, 4GB RAM, 20GB disk
Each Vagrant VM: 1-2GB RAM (repo=1GB, control=2GB, nodes=1GB each)
Total when all running: ~12GB RAM, ~60GB disk

Advanced Configuration
Customizing VM Resources
Edit the Vagrantfile to modify VM resources:
ruby# Increase memory for specific VMs
config.vm.define "control" do |control|
  control.vm.provider :virtualbox do |vb|
    vb.memory = "4096"  # Change from 2048 to 4096
    vb.cpus = 2         # Add CPU configuration
  end
end
Adding Additional VMs
Add new VM definitions to the Vagrantfile:
rubyconfig.vm.define "node6" do |node6|
  node6.vm.box = "rdbreak/rhel8node"
  node6.vm.network "private_network", ip: "192.168.56.206"
  node6.vm.provider "virtualbox" do |node6|
    node6.memory = "1024"
  end
end
Custom Provisioning
Modify the Ansible playbooks in playbooks/ directory to customize VM configuration.
Security Considerations

Default Vagrant SSH keys are used (insecure for production)
VMs use default passwords where applicable
Network is isolated to host-only adapter
This environment is intended for lab/development use only

Contributing
To contribute improvements:

Fork the repository
Create a feature branch
Make your changes
Test on multiple platforms
Submit a pull request

License
This project is provided as-is for educational and lab purposes.
Support
For issues and questions:

Check the troubleshooting section above
Review Vagrant documentation: https://www.vagrantup.com/docs
Review Multipass documentation: https://multipass.run/docs
Open an issue in the repository

Changelog
v1.0

Initial cross-platform setup scripts
Support for Windows, macOS, and Linux
Multipass-based virtualization
Pre-configured RHEL 8 lab environment
Ansible integration
Storage configuration for lab exercises
