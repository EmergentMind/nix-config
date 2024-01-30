# Install Notes

[README](../README.md) > Install Notes

## Rebuild - January 22, 2024

This covers installation of NixOS on grief (lab box) as a VirtualBox VM after hosing access to my original secrets.yaml and locking myself out of the original grief lab.
The official manual has some "NixOS in a VirtualBox guest" specific instructions that were used here.
There is mention of a pre-built nixos virtualbox appliance available but I chose hardmode.
https://nixos.org/manual/nixos/stable/#sec-installing-virtualbox-guest

1. Download nixos iso
2. Install VirtualBox on ghost.
3. Start a new VM with the following settings:
    1. 8GB hdd or higher (I chose 250GB for lab purposes)
    2. 8GB memory
    3. Settings / System / Motherboard - Enable EFI
    4. Settings / System / Processor - enable PAE/NX
    5. Settings / System / Processor - enable VT-x/AMD-V
    6. Settings / Display / Screen - video memory 128MB
    7. Settings / Display / Screen - select VMSVGA
    8. Settings / Display / Screen - Enable 3D Acceleration
    9. Settings / Network / Adapter 1 - Attached to: Bridge Adapter.
        Note the mac address under Advanced and add a static dhcp entry on guard.
4. Load the iso as the boot media
5. Follow the install steps on the live environment:
    * use a basic password until ssh is setup
    * no desktop
    * allow unfree
    * use swap w/hibernate for devices with <=8GB RAM
6. Perform install and reboot.
7. We need to add our keys to the vm but I couldn't get virtualbox guest additions running on the basic nixos install. Instead, I temporarily enabled basic ssh access to `/etc/nixos/configuration.nix`.

    ```bash
    $ nix-shell -p neovim
    $ sudo nvim /etc/nixos/configuration.nix

    # edit the file
    ```

    Edit the following:
    1. ensure that the bootloader entry is as follows. If it is grub, you may not have enabled EFI in the previous steps.

        ```nix
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        '''

    2. hostname 'grief'
    3. under "environment.systempackages" uncomment or enable the following packages:
        * neovim
        * git
        * sops
        * age
        * ssh-to-age
    4. uncomment `services. openssh.enable = true`
    5. at the end of the file at the following entry:
       `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
    6. save and exit the file

8. Save the file and then rebuild nixos.

    ```bash
    $ sudo nixos-rebuild switch
    building Nix...
    building the system configuration...
    # ...
    ```

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

12. Now we will need to copy the keys required to clone our private repo(s). On ghost, navigate to the .ssh directory and secure copy the appropriate public and private key set(s) to grief.

    on ghost:
    ```bash
    $ cd ~/.ssh
    $ ls
    id_maya id_maya.pub ...
    $ scp id_manu* ta@0.0.0.0:.ssh/
    $ scp id_maya* ta@0.0.0.0:.ssh/
    ```

13. Next you need to temporarily configure ssh to use ours keys when connecting to gitlab.com
This is temporary because we'll need to delete this file when we rebuild nixos using our flake. Otherwise home-manager will complain that the file is in its way. On grief:

    ```config
    ~/.ssh/config
    -----------------------
    Host gitlab.com
        IdentitiesOnly yes
        IdentityFile ~/.ssh/id_maya
        IdentityFile ~/.ssh/id_manu
    Host github.com
        IdentitiesOnly yes
        IdentityFile ~/.ssh/id_maya
        IdentityFile ~/.ssh/id_manu
    ```

14. Clone the `nix-config` repo.

    ```bash
    $ mkdir ~/src
    $ cd ~/src
    $ git clone git@gitlab.com:emergentmind/nix-config.git
    Cloning into 'nix-config'...
    The authenticity of host 'gitlab.com' can't be established.
    ED25519 key fingerprint is SHA256:000000000000000000000000000000000000000000
    This key is not known by any other names.
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added 'gitlab.com' (ED25519) to the list of known hosts.
    Confirm user presence for key ECDSA-SK SHA256:000000000000000000000000000000000000000000
    sign_and_send_pubkey: signing failed for ECDSA-SK "/home/ta/.ssh/id_maya": device not found
    Enter passphrase for key '/home/ta/.ssh/id_manu': 
    remote: Enumerating objects: 1238, done.
    remote: Counting objects: 100% (111/111), done.
    remote: Compressing objects: 100% (19/19), done.
    remote: Total 1238 (delta 97), reused 92 (delta 92), pack-reused 1127
    Receiving objects: 100% (1238/1238), 252.02 KiB | 1.37 MiB/s, done.
    Resolving deltas: 100% (502/502), done.
    ```

