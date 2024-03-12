# Nix-Config and Nix-Secrets Secrets Management

[README](../README.md) > Nix-Config Secrets Management

Nix-Secrets is a _private_ repository used by EmergentMind's _public_ Nix-Config to automate provisioning of passwords and keys across hosts. Contents include:

- `secrets.yaml` - houses the secrets and is encrypted/decrypted using `sops-nix`.
- `.sops.yaml` - instructs `sops-nix` which age keys to use when encrypting `secrets.yaml`.

Several key sets are used for encrypting and decrypting the secrets:

- A primary, dev age key set is used to edit and maintain `secrets.yaml`. This key is not derived from an ssh key set.
- Host-specific age key sets are used by `sops-nix` to encrypt/decrypt `secrets.yaml` during NixOS or Home-Manager builds.

Each host-specific age key set is generated/derived from the hosts ssh_host_ed25519_key set, which is automatically created by nix when we enabled openssh in the nix-config. Age keys are generated this way, instead of independently, as a redundant safety mechanism. If something happens to a given host's age key set for whatever reason, they can be regenerated using the corresponding ssh key set.

The secrets stored in `secrets.yaml` include private ssh keys, user passwords, msmtp service credentials, and other keys or passwords that are critical to provisioning systems configured through the nix-config.

## Table of Contents

