<#
Script name: SetSyslogServers
Date: 4/4/2018
Author: Who 
Description: The purpose of the script is to set the syslog servers for hosts.
Dependencies: 

===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 10.0.789315
PowerNSX Verions: 3.0.1091
PowerShell Version: 5.0
OS Version: Windows 2012
Keyword: VM
#>

$vcuser = "administrator@vsphere.local"
$vcpassword = "VMware1!"
$vcenter = "vcenter.corp.local"

$LogInsightServer = "10.44.19.14:514"


# Do not change anything below this line

$StartTime = Get-Date

Function My-Logger {
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"

    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor Green " $message"

}

# Do something 
# Disable SSL verification 
My-Logger "Disabling SSL validation"
Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false

My-Logger "Connecing to vCenter"
# Connect to vCenter
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword


Get-VMHost | Foreach {
    Write-Host “Adding $LogInsightServer as Syslog server for $($_.Name)”
    $SetSyslog = Set-VMHostSysLogServer -SysLogServer $LogInsightServer -VMHost $_ -Confirm:$false
    Write-Host “Reloading Syslog on $($_.Name)”
    $Reload = (Get-ESXCLI -VMHost $_).System.Syslog.reload()
    Write-Host “Setting firewall to allow Syslog out of $($_)”
    $FW = $_ | Get-VMHostFirewallException | Where {$_.Name -eq ‘syslog’} | Set-VMHostFirewallException -Enabled:$true
}

# Disconnect all vCenters
Disconnect-VIServer -Confirm:$false

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "Updating NTP servers complete."
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"