Import-Module .\lengStore.ps1 -Force
Import-Module .\bin\wsl.ps1 -Force
Import-Module .\bin\docker.ps1 -Force

$banner = "
   
                                    ','. '. ; : ,','
                                      '..'.,',..'
                                         ';.'  ,'
                                          ;;
                                          ;'
                            :._   _.------------.___
                    __      :__:-'                  '--.
             __   ,' .'    .'             ______________'.
           /__ '.-  _\___.'          0  .' .'  .'  _.-_.'
              '._                     .-': .' _.' _.'_.'
                 '----'._____________.'_'._:_:_.-'--'

   ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ ██╗      █████╗ ██████╗ ███████╗   ███████╗███████╗
   ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝   ██╔════╝██╔════╝
   ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝██║     ███████║██████╔╝███████╗   █████╗  ███████╗
   ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗██║     ██╔══██║██╔══██╗╚════██║   ██╔══╝  ╚════██║
   ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║███████╗██║  ██║██████╔╝███████║██╗███████╗███████║
   ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚══════╝
" 

Write-Host $Banner -ForegroundColor "Blue"

[array]$Language = LangStore -Language "en" 

if ($args.Count -eq 0) {
   function ShowGuide {
      Write-Output "`nUse --> ./auto_deploy.ps1 <file.tar> -parameter `n"
         
      Write-Host "`nYou have a optional parameter." -ForegroundColor "Blue"
      Write-Output "`nUse --> ./auto_deploy.ps1 <file.tar> -parameter -leng=(es,en)`n"
      exit
   }
   ShowGuide
}

if ($args.Count -eq 1) {
   Write-Host $Language.Main[2] -ForegroundColor "Red"
   exit
}

if ($args.Count -ge 2) {
   switch ($args[2]) {
      "-leng=es" {
         [array]$Language = LangStore -Language "es"
      }
      "-leng=en" {
         [array]$Language = LangStore -Language "en" 
      }
      $null {
         continue
      }
      default {
         Write-Host "`n[-] The langueage indicated not sopported.`n" -ForegroundColor "Red"
         exit
      }
   }
   
   [string]$TarFile = $args[0].Substring(2)
   [string]$ArgumentOption = $args[1]
}

$docker = [Docker]::New()
[string]$ContainerName = ("$TarFile" + "_container" -replace '.tar', '')
[string]$image = ($TarFile -replace '.tar', '')

function AnalysisSystemPrograms {
   # Verify if we have administrator permissions
   $CurrentTerminal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
   [bool]$IsAdministratorUser = $CurrentTerminal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

   if ($IsAdministratorUser) {
      # Verify if Docker exists on the system
      [Wsl]::MainInstallWSL($Language)

      if (-not (Get-Command Docker -ErrorAction SilentlyContinue).Name) {
         [Docker]::MainInstallDocker()
         # Activate the Hyper-V feature so that Docker can run properly
         powershell.exe -c "dism /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V"
         [string]$SystemRestart = Read-Host -Prompt $Language.IntallingWSL[7]
         if ($SystemRestart.ToLower() -eq "y") { shutdown.exe -r -t 5 } else { Write-Output $Language.IntallingWSL[8] }
         exit
      }
   }
   else {
      Write-Host $Language.VerifyPermissions[0] -ForegroundColor "Red"
      exit
   }
}

function Main {
   switch ($ArgumentOption) {
      "--run" {
         Write-Debug "$ContainerName, $image,$TarFile, $Language"
         $docker.CreateContainer($ContainerName, $image, $TarFile, $Language)
      }
      "--remove" {
         Write-Debug "$ContainerName, $image, $Language"
         $docker.RemoveContainer($ContainerName, $image, $Language)
      }
      "--test" {
         AnalysisSystemPrograms
         Write-Host $Language.Main[0] -ForegroundColor "Green"
      }
      "--help" {
         function ShowOptions {
            $HelpOptions = @{
               "--run"    = $Language.HelpOptions[0]
               "--remove" = $Language.HelpOptions[1]
               "--test"   = $Language.HelpOptions[2]
            }
        
            Write-Output $Language.Main[1]
        
            foreach ($key in $HelpOptions.Keys) {
               [string]$value = $HelpOptions[$key]
               Write-Output ("{0, -10} {1}" -f $key, $value)
            }
        
            Write-Output "`n"
         }
         ShowOptions
      }
      $null {
         Write-Host $Language.Main[2] -ForegroundColor "Red"
      }
      default {
         Write-Host $Language.Main[3] -ForegroundColor "Red"
      }
   } 
}

Main

# By following me
# Github    ---> https://github.com/fernandojosemoran/
# Linkeding ---> 