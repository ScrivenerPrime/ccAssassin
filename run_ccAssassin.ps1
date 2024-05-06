# ====================================================================
# ccAssassin by ScrivenerPrime
# ====================================================================
# Base thread for running ccAssassin, checks for Admin Rights, requests them if not, and then starts the app.

function CheckAndPromptForAdminRights {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $windowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-NOT $isAdmin) {
        $response = Read-Host "For best effectiveness, this script needs to run as Administrator.\n
        Do you want to restart in Administrator mode? (Y/n)"
        if ($response -eq 'Y') {
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        } else {
            Write-Host "Very well. Running script in Regular Mode."
        }
    }
}

# Check for admin rights and prompt if necessary
CheckAndPromptForAdminRights

# Try to run the main script adobe_assassin.ps1 in a separate thread
try {
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\ccAssassin.ps1`""
    Start-Process powershell.exe -ArgumentList $arguments -Wait -NoNewWindow
}
catch {
    Write-Host "An error occurred while trying to run the script: $($_.Exception.Message)"
}
finally {
    Write-Host "Script completed."
    # Pause for any key press before exiting
    # Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

exit