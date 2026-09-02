variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Multi-Cloud-Project"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "polandcentral"
}

variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
  default     = {}
}

variable "cluster_version" {
  type        = string
  description = "EKS control plane version"
  default     = "1.35"
}

variable "admin_source_ip" {
  description = "Public IP allowed to SSH into the Azure jumpbox"
  type        = string
}

variable "kubectl_version" {
  type        = string
  description = "Pinned kubectl version installed on the management host"
  default     = "v1.35.1"
}

variable "kubectl_sha256" {
  type        = string
  description = "SHA256 checksum for the pinned kubectl binary"
  default     = "36e2f4ac66259232341dd7866952d64a958846470f6a9a6a813b9117bd965207"
}

variable "kubelogin_version" {
  type        = string
  description = "Pinned kubelogin version installed on the management host"

  default = "v0.2.19"
}

variable "kubelogin_sha256" {
  type        = string
  description = "SHA256 checksum for the pinned kubelogin Linux amd64 archive"

  default = "ebaeff02aa899c5cae6a2b954b64fc02738185319df2570f7dc053451efa4b2f"
}

variable "helm_version" {
  type        = string
  description = "Pinned Helm version installed on the management host"
  default     = "v3.19.4"
}

variable "helm_sha256" {
  type        = string
  description = "SHA256 checksum for the pinned Helm archive"
  default     = "759c656fbd9c11e6a47784ecbeac6ad1eb16a9e76d202e51163ab78504848862"
}

