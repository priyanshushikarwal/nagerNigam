# Script to copy Visual C++ Runtime DLLs to the build output
$releasePath = "build\windows\x64\runner\Release"
$runtimePath = "windows\runtime_dlls"

if (Test-Path $releasePath) {
    Write-Host "Copying Visual C++ Runtime DLLs to release folder..."
    
    $dlls = @("msvcp140.dll", "vcruntime140.dll", "vcruntime140_1.dll", "concrt140.dll")
    
    foreach ($dll in $dlls) {
        $source = Join-Path $runtimePath $dll
        if (Test-Path $source) {
            Copy-Item $source $releasePath -Force
            Write-Host "  ✓ Copied $dll"
        } else {
            Write-Host "  ✗ Missing $dll in $runtimePath"
        }
    }
    
    Write-Host "Runtime DLLs copied successfully!"
} else {
    Write-Host "Release folder not found. Build the app first."
    exit 1
}
