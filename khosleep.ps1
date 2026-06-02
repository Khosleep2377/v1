# ==============================================================================
# FLOWGOD
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. PRIVILEGE & PREPARATION (ตรวจสอบสิทธิ์และล้างระบบเก่าก่อนเริ่ม)
# ------------------------------------------------------------------------------
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "Applying SMOOTKING ULTRA PRO v2 [KingSmooth - FULL VERSION]..." -ForegroundColor Cyan

Write-Host "[0/8] Performing Deep Network Reset & Cache Cleanup..." -ForegroundColor Yellow
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
netsh branchcache reset | Out-Null
nbtstat -R | Out-Null
nbtstat -RR | Out-Null
netsh int ipv4 reset | Out-Null
netsh int ipv6 reset | Out-Null
netsh int ip reset c:\resetlog.txt | Out-Null
netsh int ip reset c:\cplog.txt | Out-Null
netsh int ip reset all | Out-Null

# รีเซ็ตสัญญาณเครือข่ายและล้างแคชระบบ
ipconfig /release | Out-Null
ipconfig /renew | Out-Null
ipconfig /flushdns | Out-Null
gpupdate /force | Out-Null

# เคลียร์ไฟล์ขยะชั่วคราวทั้งหมดในเครื่อง
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 1. BASE POWER PLAN & CPU (KingSmooth - DEEP KERNEL INSANE BOOST)
# ------------------------------------------------------------------------------
Write-Host "[1/8] Configuring KingSmooth Power Plan & Kernel Settings..." -ForegroundColor Yellow

# ดึงแผนพลังงาน High Performance มาเป็นฐาน
$TargetGuid = "381b4222-f694-41f0-9685-ff5bb260df2e"
$guid = (powercfg -duplicatescheme $TargetGuid | Select-String "[A-F0-9-]{36}").Matches.Value

# เปลี่ยนชื่อแผนพลังงานเป็น KingSmooth อย่างเป็นทางการ
powercfg -changename $guid "Smooth" "KingSmooth"

# ปลดล็อกเมนูลับระดับ Kernel ของระบบจัดการพลังงานทั้งหมด
$Attributes = @(
    "PROCTHROTTLEMIN", "PROCTHROTTLEMAX", "PERFBOOSTMODE", "PERFBOOSTPOL", 
    "PERFAUTONOMOUS", "LATENCYHINT", "CPMINCORES", "CPMAXCORES",
    "CPINCREASETIME", "CPDECREASETIME", "CPINCREASEPOLICY", "CPDECREASEPOLICY"
)
foreach ($attr in $Attributes) {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\$attr" /v Attributes /t REG_DWORD /d 2 /f | Out-Null
}

# ระบบบริหารคล็อกและความร้อน (Dynamic Engine) ดันซีพียูสุดกำลังเมื่อต้องการประสิทธิภาพ
powercfg -setacvalueindex $guid SUB_PROCESSOR PROCTHROTTLEMIN 90
powercfg -setacvalueindex $guid SUB_PROCESSOR PROCTHROTTLEMAX 100

# โหมดบูสท์ระดับท็อป: 4 (Aggressive At Guaranteed) บูสท์ทะลุขีดจำกัดทันทีเมื่อเกมต้องการ
powercfg -setacvalueindex $guid SUB_PROCESSOR PERFBOOSTMODE 4
powercfg -setacvalueindex $guid SUB_PROCESSOR PERFBOOSTPOL 100

# เร่งเวลาตอบสนองชิปซีพียู (Zero-Delay Response)
powercfg -setacvalueindex $guid SUB_PROCESSOR CPINCREASETIME 1
powercfg -setacvalueindex $guid SUB_PROCESSOR CPDECREASETIME 100
powercfg -setacvalueindex $guid SUB_PROCESSOR CPINCREASEPOLICY 0
powercfg -setacvalueindex $guid SUB_PROCESSOR CPDECREASEPOLICY 1

# ปิดระบบ Autonomous: บังคับให้ Windows ส่งคำสั่งตรงเข้าฮาร์ดแวร์ ไม่ผ่านตัวกรองเดาใจระบบ
powercfg -setacvalueindex $guid SUB_PROCESSOR PERFAUTONOMOUS 0
powercfg -setacvalueindex $guid SUB_PROCESSOR LATENCYHINT 0

