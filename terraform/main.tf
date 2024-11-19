resource "google_compute_instance" "vm" {
  for_each = var.instances

  project      = var.project_id
  name         = each.key
  machine_type = each.value.machine_type
  zone         = each.value.zone
  description  = each.value.description

  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#hostname-1
  hostname = "${each.key}-${each.value.zone}.asx.com.au"

  // dynamic nested blocks utilise for_each expressions
  // to code generate nested blocks of configuration. In this
  // case, a service_account nested block is generated for_each
  // element of the list defined by the for_each expression.
  //
  // In this case however, the for_each is generating either a
  // list with a dummy value "1" or an empty list.
  //
  // This pattern is a work-around really to the fact that
  // Terraform lacks a simply conditional that could be used
  // instead to include the service_account configuration.
  //
  // Assuming var.service_account is not empty, the content
  // of the generated nested block is given in the content
  // block.
  dynamic "service_account" {
    for_each = var.service_account != "" ? [1] : []
    content {
      email  = var.service_account
      scopes = var.scopes
    }
  }

  // Adding a minimal, untested boot_disk
  // and network_interface to satisfy terraform validate
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
