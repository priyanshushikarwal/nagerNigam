# DISCOM Bill Manager - Installation Guide

## Quick Installation (Recommended)

### Method 1: Automated Script
1. **Right-click** on `install_msix.ps1`
2. Select **"Run with PowerShell"** or **"Run as Administrator"**
3. The script will:
   - Install the certificate to Trusted Root
   - Install the MSIX application
4. Find the app in your Start Menu

---

## Manual Installation

If the automated script doesn't work, follow these steps:

### Step 1: Install Certificate

1. **Open PowerShell as Administrator**
   - Press `Win + X`
   - Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Run this command:**
   ```powershell
   $password = ConvertTo-SecureString -String "1234" -Force -AsPlainText
   Import-PfxCertificate -FilePath "C:\discom_cert.pfx" -CertStoreLocation Cert:\LocalMachine\Root -Password $password
   ```

3. **You should see:** Certificate thumbprint displayed

### Step 2: Install MSIX Package

1. **In the same PowerShell window, run:**
   ```powershell
   Add-AppxPackage -Path "C:\Users\Pri yanshu\Desktop\nagerNigam\discom_bill_manager\build\windows\x64\runner\Release\discom_bill_manager.msix"
   ```

2. **Wait for installation to complete**

3. **Launch the app** from Start Menu

---

## Troubleshooting

### Issue: "Nothing happens when I click the MSIX"
**Solution:** The certificate is not in Trusted Root. Use the PowerShell commands above.

### Issue: "This app can't run on your PC"
**Solution:** 
1. Check Windows version (Windows 10 1809+ or Windows 11 required)
2. Enable Developer Mode:
   - Settings → Privacy & Security → For developers
   - Turn on "Developer Mode"

### Issue: "Installation failed"
**Solution:**
1. Uninstall old version first:
   ```powershell
   # Run as Administrator
   Get-AppxPackage | Where-Object { $_.Name -like "*discom*" } | Remove-AppxPackage
   ```
2. Try installing again

### Issue: Certificate already exists error
**Solution:** Certificate is already installed, just install the MSIX directly:
```powershell
Add-AppxPackage -Path ".\build\windows\x64\runner\Release\discom_bill_manager.msix"
```

---

## Uninstallation

### Method 1: Using Script
1. Right-click `uninstall_msix.ps1`
2. Select "Run as Administrator"

### Method 2: Windows Settings
1. Settings → Apps → Installed apps
2. Search for "DISCOM Bill Manager"
3. Click "..." → Uninstall

### Method 3: PowerShell
```powershell
Get-AppxPackage | Where-Object { $_.Name -like "*discom*" } | Remove-AppxPackage
```

---

## Distribution to Other Computers

When sharing the MSIX with other users:

1. **Copy these files:**
   - `discom_bill_manager.msix` (from build\windows\x64\runner\Release)
   - `C:\discom_cert.pfx`
   - `install_msix.ps1` (optional, for easy installation)

2. **On the new computer:**
   - Place both files
   - Run `install_msix.ps1` as Administrator
   - OR follow manual installation steps

---

## Notes

- **Certificate Password:** 1234
- **Publisher:** CN=DISCOM Bill Manager
- **Package Name:** com.discom.billmanager
- **First Launch:** May take 10-15 seconds to initialize the database

---

## Support

If you encounter issues:
1. Check Windows Event Viewer → Application logs
2. Try running in Developer Mode
3. Ensure .NET Framework is installed
4. Check Windows Update is current
