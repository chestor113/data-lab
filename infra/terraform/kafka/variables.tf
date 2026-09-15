variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the vpnctl subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "platform_id" {
  description = "Compute platform"
  type        = string
}

variable "vm_cores" {
  description = "Default number of VM vCPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Default VM memory in GB"
  type        = number
  default     = 2
}

variable "vm_core_fraction" {
  description = "Default guaranteed vCPU share in percent"
  type        = number
  default     = 20
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/iac_lab.pub"
}

variable "admin_user" {
  description = "Linux administrative user"
  type        = string
  default     = "evg"
}


variable "edge_subnet_cidr" {
  description = "CIDR for edge subnet"
  type        = list(string)
}

variable "backend_subnet_cidr" {
  description = "CIDR for backend subnet"
  type        = list(string)
}

################################ VMS

variable "vms" {
  description = "Virt Machines Config"

  type = map(object({
    private_ip = string
    hostname   = string
    public_ip  = optional(string)
    backend_ip = optional(string)
    nat        = optional(bool, false)
    subnet     = string
  }))
}


variable "debian_image_id" {
  type    = string
  default = "fd8ib96769br62k2kg2l"
}


