

#Test if DHCP Server is installed
if ((Get-windowsfeature -name dhcp).installedstate -eq "installed"){

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

    if ($TestBackupLocation -eq $True){
        #Create an array to store duplicate folder prefixes. 
        #They are used to create a prefix less likely to be a duplicate, such as "_".
        $UsedFolderNamePrefixes = @()

        function create-DHCPBackupDirectory {
            
            $ValidDirectory = $false
            while ($ValidDirectory -eq $false){
                $BackupFolderNamePrefix = Get-Random
                $UsedFolderNamePrefixes += $BackupFolderNamePrefix

                $LocalBackupPathName = (get-item $LocalBackupPath).Name
                $DirectoryCandiate = "$LocalBackupPathParent\$BackupFolderNamePrefix$LocalBackupPathName"

                $ValidDirectory = Test-Connection $DirectoryCandiate
            }

            return $DirectoryCandiate
             
            
        }

        create-DHCPBackupDirectory

        Rename-Item -path $TestBackupLocation -NewName "$env:windir\system32\dhcp\$BackupFolderNamePrefix"+"backup"
    }

    Copy-Item -path $RemoteBackupPath -Destination 
    $ShareLocation = $RemoteBackupPath

    restore-DHCPServer -path $ShareLocation

}else {
    Write-Host "The DHCP Server role has not been installed on the server"
}