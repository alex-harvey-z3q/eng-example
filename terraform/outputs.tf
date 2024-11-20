// Requirement states:
// "Create an output.tf file that would provide an output made up of the list of VM hostnames as a map, keyed by the instance name"
//
// Interpreting this to mean:
// "Create an output.tf file that would provide an output in the form of a map, where the keys are the instance names and the values are the corresponding VM hostnames."

// Note about use of predicted VM names
//
// I am unhappy about having to predict VM hostnames based on a pattern and repeat that code in 3 places.
// Ideally, I would like to export that VM hostname from the compute resource as we do with the IP. Based
// on docs however, I can't see how that is possible. I also don't have access to Google Cloud to test.
// https://registry.terraform.io/providers/hashicorp/google/3.45.0/docs/resources/compute_instance
output "vm_hostnames" {
  value = { for instance, config in var.instances : instance => "${instance}-${config.zone}.asx.com.au" }
}

output "instance_ips_by_fqdn" {
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#network_interface.0.network_ip-1
  value = { for instance, config in var.instances : "${instance}-${config.zone}.asx.com.au" => google_compute_instance.vm[instance].network_interface[0].network_ip }
}
