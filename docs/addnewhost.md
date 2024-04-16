# Adding A New Host

[README](../README.md) > Adding A New Host

FIXME These steps can and should be streamlined significantly during each roadmap stage. In particular, install from the liveISO rather than installing and then loading the config. I opted to forgo the latter until the config is more mature and I better understand the required process.

### Requirements

Because this repo relies on a private `nix-secrets` repository input as a flake uri, you must use a NixOS ISO versioned 23.11 or higher so that building the flake prompts for a passphrase.

### In this repo

1. Create a configuration file for the new host at `hosts/<hostname/default.nix`. Refer to existing host configs and define the config as needed.
2. Add users to `hosts/common/users/<usern>.nix` if needed
3. Create a host-specific home config for each user that will be accessing the host at `home/<user>/<hostname>.nix`. Refer to exiting user configs and defint the config as needed.
4. Edit `flake.nix` to include a the following entries:

   - Host information, under the `nixosConfigurations` option.

     ```nix
       ...
       nixosConfigurations = {
         # This is an example of an existing host called "grief"
         grief = lib.nixosSystem {
           modules = [ ./hosts/grief ];
           specialArgs = { inherit inputs outputs;};
         }
         # Add a descripton of your host
         yournewhostname = lib.nixosSystem {
           modules = [ ./hosts/yournewhostname ];
           specialArgs = { inherit inputs outputs;};
         }
         ...
       };
       ...
     ```

   - Primary user information for the primary user on each host, under the `homeConfigurations` option.

     ```nix
       ...
       homeConfigurations = {
         "ta@grief" = lib.homeManagerConfiguration {
           modules = [ ./home/ta/grief.nix ];
           pkgs = pkgsFor.x86_64-linux;
           extraSpecialArgs = {inherit inputs outputs;};
         };
         "username@yournewhostname" = lib.homeManagerConfiguration {
           modules = [ ./home/username/yournewhostname.nix ];
           pkgs = pkgsFor.x86_64-linux;
           extraSpecialArgs = {inherit inputs outputs;};
         };
         ...
       };
       ...
     ```

5. Commit and push the changes

### On the new host

These steps assume:

- installation on an UEFI system

0. Boot the new machine into a NixOS live environment and wait for a shell, or for the graphical installer to automatically open if you used a graphical ISO.

1. If in the graphical installer, and open a terminal.
   Confirm the boot process brought up networking successfully and a ip was acquired. Check `ip a`. If no ip was assigned, refer to <https://nixos.org/manual/nixos/stable/#sec-installation-manual-networking>

2. To gain remote access right away, set a temporary password for the root user using `passwd root` and following the prompts. Then from a remote machine, `ssh root@0.0.0.0` using the ip printed in step 1.

3. Most of the following steps require root. If you are remoted in from step 2 you should have a root shell. Otherwise, `sudo su`

> IMPORTANT: the code samples below assume installation on the `sda` device. Modify if necessary.
> These are instructions come directly from <https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning> with little to no modification.

3. Create a GPT partition table.

   `# parted /dev/sda -- mklabel gpt`

4. Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) which will be used by the boot partition.

   `# parted /dev/sda -- mkpart root ext4 512MB -8GB`

   If you do not require swap, replace `-8GB` with `100%`

5. _If you are adding a swap partition_, the size required will vary according to needs, here a 8GB one is created. NixOS uses the standard linux swap file needs so this will depend on how much memory the host has.

   `# parted /dev/sda -- mkpart swap linux-swap -8GB 100%`

6. Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its /boot partition. It uses the initially reserved 512MiB at the start of the disk.

   ```bash
   # parted /dev/sda -- mkpart ESP fat32 1MB 512MB
   # parted /dev/sda -- set 3 esp on
   ```

7. Initialize the Ext4 partitions using mkfs.ext4 and assign a unique symbolic label using the `-L label` argument. For example:

   `# mkfs.ext4 -L nixos /dev/sda1`

8. For swap, _if required_, use `mkswap` and assign a label using the `-L label` argument. For example:

   `# mkswap -L swap /dev/sda2`

9. For UEFI system boot partitions use `mkfs.fat` and assign a label using `-n label`. For example:

   `# mkfs.fat -F 32 -n BOOT /dev/sda3`

10. Mount the target file system on which NixOS should be installed on /mnt, e.g.

    `# mount /dev/disk/by-label/nixos /mnt`

11. Mount the boot file system on /mnt/boot, e.g.

    ```bash
    # mkdir -p /mnt/boot
    # mount /dev/disk/by-label/BOOT /mnt/boot
    ```

12. If you are using swap, activate swap devices now (swapon device). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.

    `# swapon /dev/sda2`

13. Generate default configs

    `# nixos-generate-config --root /mnt`

14. Edit the config so that we can quickly remote in over ssh after installation.

    ```bash
    # vim /mnt/etc/nixos/configuration.nix
    ```

