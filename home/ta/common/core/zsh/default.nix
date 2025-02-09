{
  config,
  pkgs,
  lib,
  ...
}:
let
  devDirectory = "~/src";
  devNix = "${devDirectory}/nix";
in
{
  programs.zsh = {
    enable = true;

    # relative to ~
    dotDir = ".config/zsh";
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    autosuggestion.enable = true;
    history.size = 10000;
    history.share = true;

    plugins =
      [
        {
          name = "powerlevel10k-config";
          src = ./p10k;
          file = "p10k.zsh.theme";
        }
        {
          name = "zsh-powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
      ]
      # The iso doesn't use our overlays, so don't add custom packagesa
      #FIXME:move these to an optional custom plugins module and remove iso check
      ++ lib.optionals (config.hostSpec.hostName != "iso") [
        {
          name = "zsh-term-title";
          src = "${pkgs.zsh-term-title}/share/zsh/zsh-term-title/";
        }
        {
          name = "cd-gitroot";
          src = "${pkgs.cd-gitroot}/share/zsh/cd-gitroot";
        }
        {
          name = "zhooks";
          src = "${pkgs.zhooks}/share/zsh/zhooks";
        }
      ];

    initExtraFirst = ''
      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    initExtra = ''
      # autoSuggestions config

      unsetopt correct # autocorrect commands

      setopt hist_ignore_all_dups # remove older duplicate entries from history
      setopt hist_reduce_blanks # remove superfluous blanks from history items
      setopt inc_append_history # save history entries as soon as they are entered

      # auto complete options
      setopt auto_list # automatically list choices on ambiguous completion
      setopt auto_menu # automatically use menu completion
      zstyle ':completion:*' menu select # select completions with arrow keys
      zstyle ':completion:*' group-name "" # group results by category
      zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

      #      bindkey '^I' forward-word         # tab
      #      bindkey '^[[Z' backward-word      # shift+tab
      #      bindkey '^ ' autosuggest-accept   # ctrl+space
    '';

    oh-my-zsh = {
      enable = true;
      # Standard OMZ plugins pre-installed to $ZSH/plugins/
      # Custom OMZ plugins are added to $ZSH_CUSTOM/plugins/
      # Enabling too many plugins will slowdown shell startup
      plugins = [
        "git"
        "sudo" # press Esc twice to get the previous command prefixed with sudo https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo
      ];
      extraConfig = ''
        # Display red dots whilst waiting for completion.
        COMPLETION_WAITING_DOTS="true"
      '';
    };

    shellAliases = {
      # Overrides those provided by OMZ libs, plugins, and themes.
      # For a full list of active aliases, run `alias`.

      #-------------Bat related------------
      cat = "bat --paging=never";
      diff = "batdiff";
      rg = "batgrep";
      man = "batman";

      #------------Navigation------------
      doc = "cd $HOME/documents";
      scripts = "cd $HOME/scripts";
      ts = "cd $HOME/.talon/user/fidget";
      src = "cd $HOME/src";
      edu = "cd $HOME/src/edu";
      wiki = "cd $HOME/sync/obsidian-vault-01/wiki";
      uc = "cd $HOME/src/unmoved-centre";
      l = "eza -lah";
      la = "eza -lah";
      ll = "eza -lh";
      ls = "eza";
      lsa = "eza -lah";

      #------------Nix src navigation------------
      cnc = "cd ${devNix}/nix-config";
      cns = "cd ${devNix}/nix-secrets";
      cnh = "cd ${devNix}/nixos-hardware";
      cnp = "cd ${devNix}/nixpkgs";

      #-----------Nix commands----------------
      nfc = "nix flake check";
      ne = "nix instantiate --eval";
      nb = "nix build";
      ns = "nix shell";

      #-------------justfiles---------------
      jr = "just rebuild";
      jrt = "just rebuild-trace";
      jl = "just --list";
      jc = "$just check";
      jct = "$just check-trace";

      #-------------Neovim---------------
      e = "nvim";
      vi = "nvim";
      vim = "nvim";

      #-------------SSH---------------
      ssh = "TERM=xterm ssh";

      #-------------Git Goodness-------------
      # just reference `$ alias` and use the defaults, they're good.
    };
  };
}
