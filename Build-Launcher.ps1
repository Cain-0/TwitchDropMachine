$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $root "Start-All-TwitchDropsMiner.cs"
$output = Join-Path $root "Start-All-TwitchDropsMiner.exe"
$icon = Join-Path $root "TwitchDropsMiner-dev\icons\pickaxe.ico"

$candidates = @(
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
    "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)

$csc = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $csc) {
    throw "csc.exe was not found. Install .NET Framework Developer Pack or Visual Studio Build Tools."
}

$args = @(
    "/nologo",
    "/target:winexe",
    "/optimize+",
    "/reference:System.Windows.Forms.dll",
    "/reference:System.Management.dll",
    "/out:$output"
)

if (Test-Path -LiteralPath $icon) {
    $args += "/win32icon:$icon"
}

$args += $source
& $csc @args

if (-not (Test-Path -LiteralPath $output)) {
    throw "Build failed: $output was not created."
}

Write-Host "Built: $output"
