# =========================================================
# SETTING
# =========================================================

# REQUIRE ADMIN
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "SETTING"

# =========================================================
# FUNCTIONS
# =========================================================

function Show-Step {
    param(
        [string]$Text,
        [int]$Percent
    )

    $barsize = 50
    $filled  = [math]::Floor(($Percent / 100) * $barsize)
    $bar = ("█" * $filled).PadRight($barsize, "░")

    Clear-Host
    Write-Host ""
    Write-Host " ███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ " -ForegroundColor Cyan
    Write-Host " ██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ " -ForegroundColor Cyan
    Write-Host " ███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗" -ForegroundColor Cyan
    Write-Host " ╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║" -ForegroundColor Cyan
    Write-Host " ███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝" -ForegroundColor Cyan
    Write-Host " ╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host " $Text" -ForegroundColor Green
    Write-Host ""
    Write-Host " [$bar] $Percent%" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor DarkCyan

    Start-Sleep -Milliseconds 250
}

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host "                     SETTING"
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

# =========================================
# PROJECT S - SYSTEM OPTIMIZER
# =========================================

Add-Type -AssemblyName System.Windows.Forms

# -------------------------
# STATUS FUNCTION
# -------------------------
function Show-Status {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

# -------------------------
# MAIN CLEANER
# -------------------------
function Start-ProjectS {

    try {

        # =========================
        # NETWORK
        # =========================
        Show-Status "[ NET  ] Flushing DNS cache..." "Yellow"
        Start-Process -WindowStyle Hidden -FilePath "ipconfig.exe" -ArgumentList "/flushdns" -Wait

        Show-Status "[ NET  ] Optimizing TCP profile..." "Cyan"
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global autotuninglevel=disabled" -Wait
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global rss=enabled" -Wait
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global chimney=enabled" -Wait

        # =========================
        # APP KILL
        # =========================
        Show-Status "[ APP  ] Closing heavy background apps..." "Magenta"

        $apps = @(
            "OneDrive",
            "Skype",
            "Teams",
            "XboxAppServices",
            "YourPhone",
            "SteamWebHelper",
            "Copilot"
        )

        foreach ($a in $apps) {
            Get-Process -Name $a -ErrorAction SilentlyContinue |
                Stop-Process -Force -ErrorAction SilentlyContinue
        }

        # =========================
        # TEMP CLEAN
        # =========================
        Show-Status "[ TEMP ] Cleaning user temp files..." "White"
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

        Show-Status "[ TEMP ] Cleaning Windows temp files..." "White"
        Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

        # =========================
        # DONE
        # =========================
        Show-Status "[ DONE ] PROJECT S READY" "Green"

    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Run this program as Administrator.",
            "PROJECT S"
        )

        Show-Status "[ WARN ] Some commands require administrator rights." "Yellow"
    }
}

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
    Show-Step "GROUP POLICY" 2
    Write-Host "[1/25] GROUP POLICY..."
    Run-Safe 'gpupdate /force'

# =========================================================
# BASIC RESET / CLEAN
# =========================================================

ipconfig /flushdns
ipconfig /registerdns
ipconfig /release
ipconfig /renew

netsh winsock reset
netsh winsock reset catalog
netsh int ip reset
netsh int ip reset resetlog.txt

arp -d
netsh interface ipv4 reset
netsh interface ipv6 reset
netsh interface ip delete arpcache


# =========================================================
# TCP GLOBAL STACK
# =========================================================

netsh interface tcp set global autotuninglevel=disabled
netsh interface tcp set global rss=enabled
netsh interface tcp set global chimney=enabled
netsh interface tcp set global congestionprovider=ctcp
netsh interface tcp set global ecncapability=enabled
netsh interface tcp set global timestamps=disabled
netsh interface tcp set heuristics disabled
netsh interface tcp set global netdma=enabled
netsh interface tcp set global rsc=enabled

netsh int tcp set global maxsynretransmissions=2
netsh int tcp set global initialrto=3000
netsh int tcp set global delayedacktimeout=100

