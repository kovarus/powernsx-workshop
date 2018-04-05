<#
Script name: SetNTPServers
Date: 4/4/2018
Author: Who 
Description: The purpose of the script is to set the ntp server for hosts in a cluster.
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
$location = "Datacenter"

# NTP server array
$ntpArray = @("0.north-america.pool.ntp.org","1.north-america.pool.ntp.org")


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

# Get the hosts in the datacenter

$EsxHosts = Get-VMHost -Location $location


# Loop through all hosts

foreach($esxhost in $EsxHosts) {

# Configure NTP server

# Add the NTP servers
foreach($ntpserver in $ntpArray) {
Add-VmHostNtpServer -VMHost $esxhost -NtpServer $ntpserver -ErrorAction SilentlyContinue -Confirm:$false
}

# Allow NTP queries outbound through the firewall
Get-VMHostFirewallException -VMHost $esxhost | where {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true

# Start NTP client service and set to automatic
Get-VmHostService -VMHost $esxhost | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService
Get-VmHostService -VMHost $esxhost | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"

}

# Disconnect all vCenters
Disconnect-VIServer -Confirm:$false

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "Updating NTP servers complete."
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"