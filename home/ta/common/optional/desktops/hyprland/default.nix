{pkgs, ...} : {
  imports = [
    ./binds.nix

    #./waybar.nix #infobar
    #./rofi-wayland.nix #app launcher
    #./dunst.nix #notification daemon
    #./swww.nix #wallpaper daemon
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];

    settings = {
      general = {
        gaps_in = 8;
        gaps_out = 5;
        border_size = 3;
        cursor_inactive_timeout = 4;
      };
      input = {
        kb_layout = "us";
        #mouse = {
          #acceleration = 1.0;
          #naturalScroll = true;
        #};
      };
      decoration = {
        active_opacity = 0.94;
        inactive_opacity = 0.75;
        fullscreen_opacity = 1.0;
        #rounding = 7;
        blur = {
          enabled = false;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
        drop_shadow = false;
        shadow_range = 12;
        shadow_offset = "3 3";
        "col.shadow" = "0x44000000";
        "col.shadow_inactive" = "0x66000000";
      };
    };
    # load at the end of the hyperland set
    extraConfig = ''
    '';
  };


#TODO move below into individual .nix files with their own configs
  home.packages = builtins.attrValues {
    inherit (pkgs)
    # Notifcation daemon
    libnotify # required by dunst
    dunst
    #mako

    # bar
    waybar  # closest thing to polybar available
            # where is polybar? not supported yet: https://github.com/polybar/polybar/issues/414
    #eww # alternative - complex at first but can do cool shit apparently

    # Wallpaper daemon
    #hyprpaper
    #swaybg
    #wpaperd
    #mpvpaper
    #swww #vimjoyer recoomended
    #nitrogen

    # app launcher
    rofi-wayland;
    #wofi #gtk rofi
   
     # qt support
#    qt5-wayland
    #qt6-wayland;

  };
}