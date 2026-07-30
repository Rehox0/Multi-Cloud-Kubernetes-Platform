variable "subnet_ids" { type = list(string) }
variable "instance_profile_name" { type = string }
variable "management_sg_id" { type = string }
variable "aws_region" { type = string }
variable "cluster_name" { type = string }
variable "kubectl_version" { type = string }
variable "kubectl_sha256" { type = string }
variable "helm_version" { type = string }
variable "helm_sha256" { type = string }
variable "ssh_public_keys" {
  type = list(string)
}
