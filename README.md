# RHCE Practice Environment - Cross-Platform Setup

This repository provides cross-platform scripts to set up a comprehensive RHCE (Red Hat Certified Engineer) practice environment using Multipass and Vagrant. Perfect for preparing for RHCE8 exams and future RHCE9 certification.

## 🎯 Purpose

Create a realistic RHCE exam simulation environment with:
- **Multiple RHEL 8 systems** for hands-on practice
- **Ansible control node** for automation tasks
- **Repository server** for package management
- **Storage configuration** for system administration tasks
- **Network isolation** mimicking exam conditions

## 📋 RHCE Environment Overview

The practice environment includes 7 virtual machines configured specifically for RHCE exam scenarios:

### VM Configuration
| VM | Hostname | IP Address | Role | RAM | Purpose |
|----|----------|------------|------|-----|---------|
| **repo** | repo.lab.example.com | 192.168.56.199 | Repository Server | 1GB | YUM/DNF repository, HTTP/FTP services |
| **control** | control.lab.example.com | 192.168.56.200 | Ansible Control | 2GB | Ansible automation, exam control node |
| **node1** | node1.lab.example.com | 192.168.56.201 | Managed Node | 1GB | Target for automation tasks |
| **node2** | node2.lab.example.com | 192.168.56.202 | Managed Node | 1GB | Target for automation tasks |
| **node3** | node3.lab.example.com | 192.168.56.203 | Managed Node | 1GB | Target for automation tasks |
| **node4** | node4.lab.example.com | 192.168.56.204 | Managed Node | 1GB | Target for automation tasks |
| **node5** | node5.lab.example.com | 192.168.56.205 | Managed Node | 1GB | Target for automation tasks |

### RHCE Exam Skills Covered

#### 🔧 **System Administration Tasks**
- User and group management
- File permissions and ACLs
- System services and systemd
- Process management
- Log file analysis
- System monitoring and performance tuning
- Network configuration
- Firewall management (firewalld)
- SELinux configuration

#### 📦 **Package Management**
- YUM/DNF repository configuration
- Package installation and updates
- Local repository creation
- Software management automation

#### 🔧 **Storage Management**
- Disk partitioning and formatting
- LVM (Logical Volume Management)
- File system creation and mounting
- Swap configuration
- Storage automation with Ansible

#### 🤖 **Ansible Automation** (Core RHCE Focus)
- Playbook creation and execution
- Inventory management
- Variable usage and templating
- Conditional tasks and loops
- Role creation and management
- Vault for sensitive data
- Error handling and debugging

#### 🌐 **Network Services**
- HTTP/HTTPS configuration
- FTP services
- NFS shares
- SSH configuration and key management
- Time synchronization (chronyd)

#### 🛡️ **Security**
- Firewall rules automation
- SELinux policy management
- User authentication and sudo
- SSH security hardening
- File and directory permissions

## Architecture

```
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
```

## Storage Configuration for RHCE Practice

Each managed node includes additional storage for hands-on practice with disk management, LVM, and file systems:

| VM | Primary Disk | Secondary Disk | Size | RHCE Practice Areas |
|----|--------------|----------------|------|-------------------|
| node1 | /dev/sda (system) | /dev/sdb | 5GB | LVM, file systems, mounting |
| node2 | /dev/sda (system) | /dev/sdb | 200MB | Small volume management |
| node3 | /dev/sda (system) | /dev/sdb | 500MB | Partition management |
| node4 | /dev/sda (system) | /dev/sdb | 200MB | Swap configuration |
| node5 | /dev/sda (system) | /dev/sdb | 5GB | Advanced LVM scenarios |

## Prerequisites for RHCE Practice

### System Requirements
- **CPU**: 4+ cores (8 cores recommended for smooth performance)
- **RAM**: 12GB+ (16GB recommended when all VMs running)
- **Storage**: 50GB+ free space (100GB recommended)
- **Network**: Internet connection for initial setup

### RHCE Knowledge Prerequisites
- Basic Linux command line proficiency
- Understanding of RHEL/CentOS systems
- Familiarity with text editors (vim/nano)
- Basic networking concepts

## Quick Start for RHCE Practice

### Windows 10/11

1. **Download all scripts to the same directory:**
   - `windows-setup.ps1`
   - `setup-vm.sh`
   
