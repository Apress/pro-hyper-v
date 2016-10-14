$GuestVM = "W2K3-Map"

$Namespace = "root\virtualization"

$Computer = "HyperV-Dev"

$VMService = Get-WmiObject -class "Msvm_VirtualSystemManagementService" `
-namespace $Namespace -ComputerName $Computer

$VM = Get-WmiObject -Namespace $Namespace -ComputerName $Computer `
-Query "Select * From Msvm_ComputerSystem `
Where ElementName='$GuestVM'"

$VMSettingData = Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VM} `
Where ResultClass=Msvm_VirtualSystemSettingData `
AssocClass=Msvm_SettingsDefineState"

$Vmem = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VMSettingData} `
Where ResultClass=Msvm_MemorySettingData `
AssocClass=Msvm_VirtualSystemSettingDataComponent" | `
where-object -FilterScript {$_.ResourceSubType `
-eq "Microsoft Virtual Machine Memory"})

$Vmem.VirtualQuantity = [string]2048

$Vmem.Reservation = [string]2048

$Vmem.Limit = [string]2048

$VMService.ModifyVirtualSystemResources($VM.__Path, $Vmem.PSBase.GetText(1))