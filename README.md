# PSCopyDHCP

##RestoreDHCPFromBackup

The "RestoreDHCPFromBackup.ps1" script will copy the backup folder from a remote server and copy it to a new DHCP server. 

Running the script:

* Change the name of the "RemoteServer" in the settings.json to the old DHCP Server's name.
* Run the script from the new DHCP Server.
* Once the script finishes the "DHCP Server" service will need to be restarted. 