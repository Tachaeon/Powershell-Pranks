# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

A collection of harmless Windows PowerShell pranks — custom animated cursors, joke/fact popups, and visual effects — plus a Windows Forms GUI (`Pranks_GUI.ps1`) that bundles them all with optional remote execution via PSRemoting.

## Running Scripts

No build system. Run scripts directly:

```powershell
# Individual prank
.\Individual Pranks\Get-Matrix.ps1

# Full GUI (local or remote targeting)
.\Pranks_GUI.ps1
```

Execution policy must allow scripts:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

## Architecture

### Individual scripts are fully standalone

Each script in `Individual Pranks\` has no dependencies on other files in the repo. They can be copied and run anywhere.

### Two script patterns

**Cursor pranks** (`Cursors_*.ps1`) follow this sequence:
1. Download cursor `.cur`/`.ani` files and an MP3 to `C:\Install\`
2. `Add-Type` a C# shim that P/Invokes `user32.dll!SystemParametersInfo`
3. Call `Set-Cursor` with a hashtable mapping cursor roles to downloaded file paths
4. Refresh the system cursor via `SystemParametersInfo`
5. Download a GIF, create a Windows toast notification, play the audio

**Joke/fact pranks** (`Get-*.ps1`) follow this sequence:
1. Call a public REST API (`Invoke-RestMethod`)
2. Build a toast notification using an inline base64-encoded PNG
3. Speak the result aloud via `System.Speech.Synthesis.SpeechSynthesizer`

### GUI architecture (`Pranks_GUI.ps1`)

The GUI does not import the individual scripts. Instead, each button's `Click` handler contains the prank logic stored as a here-string (`@" ... "@`) and executes it as a script block:

```powershell
$code = @" ... prank code ... "@
$sb = [scriptblock]::Create($code)
if ($computerName) { Invoke-Command -ComputerName $computerName -ScriptBlock $sb }
else               { & $sb }
```

This means **the GUI and individual scripts are maintained separately** — changes to one do not affect the other.

### Remote execution

The GUI accepts a computer name and routes execution through `Invoke-Command`. The target machine must have PSRemoting enabled (`Enable-PSRemoting -Force`).

## Script Conventions

- All new scripts need a `<# .SYNOPSIS / .DESCRIPTION / .EXAMPLE #>` comment block at the top.
- Toast notifications embed images as base64 strings directly in the script (no external image files) so they work offline and when run remotely.
- Cursor/media downloads land in `C:\Install\` on the target machine.
- WinAPI calls use `Add-Type -TypeDefinition` with an inline C# class rather than loading external assemblies.
