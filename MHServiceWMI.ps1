
function Get-MHServiceWMI {
<#
.SYNOPSIS
   Get Service Information from WMI
.DESCRIPTION
   This function retrieves Service information from WMI on the local computer by default or remote computer if specified.  The information returned is:
   -System Name: Name of Computer
   -Service Name: Display Name of the service
   -Start Mode: Automatic/Manual/Disabled/Delayed Start
   -State: Current running state
   -Start Name: The account that started the service
.NOTES
   Function Name : Get-MHServiceWMI
   Author : Matt Hitchcock
   Requires : PowerShell V2
.LINK
   http://matthitchcock.com/
.EXAMPLE
   Get-MHServiceWMI
   Returns WMI information for services running on the local computer.
.EXAMPLE
   Get-MHServiceWMI -ComputerName 'myserver'
   Returns WMI information for services running on the specified computer.
.PARAMETER ComputerName 
   Computer Name of target machine. Default Value is LocalHost 
#>

#parameter validataion
param ( 
   [Parameter(Position=0,Mandatory=$false,HelpMessage="Enter the target Computer Name")] 
   [validatenotnullorempty()]
   [Array] $ComputerName = "localhost"
) 
BEGIN 	{

foreach ($Server in $ComputerName) {

if (-NOT (Test-Connection -ComputerName $Server -Quiet -Count 1))	{
	Write-Warning "$Server cannot be contacted and will not be processed."
																	}
else {$Online += $Server}
 									}
									
# Administrator Check

foreach ($Server in $Online) 			{

	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
 														{
								Write-Warning "You do not have Administrator rights to run this script on $Server! This server will not be processed!"
 									
	else $TargetMachines += $Server
														}			
													
									}
						}
PROCESS {

if ($TargetMachines -NE $Null)	{

	$CollectedInfo = @()

		foreach ($machine in $TargetMachines) 	{

			$Temp = Get-WmiObject -ComputerName $Machine -Class Win32_Service | Select-Object Systemname,Name,StartMode,State,StartName
				foreach ($svc in $Temp) {
					$CollectedInfo += $Temp
										}

							
											}

							}
		}
		
	
END {

Write-Warning "All contactable machines have been processed."

return $CollectedInfo

	}
}


$MyLogFile = "c:\MyServerLog.csv"
	
$MyData = Get-MHServiceWMI -ComputerName localhost,unknown

$MyData | Export-Csv $MyLogFile -NoTypeInformation
