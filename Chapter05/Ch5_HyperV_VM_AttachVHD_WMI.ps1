$VHD = "e:\virtualdisks\test.vhd"

$GuestVM = "W2K3-Map"

$Namespace = "root\virtualization"

$Computer = "HyperV-Dev"

$VMService = Get-WmiObject -class "Msvm_VirtualSystemManagementService" `
-namespace $Namespace -ComputerName $Computer

$VM = Get-WmiObject -Namespace $Namespace -ComputerName $Computer `
-Query "Select * From Msvm_ComputerSystem Where ElementName='$GuestVM'"

$VMSettingData = Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VM} Where ResultClass=Msvm_VirtualSystemSettingData `
AssocClass=Msvm_SettingsDefineState"

$VMIDEController = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VMSettingData} `
Where ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_VirtualSystemSettingDataComponent" | `
where-object -FilterScript {$_.ResourceSubType `
-eq "Microsoft Emulated IDE Controller" -and $_.Address -eq 0})

$DiskAllocationSetting = Get-WmiObject -Namespace $Namespace `
-Query "SELECT * FROM Msvm_AllocationCapabilities `
WHERE ResourceSubType = 'Microsoft Synthetic Disk Drive'"
$DefaultDiskDrive = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$DiskAllocationSetting} `
Where ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_SettingsDefineCapabilities" | `
where-object -FilterScript {$_.InstanceID -like "*Default"})

$DefaultDiskDrive.Parent = $VMIDEController.__Path

$DefaultDiskDrive.Address = 1

$NewDiskDrive = ($VMService.AddVirtualSystemResources($VM.__Path, `
$DefaultDiskDrive.PSBase.GetText(1))).NewResources

$DiskAllocationSetting = Get-WmiObject -Namespace $Namespace `
-Query "SELECT * FROM Msvm_AllocationCapabilities `
WHERE ResourceSubType = 'Microsoft Virtual Hard Disk'"

$DefaultHardDisk = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$DiskAllocationSetting} `
Where ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_SettingsDefineCapabilities" | `
where-object -FilterScript {$_.InstanceID -like "*Default"})

$DefaultHardDisk.Parent = $NewDiskDrive

$DefaultHardDisk.Connection = $VHD

$VMService.AddVirtualSystemResources($VM.__Path, $DefaultHardDisk.PSBase.GetText(1))