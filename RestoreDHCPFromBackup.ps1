
function create-DHCPBackupDirectory {
    #Renames dhcp backup folder if it already exists.
    $DirectoryExists = $true
    while ($DirectoryExists -eq $true){
        $BackupFolderNamePrefix = Get-Random
        $UsedFolderNamePrefixes += $BackupFolderNamePrefix

        $LocalBackupPathName = (get-item $LocalBackupPath).Name
        $DirectoryCandiate = "$LocalBackupPathParent\$BackupFolderNamePrefix$LocalBackupPathName"

        #Stops loop when an appropriate directory name is found
        $DirectoryExists = Test-path $DirectoryCandiate
    }

    Rename-Item -path $LocalBackupPath -NewName $DirectoryCandiate
         
}

#Test if DHCP Server is installed
if ((Get-windowsfeature -name dhcp).installstate -eq "installed"){

    $RemoteServer = (get-content settings.json |ConvertFrom-Json).RemoteServer
    
    #Local backup location
    $LocalBackupPath = (get-DHCPServerDatabase).backuppath

    #Gets the parent directory of the local backup location
    $LocalBackupPathParent = (get-item $LocalBackupPath).Parent.FullName

    $RemoteBackupPath = Invoke-Command -ComputerName $RemoteServer -ScriptBlock{
        (get-DHCPServerDatabase).backuppath
    }

    #Converts local drive of the remote to a network share.
    if ($RemoteBackupPath -ne "\*") {
        $SplitPath = $RemoteBackupPath -split ":"
        $ConvertLocal = $SplitPath[0]
        $RemoteDirectory = $SplitPath[1]

        $RemoteBackupPath = "\\$RemoteServer\$ConvertLocal`$$RemoteDirectory"
    }

    #Tests if the folder in the DHCP settings exists.
    $TestBackupLocation = test-path -path $LocalBackupPath

    if ($RemoteBackupPath -ne $LocalBackupPath){
        
        #Creates a backup directory on the new DHCP server, if a backup folder already exists.
        if ($TestBackupLocation -eq $True -and $RemoteBackupPath -ne $LocalBackupPath){create-DHCPBackupDirectory}

        #Copies the backup from the old DHCP server to the new DHCP server.
        Copy-Item -path $RemoteBackupPath -Destination $LocalBackupPath -Recurse

    }
        
    restore-DHCPServer -path $LocalBackupPath

}else {Write-Host "The DHCP Server role has not been installed on the server"}