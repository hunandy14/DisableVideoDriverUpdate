# 禁用顯示卡自動更新驅動
function DisableVideoDriverUpdate {
    param(
        [Parameter(ParameterSetName = "A")]
        [string] $Filter,
        [Parameter(ParameterSetName = "B")]
        [switch] $Recovery,
        [Parameter(ParameterSetName = "C")]
        [switch] $Info,
        [Parameter(ParameterSetName = "")]
        [switch] $Force
    )
    # 查看顯卡設備名稱
    if ($Info) {
        Write-Host "已安裝的顯示卡設備" -ForegroundColor:Yellow;
        $Devices += @(Get-WmiObject -Class CIM_PCVideoController)
        for ($i = 0; $i -lt $Devices.Count; $i++) {
            Write-Host "  " [$($i+1)] $Devices[$i].Name
        } Write-Host ""
        return
    }
    # 復原預設值
    if ($Recovery) {
        Write-Host "即將恢復所有設備的自動更新" -ForegroundColor:Yellow;
        if (!$Force) {
            $response = Read-Host " 沒有異議, 請輸入Y (Y/N) ";
            if ($response -ne "Y" -or $response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
        }
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall") {
            reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall" /f
        } return
    }
    
    # 獲取顯示卡
    $DevicesAll = @()
    $DevicesAll += ((Get-WmiObject -Class CIM_PCVideoController))
    # 過濾特定廠牌 
    $Devices = @()
    if ($Filter) {
        $Devices += $DevicesAll|Where-Object{$_.Name -match $Filter}
        # $Devices |Select-Object  Name,PNPDeviceID
    } else { $Devices = $DevicesAll }
    if ($Devices.Length -eq 0) { Write-Host "沒有找到$($Filter)設備" -ForegroundColor:Yellow; return }
    
    # 確認禁用設備
    for ($i = 0; $i -lt $Devices.Count; $i++) { Write-Host " " [$($i+1)] $Devices[$i].Name }
    Write-Host "即將禁用上述設備的自動更新" -ForegroundColor:Yellow;
    if (!$Force) {
        $response = Read-Host " 沒有異議, 請輸入Y (Y/N) ";
        if ($response -ne "Y" -or $response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
    }
    
    # 寫入登錄檔
    $regPath1 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
    $regPath2 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs"
    for ($i = 0; $i -lt $Devices.Count; $i++) {
        $DeviceID   = "PCI\" + ($Devices[$i].PNPDeviceID.Split('\'))[1]
        $DeviceName = $Devices[$i].Name
        reg add $regPath1 /f /t "REG_DWORD" /v "DenyDeviceIDs" /d "1"
        reg add $regPath1 /f /t "REG_DWORD" /v "DenyDeviceIDsRetroactive" /d "0"
        if (Test-Path "Registry::$regPath2") { reg delete $regPath2 /f }
        reg add $regPath2 /f /t "REG_SZ" /v $($i + 1) /d $DeviceID
        Write-Host "[$($i+1)] $DeviceID(" -NoNewline
        Write-Host $DeviceName -ForegroundColor:Yellow -NoNewline
        Write-Host ")::" -NoNewline
        Write-Host "已禁用" -ForegroundColor:Red
    }
    
    # 導向說明網站
    Write-Host "`n關於注意事項(很重要), 3秒後導向作者說明網站..." -ForegroundColor:Yellow; Start-Sleep 5
    explorer.exe "https://charlottehong.blogspot.com/2022/01/nvidia-or-amd.html"
} # DisableVideoDriverUpdate -Filter:"VMware"



# 簡化禁用代碼
function DisAMD {
    DisableVideoDriverUpdate -Filter:Radeon
} # DisAMD

# 簡化復原代碼
function RcvAMD {
    DisableVideoDriverUpdate -Recovery
} # RcvAMD