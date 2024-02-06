{ pkgs, config, ... }:
{
  gtk = {
    enable = true;
    #font.name =  TODO see misterio https://github.com/Misterio77/nix-config/blob/f4368087b0fd0bf4a41bdbf8c0d7292309436bb0/home/misterio/features/desktop/common/gtk.nix   he has a custom config for managing fonts, colorsheme etc.
    theme.name = "adw-gtk3";
    theme.package = pkgs.adw-gtk3;
    #TODO add ascendancy cursor pack
    #cursortTheme.name = "";
    #cursortTheme.package = ;
    #iconTheme.name = "";
    #iconTheme.package = ;
  };
}
