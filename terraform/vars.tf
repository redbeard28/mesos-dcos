variable "image" {
#  default = "CentOS-7-x86_64-1702"
  default = "ubuntu-16.04-x64"
}

variable "flavor" {
  default = "m1.tiny"
}

variable "masterflavor" {
  default = "m1.tiny"
}

variable "slaveflavor" {
  default = "m1.tiny"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa_stack"
}

variable "ssh_user_name" {
#  default = "centos"
  default = "ubuntu"
}

variable "external_gateway" {}

variable "pool" {}

variable "nodes" {
  default ="3"
}

variable "os_name" {
  default ="ubuntu"
}

// The path to the user-data script you created
variable "user_data_path" {
  default = "scripts/user-data.sh"
}