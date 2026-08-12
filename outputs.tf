output "ad_vm_name" {
  value = proxmox_virtual_environment_vm.ad.name
}

output "ad_vm_id" {
  value = proxmox_virtual_environment_vm.ad.vm_id
}

output "ad_ip_address" {
  value = cidrhost(var.bridge_cidr_range, var.ad_network_host)
}