# จัดระเบียบระบบคอร์หลับ (No Core Parking Stutter) บังคับคอร์วิ่งเต็ม 100% ตลอดเวลา
powercfg -setacvalueindex $guid SUB_PROCESSOR IDLEDISABLE 0
powercfg -setacvalueindex $guid SUB_PROCESSOR CPMINCORES 100
powercfg -setacvalueindex $guid SUB_PROCESSOR CPMAXCORES 100

# ปลดแบนด์วิดท์ฮาร์ดแวร์ขั้นสูงสุด (PCIe, USB, Storage, Sleep Core)
powercfg -setacvalueindex $guid SUB_PCIEXPRESS ASPM 0
powercfg -setacvalueindex $guid SUB_USB USBSELECTIVE SUSPEND 0
powercfg -setacvalueindex $guid SUB_DISK DISKIDLE 0
powercfg -setacvalueindex $guid SUB_SLEEP STANDBYIDLE 0
powercfg -setacvalueindex $guid SUB_SLEEP HIBERNATEIDLE 0
powercfg /hibernate off

# เปิดแอปพลายแผนพลังงานทันที
powercfg -setactive $guid

# เคลียร์ค่าพลังงานในคีย์ซ่อนของ Registry เก่า
$PowerKeys = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\cc5b647-c1df-4637-891a-dec35c318583",
    "HKLM:\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\cc5b647-c1df-4637-891a-dec35c318583",
    "HKLM:\SYSTEM\ControlSet002\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\cc5b647-c1df-4637-891a-dec35c318583"
)
foreach ($pk in $PowerKeys) {
    if (Test-Path $pk) {
        Set-ItemProperty -Path $pk -Name "ValueMin" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $pk -Name "ValueMax" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
}
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\893dee8e-2bef-41e0-89c6-b55d0929964c" -Name "ValueMax" -Value 100 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\893dee8e-2bef-41e0-89c6-b55d0929964c\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -Name "ValueMax" -Value 100 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 2. SYSTEM PERFORMANCE & WINDOWS RESPONSIVENESS
# ------------------------------------------------------------------------------
Write-Host "[2/8] Tuning Desktop Responsiveness & Application Timeouts..." -ForegroundColor Yellow

$DesktopPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $DesktopPath -Name "AutoEndTasks" -Value "1" -Type String
Set-ItemProperty -Path $DesktopPath -Name "MenuShowDelay" -Value "0" -Type String
Set-ItemProperty -Path $DesktopPath -Name "HungAppTimeout" -Value "1000" -Type String
Set-ItemProperty -Path $DesktopPath -Name "WaitToKillAppTimeout" -Value "2000" -Type String
Set-ItemProperty -Path $DesktopPath -Name "WaitToKillServiceTimeout" -Value "1000" -Type String
Set-ItemProperty -Path $DesktopPath -Name "LowLevelHooksTimeout" -Value "1000" -Type String
Set-ItemProperty -Path $DesktopPath -Name "ForegroundLockTimeout" -Value "150000" -Type String
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableBalloonTips" -Value 0 -Type DWord -ErrorAction SilentlyContinue

# ปรับระดับความสำคัญในการทำงานของ Thread (Win32PrioritySeparation ขั้นสูง)
$PriorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
Set-ItemProperty -Path $PriorityPath -Name "ConvertibleSlateMode" -Value 0 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "Win32PrioritySeparation" -Value 38 -Type DWord 
Set-ItemProperty -Path $PriorityPath -Name "IRQ8Priority" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "IRQ16Priority" -Value 2 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "IRQ0Priority" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "IRQPriority" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "AdjustDpcThreshold" -Value 800 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "DeepIoCoalescingEnabled" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "IdealDpcRate" -Value 2 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "ForegroundBoost" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "SchedulerAssistThreadFlagOverride" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "ThreadBoostType" -Value 2 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "ThreadSchedulingModel" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "AVX2PriorityBoost" -Value 1 -Type DWord
Set-ItemProperty -Path $PriorityPath -Name "Win32TimeSlice" -Value 1 -Type DWord

# GPU Scheduling & NVIDIA System Latency Optimization
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" -Name "VsyncIdleTimeout" -Value 0 -Type DWord
if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS") {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" -Name "EnableRID61684" -Value 1 -Type DWord
}

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
    
