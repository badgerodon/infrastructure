terraform {
	backend "local" {
		path = "/Users/caleb/sync/badgerodon/terraform-prod.tfstate"
	}
}

provider "scaleway" {
	organization = "${var.scaleway_organization}"
	token        = "${var.scaleway_token}"
	region       = "${var.scaleway_region}"
}

data "scaleway_image" "ubuntu" {
	architecture = "arm64"
	name         = "Ubuntu Zesty"
}
