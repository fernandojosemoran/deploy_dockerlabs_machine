Import-Module .\lengStore.ps1 -Force

class WslInstallationAndConfiguration {

    hidden [void]VerifyIfExistWinget($Lang) {
        $Language = LangStore -Language $Lang
        if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue).Name) {
            try {
                Write-Output $Language.IntallingWSL[2]
                Write-Output $Language.IntallingWSL[3]
                
                #Install WSL if isn't installed
                [string]$ExecutableName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
                Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.7.3452-preview/$ExecutableName" -OutFile $ExecutableName

                # Open the executable to install winget manually
                powershell.exe -c "Start-Process '$pwd\$ExecutableName'"
                powershell.exe -c "DISM /Online /Enable-Feature /FeatureName:VirtualMachinePlatform /All /NoRestart"
                Write-Output $Language.IntallingWSL[4]
                exit
            }
            catch {
                Write-Output $Language.IntallingWSL[5]
                Write-Output $Language.IntallingWSL[4]
                exit
            }
        }
    }

    [void]MainInstallWSL($Lang) {
        $Language = LangStore -Language $Lang
        
        [bool]$ExistUbuntu = $false
        foreach ($text in (wsl --list)) { if (-not ([string]$text -ne "Ubuntu (Default)")) { $ExistUbuntu = $true } }
        if (-not $ExistUbuntu) {
            Write-Output $Language.IntallingWSL[0]
            Write-Host $Language.IntallingWSL[1] -ForegroundColor "Magenta"
            #Verify the installation and enablement of virtualization features.
            
            VerifyIfExistWinget($Language)
  
            try {
                function ActivateFeatures {
                    powershell.exe -c "dism.exe /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V"
                    powershell.exe -c "dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
                    powershell.exe -c "dism.exe /Online /Enable-Feature /FeatureName:HypervisorPlatform /all /noRestart"
                    powershell.exe -c "dism.exe /Online /Enable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux /all /noRestart"
                }
                ActivateFeatures
              
                wsl --install 
                wsl --set-default-version 2
                bcdedit / set hypervisorlaunchtype Auto
  
                Write-Host $Language.IntallingWSL[6] -ForegroundColor "Green"
                [string]$SystemRestart = Read-Host -Prompt $Language.IntallingWSL[7]
                if ($SystemRestart.ToLower() -eq "y") { shutdown.exe -r -t 5 } else { Write-Output $Language.IntallingWSL[8] }
                exit
            }
            catch {
                Write-Host "" -ForegroundColor "Red"
            }
        }
    }
}