# Backup

This module provides a service and options for automating the backup of host data using borg. It assumes that a borg server has been configured, either locally or remotely.

## Requirements

- msmtp for email notifications
- A borg server. In the following example, we'll be using a borg server installed on a remote host but a local borg server can also be used.

## Setup

1. First we'll need to create a passphrase that will secure the BORG_KEY that gets generated for our borg repo in  later steps. To do so, create and save a passphrase in your preferred password vault such as Proton Pass.
2. Now we'll need a way for our backup module on the host to provide the passphrase to the borg server when it runs. To do this we'll add the pasphrase to our `nix-secrets/secrets.yaml` using sops and extract it on to the host at the location the module expects to find it.
3. Add the passphrase to `nix-secrets/secrets.yaml` using sops. For example, run `sops path/to/nix-secrets/secrets.yaml`

```diff

nix-secrets/secrets.yaml

--------------------

passwords:
    username: <data>
+   borg: <BORG_KEY PASSPHRASE>

...

```

Commit and push your nix-secrets changes.
4. Now we'll ensure that the secret is extracted on our host during rebuild.

```diff

hosts/common/core/sops.nix

--------------------

  ...

  secrets = {
+    # borg password required by nix-config/modules/hosts/nixos/backup
+    "passwords/borg" = {
+      owner = "root";
+      group = if pkgs.stdenv.isLinux then "root" else "wheel";
+      mode = "0600";
+      path = "/etc/borg/passphrase";
+    };

    ...

   };

  ...

```
In the example above, we provide the path to the BORG_KEY passphrase in our nix-secrets and specify that it should be extracted to "/etc/borg/passphrase", which is where the backup module will look for it.

4. With our passphrase set up , we'll do some prep work on the borg server. Depending on how you set up the borg server, this step may not be necessary.

Depending how you configure the borg server, user's home locations may not be in the typical `/home/<user>` or `/Users/<user>` location.

    1. Log in to the server and run `pwd` to print the working directory of the user's home.

    For example:

    ```bash
    $ ssh <borgserver>
    Confirm user presence for key
    User presence confirmed

    ta@<borgserver>:~$ pwd
    /var/services/homes/ta
    ```

    2. Create a directory where you want to store the backup repositories for each of the hosts you'll be enabling backup for on this server.

    ```bash
    $ mkdir backups
    ```

    Note the full path to the directory you created as we'll be providing it to one of the backup module's options in the next step. In this example the full path on the server is `/var/services/homes/ta/backups`.

5. In nix-config, enable the backup module for the host that will be backed up. For example:

```nix

nix-config/hosts/nixos/ghost/default.nix

--------------------

...

  services.backup = {
    enable = true;
    borgBackupStartTime = "02:00:00";
    borgServer = "${config.hostSpec.networking.subnets.oops.ip}";
    borgUser = "${config.hostSpec.username}";
    borgPort = "${builtins.toString config.hostSpec.networking.subnets.oops.port}";
    borgBackupPath = "/var/services/homes/${config.hostSpec.username}/backups";
    borgNotifyFrom = "${config.hostSpec.email.notifier}";
    borgNotifyTo = "${config.hostSpec.email.backup}";
  };

...

```

In the above snippet, we enable the backup module and declare specific optional values the module will use to access the server. Note that the `borgBackupPath` option above specifies a non-standard path to the user's home.

6. Rebuild nix-config, and then run `sudo borg-backup-init`. This will create a borg repository for the host, on the borg server and generate a BORG_KEY using our previously provided passphrase. In our example, when the module has been enabled our host called `ghost`, running the command will create a borg repository on the borg server at `/var/services/homes/ta/backups/ghost`.

7. This step is optional. Log back into the server if needed, and run `borg key export backups/<hostname>`. Follow any prompts. This will print the BORG_KEY that borg generated for the repository. The key itself will be is stored on the server with the repo; we are exporting it for future reference. Copy the BORG_KEY data to a secure location such as Proton Pass.
8. Rebuild nix-config and update inputs so that the nix-secrets changes are pulled in. With nix-config we can do this by running `just rebuild-update`.
9. To test that email notification is working correctly, run `borg-backup-test-email` and then check your email inbox for an email from your msmtp notifier to whichever address you configure.
10. To specify which files or directories should be excluded from backup, refer to [Exclude Lists](#Exclude Lists) below.

## Exclude Lists

Exclude lists are purposefully kept in external files so that it's easier to integrate additions based on other repos.

See [this repo](https://github.com/SterlingHooten/borg-backup-exclusions-macos) for where the backup exclude lists originated from.

NOTE: Folders containing a .nobackup file will not be backed up!

There are three Exclude Lists:

- `borg-exclude-common.lst` provides a place to exclude files or directories that are common across Linux and Darwin
- `borg-exclude-linux-core.lst` provides a place to exclude files or directories that are exclusive to Linux
- `borg-exclude-macos-core.lst` provides a place to exclude files or directories that are exclusive to Darwin

See the comments in each .lst file for instructions on how to add to them.
