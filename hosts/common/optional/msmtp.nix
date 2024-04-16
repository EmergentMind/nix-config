{ config, configVars, ... }:
{
  sops.secrets = {
    "msmtp-password" = {
      owner = config.users.users.${configVars.username}.name;
      inherit (config.users.users.${configVars.username}) group;
    };
    "msmtp-host" = {
      owner = config.users.users.${configVars.username}.name;
      inherit (config.users.users.${configVars.username}) group;
    };
    "msmtp-address" = {
      owner = config.users.users.${configVars.username}.name;
      inherit (config.users.users.${configVars.username}) group;
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
