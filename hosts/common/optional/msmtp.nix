{ config, ... }:
{
  sops.secrets = {
    "msmtp-password" = {
      owner = config.users.users.ta.name;
      inherit (config.users.users.ta) group;
    };
    "msmtp-host" = {
      owner = config.users.users.ta.name;
      inherit (config.users.users.ta) group;
    };
    "msmtp-address" = {
      owner = config.users.users.ta.name;
      inherit (config.users.users.ta) group;
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true; # set the system sendmail to msmtp's

    accounts = {
      "default" = {
        host = "cat ${config.sops.secrets."msmtp-host".path}";
        port = 587;
        auth = true;
        tls = true;
        tls_starttls = true;
        from = "cat ${config.sops.secrets."msmtp-address".path}";
        user = "cat ${config.sops.secrets."msmtp-address".path}";
        passwordeval = "cat ${config.sops.secrets."msmtp-password".path}";
        logfile = "~/.msmtp.log";
      };
    };
  };
}
