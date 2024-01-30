{ config, ... }:
{
  sops.secrets = {
    "msmtp-password" = {
      owner = config.users.users.ta.name;
      inherit (config.users.users.ta) group;
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true; # set the system sendmail to msmtp's
    
    accounts = {
      "default" = {
        host = "smtp.protonmail.ch";
        port = 587;
        auth = true;
        tls = true;
        tls_starttls = true;
        from = "notifier@hexagon.cx";
        user = "notifier@hexagon.cx";
        passwordeval = "cat ${config.sops.secrets."msmtp-password".path}";
        logfile = "~/.msmtp.log";
      };
    };
  };
}