15. Edit or add the following as needed.

    1. Verify:

       ```nix
       boot.loader.systemd-boot.enable = true;
       boot.loader.efi.canTouchEfiVariables = true;
       ```

    2. Uncomment this line and replace `nixos` with your desired host name:

       ```nix
       # networking.hostname = "nixos";
       ```

       This step isn't technically required but will make connected to the machine faster if you have aliases already setup.

    3. Delete or comment out the following lines if the are present.

       ```nix
       # services.xserver.enable = true;

       # services.xserver.displayManager.gdm.enable = true;

       # services.xserver.desktopManager.gnome.enable = true;
       ```

    4. Uncomment the `users.users.alice` section and create a basic use. For example:

       ```nix
       #users.users.ta := {
         #isNormalUser = true;
         #extraGroups = [ "wheel" ];
         #initialPassword = "temp";
       #};
       #users.mutableUsers = true;
       ```

    5. Uncomment `services.openssh.enable = true`

    6. At the end of the file, but prior to the final `}`, add the following line:

       `nix.settings.experimental-features = [ "nix-command" "flakes" ];`

    7. Save and exit the file

16. Do the installation.

    `# nixos-install` and set the root password when prompted.

17. Once installation is complete:

    `# reboot`

18. Sign in with the user you created.
19. In case something goes wrong in the next steps, set the password for the user defined in 15.4. For example: `passwd ta`
20. Create as source directory in the users home and clone the nix-config repo.

    ```bash
    $ mkdir -p ~/src
    $ cd ~/src
    $ nix-shell -p git --run 'git clone https://github.com/EmergentMind/nix-config.git'
    ```

21. Change to the repo directory and run nix-develop to access the dev shell defined in flake.nix.

    ```bash
    $ cd nix-config
    $ nix develop
    ```

22. Generate an age key on the new host, based on it's ssh host key.

    ```bash
    $ cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
    age00000000000000000000000000000000000000000000000000
    ```

### On a system with access to nix-secrets

22. On a system with access to the nix-secrets repo, add the generated age key as a host key entry to the `nix-secrets/.sops.yaml` file.

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

23. Update the keys of the related sops file

    ```bash
    $ sops --config ../nix-secrets/.sops.yaml updatekeys ../nix-secrets/secrets.yaml
    2024/02/09 12:11:05 Syncing keys for file /home/ta/src/nix-secrets/secrets.yaml
    The following changes will be made to the file's groups:
    Group 1
        age00000000000000000000000000000000000000000000000000
        age00000000000000000000000000000000000000000000000000
    +++ age00000000000000000000000000000000000000000000000000
    Is this okay? (y/n):y
    2024/02/09 12:16:54 File /home/ta/src/nix-secrets/secrets.yaml synced with new keys
    ```

24. Commit and push the changes to `nix-secrets` so they will be retrieved when the flake is built on the new host.

25. Before we build the flake and home-manager confgs on the new host, we need to ensure that it can access the private `nix-secrets` repo. From a system with the required priv/pub key-pair, cp the keys to the newhost:

    ```bash
    $ scp ~/.ssh/key_name* user@0.0.0.0:.ssh/
    ```

### Back on the new host

26. Back on the new hosts, create a `~/.ssh/config` so the correct keys are used.

    ```ssh
    ~/.ssh/config
    ------------------------------
    Host gitlab.com github.com
      IdentitiesOnly yes
      IdentityFile ~/.ssh/id_manu

    Host *
      ForwardAgent no
      Compression no
      ServerAliveInterval 0
      ServerAliveCountMax 3
      HashKnownHosts no
      UserKnownHostsFile ~/.ssh/known_hosts
      ControlMaster no
      ControlPath ~/.ssh/master-%r@%n:%p
      ControlPersist no
    ```

27. Since we've updated nix-secrets, we'll have to update the flake lock file to ensure that the latest revision is retrieved.

    ```bash
    $ nix flake lock --update-input nix-secrets
    warning: Git tree '/home/ta/src/nix-config' is dirty
    Enter passphrase for key '/home/ta/.ssh/id_manu':
    warning: updating lock file '/home/ta/src/nix-config/flake.lock':
    • Updated input 'nix-secrets':
     'git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&rev=aa0165aff5f74d367b523cc27dbd028b0251c30d&shallow=1' (2024-02-09)
    → 'git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&rev=2ef287a53f19be75a4ff1f5ba28595686d4b5cbb&shallow=1' (2024-02-13)
    warning: Git tree '/home/ta/src/nix-config' is dirty
    ```

    Enter the passphrase when prompted.

28. Copy the generated hardware config from its default location to the nix-config location:

    `$ cp /etc/nixos/hardware-configuration.nix ~/src/nix-config/hosts/NEWHOSTNAME/hardware-configuration.nix`

29. Build and switch to the flake:

    ```bash
    $ sudo nixos-rebuild switch --flake .#newhostname`
    ```

30. Once the build is finished build home-manager configs for each user on the system:

    ```bash
    $ home-manager build --flake .#user@newhostname

    ...

    $ home-manager build --flake .#user@newhostname
    ```

31. Commit and push the new hardware-configuration that was copied in step 2

---

[Return to top](#adding-a-new-host)

[README](../README.md) > Adding A New Host
