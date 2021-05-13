# 디ì©£스ö¨¬크¨Ï SAN 정¢´책¡Í을¡í Onlineall 다¥U음¨ö과Æu 같Æ¡Æ이I 설ù©ø정¢´ 
#diskpart.exe
#DISKPART> san policy=onlineall
#DISKPART> exit
 
 
 
# Windows에¯¢® 대¥e 한N UTC (협u정¢´ 세ù¨ù계Æe시öA) 시öA간Æ¡Ì을¡í 설ù©ø정¢´ 합O니¥I다¥U. 또ÒC한N Windows 시öA간Æ¡Ì 서ù¡©비¬n스ö¨¬ w32time 의C 시öA작U 유?형u을¡í 자U동ì¢¯ 으¢¬로¤I 설ù©ø정¢´ 합O니¥I다¥U.
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation -Name RealTimeIsUniversal -Value 1 -Type DWord -Force
Set-Service -Name w32time -StartupType Automatic
 
# 전u원¯©ª 프A로¤I필E을¡í 고Æi성ù¨¬능¥E으¢¬로¤I 설ù©ø정¢´
powercfg.exe /setactive SCHEME_MIN
 
# 환?경Æ©¡ 변¬?수ùo TEMP 및ö¡¿ TMP 가Æ¢® 기¾a본¬¡í값Æ¨£으¢¬로¤I 설ù©ø정¢´
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name TEMP -Value "%SystemRoot%\TEMP" -Type ExpandString -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name TMP -Value "%SystemRoot%\TEMP" -Type ExpandString -Force
 
# Windows 서ù¡©비¬n스ö¨¬가Æ¢® 각Æ¡Ë각Æ¡Ë Windows 기¾a본¬¡í값Æ¨£으¢¬로¤I 설ù©ø정¢´ 되ìC어úi 있O는¥A지o 확¢ç인I 합O니¥I다¥U. 이I러¤?한N 서ù¡©비¬n스ö¨¬는¥A VM 연¯¡þ결Æa을¡í 보¬¢¬장a 하I기¾a 위¡×해¨ª 구¾¢¬성ù¨¬ 해¨ª야ú©¬ 하I는¥A 최O소ùO
Get-Service -Name BFE, Dhcp, Dnscache, IKEEXT, iphlpsvc, nsi, mpssvc, RemoteRegistry |
  Where-Object StartType -ne Automatic |
    Set-Service -StartupType Automatic
 
Get-Service -Name Netlogon, Netman, TermService |
  Where-Object StartType -ne Manual |
    Set-Service -StartupType Manual
 
 
# RDP(원¯©ª격ÆY 데ì¡Í스ö¨¬크¨Ï톱e 프A로¤I토a콜Y)이I 활¡Æ성ù¨¬화¡©
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name fDenyTSConnections -Value 0 -Type DWord -Force
 
# 기¾a본¬¡í 포¡¡À트¡¢ç인I 3389를¬| 사íc용¯e 하I 여¯¨Ï RDP 포¡¡À트¡¢ç가Æ¢® 올¯A바öU르¬¡Ì게ÆO 설ù©ø정¢´
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name PortNumber -Value 3389 -Type DWord -Force
 
# 수ùo신öA기¾a가Æ¢® 모¬©£든ìc 네ø¡¿트¡¢ç워¯o크¨Ï 인I터I페¡a이I스ö¨¬에¯¢®서ù¡© 수ùo신öA 대¥e기¾a 중©¬
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name LanAdapter -Value 0 -Type DWord -Force
 
# RDP 연¯¡þ결Æa에¯¢® 대¥e해¨ª NLA (네ø¡¿트¡¢ç워¯o크¨Ï 수ùo준¨ª 인I증o) 모¬©£드ìa를¬| 구¾¢¬성ù¨¬
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name SecurityLayer -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name fAllowSecProtocolNegotiation -Value 1 -Type DWord -Force
 
# 연¯¡þ결Æa 유?지o 값Æ¨£을¡í 설ù©ø정¢´
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name KeepAliveEnable -Value 1  -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name KeepAliveInterval -Value 1  -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name KeepAliveTimeout -Value 1 -Type DWord -Force
 
# 다¥U시öA 연¯¡þ결Æa 옵¯E션ùC을¡í 설ù©ø정¢´
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name fDisableAutoReconnect -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name fInheritReconnectSame -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name fReconnectSame -Value 0 -Type DWord -Force
 
# 동ì¢¯시öA 연¯¡þ결Æa 수ùo를¬| 제|한N
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name MaxInstanceCount -Value 4294967295 -Type DWord -Force
 
