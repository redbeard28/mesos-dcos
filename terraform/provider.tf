#######################################################
#
#	Provider configuration
#
#		by J.CUADRADO 11/04/2017
#
#######################################################

provider "openstack" {}


#######################################################
#
#	Main configuration
#
#		by J.CUADRADO 31/03/2017
#
########################################################
# v1  - Création

resource "openstack_compute_keypair_v2" "terraform" {
  name       = "terraform"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_network_v2" "terraform" {
  name           = "terraform"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "terraform" {
  name            = "terraform"
  network_id      = "${openstack_networking_network_v2.terraform.id}"
  cidr            = "192.168.200.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "terraform" {
  name             = "terraform"
  admin_state_up   = "true"
  external_gateway = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "terraform" {
  router_id = "${openstack_networking_router_v2.terraform.id}"
  subnet_id = "${openstack_networking_subnet_v2.terraform.id}"
}

resource "openstack_compute_secgroup_v2" "terraform" {
  name        = "terraform"
  description = "Security group for the Terraform example instances"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_floatingip_v2" "mesosmaster_ip" {
  pool       = "${var.pool}"
  depends_on = ["openstack_networking_router_interface_v2.terraform"]
}


resource "openstack_compute_instance_v2" "terraform" {
  name            = "terraform"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.terraform.name}"
  security_groups = ["${openstack_compute_secgroup_v2.terraform.name}"]
  floating_ip     = "${openstack_compute_floatingip_v2.mesosmaster_ip.address}"
  user_data        = "${file("${var.user_data_path}")}"
  network {
    uuid = "${openstack_networking_network_v2.terraform.id}"
    fixed_ip_v4 = "192.168.200.5"
  }

  provisioner "file" {
    connection {
      user     = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }
    source      = "~/.ssh/id_rsa"
    destination = "~/.ssh/id_rsa"
  }
  
  provisioner "remote-exec" {
    connection {
      user     = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }
    inline = [
      "for i in $(echo 'bastion node-0 node-1 node-2');do ssh-keyscan $i;done",
    ]
  }
}


######## MESOS SERVERS ########
resource "openstack_compute_instance_v2" "node" {
  count = "${var.nodes}"
  name            = "node-${count.index}"
  image_name      = "${var.image}"
  flavor_name     = "${var.slaveflavor}"
  key_pair        = "${openstack_compute_keypair_v2.terraform.name}"
  user_data       = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_key_file}")}\"\n"
  security_groups = ["${openstack_compute_secgroup_v2.terraform.name}"]
  network {
    uuid = "${openstack_networking_network_v2.terraform.id}"
    fixed_ip_v4 = "192.168.200.2${count.index}"
  }
}