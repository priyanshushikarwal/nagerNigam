# DISCOM Bill Manager - MSIX Installation Script
# This script installs the certificate and then installs the MSIX package

Write-Host "DISCOM Bill Manager - Installation Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on this script and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Certificate and MSIX paths
$certPath = "C:\discom_cert.pfx"
$certPassword = "1234"
$msixPath = "$PSScriptRoot\build\windows\x64\runner\Release\discom_bill_manager.msix"

# Check if certificate exists
if (-not (Test-Path $certPath)) {
    Write-Host "ERROR: Certificate not found at: $certPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if MSIX exists
if (-not (Test-Path $msixPath)) {
    Write-Host "ERROR: MSIX package not found at: $msixPath" -ForegroundColor Red
    Write-Host "Please run 'dart run msix:create' first to build the MSIX package." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Step 1: Installing certificate to Trusted Root..." -ForegroundColor Green

try {
    # Convert password to secure string
    $securePassword = ConvertTo-SecureString -String $certPassword -Force -AsPlainText
    
    # Import certificate to Trusted Root Certification Authorities
    Import-PfxCertificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root -Password $securePassword -ErrorAction Stop | Out-Null
    
    Write-Host "  ✓ Certificate installed successfully!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "  ✗ Failed to install certificate: $_" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Step 2: Installing DISCOM Bill Manager..." -ForegroundColor Green

try {
    # Install the MSIX package
    Add-AppxPackage -Path $msixPath -ErrorAction Stop
    
    Write-Host "  ✓ DISCOM Bill Manager installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation Complete!" -ForegroundColor Cyan
    Write-Host "You can now find 'DISCOM Bill Manager' in your Start Menu." -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "  ✗ Failed to install MSIX: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "  1. Make sure Windows is updated" -ForegroundColor White
    Write-Host "  2. Enable Developer Mode in Windows Settings" -ForegroundColor White
    Write-Host "  3. Try uninstalling the old version first" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Read-Host "Press Enter to exit"
