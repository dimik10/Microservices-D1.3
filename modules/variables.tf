variable "instance_family_image" {
  description = "Instance image"
  type        = string
  default     = "ubuntu-2204-lts"
  #  default     = "lamp"
}

variable "vpc_subnet_id" {
  description = "VPC subnet network id"
  type        = string
}

variable "instance_root_disk" {
  default = "50"
}

variable "managers" {
  description = "Count of manager nodes"
  type        = number
  default     = 1
}

variable "workers" {
  description = "Count of worker nodes"
  type        = number
  default     = 1
}

variable "ssh_credentials" {
  description = "Credentials for connect to instances"
  type        = object({
    user        = string
    private_key = string
    pub_key     = string
  })
  default     = {
    user        = "ubuntu"
    private_key = "~/.ssh/yandex1"
    pub_key     = "~/.ssh/yandex1.pub"
  }
}