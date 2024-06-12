packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

source "qemu" "opnsense" {
  boot_wait = "3s"
  boot_steps = [
    ["1", "Boot in multi user mod"],
    ["<wait1m>", "Wait for boot and skip configuration importer"],
    ["root<enter>opnsense<enter><wait3s>", "Login into the firewall"],
    ["1<enter><wait>", "Start manual interface assignment"],
    ["N<enter><wait>", "Do not configure LAGGs now"],
    ["N<enter><wait>", "Do not configure VLANs now"],
    ["vtnet0<enter><wait>", "Configure WAN interface"],
    ["<enter><wait>", "Skip LAN interface configuration"],
    ["<enter><wait>", "Skip Optional interface 1 configuration"],
    ["y<enter><wait>", "I want to proceed"],
    ["<wait10s>", "Wait for OPNSense to start"],
    ["<wait>8<enter>", "Enter in shell"],
    [
      "curl -o /conf/config.xml  http://{{ .HTTPIP }}:{{ .HTTPPort }}/config.xml<enter><wait3s>",
      "Download config.xml"
    ],
    ["opnsense-installer<enter><wait>", "Run OPNsense Installer"],
    ["<enter><wait>", "Use default keymap"],
    ["<enter><wait3s>", "Use UFS"],
    ["<enter><wait><left><enter><wait2m>", "Select the disk and install OPNsense"],
    ["<down><enter><wait1m>", "Exit installer and wait 1min for reboot"],
    ["root<enter>opnsense<enter><wait3s>", "Login into the firewall"],
    ["8<enter><wait>pfctl -d<enter><wait>", "Disabling firewall"],
    [
      "curl -o /usr/local/etc/rc.d/firstboot  http://{{ .HTTPIP }}:{{ .HTTPPort }}/first-boot.sh<enter><wait3s>",
      "Download first-boot.sh"
    ],
    [
      "chmod +x /usr/local/etc/rc.d/firstboot<enter>",
      "Add executable permission to firstboot script"
    ]
  ]
  shutdown_command = "shutdown<enter>"

  disk_size        = "8192M"
  disk_compression = true
  memory = 2048 # OPNSense require 2G of RAM to install
  http_directory   = "http"
  net_device       = "virtio-net"

  iso_checksum = "${var.iso_checksum}"
  iso_urls = [
    "./iso/OPNsense-${var.version}-dvd-amd64.iso",
  ]
  output_directory = "output"
  format           = "qcow2"

  ssh_timeout  = "2m"
  ssh_port     = 22
  ssh_username = "root"
  ssh_password = "opnsense"

  headless = true # Set false to enable visual debug

  vm_name = "opnsense.qcow2"
}


build {
  sources = ["source.qemu.opnsense"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "scripts/base.sh",
      "scripts/qemu-guest-agent.sh",
      "scripts/cloud-init.sh",
      "scripts/post-install.sh"
    ]
  }
}

variable "version" {
  type    = string
  default = "24.1"
  validation {
    condition = can(regex("^\\d{2}\\.\\d$", var.version))
    error_message = "The version should be XX.X. Ex: 24.1."
  }
}

variable "iso_checksum" {
  type    = string
  default = "sha1:2722ee32814ee722bb565ac0dd83d9ebc1b31ed9"
  validation {
    condition = can(regex("^\\w+:\\w+", var.iso_checksum))
    error_message = "The ISO checksum should be <type>:<value>. Ex: sha1:2722ee32814ee722bb565ac0dd83d9ebc1b31ed9."
  }
}
