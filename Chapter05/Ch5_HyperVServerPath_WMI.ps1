# Variable to keep track of your place in the HyperV_List.txt file.

$a = 0
# Set up the Foreach-object loop to act on each computer in the text file.

get-content HyperV_List.txt | Foreach-object {$computer = (get-content HyperV_List.txt)[$a]

# Define the namespace used for WMI queries
$namespace = "root\virtualization"
# Define the WMI query object to change Hyper-V server settings.

$query = Get-WmiObject -class Msvm_VirtualSystemManagementService `
-computername $computer -namespace $namespace

# Define the WMI query to get the Hyper-V server settings data.
$querydata = Get-WmiObject -class Msvm_VirtualSystemManagementServiceSettingData `
-computername $computer -namespace $namespace

# Set the value for the DefaultExternalDataRoot property.
$querydata.DefaultExternalDataRoot = "e:\virtualmachines"

# Set the value for the DefaultExternalHardDiskPath property.
$querydata.DefaultVirtualHardDiskPath = "e:\virtualdisks"

# Actually modify the default path settings.
$query.ModifyServiceSettings($querydata.PSbase.GetText(1))

# Increment the text file placeholder variable.
$a = $a+1

# End the Foreach loop action
}

# Variable to keep track of your place in the HyperV_List.txt file.
$a = 0

# Set up a function to explicitly define an array.
function New-Array {,$args}

# Set up a new $scriptfail array with a space character.
$scriptfail = New-Array ""

# Set up a new $scriptsucceed array with a space character.
$scriptsucceed = New-Array ""

# Set up the Foreach-object loop to act on each computer in the text file.
get-content HyperV_List.txt | Foreach-object {$computer = (get-content HyperV_List.txt)[$a]

# Define the WMI query to get the Hyper-V server settings data.
$querydata = Get-WmiObject -class Msvm_VirtualSystemManagementServiceSettingData `
-computername $computer -namespace $namespace

# If the path settings are not what is expected then add the computer name
# to the $scriptfail array.
if ((!($querydata.DefaultExternalDataRoot -eq "e:\virtualmachines")) `
-and (!($querydata.DefaultVirtualHardDiskPath -eq "e:\virtualdisks")))
{$scriptfail +=$computer}

# Else, add the computer name to the $scriptsucceed array.
else {$scriptsucceed +=$computer}

# Increment the text file placeholder variable.
$a = $a+1

# End the Foreach loop action
}

# Set up and send the script completed email.
$emailFrom = "defaultpathscript@hyperv.int"

$emailTo = "hstagner@hyperv.int"

$subject = "Script Complete"

$body = "The script completed successfully on: $scriptsucceed. The script did not complete on: $scriptfail."

$smtpServer = "smtp.hyperv.int"

$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$smtp.Send($emailFrom, $emailTo, $subject, $body)