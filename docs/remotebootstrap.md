# Remotely Bootstrapping NixOS and nix-config

## Introduction

My objective with this stage of my nix-config roadmap was to achieve automated, remote installation of NixOS on a target host followed by the building my full nix-config which incorporates my private nix-secrets repo. Part-way through the development of the solution, my brother @fidgetingbits started collaborating with me to speed things up, which I mention early as it was joint effort.

My ideal outcome was an entirely unattended process, from initial script execution to completion. However, I knew even before I started  would not be possible because I use passphrases for very nearly all of my ssh keys. As you'll see there are, many times where ssh authentication is required. We decided to also include several yes/no prompts at important places in the script. The additional attendance these require is trivial considering the ssh prompt attendance and importantly they allowed us to skip over specific sections of the script during testing. As you might imagine, debugging this script involved countless reboots into the ISO, re-installations of NixOS, rebuilds of the config, etcetera, to work out all of the kinks and niggles that we encountered along the way.

On the topic of attending to prompts during the bootstrap process it's worth pointing out that, depending on your SecOps requirements, a significant number of the prompts could be eliminated by simply using ssh keys that do _not_ have passphrases. Given this isn't the case for me, I haven't tested it but I believe that the entire process could quite easily be cut down to a single prompt if one removed all of the yes/no prompts _and_ used ssh keys without passphrases. It is possible the process could be made entirely unattended.

So with that bit of preamble out of the way. Let's take a look at the high level steps this project set out to solve.

First we can think about the typical, basic steps required get a new host booted into an installation environment and fully built according to our nix-config.

### Typical manual installation steps _without_ secrets

1. Download a NixOS ISO image and load it on a USB drive
2. Boot the new host into the ISO
3. Partition and format disks
4. Install NixOS
5. Clone or copy nix-config to the new host
6. Build nix-config
7. Update nix-config with the new host's hardware-configuration.nix

This would actually be quite trivial to automate with some readily available tools. Alas, having no secrets in the mix isn't practical.

### Typical manual installation steps _with_ secrets

1. Download a NixOS ISO image and load it on a USB drive
2. Boot the new host into the ISO
3. Partition and format disks
4. Install NixOS
5. Generate a new hosts age key for use with sops
6. Update nix-secrets with the new key
7. Push changes to the nix-secrets repo
8. Clone or copy nix-config
9. Build nix-config
10. Update nix-config with the new host's hardware-configuration.nix

Adding secrets complicates things significantly; we can't simply build the nix-config because it uses our private nix-secrets as an input. A valid private key needs to be present on the host so it can download nix-secrets from the private repository during build. Not only that, even if nix-secrets has been successfully downloaded, the new host will require a valid age key for sops to decrypt our secrets during build.

