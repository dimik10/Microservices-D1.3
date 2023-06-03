#output "internal_ip_address_vm" {
#  value = yandex_compute_instance.vm.network_interface.0.ip_address
#}

#output "external_ip_address_vm" {
#  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
#}

output "external_ip_address_manager" {
  value = yandex_compute_instance.vm1[*].network_interface.0.nat_ip_address
}

output "external_ip_address_workers" {
  value = yandex_compute_instance.vm2[*].network_interface.0.nat_ip_address
}