netsh int tcp set global fastopen=enabled
netsh int tcp set global pacingprofile=alwayson
netsh int tcp set global hystart=enabled
netsh int tcp set global dca=enabled

netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set security mpp=disabled
netsh int tcp set security profiles=disabled

netsh int udp set global uro=disabled


# =========================================================
# IPV6 / TEREDO
# =========================================================

netsh interface teredo set state disabled
netsh interface ipv6 set teredo disabled

netsh interface ipv6 set global randomizeidentifiers=disabled
netsh interface ipv6 set privacy state=disabled


# =========================================================
# DNS SETTINGS (8.8.8.8)
# =========================================================

$IFACE = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1).Name

netsh interface ipv4 set dns name="$IFACE" static 8.8.8.8
netsh interface ipv4 add dns name="$IFACE" 8.8.4.4 index=2

netsh interface ipv6 set dnsservers "$IFACE" static 2001:4860:4860::8888
netsh interface ipv6 add dnsservers "$IFACE" 2001:4860:4860::8844 index=2


# =========================================================
# ADVANCED INTERFACE SETTINGS
# =========================================================

netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
netsh interface ipv6 set subinterface "Ethernet" mtu=1500 store=persistent

netsh interface set interface "Ethernet" admin=enabled


# =========================================================
# FIREWALL (OPTIONAL DISABLE)
# =========================================================

netsh advfirewall set allprofiles state off


# =========================================================
# POWERSHELL ADAPTER OPTIMIZATION
# =========================================================

Disable-NetAdapterPowerManagement -Name "*" -ErrorAction SilentlyContinue
Disable-NetAdapterEncapsulatedPacketTaskOffload -Name "*" -ErrorAction SilentlyContinue
Disable-NetAdapterLso -Name "*" -ErrorAction SilentlyContinue
Enable-NetAdapterPacketDirect -Name "*" -ErrorAction SilentlyContinue
Disable-NetAdapterRsc -Name "*" -ErrorAction SilentlyContinue
Enable-NetAdapterRss -Name "*" -ErrorAction SilentlyContinue


# =========================================================
# REGISTRY TCP TWEAK (GLOBAL)
# =========================================================

$tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"

New-ItemProperty $tcp "SackOpts" 0 -Force
New-ItemProperty $tcp "Tcp1323Opts" 0 -Force
New-ItemProperty $tcp "DisableTaskOffload" 0 -Force
New-ItemProperty $tcp "EnableConnectionRateLimiting" 0 -Force
New-ItemProperty $tcp "EnableDCA" 1 -Force
New-ItemProperty $tcp "TcpTimedWaitDelay" 60 -Force
New-ItemProperty $tcp "MaxUserPort" 65534 -Force


# =========================================================
# DNS PRIORITY
# =========================================================

$svc = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider"

New-ItemProperty $svc "DnsPriority" 6 -Force
New-ItemProperty $svc "LocalPriority" 4 -Force
New-ItemProperty $svc "NetbtPriority" 7 -Force
New-ItemProperty $svc "HostPriority" 5 -Force


# =========================================================
# NLA PROBING DISABLE
# =========================================================

$nla = "HKLM:\System\ControlSet001\services\NlaSvc\Parameters\Internet"

New-ItemProperty $nla "EnableActiveProbing" 0 -Force
New-ItemProperty $nla "EnableUserActiveProbing" 0 -Force
New-ItemProperty $nla "MaxActiveProbes" 1 -Force


# =========================================================
# GPU (NVIDIA) REGISTRY TWEAKS
# =========================================================

$gpu = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"