2. **Run PowerShell as Administrator**
3. **Execute the setup script:**
   ```powershell
   # Navigate to the directory containing the scripts
   cd C:\path\to\scripts
   .\windows-setup.ps1
   ```
4. **Access your RHCE practice environment:**
   ```powershell
   cd $env:USERPROFILE\vagrant-multipass-lab
   .\access-vm.ps1
   ```

### macOS (Intel & Apple Silicon)

1. **Download all scripts to the same directory:**
   - `macos-setup.sh`  
   - `setup-vm.sh`
   
2. **Run the setup script:**
   ```bash
   chmod +x macos-setup.sh
   ./macos-setup.sh
   ```
3. **Access your RHCE practice environment:**
   ```bash
   cd ~/vagrant-multipass-lab
   ./access-vm.sh
   ```

### Linux (Ubuntu/Debian/CentOS/RHEL/Fedora/openSUSE)

1. **Download all scripts to the same directory:**
   - `linux-setup.sh`
   - `setup-vm.sh`
   
2. **Run the setup script:**
   ```bash
   chmod +x linux-setup.sh
   ./linux-setup.sh
   ```
3. **Access your RHCE practice environment:**
   ```bash
   cd ~/vagrant-multipass-lab
   ./access-vm.sh
   ```

## RHCE Practice Workflow

### 1. Start Your Practice Session
```bash
# Access the Multipass VM
./access-vm.sh  # (Linux/macOS) or .\access-vm.ps1 (Windows)

# Inside the VM, start the RHCE lab
cd ~/vagrant-projects/rhel-lab
./start-lab.sh

# Check all VMs are running
vagrant status
```

### 2. Begin RHCE Tasks on Control Node
```bash
# SSH to the Ansible control node
vagrant ssh control

# Verify Ansible connectivity to all managed nodes
ansible all -m ping

# Start practicing RHCE tasks
cd /vagrant/playbooks
```

### 3. Common RHCE Practice Commands
```bash
# Test Ansible inventory
ansible-inventory --list

# Run ad-hoc commands on managed nodes
ansible nodes -m shell -a "uptime"
ansible nodes -m yum -a "name=httpd state=present" --become

# Practice playbook execution
ansible-playbook playbooks/system-config.yml
ansible-playbook playbooks/user-management.yml
ansible-playbook playbooks/storage-setup.yml
```

### 4. Access Individual Managed Nodes
```bash
# From the host (Multipass VM)
vagrant ssh node1  # Practice system administration
vagrant ssh node2  # Test configurations
vagrant ssh node3  # Verify automation results
```

## What Gets Installed

### Host System
- **Multipass**: VM management platform
- **Vagrant**: VM orchestration tool
- Platform-specific package managers (Chocolatey/Homebrew/distro packages)

### Inside Multipass VM
- **Ubuntu 20.04 LTS**
- **VirtualBox**: Virtualization platform
- **Vagrant**: VM orchestration
- **Ansible**: Configuration management
- **Development tools**: Git, Python, build essentials
- **Lab environment**: Pre-configured Vagrantfile and scripts

## Repository Structure

```
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
```

## Prerequisites

Before running any setup script, ensure you have:

1. **All required scripts downloaded** in the same directory:
   - Platform-specific setup script (`windows-setup.ps1`, `macos-setup.sh`, or `linux-setup.sh`)
   - General VM setup script (`setup-vm.sh`)

2. **Administrative privileges** (Windows) or sudo access (Linux/macOS)

3. **Adequate system resources** (see Resource Requirements section)

4. **Internet connection** for downloading packages (setup scripts work offline after initial setup)

## Usage

### Starting the Lab Environment

1. **Access the Multipass VM:**
   ```bash
   # Windows
   .\access-vm.ps1
   
   # macOS/Linux
   ./access-vm.sh
   ```

2. **Navigate to the lab directory:**
   ```bash
   cd ~/vagrant-projects/rhel-lab
   ```

3. **Start all VMs:**
   ```bash
   ./start-lab.sh
   ```

   Or start individual VMs:
   ```bash
   vagrant up repo
   vagrant up control
   vagrant up node1
   # etc.
   ```

### Managing VMs

```bash
# Check status of all VMs
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
```

### Managing the Multipass VM

```bash
# Check Multipass VM status
multipass list

# Start/stop the Multipass VM
multipass start vagrant-primary
multipass stop vagrant-primary

# Mount host directory into VM
multipass mount /path/to/your/files vagrant-primary:/mnt/host

# Get VM information
multipass info vagrant-primary
```

