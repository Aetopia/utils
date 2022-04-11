if (-Not(Get-Command ffmpeg -Ea Ignore)){
    "FFmpeg not found" # Installing FFmpeg isn't the point of this specific script.
    Pause
    exit
}

$DriverVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}_Display.Driver" -ErrorAction Ignore).DisplayVersion
    if ($DriverVersion){ # Only triggers if it parsed a NVIDIA driver version
        if ($DriverVersion -lt 477.41){ # Oldest NVIDIA version capable
        Write-Warning "Outdated NVIDIA Drivers detected ($DriverVersion), NVIDIA settings won't be available until you upgrade your drivers"
    }
}

@(
    'hevc_nvenc -rc constqp -preset p7 -qp 18'
    'h264_nvenc -rc constqp -preset p7 -qp 15'
    'hevc_amf -quality quality -qp_i 16 -qp_p 18 -qp_b 20'
    'h264_amf -quality quality -qp_i 12 -qp_p 12 -qp_b 12'
    'hevc_qsv -preset veryslow -global_quality:v 18'
    'h264_qsv -preset veryslow -global_quality:v 15'
    'libx265 -preset medium -crf 18'
    'libx264 -preset slow -crf 15'
) | ForEach-Object -Begin {
    $script:shouldStop = $false
} -Process {
    if ($shouldStop -eq $true) { return }
    Invoke-Expression "ffmpeg.exe -loglevel fatal -f lavfi -i nullsrc=3840x2160 -t 0.1 -c:v $_ -f null NUL"
    if ($LASTEXITCODE -eq 0){
        $script:valid_args = $_
        Write-Host ("Found compatible encoding settings: {0}" -f $script:valid_args.Split(' ')[0].Replace('_', ' ').ToUpper()) -ForegroundColor Green
        $shouldStop = $true # Crappy way to stop the loop since most people that'll execute this will technically be parsing the raw URL as a scriptblock
    }
}

if (-Not($script:valid_args)){
    Write-Host "No compatible encoding settings found (should not happen, is FFmpeg installed?)" -ForegroundColor DarkRed
    Get-Command FFmpeg -Ea Ignore
    Pause
    exit
}
