class Docker {
    
    [void] CreateContainer ([string]$ContainerName, [string]$Image, [string]$TarFile, $Language) {

        # The IP returned by Docker doesn't seem to respond, as it probably requires the Hyper-V feature, which is only available in Windows Pro or other versions besides Home.
        # Without this feature, it's not possible to create a network interface that the machine can use to communicate with the local network.
        # probably solution https://4sysops.com/archives/windows-container-networking-part-1-configuring-nat/

        (docker images 2>$null) > $null
 
        if ($?) {
            # Start-Process docker
            Write-Output "`nDeploying the lab.`n"
            docker load -i $TarFile
    
            if ($?) {
                [string]$hash = docker run -d --name $ContainerName $image
                Write-Output "`nHASH=$hash"
                [string]$IpAddress = $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ContainerName)
                Write-Host ($Language.CreateContainer[0] + $IpAddress + "`n") -ForegroundColor "Green"
            }
            else {
                Write-Host ($Language.CreateContainer[1]) -ForegroundColor "Red"
            }
        }
        else {
            Write-Host "`n[-] Docker isn't turn on.`n" -ForegroundColor "Red"
        }
    }

    [void] RemoveContainer ([string]$ContainerName, [string]$Image, $Language) {
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

    hidden [void] InstallDockerManually () {
        Write-Output "`nThere's a error with your winget.exe"
        [string]$Restart = Read-Host "`nYou want to Install docker manually (y/n)."

        if ($Restart -eq "y") {  
            [string]$DockerEncodeUrl = "Docker%20Desktop%20Installer.exe"
            # Decode the URL to obtain a readable URL
            [string]$DockerDecodeUrl = [System.Web.HttpUtility]::UrlDecode($DockerEncodeUrl)
            # Concatenate the string to format the link to download Docker
            Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/$DockerEncodeUrl" -OutFile $DockerDecodeUrl
            Write-Host "`nYou must click on next always.`n" -ForegroundColor "Magenta"
            powershell.exe -c "Start-Process '$pwd\$DockerDecodeUrl'"
            Write-Output "Again to execute the script after to install docker manually"
            exit
        }
    }


    static [void] MainInstallDocker ($Language) {
        Write-Output $Language.InstallDocker[0]
        try {
            # There's an error with Winget called 'Failed when searching source: msstore
            winget.exe install --id "Docker.DockerDesktop" 2> $null
            # If the error occurred, then install Docker manually
            if (-not $?) {
                InstallDockerManually
            }
            else {
                Write-Host $Language.InstallDocker[1] -ForegroundColor "Green"
                exit
            }
        }
        catch {
            Write-Host $Language.InstallDocker[2] -ForegroundColor "Red"
            exit 
        }
    }
}