## Network Configuration

All VMs are connected via a private network (192.168.56.0/24):

| VM | IP Address | Role |
|----|------------|------|
| repo | 192.168.56.199 | Repository/Package server |
| control | 192.168.56.200 | Ansible control node |
| node1 | 192.168.56.201 | Worker node |
| node2 | 192.168.56.202 | Worker node |
| node3 | 192.168.56.203 | Worker node |
| node4 | 192.168.56.204 | Worker node |
| node5 | 192.168.56.205 | Worker node |

## Ansible Integration

The environment includes pre-configured Ansible setup:

### Inventory File
```ini
[control]
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
```

### Running Ansible Playbooks
```bash
# From the control VM
vagrant ssh control

# Test connectivity
ansible all -m ping

# Run the main playbook
ansible-playbook playbooks/master.yml

# Run ad-hoc commands
ansible nodes -m shell -a "uptime"
```

## RHCE Practice Scenarios

### 📋 **Scenario 1: User Management Automation**
**Objective**: Create users and groups across all managed nodes using Ansible
```bash
# Practice commands on control node
ansible-playbook playbooks/user-management.yml
ansible managed_nodes -m shell -a "getent passwd john"
ansible managed_nodes -m shell -a "groups jane"
```

### 💾 **Scenario 2: Storage Configuration**
**Objective**: Configure LVM and filesystems on managed nodes
```bash
# Practice commands
ansible-playbook playbooks/storage-management.yml
ansible managed_nodes -m shell -a "lsblk"
ansible managed_nodes -m shell -a "df -h /mnt/data"
```

### 🌐 **Scenario 3: Web Services Deployment**
**Objective**: Deploy and configure Apache web servers
```bash
# Practice commands
ansible-playbook playbooks/network-services.yml
ansible web_servers -m uri -a "url=http://{{ ansible_host }}"
```

### 🔒 **Scenario 4: Security Hardening**
**Objective**: Configure firewall and SELinux policies
```bash
# Practice ad-hoc security commands
ansible managed_nodes -m firewalld -a "service=ssh permanent=yes state=enabled"
ansible managed_nodes -m shell -a "getenforce"
ansible managed_nodes -m selinux -a "policy=targeted state=enforcing"
```

### 📦 **Scenario 5: Package Management**
**Objective**: Manage software packages and repositories
```bash
# Practice package management
ansible managed_nodes -m yum_repository -a "name=epel description='EPEL Repository' baseurl=https://download.fedoraproject.org/pub/epel/8/Everything/x86_64/ enabled=yes gpgcheck=no"
ansible managed_nodes -m yum -a "name=htop state=present"
```

## RHCE Exam Simulation

### 🎯 **Timed Practice Sessions** (Recommended)
1. **30-minute sprints**: Focus on single tasks (user management, storage, etc.)
2. **2-hour simulations**: Complete multiple related tasks
3. **4-hour mock exams**: Full RHCE exam simulation

### 📝 **Common RHCE Tasks to Practice**

#### **Ansible Automation** (60% of exam focus)
- [ ] Create and run playbooks for system configuration
- [ ] Use variables, loops, and conditionals
- [ ] Implement error handling and when conditions
- [ ] Create and use Ansible roles
- [ ] Manage Ansible Vault for sensitive data
- [ ] Use Ansible Galaxy for community roles

#### **System Configuration** (25% of exam focus)
- [ ] Configure network settings and hostname
- [ ] Manage system services with systemd
- [ ] Configure time synchronization
- [ ] Set up log rotation and analysis
- [ ] Configure kernel parameters

#### **Security Management** (15% of exam focus)
- [ ] Configure SELinux policies and contexts
- [ ] Manage firewall rules with firewalld
- [ ] Set up SSH key-based authentication
- [ ] Configure sudo access and policies
- [ ] Implement file and directory permissions

### 🧪 **Advanced Practice Labs**

#### **Lab 1: Multi-tier Application Deployment**
Deploy a complete web application stack:
```bash
# Database tier (node3, node4)
ansible database_servers -m yum -a "name=mariadb-server state=present"
ansible database_servers -m systemd -a "name=mariadb state=started enabled=yes"

# Web tier (node1, node2)  
ansible web_servers -m yum -a "name=httpd,php,php-mysqlnd state=present"
ansible web_servers -m systemd -a "name=httpd state=started enabled=yes"

# Load balancer tier (node5)
ansible file_servers -m yum -a "name=haproxy state=present"
```

