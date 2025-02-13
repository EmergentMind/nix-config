{
  pkgs,
  ...
}:

{
  gtk = {
    enable = true;
    iconTheme = {
      name = "elementary-Xfce-dark";
      package = pkgs.elementary-xfce-icon-theme;
    };
    #TODO add ascendancy cursor pack
    #cursortTheme.name = "";
    #cursortTheme.package = ;
    #    theme = {
    #      name = "adwaita-dark";
    #      package = pkgs.adw-gtk3;
    #    };
    #    gtk3.extraConfig = {
    #      Settings = ''
    #        gtk-application-prefer-dark-theme=1
    #      '';
    #    };
    #    gtk4.extraConfig = {
    #      Settings = ''
    #        gtk-application-prefer-dark-theme=1
    #      '';
    #    };
  };
}
