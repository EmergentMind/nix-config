# Remote Bootstrap

## Introduction

Objective remote installation of nixos on a target machine followed but building my full nix-config for that machine, including secrets. 

goal to be as automated and unattended as possible. nix-secrets creates many challenges

What are the typical steps to get from a bootable install environment -> fully built nix-config

Without Secrets

1. bootable iso
2. format drives
3. nixos installation
4. copying of nix-config to target
5. rebuild

With Secrets

1. Boot into iso
2. Manually format drives or use visual wizard
3. Install NixOS
4. install and configure tools required to generate age keys for sops
5. generate new host age key, add to .sops.yaml, and update keys
6. push changes to nix-secrets repo
7. copy/clone full nix-config to target
8. run the full rebuild
9. push the machines hardware-config to the repo

With secrets, declarative disk partitioning, and automate doing it all remotely

1. Boot target into custom iso
2. Run script from source machine that will:

    1. Prep declarative drive partition and format via disko
    2. Generate target machine hardware-configuration and add to nix-config
    3. Remotely install nixos using minimal installer flake to accommodate next step
    4. Generate age keys for accessing sops secrets based on the hosts ssh keys
    5. Add new key to .sops.yaml, and update keys
    6. Push changes to nix-secrets
    7. Copy full nix-config to target
    8. Run the full rebuild
    9. Push the machine's hardware-config to the repo

3. Answer yes/no helper questions and enter credentials when required.

Along we'll also need to handle all of the known_hosts fingerprinting and ssh access checks along the way.

In this article we'll go over each of the tools used, changes to the nix-config to solve various challenges, detail each of the individual steps, and then tie it all together as an automated process (or at least, as automated as possible).

## Tools used

Before diving into the automation steps and procedure for performing the install, we'll go over a few of the tools used to help achieve the solution.

These are:

- just
- custom iso
- disko
- nixos-anywhere

### Just
TODO quick blurb about just and a link to video

### Booting to a custom installation environment

Initially started using the minimal install iso but in 23.11 rsync was not included in the iso. This was problematic because I knew I wanted to use nixos-anywhere to perform remote installation of nixos while referencing my own flake for configuration settings. Nixos-anywhere makes use of rsync and failed to run correctly against the 23.11 iso. At the time of developing my solution there was an open issue on their repo (FIXME add reference) that will likely make use of a different tool. As a work around, we can generate my own custom iso that includes all of the tools needed to perform the remote bootstrap. As a side benefit we'll have a convenient means of generating custom iso environments in the future for testing or whatever other scenarios may arise.

To accomplish this, we use a new hosts entry in nix-config called iso and added all of the requisite information. FIXME fill out what this info is

With that complete, we generate the iso file which will be written to `result/iso/`

The ISO can then be flashed to a USB stick to insert in to a target machine or if you're building a VM, you can point the optical drive to the file. There are many other ways that ISOs can be generated and you can even skip the ISO and generate a VM environment directly. FIXME add references

describe doing this with just iso and just iso drive

With the custom iso generated, we can set it aside for now and work on the rest of the steps.

### Declarative disk partitioning and formatting

Disko provides NixOS with a convenient and powerful means of handling your disk partitioning and formatting requirements in the same manner as configuring the OS.

FIXME add information about disko

I decided that I would likely follow a similar partitioning scheme across most if not all of my hosts, so I wrote the disko specification module to hosts/common/disks to keep things organized.

FIXME overview of disko file. Overview of how I'm partitioning. overview of where the disko and the configfile needs to be referenced and why (nixos-installer config, and hosts/[host]/default.nix)

### Remote OS installation

nixos-anywhere allows users to remotely install NixOS to a specified target machine using a single command. For our purposes, the only requirements are that the target be booted into a nix os environment and the tool be instantiated from a nix environment (FIXME clarify nix or nixos env). There are other starting points as well FIXME: what starting points are those?

nixos-anywhere is also flake based, which means we don't need to clone the code and can simply use nix run to instantiate the installation process while providing several arguments such as where our config flake is located and what the target is.

## Nix-config Modifications

To automate the process, several modifications to the nix-config were made:

TODO show updated nix-config diagram
TODO note about how lib and vars have been added and are used but not a requirement for this

### A minimal nixos-installer flake
To perform a success build of nix-config requires access to our private nix-secrets repository, which means the host needs age key and the nix-secrets repository has to be updated with the key prior to building nix-config. This presents a few issues:

- we need to have NixOS installed on the host to generate the age keys and update nix-secrets
- when we install NixOS we want it to follow at least some of the specifications we have for the host, in particular the disko specs.
- we can not leverage the full nix-config because it inputs nix-secrets

To solve this problem, we'll create a separate 'mini' flake withing the nix-config that can cherry pick the minimum required to configuration details for us to install NixOS according to spec, generate age keys for the host, update the nix-secrets repo, and then load and build the full nix-config.

Conveniently, we'll also need a place to house our ISO configs. Generating the ISOs requires defining them as flake output so rather than adding to our main flake.nix file, we can add the iso output exclusively to the nixos-installer flake file. In doing so we can segregate all of our 'install-only' items from the rest of the nix-config.

`nixos-installer`
    flake.nix
    iso/default.nix
    minimal-configuration.nix

TODO details about each file
detail referencing the various full config pieces

### A new hosts/common/disks directory

For disko, I'll be using the same disk partitioning and format specification for most of my hosts, so I've added disks to the hosts/common directory. Each host module will reference the appropriate disko spec along with it's hardware-configuration module
TODO: show example of the imports for this
`hosts/common/disks`

Details about setting up disko spec and referencing it in both the main config and minimal
Show setting up guppy

## Order of operations

With our config ready to go we can detail the order in which all of the steps of the process need to happen.

TODO explain order of operations, including what is happening on which machine
TODO diagram sequencing the procedure

### Pre-reqs

Source machine has updated copies of nix-config and nix-secrets repos, both of which reside in the same parent directory.
Automation script be executed from nix-config directory because we'll need to navigate into and out of directories relative to that location
Target host has entries established in the requisite places, including the disko spec

### Booting the target to a custom ISO

details

### Remote installation of NixOS

For this portion of the install we'll be using the root user provided by the ISO boot environment.

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
At this point of the process we'll switch from using the root user that was provided by the ISO boot environment to our primary user, that was created and configured during installation according to our minimal flake.
Also, when we copied the nix-config to the ISO environment for use during installation, it was not retained when we rebooted and entered the installation. So first we'll need to copy the nix-config over to our primary user's home on the target and we'll also copy nix-secrets
    remind that sync rather than clone is faster

### Building nix-config

note about this being optional in the script and that we print the manual instructions as a helper.

### Pushing the target's hardware-configuration

## Putting it all together


TODO: the items below the line should just be separate video material.. not necessary for remote install

lib and configLib
vars and configVars
...


1. Boot target into custom iso
2. Run script from source machine that will:

    1. Prep declarative drive partition and format via disko
    2. Generate target machine hardware-configuration and add to nix-config
    3. Remotely install nixos using minimal installer flake to accommodate next step
    4. Generate age keys for accessing sops secrets based on the hosts ssh keys
    5. Add new key to .sops.yaml, and update keys
    6. Push changes to nix-secrets
    7. Copy full nix-config to target
    8. Run the full rebuild
    9. Push the machine's hardware-config to the repo

3. Answer yes/no helper questions and enter credentials when required.