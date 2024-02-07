{
  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "ta";
  };
  services.xserver.xkb.layout = "us";
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.enableScreensaver = false;
}