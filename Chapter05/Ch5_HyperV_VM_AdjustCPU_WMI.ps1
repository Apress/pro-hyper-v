$GuestVM = "W2K3-Map"

$Namespace = "root\virtualization"

$Computer = "HyperV-Dev"

$VMService = Get-WmiObject -class "Msvm_VirtualSystemManagementService" `
-namespace $Namespace -ComputerName $Computer

$VM = Get-WmiObject -Namespace $Namespace -ComputerName $Computer `
-Query "Select * From Msvm_ComputerSystem Where ElementName='$GuestVM'"

$VMSettingData = Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VM} `
Where ResultClass=Msvm_VirtualSystemSettingData `
AssocClass=Msvm_SettingsDefineState" `
$Vproc = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VMSettingData} `
Where ResultClass=Msvm_ProcessorSettingData `
AssocClass=Msvm_VirtualSystemSettingDataComponent" | `
where-object -FilterScript {$_.ResourceSubType -eq "Microsoft Processor"})

$Vproc.VirtualQuantity = [string]1

$Vproc.Reservation = [string]0

$Vproc.Limit = [string]100000

$Vproc.Weight = [string]100

$VMService.ModifyVirtualSystemResources($VM.__Path, $Vproc.PSBase.GetText(1))