# ------------------------------------------------------------------------------
# 3. MULTIMEDIA CLASS SCHEDULER (MMCSS) GAMING TWEAKS
# ------------------------------------------------------------------------------
Write-Host "[3/8] Optimizing Multimedia Class Scheduler (MMCSS)..." -ForegroundColor Yellow

$SysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $SysProfilePath -Name "SystemResponsiveness" -Value 10 -Type DWord 
Set-ItemProperty -Path $SysProfilePath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord

# ฟังก์ชันจัดการคีย์ย่อยใน Multimedia Tasks เพื่อลดพื้นที่โค้ดซ้ำซ้อนและป้อนค่าได้ครบถ้วน
function Set-MultimediaTask($TaskName, $TaskProperties) {
    $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\$TaskName"
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    foreach ($Prop in $TaskProperties.GetEnumerator()) {
        $Type = if ($Prop.Value -is [int]) { "DWord" } else { "String" }
        Set-ItemProperty -Path $Path -Name $Prop.Name -Value $Prop.Value -Type $Type -Force
    }
}

Set-MultimediaTask "Games" @{"Affinity"=0; "Background Only"="False"; "Clock Rate"=10000; "GPU Priority"=8; "Priority"=6; "Scheduling Category"="High"; "SFIO Priority"="High"; "Latency Sensitive"="True"}
Set-MultimediaTask "Low Latency" @{"Affinity"=0; "Background Only"="False"; "Clock Rate"=10000; "GPU Priority"=8; "Priority"=2; "Scheduling Category"="High"; "SFIO Priority"="High"; "Latency Sensitive"="True"}
Set-MultimediaTask "Audio" @{"Affinity"=0; "Background Only"="True"; "Clock Rate"=10000; "GPU Priority"=2; "Priority"=1; "Scheduling Category"="High"; "SFIO Priority"="High"}
Set-MultimediaTask "Pro Audio" @{"Affinity"=0; "Background Only"="False"; "Clock Rate"=10000; "GPU Priority"=5; "Priority"=1; "Scheduling Category"="High"; "SFIO Priority"="High"}

# ------------------------------------------------------------------------------
# 4. MOUSE, KEYBOARD & INPUT DELAY FIX (RAW INPUT 1:1)
# ------------------------------------------------------------------------------
Write-Host "[4/8] Removing Mouse Acceleration & Keyboard Input Delays..." -ForegroundColor Yellow

# ล้างค่าการเร่งความเร็วเมาส์เพื่อความเสถียร 1:1 ทั้งผู้ใช้ปัจจุบันและผู้ใช้เริ่มต้นระบบ
$MouseTargets = @("HKCU:\Control Panel\Mouse", "HKU:\.DEFAULT\Control Panel\Mouse")
foreach ($Path in $MouseTargets) {
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name "ActiveWindowTracking" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Path -Name "DoubleClickWidth" -Value "8" -Type String
    Set-ItemProperty -Path $Path -Name "DoubleClickSpeed" -Value "3004" -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Path -Name "MouseSpeed" -Value "0" -Type String
    Set-ItemProperty -Path $Path -Name "MouseThreshold1" -Value "0" -Type String
    Set-ItemProperty -Path $Path -Name "MouseThreshold2" -Value "0" -Type String
    Set-ItemProperty -Path $Path -Name "SnapToDefaultButton" -Value "0" -Type String
    Set-ItemProperty -Path $Path -Name "SwapMouseButtons" -Value "0" -Type String
    Set-ItemProperty -Path $Path -Name "MouseTrails" -Value "0" -Type String
}

# เพิ่มขนาดบัฟเฟอร์คิวข้อมูลของคอนโทรลเลอร์ฮาร์ดแวร์เมาส์ 
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 1024 -Type DWord

