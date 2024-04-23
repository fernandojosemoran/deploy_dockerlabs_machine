Import-Module .\lengStore.ps1 -Force
Import-Module .\bin\wsl.ps1 -Force

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

if (
      ($args[0].ToLower() -eq $null -and $args[1] -eq $null) -or 
      ($args[0].ToLower() -eq "--run") -or 
      ($args[0].ToLower() -eq "--remove") -or 
      ($args[0].ToLower() -eq "--test")
) {
   function ShowGuide {
      Write-Output "`nUse --> ./auto_deploy.ps1 <file.tar> -parameter `n"
      
      Write-Output "`nYou have a optional parameter.`n"
      Write-Output "`nUse --> ./auto_deploy.ps1 <file.tar> -parameter -leng=(es,en)`n"
   }
   ShowGuide
   exit
}
else {
   switch ($args[2]) {
      "-leng=es" {
         [array]$Language = LangStore -Language "es"
      }
      "-leng=en" {
         [array]$Language = LangStore -Language "en" 
      }
      $null {
         [array]$Language = LangStore -Language "en" 
      }
      default {
         Write-Host "`n[-] The langueage indicated not sopported.`n" -ForegroundColor "Red"
         exit
      }
   }

   [string]$TarFile = $args[0].Substring(2)
   [string]$ArgumentOption = $args[1]
}

[string]$ContainerName = ("$TarFile" + "_container" -replace '.tar', '')
[string]$image = ($TarFile -replace '.tar', '')

function InstallDocker {
   Write-Output $Language.InstallDocker[0]

   try {
      # There's a error of winget called 'Failed when searching source: msstore'
      winget.exe install --id "Docker.DockerDesktop"
      # If the error ocurred then install docker manually
      if (-not $?) {
         function InstallDockerManually {
            Write-Output "`nThere's a error with your winget.exe"
            [string]$Restart = Read-Host "`nYou want to Install docker manually (y/n)."

            if ($Restart -eq "y") {  
               [string]$DockerEncodeUrl = "Docker%20Desktop%20Installer.exe"
               # Decode the url to obtain a legible url
               [string]$DockerDecodeUrl = [System.Web.HttpUtility]::UrlDecode($DockerEncodeUrl)
               # concat the string to format the link to download docker
               Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/$DockerEncodeUrl" -OutFile $DockerDecodeUrl
               Write-Host "`nYou must click on next always.`n" -ForegroundColor "Magenta"
               powershell.exe -c "Start-Process '$pwd\$DockerDecodeUrl'"
               Write-Output "Again to execute the script after to install docker manually"
               exit
            }
         }
         else {
            Write-Host $Language.InstallDocker[1] -ForegroundColor "Green"
         }

         InstallDockerManually
      }
   }
   catch {
      Write-Host $Language.InstallDocker[2] -ForegroundColor "Red"
   }
}

function AnalysisSystemPrograms {
   $WslInstance = [WslInstallationAndConfiguration]::New()

   function VerifyPermissions {
      # Verify if we have administrator permissions
      $CurrentTerminal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
      [bool]$IsAdministratorUser = $CurrentTerminal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

      if ($IsAdministratorUser) {
         #Verify if Docker exists on the system
         $WslInstance.MainInstallWSL($Language)

         if (-not (Get-Command Docker -ErrorAction SilentlyContinue).Name) {
            InstallDocker
            #Activate the feature de hyper-v for that docker can run well
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

   VerifyPermissions
}


function RemoveContainer {
   if ($(docker ps -a -q -f name=$ContainerName -f status=exited)) {
      docker rm $ContainerName
   }

   if (docker ps -q -f name=$ContainerName) {
      docker stop $ContainerName 
      docker rm $ContainerName 
   }

   if (docker images -q $image) {
      docker rmi $image
   }
   
   Write-Host "`n[+] The lab is deleted.`n" -ForegroundColor "Green"
   
   # Stop-Process -Name docker -Force
}

function CreateContainer {
   (docker images 2>$null) > $null

   if ($?) {
      # Start-Process docker
      Write-Output "`nDeploying the lab.`n"
      docker load -i $TarFile
   
      if ($?) {
         [string]$hash = docker run -d --name $ContainerName $image
         Write-Output "`nThe hash of the container $ContainerName is $hash"
         [string]$IpAddress = $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ContainerName)
         Write-Host ($Language.CreateContainer[0] + $IpAddress) -ForegroundColor "Green"
      }
      else {
         Write-Host $Language.CreateContainer[1] + "`n" -ForegroundColor "Red"
      }
   }
   else {
      Write-Host "`n[-] Docker isn't turn on.`n" -ForegroundColor "Red"
   }
}

function Main {
   switch ($ArgumentOption) {
      "--run" {
         CreateContainer
      }
      "--remove" {
         RemoveContainer
      }
      "--test" {
         AnalysisSystemPrograms
         Write-Host $Language.Main[0] -ForegroundColor "Green"
      }
      "--help" {
         function ShowOptions {
            [HashTable]$HelpOptions = @{
               "--run"    = $Language.HelpOptions[0]
               "--remove" = $Language.HelpOptions[1]
               "--test"   = $Language.HelpOptions[2]
            }
   
            Write-Output $Language.Main[1]
   
            foreach ($key in $HelpOptions.Keys) {
               [string]$value = $HelpOptions[$key]
               Write-Output ("{ 0, -10 } { 1 }" -f $key, $value)
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