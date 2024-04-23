function LangStore {
    param (
        [string]$Language
    )

    switch ($Language) {
        "es" {
            return @{
                HelpOptions       = @(
                    "Despliega el contenedor del laboratorio.",
                    "Elimina todos los rastros de la máquina, incluidos (contenedores, imágenes, redes, volúmenes).",
                    "Realiza un análisis del sistema, verificando que el sistema tenga los programas necesarios instalados para desplegar el laboratorio."
                )
                InstallDocker     = @(
                    "`nInstalando Docker.`n",
                    "`n[+] Docker instalado exitosamente.",
                    "`n[-] Lo siento, ocurrió un error durante la instalación.`n"
                )
                IntallingWSL      = @(
                    "`nInstalando Ubuntu en WSL (Windows Subsystem for Linux)",
                    "`nDurante el proceso de instalación de WSL, presiona la tecla de espacio o la tecla Enter para avanzar con la instalación.`n",
                    "`nNo tienes winget.exe en tu sistema.",
                    "`nInstalando winget`n",
                    "`nVas por buen camino, ¡ejecuta el script de nuevo :)`n",
                    "`nOcurrió un error, intenta instalar el ejecutable manualmente. Puedes descargarlo desde https://aka.ms/getwinget.",
                    "`n[+] Ubuntu instalado en tu WSL (Windows Subsystem for Linux) Exitorsamente.",
                    "`nDebes reiniciar tu computadora para continuar con la configuración (y/n)",
                    "`nPor favor, es recomendable reiniciar tu sistema.`n"
                )
                VerifyPermissions = @(
                    "`n[-] Necesitas tener permisos de administrador.`n"
                )
                CreateContainer   = @(
                    "`n[+] La máquina ya está activa --> IP: ",
                    "`n[-] Se produjo un error al desplegar el laboratorio en Docker.`n"
                )
                Main              = @(
                    "`n[+] ¡Felicidades! Tienes los programas necesarios para desplegar el laboratorio.`n",
                    "Parametros`n",
                    "`n[-] Parametro no indicado.`n",
                    "`n[-] El parámetro indicado no existe.`n"
                )
            }
        }
        "en" {
            return @{
                HelpOptions       = @(
                    "Deploy the laboratory container.",
                    "Delete all traces of the machine including (containers, images, networks, volumes).",
                    "It performs a system analysis, verifying that the system has the necessary programs installed to deploy the lab."
                )
                InstallDocker     = @(
                    "`nInstalling Docker.`n",
                    "`n[+] Docker installed successfully.",
                    "`n[-] Sorry, an error occurred during installation.`n"
                )
                IntallingWSL      = @(
                    "`nInstalando Ubuntu en WSL (Windows Subsystem para Linux)",
                    "`nDurante el proceso de instalación de WSL, presiona la tecla de espacio o la tecla Enter para avanzar con la instalación.`n",
                    "`nNo tienes winget.exe en tu sistema.",
                    "`nInstalando winget",
                    "`nVas por buen camino, ¡ejecuta el script de nuevo :)`n",
                    "`nOcurrió un error, intenta instalar el ejecutable manualmente. Puedes descargarlo desde https://aka.ms/getwinget.",
                    "`n[+] Ubuntu instalado en tu WSL (Windows Subsystem para Linux) exitosamente.",
                    "`nDebes reiniciar tu computadora para continuar con la configuración (s/n)",
                    "`nPor favor, es recomendable reiniciar tu sistema.`n"
                )

                VerifyPermissions = @(
                    "`n[-] You need to have administrator permissions.`n"
                )
                CreateContainer   = @(
                    "`n[+] The machine is already active --> IP: ",
                    "`n[-] An error occurred while deploying the lab in Docker.`n"
                )
                Main              = @(
                    "`n[+] Congratulations! You have the necessary programs to deploy the lab.`n",
                    "Parameters`n",
                    "`n[-] Parameter don't indicated.`n",
                    "`n[-] The indicated parameter does not exist`n"
                )
            }
        }
    }
}