# การตอบสนองของแผงฟังก์ชันช่วยเหลือเมาส์ (MouseKeys)
$MouseKeysPath = "HKCU:\Control Panel\Accessibility\MouseKeys"
if (-not (Test-Path $MouseKeysPath)) { New-Item -Path $MouseKeysPath -Force | Out-Null }
Set-ItemProperty -Path $MouseKeysPath -Name "Flags" -Value "1000" -Type String
Set-ItemProperty -Path $MouseKeysPath -Name "MaximumSpeed" -Value "90000" -Type String
Set-ItemProperty -Path $MouseKeysPath -Name "TimeToMaximumSpeed" -Value "70000" -Type String

# เร่งอัตราตอบสนองการกดปุ่มคีย์บอร์ดให้รับคำสั่งไวที่สุด
$KeyboardResponse = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (-not (Test-Path $KeyboardResponse)) { New-Item -Path $KeyboardResponse -Force | Out-Null }
Set-ItemProperty -Path $KeyboardResponse -Name "AutoRepeatDelay" -Value "150" -Type String
Set-ItemProperty -Path $KeyboardResponse -Name "AutoRepeatRate" -Value "25" -Type String
Set-ItemProperty -Path $KeyboardResponse -Name "BounceTime" -Value "0" -Type String
Set-ItemProperty -Path $KeyboardResponse -Name "DelayBeforeAcceptance" -Value "0" -Type String
Set-ItemProperty -Path $KeyboardResponse -Name "Flags" -Value "1000" -Type String

# ------------------------------------------------------------------------------
# 5. NETWORK & TCP/IP PARAMETERS (DISABLE NAGLE'S ALGORITHM)
# ------------------------------------------------------------------------------
Write-Host "[5/8] Injecting Advanced TCP/IP Profiles & Network Tweaks..." -ForegroundColor Yellow

# ตั้งค่าพารามิเตอร์ของระบบเครือข่ายแกนหลัก (รวมค่า Buffer และ Queue ทั้งหมด)
$TCPPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
$TCPValues = @{
    "MTU" = 1500; "MSS" = 1460; "TcpAckFrequency" = 1; "TcpDelAckTicks" = 0; "TCPNoDelay" = 1;
    "NumTcbTablePartitions" = 8; "TcpWindowSize" = 65535; "SackOpts" = 1; "TcpMaxDataRetransmissions" = 3;
    "Tcp1323Opts" = 1; "TCPTimedWaitDelay" = 30; "IRPStackSize" = 15; "DefaultTTL" = 64;
    "KeepAliveTime" = 7200000; "KeepAliveInterval" = 1000; "TCPInitialRtt" = 300; "TcpMaxDupAcks" = 2;
    "TcpRecSegmentSize" = 2776677; "EnablePMTUBHDetect" = 0; "EnablePMTUDiscovery" = 1;
    "GlobalMaxTcpWindowSize" = 65535; "MaxHashTableSize" = 65536; "DisableTaskOffload" = 0;
    "WorldMaxTcpWindowsSize" = 700967; "TCPAllowedPorts" = 1; "NTEContextList" = 3;
    "DisableLargeMTU" = 0; "IGMPVersion" = 2; "IGMPLevel" = 2; "MaxConnectionsPer1_0Server" = 16;
    "MaxConnectionsPerServer" = 16; "MaxFreeTcbs" = 65536; "ArpTRSingleRoute" = 1;
    "SynAttackProtect" = 1; "MaxForwardBufferMemory" = 175200; "ForwardBufferMemory" = 175200;
    "NumForwardPackets" = 567; "MaxNumForwardPackets" = 567; "MaxUserPort" = 65534;
    "TcpMaxSendFree" = 65535; "DeadGWDetectDefault" = 1; "DontAddDefaultGatewayDefault" = 1;
    "MaxMpxCt" = 175; "EnableICMPRedirect" = 0; "CacheHashTableBucketSize" = 8907;
    "EnableWsd" = 0; "EnableDynamicBacklog" = 2; "EnableDHCP" = 3; "AllowUnqualifiedQuery" = 2;
    "DisableMediaSenseEventLog" = 1; "DisableRss" = 0; "DisableTcpChimneyOffload" = 0;
    "DnsOutstandingQueriesCount" = 3000; "EnableAddrMaskReply" = 4; "EnableBcastArpReply" = 2;
    "EnableConnectionRateLimiting" = 0; "EnableDca" = 1; "EnableHeuristics" = 0;
    "EnableIPAutoConfigurationLimits" = 1; "EnableTCPA" = 1; "IPEnableRouter" = 7;
    "QualifyingDestinationThreshold" = 729796; "StrictTimeWaitSeqCheck" = 4
}
foreach ($v in $TCPValues.Keys) {
    Set-ItemProperty -Path $TCPPath -Name $v -Value $TCPValues[$v] -Type DWord -ErrorAction SilentlyContinue
}

