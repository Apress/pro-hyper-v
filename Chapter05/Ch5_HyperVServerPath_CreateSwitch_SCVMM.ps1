Get-VMMServer -ComputerName "HyperV-Dev2.hyperv.int"

$VMHost = Get-VMHost -ComputerName "hyperv-dev.hyperv.int"

$HostAdapter = Get-VMHostNetworkAdapter `
-VMHost $VMHost `
-Name "Marvell Yukon 88E8056 PCI-E Gigabit Ethernet Controller"

New-VirtualNetwork -Name "Hyper-V External Switch" -VMHost $VMHost `
-VMHostNetworkAdapter $HostAdapter