Get-VMMServer -ComputerName "HyperV-Dev2.hyperv.int"

$VM = Get-VM -Name "Test-VM"

Set-VM -VM $VM -CPUCount 2