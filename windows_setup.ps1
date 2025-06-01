# Windows Setup Script for Multipass Vagrant Environment
# Run as Administrator

param(
    [switch]$Force
)

Write-Host "Setting up Vagrant Multi-VM Environment on Windows..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator. Please run PowerShell as Administrator and try again."
    exit 1
}

# Function to check if a command exists
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function to download file with progress
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    Write-Host "Downloading from: $Url" -ForegroundColor Yellow
    Write-Host "Saving to: $OutputPath" -ForegroundColor Yellow
    
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($Url, $OutputPath)
}

# Function to install Multipass from official installer
function Install-Multipass {
    if (Test-Command multipass) {
        Write-Host "Multipass already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Multipass from official installer..." -ForegroundColor Yellow
    
    # Create temp directory
    $tempDir = "$env:TEMP\multipass-installer"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    # Download the latest Multipass installer
    $installerPath = "$tempDir\multipass-installer.exe"
    $downloadUrl = "https://github.com/canonical/multipass/releases/latest/download/multipass-1.15.1+win-win64.exe"
    
    try {
        Write-Host "Downloading Multipass installer..." -ForegroundColor Yellow
        # Use Invoke-WebRequest for better progress indication
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
        
        if (-not (Test-Path $installerPath)) {
            throw "Failed to download Multipass installer"
        }
        
        Write-Host "Running Multipass installer..." -ForegroundColor Yellow
        Write-Host "Please follow the installer prompts to complete installation." -ForegroundColor Cyan
        
        # Run installer and wait for completion
        $process = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Multipass installer completed successfully." -ForegroundColor Green
        } else {
            throw "Multipass installer failed with exit code: $($process.ExitCode)"
        }
        
        # Add Multipass to PATH if not already there
        $multipassPath = "${env:ProgramFiles}\Multipass\bin"
        $currentPath = $env:PATH
        if ($currentPath -notlike "*$multipassPath*") {
            Write-Host "Adding Multipass to system PATH..." -ForegroundColor Yellow
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$multipassPath", [EnvironmentVariableTarget]::Machine)
            $env:PATH = "$env:PATH;$multipassPath"
        }
        
        # Clean up installer
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        
    } catch {
        Write-Error "Failed to install Multipass: $_"
        throw
    }
}