New-ItemProperty $gpu "DisableDynamicPstate" 1 -Force
New-ItemProperty $gpu "DisableAsyncPstates" 1 -Force
New-ItemProperty $gpu "RMDisableGpuASPMFlags" 3 -Force
New-ItemProperty $gpu "RMEnableASPMDT" 1 -Force
New-ItemProperty $gpu "RmOverrideSupportChipsetAspm" 1 -Force
New-ItemProperty $gpu "RML1ExitLatencyOverride" 1 -Force
New-ItemProperty $gpu "PciLatencyTimerControl" 4294967295 -Force
New-ItemProperty $gpu "RMDisableLRCCoalescing" 1 -Force
New-ItemProperty $gpu "RMDisablePerIntrDPCQueueing" 1 -Force
New-ItemProperty $gpu "DisableOverlay" 1 -Force
New-ItemProperty $gpu "GrCtxSwMode" 2 -Force

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

    # =========================================================
    # PRIORITY CONTROL
    # =========================================================
    Show-Step "PRIORITY CONTROL" 55
    Write-Host "[10/25] PRIORITY CONTROL..."
    $PC = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    Set-RegValue $PC "ConvertibleSlateMode" 0
    Set-RegValue $PC "Win32PrioritySeparation" 16397098
    Set-RegValue $PC "IRQ8Priority" 1
    Set-RegValue $PC "IRQ16Priority" 2
    Set-RegValue $PC "AdjustDpcThreshold" 800
    Set-RegValue $PC "DeepIoCoalescingEnabled" 1
    Set-RegValue $PC "IdealDpcRate" 800
    Set-RegValue $PC "ForegroundBoost" 1
    Set-RegValue $PC "SchedulerAssistThreadFlagOverride" 1
    Set-RegValue $PC "ThreadBoostType" 2
    Set-RegValue $PC "ThreadSchedulingModel" 1
    Set-RegValue $PC "IRQ0Priority" 1
    Set-RegValue $PC "SystemResponsiveness" 1
    Set-RegValue $PC "AVX2PriorityBoost" 1
    Set-RegValue $PC "Win32TimeSlice" 1

    # =========================================================
    # TCP PARAMETERS
    # =========================================================
    Show-Step "TCP PARAMETERS" 60
    Write-Host "[11/25] TCP PARAMETERS..."

    $ifglobal = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-RegValue $ifglobal "TcpAckFrequency" 7
    Set-RegValue $ifglobal "TcpDelAckTicks" 2
    Set-RegValue $ifglobal "NumTcbTablePartitions" 9
    Set-RegValue $ifglobal "TCPNoDelay" 4
    Set-RegValue $ifglobal "TcpWindowSize" 0x000B2390
    Set-RegValue $ifglobal "SackOpts" 3
    Set-RegValue $ifglobal "TcpMaxDataRetransmissions" 4
    Set-RegValue $ifglobal "Tcp1323Opts" 2
    Set-RegValue $ifglobal "TCPTimedWaitDelay" 33
    Set-RegValue $ifglobal "IRPStackSize" 34
    Set-RegValue $ifglobal "DefaultTTL" 79
    Set-RegValue $ifglobal "KeepAliveTime" 90000
    Set-RegValue $ifglobal "KeepAliveInterval" 3000
    Set-RegValue $ifglobal "TCPInitialRtt" 700
    Set-RegValue $ifglobal "TcpMaxDupAcks" 2
    Set-RegValue $ifglobal "EnablePMTUBHDetect" 0
    Set-RegValue $ifglobal "EnablePMTUDiscovery" 1
    Set-RegValue $ifglobal "MaxHashTableSize" 0x00010000
    Set-RegValue $ifglobal "DisableTaskOffload" 0
    Set-RegValue $ifglobal "TCPAllowedPorts" 3
    Set-RegValue $ifglobal "NTEContextList" 5
    Set-RegValue $ifglobal "DisableLargeMTU" 1
    Set-RegValue $ifglobal "IGMPVersion" 4
    Set-RegValue $ifglobal "IGMPLevel" 3
    Set-RegValue $ifglobal "MaxConnectionsPer1_0Server" 24
    Set-RegValue $ifglobal "MaxConnectionsPerServer" 24
    Set-RegValue $ifglobal "MaxFreeTcbs" 0x00012AC2
    Set-RegValue $ifglobal "ArpTRSingleRoute" 3
    Set-RegValue $ifglobal "SynAttackProtect" 1
    Set-RegValue $ifglobal "MaxForwardBufferMemory" 0x0003BFD8
    Set-RegValue $ifglobal "ForwardBufferMemory" 0x0002AAF2
    Set-RegValue $ifglobal "NumForwardPackets" 0x000002AF
    Set-RegValue $ifglobal "MaxNumForwardPackets" 0x000002AF
    Set-RegValue $ifglobal "MaxUserPort" 0x00012AC2
    Set-RegValue $ifglobal "TcpMaxSendFree" 0x00012AB9
    Set-RegValue $ifglobal "DeadGWDetectDefault" 3
    Set-RegValue $ifglobal "DontAddDefaultGatewayDefault" 1
    Set-RegValue $ifglobal "MaxMpxCt" 0xAF
    Set-RegValue $ifglobal "EnableICMPRedirect" 2
    Set-RegValue $ifglobal "EnableWsd" 1
    Set-RegValue $ifglobal "EnableDynamicBacklog" 2
    Set-RegValue $ifglobal "EnableDHCP" 3
    Set-RegValue $ifglobal "AllowUnqualifiedQuery" 2
    Set-RegValue $ifglobal "DisableMediaSenseEventLog" 3
    Set-RegValue $ifglobal "DisableRss" 4
    Set-RegValue $ifglobal "DisableTcpChimneyOffload" 1
    Set-RegValue $ifglobal "DnsOutstandingQueriesCount" 3000
    Set-RegValue $ifglobal "EnableAddrMaskReply" 4
    Set-RegValue $ifglobal "EnableBcastArpReply" 2
    Set-RegValue $ifglobal "EnableConnectionRateLimiting" 4
    Set-RegValue $ifglobal "EnableDca" 0
    Set-RegValue $ifglobal "EnableHeuristics" 3
    Set-RegValue $ifglobal "EnableIPAutoConfigurationLimits" 1
    Set-RegValue $ifglobal "EnableTCPA" 4
    Set-RegValue $ifglobal "IPEnableRouter" 7
    Set-RegValue $ifglobal "QualifyingDestinationThreshold" 0x000B22C4
    Set-RegValue $ifglobal "StrictTimeWaitSeqCheck" 4

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

    Run-Safe 'wmic process where name="FiveM.exe" CALL setpriority 512'
    Run-Safe 'wmic process where name="FiveM_GTAProcess.exe" CALL setpriority 512'

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
    Run-Safe 'reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v DisablePreemption /t REG_DWORD /d 1 /f'

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

