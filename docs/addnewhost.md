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

0. Boot the new machine into a NixOS live environment and wait for the installer to automatically open.
1. Exit out fo the installer.
2. Open a terminal
3. 


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