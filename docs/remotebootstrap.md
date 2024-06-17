# Remotely Bootstrapping NixOS and nix-config

NOTE: Introductions, Tools  and nix-config modifications sections have been moved to [unmovedcentre.com](https://unmovedentre.com)

## Order of operations

With our config ready to go we can detail the order in which all of the steps of the process need to happen.

### Booting the target to a custom ISO

details

### Remote installation of NixOS

For this portion of the install we'll be using the root user provided by the ISO environment.

using nixos-anywhere

#### preparation

from the nix-config directory
first we'll wipe any known_hosts entries on the source box

then need to prep a few things in the iso
create a directory for sshd to pick up a specified host key
generate a host key to the directory
update permissions
fingerprint the target

cd nixos-installer
prep temp password for disko
    explain
syncing nix-config to target
    explain sync rather than clone is faster
generate hw-config
copy the hw-config to source
resync nix-config to target (places hw-config in correct location on both systems)

#### installation

instantiate nixos-anywhere using minimal flake (since we are currently in nixos-installer dir)

#### post install

update ssh fingerprints
Persistance stuff (perhaps wait on this?)

### Generate Age Keys

### Adding ssh host fingerprints for gitlab and github

### Copying the nix-config

At this point of the process we'll switch from using the root user that was provided by the ISO to our primary user, that was created and configured during installation according to our minimal flake.
Also, when we copied the nix-config to the ISO image for use during installation, it was not retained when we rebooted and entered the installation. So first we'll need to copy the nix-config over to our primary user's home on the target and we'll also copy nix-secrets
    remind that sync rather than clone is faster

### Building nix-config

note about this being optional in the script and that we print the manual instructions as a helper.

### Pushing the target's hardware-configuration

## Putting it all together
