Get-VMMServer -ComputerName "hyperv-dev2.hyperv.int"

$VM = Get-VM -Name "Test-VM"

$VNetwork = "Hyper-V External Switch"

New-VirtualNetworkAdapter -VirtualNetwork $VNetwork -VM $VM

New-VirtualNetworkAdapter -VM $VM `
-VirtualNetwork $VNetwork -PhysicalAddress "00-15-5D-92-90-FF" `
-PhysicalAddressType "Static"