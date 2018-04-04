<#
Script name: CreateVXLanVDSandAddHosts.ps1 
03/21/2018
Author: Dana Gertsch
Description: The purpose of the script is to add a VDSSwitch for NSX components
Dependencies: None known

===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 10.0.789315
PowerNSX Verions: 3.0.1091
PowerShell Version: 5.0
OS Version: Windows 2012
Keyword: VM
#>
$vcenter = "vcenter.corp.local"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"
$DVSVMnic = "vmnic1"
$datacenter = "Datacenter"
$newVDSwitch = "vDS vxlan"

# Do not change below this line

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
# Connect to vCenter
My-Logger "Connecting to vCenter"
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword

$myDataCenter = Get-Datacenter -Name $datacenter

$vmhosts = $myDataCenter | Get-VMHost

# Create the new vDS
My-Logger "Creating new vDS"
$myVDSSwitch = New-VDSwitch -Name $newVDSwitch -Location $datacenter

# Hosts to vDS
My-Logger "Adding hosts to new vDS"
Add-VDSwitchVMHost -VDSwitch $myVDSSwitch -VMHost $vmhosts

# Get the VMNICs
$hostsPhysicalNic = $vmhosts | Get-VMHostNetworkAdapter -Name $DVSVMnic

# Add Nic to VDS
Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $hostsPhysicalNic -DistributedSwitch $newVDSwitch -Confirm:$false

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "Creation of new vDS complete."
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"

