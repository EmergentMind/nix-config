{ pkgs, configVars, ... }:
{
  programs.fish = {
    enable = true;

    # relative to ~
    dotDir = ".config/fish";
    enableCompletion = true;

    plugins = [
      {
        name = "fisher";
        src = "${pkgs.fisher}/bin/fisher";
      }
      {
        name = "bobthefish";
        src = "https://github.com/oh-my-fish/theme-bobthefish";
      }
      {
        name = "z";
        src = "https://github.com/jethrokuan/z";
      }
      {
        name = "fzf";
        src = "https://github.com/jethrokuan/fzf";
      }
    ];

    # Additional configurations and initializations
    initExtra = ''
      # Set Fish history settings
      set -g fish_history_size 10000
      set -g fish_hybrid_history yes

      # Enable syntax highlighting and autosuggestions
      source (dirname (status --current-filename))/completions.fish
    '';

    shellAliases = {
      # Custom commands
      cat = "bat";
      diff = "batdiff";
      rg = "batgrep";
      man = "batman";

      # Navigation shortcuts
      doc = "cd $HOME/documents";
      scripts = "cd $HOME/scripts";
      ts = "cd $HOME/.talon/user/fidget";
      src = "cd $HOME/src";
      dfs = "cd $HOME/src/dotfiles";

      # Neovim aliases
      e = "nvim";
      vi = "nvim";
      vim = "nvim";

      # Nix related commands
      nfc = "nix flake check";
      ne = "nix instantiate --eval";
      nb = "nix build";
      ns = "nix shell";
    };
  };
}
