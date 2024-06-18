# OPNsense Cloud Image

This repository aims to create a Packer recipe to build OPNsense for Cloud applications (OpenStack, AWS, Azure...).

## How to build

### With OpenImage docker
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

Make sure to run privileged container

```shell
sudo docker run --privileged -v .:/input -v ./output:/output openimage:latest
```

### Manually

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

The result will be located at `output/opnsense.qcow2`.

## Notes

The build of this image highly relies on speed of the worker. You way want to adapt `<waitX>` in the recipe file.

## How to debug the image
## How to build

### With OpenImage docker

Make sure to run privileged container

```shell
sudo docker run --privileged -p 5901:5901 -v .:/input -v ./output:/output openimage:latest
```
