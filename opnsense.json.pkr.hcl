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
    ["<wait6m>", "Waiting 3min for guest to start"],
    ["root<enter>opnsense<enter><wait3s>", "Login into the firewall"],
    ["1<enter><wait2s>", "Start manual interface assignment"],
    ["N<enter><wait2s>", "Do not configure LAGGs now"],
    ["N<enter><wait2s>", "Do not configure VLANs now"],
    ["vtnet0<enter><wait2s>", "Configure WAN interface"],
    ["<enter><wait2s>", "Skip LAN interface configuration"],
    ["<enter><wait2s>", "Skip Optional interface 1 configuration"],
    ["y<enter><wait2s>", "I want to proceed"],
    ["<wait1m>", "Wait for OPNSense to reload"],
    ["<wait2s>8<enter><wait2s>", "Enter in shell"],
    [
      "curl -o /conf/config.xml http://{{ .HTTPIP }}:{{ .HTTPPort }}/config.xml<enter><wait3s>",
      "Download config.xml"
    ],
    ["opnsense-installer<enter><wait2s>", "Run OPNsense Installer"],
    ["<enter><wait2s>", "Use default keymap"],
    ["<down><enter><wait2s><enter><wait3s>", "Use UFS"],
    ["<enter><wait2s><left><enter><wait10m>", "Select the disk and install OPNsense"],
    ["<down><enter><wait2s><enter><wait5m>", "Exit installer and wait 2min for guest to start"],
    ["root<enter>opnsense<enter><wait5s>", "Login into the firewall"],
    ["8<enter><wait2s>pfctl -d<enter><wait2s>", "Disabling firewall"],
    [
      "curl -o /usr/local/bin/opn-apikey http://{{ .HTTPIP }}:{{ .HTTPPort }}/opn-apikey<enter><wait3s>",
      "Download opn-apikey"
    ],
    [
      "chmod +x /usr/local/bin/opn-apikey<enter>",
      "Add executable permission to opn-apikey script"
    ]
  ]
  shutdown_command = "shutdown -p now<enter>"

  disk_size        = "8192M"
  disk_compression = true
  cpus             = 2
  memory           = 4096 # OPNSense require 2G of RAM to install
  http_directory   = "http"
  net_device       = "virtio-net"

  iso_checksum = "${var.ISO_CHECKSUM}"
  iso_urls = [
    "./iso/OPNsense-${var.VERSION}-dvd-amd64.iso",
  ]
  output_directory = "output"
  format           = "qcow2"

  ssh_timeout  = "2m"
  ssh_port     = 22
  ssh_username = "root"
  ssh_password = "opnsense"

  # Setting headless to false open the libvirt gui to actually see
  # the installer is doing
  headless = true

  qemuargs = [
    ["-chardev", "socket,path=${var.SOCKET_DIR}/qemu-isa-serial.sock,server=on,wait=off,id=qga0"],
    ["-device", "isa-serial,chardev=qga0"],
    ["-device", "virtio-serial"],
    ["-chardev", "socket,path=${var.SOCKET_DIR}/qemu-virtconsole.sock,server=on,wait=off,id=qvt0"],
    ["-device", "virtconsole,chardev=qvt0"],
    ["-chardev", "socket,path=${var.SOCKET_DIR}/qemu-virtserialport.sock,server=on,wait=off,id=qvsp0"],
    ["-device", "virtserialport,chardev=qvsp0,name=org.qemu.guest_agent.0"]
  ]

  # You may use this for debug purpose
  # vnc_bind_address = "0.0.0.0"
  # vnc_port_min = 5901
  # vnc_port_max = 5901

  vm_name = "opnsense.qcow2"
}


build {
  sources = ["source.qemu.opnsense"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "scripts/base.sh",
      "scripts/qemu-guest-agent.sh",
      "scripts/post-install.sh"
    ]
  }
}

variable "VERSION" {
  type    = string
  default = "25.7"
  validation {
    condition = can(regex("^\\d{2}\\.\\d$", var.VERSION))
    error_message = "The version should be XX.X. Ex: 25.7."
  }
}

variable "ISO_CHECKSUM" {
  type    = string
  default = "sha1:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  validation {
    condition = can(regex("^\\w+:\\w+", var.ISO_CHECKSUM))
    error_message = "The ISO checksum should be <type>:<value>. Ex: sha1:2722ee32814ee722bb565ac0dd83d9ebc1b31ed9."
  }
}

variable "SOCKET_DIR" {
  type    = string
  default = "/tmp" 
}
