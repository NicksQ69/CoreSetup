# CoreSetup

## How to build the application as a Windows executable

### Prerequisites :
Run the Powershell application and then paste the commands below:
>Install-Module ps2exe

If you receive an error telling you that Install-Module is unable to run, run the following command to authorize the execution:
>Set-ExecutionPolicy Unrestricted

>Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

Now try again the Install-Module command.

### Building the Windows executable
Copy and paste the following command into a powershell from the folder where the script is located:
>Invoke-PS2EXE "CoreSetup.ps1" "CoreSetup.exe" -noConsole
