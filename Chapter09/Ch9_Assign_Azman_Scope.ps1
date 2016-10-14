$Namespace = "root\virtualization"

$Computer = Read-Host "Enter the Hyper-V server that you want to connect to"

$VMName = Read-Host `
"Enter the Virtual machine that you would like to assign the scope to"

$Scope = Read-Host `
"Enter the scope name that you would like to assign to the virtual machine"

$VM_Service = Get-WmiObject -ComputerName $Computer `
-Namespace $Namespace -Class Msvm_VirtualSystemManagementService

$VM = Get-WmiObject -ComputerName $Computer `
-Namespace $Namespace -Class Msvm_ComputerSystem | `
Where-Object -FilterScript {$_.ElementName -eq $VMName}

Get-Wmiobject -ComputerName $Computer `
-Namespace $Namespace -Class Msvm_ComputerSystem | `
Where-Object -FilterScript {$_.ElementName -eq $VMName} | ForEach-Object {

if ( $VMName -ne $Null)

{

$VMGlobalSetting = Get-Wmiobject -ComputerName $Computer `
-Namespace $Namespace -Class Msvm_VirtualSystemGlobalSettingData | `
Where-Object -FilterScript { $_.ElementName -eq $VMName}

$VMGlobalSetting.ScopeOfResidence = $Scope

$VM_Service.ModifyVirtualSystem($VM.__PATH, $VMGlobalSetting.psbase.Gettext(1))

}

}