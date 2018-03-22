<#
Script to enable vmotion on the VM Network
Kovarus
03/19/2018

#>
$vcuser = "administrator@vsphere.local"
$vcpassword = "VMware1!"


$vc = Connect-VIServer "vcenter.corp.local" -User $vcuser -Password $vcpassword
$esxhosts = Get-VMHost
foreach ($esxhost in $esxhosts) {
# Get the Management Network VMK and enable VMotion
    Get-VMHostNetworkAdapter -VMHost $esxhost -VMKernel | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false
    Write-Host "Enabling VMotion on $esxhost"
 }