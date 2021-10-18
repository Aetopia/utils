$ErrorActionPreference = 'Inquire' # Pauses the script if an error shows up
$LaunchOpts = '+exec autoexec +fps_max 180 -dev -novid' # Feel free to suggest better ones

'Welcome to the Apex Settings Patcher (APS), this scripts assume you have Apex Legends installed correctly'
''
'The following launch options have been copied to your clipboard:'
$LaunchOpts | Set-Clipboard
$LaunchOpts
'How to apply them:'
''
'1 - Launch Steam'
'2 - Go to Libraby'
'3 - Right click Apex Legends -> Properties'
'4 - Paste in launch options'
''
"Press any key to continue once you're done"
While (-not [Console]::KeyAvailable){Start-Sleep -Milliseconds 15} # Equivalent to batch's pause>nul
if (!(Test-Path "$home\Saved Games")){
	Write-Output "The Saved Games folder wasn't found (where videoconfig.txt is stored)"
	Write-Output "(Might be because Windows' in another language)"
	Write-Output "Please indicate it's location by dragging in the Saved Games folder"
	$SavedGames = Read-Host "Path"
	while ($SavedGames -eq '' -or (!(Test-Path $SavedGames))){ # Loops until user gives existing folder
			Write-Output "The path you entered was invalid"
			Write-Output "you can alternatively press SHIFT + Right click on the Saved Games folder and click 'Copy Path', then paste it in here"
			$SavedGames = Read-Host "Path"
			if (Test-Path $SavedGames){break}else{continue}
	}
}else{$SavedGames = "$home\Saved Games"}
$VideoConfig = Join-Path $SavedGames "Respawn\Apex\local\videoconfig.txt"

$total_disk =  (GET-WMIOBJECT -query "SELECT * FROM Win32_DiskDrive").Count
if ($total_disk -eq 1){$Drive = $env:HOMEDRIVE}
else{
	$ApexPath
	While (!(Test-Path $ApexPath)){
		''
		Write-Output "Which drive letter is Apex Legends installed on?"
		''
		$DriveLetter = Read-Host "(C:/,D:/,E:/ etc..)"
		$DriveLetter = $DriveLetter.ToUpper().replace('"','').Replace(':','').Replace('\','').Replace('/','').Replace("`'",'').Substring(0,1)
		$Drive = "${DriveLetter}:\"
		"Searching for Apex in $Drive .."
	}
	$ApexPath = Get-ChildItem -Path $Drive -Filter r5apex.exe -Recurse -ErrorAction SilentlyContinue | ForEach-Object{$_.FullName}
	if (!$ApexPath) {
		Write-Host "r5apex.exe wasn't found, try again with another drive letter"
		timeout 3
		exit
}
}
Write-Output "Apex found at path " + $ApexPath
''
$CurrentWidth = (Get-WmiObject Win32_VideoController).CurrentHorizontalResolution
$CurrentVertical = (Get-WmiObject Win32_VideoController).CurrentVerticalResolution
'Which resolution would you like to use?'
''
'1 - 1920x1080'
'2 - 1280x720'
'3 - 1366x768'
'4 - 1360x768'
'5 - 1600x900'
''
'6 - 1680x1050'
'7 - 1728x1080'
''
"C - Current resolution ($($CurrentWidth)x$($CurrentVertical))"
choice.exe /C 1234567C /N
switch ($LASTEXITCODE){
	1{$Width=1920;$Height=1080}
	2{$Width=1280;$Height=720}
	3{$Width=1366;$Height=768}
	4{$Width=1360;$Height=768}
	5{$Width=1600;$Height=900}

	6{$Width=1680;$Height=1050}
	7{$Width=1728;$Height=1080}
	
	8{$Width=$CurrentWidth;$Height=$CurrentVertical}
}




[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

$ApexDir = $ApexPath.Replace("'",'')
$ApexDir = $ApexDir.Replace('"','')
$ApexDir = $ApexDir.Substring(0,$ApexDir.Length-11)

$GHURL = 'https://github.com/couleur-tweak-tips/utils/raw/main/Patchers/Apex%20Settings%20%Patcher'

Remove-Item $ApexDir\cfg\autoexec.cfg -Force -ErrorAction SilentlyContinue
Invoke-RestMethod "$GHURL/autoexec.cfg" | Set-Content $ApexDir\cfg\autoexec.cfg -Force
Set-ItemProperty -path $ApexDir\cfg\autoexec.cfg -name IsReadOnly $false

Remove-Item $videoconfig -Force -ErrorAction SilentlyContinue
$VideoConfig = Invoke-RestMethod "$GHURL/videoconfig.txt"
$videoconfig.Replace('1920',$($Width)).Replace('1080',$Height) | Set-Content $videoconfig -Force
Set-ItemProperty -path $videoconfig -name IsReadOnly $true

Write-Output "Script finished, let me know of any errors/problems about this script on discord.gg/CTT"
''
While (-not [Console]::KeyAvailable){Start-Sleep -Milliseconds 15}
exit