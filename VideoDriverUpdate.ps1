function DisableVideoDriverUpdate {
    param(
        [switch] $Recovery
    )
    $Device = ((Get-WmiObject -Class CIM_PCVideoController)|Select-Object Name, PNPDeviceID)# -match("NVIDIA|AMD")
    if ($Device -eq "") { Write-Host "ERROR:: No (NVIDIA or AMD) Device" -F:yellow; return }
    $DeviceID = "PCI\"+($Device.PNPDeviceID.Split('\'))[1]
    
    $regPath1 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
    $regPath2 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs"
    
    if ($Recovery) {
        reg delete $regPath2
    } else {
        reg add $regPath1 /f /t "REG_DWORD" /v "DenyDeviceIDs" /d "1"
        reg add $regPath1 /f /t "REG_DWORD" /v "DenyDeviceIDsRetroactive" /d "0"
        reg add $regPath2 /f /t "REG_SZ" /v "1" /d $DeviceID
    }
}
# DisableVideoDriverUpdate
