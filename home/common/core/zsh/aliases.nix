{ config, ... }:
let
  devDirectory = "$HOME/src";
  devNix = "${devDirectory}/nix";
in
{
  # Overrides those provided by OMZ libs, plugins, and themes.
  # For a full list of active aliases, run `alias`.

  whichreal = ''function _whichreal(){ (alias "$1" >/dev/null 2>&1 && (alias "$1" | sed "s/.*=.\(.*\).../\1/" | xargs which)) || which "$1"; }; _whichreal'';

  #-------------Bat related------------
  cat = "bat --paging=never";
  diff = "batdiff";
  man = "batman";
  less = "bat --style=plain";
  rg = "batgrep";
  #rg = "rg -M300";

  #------------Navigation------------
  c = "clear";
  rst = "reset";
  doc = "cd $HOME/doc";
  edu = "cd $HOME/edu";
  wiki = "cd $HOME/sync/obsidian-vault-01/wiki";
  l = "eza -lah";
  la = "eza -lah";
  ldt = "eza -TD"; # list directory tree
  ll = "eza -lh";
  ls = "eza";
  lsa = "eza -lah";
  tree = "eza -T";
  ".h" = "cd ~"; # Because I find pressing ~ tedious"
  cdr = "cd-gitroot";
  ".r" = "cd-gitroot";
  cdpr = "..; cd-gitroot";
  "..r" = "..; cd-gitroot";

  #------------compression------------
  unzip = "7z x";

  #------------ src navigation------------
  src = "cd ${devDirectory}";
  cnc = "cd ${devNix}/nix-config";
  cns = "cd ${devNix}/nix-secrets";
  cnh = "cd ${devNix}/nixos-hardware";
  cnp = "cd ${devNix}/nixpkgs";
  cin = "cd ${devNix}/introdus";
  cab = "cd ${devDirectory}/abbot-wiki";
  cuc = "cd ${devDirectory}/unmoved-centre";

  #-----------Nix commands----------------
  nfc = "nix flake check";
  ne = "nix instantiate --eval";
  nb = "nix build";
  ns = "nix shell";

  # prevent accidental killing of single characters
  pkill = "pkill -x";

  #-------------direnv---------------
  da = "direnv allow";
  dr = "direnv reload";

  #-------------justfiles---------------
  jr = "just rebuild";
  jrup = "just rebuild-update";
  jrt = "just rebuild-trace";
  jl = "just --list";
  jup = "just update";
  jug = "just upgrade";
  jb = "just build-host";

  #-------------Neovim---------------
  e = "nvim";
  vi = "nvim";
  vim = "nvim";

  #-------------journalctl---------------
  jc = "journalctl";
  jcu = "journalctl --user";

  #-------------SSH---------------
  ssh = "TERM=xterm ssh";
  pinghosts = "nmap -sP ${config.hostSpec.networking.subnets.grove.cidr}";
  scanhostson10022 = "sudo nmap -sS ${config.hostSpec.networking.subnets.grove.cidr} -p ${toString config.hostSpec.networking.ports.tcp.ssh}";

  #-------------rmtrash---------------
  # Path to real rm and rmdir in coreutils. This is so we can not use rmtrash for big files
  rrm = "/run/current-system/sw/bin/rm";
  rrmdir = "/run/current-system/sw/bin/rmdir";
  rm = "rmtrash";
  rmdir = "rmdirtrash";

  #-------------Git Goodness-------------
  gcm = "git commit -m";
  gcmcf = "git commit -m 'chore: update flake.lock'";
  gca = "git commit --amend";
  gcan = "git commit --amend --no-edit";
  gcam = "git commit --amend -m";

  # We use source because we want it to use other aliases, which allow yubikey signing over ssh
  gsr = "git_smart_rebase";
  grst = "git reset --soft ";

  gr = "git restore";
  gra = "git restore :/";
  grs = "git restore --staged";
  grsa = "git restore --staged :/";

  ga = "git add";
  # "git add again" - Re-add changes for anything that was already staged. Useful for pre-commit changes, etc
  gaa = "git update-index --again";
  gau = "git add --update";

  # Only add updates to files that are already staged
  gas = "git add --update $(git diff --name-only --cached)";
  gs = "git status --untracked-files=no";
  gsa = "git status";
  gst = "git stash";
  gstp = "git stash pop";
  gsw = "git switch";
  gswc = "git switch -c";
  gco = "git checkout";
  gf = "git fetch";
  gfa = "git fetch --all";
  gfu = "git fetch upstream";
  gfm = "git fetch origin master";
  gds = "git diff --staged";
  gd = "git diff";
  gp = "git push";
  gpf = "git push --force-with-lease";
  gl = "git log";
  gc = "git clone";

}