15. Clone the `nix-secrets` repo. Normally we wouldn't do this because it is a flake input for nix-config, however in this case we need to recreate `secrets.yaml` in both locations until we refactor.

    ```bash
    $ git clone git@gitlab.com:emergentmind/nix-secrets.git
    Cloning into 'nix-secrets'...
    Confirm user presence for key ECDSA-SK SHA256:000000000000000000000000000000000000000000 
    sign_and_send_pubkey: signing failed for ECDSA-SK "/home/ta/.ssh/id_maya": device not found
    Enter passphrase for key '/home/ta/.ssh/id_manu': 
    remote: Enumerating objects: 16, done.
    remote: Counting objects: 100% (16/16), done.
    remote: Compressing objects: 100% (15/15), done.
    remote: Total 16 (delta 4), reused 0 (delta 0), pack-reused 0
    Receiving objects: 100% (16/16), 9.68 KiB | 9.68 MiB/s, done.
    Resolving deltas: 100% (4/4), done.
    ```

16. We'll need to use the hardware-configuration.nix that was generated for this vm during the nixos-rebuild we did in earlier. Copy it to the hosts directory of the nix-config repo

    ```bash
    $ cd nix-config
    $ cp /etc/nixos/hardware-configuration.nix hosts/grief/
    ```

17. Add git user info so that the changes can be successfully committed and pushed

    ```bash
    $ git config --global user.name "emergentmind"
    $ git config --global user.email "2889621-emergentmind@users.noreply.gitlab.com"
    ```

18. Commit the new hardware config

    ```bash
    $ git commit -a -m "add vm hardware config for grief"
    [dev a34ef60] add vm hardware config for grief
    1 file changed, 6 insertions(+), 14 deletions(-)
    ```

19. Push the changes with `git push`
20. Rename the .ssh/config so it doesn't conflict with our flake config
    `mv ~/.ssh/config ~/.ssh/config.bkp`
21. Copy our ta/dev user age key to grief.
    On ghost:

    ```bash
    $ scp ~/.config/sops/age/keys.txt ta@0.0.0.0:.config/sops/age/
    (ta@0.0.0.0) Password: 
    keys.txt  
    ```

22. Next we'll generate age keys for grief based on its ssh host keys (these would have been auto-created when enabling ssh earlier on)

    ```bash
    $ nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    this path will be fetched (0.94 MiB download, 2.70 MiB unpacked):
    /nix/store/j1nbcdrr1xqc6swycq0c361sxrpm54fy-ssh-to-age-1.1.3
    copying path '/nix/store/j1nbcdrr1xqc6swycq0c361sxrpm54fy-ssh-to-age-1.1.3' from 'https://cache.nixos.org'...
    age10000000000000000000000000000000000000000000000000000
    ```

    Add the age key to .sops.yaml. Since we're in a recovery state, we'll do this on the .sops.yaml for both repos (nix-config and nix-secrets) since we'll eventually be reducing it down to one.

    ```bash
    $ nvim src/nix-config/.sops.yaml

    .sops.yaml

    ---------
    # pub keys
    keys:
    - &users:
        - &ta age10000000000000000000000000000000000000000000000000000 #primate age key
    - &hosts: # nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
        - &grief age0000000000000000000000000000000000000000000000000000 

    creation_rules:
        #path should be relative to location of this file (.sops.yaml)
    - path_regex: hosts/common/secrets.yaml$
        key_groups:
        - age:
        - *ta
        - *grief

    ---------

    $ cp src/nix-config/.sops.yaml src/nix-secrets
    ```

23. Now we're ready to recreate `secrets.yaml` using sops
    Note: something was up with the EDITOR environment variable wanting xterm kitty so first I ran
    `export EDITOR=nvim` then i deleted the old, inaccessilbe copy of secrets.yaml from nix-config using `rm ~/src/nix-config/hosts/common/secrets.yaml`

    ```bash
    $ cd ~/src/nix-config
    $ sops hosts/common/secrets.yaml
    
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
    
24. Copy the new `secrets.yaml` from `nix-config` to `nix-secrets`
25. Commit and push the changes to nix-config.

    ```bash
    $ cd ~/src/nix-config
    $ git commmit -a -m "updated sops files"
    [dev 157d414] updated sops files
    2 files changed, 24 insertions(+), 23 deletions(-)
    $ git push
    Enter passphrase for key '/home/ta/.ssh/id_manu': 
    Enumerating objects: 11, done.
    Counting objects: 100% (11/11), done.
    Delta compression using up to 4 threads
    Compressing objects: 100% (6/6), done.
    Writing objects: 100% (6/6), 4.01 KiB | 4.01 MiB/s, done.
    Total 6 (delta 3), reused 0 (delta 0), pack-reused 0
    To gitlab.com:emergentmind/nix-config.git
    c0c9ef2..157d414  dev -> dev
    ```

26. Now we should be able to `sudo nixos-rebuild switch --flake .#grief`
    If all went well we can also switch to our home-manager config
    `home-manager switch --flake .#ta@grief`

