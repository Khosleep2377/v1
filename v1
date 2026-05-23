
# =========================================================
# SETTING
# =========================================================

# REQUIRE ADMIN
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

# =========================================================
# SETTING
# =========================================================

# REQUIRE ADMIN
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


# =========================================================
# TITLE
# =========================================================

$Host.UI.RawUI.WindowTitle = "SETTING"


# =========================================================
# PRO 
# =========================================================

$VALID_KEY = "404"

# ไฟล์เก็บ session
$sessionFile = "$env:APPDATA\gamingos_session.dat"

# ดึง HWID แบบง่าย
function Get-HWID {
    return (Get-WmiObject Win32_ComputerSystemProduct).UUID
}

$HWID = Get-HWID

# =========================================================
# CHECK SESSION (จำเครื่อง)
# =========================================================
function Check-Session {

    if (Test-Path $sessionFile) {

        $saved = Get-Content $sessionFile -ErrorAction SilentlyContinue

        if ($saved -eq $HWID) {
            return $true
        }
    }

    return $false
}

# =========================================================
# KEY SYSTEM
# =========================================================

$ADMIN_KEY = "4043"
$USER_KEY  = "22"
$MAX_TRY   = 99

function Show-Login {

    $try = 0

    while ($true) {

        Clear-Host

        Write-Host ""
        Write-Host " ███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ " -ForegroundColor Cyan
        Write-Host " ██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ " -ForegroundColor Cyan
        Write-Host " ███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗" -ForegroundColor Cyan
        Write-Host " ╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║" -ForegroundColor Cyan
        Write-Host " ███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝" -ForegroundColor Cyan
        Write-Host " ╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ " -ForegroundColor Cyan

        Write-Host ""
        Write-Host "==================== LOGIN SYSTEM ====================" -ForegroundColor DarkCyan
        Write-Host ""

        $KEY = Read-Host "ENTER KEY"

        if ($KEY -eq $VALID_KEY) {

            Write-Host ""
            Write-Host "LOGIN SUCCESS" -ForegroundColor Green
            Start-Sleep -Seconds 1
            return $true
        }
        else {

            $try++

            Write-Host ""
            Write-Host "INVALID KEY ($try/$MAX_TRY)" -ForegroundColor Red
            Start-Sleep -Seconds 2

            if ($try -ge $MAX_TRY) {

... (576 บรรทัด)

New Text Document.ps1
27 KB
น้อวนิว ผู้พิทักษ์โลก [aiko],  — 13:48

$Host.UI.RawUI.WindowTitle = "SETTING"

# =========================================================
# LOADING BAR
# =========================================================

# =========================================================
# SETTING
# =========================================================

# REQUIRE ADMIN
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


# =========================================================
# TITLE
# =========================================================

$Host.UI.RawUI.WindowTitle = "SETTING"


# =========================================================
# PRO 
# =========================================================

$VALID_KEY = "404"

# ไฟล์เก็บ session
$sessionFile = "$env:APPDATA\gamingos_session.dat"

# ดึง HWID แบบง่าย
function Get-HWID {
    return (Get-WmiObject Win32_ComputerSystemProduct).UUID
}

$HWID = Get-HWID

# =========================================================
# CHECK SESSION (จำเครื่อง)
# =========================================================
function Check-Session {

    if (Test-Path $sessionFile) {

        $saved = Get-Content $sessionFile -ErrorAction SilentlyContinue

        if ($saved -eq $HWID) {
            return $true
        }
    }

    return $false
}

# =========================================================
# KEY SYSTEM
# =========================================================

$ADMIN_KEY = "4043"
$USER_KEY  = "22"
$MAX_TRY   = 99

function Show-Login {

    $try = 0

    while ($true) {

        Clear-Host

        Write-Host ""
        Write-Host " ███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ " -ForegroundColor Cyan
        Write-Host " ██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ " -ForegroundColor Cyan
        Write-Host " ███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗" -ForegroundColor Cyan
        Write-Host " ╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║" -ForegroundColor Cyan
        Write-Host " ███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝" -ForegroundColor Cyan
        Write-Host " ╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ " -ForegroundColor Cyan

        Write-Host ""
        Write-Host "==================== LOGIN SYSTEM ====================" -ForegroundColor DarkCyan
        Write-Host ""

        $KEY = Read-Host "ENTER KEY"

        if ($KEY -eq $VALID_KEY) {

            Write-Host ""
            Write-Host "LOGIN SUCCESS" -ForegroundColor Green
            Start-Sleep -Seconds 1
            return $true
        }
        else {

            $try++

            Write-Host ""
            Write-Host "INVALID KEY ($try/$MAX_TRY)" -ForegroundColor Red
            Start-Sleep -Seconds 2

            if ($try -ge $MAX_TRY) {

                Write-Host ""
                Write-Host "TOO MANY FAILED ATTEMPTS" -ForegroundColor Red
                Start-Sleep -Seconds 2
                exit
            }
        }
    }
}
$Host.UI.RawUI.WindowTitle = "SETTING"

# =========================================================
# LOADING BAR
# =========================================================

function Show-Step {

    param (
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

    Start-Sleep -Milliseconds 350
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
function Get-Interface {

    $iface = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1).Name

    if (!$iface) {
        $iface = "Ethernet"
    }

    return $iface
}

function Apply-All {

    Clear-Host

    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "                     SETTING"
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""

    $IFACE = Get-Interface

Set-ExecutionPolicy Bypass -Scope Process

    # =========================================================
    # GROUP POLICY
    # =========================================================

    Show-Step "GROUP POLICY" 5

    Write-Host "[1/25] GROUP POLICY..."
    gpupdate /force

    # =========================================================
    # TCP STACK
    # =========================================================

    Show-Step "TCP STACK" 12

    Write-Host "[2/25] TCP STACK..."

    netsh int udp set global uro=disabled
    netsh interface tcp set global autotuninglevel=disabled
    netsh interface tcp set global rss=enabled
    netsh interface tcp set global chimney=enabled
    netsh interface tcp set global congestionprovider=ctcp
    netsh interface tcp set global ecncapability=enabled
    netsh interface tcp set global timestamps=disabled
    netsh interface tcp set heuristics disabled
    netsh int tcp set global rsc=enabled
    netsh int tcp set global maxsynretransmissions=2
    netsh int tcp set global initialrto=3000
    netsh int tcp set global delayedacktimeout=100
    netsh int tcp set global fastopen=enabled
    netsh int tcp set global pacingprofile=alwayson
    netsh int tcp set global hystart=enabled
    netsh int tcp set global dca=enabled
    netsh interface teredo set state disabled
    netsh interface ipv6 set teredo disabled
    netsh interface tcp set global netdma=enabled

    # =========================================================
    # DNS
    # =========================================================

    Show-Step "DNS" 21

    Write-Host "[3/25] DNS..."

    netsh interface ipv4 set dns name="$IFACE" static 8.8.8.8
    netsh interface ipv4 add dns name="$IFACE" 8.8.4.4 index=2

    netsh interface ipv6 set dnsservers "$IFACE" static 2001:4860:4860::8888
    netsh interface ipv6 add dnsservers "$IFACE" 2001:4860:4860::8844 index=2

    # =========================================================
    # IPV6
    # =========================================================

    Show-Step "IPV6" 27

    Write-Host "[4/25] IPV6..."

    netsh interface ipv6 set global randomizeidentifiers=disabled
    netsh interface ipv6 set privacy state=disabled

    # =========================================================
    # FPS + INPUT
    # =========================================================

    Show-Step "FPS + INPUT" 30

    Write-Host "[5/25] FPS + INPUT..."

    bcdedit /set useplatformtick yes
    bcdedit /set disabledynamictick yes
    bcdedit /set tscsyncpolicy enhanced

    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f

    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f

    powercfg -setactive SCHEME_MIN

    # =========================================================
    # SYSTEM PROFILE
    # =========================================================

    Show-Step "SYSTEM PROFILE" 42

    Write-Host "[6/25] SYSTEM PROFILE..."

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d 65536 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d 1 /f

    # =========================================================
    # ALL MMCSS TASKS
    # =========================================================

    Show-Step "MMCSS TASKS" 45

    Write-Host "[7/25] MMCSS TASKS..."

    $Tasks = @(
        "Audio",
        "Capture",
        "DisplayPostProcessing",
        "Distribution",
        "Games",
        "Playback",
        "Pro Audio"
    )

    foreach ($task in $Tasks) {

        $path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\$task"

        reg add "$path" /v "Affinity" /t REG_DWORD /d 1 /f
        reg add "$path" /v "Background Only" /t REG_SZ /d "False" /f
        reg add "$path" /v "Clock Rate" /t REG_DWORD /d 10000 /f
        reg add "$path" /v "GPU Priority" /t REG_DWORD /d 8 /f
        reg add "$path" /v "Priority" /t REG_DWORD /d 6 /f
        reg add "$path" /v "Scheduling Category" /t REG_SZ /d "High" /f
        reg add "$path" /v "SFIO Priority" /t REG_SZ /d "High" /f
        reg add "$path" /v "Latency Sensitive" /t REG_SZ /d "False" /f
    }

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "NoLazyMode" /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "BackgroundPriority" /t REG_DWORD /d 8 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "BackgroundPriority" /t REG_DWORD /d 6 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Priority" /t REG_DWORD /d 1 /f

    # =========================================================
    # MEMORY MANAGEMENT
    # =========================================================

    Show-Step "MEMORY MANAGEMENT" 47

    Write-Host "[8/25] MEMORY MANAGEMENT..."

    $MM = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"

    reg add "$MM" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f
    reg add "$MM" /v "LargeSystemCache" /t REG_DWORD /d 1 /f
    reg add "$MM" /v "NonPagedPoolQuota" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "NonPagedPoolSize" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "PagedPoolQuota" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "PagedPoolSize" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "SecondLevelDataCache" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "SessionPoolSize" /t REG_DWORD /d 4 /f
    reg add "$MM" /v "SessionViewSize" /t REG_DWORD /d 48 /f
    reg add "$MM" /v "SystemPages" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f
    reg add "$MM" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
    reg add "$MM" /v "EnableAsyncLazywrite" /t REG_DWORD /d 1 /f
    reg add "$MM" /v "EnablePerVolumeLazyWriter" /t REG_DWORD /d 1 /f
    reg add "$MM" /v "EnableCfg" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "DisablePageCombining" /t REG_DWORD /d 1 /f
    reg add "$MM" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "MoveImages" /t REG_DWORD /d 0 /f
    reg add "$MM" /v "FeatureSettings" /t REG_DWORD /d 1 /f
    reg add "$MM" /v "IoPageLockLimit" /t REG_DWORD /d 4294967295 /f
    reg add "$MM" /v "PhysicalAddressExtension" /t REG_DWORD /d 1 /f

    # =========================================================
    # PREFETCH
    # =========================================================

    Show-Step "PREFETCH" 50

    Write-Host "[9/25] PREFETCH..."

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "BootId" /t REG_DWORD /d 11 /f

    # =========================================================
    # PRIORITY CONTROL
    # =========================================================

    Show-Step "PRIORITY CONTROL" 55

    Write-Host "[10/25] PRIORITY CONTROL..."

    $PC = "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl"

    reg add "$PC" /v "ConvertibleSlateMode" /t REG_DWORD /d 0 /f
    reg add "$PC" /v "Win32PrioritySeparation" /t REG_DWORD /d 16397098 /f
    reg add "$PC" /v "IRQ8Priority" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "IRQ16Priority" /t REG_DWORD /d 2 /f
    reg add "$PC" /v "AdjustDpcThreshold" /t REG_DWORD /d 800 /f
    reg add "$PC" /v "DeepIoCoalescingEnabled" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "IdealDpcRate" /t REG_DWORD /d 800 /f
    reg add "$PC" /v "ForegroundBoost" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "SchedulerAssistThreadFlagOverride" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "ThreadBoostType" /t REG_DWORD /d 2 /f
    reg add "$PC" /v "ThreadSchedulingModel" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "IRQ0Priority" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "SystemResponsiveness" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "AVX2PriorityBoost" /t REG_DWORD /d 1 /f
    reg add "$PC" /v "Win32TimeSlice" /t REG_DWORD /d 1 /f

    # =========================================================
    # TCP PARAMETERS
    # =========================================================

    Show-Step "TCP PARAMETERS" 60

    Write-Host "[11/25] TCP PARAMETERS..."

# =====================================================
# INTERFACES GLOBAL
# =====================================================

$ifglobal = "HKLM:\SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces"

Set-RegValue $ifglobal "MTU" 0x9999FFFF
Set-RegValue $ifglobal "MSS" 0x7777FFFF
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
Set-RegValue $ifglobal "TcpRecSegmentSize" 0x002A5E65
Set-RegValue $ifglobal "EnablePMTUBHDetect" 0
Set-RegValue $ifglobal "EnablePMTUDiscovery" 1
Set-RegValue $ifglobal "GlobalMaxTcpWindowSize" 0x000AB227
Set-RegValue $ifglobal "MaxHashTableSize" 0x00010000
Set-RegValue $ifglobal "DisableTaskOffload" 0
Set-RegValue $ifglobal "WorldMaxTcpWindowsSize" 0x000AB227
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
Set-RegValue $ifglobal "CacheHashTableBucketSize" 0x22CB
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
Set-RegValue $ifglobal "MTS" 0x8888FFFF

# =====================================================
# LANMAN SERVER
# =====================================================

$lanman = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"

Set-RegValue $lanman "autodisconnect" 0xFFFFFFFF
Set-RegValue $lanman "Size" 3
Set-RegValue $lanman "EnableOplocks" 0
Set-RegValue $lanman "IRPStackSize" 32
Set-RegValue $lanman "SharingViolationDelay" 0
Set-RegValue $lanman "SharingViolationRetries" 0

# =====================================================
# FIVEM PRIORITY
# =====================================================

$fivem = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions"
Set-RegValue $fivem "CpuPriorityClass" 3

$fivemgta = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
Set-RegValue $fivemgta "CpuPriorityClass" 3

$discord = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discord.exe\PerfOptions"
Set-RegValue $discord "CpuPriorityClass" 1

# =====================================================
# MOUSE KEYS
# =====================================================

$mouse = "HKCU:\Control Panel\Accessibility\MouseKeys"

Set-RegValue $mouse "Flags" "3000" "String"
Set-RegValue $mouse "MaximumSpeed" "90000" "String"
Set-RegValue $mouse "TimeToMaximumSpeed" "90000" "String"
Set-RegValue $mouse "MaximumSpeed2" "90000" "String"
Set-RegValue $mouse "TimeToMaximumSpeed2" "90000" "String"

# =====================================================
# PRINT
# =====================================================

$print = "HKLM:\SYSTEM\CurrentControlSet\Control\Print"

Set-RegValue $print "PriorityClass" 1


    # =========================================================
    # INTERFACES
    # =========================================================

    Show-Step "INTERFACES" 62

    Write-Host "[12/25] INTERFACES..."

    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" | ForEach-Object {

        $p = $_.Name.Replace('HKEY_LOCAL_MACHINE','HKLM')

    }

    # =========================================================
    # REALTEK
    # =========================================================

    Show-Step "REALTEK" 66

    Write-Host "[13/25] REALTEK..."

    $adapterKeys = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"

    foreach ($key in $adapterKeys) {

        $path = $key.Name.Replace("HKEY_LOCAL_MACHINE","HKLM")


        Show-Status "[ POWER] Applying Ultimate Performance power plan..." "Magenta"
        Start-Process -WindowStyle Hidden -FilePath "powercfg.exe" -ArgumentList "-setactive SCHEME_MIN" -Wait

        Show-Status "[ INPUT] Keyboard repeat speed tuning..." "Violet"
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31"

        Show-Status "[ NET  ] Flushing DNS cache..." "Yellow"
        Start-Process -WindowStyle Hidden -FilePath "ipconfig.exe" -ArgumentList "/flushdns" -Wait

        Show-Status "[ NET  ] Optimizing TCP profile..." "Orange"
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global autotuninglevel=disabled" -Wait
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global rss=enabled" -Wait
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global chimney=enabled" -Wait

        Show-Status "[ APP  ] Closing heavy background apps..." "HotPink"
        $apps = "OneDrive","Skype","Teams","XboxAppServices","YourPhone","SteamWebHelper","Copilot"
       foreach($a in $apps){
        Get-Process $a -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }

}

    # =========================================================
    # SERVICES
    # =========================================================

    Show-Step "SERVICES" 70

    Write-Host "[14/25] SERVICES..."

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

    foreach ($svc in $services) {
        Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }

    # =========================================================
    # NETWORK RESET
    # =========================================================

    Show-Step "NETWORK RESET" 72

    Write-Host "[15/25] NETWORK RESET..."

    netsh winsock reset
    netsh winsock reset catalog
    netsh int ip reset
    netsh interface ipv4 reset
    netsh interface ipv6 reset

    # =========================================================
    # REFRESH
    # =========================================================

    Show-Step "REFRESH" 74

    Write-Host "[16/25] REFRESH..."

    ipconfig /flushdns
    ipconfig /registerdns
    ipconfig /release
    ipconfig /renew

    arp -d *

    netsh interface ip delete arpcache

    # =========================================================
    # MTU
    # =========================================================

    Show-Step "MTU" 77

    Write-Host "[17/25] MTU..."

    netsh interface ipv4 set subinterface "$IFACE" mtu=1500 store=persistent
    netsh interface ipv6 set subinterface "$IFACE" mtu=1500 store=persistent

    # =========================================================
    # RESTART ADAPTER
    # =========================================================

    Show-Step "RESTART ADAPTER" 80

    Write-Host "[18/25] RESTART ADAPTER..."

    Disable-NetAdapter -Name "$IFACE" -Confirm:$false
    Start-Sleep -Seconds 2
    Enable-NetAdapter -Name "$IFACE" -Confirm:$false

    # =========================================================
    # DIAGNOSTIC
    # =========================================================

    Show-Step "DIAGNOSTIC" 83

    Write-Host "[19/25] DIAGNOSTIC..."

    netstat -an

    # =========================================================
    # GPUPDATE
    # =========================================================

    Show-Step "GPUPDATE" 86

    Write-Host "[20/25] GPUPDATE..."

    gpupdate /force

    # =========================================================
    # BCDEDIT
    # =========================================================

    Show-Step "BCDEDIT" 90

    Write-Host "[21/25] BCDEDIT..."

    bcdedit /set useplatformclock no
    bcdedit /set useplatformtick yes
    bcdedit /set disabledynamictick yes
    bcdedit /set nx optout

    # =========================================================
    # TIMER
    # =========================================================

    Show-Step "TIMER" 94

    Write-Host "[22/25] TIMER..."

    Start-Sleep -Milliseconds 500

    # =========================================================
    # FINALIZE
    # =========================================================

    Show-Step "DNS" 96

    Write-Host "[23/25] FINALIZE..."
    Rundll32.exe advapi32.dll,ProcessIdleTasks

    # =========================================================
    # CLEAN
    # =========================================================

    Show-Step "CLEANUP" 98

    Write-Host "[24/25] CLEAN..."

    Clear-Host

    # =========================================================
    # COMPLETE
    # =========================================================

    Show-Step "COMPLETE" 100

    Write-Host "[25/25] COMPLETE..."

    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host "                 OPTIMIZATION COMPLETE"
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "RESTART RECOMMENDED"
    Write-Host ""

    Pause
}

# =========================================================
# START (IMPORTANT FIX)
# =========================================================
Show-Login

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
