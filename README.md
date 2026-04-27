# TwitchDropsMiner Multi-Account Launcher

Small Windows launcher that starts four local TwitchDropsMiner instances at once.

## Included

- `Start-All-TwitchDropsMiner.cs` - source code for the launcher.
- `Build-Launcher.ps1` - builds `Start-All-TwitchDropsMiner.exe` locally on Windows.
- `Setup-TwitchDropsMiner-Accounts.ps1` - recreates the four local account folders without storing Twitch sessions in Git.
- `.gitignore` - prevents local Twitch login/session data from being committed.

## Build The Launcher

```powershell
powershell -ExecutionPolicy Bypass -File .\Build-Launcher.ps1
```

This creates:

```text
Start-All-TwitchDropsMiner.exe
```

## Expected Folder Layout

Put the launcher next to these folders:

```text
Start-All-TwitchDropsMiner.exe
TwitchDropsMiner-dev/
TwitchDropsMiner-account2/
TwitchDropsMiner-account3/
TwitchDropsMiner-account4/
```

Run setup if those folders do not exist:

```powershell
powershell -ExecutionPolicy Bypass -File .\Setup-TwitchDropsMiner-Accounts.ps1
```

Then double-click:

```text
Start-All-TwitchDropsMiner.exe
```

## Security

This repo intentionally does not include Twitch cookies or account sessions.

Do not commit these files or folders:

- `config/cookies.jar`
- `cache/`
- `env/`
- `*.log`
- `lock.file`

Each Twitch account must log in locally after setup.
