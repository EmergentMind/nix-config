{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--no-default-browser-check"
      "--restore-last-session"
    ];
  };
}