#### **Lab 2: Automated Backup Solution**
Create automated backup strategies:
```bash
# Practice cron jobs and rsync
ansible managed_nodes -m cron -a "name='Daily backup' minute=0 hour=2 job='rsync -av /home/ /backup/'"
```

#### **Lab 3: Monitoring and Logging**
Set up centralized logging:
```bash
# Configure rsyslog forwarding
ansible managed_nodes -m lineinfile -a "path=/etc/rsyslog.conf line='*.* @@192.168.56.200:514'"
```

## Troubleshooting RHCE Environment

### 🔧 **Common Issues and Solutions**

#### **Ansible Connectivity Problems**
```bash
# Debug SSH connectivity
ansible all -m ping -vvv

# Check SSH keys
ansible all -m shell -a "ssh-keygen -f ~/.ssh/known_hosts -R 192.168.56.201"

# Verify inventory
ansible-inventory --list
```

#### **Storage Configuration Issues**
```bash
# Check available disks
ansible managed_nodes -m shell -a "lsblk"

# Verify LVM configuration
ansible managed_nodes -m shell -a "pvdisplay"
ansible managed_nodes -m shell -a "vgdisplay"
ansible managed_nodes -m shell -a "lvdisplay"
```

#### **Service Management Problems**
```bash
# Check service status across nodes
ansible managed_nodes -m systemd -a "name=httpd state=started" --check

# View service logs
ansible web_servers -m shell -a "journalctl -u httpd --no-pager -n 20"
```

#### **Network and Firewall Issues**
```bash
# Test network connectivity
ansible all -m shell -a "ping -c 1 192.168.56.200"

# Check firewall rules
ansible managed_nodes -m shell -a "firewall-cmd --list-all"

# Verify port accessibility
ansible managed_nodes -m shell -a "ss -tuln | grep :80"
```

### Common Issues

#### 1. VM Won't Start
```bash
# Check Multipass VM status
multipass list

# Restart Multipass VM
multipass restart vagrant-primary

# Check VirtualBox inside VM
multipass exec vagrant-primary -- vboxmanage list vms
```

#### 2. Network Connectivity Issues
```bash
# Check VM network configuration
vagrant ssh control
ip addr show

# Test connectivity between VMs
ping 192.168.56.199  # repo
ping 192.168.56.201  # node1
```

#### 3. Storage Issues
```bash
# Check available space in Multipass VM
multipass exec vagrant-primary -- df -h

# Check VirtualBox disk usage
multipass exec vagrant-primary -- ls -la ~/vagrant-projects/rhel-lab/disk-*.vdi
```

#### 4. Performance Issues
- Increase Multipass VM resources:
  ```bash
  multipass stop vagrant-primary
  multipass set vagrant-primary --cpus 6
  multipass set vagrant-primary --memory 8G
  multipass start vagrant-primary
  ```

### Platform-Specific Issues

#### Windows
- **PowerShell Execution Policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Chocolatey Issues**: Restart PowerShell as Administrator after installation
- **Hyper-V Conflicts**: Disable Hyper-V if using VirtualBox

#### macOS
- **Homebrew Permissions**: Check ownership of `/opt/homebrew` (M1/M2) or `/usr/local` (Intel)
- **Security Permissions**: Allow Multipass in System Preferences > Security & Privacy
- **Rosetta 2**: May be needed for some Intel-based tools on Apple Silicon

#### Linux
- **Snap Installation**: Some distributions require manual snapd setup
- **Group Membership**: Log out and back in after installation for group changes
- **SELinux**: May need configuration on RHEL/CentOS systems

## Resource Requirements

### Minimum System Requirements
- **CPU**: 4 cores (8 cores recommended)
- **RAM**: 8GB (16GB recommended)
- **Storage**: 50GB free space (100GB recommended)
- **Network**: Internet connection for downloads

### Resource Allocation
- **Multipass VM**: 4 CPUs, 4GB RAM, 20GB disk
- **Each Vagrant VM**: 1-2GB RAM (repo=1GB, control=2GB, nodes=1GB each)
- **Total when all running**: ~12GB RAM, ~60GB disk

## Advanced Configuration

### Customizing VM Resources

