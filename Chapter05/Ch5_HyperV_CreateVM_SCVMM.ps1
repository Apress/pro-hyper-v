$VHD = Get-VirtualHardDisk | where {$_.Name -eq "Test_Disk.vhd"}

$VMPath = "e:\virtualmachines"

$VMHost = Get-VMHost | where {$_.Name -eq "hyperv-dev.hyperv.int"}

New-VM -Name "Test-VM" -VirtualHardDisk $VHD -VMHost $VMHost -Path $VMPath

$VNetwork = "Hyper-V External Switch"

$VM = Get-VM -Name "Test-VM"

New-VirtualNetworkAdapter -VirtualNetwork $VNetwork -VM $VM

New-VirtualNetworkAdapter -VM $VM -VirtualNetwork $VNetwork `
-PhysicalAddress "00-15-5D-92-90-FF" -PhysicalAddressType "Static"

New-VirtualDVDDrive -VM $VM -Bus 0 -LUN 1