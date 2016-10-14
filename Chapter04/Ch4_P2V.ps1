# Begin Code
# ------------------------------------------------------------------------------
# Convert Physical Server (P2V) Wizard Script
# ------------------------------------------------------------------------------
# Script generated on Monday, November 24, 2008 3:02:24 AM
# by Virtual Machine Manager
# For additional help on cmdlet usage, type get-help <cmdlet name>
# ------------------------------------------------------------------------------
$Server = "hyperv-dev.hyperv.int"

$VMPath = "e:\virtualmachines"

$VMOwner = "hyperv\administrator"

$CPUCount = "1"

$VMMemory = "512"

#Initiate the variable used to go through the object array created with get-content
$a = 0

$b = 0

#Get the credentials needed for the P2V conversion
#Moved this out of the loop so that it only needs to be captured once
$Credential = get-credential

#Read the p2v.txt file to get the list of computers
get-content p2v.txt | Foreach-object {

#Get the $a line in the p2v.txt file
$strSourceComputer = (get-content p2v.txt)[$a]

$strSourceNIC = (get-content p2v-network.txt)[$b]

#Default P2V script that was produced by SCVMM 2008
New-MachineConfig -VMMServer localhost -SourceComputerName $strSourceComputer -Credential $Credential

$VMHost = Get-VMHost -VMMServer localhost | where {$_.Name -eq $Server}

$VirtualNetwork = Get-VirtualNetwork -VMMServer localhost | where {$_.ID -eq "d8149071-09d5-4df1-9fe0-a09844da87c9"}

$MachineConfig = Get-MachineConfig -VMMServer localhost | where {$_.Name -eq $strSourceComputer}

New-P2V -VMMServer localhost -VMHost $VMHost -RunAsynchronously `
-JobGroup a925f8e4-dae6-4db3-bf34-34a7cd7d4b2c -SourceNetworkConnectionID $strSourceNIC `
-PhysicalAddress $strSourceNIC -PhysicalAddressType Static -VirtualNetwork $VirtualNetwork `
-MachineConfig $MachineConfig

$VMHost = Get-VMHost -VMMServer localhost | where {$_.Name -eq "$Server"}

$MachineConfig = Get-MachineConfig -VMMServer localhost | where {$_.Name -eq $strSourceComputer}

New-P2V -VMMServer localhost -VMHost $VMHost -RunAsynchronously `
-JobGroup a925f8e4-dae6-4db3-bf34-34a7cd7d4b2c -VolumeDeviceID "C" `
-Fixed -IDE -Bus 0 -LUN 0 -MachineConfig $MachineConfig

$VMHost = Get-VMHost -VMMServer localhost | where {$_.Name -eq "$Server"}

$MachineConfig = Get-MachineConfig -VMMServer localhost | where {$_.Name -eq $strSourceComputer}

New-P2V -Credential $Credential -VMMServer localhost -VMHost $VMHost -Path $VMPath `
-Owner $VMOwner -RunAsynchronously -JobGroup a925f8e4-dae6-4db3-bf34-34a7cd7d4b2c `
-Trigger -Name $strSourceComputer -MachineConfig $MachineConfig `
-CPUCount $CPUCount -MemoryMB $VMMemory -RunAsSystem `
-StartAction NeverAutoTurnOnVM -StopAction ShutdownGuestOS

$a = $a+1

$b = $b+1

}

# End Code