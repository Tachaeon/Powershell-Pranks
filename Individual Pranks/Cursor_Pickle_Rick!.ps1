$Directory = "C:\Install\Cursors\PickleRick"
If (-Not (Test-Path -Path $Directory)) {
    New-Item -Path $Directory -ItemType Directory
}

$ProgressPreference = 'SilentlyContinue'
$WebClient = New-Object System.Net.WebClient

$Ani = "Pickle_Rick.ani"
$AniURL = 'http://www.rw-designer.com/cursor-download.php?id=102541'
$AniFile = "$Directory\$Ani"

$Mp3 = "Pickle-Rick.mp3"
$Mp3URL = 'https://soundboardguy.com/wp-content/uploads/2021/06/pickle-rick.mp3'
$Mp3File = "$Directory\$Mp3"

$Cursor = "$Directory\*.ani"
If (-Not (Test-Path -Path $Cursor)) {
    $WebClient.DownloadFile($AniURL, $AniFile)
    $WebClient.DownloadFile($Mp3URL, $Mp3File)
}

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
    'Arrow'       = "$Directory\Pickle_Rick.ani"
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
[SysParamsInfo]::CursorHasChanged()

$Header_type = "GIF"
$URL = "https://i.gifer.com/fxmn.gif"

# Toast information
$Title = "I'm Pickle Rick!"
$Message = "`nI turned myself into a pickle, Morty! Boom! Big reveal: I'm a pickle. What do you think about that? I turned myself into a pickle! W-what are you just staring at me for, bro? I turned myself into a pickle, Morty!"
$Advice = "`nShutup Summer!"
$Text_AppName = "Rick and Morty"

If ($Header_type -eq "GIF") {
    $HeroImage = "$env:temp\reboot.gif"		
    Invoke-WebRequest -Uri $URL -OutFile $HeroImage -UseBasicParsing
}

Function Register-NotificationApp($AppID, $AppDisplayName) {
    [int]$ShowInSettings = 0
    [int]$IconBackgroundColor = 0
    $IconUri = "C:\Windows\ImmersiveControlPanel\images\logo.png"
    $AppRegPath = "HKCU:\Software\Classes\AppUserModelId"
    $RegPath = "$AppRegPath\$AppID"
    $Notifications_Reg = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'
    If (!(Test-Path -Path "$Notifications_Reg\$AppID")) {
        New-Item -Path "$Notifications_Reg\$AppID" -Force
        New-ItemProperty -Path "$Notifications_Reg\$AppID" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force
    }
    If ((Get-ItemProperty -Path "$Notifications_Reg\$AppID" -Name 'ShowInActionCenter' -ErrorAction SilentlyContinue).ShowInActionCenter -ne '1') {
        New-ItemProperty -Path "$Notifications_Reg\$AppID" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force
    }
    try {
        if (-NOT(Test-Path $RegPath)) {
            New-Item -Path $AppRegPath -Name $AppID -Force | Out-Null
        }
        $DisplayName = Get-ItemProperty -Path $RegPath -Name DisplayName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($DisplayName -ne $AppDisplayName) {
            New-ItemProperty -Path $RegPath -Name DisplayName -Value $AppDisplayName -PropertyType String -Force | Out-Null
        }
        $ShowInSettingsValue = Get-ItemProperty -Path $RegPath -Name ShowInSettings -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ShowInSettings -ErrorAction SilentlyContinue
        if ($ShowInSettingsValue -ne $ShowInSettings) {
            New-ItemProperty -Path $RegPath -Name ShowInSettings -Value $ShowInSettings -PropertyType DWORD -Force | Out-Null
        }
        New-ItemProperty -Path $RegPath -Name IconUri -Value $IconUri -PropertyType ExpandString -Force | Out-Null	
        New-ItemProperty -Path $RegPath -Name IconBackgroundColor -Value $IconBackgroundColor -PropertyType ExpandString -Force | Out-Null
    }
    catch {
    }
}

$Scenario = 'reminder'
[xml]$Toast = @"
<toast scenario="$Scenario">
    <visual>
    <binding template="ToastGeneric">
        <image placement="inline" src="$HeroImage" hint-crop="none"/>
        <text placement="attribution">$Attribution</text>
        <text>$Title</text>
        <group>
            <subgroup>
                <text hint-style="body" hint-wrap="true" >$Message</text>
            </subgroup>
        </group>
		
		<group>
			<subgroup>
				<text hint-style="body" hint-wrap="true" >$Advice</text>
			</subgroup>
		</group>
    </binding>
    </visual>
	$Actions
</toast>
"@

$AppID = $Text_AppName
$AppDisplayName = $Text_AppName
Register-NotificationApp -AppID $Text_AppName -AppDisplayName $Text_AppName

# Toast creation and display
$Load = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$Load = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($Toast.OuterXml)
# Display the Toast
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID).Show($ToastXml)

# Play a single file
Add-Type -AssemblyName presentationCore
$mediaPlayer = New-Object system.windows.media.mediaplayer
$mediaPlayer.open($Mp3File)
$mediaPlayer.Play()
Start-Sleep 3
$mediaPlayer1 = New-Object system.windows.media.mediaplayer
$mediaPlayer1.open($Mp3File)
$mediaPlayer1.Play()