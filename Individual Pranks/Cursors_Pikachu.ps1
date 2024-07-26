$Directory = "C:\Install\Cursors\Pikachu"
If (-Not (Test-Path -Path $Directory)) {
    New-Item -Path $Directory -ItemType Directory
}
$ProgressPreference = 'SilentlyContinue'
$WebClient = New-Object System.Net.WebClient

$Zip = "Pikachu.zip"
$ZipURL = 'http://www.rw-designer.com/cursor-downloadset.php?id=pokemon-lightning'
$ZipFile = "$Directory\$Zip"

$Mp3 = "Pikachu.mp3"
$Mp3URL = 'https://www.myinstants.com/media/sounds/pkmntheme.mp3'
$Mp3File = "$Directory\$Mp3"

$Cursor = "$Directory\*.ani"
If (-Not (Test-Path -Path $Cursor)) {
    $WebClient.DownloadFile($ZipURL, $ZipFile)
    $WebClient.DownloadFile($Mp3URL, $Mp3File)
    Expand-Archive -Path $ZipFile -DestinationPath $Directory
    if (Test-Path -Path "$Directory\*.ani") {
        Remove-Item -Path $File
    }
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
    Set-ItemProperty -Path 'HKCU:\Control Panel\Cursors' -Name $CursorName -Value "$Directory\$FileName"
}

# Hashtable of cursor settings
$cursorSettings = @{
    'AppStarting' = "pikachu - work.ani"
    'Arrow'       = "pikachu - normal.ani"
    'Crosshair'   = "pikachu - precision.ani"
    'Hand'        = "pikachu - link.ani"
    'Help'        = "pikachu - help.ani"
    'Ibeam'       = "pikachu - text.ani"
    'No'          = "pikachu - unavailable.ani"
    'NWPen'       = "pikachu - handwriting.ani"
    'SizeAll'     = "pikachu - move.ani"
    'SizeNESW'    = "pikachu - d2.ani"
    'SizeNS'      = "pikachu - vertic.ani"
    'SizeNWSE'    = "pikachu - d1.ani"
    'SizeWE'      = "pikachu - horizon.ani"
    'UpArrow'     = "pikachu - alt.ani"
    'Wait'        = "pikachu - busy.ani"
}

# Apply each cursor setting
foreach ($cursor in $cursorSettings.GetEnumerator()) {
    Set-Cursor -CursorName $cursor.Key -FileName $cursor.Value
}

# Notify the system about settings change by calling the C# code
$Null = [SysParamsInfo]::CursorHasChanged()

$Header_type = "GIF"
$URL = "https://media.tenor.com/uUNcnHwYJQEAAAAi/running-pikachu-transparent-snivee.gif"

# Toast information
$Title = "Pika Pika!"
$Message = "`nI wanna be the very best like no one ever was. To catch them is my real test. To train them is my cause. I will travel across the land searching far and wide. Teach Pokémon to understand the power that's inside."
$Advice = "`nWho's that Pokemon?"
$Text_AppName = "Pikachu!"

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
Start-Sleep -Seconds 7
$mediaPlayer.Stop()