$RemoteServer = (get-content settings.json |ConvertFrom-Json).RemoteServer

$BackupPath = Invoke-Command -ComputerName $RemoteServer -ScriptBlock{
    (get-DHCPServerDatabase).backuppath
}

#Converts local drive of the remote to a network share.
if ($BackupPath -ne "\*") {
    $SplitPath = $BackupPath -split ":"
    $ConvertLocal = $SplitPath[0]
    $RemoteDirectory = $SplitPath[1]

    $BackupPath = "\\$RemoteServer\$ConvertLocal`$$RemoteDirectory"
}

Copy-Item -path $BackupPath -Destination .\
$ShareLocation = $BackupPath

restore-DHCPServer -path $ShareLocation