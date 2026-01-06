# DISCOM Bill Manager - Uninstall Script
# This script removes the DISCOM Bill Manager application

Write-Host "DISCOM Bill Manager - Uninstall Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
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

try {
    # Find and remove the package
    $package = Get-AppxPackage | Where-Object { $_.Name -like "*discom*" -or $_.Name -like "*billmanager*" }
    
    if ($package) {
        Write-Host "Found: $($package.Name)" -ForegroundColor Yellow
        Write-Host "Removing application..." -ForegroundColor Green
        
        Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
        
        Write-Host "✓ DISCOM Bill Manager uninstalled successfully!" -ForegroundColor Green
    } else {
        Write-Host "DISCOM Bill Manager is not installed." -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Failed to uninstall: $_" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
