#Get the vhd path from the user
$VHDPath = Read-Host "Enter the path to the VHD you want to mount"

$Namespace = "root\virtualization"

#Get the MSVM_ImageManagementService via WMI.
$VHDService = Get-WMIobject -Class "Msvm_ImageManagementService" `
-Namespace $Namespace -Computername "."

#Mount the VHD
$VHDService.Mount($VHDName)