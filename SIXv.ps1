# =========================================================
# SIXv
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
    Write-Host "                     SIXv"
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
    Write-Host "                     SIXv"
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

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discord.exe\PerfOptions" "CpuPriorityClass" 1

Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "CpuPriorityClass" 3
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "IoPriority" 3
Add-RegValueIfMissing "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" "PagePriority" 5

# =========================================================
# MOUSE
# =========================================================
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f


# =========================================================
# DESKTOP
# =========================================================
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f


# =========================================================
# SYSTEM PROFILE (MULTIMEDIA)
# =========================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NoLazyMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v LazyModeTimeout /t REG_DWORD /d 65536 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v AlwaysOn /t REG_DWORD /d 1 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f


# =========================================================
# GAME TASKS
# =========================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f


# =========================================================
# POWER SETTINGS
# =========================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v ValueMax /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v ValueMin /t REG_DWORD /d 0 /f


# =========================================================
# VISUAL / DWM
# =========================================================
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v Composition /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v UseDpiScaling /t REG_DWORD /d 0 /f


# =========================================================
# EXPLORER
# =========================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 3 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f


# =========================================================
# AUDIO
# =========================================================
reg add "HKCU\Software\Microsoft\Multimedia\Audio" /v UserDuckingPreference /t REG_DWORD /d 3 /f


# =========================================================
# DXGKRNL
# =========================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v MonitorLatencyTolerance /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v MonitorRefreshLatencyTolerance /t REG_DWORD /d 1 /f


# =========================================================
# GRAPHICS POWER
# =========================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultD3TransitionLatencyActivelyUsed /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultD3TransitionLatencyIdleLongTime /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultD3TransitionLatencyIdleMonitorOff /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultD3TransitionLatencyIdleNoContext /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultD3TransitionLatencyIdleShortTime /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultD3TransitionLatencyIdleVeryLongTime /t REG_DWORD /d 1 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceIdle0 /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceIdle0MonitorOff /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceIdle1 /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceIdle1MonitorOff /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceMemory /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceNoContext /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceOther /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v DefaultLatencyToleranceTimerPeriod /t REG_DWORD /d 1 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v MaxIAverageGraphicsLatencyInOneBucket /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v MiracastPerfTrackGraphicsLatency /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v MonitorLatencyTolerance /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v MonitorRefreshLatencyTolerance /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v TransitionLatency /t REG_DWORD /d 1 /f


# =========================================================
# SESSION / SYSTEM POWER
# =========================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\ModernSleep" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v CoalescingTimerInterval /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v PlatformAoAcOverride /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v EnergyEstimationEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v EventProcessorEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v CsEnabled /t REG_DWORD /d 0 /f


# =========================================================
# FTH / SERVICES / EDGE / CHROME
# =========================================================
reg add "HKLM\SOFTWARE\Microsoft\FTH" /v Enabled /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f

reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdate" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdatem" /v Start /t REG_DWORD /d 4 /f


# =========================================================
# EXTRA UI
# =========================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\VideoSettings" /v VideoQualityOnBattery /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" /v DisableStartupSound /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v ctfmon /t REG_SZ /d "C:\Windows\System32\ctfmon.exe" /f
	
# =========================================================
# EXPLORER
# =========================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f


# =========================================================
# TELEMETRY
# =========================================================
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\safer\codeidentifiers" /v "authenticodeenabled" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f


# =========================================================
# SPEECH / INPUT PRIVACY
# =========================================================
reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f


# =========================================================
# DIAG
# =========================================================
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "ShowedToastAtLevel" /t REG_DWORD /d 1 /f


# =========================================================
# DELIVERY OPTIMIZATION
# =========================================================
reg add "HKU\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DownloadMode" /t REG_DWORD /d 0 /f


# =========================================================
# PRIVACY
# =========================================================
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f


# =========================================================
# DRIVER / DEVICE
# =========================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f


# =========================================================
# WINDOWS UPDATE
# =========================================================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f


# =========================================================
# CAPABILITY DENY
# =========================================================
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Deny" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" /v "Value" /t REG_SZ /d "Deny" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Deny" /f


# =========================================================
# CONTENT DELIVERY
# =========================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d 0 /f


# =========================================================
# ACTIVITY FEED
# =========================================================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f


# =========================================================
# BACKGROUND / SEARCH
# =========================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f


