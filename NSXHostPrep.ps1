<#
Script name:NSXHostPrep.ps1 
03/21/2018
Author: Dana Gertsch
Description: The purpose of the script is to prep the hosts for our PowerCLI/NSX workshop
Dependencies: None known

===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 10.0.789315
PowerNSX Verions: 3.0.1091
PowerShell Version: 5.0
OS Version: Windows 2012
Keyword: VM
#>

# Pool settings
$ManagementNetworkGateway = "10.44.17.1"
$ManagementNetworkSubnetPrefixLength = "24"
$DnsServer1 = "10.44.17.17"
$DnsSuffix = "corp.local"
$ControllerPoolStartIp = "10.44.17.200"
$ControllerPoolEndIp = "10.44.17.224"

# vCenter settings
$vcenter = "10.44.17.14"
$vCenterUserName = "administrator@vsphere.local"
$vCenterPassword = "VMware1!"
$MgmtClusterName = "VSAN-Cluster"

$ManagementvDSSwitchName = "vDS vxlan"

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

My-Logger "Connecting to vCenter"
Connect-NsxServer -vCenterServer $vcenter -Username $vCenterUsername -Password $vCenterPassword -DefaultConnection:$true

$MgmtVds = Get-VDSwitch $ManagementvDSSwitchName
$MmgtCluster = Get-Cluster "VSAN-Cluster"

My-Logger "Creating new NSX ipPool"
# Assumes we will run this before deploying the controller.

$ControllerPool = New-NsxIpPool -Name "Controller Pool" -Gateway $ManagementNetworkGateway -SubnetPrefixLength $ManagementNetworkSubnetPrefixLength -DnsServer1 $DnsServer1 -DnsSuffix $DnsSuffix -StartAddress $ControllerPoolStartIp -EndAddress $ControllerPoolEndIp


# Prep vxlan
My-Logger "Creating vDS Context"

New-NsxVdsContext -VirtualDistributedSwitch $MgmtVds -Teaming FAILOVER_ORDER -Mtu "9000" 

# Get the ipPool by name
My-Logger "Getting the NSX pool by name"
$MgmtVtepPool = Get-NsxIpPool -Name "Controller Pool"

# Create new vxlan portgroup
My-Logger "Prepping hosts in cluster"
Get-Cluster $MgmtCluster | New-NsxClusterVxlanConfig -VirtualDistributedSwitch $MgmtVds -ipPool $MgmtVtepPool | out-null
<#

If you get something like "is in an inconsistent state UNINSTALLED" at this step, and you have uninstalled (deprepped) the hosts, make sure you put 
them in maintenance mode so the unistall actually happens.

#>

Disconnect-NsxServer


$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "NSX Host Prep Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"