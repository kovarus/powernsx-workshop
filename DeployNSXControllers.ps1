<#
Script name: DeployNSXControllers.ps1 
03/21/2018
Author: Dana Gertsch
Description: The purpose of the script is to deploy NSX Controller for our PowerCLI/NSX workshop
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
$MgmtDatastoreName = "Storage"
$ManagementPortGroupName = "DPortGroup"


# NSX Settings
$ControllerPassword = "VMw@re123!VMw@re123!"
$NsxManagerIpAddress = "10.44.17.15"
$NsxManagerPassword = "VMware123!"

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

#Connect to NSX
My-Logger "Connecting to vCenter"
Connect-NsxServer -vCenterServer $vcenter -Username $vCenterUsername -Password $vCenterPassword -DefaultConnection:$true

$MgmtCluster = Get-Cluster $MgmtClusterName
$MgmtDatastore = Get-Datastore $MgmtDatastoreName
$ManagementPortGroup = Get-VDPortgroup $ManagementPortGroupName

# Check to see if the Controller Pool already exists
My-Logger "Check for pre-existing NSX IPPool"
if (Get-NsxIpPool -Name "Controller Pool") {
    My-Logger "The Controller Pool already exists"
} else {

My-Logger "Creating IP Pool for Controller addressing"

$ControllerPool = New-NsxIpPool -Name "Controller Pool" -Gateway $ManagementNetworkGateway -SubnetPrefixLength $ManagementNetworkSubnetPrefixLength -DnsServer1 $DnsServer1 -DnsSuffix $DnsSuffix -StartAddress $ControllerPoolStartIp -EndAddress $ControllerPoolEndIp

}
My-Logger "Deploying NSX Controller"


$Controller = New-NsxController -ipPool $ControllerPool -Cluster $MgmtCluster -datastore $MgmtDatastore -PortGroup $ManagementPortGroup -password $ControllerPassword -confirm:$false -wait

My-Logger "Controller online."



$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "NSX Manager Deployment Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"