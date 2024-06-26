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
    $global:isAdmin = $windowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-NOT $isAdmin) {
        $response = Read-Host "For best effectiveness, this script needs to run as Administrator.\n
        Do you want to restart in Administrator mode? (Y/n)"
        if ($response -ne 'Y') {
            Write-Host "Very well. Running script in Regular Mode."
        } else {
            try {
                Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            } catch {
                Write-Host "Failed to start a new PowerShell process with admin rights: $($_.Exception.Message)"
                exit
            }
        }
    }
}

function ccSniper {
    Write-Host "Checking for Adobe Processes..."
    # Check to see if any Adobe apps are running by looking for .exe files
    # that start with "Adobe" or are located in a folder with "Adobe" in the
    # path, and the file type is .exe
    try {    
        $adobeProcesses = Get-Process | ForEach-Object {
            try {
                if (($_.ProcessName -like "Adobe*" -or $_.Path -like "*Adobe*") -and $_.Path -like "*.exe") {
                    $_
                }
            } catch {
                Write-Host "Error occurred when checking process $($_.Id): $($_.Exception.Message)"
            }
        }
    } catch {
        Write-Host "Error occurred when checking for Adobe processes: $($_.Exception.Message)"
        exit
    }

    # Print a list of discovered Adobe processes
    if ($adobeProcesses) {
        Write-Host "The following Adobe processes are running:"
        $adobeProcesses | Format-Table -Property Id, ProcessName, Path -AutoSize
        Write-Host "Save your work and close any Adobe apps before continuing."
        # Wait for user to acknowledge the message with a Y or N to continue
        $response = Read-Host "Do you want to continue with the operation? (Y/n)"
        if ($response -ne "Y") {
            Write-Host "Exiting script."
            Exit
        } else {
            Write-Host "Terminating Adobe apps, services, and background processes..."
            # for each process, stop the process
            foreach ($process in $adobeProcesses) {
                # Check if the process is still running
                if (Get-Process -Id $process.Id -ErrorAction SilentlyContinue) {
                    try {
                        Stop-Process -Id $process.Id -Force
                        if (Get-Process -Id $process.Id -ErrorAction SilentlyContinue) {
                            # TODO: This needs to happen later, after all processes are stopped
                            Write-Host "Failed to stop process $($process.Id): $($process.ProcessName). It's still running."
                        } else {
                            Write-Host "Stopped process $($process.Id): $($process.ProcessName)"
                        }
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
    }
}

function ccTaskHunter {
    # Get all scheduled tasks that have "Adobe" in the name and are not disabled
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Adobe*" -and $_.State -ne "Disabled" }
    
    if ($tasks) {
        # Print a list of discovered Adobe scheduled tasks
        $tasks | Format-Table -Property TaskName, State, LastRunTime, NextRunTime -AutoSize
        Write-Host "The following Adobe scheduled tasks are running:"
        
        # Prompt the user to disable the Adobe scheduled tasks
        $response = Read-Host "Do you want to disable them? (Y/n)"
        if ($response -eq "Y") {
            Write-Host "Disabling Adobe scheduled tasks..."
            # For each scheduled task, disable the task
            foreach ($task in $tasks) {
                try {
                    $disabledTask = Disable-ScheduledTask -TaskName $task.TaskName -PassThru
                    if ($disabledTask.State -eq "Ready") {
                        Write-Host "Failed to disable task $($task.TaskName). It's still enabled."
                    } else {
                        Write-Host "Disabled task $($task.TaskName)"
                    }
                } catch {
                    Write-Host "Failed to disable task $($task.TaskName). This may be due to lack of admin rights."
                }
            }
        } else {
            Write-Host "Exiting script."
            Exit
        }
    } else {
        Write-Host "Congrats! No Adobe scheduled tasks are enabled."
    }
}


# Check for admin rights and prompt if necessary
ccMakeAdmin

# Display the rad logo
Clear-Host
Write-Host @'
============================ Prepare to be Terminated! ===========================
//////////////////////////////////////////////////////////////////////////////////
////////////////////█████╗/███████╗███████╗/█████╗/███████╗███████╗██╗███╗///██╗//
///██████╗/██████╗/██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝██║████╗//██║//
//██╔════╝██╔════╝/███████║███████╗███████╗███████║███████╗███████╗██║██╔██╗/██║//
//██║/////██║//////██╔══██║╚════██║╚════██║██╔══██║╚════██║╚════██║██║██║╚██╗██║//
//╚██████╗╚██████╗/██║//██║███████║███████║██║//██║███████║███████║██║██║/╚████║//
///╚═════╝/╚═════╝/╚═╝//╚═╝╚══════╝╚══════╝╚═╝//╚═╝╚══════╝╚══════╝╚═╝╚═╝//╚═══╝//
//////////////////////////////////////////////////////////////////////////////////
================================ by ScrivenerPrime ====================== v0.3.0 =
'@

# Assassinate Adobe Processes and Services, Exterminate Scheduled Tasks
ccSniper

# If user is admin, check for scheduled tasks
if ($isAdmin) {
    Write-Host "Checking for Scheduled Tasks..."
    ccTaskHunter
}

# Press any key to exit
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


# TODO: add arguments for running hands-free
# TODO: maybe a function to set up a task for running this script in the background?