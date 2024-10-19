# Backup

This module provides a service and options for automating the backup of host data using borg. It assumes that a borg server has been configured, either locally or remotely.

## Requirements

- msmtp for email notifications
- A borg server. In the following example, we'll be using a borg server installed on a remote host but a local borg server can also be used.

## Setup

FIXME add steps for:
    - add and enable backup module?
    - configuring the borg server itself

1. Depending on how you configure the borg server, user's home locations may not be in the typical `/home/<user>` or `/Users/<user>` location.

Log in to the server and run `pwd` to print the working directory of the user's home.

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

3. In nix-config, enable the backup module for the host that will be backedup. For example:

```nix

nix-config/hosts/ghost/default.nix

--------------------

...

  services.backup = {
    enable = true;
    borgBackupStartTime = "02:00:00";
    borgServer = "${configVars.networking.subnets.oops.ip}";
    borgUser = "${configVars.username}";
    borgPort = "${builtins.toString configVars.networking.subnets.oops.port}";
    borgBackupPath = "/var/services/homes/${configVars.username}/backups";
    borgNotifyFrom = "${configVars.email.notifier}";
    borgNotifyTo = "${configVars.email.backup}";
  };

...

```

In the above snippet, we enable the backup module and declare specific optional values the module will use to access the server. Note that the `borgBackupPath` option above specifies a non-standard path to the user's home.
1. Rebuild nix-config, and then run `sudo borg-backup-init`. This will create a borg repository for the host, on the borg server. In our example, when the module has been enabled our host called `ghost`, running the command will create a borg repository on the borg server at `/var/services/homes/ta/backups/ghost`.

With the initialization complete, we'll go back to the borg server to get the encryption key that borg generated and assign a passphrase.

2. Log back into the server if needed, and run `borg key export backups/<hostname>`. This will print the BORG_KEY that borg generate for the repository. The key itself will be is stored on the server with the repo. We are exporting it for future reference.
3. Copy the BORG_KEY data to a secure location such as Proton Pass.
4. We need to secure the BORG_KEY with a passphrase. To do so, run `borg key change-passphrase backups/<hostname>` and follow the prompts.
5. Copy the BORG_KEY passphrase to a secure location for reference.

Now we'll need a way for our backup module on the host to provide the passphrase to the borg server when it runs. To do this we'll add the pasphrase to our `nix-secrets/secrets.yaml` using sops and extract it on to the host at the location the module expects to find it.
6. Add the passphrase to `nix-secrets/secrets.yaml` using sops. For example, run `sops path/to/nix-secrets/secrets.yaml`

```diff

nix-secrets/secrets.yaml

--------------------

passwords:
    username: <data>
+   borg: <BORG_KEY PASSPHRASE>

...

```

Commit and push your nix-secrets changes.
7. Now we'll ensure that the secret is extracted on our host during rebuild.

```diff

hosts/common/core/sops.nix

--------------------

  ...

  secrets = {
+    # borg password required by nix-config/modules/nixos/backup
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

8. Rebuild nix-config and update inputs so that the nix-secrets changes get pulled in. With nix-config we can do this by running `just rebuild-update`.
9. To test that email notification is working correctly, run `borg-backup-test-email` and then check your email inbox for an email from your msmtp notifier to whichever address you configure.
10. To specify which files or directories should be excluded from backup, refer to [Exclude Lists](#Exclude Lists) below.

## Exclude Lists

Exclude lists are purposefully kept in external files so that it's easier to integrate additions based on other repos.

See [this repo](https://github.com/SterlingHooten/borg-backup-exclusions-macos) for where the backup exclude lists originated from.

NOTE: Folders containing a .nobackup file will not be backed up!

There are three Exclude Lists:

- `borg-exclude-common.lst` provides a place to exclude files or directories that are common across Linux, Darwin,  and MacOS
- `borg-exclude-linux-core.lst` provides a place to exclude files or directories that are exclusive to Linux and Darwin
- `borg-exclude-macos-core.lst` provides a place to exclude files or directories that are exclusive to MacOS

See the comments in each .lst file for instructions on how to add to them.