To deal with this hurdle we are left with some choices about what steps should occur on the new host versus on an existing source host, the latter of which would already be able to access and update nix-secrets. There are likely several ways to go about this but they would all require various manual steps to get the new host into a state that it will successfully access secrets when building nix-config. The solution I chose prior to automation was to build a stripped-down, minimal flake that aids in the process (an idea that came from [Ryan Yin's config](https://github.com/ryan4yin/nix-config/tree/main/nixos-installer)). Ultimately, the minimal installer flake approach was also used for the automated process described next.

### Automated remote installation with secrets

1. Generate a custom ISO image - to ensure we have all the tools we require
2. Boot the new host into the custom ISO
3. Execute a script from the source host that will:

    1. Generate target host hardware-configuration
    2. Remotely install NixOS using the minimal flake
    3. Generate an age key for the host to access nix-secrets during full rebuild below
    4. Update nix-secrets with the new key
    5. Push the nix-secrets changes to our private repository
    6. Copy both the nix-config and nix-secrets repos to target host
    7. Run the full rebuild
    8. Push the target host's hardware-config to the nix-config repo

Along we'll also need to handle all of the ssh related fingerprinting and authentication, do some validation checks, and have the script modify files cleanly so that if the script needs to be run multiple times on the same target (during testing or if we need to reinstall a host) any existing ssh or secrets related entries are replaced rather than added to.

> NOTE: While writing the documentation for all of this I realized that the steps above could be rearranged slightly and the minimal flake could be eliminated, if one didn't want to go that route. Roughly, this would involve revising steps 3.3 to 3.5 to occur prior to 3.2 and then installing the NixOS using the full nix-config instead of the minimal flake. This would effectively eliminate steps 3.6 and 3.7.
>
> However, I think there significant value in having and using the minimal flake as an intermediary step. With future additions to the config such as full disk encryption, impermanence, and who knows what else, I will appreciate having the ability to quickly install a lightweight version of the config to test and validate assumptions without as much overhead (fewer packages to download, faster build time, and a smaller footprint to debug when something inevitably goes sideways). It's worth noting that Ryan Yin states this as why he uses the minimal flake as well.
>
> In a future iteration of the script, I may add some options for skipping the intermediary steps but for now it's working well enough.

In the remainder of this article we'll go over each of the tools used, changes we made to the nix-config to solve various challenges, the individual steps of the script, and then tie it all together as an automated process (or at least, as automated as possible).

## Tools used

- [nixos-anywhere](#nixos-anywhere---remote-nixos-installation-via-ssh)
- [custom NixOS ISO image](#custom-nixos-iso-image)
- [disko](#disko---declarative-disk-partitioning)
- [just](#just---a-simple-command-runner)

### nixos-anywhere - Remote NixOS installation via ssh

__Official repo:__ [https://github.com/nix-community/nixos-anywhere](https://github.com/nix-community/nixos-anywhere)

nixos-anywhere allows users to remotely install NixOS to a specified target host with a single command, unattended. There is support for installing to a target that has a NixOS installer present or to a target that supports the Linux `kexec` tool, which is provided by most Linux distros these days. The latter scenario is typically only relevant when installing to a target that has a pre-existing, non-NixOS distribution installed on it. This could be the case when the target is provided by some sort of cloud infrastructure provider that ~~is in the dark ages~~ doesn't provide NixOS images yet. nixos-anywhere importantly also supports installations that use disko (covered below).

We'll be focusing on hosts booted into a NixOS ISO image, so the pre-requisites we need to meet are:

    - the source host has nix or NixOS installed 
    - the target host is:
        - booted into an ISO image
        - network accessible
        - has at least 1.5GB RAM

nixos-anywhere is also flake based, which means we won't need to clone the code to our source host; we can simply use a `nix run` command pointing to the github repo, along with several arguments such as where our config flake is located and what the target is. A simplified example:

    ```bash
        nix run github:nix-community/nixos-anywhere -- --flake .#foo root@192.168.100.10
    ```
When I first encountered nixos-anywhere I was hopeful that it would solve the entire problem set for my objective. While it does conveniently handle a substantial part of the process it does not get us into the ISO (no biggie), doesn't really handle secrets the way we need to, and it stops after NixOS has successfully been installed and the target host rebooted. That's pretty good though, all things considered and I learned a lot just by looking at the source code.

### Custom NixOS ISO image

I initially started using the official [NixOS Minimal ISO image](https://nixos.org/download/) but, in the 23.11 version, `rsync` was not included with it for some reason. This is problematic because nixos-anywhere uses `rsync` to perform part of the install. At the time of developing my solution there was an [open issue(260) on their repo](https://github.com/nix-community/nixos-anywhere/issues/260) about it. As I'm updating this text, there is apparently now a merged fix, [PR316](https://github.com/nix-community/nixos-anywhere/pull/316) that uses `ssh` and `tar` instead of `rsync`.

Regardless we're going to stick with generating our own custom ISO. As a side benefit we'll have a convenient means of generating custom ISOs in the future, for testing or whatever other scenarios may arise. The details of how we do this will be explained later in this article.

### disko - Declarative disk partitioning

__Official repo:__ [https://github.com/Mic92/disko](https://github.com/Mic92/disko)

I, and I suspect most people, don't often perform disk partitioning and formatting tasks. Whenever the time comes to do it I have to pull up a dusty and cobweb ridden section of my personal wiki to find out what I did last time. Even worse, before I had the sense to discipline myself to use a personal wiki, I was left to searching online and very likely running into the same, long forgotten, problems that I'd encountered in the past. Of course this isn't the case for simple disk configurations but with raid arrays, LUKS encryption, and my pre-disposition for encountering poorly documented outlier scenarios, anything that will help me make the process as consistent and reproducible as possible will be a Godsend.

Disko provides NixOS with a convenient and powerful means of declaratively handling disk partitioning and formatting requirements. It supports LUKS disk encryption, is handled by nixos-anywhere, and provides a quick reference of sorts to view our disk configuration specs from within the nix-config. Without this we are left with using the installation wizard or remembering which cli tools are for what - `fdisk`, `parted`, `fstab`, etc. Of course, the wizard works and the tools are great but I'll happily allow the rust to accumulate on them if I can simply declare what I want and go.

For the scope of this project, I decided that I would likely follow a similar partitioning scheme across most, if not all, of my hosts. Furthermore, until I got the installation process stable, I would skip over LUKS disk encryption and modify the code later.

We'll go over the details of the disko spec and updates needed in the nix-config later in the article.

### just - A simple command runner

__Official repo:__ [https://github.com/casey/just](https://github.com/casey/just)

`just` is quite simply, just a command runner that uses `make`-like syntax but is more elegant. We use it to provide quickly accessible cli recipes, via `just foo`, which will run whatever commands we've defined in a `justfile` for the specified recipe. This is also similar to running a bash script but running specific functions/recipes from the cli is simpler in `just`.

`just` was actually added to the nix-config prior to working on this project to streamline some of the dev workflow. I recently posted [a brief video](https://youtu.be/wQCV0QgIbuk) about it to my [YouTube channel](www.youtube.com/@Emergent_Mind) if you're interested.

## Nix-config Modifications

To automate the process, several modifications to the nix-config were made. At a high level, there were significant additions to the structural anatomy as seen in the following diagram. I'm fairly confident that, with these additions in place, the remainder of the nix-config will involve fleshing out existing parts of the structure as opposed to adding new limbs, so to speak.

![Anatomy v3](diagrams/anatomy_v3.png)

If you're new to my nix-config, you can find details about the original design concepts, constraints, and structural interactions in the article and/or Youtube video titled [Anatomy of a NixOS Config](https://unmovedcentre.com/technology/2024/02/24/anatomy-of-a-nixos-config.html).

### lib and vars

We've added a custom config library to `nix-config/lib` and a set of custom variables to `nix-config/vars`. Adding these isn't entirely necessary to accomplish remote bootstrapping but they were implemented during the project and show up in some of the examples throughout this article so it's worth going over what they do.

![lib and vars](diagrams/zoomin-vars-lib.png)

The contents of `lib` and `vars` made available in our main `flake.nix` outputs via:

```nix
nix-config/flake.nix
--------------------

# ...
configVars = import ./vars { inherit inputs lib; };
configLib = import ./lib { inherit lib; };
# ...
```

#### configVars

```nix
nix-config/vars/default.nix
--------------------

{ lib }:
{
  username = "ta";
  handle = "emergentmind";
  gitEmail = "7410928+emergentmind@users.noreply.github.com";
  networking = import ./networking.nix { inherit lib; };
  persistFolder = "/persist";
  isMinimal = false; # Used to indicate nixos-installer build
}
```

`configVars` gives us convenient access to a set of global-style configuration variables, or attributes more accurately, such as `configVars.username` for the primary user and `configVars.isMinimal` which will be described in detail later on in this article.

There are several other attributes listed but I've only started using few of them at this point.

#### configLib

```nix
nix-config/lib/default.nix
--------------------

{ lib, ... }:
{
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  scanPaths = path:
    builtins.map
      (f: (path + "/${f}"))
      (builtins.attrNames
        (lib.attrsets.filterAttrs
          (
            path: _type:
              (_type == "directory") # include directories
              || (
                # FIXME this barfs when child directories don't contain a default.nix
                # example:
                #   error: getting status of '/nix/store/mx31x8530b758ap48vbg20qzcakrbc8 (see hosts/common/core/services/default.nix)a-source/hosts/common/core/services/default.nix': No such file or directory
                # I created an empty default.nix in hosts/common/core/services to work around
                (path != "default.nix") # ignore default.nix
                && (lib.strings.hasSuffix ".nix" path) # include .nix files
              )
          )
          (builtins.readDir path)));
}

```

`configLib` gives us the `scanPaths` and `relativeToRoot` functions, both of which help clean up imports. Credit for both of these functions goes to [Ryan Yin](https://github.com/ryan4yin).

`scanPaths` will build a map of the paths to all .nix files in the current directory and it's children, excluding files called `default.nix`. It effectively lets us shrink some of our import blocks. For example:

```diff
 nix-config/hosts/common/core/default.nix
 --------------------

- { inputs, outputs, ... }: {
+ { inputs, outputs, configLib, ... }: {
-   imports = [
+     imports = (configLib.scanPaths ./.) 
-     ./locale.nix
-     ./nix.nix
-     ./sops.nix
-     ./zsh.nix 
-     ./services/auto-upgrade.nix
-     inputs.home-manager.nixosModules.home-manager ]
+   ++ [ inputs.home-manager.nixosModules.home-manager ]
    ++ (builtins.attrValues outputs.nixosModules);
    # ...
```

As you can see, we no longer need to individually name each of the modules that we want imported. Obviously this only works if _all_ of the .nix files in the current and child-directories are meant to be imported but since everything in our `core` directories is always used, `foo/core/default.nix` is the perfect candidate. I'm currently using this on the following modules:

    - hosts/common/core/default.nix
    - home/ta/common/core/default.nix
    - home/media/common/core/default.nix

> NOTE: Using `scanPaths` to auto-import files does have drawbacks. The files being imported aren't being explicitly stated, so in the future we may run in to trouble debugging errors. This is largely a matter of personal preference so, if you choose to follow suit just be aware of the risks. Being explicit wherever possible will arguable be more forgiving in the future.

`relativeToRoot` allows us to provided file paths based on the root of `nix-config/` instead of having to use `../` for static navigation. This typically occurs for imports and depending on the scenario, you may be traversing back several directories. The beauty of using `relativeToRoot` is that you can move files to different directories if need be and the pathing will still work. Consider the following examples for the two basic use cases.

##### Example 1 - single file import

```diff
 nix-config/nixos-installer/iso/default.nix
 --------------------

-  { pkgs, lib, config, ... }:
+  { pkgs, lib, config, configLib, ... }:
  {
  imports = [
-      ../../hosts/common/users/ta
+      (configLib.relativeToRoot "hosts/common/users/ta")
  ];

  # ...
```

In this example, we're really only eliminating the use of `../` to traverse directories in favor of portability relative to root.

##### Example 2 - multiple file imports

In this example I also include a single file import use case because I want to keep some segregation of imports for the time being.

```diff
  nix-config/hosts/grief/default.nix
  --------------------

-    { inputs, ... }: {
+    { inputs, configLib, ... }: {
    imports = [
        #################### Every Host Needs This ####################
        ./hardware-configuration.nix
    
        #################### Hardware Modules ####################
        inputs.hardware.nixosModules.common-cpu-amd
        inputs.hardware.nixosModules.common-gpu-amd
        inputs.hardware.nixosModules.common-pc-ssd

        #################### Disk Layout ####################
        inputs.disko.nixosModules.disko
-        ../common/disks/standard-disk-config.nix
+        (configLib.relativeToRoot "hosts/common/disks/standard-disk-config.nix")
        {
        _module.args = {
            disk = "/dev/vda";
            withSwap = true;
        };
        }
+    ]
+    ++ (map configLib.relativeToRoot [
        #################### Required Configs ####################
-        ../common/core
+        "hosts/common/core"

        #################### Host-specific Optional Configs ####################
-        ../common/optional/yubikey
+        "hosts/common/optional/yubikey"
-        ../common/optional/services/clamav.nix
+        "hosts/common/optional/services/clamav.nix"
-        ../common/optional/msmtp.nix
+        "hosts/common/optional/msmtp.nix"
-        ../common/optional/services/openssh.nix
+        "hosts/common/optional/services/openssh.nix"

        # Desktop
-        ../common/optional/services/greetd.nix"
+        "hosts/common/optional/services/greetd.nix"
-        /common/optional/hyprland.nix"
+        "hosts/common/optional/hyprland.nix"

        #################### Users to Create ####################
-        /common/users/ta
+        "hosts/common/users/ta"
    ]);

    # ...
```

The single file use case in this example is in the "Disk Layout" section. The multiple files use case towards then end makes use of the `map` function to apply `configLib.relativeToRoot` to all of the strings in the list that follows it. This way we don't have to write out the `configLib.relativeToRoot` for every imported file like we did for the single file. As you can see, aside from removing the `../` and adding in the path relative to root, we just need to wrap each list item in quotes so that they are handled correctly by `map`.

### A minimal nixos-installer flake

For our 'minimal' flake we'll create a new directory within our nix-config. This will let us cherry pick the minimum required configuration details to install NixOS according to our disko spec, generate age keys for the host, update the nix-secrets repo, and then, if all goes well, load and build the full nix-config. At any point along the way, we can interrupt the process to perform tests and experimentation.

This new directory also gives us a place house our ISO configs. Generating ISO files requires defining them as flake output, so rather than adding to our main flake.nix file, we can add our iso output exclusively to the nixos-installer flake file. In doing so we can segregate all of our 'install-only' items from the rest of the nix-config.

```bash
nix-config/nixos-installer
├── flake.lock
├── flake.nix
├── iso
│   └── default.nix
└── minimal-configuration.nix
```

![nixos-installer](diagrams/nixos-installer.png)

#### nix-config/nixos-installer/flake.nix

Let's have a look at the flake file.

```nix
nix-config/nixos-installer/flake.nix
--------------------

{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    inherit (self) outputs;
    inherit (nixpkgs) lib;
    configVars = import ../vars { inherit inputs lib; };
    configLib = import ../lib { inherit lib; };
    minimalConfigVars = lib.recursiveUpdate configVars {
      isMinimal = true;
    };
    minimalSpecialArgs = {
      inherit inputs outputs configLib;
      configVars = minimalConfigVars;
    };

    newConfig =
      name: disk: withSwap: swapSize:
      (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = minimalSpecialArgs;
        modules = [
          inputs.disko.nixosModules.disko
          ../hosts/common/disks/standard-disk-config.nix
          {
            _module.args = {
              inherit disk withSwap swapSize;
            };
          }
          ./minimal-configuration.nix
          {
            networking.hostName = name;
          }
          ../hosts/${name}/hardware-configuration.nix
        ];
      });
  in
  {
    nixosConfigurations = {
      # host = newConfig "name" disk" "swapSize" "withSwap"
      # Swap size is in GiB
      grief = newConfig "grief" "/dev/vda" "0" false;
      guppy = newConfig "guppy" "/dev/vda" "0" false;
      gusto = newConfig "gusto" "/dev/sda" "8" false;

      # Custom ISO
      #
      # `just iso` - from nix-config directory to generate the iso standalone
      # 'just iso-install <drive>` - from nix-config directory to generate and copy directly to USB drive
      # `nix build ./nixos-installer#nixosConfigurations.iso.config.system.build.isoImage` - from nix-config directory to generate the iso manually
      #
      # Generated images will be output to the ~/nix-config/results directory unless drive is specified
      iso = nixpkgs.lib.nixosSystem {
        specialArgs = minimalSpecialArgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ./iso
        ];
      };
    };
  };
}
```

As you can see, we'll only need to input `nixpkgs` and `disko`, so we're already inputting a lot less than in the full `nix-config/flake.nix` which currently has 8 inputs.

Moving on to the outputs section, we've got a large `let` statement with a few notable distinctions from the main flake.

The first is that we're defining a `minimalConfigVars` set using the `lib.recursiveUpdate`<sup>1</sup> function, which takes in `configVars` but updates the value of `configVars.isMinimal` to `true`. This is effectively how we'll differentiate the minimal flake from the full flake when importing modules that are used by both. We'll cover how the `isMinimal` attribute is used by the relevant modules in the sections on [nix-config/nixos-installer/minimal-configuration.nix](#nix-confignixos-installerminimal-configurationnix) and [modifications to the primary user module](#modifications-to-the-primary-user-module).

The second notable distinction is the `newConfig` function which establishes a pattern of attributes that are used to quickly define the specs for each host in `nixosConfigurations` at the top of the `in` statement that follows. By dynamically handling the `name`, `disk` location, `withSwap` boolean, and `swapSize`, some duplicate entry is reduced. This pattern is something we're currently experimenting with in the nixos-installer but there is another that we're considering as well. As such, I have yet to update the main flake to follow suit. We'll look at how these attributes are used in the section on [a new hosts/common/disk` directory](#a-new-hostscommondisks-directory).

Another important distinction is that rather than each host using its own configuration module (e.g. nix-config/hosts/grief/default.nix), as they do in the main flake, all of the hosts here use `nix-config/nixos-installer/minimal-configuration.nix`.

Also note that `nixosConfigurations` provides the entry point to our ISO, which is discussed under [nix-config/nixos-installer/iso/default.nix](#nix-confignixos-installerisodefaultnix) below.

__References:__

1. recursiveUpdate - [https://noogle.dev/f/lib/recursiveUpdate](https://noogle.dev/f/lib/recursiveUpdate)

#### nix-config/nixos-installer/minimal-configuration.nix

```nix
nix-config/nixos-installer/flake.nix
--------------------

{  lib, pkgs, configLib, configVars, ... }:
{
  imports = [
    (configLib.relativeToRoot "hosts/common/users/${configVars.username}")
  ];

  fileSystems."/boot".options = ["umask=0077"]; # Removes permissions and security warnings.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    # we use Git for version control, so we don't need to keep too many generations.
    configurationLimit = lib.mkDefault 2;
    # pick the highest resolution for systemd-boot's console.
    consoleMode = lib.mkDefault "max";
  };
  boot.initrd.systemd.enable = true;

  networking = {
    # configures the network interface(include wireless) via `nmcli` & `nmtui`
    networkmanager.enable = true;
  };

  services = {
    qemuGuest.enable = true;
    openssh = {
      enable = true;
      ports = [22]; # FIXME: Make this use configVars.networking
      settings.PermitRootLogin = "yes";
      # Fix LPE vulnerability with sudo use SSH_AUTH_SOCK: https://github.com/NixOS/nixpkgs/issues/31611
      # this mitigates the security issue caused by enabling u2fAuth in pam
      authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];
    };
  };

  # yubikey login / sudo
  # this potentially causes a security issue that we mitigated above
  security.pam = {
    enableSSHAgentAuth = true;
    #FIXME the above is deprecated in 24.05 but we will wait until release
    #sshAgentAuth.enable = true;
    services = {
      sudo.u2fAuth = true;
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit(pkgs)
    wget
    curl
    rsync;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
```

Most of this file declares the basic NixOS options that are used on all of our hosts, with some minor tweaks that are only really acceptable in a minimal environment that won't be around for long. The most notable tweaks are:

- `fileSystems."/boot".options = ["umask=0077"];` to remove warnings about permissions and security that are acceptable in this state
- `services.openssh.settings.PermitRootLogin = "yes";` which is set to "no" under normal circumstances but will allow for convenient automation prior to building the full nix-config

We also set up some `security.pam` options that make the the remote process more convenient by forwarding any ssh authentication requests from the target host to the source host.

Some of these options do appear in various `hosts/core` or `hosts/optional` modules but because the vast majority of what's in those modules are things we don't want in the minimal environment, we repeat the declarations here. The one exception to this is when we set up a user for the minimal environment using our primary user module, which we import at the top of the file.

There are enough options configured in our `hosts/common/users/${configVars.username}` module (which in my cases is user `ta`, that we want to import it whole. However, some of what gets used will be limited by the `isMinimal` attribute being `true`. The details of which options are and are not used because of this are covered in the section on [modifications to the primary user module](#modifications-to-the-primary-user-module).

#### nix-config/nixos-installer/iso/default.nix

The `iso` section of our minimal flake's `nixosConfigurations` set references three modules.

1. `${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix` - which defines a small, non-graphical NixOS installation<sup>1</sup>
2. `${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix` - which provides an initial copy of the NixOS channel so we don't need to run `nix-channel --update`<sup>2</sup>
3. `./iso/default.nix` - which is where we declare the custom attributes we want.

```nix
nix-config/nixos-installer/iso/default.nix
--------------------

{ pkgs, lib, config, configLib, configVars, ... }:
{
  imports = [
    (configLib.relativeToRoot "hosts/common/users/${configVars.username}")
  ];

  # The default compression-level is (6) and takes too long on some machines (>30m). 3 takes <2m
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  # FIXME: Reference generic nix file
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  services = {
    qemuGuest.enable = true;
    openssh = {
      ports = [22]; # FIXME: Make this use configVars.networking
      settings.PermitRootLogin = lib.mkForce "yes";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [ "btrfs" "vfat" ];
  };

  networking = {
    hostName = "iso";
  };

  systemd = {
    services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    # gnome power settings to not turn off screen
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
```

As you can see, the ISO customization is relatively simple. It sets us up with flakes, QEMU guest support, and some ssh basics among other things. We're also importing our primary user module so that we get our preferred shell and some required tooling. As with elsewhere in the minimal flake, use of the primary user module will be limited by `isMinimal` being set to `true`. Details about this are covered in the section on [modifications to the primary user module](#modifications-to-the-primary-user-module).

To generate our custom ISO image we can run the following command from the root of our `nix-config`:

`nix build ./nixos-installer#nixosConfigurations.iso.config.system.build.isoImage`

The results will be written to `nix-config/result/iso/`.

> NOTE: If you are booted into the image file using libvirtd for a virtual machine, build a new version of the image file, and then reboot your VM, the original image will be used instead of the new one. To get around this, you must first delete the file from `nix-config/result/iso/` and then build the new image.

To simplify the command, and also deal with the noted libvirtd issue, we can run the `just iso` recipe from our `nix-config/justfile`, which will delete the `nix-config/result/` directory and build the ISO using one quick command. With the ISO image created, it can be flashed to a USB stick to insert in to a target host or, if you're building a VM, you can point the machine's optical drive directly to the file.

When we do need the ISO flashed to a USB device, we can run the `just iso-install [DRIVE]` command, where [DRIVE] is the path to your USB device. This recipe will first run `just iso` and then perform the following `dd`<sup>3</sup> command to write the image to our specified the specified device.

`sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync`

With the custom ISO generated, we can set it aside for now and work on the rest of the steps.

> NOTE: It's possible to create images in many different formats other than ISO using a nix-community tool called nixos-generators<sup>4</sup>. You can, for example, generate a `qcow` image, which is the QEMU virtual storage file format and that image can be run directly as a virtual machine with an appropriate vm manager. I chose to focus on ISO only for the time being because it serves all of my needs.

__References:__

1. installation-cd-minimal.nix - [https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix)
2. channel.nix - [https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/channel.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/channel.nix)
3. dd command - [https://man7.org/linux/man-pages/man1/dd.1.html](https://man7.org/linux/man-pages/man1/dd.1.html)
4. nixos-generators - [https://github.com/nix-community/nixos-generators](https://github.com/nix-community/nixos-generators)

### Modifications to the primary user module

In this section, we'll examine how `configVars.isMinimal` is used in our primary user module (in my case `ta`) to define different settings depending on whether we are build our full config or just what we need for a minimal configuration.

```nix
nix-config/hosts/common/users/ta/default.nix
--------------------

{ pkgs, inputs, config, lib, configVars, configLib, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."${configVars.username}/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (./keys);

  # these are values we don't want to set if the environment is minimal. E.g. ISO or nixos-installer
  # isMinimal is true in the nixos-installer/flake.nix
  fullUserConfig = lib.optionalAttrs (!configVars.isMinimal)
    {
      users.users.${configVars.username} = {
        hashedPasswordFile = sopsHashedPasswordFile;
        packages = [ pkgs.home-manager ];
      };

      # Import this user's personal/home configurations
      home-manager.users.${configVars.username} = import (configLib.relativeToRoot "home/${configVars.username}/${config.networking.hostName}.nix");
    };
in
{
  config = lib.recursiveUpdate fullUserConfig 
    #this is the second argument to recursiveUpdate
    { 
    users.mutableUsers = false; # Only allow declarative credentials; Required for sops
    users.users.${configVars.username} = {
      isNormalUser = true;
      password = "nixos"; # Overridden if sops is working

      extraGroups = [
        "wheel"
      ] ++ ifTheyExist [
        "audio"
        "video"
        "docker"
        "git"
        "networkmanager"
      ];

      # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
      openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

      shell = pkgs.zsh; # default shell
    };

    # Proper root use required for borg and some other specific operations
    users.users.root = {
      hashedPasswordFile = config.users.users.${configVars.username}.hashedPasswordFile;
      password = lib.mkForce config.users.users.${configVars.username}.password;
      # root's ssh keys are mainly used for remote deployment.
      openssh.authorizedKeys.keys = config.users.users.${configVars.username}.openssh.authorizedKeys.keys;
    };

    # No matter what environment we are in we want these tools for root, and the user(s)
    programs.zsh.enable = true;
    programs.git.enable = true;
    environment.systemPackages = [
      pkgs.just
      pkgs.rsync
    ];
  };
}
```

In the `let` statement we define `fullUserConfig` using `lib.optionalAttrs`<sup>1</sup> which takes in two inputs. If the first input is `true` then the function will return the second input, an attribute set.

In our case, the conditional input is `(!configVars.isMinimal)`. The result being that when `isMinimal` is `false`, `optionalAttrs` will return the provided set of attributes to `fullUserConfig`. However, if `isMinimal` is `true`, `optionalAttrs` will return an empty set, `{}`.

All of the attributes we provide in the `fullUserConfig` set should be options we only want when our full user configuration is required. These include:

- `users.users.${configVars.username}.sopsHashedPasswordFile;` - although `sopsHashedPasswordFile` is defined earlier in the file, it will only have a meaningful value if sops is working, which will only be the case when the full config is being built.
- the two lines related to home-manager - we won't bother using home-manager for the minimal install, which will cut down immensely on the installation size because the majority of programs used in our full-config are declared through home-manager.

With that out of the way, we come to the `in` statement where we define `config` using `lib.recursiveUpdate`<sup>2</sup>. As we know from using this function in `nixos-installer/flake.nix`, it will merge two attribute set inputs. In this case, we input our `fullUserConfig` from the `let` statement and for the second input we declare our set of attributes that we want regardless of what value `isMinimal` is set to.

There are a three things particularly noteworthy regarding this section of the config because they caused some hurdles and confusion.

First, `recursiveUpdate` is a recursive variant of the attribute update operator `//`<sup>3</sup>. The recursion in `recursiveUpdate` will stop "when one of the attribute values is not an attribute set, in which case the right hand side value is takes precedence of the left hand side value." In an early iterative of this file we used `//` in error to merge `fullUserConfig` with the second set. What happened was that regardless of whether `isMinimal` was true or not, the `users.users.${configVars.username}` options from the second attribute set were always used. The reason for this is quite subtle; consider the following examples:

```nix
foo = {
  users.users.ta = {
    packages = [ pkgs.home-manager ];
    shell = pkgs.bash
  };
};

bar = {
  users.users.ta = {
    shell = pkgs.zsh;
  };
};

example1 = lib.recursiveUpdate foo bar;
example2 = foo // bar;

# The result of example1 will be:
users.users.ta = {
  packages = [ pkgs.
In this example I also include a single file import use case because I want to keep some segregation of imports for the time being.
iveUpdate` prefers the second argument when a duplicate attribute name is encountered, but _only_ when recursion on an attribute value stops and this occurs when an attribute value is not a set. In other words, the function continues even though both arguments have `users.users.ta.shell`. As expected, `packages = [ pkgs.home-manager ];` from the first argument is merged with `shell = pkgs.zsh;` from the second argument, having taken precedence over `shell = pkgs.bash;` from the first.

On the contrary, when `//` encounters the same attribute name in both sets it takes the value of the second set. In other words, it sees that both arguments have an attribute name `users.users.ta` and
takes only the value of the second argument.

This took a little bit of digging to figure out given the scenario so I hope calling it out will help someone else in the future. To be clear, the documentation on this is clear but we'd forgotten the details and neglected to confirm our assumptions, which serves as a good reminder that regularly revisiting basic features that you may not use frequently can be worthwhile.

The second thing of note in this section added significant confusion when trying to solve the first because the official documentation states that `password` overrides `hashedPasswordFile`<sup>4,5,6</sup>. This not only doesn't make sense but it is not how the underlying code in nixpkgs actually works. @fidgetingbits looked into this extensively and filed [PR #310484](https://github.com/NixOS/nixpkgs/pull/310484) to correct the issue. As of this writing, the PR is still open.

The third thing of note, now that we understand the actual password options precedence is that we set a plaintext password as a generic password. This isn't a security concern when the full config is built because `hashedPasswordFile` being set in `fullUserConfig` will take precedence over `password` when `isMinimal` is false.

The final thing I'll mention about using plaintext `password` is this. It's possible due to testing and experimentation needs that you'll want to have a host on your network running in the ISO or minimal flake, without immediately building the full config. If that's the case you likely don't want to use the plaintext password option. Instead, you can simply replace `password` with `hashedPassword` and provide it the value of a hashed password that is still something convenient to use/remember given the environment but is different than your actual user or root password.

To generate a hash for your password, you can do so in the cli using `mkpassword -s` and following the prompts. For example:

```bash
$ mkpasswd -s
Password:***********
<hashed password data>
```

That's enough of that; moving on!

References:

1. optionalAttrs - [https://noogle.dev/f/lib/optionalAttrs](https://noogle.dev/f/lib/optionalAttrs)
2. recursiveUpdate - [https://noogle.dev/f/lib/recursiveUpdate](https://noogle.dev/f/lib/recursiveUpdate)
3. attribute update operator `//` - [https://nix.dev/manual/nix/2.18/language/operators#update](https://nix.dev/manual/nix/2.18/language/operators#update)
4. users.users.\<name>.password - [https://search.nixos.org/options?channel=23.11&show=users.users.%3Cname%3E.password&from=0&size=50&sort=relevance&type=packages&query=users.users.%3Cname%3E.password](https://search.nixos.org/options?channel=23.11&show=users.users.%3Cname%3E.password&from=0&size=50&sort=relevance&type=packages&query=users.users.%3Cname%3E.password)
5. users.users.\<name>.hashedPassword - [https://search.nixos.org/options?channel=23.11&show=users.users.%3Cname%3E.hashedPassword&from=0&size=50&sort=relevance&type=packages&query=users.users.%3Cname%3E.hashedpassword](https://search.nixos.org/options?channel=23.11&show=users.users.%3Cname%3E.hashedPassword&from=0&size=50&sort=relevance&type=packages&query=users.users.%3Cname%3E.hashedpassword)
6. users.users.\<name>.hashedPasswordFile - [https://search.nixos.org/options?channel=23.11&show=users.users.%3Cname%3E.hashedPasswordFile&from=0&size=50&sort=relevance&type=packages&query=users.users.%3Cname%3E.hashedPasswordFile](https://search.nixos.org/options?channel=23.11&show=users.users.%3Cname%3E.hashedPasswordFile&from=0&size=50&sort=relevance&type=packages&query=users.users.%3Cname%3E.hashedPasswordFile)

### A new hosts/common/disks directory

Our disko specifications are stored in `hosts/common/disks` to keep them organized and separate from unrelated modules. For the time being there is a single file, `standard-disk-config.nix`, that all of the hosts will use.

Each host is assumed to have a single disk that will consist of an obligatory ESP partition for `/boot`  and a [btrfs](https://btrfs.readthedocs.io/en/latest/Introduction.html) partition split into sub-volumes for root, persist (thinking ahead to impermanence), nix, and swap (optionally). The spec is quite simple but we'll want to make it handle some use cases dynamically.

Disko locates devices to partition and format through the `disko.devices.disk.*.device` attribute, which is the path to the device. For example, this could be "/dev/sda" for your primary hard disk or "/dev/vda" for your primary Virtual Machine disk. You can also provide paths to devices using their other identification paths, such as "/dev/disk/by-id/nvme-[device id]", if you prefer. Since some of my hosts are virtual and others are not, we'll need a way to set this depending on the host.

To start with, each host configuration module (`hosts/foo/default.nix`) will import disko from the flake inputs along with the `standard-disk-config.nix` disko spec and below that we'll also define some arguments for the host.

This is an example of the relevant code from the module for my host "grief":

```nix
nix-config/hosts/grief/default.nix
--------------------

{ inputs, configLib, ... }: {
  imports = [
    
    # ...
    
    #################### Disk Layout ####################
    inputs.disko.nixosModules.disko
    (configLib.relativeToRoot "hosts/common/disks/standard-disk-config.nix")
    {
      _module.args = {
        disk = "/dev/vda";
        swapSize = "8";
        withSwap = true;
      };
    }
  ]

  # ...
```

Note that, we're providing the `disk` path, `swapSize`, and `withSwap` state specifically for this host.

Now let's briefly review how the same arguments were set in our nixos-installer flake, since it doesn't use these host's configuration module. This is a snippet of the relevant code:

```nix
nix-config/nixos-installer/flake.nix
--------------------

# ...
    newConfig =
      name: disk: withSwap: swapSize:
      (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = minimalSpecialArgs;
        modules = [
          inputs.disko.nixosModules.disko
          ../hosts/common/disks/standard-disk-config.nix
          {
            _module.args = {
              inherit disk withSwap swapSize;
            };
          }
          ./minimal-configuration.nix
          {
            networking.hostName = name;
          }
          ../hosts/${name}/hardware-configuration.nix
        ];
      });
  in
  {
    nixosConfigurations = {
      # host = newConfig "name" disk" "swapSize" "withSwap"
      # Swap size is in GiB
      grief = newConfig "grief" "/dev/vda" "0" false;
      guppy = newConfig "guppy" "/dev/vda" "0" false;
      gusto = newConfig "gusto" "/dev/sda" "8" false;
# ...
```

As you can see, the same information is passed through to disko.

> Eventually, the same pattern will be used across the locations that set the arguments, once I decide which pattern to use, and at that point I'll likely define the values for each host using configVars.

Now that we know where the arguments are set, let's look at `standard-disk-config.nix` to see how they are used.

```nix
nix-config/hosts/common/disks/standard-disk-config.nix
--------------------

{
  lib,
  disk ? "/dev/vda",
  withSwap ? true,
  swapSize,
  configVars,
  ...
}:
{
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@persist" = {
                    mountpoint = "${configVars.persistFolder}";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@swap" = lib.mkIf withSwap {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "${swapSize}G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

```

At the top of this file, we take in the arguments (`disk`, `withSwap`, and `swapSize`) defined in the host config, while also defining some default values for two of them in case they weren't defined for the host.

In the expression that follows we can see where each argument is used. `disko.devices.disk.disk0.device = disk` sets the path of the device. Moving further down to the last subvolume in the file, we can see that `"@swap"` will only have values if `withSwap` is true, in which case `swapSize` will be used.

By reading through the rest of the file we can see how it's relatively easy to define that the disk will consist of the two partitions (512M for /boot and the remainder for root) and the second partition will consist of three to four subvolumes: @root, @persist, @nix, and optionally @swap.

A final piece of information on the topic of disks is that each host _will_ still require a `hardware-configuration.nix` file as is normal for NixOS. When using disko however, the `fileSystems` and `swapDevices` attributes, which are normal declared in the hardware config file, will be absent. This may not be of interest to most people because the hardware file is typically generated automatically.

## Order of operations

With our config ready to go we can detail the order in which all of the steps of the process need to happen.and then load and build the full nix-config.

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
