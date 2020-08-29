$RemoteServer = 'TestServer'
$ShareLocation = ''

Invoke-Command -ComputerName $RemoteServer -ScriptBlock{
    $BackupPath = (get-DHCPServerDatabase).backuppath
    Copy-Item -path $BackupPath -Destination $ShareLocation
}

