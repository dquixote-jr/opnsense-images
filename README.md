# OPNsense Cloud Image

This repository aims to create a Packer recipe to build OPNsense for Cloud applications (OpenStack, AWS, Azure...).

## How to build

[Install packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli).

Configure the build env:

```shell
export PKR_VAR_VERSION="24.1" # OPNsense version
export PKR_VAR_MIRROR="https://mirror.init7.net/opnsense" # OPNSense mirror
export PKR_VAR_ISO_CHECKSUM="sha1:2722ee32814ee722bb565ac0dd83d9ebc1b31ed9" # ISO Checksum
```

Download OPNsense DVD iso:

```shell
./get-iso.sh

```

Initialize packer:

```shell
packer init .
```

Build the image:

```shell
packer build .
```

The result will be located at ``
