﻿$String = "SettingNamel"
$Domain = "Domain.local"

$Container = @()
$NearestDC = (Get-ADDomainController -Discover -NextClosestSite).Name

#Get a list of GPOs from the domain
$GPOs = Get-GPO -All -Domain $Domain -Server $NearestDC | sort DisplayName
 
#Go through each Object and check its XML against $String
Foreach ($GPO in $GPOs)  {
  
  Write-Host "Working on $($GPO.DisplayName)"
  
  #Get Current GPO Report (XML)
  $CurrentGPOReport = Get-GPOReport -Guid $GPO.Id -ReportType Xml -Domain $Domain -Server $NearestDC
  
  If ($CurrentGPOReport -match $String)  {
	Write-Host "A Group Policy matching ""$($String)"" has been found:" -Foregroundcolor Green
	Write-Host "-  GPO Name: $($GPO.DisplayName)" -Foregroundcolor Green
	Write-Host "-  GPO Id: $($GPO.Id)" -Foregroundcolor Green
	Write-Host "-  GPO Status: $($GPO.GpoStatus)" -Foregroundcolor Green

    $Container = $Container + $GPO.DisplayName

  }
  
}

#Write down All GPOs that match $String
Write-Host "`n`n""Following GPOs match '$($String)':" -Foregroundcolor Green 

Foreach ($Containment in $Container) {

    Write-Host "-  $($Containment)" -ForegroundColor Green
}
