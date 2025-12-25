# Flutter Clean Fix Script
# This script kills Flutter/Dart processes and cleans the project

Write-Host "Fixing Flutter clean issue..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill Flutter/Dart processes
Write-Host "Step 1: Stopping any running Flutter/Dart processes..." -ForegroundColor Yellow
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Remove locked directories
Write-Host "Step 2: Removing locked directories..." -ForegroundColor Yellow
Set-Location -Path "frontend"

$buildPath = Join-Path $PWD "build"
$dartToolPath = Join-Path $PWD ".dart_tool"

if (Test-Path $buildPath) {
    Write-Host "Removing build directory..." -ForegroundColor Yellow
    try {
        Remove-Item -Path $buildPath -Recurse -Force -ErrorAction Stop
        Write-Host "Build directory removed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not remove build directory: $_" -ForegroundColor Red
        Write-Host "You may need to close any programs using these files (IDE, file explorer, etc.)" -ForegroundColor Yellow
    }
}

if (Test-Path $dartToolPath) {
    Write-Host "Removing .dart_tool directory..." -ForegroundColor Yellow
    try {
        Remove-Item -Path $dartToolPath -Recurse -Force -ErrorAction Stop
        Write-Host ".dart_tool directory removed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not remove .dart_tool directory: $_" -ForegroundColor Red
        Write-Host "You may need to close any programs using these files (IDE, file explorer, etc.)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Step 3: Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "Clean process completed!" -ForegroundColor Green
Set-Location -Path ".."