# ปิดดีเลย์หน่วงแพ็กเก็ตเน็ต (Nagle's) ยิงตรงรายอะแดปเตอร์เครือข่ายทุกตัวในเครื่อง
$InterfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem -Path $InterfacesPath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "MTU" -Value 1500 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "MSS" -Value 1460 -Type DWord -ErrorAction SilentlyContinue
}

# ตั้งค่าการจัดลำดับความสำคัญของเน็ตเวิร์กเซอวิส (Network Service Priority)
$ServiceProvider = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider"
Set-ItemProperty -Path $ServiceProvider -Name "Class" -Value 8 -Type DWord
Set-ItemProperty -Path $ServiceProvider -Name "DnsPriority" -Value 6 -Type DWord
Set-ItemProperty -Path $ServiceProvider -Name "HostsPriority" -Value 5 -Type DWord
Set-ItemProperty -Path $ServiceProvider -Name "LocalPriority" -Value 4 -Type DWord
Set-ItemProperty -Path $ServiceProvider -Name "NetbtPriority" -Value 7 -Type DWord

# ล็อกแบนด์วิดท์โครงสร้าง Lanman Server & Workstation ให้ดึงความสามารถฮาร์ดแวร์มาได้เต็มที่
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SizReqBuf" -Value 17424 -Type DWord
$LanmanWorkstation = "HKLM:\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters"
Set-ItemProperty -Path $LanmanWorkstation -Name "DisableBandwidthThrottling" -Value 1 -Type DWord
Set-ItemProperty -Path $LanmanWorkstation -Name "DisableLargeMtu" -Value 0 -Type DWord
Set-ItemProperty -Path $LanmanWorkstation -Name "MaxCmds" -Value 30 -Type DWord
Set-ItemProperty -Path $LanmanWorkstation -Name "MaxThreads" -Value 30 -Type DWord
Set-ItemProperty -Path $LanmanWorkstation -Name "MaxCollectionCount" -Value 32 -Type DWord
Set-ItemProperty -Path $LanmanWorkstation -Name "KeepConn" -Value 86400 -Type DWord

# ปลดล็อก Bandwidth QoS Packet Scheduler ให้วิ่งตรง 100%
$PschedPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
if (-not (Test-Path $PschedPath)) { New-Item $PschedPath -Force | Out-Null }
Set-ItemProperty -Path $PschedPath -Name "NonBestEffortLimit" -Value 0 -Type DWord

# บังคับเปิดประสิทธิภาพฮาร์ดแวร์ผ่าน MSMQ Registry
if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters")) { New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" -Force | Out-Null }
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" -Name "TCPNoDelay" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" -Name "TcpNoDelay" -Value 1 -Type DWord

# สั่งปิดฟังก์ชันประหยัดพลังงานที่ตัวการ์ดแลนทางกายภาพ
Get-NetAdapter | ForEach-Object {
    $name = $_.Name
    Set-NetAdapterPowerManagement -Name $name -AllowComputerToTurnOffDevice Disabled -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
}

# ปรับจูน Netsh TCP Global (ลบข้อขัดแย้งของคำสั่งเดิมทั้งหมด)
netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global rss=enabled | Out-Null
netsh int tcp set global chimney=enabled | Out-Null
netsh int tcp set global dca=enabled | Out-Null
netsh int tcp set global netdma=enabled | Out-Null
netsh int tcp set global congestionprovider=ctcp | Out-Null
netsh int tcp set global timestamps=disabled | Out-Null
netsh int tcp set global nonsackrttresiliency=disabled | Out-Null
netsh int tcp set global maxsynretransmissions=2 | Out-Null
netsh int tcp set heuristics disabled | Out-Null

