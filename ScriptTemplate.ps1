<#
Script name: Put your name here 
Date: 
Author: Who 
Description: The purpose of the script is to ...
Dependencies: None known

===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 10.0.789315
PowerNSX Verions: 3.0.1091
PowerShell Version: 5.0
OS Version: Windows 2012
Keyword: VM
#>


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


$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "NSX Manager Deployment Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"