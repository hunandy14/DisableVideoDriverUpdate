function VideoDriverUpdate {
    $Device = ((Get-WmiObject -Class CIM_PCVideoController)|Select-Object Name, PNPDeviceID) -match("NVIDIA|AMD")
    if ($Device -eq "") { Write-Host "ERROR:: No (NVIDIA or AMD) Device" -F:yellow; return }
    $DeviceID = "PCI\"+($Device.PNPDeviceID.Split('\'))[1]

    $regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
    reg add $regPath /f /t "REG_DWORD" /v "DenyDeviceIDs" /d "1"
    reg add $regPath /f /t "REG_DWORD" /v "DenyDeviceIDsRetroactive" /d "0"
    $regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs"
    reg add $regPath /f /t "REG_SZ" /v "1" /d $DeviceID
}
VideoDriverUpdate