# ตั้งค่าช่องทาง Google DNS เสถียรสูงให้การ์ดอินเทอร์เน็ตหลัก
netsh interface ip set dns name="Ethernet" static 8.8.8.8 | Out-Null
netsh interface ip add dns name="Ethernet" 8.8.4.4 index=2 | Out-Null

# ------------------------------------------------------------------------------
# 6. FILE SYSTEM, MEMORY & INTEL HARDWARE ALLOCATION
# ------------------------------------------------------------------------------
Write-Host "[6/8] Tuning Filesystem, Storage & Memory Buffers..." -ForegroundColor Yellow

$FileSystem = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
Set-ItemProperty -Path $FileSystem -Name "NtfsMftZoneReservation" -Value 1 -Type DWord
Set-ItemProperty -Path $FileSystem -Name "NTFSDisable8dot3NameCreation" -Value 1 -Type DWord
Set-ItemProperty -Path $FileSystem -Name "DontVerifyRandomDrivers" -Value 1 -Type DWord
Set-ItemProperty -Path $FileSystem -Name "NTFSDisableLastAccessUpdate" -Value 1 -Type DWord
Set-ItemProperty -Path $FileSystem -Name "ContigFileAllocSize" -Value 64 -Type DWord

# ลบระบบสแกนไฟล์เบื้องหลังเพื่อลดการสั่นกระตุกของพื้นที่จัดเก็บข้อมูล (SSD/HDD)
$Prefetch = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
Set-ItemProperty -Path $Prefetch -Name "EnablePrefetcher" -Value 0 -Type DWord
Set-ItemProperty -Path $Prefetch -Name "EnableSuperfetch" -Value 0 -Type DWord
Set-ItemProperty -Path $Prefetch -Name "EnableBoottrace" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "Max Cached Icons" -Value "2000" -Type String

# ปลดล็อกทรัพยากรการคำนวณกราฟิกภายในชิปเซ็ต (Dedicated Segment Size)
if (-not (Test-Path "HKLM:\SOFTWARE\Intel\GMM")) { New-Item -Path "HKLM:\SOFTWARE\Intel\GMM" -Force | Out-Null }
Set-ItemProperty -Path "HKLM:\SOFTWARE\Intel\GMM" -Name "DedicatedSegmentSize" -Value 1298 -Type DWord

# บล็อกระบบแจ้งเตือนพื้นที่เหลือน้อยของ Windows Explorer และการค้นหาขยะ
$PoliciesExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
if (-not (Test-Path $PoliciesExplorer)) { New-Item -Path $PoliciesExplorer -Force | Out-Null }
Set-ItemProperty -Path $PoliciesExplorer -Name "NoLowDiskSpaceChecks" -Value 1 -Type DWord
Set-ItemProperty -Path $PoliciesExplorer -Name "LinkResolveIgnoreLinkInfo" -Value 1 -Type DWord
Set-ItemProperty -Path $PoliciesExplorer -Name "NoResolveSearch" -Value 1 -Type DWord
Set-ItemProperty -Path $PoliciesExplorer -Name "NoResolveTrack" -Value 1 -Type DWord
Set-ItemProperty -Path $PoliciesExplorer -Name "NoInternetOpenWith" -Value 1 -Type DWord

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" -Name "TimeStampInterval" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\cdrom" -Name "AutoRun" -Value 0 -Type DWord

# ------------------------------------------------------------------------------
# 7. GAME MODE & WINDOWS GAME DVR SYSTEM OFF
# ------------------------------------------------------------------------------
Write-Host "[7/8] Enforcing Game Mode & Disabling Windows Background DVR..." -ForegroundColor Yellow

# ตรวจสอบและเตรียมเส้นทางเพื่อเขียนค่า Registry ระบบย่อยของ GameBar
$GameBarPaths = @("HKCU:\Software\Microsoft\GameBar", "HKCU:\System\GameConfigStore", "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR", "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR")
foreach ($p in $GameBarPaths) { if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null } }

# บังคับรันระบบปฏิบัติการเข้าสู่โหมดรีดเฟรมเรตเกม (Game Mode)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord

