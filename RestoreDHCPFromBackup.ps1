$RemoteServer = 'TestServer'

Invoke-Command -ComputerName $RemoteServer -ScriptBlock{
    $ShareLocation = ''
    $BackupPath = (get-DHCPServerDatabase).backuppath
    Copy-Item -path $BackupPath -Destination $ShareLocation
}