# Main installation process
try {
    Install-Multipass

    # Verify installation
    Write-Host "Verifying Multipass installation..." -ForegroundColor Yellow
    
    # Refresh environment variables
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    
    # Wait a moment for installation to complete
    Start-Sleep -Seconds 5
    
    if (Test-Command multipass) {
        $multipassVersion = multipass version
        Write-Host "Multipass installed successfully: $multipassVersion" -ForegroundColor Green
    } else {
        Write-Warning "Multipass command not found in PATH. You may need to restart your terminal."
        Write-Host "Multipass should be installed at: ${env:ProgramFiles}\Multipass\bin\multipass.exe" -ForegroundColor Yellow
        
        # Try direct path
        $multipassExe = "${env:ProgramFiles}\Multipass\bin\multipass.exe"
        if (Test-Path $multipassExe) {
            Write-Host "Found Multipass at: $multipassExe" -ForegroundColor Green
            $multipassVersion = & $multipassExe version
            Write-Host "Version: $multipassVersion" -ForegroundColor Green
        } else {
            throw "Multipass installation verification failed"
        }
    }

    # Create project directory
    $projectDir = "$env:USERPROFILE\vagrant-multipass-lab"
    if (-not (Test-Path $projectDir)) {
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        Write-Host "Created project directory: $projectDir" -ForegroundColor Green
    }

    # Check if setup-vm.sh exists in current directory
    $localSetupScript = ".\setup-vm.sh"
    if (-not (Test-Path $localSetupScript)) {
        Write-Error "setup-vm.sh not found in current directory!"
        Write-Host "Please ensure setup-vm.sh is in the same directory as this Windows setup script." -ForegroundColor Yellow
        Write-Host "Expected location: $(Get-Location)\setup-vm.sh" -ForegroundColor Yellow
        throw "Required setup-vm.sh script not found"
    }

    Write-Host "Found local setup-vm.sh script" -ForegroundColor Green

    # Launch primary Multipass VM for Vagrant
    Write-Host "Setting up Multipass VM for Vagrant environment..." -ForegroundColor Yellow
    
    # Use direct path if multipass not in PATH
    $multipassCmd = if (Test-Command multipass) { "multipass" } else { "${env:ProgramFiles}\Multipass\bin\multipass.exe" }
    
    # Check if VM already exists
    $existingVMs = & $multipassCmd list --format csv | ConvertFrom-Csv
    $vmExists = $existingVMs | Where-Object { $_.Name -eq "vagrant-primary" }
    
    if ($vmExists -and -not $Force) {
        Write-Host "VM 'vagrant-primary' already exists. Use -Force to recreate." -ForegroundColor Yellow
    } else {
        if ($vmExists) {
            Write-Host "Stopping and deleting existing VM..." -ForegroundColor Yellow
            & $multipassCmd stop vagrant-primary
            & $multipassCmd delete vagrant-primary
            & $multipassCmd purge
        }
        
        # Launch new VM with Ubuntu 20.04 (good Vagrant support)
        Write-Host "Launching Ubuntu 20.04 VM with 4 CPUs, 4GB RAM, 20GB disk..." -ForegroundColor Yellow
        & $multipassCmd launch 20.04 --name vagrant-primary --cpus 4 --memory 4G --disk 20G
        
        # Wait for VM to be ready
        Write-Host "Waiting for VM to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        # Transfer the local setup script directly to VM
        Write-Host "Transferring local setup-vm.sh script to VM..." -ForegroundColor Yellow
        & $multipassCmd transfer $localSetupScript vagrant-primary:/tmp/setup-vm.sh
        
        Write-Host "Making setup script executable..." -ForegroundColor Yellow
        & $multipassCmd exec vagrant-primary -- chmod +x /tmp/setup-vm.sh
        
        Write-Host "Executing setup script in VM (this may take several minutes)..." -ForegroundColor Yellow
        $setupResult = & $multipassCmd exec vagrant-primary -- /tmp/setup-vm.sh
        
        # Check if setup was successful
        $setupExitCode = $LASTEXITCODE
        if ($setupExitCode -eq 0) {
            Write-Host "VM setup completed successfully!" -ForegroundColor Green
        } else {
            Write-Error "VM setup failed with exit code: $setupExitCode"
            Write-Host "Setup output:" -ForegroundColor Yellow
            Write-Host $setupResult
            throw "VM setup failed"
        }
    }

    # Create Windows helper scripts
    Write-Host "Creating helper scripts..." -ForegroundColor Yellow
    
    # Create VM access script
    $accessScriptPath = "$projectDir\access-vm.ps1"
    $accessScriptContent = @"
# Quick access script for the Multipass VM
Write-Host "Accessing Vagrant lab environment..." -ForegroundColor Green
Write-Host "Use 'exit' to return to Windows host" -ForegroundColor Yellow
Write-Host ""

# Use full path if multipass not in PATH
`$multipassCmd = if (Get-Command multipass -ErrorAction SilentlyContinue) { "multipass" } else { "`${env:ProgramFiles}\Multipass\bin\multipass.exe" }

& `$multipassCmd shell vagrant-primary
"@
    Set-Content -Path $accessScriptPath -Value $accessScriptContent -Encoding UTF8

    # Create VM management script
    $manageScriptPath = "$projectDir\manage-vm.ps1"
    $manageScriptContent = @"
# VM Management Script for Multipass
param(
    [Parameter(Mandatory=`$true)]
    [ValidateSet("start", "stop", "restart", "status", "info", "shell", "mount", "unmount")]
    [string]`$Action,
    
    [string]`$Path
)

`$vmName = "vagrant-primary"
`$multipassCmd = if (Get-Command multipass -ErrorAction SilentlyContinue) { "multipass" } else { "`${env:ProgramFiles}\Multipass\bin\multipass.exe" }