# =========================
# ZEACROSS POWER ENGINE PRO
# =========================

Write-Host "ZEACROSS POWER ENGINE START..." -ForegroundColor Cyan

# =========================
# CREATE PLAN (SAFE)
# =========================
$raw = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
$guid = ($raw | Select-String -Pattern "[a-f0-9\-]{36}").Matches.Value

if (-not $guid) {
    Write-Host "FAILED TO CREATE POWER PLAN" -ForegroundColor Red
    exit
}

# =========================
# RENAME PLAN
# =========================
powercfg /changename $guid "Zeacross" "Zeacross Gaming Pro Mode"

# =========================
# CPU PERFORMANCE MODE
# =========================
powercfg /setacvalueindex $guid SUB_PROCESSOR PROCTHROTTLEMIN 90
powercfg /setacvalueindex $guid SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex $guid SUB_PROCESSOR PERFBOOSTMODE 1
powercfg /setacvalueindex $guid SUB_PROCESSOR SYSTEMCOOLINGPOLICY 1

# =========================
# DISABLE POWER SAVING DELAYS
# =========================
powercfg /change -standby-timeout-ac 0
powercfg /change -hibernate-timeout-ac 0
powercfg /change -monitor-timeout-ac 0

# =========================
# USB / PCI PERFORMANCE
# =========================
powercfg /setacvalueindex $guid SUB_USB USBSELECTSUSPEND 0
powercfg /setacvalueindex $guid SUB_PCIEXPRESS ASPM 0

# =========================
# APPLY PLAN
# =========================
powercfg /setactive $guid

# =========================
# VERIFY
# =========================
$active = powercfg /getactivescheme

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