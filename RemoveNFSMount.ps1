﻿<#
Script name: RemoveNFSMount 
Date: 4/4/2018
Author: Who 
Description: The purpose of the script is to remove inaccessible NFS mounts.
Dependencies: NFS share cannot have open files.  You may need to disable HA while running this script.

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
My-Logger "Connecing to vCenter"
# Connect to vCenter
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword

$EsxHosts = Get-VMHost
foreach($EsxHost in $EsxHosts){
  $esxcli = Get-VMHost $EsxHost | Get-EsxCli -V2
  $esxcli.storage.nfs.remove.Invoke(@{volumename = 'Storage'}) 
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "Removing stale NFS mounts complete"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"