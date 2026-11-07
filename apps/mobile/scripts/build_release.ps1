<#
.SYNOPSIS
  Automated Release Build Script for Ramez Tunnel Plus (Android)
.DESCRIPTION
  Performs pre-flight checks, runs code analysis, executes tests, and produces
  an obfuscated production Android App Bundle (AAB) with split debug symbols.
#>

param (
    [switch]$ApkOnly = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🚀 Ramez Tunnel Plus — Production Release Build Automation" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Pre-flight Checks
Write-Host "`n[1/4] Running Static Code Analysis (flutter analyze)..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter analyze failed! Resolve issues before building release."
}

# 2. Test Suite
Write-Host "`n[2/4] Executing Mobile Automated Test Suite..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed! Release aborted."
}

# 3. Clean and prepare symbols directory
Write-Host "`n[3/4] Preparing output and symbol directories..." -ForegroundColor Yellow
$SymbolsDir = "./build/app/outputs/symbols"
if (-not (Test-Path $SymbolsDir)) {
    New-Item -ItemType Directory -Force -Path $SymbolsDir | Out-Null
}

# 4. Build Artifacts
if ($ApkOnly) {
    Write-Host "`n[4/4] Building Obfuscated Split-ABI Release APKs..." -ForegroundColor Green
    flutter build apk --release `
        --split-per-abi `
        --obfuscate `
        --split-debug-info=$SymbolsDir `
        --target=lib/main_prod.dart
    Write-Host "`n✅ Release APKs built successfully in build/app/outputs/flutter-apk/" -ForegroundColor Green
} else {
    Write-Host "`n[4/4] Building Obfuscated Production Android App Bundle (AAB)..." -ForegroundColor Green
    flutter build appbundle --release `
        --obfuscate `
        --split-debug-info=$SymbolsDir `
        --target=lib/main_prod.dart
    Write-Host "`n✅ Production App Bundle (AAB) built successfully in build/app/outputs/bundle/release/" -ForegroundColor Green
}

Write-Host "Symbols preserved in: $SymbolsDir (upload to Play Console for de-obfuscation)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
