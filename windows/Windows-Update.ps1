#Run –> cmd

#Run the following command to check for new updates:
wuauclt /detectnow 

#Run the following command to install new updates
wuauclt /updatenow

#Since the command prompt does not show any progress, a better approach would be to check and install updates at the same time. Here’s the command for this:
wuauclt /detectnow /updatenow

StartScan – Start checking for updates
StartDownload – Start downloading updates
StartInstall – Start installing downloaded updates
RestartDevice – Restart Windows after updates are installed
ScanInstallWait – Check for updates, download available updates and install them