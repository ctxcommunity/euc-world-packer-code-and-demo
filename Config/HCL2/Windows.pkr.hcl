packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
  }
}

variable "OStoInstall" {
  type = string
}

variable "configpath" {
  type = string
}

variable "disk-controller-type" {
  type = string
}

variable "guest-os-type" {
  type = string
}

variable "os_iso_path" {
  type = string
}

variable "vm-cpu-cores" {
  type = string
}

variable "vm-cpu-num" {
  type = string
}

variable "vm-disk-size" {
  type = string
}

variable "vm-firmware" {
  type = string
}

variable "vm-mem-size" {
  type = string
}

variable "vm-name" {
  type = string
}

variable "vmtools_iso_path" {
  type = string
}

variable "vsphere-cluster" {
  type = string
}

variable "vsphere-datacenter" {
  type = string
}

variable "vsphere-datastore" {
  type = string
}

variable "vsphere-folder" {
  type = string
}

variable "vsphere-network" {
  type = string
}

#variable "vsphere-resource-pool" {
#  type = string
#}

variable "vsphere-server" {
  type = string
}

variable "vsphere-user" {
  sensitive = true
  default = env("PACKER_VSPHERE_USER")

  validation {
    condition     = length(var.vsphere-user) > 0
    error_message = <<EOF
The environment variable PACKER_VSPHERE_USER is undefined.
EOF
  }
}

variable "vsphere-password" {
  sensitive = true
  default = env("PACKER_VSPHERE_PASSWORD")

  validation {
    condition     = length(var.vsphere-password) > 0
    error_message = <<EOF
The environment variable PACKER_VSPHERE_PASSWORD is undefined.
EOF
  }
}

variable "winadmin-user" {
  sensitive = true
  default = env("PACKER_WINADMIN_USER")

  validation {
    condition     = length(var.winadmin-user) > 0
    error_message = <<EOF
The environment variable PACKER_WINADMIN_USER is undefined.
EOF
  }
}

variable "winadmin-password" {
  sensitive = true
  default = env("PACKER_WINADMIN_PASSWORD")

  validation {
    condition     = length(var.winadmin-password) > 0
    error_message = <<EOF
The environment variable PACKER_WINADMIN_PASSWORD is undefined.
EOF
  }
}

variable "packer-service-domain" {
  sensitive = true
  default = env("PACKER_SERVICE_DOMAIN")

  validation {
    condition     = length(var.packer-service-domain) > 0
    error_message = <<EOF
The environment variable PACKER_SERVICE_DOMAIN is undefined.
EOF
  }
}

variable "packer-service-account" {
  sensitive = true
  default = env("PACKER_SERVICE_ACCOUNT")

  validation {
    condition     = length(var.packer-service-account) > 0
    error_message = <<EOF
The environment variable PACKER_SERVICE_ACCOUNT is undefined.
EOF
  }
}

variable "packer-service-password" {
  sensitive = true
  default = env("PACKER_SERVICE_PASSWORD")

  validation {
    condition     = length(var.packer-service-password) > 0
    error_message = <<EOF
The environment variable PACKER_SERVICE_PASSWORD is undefined.
EOF
  }
}


source "vsphere-iso" "windows" {
  CPUs                    = "${var.vm-cpu-num}"
  RAM                     = "${var.vm-mem-size}"
  RAM_reserve_all         = false
  boot_command            = ["<spacebar><spacebar>"]
  boot_wait               = "3s"
  cluster                 = "${var.vsphere-cluster}"
  communicator            = "winrm"
  convert_to_template     = "false"
  cpu_cores               = "${var.vm-cpu-cores}"
  datacenter              = "${var.vsphere-datacenter}"
  datastore               = "${var.vsphere-datastore}"
  disk_controller_type    = ["${var.disk-controller-type}"]
  firmware                = "${var.vm-firmware}"
  floppy_files            = ["config/Autounattend/${var.OStoInstall}-${var.vm-firmware}/autounattend.xml", "scripts/Install-vmtools.ps1","scripts/WinRM-Config.ps1", "scripts/Initial-Config.ps1", "config/JSON/${var.configpath}/server-config-${var.vm-name}.json"]
  floppy_img_path         = "[] /vmimages/floppies/pvscsi-Windows8.flp"
  folder                  = "${var.vsphere-folder}"
  guest_os_type           = "${var.guest-os-type}"
  insecure_connection     = "true"
  iso_paths               = ["${var.os_iso_path}", "${var.vmtools_iso_path}"]
  network_adapters {
    network               = "${var.vsphere-network}"
    network_card          = "vmxnet3"
  }
  password                = "${var.vsphere-password}"
  remove_cdrom            = true
#  resource_pool           = "${var.vsphere-resource-pool}"
  storage {
    disk_size             = "${var.vm-disk-size}"
    disk_thin_provisioned = true
  }
  username                = "${var.vsphere-user}"
  vcenter_server          = "${var.vsphere-server}"
  vm_name                 = "${var.vm-name}"
  winrm_username          = "${var.winadmin-user}"
  winrm_password          = "${var.winadmin-password}"
  winrm_use_ntlm          = true
  winrm_use_ssl           = true
  winrm_insecure          = true
}

build {
  sources = ["source.vsphere-iso.windows"]

  provisioner "windows-restart" {
  }

  provisioner "file" {
    destination           = "c:/scripts/Server-Rename.ps1"
    source                = "scripts/Server-Rename.ps1"
  }

  provisioner "file" {
    destination           = "c:/scripts/Server-Config.ps1"
    source                = "scripts/Server-Config.ps1"
  }

  provisioner "powershell" {
    inline                = ["& c:/scripts/Server-Rename.ps1"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    inline                = ["& c:/scripts/Server-Config.ps1 ${var.packer-service-domain} ${var.packer-service-account} ${var.packer-service-password}"]
  }

  provisioner "windows-restart" {
  }
}
