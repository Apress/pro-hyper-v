Get-VMMServer -Computername "HyperV-Dev2.hyperv.int"

$VM = Get-VM -Name "Test-VM"

New-VirtualDiskDrive -VM $VM -Fixed `
-Filename "e:\virtualdisks\Test_Disk.vhd" -IDE `
-Size 10240 -Bus 0 -LUN 1