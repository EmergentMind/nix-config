# Adding A New Host

[README](../README.md) > Adding A New Host

TODO Stage 2:  This section is outdated. Update during deployment to gusto and consider moving this section back to the README.
Also need to include updating secrets

### In this repo

1. Create a configuration file for the new host at `hosts/<hostname/default.nix`. Refer to existing host configs and define the config as needed.
2. Add users to `hosts/common/users/<usern>.nix` if needed
3. Create a host-specific home config for each user that will be accessing the host at `home/<user>/<hostname>.nix`. Refer to exiting user configs and defint the config as needed.
4. Edit `flake.nix` to include a the following entries:
    * Host information, under the `nixosConfigurations` option.
 
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

   * Primary user information for the primary user on each host, under the `homeConfigurations` option.

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
 
FIXME These steps can be streamlined significantly at later roadmap stages to install based on the config, rather than installing and then loading the config. I opted to forgo the latter until the config is more mature and I better understand the required process.

These steps assume:
* installation on an UEFI system

0. Boot the new machine into a NixOS live environment and wait for the installer to automatically open.

1. Exit the graphical installer and open a terminal.
  Confirm the boot process brought up networking successfully and a ip was acquired. Check `ip a`. If no ip was assigned, refer to <https://nixos.org/manual/nixos/stable/#sec-installation-manual-networking>

2. Most of the following steps require root 

    `sudo su`

   > IMPORTANT: the code samples below assume installation on the `sda` device. Modify if necessary.
   These are instructions come directly from <https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning> with little to no modification.

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

10.  Mount the target file system on which NixOS should be installed on /mnt, e.g.

    `# mount /dev/disk/by-label/nixos /mnt`

11. Mount the boot file system on /mnt/boot, e.g.
    ```bash
    # mkdir -p /mnt/boot
    # mount /dev/disk/by-label/boot /mnt/boot
    ```

12. If you are using swap, activate swap devices now (swapon device). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.

    `# swapon /dev/sda2`

13. Generate default configs

    `# nixos-generate-config --root /mnt`

14. Edit the config so that we can quickly remote in over ssh after installation.

    ```bash
    # vim /mnt/etc/nixos/configuration.nix
    ```

    or use nano if you're in a great mood and don't care.

15. Edit or add the following as needed.

    1. Verify:

        ```nix
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        ```

    2. Uncomment this line and replace `nixos` with your desired host name:

        ```nix
        networking.hostname = "nixos";
        ```

    3. Delete the following lines:

        ```nix
        services.xserver.enable = true;

        services.xserver.displayManager.gdm.enable = true;
      
        services.xserver.desktopManager.gnome.enable = true;
        ```
    
    4. Uncomment the `users.users.alice` section and create a basic use. For example:

        ```nix
        users.users.ta = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          initialPassword = "temp";
          mutableUsers = true;
        };
        ```
    
    5. Uncommment the `environment.systemPackages` list and add a few key packages. The section should look like:

        ```nix
        environment.systemPackages = with pkgs; [
          neovim
          git
          sops
          age
          ssh-to-age
        ];
        ```

      6. Uncomment `services.openssh.enable = true`

    7. At the end of the file, but prior to the final `}`, add the following line:

       `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
       
    8. Save and exit the file

16. Do the installation.

    `# nixos-install` and set the root password when prompted.

17. Once installation is complete:

    `# reboot`

18. Sign in with the user you created.
19. In case something goes wrong in the next steps, set the password for the user defined in 15.4. For example: `passwd ta`
20. Create as source directory in the users home and clone the nix-config repo.

    ```nix
    $ mkdir -p ~/src
    $ cd ~/src
    $ git clone https://github.com/EmergentMind/nix-config.git
    ```

21. Generate an age key on the new host, based on it's ssh host key.

    ```nix
    nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    this path will be fetched (0.01 MiB download, 0.05 MiB unpacked):
      /nix/store/gv2cl6qvvslz5h15vqd89f1rpvrdg5yc-stdenv-linux
    copying path '/nix/store/gv2cl6qvvslz5h15vqd89f1rpvrdg5yc-stdenv-linux' from 'https://cache.nixos.org'...
    age00000000000000000000000000000000000000000000000000
    ```

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

24. 



9. ssh to the vm from ghost `ssh ta@0.0.0.0`
10. Now we'll add some authorized_keys so that we can ssh without a password

    ```bash
    $ nix-shell -p neovim
    $ mkdir .ssh
    $ nvim .ssh/authorized_keys
    
    .ssh/authorized_keys
    ---------
    <public key data>
    <public key 2 data>
    
    ```

11. Save and exit the file and then open a new terminal on ghost. Connect to grief over ssh again and confirm that it asks for authorization against one of the authorized keys we just added.
If not, diagnose the issue.






1. Exit out fo the installer.
2. Open a terminal
3. Partition and format drives as desired using the cli. <https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning>
4. Clone the public config repo:
    TODO: update url to appropraite Release branch when that stage comes
    `git clone https://github.com/EmergentMind/nix-config.gitit@github.com:EmergentMind/nix-config.git`
. 

1. Follow the installer steps, select no gui for windows manager, wait for it to install and reboot.
2. Once you've booted to the terminal.
3. Set the required features: `export NIX_CONFIG="experimental-features = nix-command flakes"`
4. `mkdir -p src/`
5. `nix-shell -p git`
6. `git init src/nix-config`
7. `ls /dev` to display the current devices. Note the devices called `sda`, `sdb`, `sdb1`, etc.
8. Plug in the USB still with the copy of nix-config repo
9. `ls /dev` again, and note the new device. e.g. `sdc`
10. `mkdir -p /mnt/usbstick` to create a mountpoint
11. run `sudo mount /dev/<device> /mnt/usbstick` but replace `<device>` with the device you identified in step 8.
12. `ls /mnt/usbstick` to confirm the contents of the mounted device are in fact the nix-config repo
13. `cp -r /mnt/usbstick/* src/nix-config` to copy the contents of the repo to its location on the new host.
. Generate a `hardware-configuration.nix` file for this machine: `sudo nixos-generate-config`
    You should see output saying that `hardware-configuration.nix` is writting and a warning that `configuration.nix` is not being overwritten.
14. run `cp /etc/nixos/hardware-configuration.nix src/nix-config/hosts/<hostname>/` but replace `<hostname>` with the actual hostname.
15. `cd src/nix-config`
16. Stage all of the files so nix flakes knows they exists `git add .`
17. Apply your system configuration using `sudo nixos-install --flake .#<hostname>`, wait for the installation to complete, and reboot.
      NOTE: If you are not in a live environment. run `sudo nixos-rebuild switch --flake .#hostname` and don't reboot.
18. If you didn't fuck up, you can install home-manager to the nix shell so we can apply the home configuration. `nix-shell -p home-manager`
19. `home-manager switch --flake .#<user>@<hostname>`
20. You should be able to remote in over ssh

---
[Return to top](#adding-a-new-host)

[README](../README.md) > Adding A New Host