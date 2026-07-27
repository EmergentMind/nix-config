This repo uses [microvm.nix](https://microvm-nix.github.io/) with some additional automation around it.

Quick structural overview:

`hosts/nixos/<host>/microvms/` - One or more microvms to run on <host>
`modules/hosts/nixos/microvms` - Functionality for managing microvms on the host (secrets, network, vpn, etc)
`modules/home/nixos/auto/microvms.nix` - Automatic home-level helpers for microvm management, like zsh aliases, etc.
`microvms/` - Configuration for host/home level on the microvm itself

The design tries to mimic the idea of isolated "hosts" and "home"
configurations for the microvms, and will automatically build microvms defined
by a given host.

We will use `ossa` as an example. The folder `hosts/nixos/ossa/microvms/` exists,
so underlying microvms are automatically parsed. There is a folder called `nano`,
which defines a microvm called nano. This `nano` folder defines custom host-level
configuration, and can also be used to store any other home-level customization
as well, like in `home.nix`.

The creation of said per-host microvms is handled by a function called
`lib.custom.microvms.mkMicrovm` which is called by
`hosts/nixos/ossa/microvms/default.nix`, though this will eventually be moved
so it is more generic. This file gets auto-parsed because `mkHost` for a given
nixos system already has automation such that every .nix file or
`<folder>/default.nix` file is imported. That said, having to add this file
per host isn't ideal, so it will likely be moved to `mkHost` or similar.

The `mkMicrovm` function is defined in
[introdus](https://codeberg.org/fidgetingbits/introdus/src/branch/aa/lib/microvms.nix)
and sets up a baseline microvm using `microvms/hosts/common/core/`. Although
individual microvms are defined per host, I still chose to use the
`hosts/common/core` folder schema for familiarization sake, since it mimics how
non-virtualized hosts are built.

As per above, the `microvms/` folder holds generic host/home level
configuration for microvms themselves. This includes the core, as well
as optional behavior like agents software, etc.

## Networking

This is handled by `modules/hosts/nixos/mcirovms/network.nix` which is automatically
imported for a given microvm.

microvms are placed onto an isolated network managed by the host using a `vbr-microvms` bridge.


```bash
4: vbr-microvms: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 12:34:56:78:9a:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.1/24 brd 10.0.6.255 scope global vbr-microvms
       valid_lft forever preferred_lft forever
9: microvm-nano: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vbr-microvms state UP group default qlen 1000
    link/ether 12:34:56:78:9a:bd brd ff:ff:ff:ff:ff:ff
```


If you have the `config.${namespace}.microvms.vpn.enable` setting set, you will
also have a `vm-vpn` interface setup, which connects to a VPN and automatically
sets up rules for forwarding internet traffic from the vm over that channel.

```bash
3: vm-vpn: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 10.2.0.2/32 scope global vm-vpn
       valid_lft forever preferred_lft forever
```

You can specify `allowedPorts` in the `vmSpecs` of a given microvm which will
also automatically inject rules into nixos-fw that allow the microvm to access
services. This is useful if you are running an agent that wants to talk to
a local llm service for example.

## VM Settings

At the moment I default to creating disk images for the microvms, which means
it isn't auto wiped on a run. Eventually something like impermanence for the
microvm should be introduced as an option.

The hosts /nix/store is imported read-only into the microvm to speed up creation. This
has the caveat that any soft secrets inside the store get leaked to the microvm, which
may not be trusted. This will need to also made an option.

The default host-level configuration for a microvm is defined in
`microvms/hosts/common/core/` which all vms will have. This also imports
`microvms/hme/common/core/`. There are other base files in both hosts and home
that could be used as templates for other microvms, like `agents.nix` which
will add some baseline tooling. Further per-microvm customization should be
done in `hosts/nixos/<host>/microvms/<vm-name>/`

## Secrets

A microvm may need access to some secrets that are managed by the host, like
API keys. It's not possible to simply place a symlink to a sops secret in a
shared folder because of the way the sharing works. So we have a service that
initializes a tmpfs folder in `/run/microvm-secrets` on the host, that gets mapped
to `/run/secrets` inside the microvm. Then secrets are exposed there.
