<#
Script name: VerifyNSXRegistration.ps1 
03/21/2018
Author: Dana Gertsch
Description: The purpose of the script is to verify NSX registration on the nested hosts for our PowerCLI/NSX workshop
Dependencies: None known

===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 10.0.789315
PowerNSX Verions: 3.0.1091
PowerShell Version: 5.0
OS Version: Windows 2012
Keyword: VM
#>
Import-Module PowerNSX



# NSX Manager Configuration

$NSXHostname = "10.44.17.15"
$NSXCLIPassword = "VMw@re123!"
$NSXUIPassword = "VMw@re123!"

# VCSA Deployment Configuration

$VCSAHostname = "10.44.17.14" #Change to IP if you don't have valid DNS
$VCSASSODomainName = "vsphere.local"
$VCSASSOSiteName = "default-site"
$VCSASSOPassword = "VMware1!"
$VCSARootPassword = "VMware1!"

# Do not edit below this line

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

My-Logger "Registering NSX Manager ...."
Connect-NSXServer -Server $NSXHostname -Username admin -Password $NSXUIPassword -DisableVIAutoConnect -WarningAction SilentlyContinue
My-Logger "Successfully logged into NSX Manager $NSXHostname ..."


$ssoUsername = "administrator@$VCSASSODomainName"
My-Logger "Registering NSX Manager with vCenter Server $VCSAHostname ..."
$vcConfig = Set-NsxManager -vCenterServer $VCSAHostname -vCenterUserName $ssoUsername -vCenterPassword $VCSASSOPassword

My-Logger "Registering NSX Manager with vCenter SSO $VCSAHostname ..."
$ssoConfig = Set-NsxManager -SsoServer $VCSAHostname -SsoUserName $ssoUsername -SsoPassword $VCSASSOPassword -AcceptAnyThumbprint

My-Logger "Disconnecting from NSX Manager ..."
Disconnect-NsxServer


$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "NSX Manager Deployment Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"