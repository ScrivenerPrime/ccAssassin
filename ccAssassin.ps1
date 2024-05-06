# ====================================================================
# ccAssassin for Powershell v0.2.0 by ScrivenerPrime
# ====================================================================
# This script first checks for Admin Rights, requests them if not, and
# then starts the carnage. It can be run without Admin, but will only
# be able to stop processes that are running under the same user.
# ====================================================================
# Sources:
# https://gist.github.com/carcheky/530fd85ffff6719486038542a8b5b997#gistcomment-3586740
# https://github.com/t4rra/CCStopper
# ====================================================================


function ccMakeAdmin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $windowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-NOT $isAdmin) {
        $response = Read-Host "For best effectiveness, this script needs to run as Administrator.\n
        Do you want to restart in Administrator mode? (Y/n)"
        if ($response -ne 'Y') {
            Write-Host "Very well. Running script in Regular Mode."
        } else {
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
    }
}

function ccPromptAndExit {
    Write-Host "Press any key within 5 seconds to check for any sneaky restarts..."

    for ($i = 0; $i -lt 5; $i++) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Write-Host "Running script again... If you continue to see Adobe processes, you may need to manually stop them."
            Write-Host "We'll wait 60 seconds to give them time to start up again..."
            Start-Sleep -Seconds 60
            ccSniper
            exit
        }

        Start-Sleep -Seconds 1
    }

    Write-Host "No key pressed. Exiting script..."
    exit
}

function ccSniper {
    # Check to see if any Adobe apps are running by looking for .exe files
    # that start with "Adobe" or are located in a folder with "Adobe" in the
    # path, and the file type is .exe
    $adobeProcesses = Get-Process | ForEach-Object {
        try {
            if (($_.ProcessName -like "Adobe*" -or $_.Path -like "*Adobe*") -and $_.Path -like "*.exe") {
                $_
            }
        } catch {
            Write-Host "Error occurred when checking process $($_.Id): $($_.Exception.Message)"
        }
    }

    # Print a list of discovered Adobe processes
    if ($adobeProcesses) {
        Write-Host "The following Adobe processes are running:"
        $adobeProcesses | Format-Table -Property Id, ProcessName, Path -AutoSize
        Write-Host "Save your work and close any Adobe apps before continuing."
        # Wait for user to acknowledge the message with a Y or N to continue
        $response = Read-Host "Do you want to continue? (Y/n)"
        if ($response -ne "Y") {
            Write-Host "Exiting script."
            Exit
        } else {
            Write-Host "Closing Adobe apps..."
            # for each process, stop the process
            foreach ($process in $adobeProcesses) {
                # Check if the process is still running
                if (Get-Process -Id $process.Id -ErrorAction SilentlyContinue) {
                    try {
                        Stop-Process -Id $process.Id -Force
                        Write-Host "Stopped process $($process.Id): $($process.ProcessName)"
                    } catch {
                        Write-Host "Failed to stop process $($process.Id): $($process.ProcessName). This may be due to lack of admin rights."
                    }
                } else {
                    Write-Host "Process $($process.Id): $($process.ProcessName) is no longer running."
                }
            }
        }
    } else {
        Write-Host "No Adobe processes are running."
        ccPromptAndExit
    }
}

# Check for admin rights and prompt if necessary
ccMakeAdmin

# Run the function
Clear-Host
Write-Host @'
========================== Prepare to be Terminated! =========================
                  █████╗ ███████╗███████╗ █████╗ ███████╗███████╗██╗███╗   ██╗
 ██████╗ ██████╗ ██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝██║████╗  ██║
██╔════╝██╔════╝ ███████║███████╗███████╗███████║███████╗███████╗██║██╔██╗ ██║
██║     ██║      ██╔══██║╚════██║╚════██║██╔══██║╚════██║╚════██║██║██║╚██╗██║
╚██████╗╚██████╗ ██║  ██║███████║███████║██║  ██║███████║███████║██║██║ ╚████║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝
============================== by ScrivenerPrime ==================== v0.2.0 =
'@

ccSniper

# Prompt for rerun or exit
ccPromptAndExit