# =========================================================
# Ego100%
# =========================================================

# REQUIRE ADMIN
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Ego100%"


function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host "                     Ego100%"
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host " [1] SETTING"
    Write-Host " [2] EXIT"
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host ""
}

function Show-Status {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    $valid = [enum]::GetNames([System.ConsoleColor])
    if ($valid -notcontains $Color) { $Color = "White" }

    try {
        Write-Host $Text -ForegroundColor $Color
    }
    catch {
        Write-Host $Text
    }
}

function Convert-ToRegPath {
    param([string]$Path)

    $p = $Path.Trim()

    if ($p -match '^HKLM:\\') { return ($p -replace '^HKLM:\\','HKLM\') }
    if ($p -match '^HKCU:\\') { return ($p -replace '^HKCU:\\','HKCU\') }
    if ($p -match '^HKCR:\\') { return ($p -replace '^HKCR:\\','HKCR\') }
    if ($p -match '^HKU:\\')  { return ($p -replace '^HKU:\\','HKU\') }
    if ($p -match '^HKCC:\\') { return ($p -replace '^HKCC:\\','HKCC\') }
    return $p
}

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )

    try {
        $regPath = Convert-ToRegPath $Path

        if ($Type -eq "String") {
            & reg.exe add $regPath /v $Name /t REG_SZ /d "$Value" /f | Out-Null
        }
        else {
            & reg.exe add $regPath /v $Name /t REG_DWORD /d "$Value" /f | Out-Null
        }
    }
    catch {
        Write-Host "FAILED : $Path\$Name" -ForegroundColor Red
    }
}

function Run-Safe {
    param([string]$Command)

    try {
        Invoke-Expression $Command
    }
    catch {
        Write-Host "SKIPPED : $Command" -ForegroundColor DarkYellow
    }
}

function Get-Interface {
    try {
        $iface = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1 -ExpandProperty Name
        if ([string]::IsNullOrWhiteSpace($iface)) { $iface = "Ethernet" }
        return $iface
    }
    catch {
        return "Ethernet"
    }
}

# =========================================================
# MAIN ACTION
# =========================================================

function Apply-All {

    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "                     SETTING"
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""

    $IFACE = Get-Interface


# =========================================================
# FIVEM ONLY - ADDITIONAL SAFE VALUES
# เพิ่มอย่างเดียว / ไม่ลบ / ไม่แก้
# =========================================================

function Add-RegValueIfMissing {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )

    try {
        $regPath = Convert-ToRegPath $Path

        $exists = $false
        try {
            $current = Get-ItemProperty -Path $regPath -Name $Name -ErrorAction Stop
            if ($null -ne $current) { $exists = $true }
        } catch {
            $exists = $false
        }

        if (-not $exists) {
            if ($Type -eq "String") {
                & reg.exe add $regPath /v $Name /t REG_SZ /d "$Value" /f | Out-Null
            }
            else {
                & reg.exe add $regPath /v $Name /t REG_DWORD /d "$Value" /f | Out-Null
            }
        }
    }
    catch {
        Write-Host "SKIPPED : $Path\$Name" -ForegroundColor DarkYellow
    }
}

# ---------------------------------------------------------
# FiveM process priority
# ---------------------------------------------------------
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "CpuPriorityClass" 3
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "IoPriority" 3
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "PagePriority" 5

Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "IoPriority" 3
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "PagePriority" 5

# ---------------------------------------------------------
# FiveM versions
# ---------------------------------------------------------
$FiveMVersions = @(
    "FiveM_b2372_GTAProcess.exe",
    "FiveM_b2545_GTAProcess.exe",
    "FiveM_b2699_GTAProcess.exe",
    "FiveM_b2802_GTAProcess.exe",
    "FiveM_b2944_GTAProcess.exe",
    "FiveM_b3095_GTAProcess.exe",
    "FiveM_b3258_GTAProcess.exe"
)

foreach ($ver in $FiveMVersions) {
    $p = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$ver\PerfOptions"
    Add-RegValueIfMissing $p "CpuPriorityClass" 3
    Add-RegValueIfMissing $p "IoPriority" 3
    Add-RegValueIfMissing $p "PagePriority" 5
}

# ---------------------------------------------------------
# Game mode / DVR
# ---------------------------------------------------------
Add-RegValueIfMissing "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1
Add-RegValueIfMissing "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1
Add-RegValueIfMissing "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
Add-RegValueIfMissing "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 0

# ---------------------------------------------------------
# FiveM graphics preference
# ---------------------------------------------------------
Add-RegValueIfMissing "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "FiveM.exe" "GpuPreference=2;" "String"

# ---------------------------------------------------------
# Desktop / input for faster response
# ---------------------------------------------------------
Add-RegValueIfMissing "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0" "String"
Add-RegValueIfMissing "HKCU:\Control Panel\Desktop" "LowLevelHooksTimeout" "1000" "String"
Add-RegValueIfMissing "HKCU:\Control Panel\Desktop" "WaitToKillAppTimeout" "2000" "String"
Add-RegValueIfMissing "HKCU:\Control Panel\Desktop" "HungAppTimeout" "1000" "String"

# ---------------------------------------------------------
# Multimedia profile
# ---------------------------------------------------------
$MP = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Add-RegValueIfMissing $MP "SystemResponsiveness" 0
Add-RegValueIfMissing $MP "NetworkThrottlingIndex" 4294967295
Add-RegValueIfMissing $MP "NoLazyMode" 1

$Games = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Add-RegValueIfMissing $Games "GPU Priority" 8
Add-RegValueIfMissing $Games "Priority" 6
Add-RegValueIfMissing $Games "Scheduling Category" "High" "String"
Add-RegValueIfMissing $Games "SFIO Priority" "High" "String"

    # =========================================================
    # GROUP POLICY
    # =========================================================
    Show-Step "GROUP POLICY" 5
    Write-Host "[1/25] GROUP POLICY..."
    Run-Safe 'gpupdate /force'

    # =========================================================
    # TCP STACK
    # =========================================================
    Show-Step "TCP STACK" 12
    Write-Host "[2/25] TCP STACK..."

    $tcpCommands = @(
        'netsh int udp set global uro=disabled',
        'netsh interface tcp set global autotuninglevel=disabled',
        'netsh interface tcp set global rss=enabled',
        'netsh interface tcp set global chimney=enabled',
        'netsh interface tcp set global congestionprovider=ctcp',
        'netsh interface tcp set global ecncapability=enabled',
        'netsh interface tcp set global timestamps=disabled',
        'netsh interface tcp set heuristics disabled',
        'netsh int tcp set global rsc=enabled',
        'netsh int tcp set global maxsynretransmissions=2',
        'netsh int tcp set global initialrto=3000',
        'netsh int tcp set global delayedacktimeout=100',
        'netsh int tcp set global fastopen=enabled',
        'netsh int tcp set global pacingprofile=alwayson',
        'netsh int tcp set global hystart=enabled',
        'netsh int tcp set global dca=enabled',
        'netsh interface teredo set state disabled',
        'netsh interface ipv6 set teredo disabled',
        'netsh interface tcp set global netdma=enabled'
    )
    foreach ($c in $tcpCommands) { Run-Safe $c }

    # =========================================================
    # DNS
    # =========================================================
    Show-Step "DNS" 21
    Write-Host "[3/25] DNS..."

    Run-Safe "netsh interface ipv4 set dns name=`"$IFACE`" static 8.8.8.8"
    Run-Safe "netsh interface ipv4 add dns name=`"$IFACE`" 8.8.4.4 index=2"
    Run-Safe "netsh interface ipv6 set dnsservers `"$IFACE`" static 2001:4860:4860::8888"
    Run-Safe "netsh interface ipv6 add dnsservers `"$IFACE`" 2001:4860:4860::8844 index=2"

# ---------------------------------------------------------
# PER-ADAPTER TCP ADDITIONS
# ---------------------------------------------------------
try {
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    if ($adapter -and $adapter.InterfaceGuid) {
        $ifaceKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($adapter.InterfaceGuid)"

        Set-RegValue $ifaceKey "TcpAckFrequency" 1
        Set-RegValue $ifaceKey "TCPNoDelay" 1
        Set-RegValue $ifaceKey "TcpDelAckTicks" 0
        Set-RegValue $ifaceKey "TcpWindowSize" 64240
        Set-RegValue $ifaceKey "Tcp1323Opts" 1
        Set-RegValue $ifaceKey "EnablePMTUDiscovery" 1
        Set-RegValue $ifaceKey "EnablePMTUBHDetect" 0
    }
}
catch {
    Write-Host "SKIPPED : PER-ADAPTER TCP ADDITIONS" -ForegroundColor DarkYellow
}

# ---------------------------------------------------------
# FIVE M RENDER / GPU HINTS
# ---------------------------------------------------------
Run-Safe 'reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FiveM.exe" /t REG_SZ /d "GpuPreference=2;" /f'
Run-Safe 'reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "GTA5.exe" /t REG_SZ /d "GpuPreference=2;" /f'
Run-Safe 'reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FiveM_GTAProcess.exe" /t REG_SZ /d "GpuPreference=2;" /f'

# ---------------------------------------------------------
# OPTIONAL EXTRA MMCSS HINT
# ---------------------------------------------------------
Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f'
Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f'
Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f'


    # =========================================================
    # IPV6
    # =========================================================
    Show-Step "IPV6" 27
    Write-Host "[4/25] IPV6..."
    Run-Safe 'netsh interface ipv6 set global randomizeidentifiers=disabled'
    Run-Safe 'netsh interface ipv6 set privacy state=disabled'

    # =========================================================
    # FPS + INPUT
    # =========================================================
    Show-Step "FPS + INPUT" 30
    Write-Host "[5/25] FPS + INPUT..."
    Run-Safe 'bcdedit /set useplatformtick yes'
    Run-Safe 'bcdedit /set disabledynamictick yes'
    Run-Safe 'bcdedit /set tscsyncpolicy enhanced'
    Run-Safe 'reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f'
    Run-Safe 'reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f'
    Run-Safe 'reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f'
    Run-Safe 'reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f'
    Run-Safe 'powercfg -setactive SCHEME_MIN'

    # =========================================================
    # SYSTEM PROFILE
    # =========================================================
    Show-Step "SYSTEM PROFILE" 42
    Write-Host "[6/25] SYSTEM PROFILE..."
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d 65536 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d 1 /f'

    # =========================================================
    # MMCSS TASKS
    # =========================================================
    Show-Step "MMCSS TASKS" 45
    Write-Host "[7/25] MMCSS TASKS..."

    $Tasks = @("Audio","Capture","DisplayPostProcessing","Distribution","Games","Playback","Pro Audio")
    foreach ($task in $Tasks) {
        $path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\$task"
        Run-Safe "reg add `"$path`" /v `"$([string]'Affinity')`" /t REG_DWORD /d 1 /f"
        Run-Safe "reg add `"$path`" /v `"Background Only`" /t REG_SZ /d False /f"
        Run-Safe "reg add `"$path`" /v `"Clock Rate`" /t REG_DWORD /d 10000 /f"
        Run-Safe "reg add `"$path`" /v `"GPU Priority`" /t REG_DWORD /d 8 /f"
        Run-Safe "reg add `"$path`" /v `"Priority`" /t REG_DWORD /d 6 /f"
        Run-Safe "reg add `"$path`" /v `"Scheduling Category`" /t REG_SZ /d High /f"
        Run-Safe "reg add `"$path`" /v `"SFIO Priority`" /t REG_SZ /d High /f"
        Run-Safe "reg add `"$path`" /v `"Latency Sensitive`" /t REG_SZ /d False /f"
    }

    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "NoLazyMode" /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "BackgroundPriority" /t REG_DWORD /d 8 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "BackgroundPriority" /t REG_DWORD /d 6 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Priority" /t REG_DWORD /d 1 /f'

    # =========================================================
    # MEMORY MANAGEMENT
    # =========================================================
    Show-Step "MEMORY MANAGEMENT" 47
    Write-Host "[8/25] MEMORY MANAGEMENT..."

    $MM = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-RegValue $MM "ClearPageFileAtShutdown" 0
    Set-RegValue $MM "DisablePagingExecutive" 1
    Set-RegValue $MM "LargeSystemCache" 1
    Set-RegValue $MM "NonPagedPoolQuota" 0
    Set-RegValue $MM "NonPagedPoolSize" 0
    Set-RegValue $MM "PagedPoolQuota" 0
    Set-RegValue $MM "PagedPoolSize" 0
    Set-RegValue $MM "SecondLevelDataCache" 0
    Set-RegValue $MM "SessionPoolSize" 4
    Set-RegValue $MM "SessionViewSize" 48
    Set-RegValue $MM "SystemPages" 0
    Set-RegValue $MM "FeatureSettingsOverride" 3
    Set-RegValue $MM "FeatureSettingsOverrideMask" 3
    Set-RegValue $MM "EnableAsyncLazywrite" 1
    Set-RegValue $MM "EnablePerVolumeLazyWriter" 1
    Set-RegValue $MM "EnableCfg" 0
    Set-RegValue $MM "DisablePageCombining" 1
    Set-RegValue $MM "EnablePrefetcher" 0
    Set-RegValue $MM "EnableSuperfetch" 0
    Set-RegValue $MM "MoveImages" 0
    Set-RegValue $MM "FeatureSettings" 1
    Set-RegValue $MM "IoPageLockLimit" 4294967295
    Set-RegValue $MM "PhysicalAddressExtension" 1

    # =========================================================
    # PREFETCH
    # =========================================================
    Show-Step "PREFETCH" 50
    Write-Host "[9/25] PREFETCH..."
    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f'
    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "BootId" /t REG_DWORD /d 11 /f'
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{122da4c0-a8c1-11ed-bcf3-806e6f6e6963}" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "Lease" /t REG_DWORD /d "10800" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "LeaseObtainedTime" /t REG_DWORD /d "1677856209" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "T1" /t REG_DWORD /d "1677861609" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "T2" /t REG_DWORD /d "1677865659" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "LeaseTerminatesTime" /t REG_DWORD /d "1677867009" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "IsServerNapAware" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "DhcpDefaultGateway" /t REG_MULTI_SZ /d "192.168.1.1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "DhcpInterfaceOptions" /t REG_BINARY /d "fc0000000000000000000000000000002e150000790000000000000000000000000000002e150000770000000000000000000000000000002e1500002f0000000000000000000000000000002e1500002e0000000000000000000000000000002e1500002c0000000000000000000000000000002e1500002b0000000000000000000000000000002e150000210000000000000000000000000000002e1500001f0000000000000000000000000000002e1500000f0000000000000000000000000000002e1500000600000000000000040000000000000016002a30c0a801010300000000000000040000000000000016002a30c0a801010100000000000000040000000000000016002a30ffffff003300000000000000040000000000000016002a3000002a303600000000000000040000000000000016002a30c0a801013500000000000000010000000000000016002a3005000000" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "DhcpGatewayHardware" /t REG_BINARY /d "c0a8010106000000c4a402768dbd" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{2C2B0C5F-D7AC-44D7-AEEB-204915937C46}" /v "DhcpGatewayHardwareCount" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "UseZeroBroadcast" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "EnableDHCP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "NameServer" /t REG_SZ /d "8.8.8.8,8.8.4.4" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "Domain" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "Lease" /t REG_DWORD /d "864000" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "LeaseObtainedTime" /t REG_DWORD /d "1467505923" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "T1" /t REG_DWORD /d "1467937923" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "T2" /t REG_DWORD /d "1468261923" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "LeaseTerminatesTime" /t REG_DWORD /d "1468369923" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "IsServerNapAware" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpNetworkHint" /t REG_SZ /d "6627565626F687F5B41495" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpInterfaceOptions" /t REG_BINARY /d "06000000000000000800000000000000038c8557d41b28f1d41b28f003000000000000000400000000000000038c8557c0a800fe01000000000000000400000000000000038c8557ffffff0036000000000000000400000000000000038c8557c0a800fe35000000000000000100000000000000038c855705000000fc000000000000000000000000000000dd89785733000000000000000400000000000000038c8557000d2f00" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpGatewayHardware" /t REG_BINARY /d "c0a800fe060000000024d4b16589" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpGatewayHardwareCount" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "MTU" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "TCPNoDelay" /t REG_DWORD /d "1694564351" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "TcpAckFrequency" /t REG_DWORD /d "61167" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpNameServer" /t REG_SZ /d "212.27.40.241 212.27.40.240" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpDefaultGateway" /t REG_MULTI_SZ /d "192.168.1.1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "EnableDHCP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "NameServer" /t REG_SZ /d "104.197.191.4" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "Domain" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpIPAddress" /t REG_SZ /d "94.238.154.142" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpSubnetMask" /t REG_SZ /d "255.255.224.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpServer" /t REG_SZ /d "94.238.159.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "Lease" /t REG_DWORD /d "300" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "LeaseObtainedTime" /t REG_DWORD /d "1455802053" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "T1" /t REG_DWORD /d "1455802203" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "T2" /t REG_DWORD /d "1455802315" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "LeaseTerminatesTime" /t REG_DWORD /d "1455802353" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "IsServerNapAware" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpNetworkHint" /t REG_SZ /d "24F6579776575637024556C65636F6D6027596D26496" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpInterfaceOptions" /t REG_BINARY /d "fc000000000000000000000000000000cac6c55606000000000000000800000000000000f1c7c556c29e7a0ac29e7a0f03000000000000000400000000000000f1c7c5565eee9ffe01000000000000000400000000000000f1c7c556ffffe00033000000000000000400000000000000f1c7c5560000012c36000000000000000400000000000000f1c7c5565eee9ffe35000000000000000100000000000000f1c7c55605000000" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpNameServer" /t REG_SZ /d "194.158.122.10 194.158.122.15" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpDefaultGateway" /t REG_MULTI_SZ /d "94.238.159.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\24F6579776575637024556C65636F6D6027596D26496" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.255.224.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "EnableDHCP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "NameServer" /t REG_SZ /d "8.8.8.8,8.8.4.4" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "Domain" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpIPAddress" /t REG_SZ /d "192.168.1.30" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpSubnetMask" /t REG_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpServer" /t REG_SZ /d "192.168.1.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "Lease" /t REG_DWORD /d "43200" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "LeaseObtainedTime" /t REG_DWORD /d "1465403852" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "T1" /t REG_DWORD /d "1465425452" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "T2" /t REG_DWORD /d "1465441652" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "LeaseTerminatesTime" /t REG_DWORD /d "1465447052" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "IsServerNapAware" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpNetworkHint" /t REG_SZ /d "6427565626F687D2241314736363" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpInterfaceOptions" /t REG_BINARY /d "060000000000000004000000000000007df65857c0a801fe030000000000000004000000000000007df65857c0a801fe010000000000000004000000000000007df65857ffffff00330000000000000004000000000000007df658570000a8c0360000000000000004000000000000007df65857c0a801fe350000000000000001000000000000007df6585705000000fc000000000000000000000000000000bb4d5857" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpGatewayHardware" /t REG_BINARY /d "c0a801fe06000000140c76b1a766" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpGatewayHardwareCount" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpNameServer" /t REG_SZ /d "192.168.1.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpDefaultGateway" /t REG_MULTI_SZ /d "192.168.1.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565626F687D2241314736363" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "EnableDHCP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "NameServer" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "Domain" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpIPAddress" /t REG_SZ /d "10.49.225.216" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpSubnetMask" /t REG_SZ /d "255.248.0.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpServer" /t REG_SZ /d "10.55.255.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "Lease" /t REG_DWORD /d "130" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "LeaseObtainedTime" /t REG_DWORD /d "1465339910" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "T1" /t REG_DWORD /d "1465339975" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "T2" /t REG_DWORD /d "1465340023" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "LeaseTerminatesTime" /t REG_DWORD /d "1465340040" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "IsServerNapAware" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpNetworkHint" /t REG_SZ /d "6427565675966696" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpInterfaceOptions" /t REG_BINARY /d "520000000000000006000000000000008850575701040a133eab00000600000000000000080000000000000088505757d41b28f1d41b28f003000000000000000400000000000000885057570a37fffe0100000000000000040000000000000088505757fff8000033000000000000000400000000000000885057570000008236000000000000000400000000000000885057570a37fffe350000000000000001000000000000008850575705000000fc00000000000000000000000000000042505757" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpGatewayHardware" /t REG_BINARY /d "0a37fffe060000000007cb000100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpGatewayHardwareCount" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpNameServer" /t REG_SZ /d "212.27.40.241 212.27.40.240" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpDefaultGateway" /t REG_MULTI_SZ /d "10.55.255.254" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\6427565675966696" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.248.0.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "EnableDHCP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "NameServer" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "Domain" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpIPAddress" /t REG_SZ /d "192.168.223.106" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpSubnetMask" /t REG_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpServer" /t REG_SZ /d "192.168.223.1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "Lease" /t REG_DWORD /d "86400" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "LeaseObtainedTime" /t REG_DWORD /d "1465339966" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "T1" /t REG_DWORD /d "1465383166" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "T2" /t REG_DWORD /d "1465415566" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "LeaseTerminatesTime" /t REG_DWORD /d "1465426366" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "IsServerNapAware" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpNetworkHint" /t REG_SZ /d "8405D2052796E647D29344D2F46666963656A656470243633303" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpInterfaceOptions" /t REG_BINARY /d "fc0000000000000000000000000000004250575736000000000000000400000000000000bea15857c0a8df0133000000000000000400000000000000bea158570001518001000000000000000400000000000000bea15857ffffff0035000000000000000100000000000000bea1585705000000" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpGatewayHardware" /t REG_BINARY /d "0a37fffe060000000007cb000100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpGatewayHardwareCount" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{4B60CC79-0175-4BDC-8B2D-5CA4AA06F32A}\8405D2052796E647D29344D2F46666963656A656470243633303" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "EnableDHCP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "Domain" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "NameServer" /t REG_SZ /d "" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpIPAddress" /t REG_SZ /d "192.168.19.214" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpSubnetMask" /t REG_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpServer" /t REG_SZ /d "192.168.19.108" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "Lease" /t REG_DWORD /d "3599" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "LeaseObtainedTime" /t REG_DWORD /d "1677790017" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "T1" /t REG_DWORD /d "1677791816" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "T2" /t REG_DWORD /d "1677793166" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "LeaseTerminatesTime" /t REG_DWORD /d "1677793616" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "AddressType" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "IsServerNapAware" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpConnForceBroadcastFlag" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpIsMeteredDetected" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpNameServer" /t REG_SZ /d "192.168.19.108" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpDefaultGateway" /t REG_MULTI_SZ /d "192.168.19.108" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpSubnetMaskOpt" /t REG_MULTI_SZ /d "255.255.255.0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpInterfaceOptions" /t REG_BINARY /d "fc0000000000000000000000000000003a070000790000000000000000000000000000003a070000770000000000000000000000000000003a0700002f0000000000000000000000000000003a0700002e0000000000000000000000000000003a0700002c0000000000000000000000000000003a070000210000000000000000000000000000003a0700001f0000000000000000000000000000003a0700000f0000000000000000000000000000003a0700000600000000000000040000000000000033000e0fc0a8136c0300000000000000040000000000000033000e0fc0a8136c1c00000000000000040000000000000033000e0fc0a813ff0100000000000000040000000000000033000e0fffffff003b00000000000000040000000000000033000e0f00000c4d3a00000000000000040000000000000033000e0f000007073300000000000000040000000000000033000e0f00000e0f3600000000000000040000000000000033000e0fc0a8136c3500000000000000010000000000000033000e0f05000000" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpGatewayHardware" /t REG_BINARY /d "c0a8136c0600000062a60dacd5e0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{bf0ec538-01df-4de9-b678-60879bdf23c5}" /v "DhcpGatewayHardwareCount" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\NsiObjectSecurity" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\PersistentRoutes" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlawaysOn" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d "1376256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Background Only" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Priority" /t REG_DWORD /d "6" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Background Only" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Priority" /t REG_DWORD /d "5" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Background Only" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "BackgroundPriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Scheduling Category" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Background Only" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Priority" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Priority" /t REG_DWORD /d "6" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Background Only" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Latency Sensitive" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "BackgroundPriority" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Priority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Priority" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Scheduling Category" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Background Only" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Priority" /t REG_DWORD /d "5" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "135" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "MaximumBuffers" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "MinimumBuffers" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "TimeoutSecs" /t REG_DWORD /d "30" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "ConvertibleSlateMode" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ8Priority" /t REG_DWORD /d "234" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ16Priority" /t REG_DWORD /d "234" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Description" /t REG_SZ /d "Controls the underlying video driver stacks to provide fully-featured display capabilities." /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DisplayName" /t REG_SZ /d "LDDM Graphics Subsystem" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "ErrorControl" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Group" /t REG_SZ /d "Video Init" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "ImagePath" /t REG_EXPAND_SZ /d "\SystemRoot\System32\drivers\dxgkrnl.sys" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Start" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Tag" /t REG_DWORD /d "16" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Type" /t REG_DWORD /d "32" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "MonitorLatencyTolerance" /t REG_BINARY /d "31ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff31fff0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "MonitorRefreshLatencyTolerance" /t REG_BINARY /d "31ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff31fff0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcWatchdogProfileOffset" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "ObUnsecureGlobalNames" /t REG_MULTI_SZ /d "netfxcustomperfcounters.1.0\0SharedPerfIPCBlock\0Cor_Private_IPCBlock\0Cor_Public_IPCBlock_" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "SeTokenSingletonAttributesConfig" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "obcaseinsensitive" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Description" /t REG_SZ /d "Controls the underlying video driver stacks to provide fully-featured display capabilities." /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DisplayName" /t REG_SZ /d "LDDM Graphics Subsystem" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "ErrorControl" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Group" /t REG_SZ /d "Video Init" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Start" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Tag" /t REG_DWORD /d "16" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "Type" /t REG_DWORD /d "32" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DistributeTimers" /t REG_DWORD /d "3839" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "MonitorLatencyTolerance" /t REG_DWORD /d "536870910" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "MonitorRefreshLatencyTolerance" /t REG_DWORD /d "536870910" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "WppRecorder_TraceGuid" /t REG_SZ /d "{fc8df8fd-d105-40a9-af75-2eec294adf8d}" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "21" /f

    # =========================================================
    # LANMAN SERVER
    # =========================================================
    Show-Step "LANMAN SERVER" 63
    Write-Host "[12/25] LANMAN SERVER..."
    $lanman = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
    Set-RegValue $lanman "autodisconnect" 0xFFFFFFFF
    Set-RegValue $lanman "Size" 3
    Set-RegValue $lanman "EnableOplocks" 0
    Set-RegValue $lanman "IRPStackSize" 32
    Set-RegValue $lanman "SharingViolationDelay" 0
    Set-RegValue $lanman "SharingViolationRetries" 0

    # =========================================================
    # FIVEM PRIORITY
    # =========================================================
    Show-Step "FIVEM PRIORITY" 66
    Write-Host "[13/25] FIVEM PRIORITY..."
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discord.exe\PerfOptions" "CpuPriorityClass" 1

    # =========================================================
    # MOUSE KEYS
    # =========================================================
    Show-Step "MOUSE KEYS" 68
    Write-Host "[14/25] MOUSE KEYS..."
    $mouse = "HKCU:\Control Panel\Accessibility\MouseKeys"
    Set-RegValue $mouse "Flags" "3000" "String"
    Set-RegValue $mouse "MaximumSpeed" "90000" "String"
    Set-RegValue $mouse "TimeToMaximumSpeed" "90000" "String"
    Set-RegValue $mouse "MaximumSpeed2" "90000" "String"
    Set-RegValue $mouse "TimeToMaximumSpeed2" "90000" "String"

    # =========================================================
    # SERVICES
    # =========================================================
    Show-Step "SERVICES" 70
    Write-Host "[15/25] SERVICES..."
    $services = @(
        "AxInstSV","tzautoupdate","bthserv","dmwappushservice",
        "MapsBroker","lfsvc","SharedAccess","lltdsvc",
        "AppVClient","NetTcpPortSharing","CscService","PhoneSvc",
        "PrintNotify","QWAVE","RmSvc","RemoteAccess",
        "SensorDataService","SensrSvc","SensorService",
        "SCardSvr","ScDeviceEnum","SSDPSRV","WiaRpc",
        "TabletInputService","upnphost","UserDataSvc",
        "UevAgentService","WalletService","FrameServer",
        "stisvc","wisvc","icssvc","XblAuthManager",
        "XblGameSave"
    )
    foreach ($svc in $services) { Run-Safe "Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue" }

    # =========================================================
    # NETWORK RESET
    # =========================================================
    Show-Step "NETWORK RESET" 72
    Write-Host "[16/25] NETWORK RESET..."
    Run-Safe 'netsh winsock reset'
    Run-Safe 'netsh winsock reset catalog'
    Run-Safe 'netsh int ip reset'
    Run-Safe 'netsh interface ipv4 reset'
    Run-Safe 'netsh interface ipv6 reset'

# =========================================================
# EXTRA FIVEM SAFE ADDITIONS
# =========================================================

Show-Step "FIVEM SAFE ADD" 73
Write-Host "[SAFE+] FIVEM EXTRA..."

# ---------------------------------------------------------
# SAFE PROCESS PRIORITY
# ---------------------------------------------------------

$FiveMExtra = @(
    "FiveM.exe",
    "FiveM_GTAProcess.exe",
    "GTA5.exe",
    "PlayGTAV.exe",
    "FiveM_b2372_GTAProcess.exe",
    "FiveM_b2545_GTAProcess.exe",
    "FiveM_b2699_GTAProcess.exe",
    "FiveM_b2802_GTAProcess.exe",
    "FiveM_b2944_GTAProcess.exe",
    "FiveM_b3095_GTAProcess.exe",
    "FiveM_b3258_GTAProcess.exe"
)

foreach ($proc in $FiveMExtra) {

    $perf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$proc\PerfOptions"

    Add-RegValueIfMissing $perf "CpuPriorityClass" 3
    Add-RegValueIfMissing $perf "IoPriority" 3
    Add-RegValueIfMissing $perf "PagePriority" 5
}

# ---------------------------------------------------------
# SAFE GPU PRIORITY
# ---------------------------------------------------------

Add-RegValueIfMissing `
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
"GPU Priority" 8

Add-RegValueIfMissing `
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
"Priority" 6

Add-RegValueIfMissing `
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
"Scheduling Category" "High" "String"

# ---------------------------------------------------------
# SAFE DIRECTX GPU PREFERENCE
# ---------------------------------------------------------

Add-RegValueIfMissing `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"FiveM.exe" `
"GpuPreference=2;" `
"String"

Add-RegValueIfMissing `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"FiveM_GTAProcess.exe" `
"GpuPreference=2;" `
"String"

# ---------------------------------------------------------
# SAFE INPUT DELAY
# ---------------------------------------------------------

Add-RegValueIfMissing `
"HKCU:\Control Panel\Desktop" `
"LowLevelHooksTimeout" `
"1000" `
"String"

Add-RegValueIfMissing `
"HKCU:\Control Panel\Desktop" `
"MenuShowDelay" `
"0" `
"String"

# ---------------------------------------------------------
# SAFE NETWORK LATENCY
# ---------------------------------------------------------

try {

    $Adapters = Get-ChildItem `
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

    foreach ($Adapter in $Adapters) {

        Add-RegValueIfMissing $Adapter.PSPath "TcpAckFrequency" 1
        Add-RegValueIfMissing $Adapter.PSPath "TCPNoDelay" 1
        Add-RegValueIfMissing $Adapter.PSPath "TcpDelAckTicks" 0
    }

}
catch {

    Write-Host "SKIPPED : SAFE NETWORK LATENCY" -ForegroundColor DarkYellow
}

    # =========================================================
    # REFRESH
    # =========================================================
    Show-Step "REFRESH" 74
    Write-Host "[17/25] REFRESH..."
    Run-Safe 'ipconfig /flushdns'
    Run-Safe 'ipconfig /registerdns'
    Run-Safe 'ipconfig /release'
    Run-Safe 'ipconfig /renew'
    Run-Safe 'arp -d *'
    Run-Safe 'netsh interface ip delete arpcache'

    # =========================================================
    # FIVEM EXTRA ONLY
    # =========================================================
    Show-Step "FIVEM EXTRA" 67
    Write-Host "[EXTRA] FIVEM EXTRA..."

    # =========================================================
    # FIVEM THREAD PRIORITY
    # =========================================================

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "CpuPriorityClass" 4
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "PagePriority" 5

    # =========================================================
    # GTA PROCESS BOOST
    # =========================================================

    Run-Safe 'wmic process where name="FiveM.exe" CALL setpriority 128'
    Run-Safe 'wmic process where name="FiveM_GTAProcess.exe" CALL setpriority 128'

    # =========================================================
    # NETWORK LATENCY BOOST
    # =========================================================

    Run-Safe 'netsh interface tcp set supplemental internet congestionprovider=ctcp'
    Run-Safe 'netsh interface tcp set supplemental internet autotuninglevel=disabled'

    # =========================================================
    # TCP ACK LOW LATENCY
    # =========================================================

    $Adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

    foreach ($Adapter in $Adapters) {

        try {

            New-ItemProperty -Path $Adapter.PSPath -Name "TcpAckFrequency" -PropertyType DWord -Value 1 -Force | Out-Null
            New-ItemProperty -Path $Adapter.PSPath -Name "TCPNoDelay" -PropertyType DWord -Value 1 -Force | Out-Null
            New-ItemProperty -Path $Adapter.PSPath -Name "TcpDelAckTicks" -PropertyType DWord -Value 0 -Force | Out-Null

        }
        catch {}

    }

    # =========================================================
    # NIC OPTIMIZATION
    # =========================================================

    Run-Safe "Disable-NetAdapterLso -Name `"$IFACE`""
    Run-Safe "Enable-NetAdapterRss -Name `"$IFACE`""
    Run-Safe "Enable-NetAdapterRsc -Name `"$IFACE`""

    # =========================================================
    # INTERRUPT PRIORITY
    # =========================================================

    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v IRQPriority /t REG_DWORD /d 1 /f'

    # =========================================================
    # GAME INPUT BOOST
    # =========================================================

    Run-Safe 'reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f'
    Run-Safe 'reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d 1 /f'

    # =========================================================
    # NVIDIA DRIVER LATENCY
    # =========================================================

    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v DisablePreemption /t REG_DWORD /d 1 /f'

    # =========================================================
    # POWER LATENCY
    # =========================================================

    Run-Safe 'powercfg -hibernate off'
    Run-Safe 'powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1'
    Run-Safe 'powercfg /setactive scheme_current'

    # =========================================================
    # CPU PARKING OFF
    # =========================================================

    Run-Safe 'powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100'
    Run-Safe 'powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100'

    # =========================================================
    # USB INPUT LATENCY
    # =========================================================

    Run-Safe 'powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE SUSPEND 0'

    # =========================================================
    # DNS FAST REFRESH
    # =========================================================

    Run-Safe 'ipconfig /flushdns'
    Run-Safe 'netsh winsock reset'

    # =========================================================
    # GPU HARDWARE ACCELERATION
    # =========================================================

    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f'

    # =========================================================
    # TIMER RESOLUTION BOOST
    # =========================================================

    Run-Safe 'bcdedit /set useplatformclock false'
    Run-Safe 'bcdedit /set disabledynamictick yes'
    Run-Safe 'bcdedit /set tscsyncpolicy Enhanced'

    # =========================================================
    # FIVEM ADDITIONAL ONLY
    # =========================================================
    Show-Step "FIVEM ADDITIONAL" 75
    Write-Host "[EXTRA+] FIVEM ADDITIONAL..."

    # =========================================================
    # FIVEM PROCESS PRIORITY (ADDITIONAL)
    # =========================================================
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "PagePriority" 5

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "PagePriority" 5

    # =========================================================
    # DISABLE FULLSCREEN OPTIMIZATIONS FOR FIVEM
    # =========================================================
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_FSEBehavior" 2
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_HonorUserFSEBehaviorMode" 1
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_DXGIHonorFSEWindowsCompatible" 1

    # =========================================================
    # GAME MODE FOR FIVEM
    # =========================================================
    Set-RegValue "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1
    Set-RegValue "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1

    # =========================================================
    # FIVEM GPU PREFERENCE
    # =========================================================
    Run-Safe 'reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FiveM.exe" /t REG_SZ /d "GpuPreference=2;" /f'
    Run-Safe 'reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FiveM_GTAProcess.exe" /t REG_SZ /d "GpuPreference=2;" /f'

    # =========================================================
    # FIVEM LAUNCH OPTIMIZATION
    # =========================================================
    Run-Safe 'taskkill /f /im FiveM.exe'
    Run-Safe 'taskkill /f /im FiveM_GTAProcess.exe'
    Run-Safe 'ipconfig /flushdns'
    Run-Safe 'arp -d *'
    Run-Safe 'Rundll32.exe advapi32.dll,ProcessIdleTasks'

    # =========================================================
    # OPTIONAL NIC OFFLOAD TWEAKS FOR GAMING
    # =========================================================
    try {
        $nic = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
        if ($null -ne $nic) {
            Disable-NetAdapterRsc -Name $nic.Name -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $nic.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $nic.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Host "SKIPPED : NIC optional tweaks" -ForegroundColor DarkYellow
    }

    # =========================================================
    # FIVEM STARTUP BOOST
    # =========================================================
    Run-Safe 'schtasks /Run /TN "\Microsoft\Windows\Gaming\GameDVR\GameDVR_Enabled"'

    # =========================================================
    # FIVEM NETWORK BOOST
    # =========================================================

    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f'

    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TcpAckFrequency /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TCPNoDelay /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TcpDelAckTicks /t REG_DWORD /d 0 /f'

    # =========================================================
    # FIVEM CPU PRIORITY
    # =========================================================

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2372_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2545_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2699_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2802_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2944_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b3095_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b3258_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3

    # =========================================================
    # FIVEM IO PRIORITY
    # =========================================================

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2372_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2545_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2699_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2f2_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2944_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b3095_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b3258_GTAProcess.exe\PerfOptions" "IoPriority" 3

    # =========================================================
    # FIVEM PAGE PRIORITY
    # =========================================================

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2372_GTAProcess.exe\PerfOptions" "PagePriority" 5
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2545_GTAProcess.exe\PerfOptions" "PagePriority" 5
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2699_GTAProcess.exe\PerfOptions" "PagePriority" 5
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2802_GTAProcess.exe\PerfOptions" "PagePriority" 5
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b2944_GTAProcess.exe\PerfOptions" "PagePriority" 5
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b3095_GTAProcess.exe\PerfOptions" "PagePriority" 5
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_b3258_GTAProcess.exe\PerfOptions" "PagePriority" 5

    # =========================================================
    # GPU PRIORITY
    # =========================================================

    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f'
    Run-Safe 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f'

    # =========================================================
    # FULLSCREEN OPTIMIZATION OFF
    # =========================================================

    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_DSEBehavior /t REG_DWORD /d 2 /f'
    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_EFSEFeatureFlags /t REG_DWORD /d 0 /f'

    # =========================================================
    # NVIDIA LOW LATENCY
    # =========================================================

    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableRID61684 /t REG_DWORD /d 1 /f'

    # =========================================================
    # TIMER RESOLUTION
    # =========================================================

    Run-Safe 'bcdedit /set disabledynamictick yes'
    Run-Safe 'bcdedit /set useplatformtick yes'
    Run-Safe 'bcdedit /set tscsyncpolicy Enhanced'

    # =========================================================
    # PROCESS CLEAN
    # =========================================================

    Run-Safe 'taskkill /f /im GameBar.exe'
    Run-Safe 'taskkill /f /im GameBarFTServer.exe'
    Run-Safe 'taskkill /f /im XboxPcApp.exe'

    # =========================================================
    # FIVEM PROCESS
    # =========================================================

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "PagePriority" 5

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "IoPriority" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "PagePriority" 5

    # =========================================================
    # GAME DVR OFF
    # =========================================================

    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f'
    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 2 /f'
    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f'
    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKCU\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 1 /f'

    Run-Safe 'reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f'

    # =========================================================
    # GAME MODE
    # =========================================================

    Run-Safe 'reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f'
    Run-Safe 'reg add "HKCU\Software\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f'
    Run-Safe 'reg add "HKCU\Software\Microsoft\GameBar" /v UseNexusForGameBarEnabled /t REG_DWORD /d 0 /f'

    # =========================================================
    # INPUT DELAY
    # =========================================================

    Run-Safe 'reg add "HKCU\Control Panel\Desktop" /v LowLevelHooksTimeout /t REG_SZ /d 1000 /f'
    Run-Safe 'reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d 2000 /f'
    Run-Safe 'reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 1000 /f'

    # =========================================================
    # GPU SCHEDULING
    # =========================================================

    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f'

    # =========================================================
    # DIRECTX
    # =========================================================

    Run-Safe 'reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FiveM.exe" /t REG_SZ /d "GpuPreference=2;" /f'

    # =========================================================
    # NETWORK REFRESH
    # =========================================================

    Run-Safe 'ipconfig /flushdns'

    # =========================================================
    # MEMORY CLEAN
    # =========================================================

    Run-Safe 'Rundll32.exe advapi32.dll,ProcessIdleTasks'

# =========================================================
# FIVEM EXTRA ADD ONLY
# เพิ่มอย่างเดียว / ไม่เขียนทับ
# =========================================================

Show-Step "FIVEM ADD ONLY" 76
Write-Host "[ADD ONLY] FIVEM SAFE EXTRA..."

# ---------------------------------------------------------
# FUNCTION
# ---------------------------------------------------------

function Add-RegIfNotExist {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )

    try {

        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        $exists = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue

        if ($null -eq $exists) {

            if ($Type -eq "String") {

                New-ItemProperty `
                    -Path $Path `
                    -Name $Name `
                    -PropertyType String `
                    -Value $Value `
                    -Force | Out-Null
            }
            else {

                New-ItemProperty `
                    -Path $Path `
                    -Name $Name `
                    -PropertyType DWord `
                    -Value ([uint32]$Value) `
                    -Force | Out-Null
            }

            Write-Host "ADDED : $Path\$Name" -ForegroundColor Green
        }
        else {

            Write-Host "SKIPPED : $Path\$Name" -ForegroundColor DarkYellow
        }

    }
    catch {

        Write-Host "FAILED : $Path\$Name" -ForegroundColor Red
    }
}

# ---------------------------------------------------------
# FIVEM PROCESS BOOST
# ---------------------------------------------------------

$FiveMAdd = @(
    "FiveM.exe",
    "FiveM_GTAProcess.exe",
    "GTA5.exe",
    "PlayGTAV.exe",
    "FiveM_b2372_GTAProcess.exe",
    "FiveM_b2545_GTAProcess.exe",
    "FiveM_b2699_GTAProcess.exe",
    "FiveM_b2802_GTAProcess.exe",
    "FiveM_b2944_GTAProcess.exe",
    "FiveM_b3095_GTAProcess.exe",
    "FiveM_b3258_GTAProcess.exe"
)

foreach ($proc in $FiveMAdd) {

    $perf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$proc\PerfOptions"

    Add-RegIfNotExist $perf "CpuPriorityClass" 3
    Add-RegIfNotExist $perf "IoPriority" 3
    Add-RegIfNotExist $perf "PagePriority" 5
}

# ---------------------------------------------------------
# GPU PREFERENCE
# ---------------------------------------------------------

Add-RegIfNotExist `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"FiveM.exe" `
"GpuPreference=2;" `
"String"

Add-RegIfNotExist `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"FiveM_GTAProcess.exe" `
"GpuPreference=2;" `
"String"

# ---------------------------------------------------------
# GAME DVR OFF
# ---------------------------------------------------------

Add-RegIfNotExist `
"HKCU:\System\GameConfigStore" `
"GameDVR_Enabled" `
0

Add-RegIfNotExist `
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
"AllowGameDVR" `
0

# ---------------------------------------------------------
# GAME MODE
# ---------------------------------------------------------

Add-RegIfNotExist `
"HKCU:\Software\Microsoft\GameBar" `
"AllowAutoGameMode" `
1

Add-RegIfNotExist `
"HKCU:\Software\Microsoft\GameBar" `
"AutoGameModeEnabled" `
1

# ---------------------------------------------------------
# LOW LATENCY NETWORK
# ---------------------------------------------------------

try {

    $Adapters = Get-ChildItem `
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

    foreach ($Adapter in $Adapters) {

        Add-RegIfNotExist $Adapter.PSPath "TcpAckFrequency" 1
        Add-RegIfNotExist $Adapter.PSPath "TCPNoDelay" 1
        Add-RegIfNotExist $Adapter.PSPath "TcpDelAckTicks" 0
    }

}
catch {

    Write-Host "SKIPPED : TCP ADD ONLY" -ForegroundColor DarkYellow
}

# ---------------------------------------------------------
# INPUT LATENCY
# ---------------------------------------------------------

Add-RegIfNotExist `
"HKCU:\Control Panel\Desktop" `
"LowLevelHooksTimeout" `
"1000" `
"String"

Add-RegIfNotExist `
"HKCU:\Control Panel\Desktop" `
"MenuShowDelay" `
"0" `
"String"

# ---------------------------------------------------------
# MMCSS GAME PROFILE
# ---------------------------------------------------------

$GamesKey = `
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"

Add-RegIfNotExist $GamesKey "GPU Priority" 8
Add-RegIfNotExist $GamesKey "Priority" 6

Add-RegIfNotExist `
$GamesKey `
"Scheduling Category" `
"High" `
"String"

Add-RegIfNotExist `
$GamesKey `
"SFIO Priority" `
"High" `
"String"

# ---------------------------------------------------------
# HW SCHEDULING
# ---------------------------------------------------------

Add-RegIfNotExist `
"HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
"HwSchMode" `
2

Write-Host ""
Write-Host "FIVEM ADD ONLY COMPLETE" -ForegroundColor Cyan
Write-Host ""

# =========================================================
# FIVEM SAFE ADD ONLY
# เพิ่มอย่างเดียว / ไม่แก้ / ไม่ลบ
# =========================================================

Show-Step "FIVEM SAFE ADD ONLY" 77
Write-Host "[ADD ONLY] FIVEM SAFE REGISTRY..."

function Add-OnlyReg {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )

    try {

        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        $exists = Get-ItemProperty `
            -Path $Path `
            -Name $Name `
            -ErrorAction SilentlyContinue

        if ($null -eq $exists) {

            if ($Type -eq "String") {

                New-ItemProperty `
                    -Path $Path `
                    -Name $Name `
                    -PropertyType String `
                    -Value $Value `
                    -Force | Out-Null
            }
            else {

                New-ItemProperty `
                    -Path $Path `
                    -Name $Name `
                    -PropertyType DWord `
                    -Value ([uint32]$Value) `
                    -Force | Out-Null
            }

            Write-Host "ADDED : $Path\$Name" -ForegroundColor Green
        }
        else {

            Write-Host "SKIPPED : $Path\$Name" -ForegroundColor DarkYellow
        }

    }
    catch {

        Write-Host "FAILED : $Path\$Name" -ForegroundColor Red
    }
}

# =========================================================
# PROCESS PRIORITY
# =========================================================

$FiveMProcesses = @(
    "FiveM.exe",
    "FiveM_GTAProcess.exe",
    "GTA5.exe",
    "PlayGTAV.exe",
    "FiveM_b2372_GTAProcess.exe",
    "FiveM_b2545_GTAProcess.exe",
    "FiveM_b2699_GTAProcess.exe",
    "FiveM_b2802_GTAProcess.exe",
    "FiveM_b2944_GTAProcess.exe",
    "FiveM_b3095_GTAProcess.exe",
    "FiveM_b3258_GTAProcess.exe"
)

foreach ($proc in $FiveMProcesses) {

    $perf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$proc\PerfOptions"

    Add-OnlyReg $perf "CpuPriorityClass" 3
    Add-OnlyReg $perf "IoPriority" 3
    Add-OnlyReg $perf "PagePriority" 5
}

# =========================================================
# GPU PREFERENCE
# =========================================================

Add-OnlyReg `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"FiveM.exe" `
"GpuPreference=2;" `
"String"

Add-OnlyReg `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"FiveM_GTAProcess.exe" `
"GpuPreference=2;" `
"String"

Add-OnlyReg `
"HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
"GTA5.exe" `
"GpuPreference=2;" `
"String"

# =========================================================
# GAME DVR OFF
# =========================================================

Add-OnlyReg `
"HKCU:\System\GameConfigStore" `
"GameDVR_Enabled" `
0

Add-OnlyReg `
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
"AllowGameDVR" `
0

# =========================================================
# GAME MODE
# =========================================================

Add-OnlyReg `
"HKCU:\Software\Microsoft\GameBar" `
"AllowAutoGameMode" `
1

Add-OnlyReg `
"HKCU:\Software\Microsoft\GameBar" `
"AutoGameModeEnabled" `
1

# =========================================================
# LOW LATENCY NETWORK
# =========================================================

try {

    $Adapters = Get-ChildItem `
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

    foreach ($Adapter in $Adapters) {

        Add-OnlyReg $Adapter.PSPath "TcpAckFrequency" 1
        Add-OnlyReg $Adapter.PSPath "TCPNoDelay" 1
        Add-OnlyReg $Adapter.PSPath "TcpDelAckTicks" 0
    }

}
catch {

    Write-Host "SKIPPED : NETWORK TWEAKS" -ForegroundColor DarkYellow
}

# =========================================================
# INPUT DELAY
# =========================================================

Add-OnlyReg `
"HKCU:\Control Panel\Desktop" `
"LowLevelHooksTimeout" `
"1000" `
"String"

Add-OnlyReg `
"HKCU:\Control Panel\Desktop" `
"MenuShowDelay" `
"0" `
"String"

# =========================================================
# MMCSS GAMES
# =========================================================

$GamesKey = `
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"

Add-OnlyReg $GamesKey "GPU Priority" 8
Add-OnlyReg $GamesKey "Priority" 6

Add-OnlyReg `
$GamesKey `
"Scheduling Category" `
"High" `
"String"

Add-OnlyReg `
$GamesKey `
"SFIO Priority" `
"High" `
"String"

# =========================================================
# GPU HARDWARE SCHEDULING
# =========================================================

Add-OnlyReg `
"HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
"HwSchMode" `
2

Write-Host ""
Write-Host "FIVEM SAFE ADD ONLY COMPLETE" -ForegroundColor Cyan
Write-Host ""

    # =========================================================
    # MTU
    # =========================================================
    Show-Step "MTU" 78
    Write-Host "[18/25] MTU..."
    Run-Safe "netsh interface ipv4 set subinterface `"$IFACE`" mtu=1500 store=persistent"
    Run-Safe "netsh interface ipv6 set subinterface `"$IFACE`" mtu=1500 store=persistent"

    # =========================================================
    # RESTART ADAPTER
    # =========================================================
    Show-Step "RESTART ADAPTER" 80
    Write-Host "[19/25] RESTART ADAPTER..."
    Run-Safe "Disable-NetAdapter -Name `"$IFACE`" -Confirm:`$false"
    Start-Sleep -Seconds 2
    Run-Safe "Enable-NetAdapter -Name `"$IFACE`" -Confirm:`$false"

    # =========================================================
    # DIAGNOSTIC
    # =========================================================
    Show-Step "DIAGNOSTIC" 83
    Write-Host "[20/25] DIAGNOSTIC..."
    Run-Safe 'netstat -an'

    # =========================================================
    # GPUPDATE
    # =========================================================
    Show-Step "GPUPDATE" 86
    Write-Host "[21/25] GPUPDATE..."
    Run-Safe 'gpupdate /force'

    # =========================================================
    # BCDEDIT
    # =========================================================
    Show-Step "BCDEDIT" 90
    Write-Host "[22/25] BCDEDIT..."
    Run-Safe 'bcdedit /set useplatformclock no'
    Run-Safe 'bcdedit /set useplatformtick yes'
    Run-Safe 'bcdedit /set disabledynamictick yes'
    Run-Safe 'bcdedit /set nx optout'

    # =========================================================
    # TIMER
    # =========================================================
    Show-Step "TIMER" 94
    Write-Host "[23/25] TIMER..."
    Start-Sleep -Milliseconds 500

    # =========================================================
    # FINALIZE
    # =========================================================
    Show-Step "FINALIZE" 96
    Write-Host "[24/25] FINALIZE..."
    Run-Safe 'Rundll32.exe advapi32.dll,ProcessIdleTasks'

    # =========================================================
    # COMPLETE
    # =========================================================
    Show-Step "COMPLETE" 100
    Write-Host "[25/25] COMPLETE..."
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host "                 OPTIMIZATION COMPLETE"
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "RESTART RECOMMENDED" -ForegroundColor Yellow
    Write-Host ""
    Pause
}

# =========================================================
# START
# =========================================================เ

while ($true) {
    Show-Menu
    $menu = Read-Host "SELECT"

    switch ($menu) {
        "1" { Apply-All }
        "2" { exit }
        default {
            Write-Host "INVALID" -ForegroundColor Red
            Start-Sleep 1
        }
    }
}