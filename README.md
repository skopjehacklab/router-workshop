# Router workshop

This repo contains some files used for a router workshop we did in the local hacklab.

The setup uses 2 or 3 VM images, based on ArchLinux and:
* systemd-networkd for basic network setup (not required, but seemed easy)
* [keepalived](http://www.keepalived.org/documentation.html) for vrrp redundancy
* [bird](http://bird.network.cz) for ospf, bfd, bgp, rip, etc…

You can see some config file examples in `mkosi.extra/` which are copied verbatim in the VM image.

The setup uses the [mkosi](https://github.com/systemd/mkosi) script from the systemd project. It's a simple tool to
create a VM image. The image is then used as a qemu base image to instanciate several virtual machines.

A custom `rooter.sh` (mis-spelled intentionally) script can run several VM instances from the same base image.
You just need to provide an ID, a number from 1 to 254, from which the name, mac and ip addresses are constructed.
Routers have 2 interfaces each, and the second interfaces are bridged together through the host.


# Prepare the host

Currently on ArchLinux as a host you need to install the `mkosi-git` from AUR and `arch-install-scripts` (and
`iproute2` for host setup). For other hosts see the docs at [mkosi](https://github.com/systemd/mkosi).


```
LAN=eth0 # or enp0sXXXX
sudo ip link add name br0 type bridge
sudo ip link set $LAN master br0
sudo ip addr add dev br0 192.168.200.254/24
sudo ip link set up dev br0
```

To create the base image (`rooter.raw`) just:
```
sudo mkosi
```

Then run several vms with:
```
./rooter.sh 1 # 2 or 3
```
each will create its own snapshot image `rooter1.img`, `rooter2.img` …


# TODO

* better docs and diagrams
* vrfs
* bgp
* quagga and other routers interoperability
* option for volatile snapshots
* systemd 233 for updated policies so that UseHostname works
