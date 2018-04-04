<#
Script name: MountNFS
Date: 04/03/2018
Author: Dana Gertsch
Description: The purpose of the script is to mount the nfs storage
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
# Do something 
My-Logger "Connecing to vCenter"
# Connect to vCenter
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword

My-Logger "Removing Storage"
if (Get-Datastore -Name "Storage") {
    My-Logger "NFS storage mount already exists, but may be broken.  Will remove it."
    Get-Cluster "VSAN-Cluster" | Get-VMHost | Remove-Datastore -Datastore "Storage" -ErrorAction SilentlyContinue -Confirm:$false
}

My-Logger "Mounting NFS storage"
get-cluster "VSAN-Cluster" | get-vmhost | New-Datastore -NFS -Name "Storage" -Path "/home/nfsshare" -nfshost "10.44.17.16"

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "Mounting NFS Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"