# =========================================================
# MAINTENANCE
# =========================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f


# =========================================================
# NOTIFICATION / FEEDS
# =========================================================
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f


# =========================================================
# EDGE / REMOTE
# =========================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f


# =========================================================
# LANMAN SERVER
# =========================================================
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "autodisconnect" /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "EnableOplocks" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d 32 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "SharingViolationDelay" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "SharingViolationRetries" /t REG_DWORD /d 0 /f


# =========================================================
# MULTIMEDIA
# =========================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d 1 /f

# =========================================================
# POWER / CPU / PERFORMANCE
# =========================================================

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" /v "fDisablePowerManagement" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PDC\Activators\Default\VetoPolicy" /v "EA:EnergySaverEngaged" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PDC\Activators\28\VetoPolicy" /v "EA:PowerStateDischarging" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Misc" /v "DeviceIdlePolicy" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "PerfEnergyPreference" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "PerfEnergyPreference" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMinCores" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMaxCores" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMinCores1" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMaxCores1" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CpLatencyHintUnpark1" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPDistribution" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CpLatencyHintUnpark" /t REG_DWORD /d "100" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "MaxPerformance1" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "MaxPerformance" /t REG_DWORD /d "100" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPDistribution1" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPHEADROOM" /t REG_DWORD /d "0" /f

reg add "HKCU\Control Panel\PowerCfg\GlobalPowerPolicy" /v "Policies" /t REG_BINARY /d "01000000020000000100000000000000020000000000000000000000000000002c0100003232030304000000040000000000000000000000840300002c01000000000000840300000001646464640000" /f
reg add "HKCU\Control Panel\PowerCfg\GlobalPowerPolicy" /v "Policies" /t REG_BINARY /d "01000000020000000100000000000000020000000000000000000000000000002c0100003232030304000000040000000000000000000000840300002c01000000000000840300000001646464640000" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Processor" /v "Cstates" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Processor" /v "Capabilities" /t REG_DWORD /d "516198" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HighPerformance" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HighestPerformance" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MinimumThrottlePercent" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaximumThrottlePercent" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaximumPerformancePercent" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "Class1InitialUnparkCount" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "InitialUnparkCount" /t REG_DWORD /d "100" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f

reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "ProccesorThrottlingEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleThreshold" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdle" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuLatencyTimer" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuSlowdown" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "DedicatedSegmentSize" /t REG_DWORD /d "1298" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "Threshold" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuDebuggingEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "ProccesorLatencyThrottlingEnabled" /t REG_DWORD /d "0" /f


# =========================================================
# EXPLORER / UI
# =========================================================

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAHealth" /t REG_DWORD /d "1" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ExtendedUIHoverTime" /t REG_DWORD /d "196608" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontPrettyPath" /t REG_DWORD /d "1" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f


# =========================================================
# EXPLORER POLICIES
# =========================================================

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoLowDiskSpaceChecks" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInstrumentation" /t REG_DWORD /d "1" /f


# =========================================================
# CPU IDLE SCRUB (RAW AS PROVIDED)
# =========================================================

reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubDelay" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubInterval" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubPower" /t REG_DWORD /d "18" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubThreshold" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubType" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValue" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueMaximum" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueMinimum" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueStep" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueDefault" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueCurrent" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValuePrevious" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueNext" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueLast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueFirst" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueCount" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\ControlSet001\Control\Processor" /v "CpuIdleScrubValueIndex" /t REG_DWORD /d "42" /f


# =========================================================
# VxD BIOS (LEGACY BLOCK - RAW)
# =========================================================

reg add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "CPUPriority" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "FastDRAM" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "AGPConcur" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "PCIConcur" /t REG_DWORD /d "1" /f


# =========================================================
# SECURITY / GAMING
# =========================================================

reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d "0" /f


# =========================================================
# GAME DVR
# =========================================================

reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f

reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f

# ================================
# REGISTRY
# ================================

Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\safer\codeidentifiers" /v "authenticodeenabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "ShowedToastAtLevel" /t REG_DWORD /d "1" /f

Reg.exe add "HKU\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f

Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f

Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Deny" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" /v "Value" /t REG_SZ /d "Deny" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Deny" /f

Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f

Reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DownloadMode" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f

Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f

Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f

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
    Show-Step "GROUP POLICY" 2
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
    Run-Safe 'powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61'

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
    
