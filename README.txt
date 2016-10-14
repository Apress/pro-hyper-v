In order to run any of the PowerShell scripts in Pro Hyper-V, you must allow PowerShell scripts to run by setting the execution policy.

For Example:

Set-ExecutionPolicy RemoteSigned

This will allow local (not from the Internet) PowerShell scripts to be executed.

Chapter 4:

Ch4_P2V.ps1

This script takes an input file (p2v.txt) that should be stored in the same directory as the script. This file lists the names of the computers that you want to perform a P2V conversion on using SCVMM 2008. The format should be like the following example:

Computer1
Computer2
Computer3

Also, be sure that you replace the variable values at the beginning with the appropriate values for your environment.


Chapter 5:

Ch5_HyperVServerPath_WMI.ps1

This script takes an input file (HyperV_List.txt) that should be stored in the same directory as the script. This file lists the names of the Hyper-V Servers that you want to change the paths on. The format should be like the following example:

HyperV-Server1
HyperV-Server2
HyperV-Server3

Be sure to change the paths to something appropriate for your environment. You should also change the values in the email related variables at the end of the script to values that are appropriate for your environment.

Ch5_HyperVServerPath_CreateSwitch_WMI.ps1

This script also takes an input file (HyperV_List.txt) that should be stored in the same directory as the script. This file lists the names of the Hyper-V Servers that you want to change the paths on. The format should be like the following example:

HyperV-Server1
HyperV-Server2
HyperV-Server3

Be sure to change the paths to something appropriate for your environment. You should also change the values in the email related variables at the end of the script to values that are appropriate for your environment. Also, you need to change the following information:

"Marvell Yukon 88E8056 PCI-E Gigabit Ethernet Controller" 

to something that is appropriate for the network adapter that you want to use in your script.

Ch5_HyperV_VM_AttachVHD_WMI.ps1
Ch5_HyperV_VM_AdjustMem_WMI.ps1
Ch5_HyperV_VM_AdjustCPU_WMI.ps1
Ch5_HyperV_VM_AddNIC_WMI.ps1
Ch5_HyperV_CreateVM_WMI.ps1

Be sure to replace the values for the variables in the beginning of the script with values that are appropriate for your environment.

Ch5_HyperVServerPath_SCVMM.ps1

This script takes an input file (HyperV_List.txt) that should be stored in the same directory as the script. This file lists the names of the Hyper-V Servers that you want to change the paths on. The format should be like the following example:

HyperV-Server1
HyperV-Server2
HyperV-Server3

Be sure to change the paths to something appropriate for your environment. You should also change the value for the SCVMM server to one that is appropriate for your environment.

Ch5_HyperVServerPath_CreateSwitch_SCVMM.ps1

You should change the value for the SCVMM server to one that is appropriate for your environment. Also, you need to change the following information:

"Marvell Yukon 88E8056 PCI-E Gigabit Ethernet Controller" 

to something that is appropriate for the network adapter that you want to use in your script.

Ch5_HyperV_VM_AttachVHD_SCVMM.ps1

You should change the value for the SCVMM server to one that is appropriate for your environment. You should also change the virtual machine and vhd paths to those that are appropriate for you environment.

Ch5_HyperV_VM_AdjustMem_SCVMM.ps1

You should change the value for the SCVMM server to one that is appropriate for your environment. You should also change the virtual machine and memory configuration to those that are appropriate for you environment.

Ch5_HyperV_VM_AdjustCPU_SCVMM.ps1

You should change the value for the SCVMM server to one that is appropriate for your environment. You should also change the virtual machine and cpu count configuration to those that are appropriate for you environment.

Ch5_HyperV_VM_AddNIC_SCVMM.ps1

You should change the value for the SCVMM server to one that is appropriate for your environment. You should also change the virtual machine, virtual network, and physical address configuration to those that are appropriate for your environment.

Ch5_HyperV_CreateVM_SCVMM.ps1

Be sure to replace the values for the variables in the beginning of the script with values that are appropriate for your environment. You should change the value for the SCVMM server to one that is appropriate for your environment. You should also change the virtual machine, virtual network, and physical address configuration to those that are appropriate for your environment.


Chapter 6:

logman_create_baseline.bat

Be sure to save this as a *.bat file and replace the following:

<YourHyperVServer>
<YourFileServer>\<YourShare>

with the appropriate values for your environment.

Chapter 8:

Ch8_MountVHD.ps1

You could replace the value for the $VHDPath variable to a hard-coded path to your VHD if you would like.

Chapter 9:

Ch9_Assign_Azman_Scope.ps1

You could replace the values for the $Computer, $VMName, and $Scope variables with hard-coded values if you would like.