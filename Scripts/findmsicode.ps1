$UinstallPaths = @(
                "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                "Registry::HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
                )

foreach ($Path in $UinstallPaths){
                $MsiCode = Get-ChildItem $Path | 
                Where-Object { $_.GetValue('DisplayName') -match "Royal*" } |
                ForEach-Object { $_.GetValue('UninstallString') }  
                Write-Output $MsiCode                 
                }
                        
           
            