Edit the Vagrantfile to modify VM resources:
```ruby
# Increase memory for specific VMs
config.vm.define "control" do |control|
  control.vm.provider :virtualbox do |vb|
    vb.memory = "4096"  # Change from 2048 to 4096
    vb.cpus = 2         # Add CPU configuration
  end
end
```

### Adding Additional VMs

Add new VM definitions to the Vagrantfile:
```ruby
config.vm.define "node6" do |node6|
  node6.vm.box = "rdbreak/rhel8node"
  node6.vm.network "private_network", ip: "192.168.56.206"
  node6.vm.provider "virtualbox" do |node6|
    node6.memory = "1024"
  end
end
```

### Custom Provisioning

Modify the Ansible playbooks in `playbooks/` directory to customize VM configuration.

## Security Considerations

- Default Vagrant SSH keys are used (insecure for production)
- VMs use default passwords where applicable
- Network is isolated to host-only adapter
- This environment is intended for lab/development use only

## RHCE Exam Preparation Tips

### 📚 **Study Strategy**
1. **Master Ansible fundamentals** - This is 60%+ of the exam
2. **Practice daily** - Consistency beats cramming
3. **Time management** - Practice with time limits
4. **Documentation skills** - Learn to read man pages quickly
5. **Error troubleshooting** - Practice debugging failed tasks

### ⏰ **Recommended Practice Schedule**
- **Week 1-2**: Basic Ansible (playbooks, modules, inventory)
- **Week 3-4**: Advanced Ansible (roles, variables, templates, vault)
- **Week 5-6**: System administration automation
- **Week 7-8**: Mock exams and time management

### 🎯 **Key RHCE Commands to Master**
```bash
# Ansible essentials
ansible-doc <module>              # Module documentation
ansible-playbook --syntax-check   # Validate syntax
ansible-playbook --check         # Dry run
ansible-vault create/edit/view    # Manage encrypted files
ansible-galaxy install           # Install roles

# System administration
systemctl status/start/stop/enable  # Service management
firewall-cmd --permanent --add-service  # Firewall rules
semanage fcontext -a -t           # SELinux contexts
lvextend/resize2fs/xfs_growfs     # Storage expansion
```

### 🚀 **Performance Optimization**
To improve VM performance during practice:
```bash
# Allocate more resources to Multipass VM
multipass stop vagrant-primary
multipass set vagrant-primary --cpus 8
multipass set vagrant-primary --memory 16G
multipass start vagrant-primary

# Or start fewer VMs for focused practice
vagrant up control repo node1 node2  # Only 4 VMs instead of 7
```

## Contributing to RHCE Practice Environment

### 🛠️ **Adding New Practice Scenarios**
1. Create new playbooks in `playbooks/` directory
2. Add inventory groups for specific scenarios
3. Document practice objectives and commands
4. Test scenarios across all managed nodes

### 📝 **Improving Documentation**
- Add more real-world RHCE scenarios
- Include timing guidelines for each task
- Provide sample exam questions
- Add troubleshooting guides

## Support and Resources

### 📖 **Official RHCE Resources**
- [Red Hat Training](https://www.redhat.com/en/training)
- [RHCE Exam Objectives](https://www.redhat.com/en/training/ex294-red-hat-certified-engineer-rhce-exam-red-hat-enterprise-linux-8)
- [Ansible Documentation](https://docs.ansible.com/)

### 🔗 **Additional Practice Resources**
- [Ansible Galaxy](https://galaxy.ansible.com/) - Community roles and collections
- [Red Hat Learning Community](https://learn.redhat.com/) - Free training materials
- [Practice Labs](https://lab.redhat.com/) - Browser-based practice

### 💬 **Community Support**
For issues, questions, or contributions:
1. Check the troubleshooting section above
2. Review official Red Hat documentation
3. Join RHCE study groups and forums
4. Open an issue in this repository

## Contributing

To contribute improvements:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## License and Disclaimer

This RHCE practice environment is provided for educational purposes only. It simulates exam conditions but does not guarantee exam success. Always refer to official Red Hat training materials and documentation for authoritative information.

**Good luck with your RHCE certification journey! 🎓🚀**

## Changelog

### v1.0
- Initial cross-platform setup scripts
- Support for Windows, macOS, and Linux
- Multipass-based virtualization
- Pre-configured RHEL 8 lab environment
- Ansible integration
- Storage configuration for lab exercises
- RHCE-focused practice scenarios and documentation
