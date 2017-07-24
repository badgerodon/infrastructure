resource "scaleway_server" "master" {
	count = "${var.master_count}"
	name  = "master-${count.index}"
	image = "${data.scaleway_image.ubuntu.id}"
	type  = "ARM64-2GB"

	dynamic_ip_required = true
}

resource "null_resource" "master_consul" {
	count = "${var.master_count}"

	triggers {
		public_ip = "${element(scaleway_server.master.*.public_ip, count.index)}"
	}
	connection {
		host = "${element(scaleway_server.master.*.public_ip, count.index)}"
	}

	provisioner "file" {
		source      = "../machines/scripts/install-base.bash"
		destination = "/tmp/install-base.bash"
	}
	provisioner "file" {
		source      = "../machines/scripts/install-consul-server.bash"
		destination = "/tmp/install-consul-server.bash"
	}
	provisioner "file" {
		source      = "../machines/scripts/install-nomad-server.bash"
		destination = "/tmp/install-nomad-server.bash"
	}
	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/*.bash",
			"/tmp/install-base.bash",
			"env ARCH=arm64 CONSUL_VERSION=0.9.0 CONSUL_IPS=${join(",", scaleway_server.master.*.private_ip)} /tmp/install-consul-server.bash",
			"env ARCH=arm64 NOMAD_VERSION=0.5.6 /tmp/install-nomad-server.bash",
		]
	}
}
