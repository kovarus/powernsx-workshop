<#
Script to update vSphere, vCenter and NSX licenses
Plan to use partner evaluation licenses, which expire every 60 days or so.
Will need to provide the current license to the students, they should not be hard coded here
Kovarus
3/19/2018
!!! Broken - using deprecated API Calls
#>
$vcenter = "vcenter.corp.local"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"
$vcenterLicense = "00000-00000-00000-00000-00000" # From https://pubs.vmware.com/vsphere-6-0/index.jsp?topic=%2Fcom.vmware.powercli.ug.doc%2FGUID-69F2FB42-EE23-4311-A4A9-5D4C7BB6E97A.html
$ESXiLicense = ""
$NSXLicense = ""

# Connect to vCenter
$vc = Connect-VIServer $vcenter -User $vcuser -Password $vcpassword

# Get the current licenses
$LicenseManager = get-view($vc.ExtensionData.content.LicenseManager)

# Add the vCenter License
# Test using the KB value
$LicenseManager.AddLicense($vcenterLicense,$null)

# Add the ESXI Licenses

# Add the NSX Licenses

# Assign the licenses
$LicenseAssignmentManager = get-view($LicenseManager.LicenseAssignmentManager)
$LicenseAssignmentManager.