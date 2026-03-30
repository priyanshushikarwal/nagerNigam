import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';

/// Service to handle downloading and installing ZIP-based updates
class UpdaterService {
  /// Get the LocalAppData install directory
  static String getInstallDir() {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData == null || localAppData.isEmpty) {
      throw Exception('LOCALAPPDATA not found');
    }
    return path.join(localAppData, 'DISCOM Bill Manager');
  }

  /// Get the installed EXE path
  static String getExePath() {
    return path.join(getInstallDir(), 'discom_bill_manager.exe');
  }

  static bool _isZipPackage(File file) {
    return path.extension(file.path).toLowerCase() == '.zip';
  }

  /// Downloads ZIP file with progress reporting
  Stream<double> downloadUpdate(
    String zipUrl,
    void Function(File file) onComplete,
    void Function(String error) onError,
  ) async* {
    try {
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFile = File(
        path.join(tempDir.path, 'discom_update_$timestamp.zip'),
      );

      final request = http.Request('GET', Uri.parse(zipUrl));
      final response = await request.send();

      if (response.statusCode != 200) {
        onError('Download failed: ${response.statusCode}');
        return;
      }

      final contentLength = response.contentLength ?? 0;
      var downloaded = 0;
      final sink = zipFile.openWrite();

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          downloaded += chunk.length;

          if (contentLength > 0) {
            yield (downloaded / contentLength);
          }
        }

        await sink.flush();
        await sink.close();
        onComplete(zipFile);
      } catch (e) {
        await sink.close();
        onError('Download error: $e');
      }
    } catch (e) {
      onError('Download failed: $e');
    }
  }

  /// Installs the update: extracts ZIP, writes PowerShell script, launches it, exits app
  Future<void> installUpdateAndRestart(File zipFile) async {
    try {
      final installDir = getInstallDir();
      final exePath = getExePath();

      final tempDir = Directory.systemTemp;
      final extractDir = Directory(
        path.join(
          tempDir.path,
          'discom_extract_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      await extractDir.create(recursive: true);

      if (_isZipPackage(zipFile)) {
        await extractFileToDisk(zipFile.path, extractDir.path);
      } else {
        final targetFile = File(path.join(extractDir.path, 'discom_bill_manager.exe'));
        await zipFile.copy(targetFile.path);
      }

      // Generate PowerShell updater script
      final scriptContent = _generatePowerShellScript(
        exePath,
        installDir,
        extractDir.path,
      );

      // Write script to temp
      final scriptFile = File(
        path.join(
          tempDir.path,
          'updater_${DateTime.now().millisecondsSinceEpoch}.ps1',
        ),
      );
      await scriptFile.writeAsString(scriptContent);

      // Launch PowerShell via cmd.exe to truly detach from parent process
      // This prevents Windows from killing the script when the app exits
      await Process.start('cmd.exe', [
        '/c',
        'start',
        '/min',
        'powershell.exe',
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-File',
        scriptFile.path,
      ], mode: ProcessStartMode.detached);

      // Give cmd.exe time to spawn PowerShell
      await Future.delayed(const Duration(seconds: 3));

      // Exit app to allow update
      exit(0);
    } catch (e) {
      throw Exception('Install failed: $e');
    }
  }

  /// Generates PowerShell updater script
  String _generatePowerShellScript(
    String exePath,
    String installDir,
    String extractPath,
  ) {
    // Escape paths for PowerShell
    final psExe = exePath.replaceAll('\\', '\\\\');
    final psInstall = installDir.replaceAll('\\', '\\\\');
    final psExtract = extractPath.replaceAll('\\', '\\\\');

    return '''
# DISCOM Bill Manager Auto-Updater
\$ErrorActionPreference = "Stop"

\$exePath = "$psExe"
\$installDir = "$psInstall"
\$extractPath = "$psExtract"
\$logFile = Join-Path \$installDir "update_log.txt"

function Log {
    param([string]\$msg)
    \$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    \$line = "[\$ts] \$msg"
    Add-Content -Path \$logFile -Value \$line -ErrorAction SilentlyContinue
    Write-Host \$line
}

Log "========================================="
Log "DISCOM Bill Manager Update Started"
Log "========================================="
Log "EXE Path: \$exePath"
Log "Install Dir: \$installDir"
Log "Extract Path: \$extractPath"

# Verify extract path exists
if (-not (Test-Path \$extractPath)) {
    Log "ERROR: Extract path not found"
    exit 1
}

# Wait for app to close and ensure it's fully terminated
Log "Waiting for app to close..."
\$processName = "discom_bill_manager"
\$maxWait = 60

for (\$i = 0; \$i -lt \$maxWait; \$i++) {
    \$proc = Get-Process -Name \$processName -ErrorAction SilentlyContinue
    if (\$null -eq \$proc) {
        Log "App closed"
        break
    }
    Start-Sleep -Milliseconds 500
}

if (\$i -ge \$maxWait) {
    Log "Timeout - forcing close"
    Get-Process -Name \$processName -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# Extra wait and kill any remaining processes
Start-Sleep -Seconds 2
Get-Process -Name \$processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Log "All app processes terminated"

# Create backup
\$backupDir = "\${installDir}_backup_\$(Get-Date -Format 'yyyyMMddHHmmss')"
Log "Creating backup: \$backupDir"
try {
    if (Test-Path \$installDir) {
        Copy-Item -Path \$installDir -Destination \$backupDir -Recurse -Force
        Log "Backup created"
    }
} catch {
    Log "WARNING: Backup failed: \$_"
}

# Delete old files (preserve .db files and /files/ folder)
Log "Removing old files..."
try {
    Get-ChildItem -Path \$installDir -Recurse -File | Where-Object {
        \$_.Extension -ne ".db" -and 
        \$_.FullName -notlike "*\\files\\*" -and
        \$_.Name -ne "update_log.txt"
    } | Remove-Item -Force -ErrorAction SilentlyContinue
} catch {
    Log "WARNING: Cleanup failed: \$_"
}

# Copy new files using robocopy (handles paths correctly)
Log "Copying new files..."
try {
    # Use robocopy for reliable file copying
    \$robocopyArgs = @(
        \$extractPath,
        \$installDir,
        "*.*",
        "/E",           # Copy subdirectories including empty
        "/XF", "*.db",  # Exclude database files
        "/XD", "files", # Exclude files folder
        "/R:2",         # Retry 2 times
        "/W:1",         # Wait 1 second between retries
        "/NJH", "/NJS", "/NDL", "/NC", "/NS"  # Minimize output
    )
    
    \$result = robocopy @robocopyArgs
    \$exitCode = \$LASTEXITCODE
    
    # Robocopy exit codes: 0-7 are success, 8+ are errors
    if (\$exitCode -ge 8) {
        throw "Robocopy failed with exit code \$exitCode"
    }
    
    Log "Files copied successfully (robocopy exit code: \$exitCode)"
} catch {
    Log "ERROR: Copy failed: \$_"
    
    # Restore backup
    if (Test-Path \$backupDir) {
        Log "Restoring backup..."
        Remove-Item -Path \$installDir -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path \$backupDir -Destination \$installDir -Recurse -Force
        Log "Backup restored"
    }
    exit 1
}

# Clean up
Log "Cleaning up..."
Remove-Item -Path \$extractPath -Recurse -Force -ErrorAction SilentlyContinue
if (Test-Path \$backupDir) {
    Remove-Item -Path \$backupDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Launch updated app
Log "Launching updated app..."
try {
    # Final check - kill any lingering processes
    Get-Process -Name \$processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Verify no processes are running
    \$check = Get-Process -Name \$processName -ErrorAction SilentlyContinue
    if (\$check) {
        Log "WARNING: Process still running, killing again"
        \$check | Stop-Process -Force
        Start-Sleep -Seconds 1
    }
    
    # Launch with explicit parameters
    \$process = Start-Process -FilePath \$exePath -WorkingDirectory \$installDir -PassThru
    
    if (\$process) {
        Log "App launched successfully (PID: \$(\$process.Id))"
    } else {
        Log "WARNING: Start-Process returned null"
    }
} catch {
    Log "ERROR: Launch failed: \$_"
    
    # Check if error is due to missing DLL
    if (\$_.Exception.Message -like "*MSVCP140*" -or \$_.Exception.Message -like "*VCRUNTIME140*") {
        Log "Missing Visual C++ Runtime detected"
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show(
            "Microsoft Visual C++ Redistributable is missing!`n`nDownload: https://aka.ms/vs/17/release/vc_redist.x64.exe",
            "Launch Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    exit 1
}

# Self-delete
Start-Sleep -Seconds 3
Remove-Item -Path \$PSCommandPath -Force -ErrorAction SilentlyContinue

Log "========================================="
Log "Update Complete"
Log "========================================="
exit 0
''';
  }
}
