$a = 0

get-content HyperV_List.txt | `
Foreach-object {$computer = (get-content HyperV_List.txt)[$a]

Get-VMMServer -ComputerName "hyperv-dev2.hyperv.int"

$VMHost = Get-VMHost -ComputerName $computer

Set-VMHost -VMHost $VMHost -VMPaths "e:\virtualmachines"

$a = $a+1

}