[Setup]
AppName=DISCOM Bill Manager
AppVersion=1.0.0
DefaultDirName={localappdata}\DISCOM Bill Manager
DefaultGroupName=DISCOM Bill Manager
OutputDir=installer
OutputBaseFilename=DISCOMBillManager_Setup
Compression=lzma
SolidCompression=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=none

[Files]
; ---- Flutter Windows Build Folder ----
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Required VC++ Runtime DLLs ----
Source: "installer_runtime\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer_runtime\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer_runtime\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer_runtime\concrt140.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\DISCOM Bill Manager"; Filename: "{app}\discom_bill_manager.exe"
Name: "{userdesktop}\DISCOM Bill Manager"; Filename: "{app}\discom_bill_manager.exe"

[Run]
Filename: "{app}\discom_bill_manager.exe"; Description: "Launch DISCOM Bill Manager"; Flags: nowait postinstall skipifsilent
