variable "scaleway_organization" {
	type = "string"
}

variable "scaleway_token" {
	type = "string"
}

variable "scaleway_region" {
	type = "string"
	default = "ams1"
}

variable "state_dir" {
	type = "string"
}

variable "master_count" {
	default = 3
}

variable "worker_count" {
	default = 2
}

output "master_ips" {
	value = "${scaleway_server.master.*.public_ip}"
}

output "worker_ips" {
	value = "${scaleway_server.worker.*.public_ip}"
}

