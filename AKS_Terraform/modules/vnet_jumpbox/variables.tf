variable "project_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "jumpbox_subnet_cidr" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}