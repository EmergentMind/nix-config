{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--no-default-browser-check"
      "--restore-last-sesion"
    ];
  };
}