27. On successful rebuild `rm ~/.ssh/config.bkp`



## First Install - November 29, 2023

Installing on Asus mini-pc. This will replicate functionality of Gusto, which is a simple theatre box with browser and vlc, and is currently running on a Raspberry Pi 4. The project will start a lightweight foundation for building out a multi-host, multi-hardware configuration and doftile repo.

### Install a minimal image via flashed USB device

https://nixos.org/manual/nixos/stable/#sec-installation-booting

Follow graphical installation steps until first reboot.

1. set up basic password until ssh is set up
2. no desktop (define later in the flake)
3. select allow unfree
4. use swap w/hibernate for devices with <8GB RAM
5. perform install and reboot
6. once you're at the terminal (no desktop installed ;) )

    ```bash
    cd /etc/nixos
    sudoedit configuration.nix
    ```

7. edit the the following:
   1. hostname
   2. under "environment.systempackages" uncomment or enable the following packages:
      - vim
      - git
   3. uncomment `services. openssh.enable = true`
   4. at the end of the file at the following entry:
      `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
   5. save and exit the file
8. `sudo nixos-rebuild switch` to rebuild the system according to the configuration
9. now that the host system is configured for ssh switch over to your main box
10. add your public key as an authorized_key to the nix host `ssh-copy-id -i ~/.ssh/manual_ed25519.pub [user]@[ip-address]` enter the basic password defined during install
11. in order to push and pull from the nix-config git repo you'll need your private and public id_ed25519 files present on the new host. Copy them over using the following command. You may need to modify it according to the number of keys you have of that type.
   `scp .ssh/manual_ed* <user>@<ip>:.ssh/`
12. connect to the nix host `ssh <user>@<ip>` to the nix host using the passphrase for your pub key
13. `passwd <user>` to change the basic install password to something more secure
14. verify that the .ssh keys you copied over have the appropriate permissions

   ```bash
   $ ls ~/.ssh
   -rw------- 1 ta ta  444 Dec 1  2020 manual_ed25519
   -rw-r--r-- 1 ta ta   95 Dec 1  2020 manual_ed25519.pub
   ```

15. Next you need to configure ssh to use the key when connecting to gitlab.com

   ```config
   ~/.ssh/config
   -----------------------
    Host gitlab.com
        IdentitiesOnly yes
        IdentityFile ~/.ssh/manual_ed25519
   ```

16. Now we'll grab our nix-config flake from the repo
17. `mkdir -p src` to create the location for our flakes
18. `cd src`
19. clone the repo `git clone git@gitlab.com:emergentmind/nix-config.git`
20. We'll need to use the hardware-configuration.nix that was generated for this system during the nixos-rebuild we did in step 2. copy it to the hosts directory of the repo
21. `cd nix-config/`
22. `mkdir hosts/<hostname>`
23. `cp /etc/nixos/hardware-configuration.nix ./hosts/<hostname>` to copy the file to the correct location in the nix-config
24. we'll also need a basic host config that points to the hardware config:

    ```bash
    cat > "hosts/<hostname>/<hostname>.nix" << EOF
    {
        imports = [
            ./hardware-configuration.nix
        ];
        #----Host specific config ----
    }
    EOF
    ```

25. Now the host is ready and we can rebuild the system according to the flake
26. `sudo nixos-rebuild switch --flake .#<hostname>` to rebuild the configuration using the flake
27. Add git user info so that the changes can be successfully committed and pushed

    ```bash
    $ git config --global user.name "emergentmind"
    $ git config --global user.email "2889621-emergentmind@users.noreply.gitlab.com"

    ```

28. now we'll add the lock and and hosts hardware file to the repo

    ```bash
    $ git add .
    $ git commit -m "message"
    $ git push
    ```

    Once the rebuild completes it's time to start customizing the flake, step by step.

---
[Return to top](#install-notes)

[README](../README.md) > Install Notes