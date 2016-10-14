$VMName = "TestVM"

$Namespace = "root\virtualization"

$Computer = "HyperV-Dev"

$VHD = "e:\virtualdisks\test.vhd"

$VHDSize = "10GB"

$VSwitchName = "Hyper-V External Switch"

$VSwitchPortName = "TestPort"

$VNicAddress = "00155D9290FF"

$VMService = Get-WmiObject -class "Msvm_VirtualSystemManagementService" `
-namespace $Namespace -ComputerName $Computer

# Assign a name to the new Virtual Machine#####
$VMGlobalSettingClass =[WMIClass]"\\$Computer\root\virtualization:Msvm_VirtualSystemGlobalSettingData"

$NewVMGS = $VMGlobalSettingClass.psbase.CreateInstance() while ($NewVMGS.psbase.Properties -eq $null) {}

$NewVMGS.psbase.Properties.Item("ElementName").value = $VMName

# Create Virtual Disk########################
$VDiskService = Get-Wmiobject -Class "Msvm_ImageManagementService" `
-Namespace "root\virtualization"

$DiskCreate = $VDiskService.CreateFixedVirtualHardDisk($VHD, 10GB)

$DiskJob = [WMI]$DiskCreate.job while (($DiskJob.JobState -eq "2") -or ($DiskJob.JobState -eq "3") `
-or ($DiskJob.JobState -eq "4")) {Start-Sleep -m 100
$DiskJob = [WMI]$DiskCreate.job}

# Create NIC##############################
$DefaultNIC = Get-WmiObject -Namespace $Namespace `
-Class Msvm_SyntheticEthernetPortSettingData | `
Where-Object -FilterScript {$_.InstanceID -like "*Default*"}

$GUID1 = [GUID]::NewGUID().ToString()

$GUID2 = [GUID]::NewGUID().ToString()

$VSwitchQuery = Get-WmiObject `
-Class "Msvm_VirtualSwitchManagementService" -Namespace $Namespace

$VMService = Get-WmiObject -class "Msvm_VirtualSystemManagementService" `
-namespace $Namespace -ComputerName $Computer

$VSwitch = Get-WmiObject -Namespace $Namespace `
-Query "Select * From Msvm_VirtualSwitch Where ElementName='$VSwitchName'"

$ReturnObject = $VSwitchQuery.CreateSwitchPort`
($VSwitch, [guid]::NewGuid().ToString(), $VSwitchPortName, "")

$NewSwitchPort1 = $ReturnObject.CreatedSwitchPort

$ReturnObject = $VSwitchQuery.CreateSwitchPort`
($VSwitch, [guid]::NewGuid().ToString(), $VSwitchPortName, "")

$NewSwitchPort2 = $ReturnObject.CreatedSwitchPort

$StaticNIC = $DefaultNIC.psbase.Clone()

$StaticNIC.VirtualSystemIdentifiers = "{$GUID1}"

$StaticNIC.StaticMacAddress = $true

$StaticNIC.Address = $VNicAddress

$StaticNIC.Connection = $NewSwitchPort1

$DynamicNIC = $DefaultNIC.psbase.Clone()

$DynamicNIC.VirtualSystemIdentifiers = "{$GUID2}"

$DynamicNIC.Connection = $NewSwitchPort2

# Add the NIC resources to the Resource Allocation Settings Data Array#
$VMRASD = @()

$VMRASD += $StaticNic.psbase.gettext(1)

$VMRASD += $DynamicNic.psbase.gettext(1)

# Create the Virtual Machine
$VMService.DefineVirtualSystem($NewVMGS.psbase.GetText(1), $VMRASD)

# Add the Disk to the new Virtual Machine###########################################
$VM = Get-WmiObject -Namespace $Namespace -ComputerName $Computer `
-Query "Select * From Msvm_ComputerSystem Where ElementName='$VMName'"

$VMSettingData = Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VM} `
Where ResultClass=Msvm_VirtualSystemSettingData `
AssocClass=Msvm_SettingsDefineState"

$VMIDEController = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$VMSettingData} Where `
ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_VirtualSystemSettingDataComponent" | `
where-object -FilterScript {$_.ResourceSubType `
-eq "Microsoft Emulated IDE Controller" -and $_.Address -eq 0})

$DiskAllocationSetting = Get-WmiObject -Namespace $Namespace `
-Query "SELECT * FROM Msvm_AllocationCapabilities `
WHERE ResourceSubType = 'Microsoft Synthetic Disk Drive'" `
$DefaultDiskDrive = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$DiskAllocationSetting} `
Where ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_SettingsDefineCapabilities" | `
where-object -FilterScript {$_.InstanceID -like "*Default"})

$DefaultDiskDrive.Parent = $VMIDEController.__Path

$DefaultDiskDrive.Address = 0

$NewDiskDrive = ($VMService.AddVirtualSystemResources($VM.__Path, `
$DefaultDiskDrive.PSBase.GetText(1))).NewResources

$DiskAllocationSetting = Get-WmiObject -Namespace $Namespace `
-Query "SELECT * FROM Msvm_AllocationCapabilities `
WHERE ResourceSubType = 'Microsoft Virtual Hard Disk'" `
$DefaultHardDisk = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$DiskAllocationSetting} `
Where ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_SettingsDefineCapabilities" | `
where-object -FilterScript {$_.InstanceID -like "*Default"})

$DefaultHardDisk.Parent = $NewDiskDrive

$DefaultHardDisk.Connection = $VHD

$VMService.AddVirtualSystemResources($VM.__Path, $DefaultHardDisk.PSBase.GetText(1))

# Add DVD Drive######################################
$DVDAllocationSetting = Get-WmiObject -Namespace $Namespace `
-Query "SELECT * FROM Msvm_AllocationCapabilities `
WHERE ResourceSubType = 'Microsoft Synthetic DVD Drive'"

$DefaultDVDDrive = (Get-WmiObject -Namespace $Namespace `
-Query "Associators of {$DVDAllocationSetting} `
Where ResultClass=Msvm_ResourceAllocationSettingData `
AssocClass=Msvm_SettingsDefineCapabilities" | `
where-object -FilterScript {$_.InstanceID -like "*Default"})

$DefaultDVDDrive.Parent = $VMIDEController.__Path

$DefaultDVDDrive.Address = 1

$NewDVDDrive = $DefaultDVDDrive.psbase.Clone()

$VMService.AddVirtualSystemResources($VM.__PATH, $NewDVDDrive.psbase.Gettext(1))