# ========================================
# TCP/IP Service Provider
# ========================================
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v LocalPriority /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v HostsPriority /t REG_DWORD /d 5 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v DnsPriority /t REG_DWORD /d 6 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v NetbtPriority /t REG_DWORD /d 7 /f


# ========================================
# Core TCP/IP Parameters
# ========================================
$tcpip = "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"

reg add $tcpip /v DefaultTTL /t REG_DWORD /d 64 /f
reg add $tcpip /v DisableTaskOffload /t REG_DWORD /d 1 /f
reg add $tcpip /v EnableConnectionRateLimiting /t REG_DWORD /d 0 /f
reg add $tcpip /v EnableDCA /t REG_DWORD /d 1 /f
reg add $tcpip /v EnablePMTUBHDetect /t REG_DWORD /d 0 /f
reg add $tcpip /v EnablePMTUDiscovery /t REG_DWORD /d 1 /f
reg add $tcpip /v EnableRSS /t REG_DWORD /d 1 /f
reg add $tcpip /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f
reg add $tcpip /v EnableWsd /t REG_DWORD /d 0 /f
reg add $tcpip /v GlobalMaxTcpWindowSize /t REG_DWORD /d 65535 /f
reg add $tcpip /v MaxConnectionsPer1_0Server /t REG_DWORD /d 10 /f
reg add $tcpip /v MaxConnectionsPerServer /t REG_DWORD /d 10 /f
reg add $tcpip /v MaxFreeTcbs /t REG_DWORD /d 65536 /f
reg add $tcpip /v EnableTCPA /t REG_DWORD /d 0 /f
reg add $tcpip /v Tcp1323Opts /t REG_DWORD /d 1 /f
reg add $tcpip /v TcpCreateAndConnectTcbRateLimitDepth /t REG_DWORD /d 0 /f
reg add $tcpip /v TcpMaxDataRetransmissions /t REG_DWORD /d 3 /f
reg add $tcpip /v TcpMaxDupAcks /t REG_DWORD /d 2 /f
reg add $tcpip /v TcpMaxSendFree /t REG_DWORD /d 65535 /f
reg add $tcpip /v TcpNumConnections /t REG_DWORD /d 16777214 /f
reg add $tcpip /v MaxHashTableSize /t REG_DWORD /d 65536 /f
reg add $tcpip /v MaxUserPort /t REG_DWORD /d 65534 /f
reg add $tcpip /v SackOpts /t REG_DWORD /d 1 /f
reg add $tcpip /v SynAttackProtect /t REG_DWORD /d 1 /f
reg add $tcpip /v DisableUserTOSSetting /t REG_DWORD /d 0 /f

# Immediate ACK (note: may not exist on all Windows builds)
reg add $tcpip /v DelayedAckTicks /t REG_DWORD /d 0 /f
reg add $tcpip /v DelayedAckFrequency /t REG_DWORD /d 0 /f


# ========================================
# Lanman Workstation
# ========================================
$lmw = "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"

reg add $lmw /v DisableLargeMtu /t REG_DWORD /d 0 /f
reg add $lmw /v MaxCmds /t REG_DWORD /d 30 /f
reg add $lmw /v MaxThreads /t REG_DWORD /d 30 /f
reg add $lmw /v MaxCollectionCount /t REG_DWORD /d 32 /f


# ========================================
# Lanman Server
# ========================================
$lms = "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"

reg add $lms /v autodisconnect /t REG_DWORD /d 4294967295 /f
reg add $lms /v Size /t REG_DWORD /d 3 /f
reg add $lms /v EnableOplocks /t REG_DWORD /d 0 /f
reg add $lms /v IRPStackSize /t REG_DWORD /d 50 /f
reg add $lms /v SizReqBuf /t REG_DWORD /d 17424 /f
reg add $lms /v MaxWorkItems /t REG_DWORD /d 8192 /f
reg add $lms /v MaxMpxCt /t REG_DWORD /d 2048 /f
reg add $lms /v MaxCmds /t REG_DWORD /d 2048 /f
reg add $lms /v DisableStrictNameChecking /t REG_DWORD /d 1 /f
reg add $lms /v SharingViolationDelay /t REG_DWORD /d 0 /f
reg add $lms /v SharingViolationRetries /t REG_DWORD /d 0 /f


