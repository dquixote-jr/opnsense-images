# Overview
    
VM image of OPNsense for CI/CD.

## About The Project

This repository has a packer configuration to create a qcow2 image of OPNsense, suitable for use with QEMU, in automation such as testing, CI/CD, github actions, etc.

To that end, it has a few customizations:
- Sets the `root` user password to `opnsense`
- Has a script [`/usr/local/bin/opn-apikey`](http/opn-apikey) which can create API keys for a user
- Installs the `qemu-guest-agent` package, which can be used to execute commands in the VM without an SSH connection
  - Can be used to create API keys together with the above script
- Disables bogons and private IP ranges from being blocked on the WAN interface

### How to use this image

In one terminal, start the VM using QEMU:

```
$ qemu-system-x86_64 -m 4096 -smp 2 -hda output/opnsense.qcow2 \
    -netdev user,id=user.0,hostfwd=tcp::8022-:22,hostfwd=tcp::8443-:443 \
    -device virtio-net,netdev=user.0 \
    -chardev socket,path=/tmp/qemu-isa-serial.sock,server=on,wait=off,id=qga0 \
    -device isa-serial,chardev=qga0 \
    -device virtio-serial \
    -chardev socket,path=/tmp/qemu-virtconsole.sock,server=on,wait=off,id=qvt0 \
    -device virtconsole,chardev=qvt0 \
    -chardev socket,path=/tmp/qemu-virtserialport.sock,server=on,wait=off,id=qvsp0 \
    -device virtserialport,chardev=qvsp0,name=org.qemu.guest_agent.0 \
    -display ncurses
```

In another terminal, connect to the guest agent socket using `socat`, and send instructions through the commandline.
N.B: The odd numbered lines are instructions sent by the user, the even numbered lines are the responses.

```
$ socat - unix-connect:/tmp/qemu-virtserialport.sock
{"execute": "guest-ping"}  # our input
{"return": {}}
{"execute": "guest-exec", "arguments": {"path": "/usr/local/bin/opn-apikey", "arg": ["-u", "root", "create"], "capture-output": true}}  # our input
{"return": {"pid": 13860}}
{"execute": "guest-exec-status", "arguments": {"pid": 13860}}  # our input
{"return": {"exitcode": 0, "out-data": "a2V5PVFEN2tFZVVXR0ZZeFFyeW4zUFY0bHNJMFpMWmpjUi8rVVNiQUozdGh5SStCTWxhdE95d3hBOHZ2UkRxU1N2S2w3UTcwNnNaaFZERHhNb0pYCnNlY3JldD13RmloS3lTeUFmVHo2RUtWWXlmemttR0hJcjJwV0ZCSnV1bVMwSnNLaE1YVlh4Qmxyelcvb0tvNi9nVEh4QXJyTS9mSVI3V2RXTDVVUTNkRQo=", "exited": true}}
```

The API keys can be found by decoding the base64 output
```
$ echo a2V5PVFEN2tFZVVXR0ZZeFFyeW4zUFY0bHNJMFpMWmpjUi8rVVNiQUozdGh5SStCTWxhdE95d3hBOHZ2UkRxU1N2S2w3UTcwNnNaaFZERHhNb0pYCnNlY3JldD13RmloS3lTeUFmVHo2RUtWWXlmemttR0hJcjJwV0ZCSnV1bVMwSnNLaE1YVlh4Qmxyelcvb0tvNi9nVEh4QXJyTS9mSVI3V2RXTDVVUTNkRQo= | base64 --decode
key=QD7kEeUWGFYxQryn3PV4lsI0ZLZjcR/+USbAJ3thyI+BMlatOywxA8vvRDqSSvKl7Q706sZhVDDxMoJX
secret=wFihKySyAfTz6EKVYyfzkmGHIr2pWFBJuumS0JsKhMXVXxBlrzW/oKo6/gTHxArrM/fIR7WdWL5UQ3dE
```

## Bugs

Currently the image is unable to be built in the CI.
But following the exact steps in the CI in a local machine is working.

## License

Distributed under the BSD 2-Clause "Simplified" License. See `LICENSE.txt` for more information.

## Acknowledgements

This project is a modified version of the amazing work done in the [openstack images repository](https://gitlab.com/open-images/opnsense).
