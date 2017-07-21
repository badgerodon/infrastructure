provider "google" {
  project = "badgerodon-prod"
  region  = "us-central1"
}

# CONSUL SERVER

resource "google_compute_instance_template" "consul" {
  name_prefix  = "consul-"
  machine_type = "f1-micro"
  region       = "us-central1"
  tags         = ["consul", "nomad"]

  metadata_startup_script = <<EOT
#!/bin/bash
set -x
set -euo pipefail
IFS=$'\n\t'
${file("../machines/scripts/install-base.bash")}
${file("../machines/scripts/install-consul-server.bash")}
${file("../machines/scripts/install-nomad-server.bash")}
  EOT

  lifecycle {
    create_before_destroy = true
  }

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1704"
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral
    }
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

resource "google_compute_instance_group_manager" "consul_group_manager" {
  name               = "consul-group"
  instance_template  = "${google_compute_instance_template.consul.self_link}"
  base_instance_name = "consul"
  zone               = "us-central1-a"
  target_size        = 3
}


# WORKER


resource "google_compute_instance_template" "worker" {
  name_prefix  = "consul-"
  machine_type = "f1-micro"
  region       = "us-central1"
  tags         = ["worker"]

  metadata_startup_script = <<EOT
#!/bin/bash
set -x
set -euo pipefail
IFS=$'\n\t'
${file("../machines/scripts/install-base.bash")}
${file("../machines/scripts/install-consul-client.bash")}
${file("../machines/scripts/install-nomad-client.bash")}
  EOT

  lifecycle {
    create_before_destroy = true
  }

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1704"
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]
  }
}

resource "google_compute_instance_group_manager" "worker_group_manager" {
  name               = "worker-group"
  instance_template  = "${google_compute_instance_template.worker.self_link}"
  base_instance_name = "worker"
  zone               = "us-central1-a"
  target_size        = 1
}


# NETWORK


resource "google_compute_firewall" "default" {
  name    = "tf-www-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["www-node"]
}



# NOMAD

// provider "nomad" {
//   address = "${google_compute_instance_template.consul.0.network_interface.0.access_config.0.nat_ip}:4646"
//   region  = "us-central1"
// }

// resource "nomad_job" "badgerodon-envoy-ds" {
//   jobspec = <<EOT
// job "badgerodon-envoy-ds" {
//   datacenters = ["dc1"]
//   type = "service"
//   group "badgerodon-envoy-ds" {
//     task "envoy" {
//       driver = "raw_exec"
//       config {
//         command = "/bin/sleep"
//         args = ["1"]
//       }

//       resources {
//         cpu = 20
//         memory = 10
//       }

//       logs {
//         max_files = 3
//         max_file_size = 10
//       }
//     }
//   }
// }
// EOT
// }
