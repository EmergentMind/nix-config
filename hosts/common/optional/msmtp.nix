{ config, configVars, ... }:
{
  sops.secrets = {
    "msmtp-password" = {
      owner = config.users.users.${configVars.username}.name;
      inherit (config.users.users.${configVars.username}) group;
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true; # set the system sendmail to msmtp's

    accounts = {
      "default" = {
        host = "${configVars.email.msmtp-host}";
        port = 587;
        auth = true;
        tls = true;
        tls_starttls = true;
        from = "${configVars.email.notifier}";
        user = "${configVars.email.notifier}";
        passwordeval = "cat ${config.sops.secrets."msmtp-password".path}";
        logfile = "~/.msmtp.log";
      };
    };
  };
}