- [Requirements](#requirements)
- [Using nix-secrets with nix-config](#using-nix-secrets-with-nix-config)
- [Initializing Secrets and Keys](#initializing-secrets-and-keys)
- [Managing Keys](#managing-keys)
- [Managing Secrets](#managing-secrets)
- [Installing Secrets on a New Host](#installing-secrets-on-a-new-host)
- [Troubleshooting](#troubleshooting)

## Requirements

Depending on the activity required, some of the following packages will be required. Packages like age, sops, and ssh-to-age aren't necessarily installed on the host so you may need to add them to a temporary shell to perform the required action e.g. `nix-shell -p foo bar`

- age
- git
- nix-shell
- nvim or other editor
- sops-nix
- ssh
- ssh-to-age

## Using nix-secrets with nix-config

### sops-nix

Both repos use sops to encryp/decrypt secrets. The Nix-Config gets sops from the 'sops-nix' repo which is an input into the nix-config flake.nix

```nix
inputs = {
 # ...
   sops-nix = {
     url = "github:mic92/sops-nix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
 # ...
};
```

Sops related nix expressions are used throughout the config to define where secrets what secrets will be decrypted and where they will be used. For a few existing examples, of this in the nix-config see the following files:

- ./hosts/common/core/sops.nix
- ./hosts/common/users/ta.nix
- ./hosts/common/optional/msmtp.nix
- ./home/ta/common/core/sops.nix

### Inputing nix-secrets to nix-config

The nix-secrets repo itself is input into my Nix-Config flake via:

```nix
inputs = {
  # ...
  mysecrets = {
        url = "git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?shallow=1";
        flake = false;
      };
  # ...
};
```

Providing `secrets.yaml` to sops-nix is achieved in ./hosts/common/core/sops.nix. This is a snippet of the relevant code:

```nix
{ inputs, config, ... }:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {

    defaultSopsFile = "${secretspath}/secrets.yaml";
 # ...
```

### Initial and subsequent flake rebuilds

When rebuilding the flake or updating the inputs using a private repo you will be asked to authenticate using the associated ssh passphrase or depending on the host, by touching a yubikey. The first time this happens you will often see errors about some of the keys it's looking for, this is normal, wait until it asks for a manual passphrase or actually asks for touch presence. Some times, in particular with input updating, you will be asked for credentials twice.
See [no such identity](#no-such-identity), below for an example of output with errors that will eventually resolve.
See [Editing `secrets.yaml`](#editing-secretsyaml), above for an example of input updating.

## Initializing Secrets and Keys

This is a log of the steps taken to create the private repo contents for grief but performed on my arch/manjaro box prior so that I can more conveniently push changes... that is, until grief is able to use the secrets :D

1. On ghost create the nix-secrets repository

   ```bash
   mkdir ~/src/nix-secrets
   cd ~/src/nix-secrets

   ```

2. Install sops and age

   ```bash
    pamac install age sops
   ```

3. Create an age key set for dev use if one does not already exist.

   ```bash
   $ mkdir -p .config/sops/age
   $ age-keygen -o ~/.config/sops/age/keys.txt
   Public key: age00000000000000000000000000000000000000000000000000
   ```

   This does not need to be based on an ssh key.

4. On grief, generate age keys for grief based on its ssh host keys (these would have been auto-created when enabling ssh earlier on)

   ```bash
   $ nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   this path will be fetched (0.94 MiB download, 2.70 MiB unpacked):
   /nix/store/j1nbcdrr1xqc6swycq0c361sxrpm54fy-ssh-to-age-1.1.3
   copying path '/nix/store/j1nbcdrr1xqc6swycq0c361sxrpm54fy-ssh-to-age-1.1.3' from 'https://cache.nixos.org'...
   age00000000000000000000000000000000000000000000000000
   ```

5. Create a `.sops.yaml` file and add the age keys. This file tells sops which keys to use when encrypting the secrets file.

   ```bash
   $ nvim ~/src/nix-secrets/.sops.yaml

   .sops.yaml
   ---------
   # pub keys
   keys:
   - &users:
       - &ta age10000000000000000000000000000000000000000000000000000000000
   - &hosts: # nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
       - &grief age10000000000000000000000000000000000000000000000000000000000

   creation_rules:
       #path should be relative to location of this file (.sops.yaml)
   - path_regex: hosts/common/secrets.yaml$
       key_groups:
       - age:
         - *ta
         - *grief
   ```

6. Back up all of the age keys.

7. Use sops to create `secrets.yaml` and add the secrets. The file will be opened in your EDITOR. The file must be strictly formatted yaml. Upon saving and exiting the browser sops will check the formatting. If it isn't well-formed, a warning will be printed and when you press enter, you will be returned to the editor to correct the issue.

   ```bash
   $ sops secrets.yaml

   secrets.yaml
   -------
   private_keys:
       maya: <private key data>
       mara: <private key data>
       manu: <private key data>
   yubico:
       u2f_keys: <key data>
   ta-password: <password>
   media-password: <password>
   msmtp-password: <password>

   ```

   For additional details on formatting refer to https://github.com/Mic92/sops-nix

8. Save and exit the secrets file.
9. Commit and push your changes to gitlab.

## Managing keys

### Adding additional keys

1. Generate a new age key. The example below demonstrates add an age key on a new host, based on it's ssh host key. This would occur on the new host itself.

   ```nix
   nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   this path will be fetched (0.01 MiB download, 0.05 MiB unpacked):
     /nix/store/gv2cl6qvvslz5h15vqd89f1rpvrdg5yc-stdenv-linux
   copying path '/nix/store/gv2cl6qvvslz5h15vqd89f1rpvrdg5yc-stdenv-linux' from 'https://cache.nixos.org'...
   age00000000000000000000000000000000000000000000000000
   ```

2. On a system with access to the nix-secrets repo, add the generated age key as a key entry to the `nix-secrets/.sops.yaml` file. This example follows the new host example from step 1.

   ```yaml
   nix-secrets/.sops.yaml

   ------------------------------

   # pub keys
   keys:
     # ...
     - &hosts:
       - &yournewhostname age00000000000000000000000000000000000000000000000000

   creation_rules:
     - path_regex: secrets.yaml$
       key_groups:
       - age:
       # ...
         - *yournewhostname

   ```

3. Update the keys of the related sops file. The following example assumes the current directory is somewhere other than `nix-secrets` and that sops is install or active in the current shell.

   ```bash
   sops --config ../nix-secrets/.sops.yaml updatekeys ../nix-secrets/secrets.yaml
   2024/02/09 12:11:05 Syncing keys for file /home/ta/src/nix-secrets/secrets.yaml
   The following changes will be made to the file's groups:
   Group 1
       age00000000000000000000000000000000000000000000000000
       age00000000000000000000000000000000000000000000000000
   +++ age00000000000000000000000000000000000000000000000000
   Is this okay? (y/n):y
   2024/02/09 12:16:54 File /home/ta/src/nix-secrets/secrets.yaml synced with new keys
   ```

4. Commit and push the changes to the `nix-secrtes` repo.
5. An a previously installed host, you will have to update the flake inputs to fetch the new secrets. This can be acheived in two ways:

   - Run `nix flake lock --update-input mysecrets` to update the flake input with the new secrets file.
   - Run `nix flake update` to update all inputs.

   Then rebuild the flake `sudo nixos-rebuild switch --flake .#<host>`

### Removing keys

TODO

### Rotating keys

TODO

## Managing Secrets

### Editing `secrets.yaml`

From the directory where your `.sops.yaml` is located run `sops path/to/secrets.yaml`

**IMPORTANT:** after updates are made to the secrets in this repository you will need to ensure that the mysecrets input in nix-config/flake.nix is updated. You can do this on each host by running `nix flake lock --update-input mysecrets` which will ask you to authenticate with the repository again. Then you can rebuild as normal.

For example:

```bash
$ nix flake lock --update-inpthese instructionsom/emergentmind/nix-secrets.git?ref=refs/heads/main&rev=33855f2689114f4b5ab7c5adaa761f891eb9399f&shallow=1' (2024-01-24)
  → 'git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=refs/heads/main&rev=b5a36e640ed350c1f18cc2d67068cae6d4cd57d3&shallow=1' (2024-01-25)
direnv: loading ~/src/nix-config/.envrc
direnv: using flake
direnv: nix-direnv: renewed cache
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_CONFIG +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIRS

$ sudo nixos-rebuild switch --flake .#grief
building the system configuration...
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
activating the configuration...
sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint age0000000000000000000000000000000000000000000000000000
modifying secret: media-password
setting up /etc...
sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint age000000000000000000000000000000000000000000000000000
reloading user units for ta...
setting up tmpfiles
restarting the following units: home-manager-ta.service
direnv: loading ~/src/nix-config/.envrc
direnv: using flake
direnv: nix-direnv: using cached dev shell
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_CONFIG +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIRS
```

### Using Hashed Passwords for Declared User Credentatials

When defining users in your Nix-Config, you can set the user password using a hashed password.
These steps assume that you have already installed and configured sops-nix to work with your nix-config.

1. Create a hashed password for the user. For this example we'll call our user foo

   ```bash
   $ mkpasswd -s
   Password:*******
   <hashed password data>
   ```

2. Copy the hashed password and open your secrets file.

   ```bash
   $ sops secrets.yaml

   secrets.yaml
   ---------

   # ...

   foo-password: <Hashed password data>

   # ...
   ```

3. Save and exit the file.
4. Commit and push the changes to the repo.
5. In the nix-config, edit the `/hosts/common/users/foo.nix` file to include the following

   ```nix
   ~/src/nix-config/hosts/common/users/foo.nix
   ---------

   # ...

   sops.secrets.foo-password.neededForUsers = true;
   users.mutableUsers = false;

   users.users.foo = {
     isNormalUser = true;
     hashedPasswordFile = config.sops.secrets.foo.path;
   };

   # ...

   ```

   It's important to include `users.mutableUsers = false` to ensure the user can't modify their password or groups. Furthermore, if the user had already been created prior to setting their password this way, their existing password will not be overwritten unless this option is false.

6. Run `nix flake lock --update-input mysecrets` to update the flake input with the new secrets file.
7. Rebuild `sudo nixos-rebuild switch --flake .#<host>`
8. Test out the user credentials

   ```bash
   $ su foo
   Password:
   foo@<host>:/home/ta/src/nix-config/>
   ```

Additional reference: https://github.com/Mic92/sops-nix#setting-a-users-password

## Installing Secrets on a New Host

Secrets from this repo are typically "installed" on hosts via the nix-config repos flake. Refer to the [nix-config/docs/addnewhost.md](https://github.com/EmergentMind/nix-config/blob/dev/docs/addnewhost.md#adding-a-new-host) for details on how to add both the nix-config and nix-secrets repos to a new host.

## Troubleshooting

### `secrets.yaml` isn found in `secretspath`

The first time I rebuilt the flake, my repo only contained this README.md
If input succeeds but `secrets.yaml` isn't found in `secretspath` make sure that the file has been pushed to the private
repo AND run `nix flake update` to update the nix store

### no such identity

FIXME: getting some complaints about nix-secrets the first time you build a flake but to just wait and then enter the ssh passphrase when it gets to that point. then rerun the build. should also probably figureout how to avoid... here's a terminal dump. Pretty sure it has something to do with the `~/.ssh/config` that gets generated from nix-config.. the first identifyfile for gitlab is "id_yubikey" which isn't a legit key but rather used by our yubikey script to cycle through plugged in keys.

```bash
         sudo nixos-rebuild switch --flake .#grief
         [sudo] password for ta:
         The authenticity of host 'gitlab.com (172.65.251.78)' can't be established.
         ED25519 key fingerprint is SHA256:000000000000000000000000000000000000000000
         This key is not known by any other names.
         Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
         Warning: Permanently added 'gitlab.com' (ED25519) to the list of known hosts.
         git@gitlab.com: Permission denied (publickey).
         fatal: Could not read from remote repository.

         Please make sure you have the correct access rights
         and the repository exists.
         warning: could not read HEAD ref from repo at 'ssh://git@gitlab.com/emergentmind/nix-secrets.git', using 'master'
         git@gitlab.com: Permission denied (publickey).
         fatal: Could not read from remote repository.

         Please make sure you have the correct access rights
         and the repository exists.
         error:
               … while updating the lock file of flake 'git+file:///home/ta/src/nix-config'

               … while updating the flake input 'mysecrets'

               … while fetching the input 'git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?shallow=1'

               error: program 'git' failed with exit code 128
         direnv: loading ~/src/nix-config/.envrc
         direnv: using flake
         no such identity: /home/ta/.ssh/id_yubikey: No such file or directory
         Enter passphrase for key '/home/ta/.ssh/id_manu': direnv: ([/nix/store/m50r3qxka7bqf7agw1z6l1sqw87y250q-direnv-2.32.3/bin/direnv export zsh]) is taking a while to execute. Use CTRL-C to give up.

         no such identity: /home/ta/.ssh/id_yubikey: No such file or directory
         Enter passphrase for key '/home/ta/.ssh/id_manu':
         warning: updating lock file '/home/ta/src/nix-config/flake.lock':
         • Added input 'mysecrets':
            'git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=refs/heads/main&rev=33855f2689114f4b5ab7c5adaa761f891eb9399f&shallow=1' (2024-01-24)
         direnv: nix-direnv: renewed cache
         direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_CONFIG +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIRS
         ❯ sudo nixos-rebuild switch --flake .#grief
         building the system configuration...
         trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
         trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
         trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
         trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
         trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
         trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
         activating the configuration...
         setting up /etc...
         sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint age0000000000000000000000000000000000000000000000000000
         reloading user units for ta...
         setting up tmpfiles
         restarting the following units: home-manager-ta.service
         direnv: loading ~/src/nix-config/.envrc
         direnv: using flake
         direnv: nix-direnv: using cached dev shell
         direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_CONFIG +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIRS
```

---

[Return to top](#nix-config-secrets-management)

[README](../README.md) > Nix-Config Secrets Management