switch (`$Action) {
    "start" {
        Write-Host "Starting VM: `$vmName" -ForegroundColor Yellow
        & `$multipassCmd start `$vmName
    }
    "stop" {
        Write-Host "Stopping VM: `$vmName" -ForegroundColor Yellow
        & `$multipassCmd stop `$vmName
    }
    "restart" {
        Write-Host "Restarting VM: `$vmName" -ForegroundColor Yellow
        & `$multipassCmd restart `$vmName
    }
    "status" {
        Write-Host "VM Status:" -ForegroundColor Yellow
        & `$multipassCmd list
    }
    "info" {
        Write-Host "VM Information:" -ForegroundColor Yellow
        & `$multipassCmd info `$vmName
    }
    "shell" {
        Write-Host "Accessing VM shell:" -ForegroundColor Yellow
        & `$multipassCmd shell `$vmName
    }
    "mount" {
        if (-not `$Path) {
            Write-Error "Path parameter required for mount action"
            Write-Host "Usage: .\manage-vm.ps1 mount -Path C:\path\to\directory"
            exit 1
        }
        Write-Host "Mounting `$Path to VM..." -ForegroundColor Yellow
        & `$multipassCmd mount `$Path "`$vmName:/mnt/host"
    }
    "unmount" {
        Write-Host "Unmounting host directories..." -ForegroundColor Yellow
        & `$multipassCmd umount `$vmName
    }
}
"@
    Set-Content -Path $manageScriptPath -Value $manageScriptContent -Encoding UTF8

    Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
    Write-Host "Project directory: $projectDir" -ForegroundColor Cyan
    Write-Host "`nFile Structure:" -ForegroundColor Yellow
    Write-Host "Repository files:" -ForegroundColor White
    Write-Host "  ├── windows-setup.ps1            # This script" -ForegroundColor White
    Write-Host "  ├── macos-setup.sh               # macOS setup script" -ForegroundColor White
    Write-Host "  ├── linux-setup.sh               # Linux setup script" -ForegroundColor White
    Write-Host "  └── setup-vm.sh                  # VM setup script (transferred to VM)" -ForegroundColor White
    Write-Host "`nQuick Start:" -ForegroundColor Yellow
    Write-Host "1. Open a new PowerShell window (to refresh environment)" -ForegroundColor White
    Write-Host "2. cd `"$projectDir`"" -ForegroundColor White
    Write-Host "3. .\access-vm.ps1                    # Access the VM" -ForegroundColor White
    Write-Host "4. cd ~/vagrant-projects/rhel-lab     # Inside VM" -ForegroundColor White
    Write-Host "5. ./start-lab.sh                     # Start Vagrant VMs" -ForegroundColor White
    Write-Host "`nVM Management:" -ForegroundColor Yellow
    Write-Host ".\manage-vm.ps1 status                # Check VM status" -ForegroundColor White
    Write-Host ".\manage-vm.ps1 start                 # Start VM" -ForegroundColor White
    Write-Host ".\manage-vm.ps1 stop                  # Stop VM" -ForegroundColor White
    Write-Host ".\manage-vm.ps1 mount -Path C:\your\path  # Mount directory" -ForegroundColor White
    Write-Host "`nInside the VM (after running access-vm.ps1):" -ForegroundColor Yellow
    Write-Host "cd ~/vagrant-projects/rhel-lab" -ForegroundColor White
    Write-Host "./start-lab.sh                        # Start all lab VMs" -ForegroundColor White
    Write-Host "vagrant status                        # Check lab VM status" -ForegroundColor White
    Write-Host "vagrant ssh control                   # SSH to control VM" -ForegroundColor White

} catch {
    Write-Error "Setup failed: $_"
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure you're running as Administrator" -ForegroundColor White
    Write-Host "2. Check Windows version compatibility" -ForegroundColor White
    Write-Host "3. Verify Hyper-V is disabled if using VirtualBox" -ForegroundColor White
    Write-Host "4. Try restarting PowerShell after installation" -ForegroundColor White
    exit 1
}
