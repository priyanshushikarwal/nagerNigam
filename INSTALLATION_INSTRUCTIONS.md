# DISCOM Bill Manager - Installation Instructions

## System Requirements

### Required Software (Must Install First!)
Before running DISCOM Bill Manager, you **MUST** install:

**Microsoft Visual C++ Redistributable (x64)**
- Download: https://aka.ms/vs/17/release/vc_redist.x64.exe
- This is a free Microsoft component required for all Flutter Windows apps
- Size: ~25 MB
- Installation time: 1-2 minutes

### Operating System
- Windows 10 (version 1809 or later) or Windows 11
- 64-bit version required

## Installation Steps

### 1. Install Visual C++ Redistributable (CRITICAL!)
1. Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
2. Run the installer
3. Click "Install"
4. Restart your computer if prompted

### 2. Install DISCOM Bill Manager
1. Extract `discom_bill_manager_windows.zip`
2. Copy the entire extracted folder to: `C:\Users\YOUR_USERNAME\AppData\Local\DISCOM Bill Manager\`
3. Run `discom_bill_manager.exe`

## Troubleshooting

### Error: "MSVCP140.dll was not found"
**Solution:** Install Visual C++ Redistributable (see link above)

### Error: "VCRUNTIME140.dll was not found"  
**Solution:** Install Visual C++ Redistributable (see link above)

### Updates Not Installing
1. Make sure you're running the app from: `%LOCALAPPDATA%\DISCOM Bill Manager\`
2. Not from the Downloads folder or Desktop
3. Check `update_log.txt` in the install folder for errors

### App Won't Start
1. Check Windows Event Viewer for error details
2. Ensure antivirus isn't blocking the app
3. Try running as administrator once

## Auto-Update System

The app includes automatic updates:
1. Go to Settings → Check for Updates
2. If an update is available, click "Update Now"
3. The app will download, install, and restart automatically
4. All your data (database, files) is preserved during updates

## Support

If you encounter issues:
1. Check `update_log.txt` in `%LOCALAPPDATA%\DISCOM Bill Manager\`
2. Note any error messages
3. Contact support with the log file

---

**Important:** Always run the app from the installed location (`%LOCALAPPDATA%\DISCOM Bill Manager\`), not from temporary folders!
