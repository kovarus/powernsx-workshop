﻿<#
Script name: EnableVmotion.ps1 
03/21/2018
Author: Dana Gertsch
Description: The purpose of the script is to enable VMotion on the nested hosts for our PowerCLI/NSX workshop
Dependencies: None known

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

My-Logger "Connecing to vCenter"
# Connect to vCenter
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword
$esxhosts = Get-VMHost
foreach ($esxhost in $esxhosts) {
# Get the Management Network VMK and enable VMotion
    Get-VMHostNetworkAdapter -VMHost $esxhost -VMKernel | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false
    My-Logger "Enabling VMotion on $esxhost"
 }

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "vMotion conifgured on hosts."
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"