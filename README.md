```
============================ Prepare to be Terminated! ===========================
//////////////////////////////////////////////////////////////////////////////////
////////////////////█████╗/███████╗███████╗/█████╗/███████╗███████╗██╗███╗///██╗//
///██████╗/██████╗/██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝██║████╗//██║//
//██╔════╝██╔════╝/███████║███████╗███████╗███████║███████╗███████╗██║██╔██╗/██║//
//██║/////██║//////██╔══██║╚════██║╚════██║██╔══██║╚════██║╚════██║██║██║╚██╗██║//
//╚██████╗╚██████╗/██║//██║███████║███████║██║//██║███████║███████║██║██║/╚████║//
///╚═════╝/╚═════╝/╚═╝//╚═╝╚══════╝╚══════╝╚═╝//╚═╝╚══════╝╚══════╝╚═╝╚═╝//╚═══╝//
//////////////////////////////////////////////////////////////////////////////////
================================ by ScrivenerPrime ===============================
```
# ccAssassin for PowerShell

ccAssassin is a PowerShell script designed to stop and disable Adobe processes
and scheduled tasks. It's particularly useful when you need to free up system
resources or troubleshoot Adobe software.

## Features

- Checks for Adobe processes and offers to terminate them.
- Checks for Adobe scheduled tasks and offers to disable them.
- Offers to elevate itself to run with administrator privileges for better
  effectiveness.

## Usage

1. Open PowerShell.
2. Navigate to the directory containing `ccAssassin.ps1`.
3. Run the script with `.\ccAssassin.ps1`.

The script will first check if it's running with administrator privileges. If
not, it will ask if you want to restart it as an administrator. This is
recommended for best effectiveness.

Next, the script will check for running Adobe processes and offer to terminate
them. It will list the processes it found and ask for confirmation before
proceeding.

If the script is running with administrator privileges, it will also check for
enabled Adobe scheduled tasks and offer to disable them. Again, it will list
the tasks it found and ask for confirmation before proceeding.

## Requirements

- Windows operating system
- PowerShell 5.1 or later

## Disclaimer

This script forcefully terminates processes and disables scheduled tasks. Make
sure to save your work in any open Adobe applications before running this
script. Use at your own risk.

## Future Plans

- Add arguments for running hands-free.
- Maybe a function to set up a task for running this script in the background.

## License

This script is released under the Creative Commons 4.0 BY-NC-SA

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt

## Thanks

- https://gist.github.com/carcheky/530fd85ffff6719486038542a8b5b997#gistcomment-3586740
- https://github.com/t4rra/CCStopper