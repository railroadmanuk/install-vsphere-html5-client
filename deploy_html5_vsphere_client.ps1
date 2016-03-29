Import-Module VMware.VimAutomation.Core;
# Declare our variables
$vc_ip = "192.168.1.200";
$vc_user = "administrator@vsphere.local";
$vc_password = "VMware1!";
$h5_client_ip = "192.168.1.201";
$ovf_location = ".\h5ngcVA-1.0.0.0-3680819_OVF10.ova";
$vm_name = "VC-H5-Client";
$network_name = "VM Network";
# Connect to vCenter
Connect-VIServer -Server $vc_ip -User $vc_user -Password $vc_password;
$vmhost = (Get-VMHost)[1];
$datastore = ($vmhost | Get-Datastore | Sort-Object -Descending FreeSpaceGB)[0];
# Import OVF Configuration
$ovfconfig = Get-OvfConfiguration $ovf_location;
# Set our variables for deployment in the OVF configuration file
$ovfconfig.NetworkMapping.Network_1.Value = $network_name;
$ovfconfig.IpAssignment.IpAllocationPolicy.Value = "fixedPolicy";
$ovfconfig.IpAssignment.IpProtocol.Value = "IPv4";
$ovfconfig.vami.vSphere_Web_Client_Appliance.ip0.Value = $h5_client_ip;
# Deploy the vApp
Import-VApp -Source $ovf_location -OvfConfiguration $ovfconfig -Name $vm_name -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin -Force;
Get-VM $vm_name | Start-VM;
# Disconnect from vCenter
Disconnect-VIServer * -Confirm:$false;