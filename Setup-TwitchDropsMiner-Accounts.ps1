$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoUrl = "https://github.com/Davixk/TwitchDropsMiner/archive/refs/heads/dev.zip"
$zipPath = Join-Path $root "TwitchDropsMiner-dev.zip"
$temp = Join-Path $root "_download"
$accounts = @(
    "TwitchDropsMiner-dev",
    "TwitchDropsMiner-account2",
    "TwitchDropsMiner-account3",
    "TwitchDropsMiner-account4"
)

$settings = @'
{
    "autostart_tray": false,
    "available_drops_check": true,
    "connection_quality": 1,
    "dark_mode": false,
    "enable_badges_emotes": false,
    "exclude": {
        "__type": "set",
        "data": []
    },
    "language": "English",
    "prioritize_by_ending_soonest": false,
    "priority": [],
    "priority_mode": {
        "__type": "PriorityMode",
        "data": 1
    },
    "proxy": {
        "__type": "URL",
        "data": ""
    },
    "tray_notifications": true
}
'@

function Write-Utf8NoBom($Path, $Content) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Patch-TwitchDropsMiner($Folder) {
    $utilsPath = Join-Path $Folder "utils.py"
    $guiPath = Join-Path $Folder "gui.py"

    if (Test-Path -LiteralPath $utilsPath) {
        $content = Get-Content -LiteralPath $utilsPath -Raw
        $content = $content.Replace('encoding="utf8") as file:', 'encoding="utf-8-sig") as file:')
        Write-Utf8NoBom $utilsPath $content
    }

    if (Test-Path -LiteralPath $guiPath) {
        $content = Get-Content -LiteralPath $guiPath -Raw
        if ($content -notmatch 'self\.always_show_icon = False') {
            $content = $content.Replace('self.icon = None', "self.icon = None`r`n        self.always_show_icon = False")
        }
        $old = @'
    def minimize(self):
        if self.icon is None:
            self._start()
        else:
            self.icon.visible = True
        self._manager._root.withdraw()
'@
        $new = @'
    def minimize(self):
        self._manager._root.iconify()
'@
        $content = $content.Replace($old, $new)
        Write-Utf8NoBom $guiPath $content
    }
}

function Setup-Account($Folder) {
    New-Item -ItemType Directory -Path (Join-Path $Folder "config") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Folder "cache") -Force | Out-Null
    Write-Utf8NoBom (Join-Path $Folder "config\settings.json") $settings
    Patch-TwitchDropsMiner $Folder

    if (-not (Test-Path -LiteralPath (Join-Path $Folder "env\Scripts\python.exe"))) {
        py -3.12 -m venv (Join-Path $Folder "env")
    }

    & (Join-Path $Folder "env\Scripts\python.exe") -m pip install -U pip
    & (Join-Path $Folder "env\Scripts\pip.exe") install wheel
    & (Join-Path $Folder "env\Scripts\pip.exe") install -r (Join-Path $Folder "requirements.txt")
}

if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
    throw "Python Launcher 'py' was not found. Install Python 3.12+ first."
}

if (Test-Path -LiteralPath $temp) {
    Remove-Item -LiteralPath $temp -Recurse -Force
}
New-Item -ItemType Directory -Path $temp -Force | Out-Null

Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $temp -Force
$downloaded = Join-Path $temp "TwitchDropsMiner-dev"

foreach ($account in $accounts) {
    $target = Join-Path $root $account
    if (-not (Test-Path -LiteralPath $target)) {
        Copy-Item -LiteralPath $downloaded -Destination $target -Recurse
    }
    Setup-Account $target
}

Remove-Item -LiteralPath $temp -Recurse -Force
Write-Host "Done. Log in separately in each TwitchDropsMiner window after running Start-All-TwitchDropsMiner.exe."