# RDP 수ùo신öA기¾a에¯¢® 연¯¡þ결Æa 된ìE 자U체¨ù 서ù¡©명¬i 된ìE 인I증o서ù¡©를¬| 모¬©£두ìI 제|거ÆA
if ((Get-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').Property -contains 'SSLCertificateSHA1Hash')
{
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name SSLCertificateSHA1Hash -Force
}
 
# 세ù¨ù 가Æ¢®지o 프A로¤I필E (도ì¥ì메¬¨¬인I, 표¡Í준¨ª 및ö¡¿ 공Æ©ª용¯e)에¯¢®서ù¡© Windows 방ö©¡화¡©벽¬¢ç을¡í 설ù©ø정¢´
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True
 
# 세ù¨ù 개Æ©ø의C 방ö©¡화¡©벽¬¢ç 프A로¤I필E (도ì¥ì메¬¨¬인I, 개Æ©ø인I 및ö¡¿ 공Æ©ª용¯e)을¡í 통e한N WinRM을¡í 허a용¯e 하I 고Æi PowerShell 원¯©ª격ÆY 서ù¡©비¬n스ö¨¬를¬| 사íc용¯e 하I도ì¥ì록¤I 설ù©ø정¢´ (언ú©£어úi팩¡N에¯¢® 따ìu라Òo 실öC패¡¨¢할O 수ùo 있O음¨ö 무ö¡ì시öA해¨ª도ì¥ì 됨ìE)
Enable-PSRemoting -Force
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled True
 
# 화¡©벽¬¢ç 규¾O칙¡Ë을¡í 사íc용¯e하I도ì¥ì록¤I 설ù©ø정¢´하I여¯¨Ï RDP 트¡¢ç래¤¢®픽E을¡í 허a용¯e (언ú©£어úi팩¡N에¯¢® 따ìu라Òo 실öC패¡¨¢할O 수ùo 있O음¨ö 무ö¡ì시öA해¨ª도ì¥ì 됨ìE)
Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled True
 
# VM이I 가Æ¢®상ío 네ø¡¿트¡¢ç워¯o크¨Ï 내ø¡í의C ping 요¯a청¡í에¯¢® 응A답¥a할O 수ùo 있O도ì¥ì록¤I 파¡A일I 및ö¡¿ 프A린¬¡Æ터I 공Æ©ª유?에¯¢® 대¥e 한N 규¾O칙¡Ë을¡í 사íc용¯e (언ú©£어úi팩¡N에¯¢® 따ìu라Òo 실öC패¡¨¢할O 수ùo 있O음¨ö 무ö¡ì시öA해¨ª도ì¥ì 됨ìE)
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Echo Request - ICMPv4-In)' -Enabled True
 
# Azure platform network에¯¢® 대¥e 한N 규¾O칙¡Ë을¡í 만¬¢¬듭ìi니¥I다¥U.
New-NetFirewallRule -DisplayName AzurePlatform -Direction Inbound -RemoteAddress 168.63.129.16 -Profile Any -Action Allow -EdgeTraversalPolicy Allow
New-NetFirewallRule -DisplayName AzurePlatform -Direction Outbound -RemoteAddress 168.63.129.16 -Profile Any -Action Allow
 
#BCD(부¬I팅¡A 구¾¢¬성ù¨¬ 데ì¡Í이I터I) 설ù©ø정¢´을¡í 지o정¢´
bcdedit.exe /set "{bootmgr}" integrityservices enable
bcdedit.exe /set "{default}" device partition=C:
bcdedit.exe /set "{default}" integrityservices enable
bcdedit.exe /set "{default}" recoveryenabled Off
bcdedit.exe /set "{default}" osdevice partition=C:
bcdedit.exe /set "{default}" bootstatuspolicy IgnoreAllFailures
 
#Enable Serial Console Feature
bcdedit.exe /set "{bootmgr}" displaybootmenu yes
bcdedit.exe /set "{bootmgr}" timeout 5
bcdedit.exe /set "{bootmgr}" bootems yes
bcdedit.exe /ems "{current}" ON
bcdedit.exe /emssettings EMSPORT:1 EMSBAUDRATE:115200
 
# 덤¥y프A 로¤I그¾¡¿ 수ùo집y을¡í 사íc용¯e 하I도ì¥ì록¤I 설ù©ø정¢´
# Set up the guest OS to collect a kernel dump on an OS crash event
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name CrashDumpEnabled -Type DWord -Force -Value 2
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name DumpFile -Type ExpandString -Force -Value "%SystemRoot%\MEMORY.DMP"
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name NMICrashDump -Type DWord -Force -Value 1
 
# Set up the guest OS to collect user mode dumps on a service crash event
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps'
if ((Test-Path -Path $key) -eq $false) {(New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name LocalDumps)}
New-ItemProperty -Path $key -Name DumpFolder -Type ExpandString -Force -Value 'C:\CrashDumps'
New-ItemProperty -Path $key -Name CrashCount -Type DWord -Force -Value 10
New-ItemProperty -Path $key -Name DumpType -Type DWord -Force -Value 2
Set-Service -Name WerSvc -StartupType Manual
 
# sysprep 명¬i령¤E어úi
 
$sysprep = 'C:\Windows\System32\Sysprep\Sysprep.exe'
 
$arg = '/generalize /oobe /shutdown /quiet'
 
Invoke-Command -ScriptBlock {
 
param($sysprep,$arg) Start-Process -FilePath $sysprep -ArgumentList $arg
 
} -ArgumentList $sysprep,$arg

