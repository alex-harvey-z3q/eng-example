// Requirement states:
// "Create an output.tf file that would provide an output made up of the list of VM hostnames as a map, keyed by the instance name"
//
// Interpreting this to mean:
// "Create an output.tf file that would provide an output in the form of a map, where the keys are the instance names and the values are the corresponding VM hostnames."
output "vm_hostnames" {
  value = { for instance, config in var.instances : instance => "${instance}-${config.zone}.asx.com.au" }
}

output "instance_ips_by_fqdn" {
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#network_interface.0.network_ip-1
  value = { for instance, config in var.instances : "${instance}-${config.zone}.asx.com.au" => google_compute_instance.vm[instance].network_interface[0].network_ip }
}
