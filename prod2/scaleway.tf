terraform {
	backend "local" {
		path = "/Users/caleb/sync/badgerodon/terraform-prod.tfstate"
	}
}

variable "consul_server_count" {
	default = 3
}

provider "scaleway" {
	organization = "${var.scaleway_organization}"
	token        = "${var.scaleway_token}"
	region       = "ams1"
}

data "scaleway_image" "ubuntu" {
	architecture = "arm64"
	name         = "Ubuntu Zesty"
}

resource "scaleway_server" "consul" {
	count = "${var.consul_server_count}"
	name  = "consul-${count.index}"
	image = "${data.scaleway_image.ubuntu.id}"
	type  = "ARM64-2GB"

	dynamic_ip_required = true
}

resource "null_resource" "consul_consul" {
	count = "${var.consul_server_count}"

	triggers {
		public_ip = "${element(scaleway_server.consul.*.public_ip, count.index)}"
	}
	connection {
		host = "${element(scaleway_server.consul.*.public_ip, count.index)}"
	}

	provisioner "file" {
		source      = "../machines/scripts/install-base.bash"
		destination = "/tmp/install-base.bash"
	}
	provisioner "file" {
		source      = "../machines/scripts/install-consul-server.bash"
		destination = "/tmp/install-consul-server.bash"
	}
	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/*.bash",
			"/tmp/install-base.bash",
			"env ARCH=arm64 CONSUL_VERSION=0.9.0 CONSUL_IPS=${join(",", scaleway_server.consul.*.private_ip)} /tmp/install-consul-server.bash",
		]
	}
}

resource "null_resource" "consul_nomad" {
	depends_on = ["null_resource.consul_consul"]
	count = "${var.consul_server_count}"

	triggers {
		public_ip = "${element(scaleway_server.consul.*.public_ip, count.index)}"
	}
	connection {
		host = "${element(scaleway_server.consul.*.public_ip, count.index)}"
	}
	provisioner "file" {
		source      = "../machines/scripts/install-nomad-server.bash"
		destination = "/tmp/install-nomad-server.bash"
	}
	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/*.bash",
			"env ARCH=arm64 NOMAD_VERSION=0.5.6 /tmp/install-nomad-server.bash",
		]
	}
}
