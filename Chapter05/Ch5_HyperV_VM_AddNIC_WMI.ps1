$GuestVM = "W2K3-Map"

$Namespace = "root\virtualization"

$Computer = "HyperV-Dev"

$VSwitchName = "Hyper-V External Switch"

$VSwitchPortName = "VMPort"

$VNicGUID1 = [GUID]::NewGUID().ToString()

$VNicGUID2 = [GUID]::NewGUID().ToString()

$DefaultNIC = Get-WmiObject -Namespace $Namespace `
-Class Msvm_SyntheticEthernetPortSettingData | `
Where-Object -FilterScript {$_.InstanceID -like "*Default*"}

$VM = Get-WmiObject -Namespace $Namespace -ComputerName $Computer `
-Query "Select * From Msvm_ComputerSystem Where ElementName='$GuestVM'"

$VSwitchQuery = Get-WmiObject `
-Class "Msvm_VirtualSwitchManagementService" -Namespace $Namespace

$VMService = Get-WmiObject -class "Msvm_VirtualSystemManagementService" `
-namespace $Namespace -ComputerName $Computer

$VSwitch = Get-WmiObject -Namespace $Namespace `
-Query "Select * From Msvm_VirtualSwitch `
Where ElementName='$VSwitchName'"

$ReturnObject = $VSwitchQuery.CreateSwitchPort `
($VSwitch, [guid]::NewGuid().ToString(), $VSwitchPortName, "")

$NewSwitchPort1 = $ReturnObject.CreatedSwitchPort

$ReturnObject = $VSwitchQuery.CreateSwitchPort `
($VSwitch, [guid]::NewGuid().ToString(), $VSwitchPortName, "")

$NewSwitchPort2 = $ReturnObject.CreatedSwitchPort

$StaticNIC = $DefaultNIC.psbase.Clone()

$StaticNIC.VirtualSystemIdentifiers = "{$VNicGUID1}"

$StaticNIC.StaticMacAddress = $true

$StaticNIC.Address = "00155D9290FF"

$StaticNIC.Connection = $NewSwitchPort1

$DynamicNIC = $DefaultNIC.psbase.Clone()

$DynamicNIC.VirtualSystemIdentifiers = "{$VNicGUID2}"

$DynamicNIC.Connection = $NewSwitchPort2

$VMService.AddVirtualSystemResources($VM.__Path, $StaticNIC.PSBase.GetText(1))

$VMService.AddVirtualSystemResources($VM.__Path, $DynamicNIC.PSBase.GetText(1))