# จัดการคีย์ย่อยสำหรับการปิดระบบบันทึกคลิปซ้อนพื้นหลังของ Game DVR
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DSEBehavior" -Value 2 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Type DWord

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord

# ล็อกค่าประสิทธิภาพการเรนเดอร์และความลื่นไหลของเอนจิ้นเกม (Fps Tweaks)
$GamesPath = "HKCU:\SOFTWARE\Microsoft\Games"
if (-not (Test-Path $GamesPath)) { New-Item -Path $GamesPath -Force | Out-Null }
Set-ItemProperty -Path $GamesPath -Name "FpsAll" -Value 1 -Type DWord
Set-ItemProperty -Path $GamesPath -Name "GameFluidity" -Value 1 -Type DWord
Set-ItemProperty -Path $GamesPath -Name "FpsStatusGames" -Value 16 -Type DWord
Set-ItemProperty -Path $GamesPath -Name "FpsStatusGamesAll" -Value 4 -Type DWord

# ------------------------------------------------------------------------------
# 8. WINDOWS TIMER & CORE ENGINE BOOT (BCDEdit Tweaks ชุดใหญ่)
# ------------------------------------------------------------------------------
Write-Host "[8/8] Injecting Latency Timer Resolution & BCDEdit Settings..." -ForegroundColor Yellow

bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set useplatformtick yes | Out-Null
bcdedit /set tscsyncpolicy Enhanced | Out-Null
bcdedit /set timeout 0 | Out-Null
bcdedit /set nx optout | Out-Null
bcdedit /set bootux disabled | Out-Null
bcdedit /set bootmenupolicy standard | Out-Null
bcdedit /set hypervisorlaunchtype off | Out-Null
bcdedit /set tpmbootentropy ForceDisable | Out-Null
bcdedit /set quietboot yes | Out-Null
bcdedit /set {globalsettings} custom:16000067 true | Out-Null
bcdedit /set {globalsettings} custom:16000069 true | Out-Null
bcdedit /set {globalsettings} custom:16000068 true | Out-Null
bcdedit /set linearaddress57 OptOut | Out-Null
bcdedit /set increaseuserva 268435328 | Out-Null
bcdedit /set firstmegabytepolicy UseAll | Out-Null
bcdedit /set avoidlowmemory 0x8000000 | Out-Null
bcdedit /set nolowmem Yes | Out-Null
bcdedit /set allowedinmemorysettings 0x0 | Out-Null
bcdedit /set isolatedcontext No | Out-Null
bcdedit /set vsmlaunchtype Off | Out-Null
bcdedit /set vm No | Out-Null
bcdedit /set configaccesspolicy Default | Out-Null
bcdedit /set MSI Default | Out-Null
bcdedit /set usephysicaldestination No | Out-Null
bcdedit /set usefirmwarepcisettings No | Out-Null
bcdedit /deletevalue useplatformclock 2>$null | Out-Null



# สั่งฆ่าโปรเซสแอปพื้นหลังที่คอยแอบแย่งความเร็วอินเทอร์เน็ตและแรมเครื่องชั่วคราว
$apps = @("OneDrive", "Skype", "Teams", "XboxAppServices", "YourPhone", "SteamWebHelper", "Copilot", "GameBar", "GameBarFTServer", "XboxPcApp")
foreach ($a in $apps) { Get-Process -Name $a -ErrorAction SilentlyContinue | Stop-Process -Force }

# ------------------------------------------------------------------------------
# COMPLETION SUMMARY
# ------------------------------------------------------------------------------
Clear-Host
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "      FLOWGOD                                                         " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host " รวบรวมค่าปรับแต่งระบบลึกระดับ Kernel, ทราฟฟิก TCP/IP, บัฟเฟอร์เมาส์ " -ForegroundColor White
Write-Host " และค่าลดเวลาหน่วง (Input Lag) ทั้งหมดให้คุณเรียบร้อย ครบถ้วน 100% แล้วครับ" -ForegroundColor White
Write-Host ""
Write-Host " แนะนำให้ผู้ใช้งานทำการ >> [ Restart คอมพิวเตอร์ 1 รอบ ] << เพื่อเริ่มระบบใหม่" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Green