# ========================================
# QoS / Psched
# ========================================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v TimerResolution /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f


# Diffserv mappings
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v ServiceTypeGuaranteed /t REG_DWORD /d 46 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v ServiceTypeNetworkControl /t REG_DWORD /d 56 /f

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v ServiceTypeGuaranteed /t REG_DWORD /d 46 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v ServiceTypeNetworkControl /t REG_DWORD /d 56 /f

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v ServiceTypeGuaranteed /t REG_DWORD /d 5 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v ServiceTypeNetworkControl /t REG_DWORD /d 7 /f


# ========================================
# Multimedia System Profile
# ========================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f


# ========================================
# MSMQ
# ========================================
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f


# ========================================
# NLA Internet Detection
# ========================================
$nla = "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet"

reg add $nla /v CorpLocationProbeTimeout /t REG_DWORD /d 30 /f
reg add $nla /v LdapTimeoutMs /t REG_DWORD /d 5000 /f
reg add $nla /v ShowDomainEndpointInterfaces /t REG_DWORD /d 1 /f
reg add $nla /v EnableNoGatewayLocationDetection /t REG_DWORD /d 1 /f
reg add $nla /v MinimumInternetHopCount /t REG_DWORD /d 2 /f


# ========================================
# AFD Fast Send
# ========================================
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v FastSendDatagramThreshold /t REG_DWORD /d 409600 /f

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
# CPU / USB / INPUT LATENCY (รวมแล้ว)
# =========================================================

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
    # GTA PROCESS BOOST
    # =========================================================

    Run-Safe 'wmic process where name="FiveM.exe" CALL setpriority 512'
    Run-Safe 'wmic process where name="FiveM_GTAProcess.exe" CALL setpriority 512'

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
    # FINALIZE
    # =========================================================
    Show-Step "FINALIZE" 96
    Write-Host "[24/25] FINALIZE..."


    Show-Status "[ SYS  ] Enabling 1ms timer precision..." "Cyan"
    [WinTimer]::timeBeginPeriod(1) | Out-Null

    Show-Status "[ POWER] Applying Ultimate Performance..." "Magenta"
    Start-Process powercfg.exe -ArgumentList "-setactive SCHEME_MIN" -WindowStyle Hidden -Wait

    Show-Status "[ INPUT] Keyboard optimization..." "Blue"

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Keyboard" `
        -Name "KeyboardDelay" `
        -Value "0"

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Keyboard" `
        -Name "KeyboardSpeed" `
        -Value "31"

    Show-Status "[ INPUT] Disabling mouse acceleration..." "Blue"

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Mouse" `
        -Name "MouseSpeed" `
        -Value "0"

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Mouse" `
        -Name "MouseThreshold1" `
        -Value "0"


    Show-Status "[ NET  ] Flushing DNS..." "Yellow"

    Start-Process ipconfig.exe `
        -ArgumentList "/flushdns" `
        -WindowStyle Hidden `
        -Wait

    Show-Status "[ NET  ] TCP optimization..." "DarkYellow"

    Start-Process netsh.exe `
        -ArgumentList "int tcp set global autotuninglevel=disabled" `
        -WindowStyle Hidden `
        -Wait

    Start-Process netsh.exe `
        -ArgumentList "int tcp set global rss=enabled" `
        -WindowStyle Hidden `
        -Wait

    Start-Process netsh.exe `
        -ArgumentList "int tcp set global chimney=enabled" `
        -WindowStyle Hidden `
        -Wait

    Show-Status "[ APP  ] Closing background apps..." "Magenta"

    $apps = @(
        "OneDrive",
        "Skype",
        "Teams",
        "XboxAppServices",
        "YourPhone",
        "SteamWebHelper",
        "Copilot"
    )

    foreach ($app in $apps) {

        Get-Process $app -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    }

    Show-Status "[ TEMP ] Cleaning TEMP..." "Gray"

    Remove-Item `
        "$env:TEMP\*" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

    Show-Status "[ TEMP ] Cleaning Windows TEMP..." "Gray"

    Remove-Item `
        "C:\Windows\Temp\*" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

    # =========================================================
    # GTA PROCESS BOOST
    # =========================================================

    Run-Safe 'wmic process where name="FiveM.exe" CALL setpriority 512'
    Run-Safe 'wmic process where name="FiveM_GTAProcess.exe" CALL setpriority 512'


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