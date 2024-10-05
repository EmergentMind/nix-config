# git interface for nvim
# https://github.com/NeogitOrg/neogit
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.neogit.enable = lib.mkEnableOption "enables neogit module";
  };

  config = lib.mkIf config.nixvim-config.plugins.neogit.enable {
    programs.nixvim = {
      plugins.neogit = {
        enable = true;
        #disableBuiltinNotifications = true;
      };
      keymaps = [
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>Neogit<CR>";
        }
      ];
    };
  };
}
