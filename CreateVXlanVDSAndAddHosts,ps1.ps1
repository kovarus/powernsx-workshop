<#
Script to create VDS for NSX
Kovarus
3/19/2018

#>
$vcenter = "vcenter.corp.local"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"
$DVSVMnic = "vmnic1"
$datacenter = "Datacenter"
$newVDSwitch = "vDS vxlan"

# Connect to vCenter
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword

$myDataCenter = Get-Datacenter -Name $datacenter

$vmhosts = $myDataCenter | Get-VMHost

# Create the new vDS

$myVDSSwitch = New-VDSwitch -Name $newVDSwitch -Location $datacenter

# Hosts to vDS
Add-VDSwitchVMHost -VDSwitch $myVDSSwitch -VMHost $vmhosts

# Get the VMNICs
$hostsPhysicalNic = $vmhosts | Get-VMHostNetworkAdapter -Name $DVSVMnic

# Add Nic to VDS
Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $hostsPhysicalNic -DistributedSwitch $newVDSwitch -Confirm:$false



