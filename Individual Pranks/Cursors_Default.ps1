# Define a C# class for calling WinAPI.
Add-Type -TypeDefinition @'
public class SysParamsInfo {
    [System.Runtime.InteropServices.DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
    
    const int SPI_SETCURSORS = 0x0057;
    const int SPIF_UPDATEINIFILE = 0x01;
    const int SPIF_SENDCHANGE = 0x02;

    public static void CursorHasChanged() {
        SystemParametersInfo(SPI_SETCURSORS, 0, 0, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    }
}
'@

# Function to set the cursor
function Set-Cursor {
    param (
        [string]$CursorName,
        [string]$FileName
    )
    Set-ItemProperty -Path 'HKCU:\Control Panel\Cursors' -Name $CursorName -Value $FileName
}

# Hashtable of cursor settings
$cursorSettings = @{
    'AppStarting' = "%SystemRoot%\cursors\aero_working.ani"
    'Arrow'       = "%SystemRoot%\cursors\aero_arrow.cur"
    'Crosshair'   = ""
    'Hand'        = "%SystemRoot%\cursors\aero_link.cur"
    'Help'        = "%SystemRoot%\cursors\aero_helpsel.cur"
    'Ibeam'       = ""
    'No'          = "%SystemRoot%\cursors\aero_unavail.cur"
    'NWPen'       = "%SystemRoot%\cursors\aero_pen.cur"
    'SizeAll'     = "%SystemRoot%\cursors\aero_move.cur"
    'SizeNESW'    = "%SystemRoot%\cursors\aero_nesw.cur"
    'SizeNS'      = "%SystemRoot%\cursors\aero_ns.cur"
    'SizeNWSE'    = "%SystemRoot%\cursors\aero_nwse.cur"
    'SizeWE'      = "%SystemRoot%\cursors\aero_ew.cur"
    'UpArrow'     = "%SystemRoot%\cursors\aero_up.cur"
    'Wait'        = "%SystemRoot%\cursors\aero_busy.ani"
}

# Apply each cursor setting
foreach ($cursor in $cursorSettings.GetEnumerator()) {
    Set-Cursor -CursorName $cursor.Key -FileName $cursor.Value
}

# Notify the system about settings change by calling the C# code
$Null = [SysParamsInfo]::CursorHasChanged()