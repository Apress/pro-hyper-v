# Variable to keep track of your place in the HyperV_List.txt file.
$a = 0

# Define the namespace used for WMI queries
$Namespace = "root\virtualization"

# Set up the Foreach-object loop to act on each computer in the text file.
Get-Content HyperV_List.txt | Foreach-object {$Computer = (Get-Content HyperV_List.txt)[$a]

# Ping test to see if the target server is reachable.
$Ping = Get-WmiObject -Query "SELECT * FROM Win32_PingStatus WHERE Address = '$Computer'"

# If the target server is reachable through a ping, then go ahead with the script.
if ($Ping.StatusCode -eq 0)
{

# Define the WMI query object to change Hyper-V server settings.
$PathQuery = Get-WmiObject -Class "Msvm_VirtualSystemManagementService" `
-Computername $Computer -Namespace $Namespace
# Define the WMI query to get the Hyper-V server settings data.
$PathQueryData = Get-WmiObject –Class "Msvm_VirtualSystemManagementServiceSettingData" `
-Computername $Computer -Namespace $Namespace

# Set the value for the DefaultExternalDataRoot property.
$PathQueryData.DefaultExternalDataRoot = "e:\virtualmachines"

# Set the value for the DefaultExternalHardDiskPath property.
$PathQueryData.DefaultVirtualHardDiskPath = "e:\virtualdisks"

# Actually modify the default path settings.
$PathQuery.ModifyServiceSettings($PathQueryData.PSbase.GetText(1))

# WMI query used to set up the virtual switch.
$VirtualSwitchQuery = Get-WmiObject -Class "Msvm_VirtualSwitchManagementService" `
-Namespace $Namespace -ComputerName $Computer

# Create the virtual switch.
$ReturnObject = $VirtualSwitchQuery.CreateSwitch([guid]::NewGuid().ToString(), "Hyper-V External Switch", "1024","")

# Store the created switch as a WMI object for later use.
$CreatedSwitch = [WMI]$ReturnObject.CreatedVirtualSwitch

# Create the internal switch port.
$ReturnObject = $VirtualSwitchQuery.CreateSwitchPort($CreatedSwitch, ?
[guid]::NewGuid().ToString(), "InternalSwitchPort", "")

# Store the created internal switch port as a WMI object for later use.
$InternalSwitchPort = [WMI]$ReturnObject.CreatedSwitchPort

# Create the external switch port.
$ReturnObject = $VirtualSwitchQuery.CreateSwitchPort($CreatedSwitch,[guid]::NewGuid().ToString(), "ExternalSwitchPort", "")

# Store the external switch port as a WMI object for later use.
$ExternalSwitchPort = [WMI]$ReturnObject.CreatedSwitchPort

# Query to get the external NIC that will be bound to the virtual switch.
$ExternalNic = Get-WmiObject -Class "Msvm_ExternalEthernetPort" `
-Namespace $Namespace -ComputerName $Computer | `
Where-Object -FilterScript `
{$_.ElementName -eq "Marvell Yukon 88E8056 PCI-E Gigabit Ethernet Controller"}

# Configure the switch using all of the WMI objects and the external NIC.
$VirtualSwitchQuery.SetupSwitch($ExternalSwitchPort, $InternalSwitchPort, `
$ExternalNic, [guid]::NewGuid().ToString(), "Hyper-V Internal Ethernet Port")
}

# Increment the computer list array variable by 1.
$a = $a+1
# End the Foreach loop action
}

# Variable to keep track of your place in the HyperV_List.txt file.
$a = 0

# Set up a function to explicitly define an array.
function New-Array {,$args}

# Set up a new $HostUnreachable array with a space character.
$HostUnreachable = New-Array ""

# Set up a new $PathFail array with a space character.
$PathFail = New-Array ""

# Set up a new $PathSucceed array with a space character.
$PathSucceed = New-Array ""

# Set up a new $SwitchSucceed array with a space character.
$Switchsucceed = New-Array ""

# Set up a new $SwitchFail array with a space character.
$SwitchFail = New-Array ""

# Set up the Foreach-object loop to act on each computer in the text file.
Get-Content HyperV_List.txt | Foreach-object {$Computer = (Get-Content HyperV_List.txt)[$a]

# Ping test to see if the target server is reachable.
$Ping = Get-WmiObject -Query "SELECT * FROM Win32_PingStatus WHERE Address = '$Computer'"

# If the target server is reachable through a ping, then go ahead with the script.
# Else, store the computer name that the script is working on in the
# $HostUnreachable array.

if ($Ping.StatusCode -eq 0)
{
# Define the WMI query to get the Hyper-V server settings data.

$PathQueryData = Get-WmiObject -Class Msvm_VirtualSystemManagementServiceSettingData `
-Computername $Computer -Namespace $Namespace

# Define the WMI query to see if the target server has a NIC
# bound to a virtual switch.
$SwitchQueryData = Get-WmiObject -Class Msvm_ExternalEthernetPort -Computername $Computer `
-Namespace $Namespace | Where-Object -Filterscript {$_.IsBound -eq "True"}

# If the path settings are not what is expected, then add the computer name
# to the $ScriptFail array.
if ((!($PathQueryData.DefaultExternalDataRoot -eq "e:\virtualmachines")) `
-and (!($PathQueryData.DefaultVirtualHardDiskPath -eq "e:\virtualdisks")))
{$PathFail +=$Computer}

# Else, add the computername to the $ScriptSucceed array.
else
{$PathSucceed +=$Computer}

# If the target server does not have a NIC bound to a virtual switch,
# add the computer name to the $SwitchFail array.

if ($SwitchQueryData -eq $null)
{$SwitchFail +=$Computer}

# Else add the computer name to the $SwitchSucceed array.
else
{$SwitchSucceed +=$Computer}

# Increment the text file placeholder variable.
}

# If the target server is reachable through a ping, then go ahead with the script.
# Else, store the computer name that the script is working on in the
# $HostUnreachable array.
else
{$HostUnreachable +=$Computer}

# Increment the computer list array variable by 1.
$a = $a+1

# End the Foreach loop action
}
# Set up and send the script completed email.
$EmailFrom = "hypervsetup@hyperv.int"
$EmailTo = "hstagner@hyperv.int"
$Subject = "Script Complete"
$Body = "The following hosts were unreachable: $HostUnreachable
The file paths were successfully changed on: $PathSucceed.
The file paths were not successfully changed on: $PathFail.
The external virtual switches were successfully created on: $SwitchSucceed.
The external virtual switches were not successfully created on: $SwitchFail."
$SmtpServer = "smtp.hyperv.int"
$Smtp = new-object Net.Mail.SmtpClient($smtpServer)
$Smtp.Send($emailFrom, $emailTo, $subject, $body)