#TODO Break this out into smaller files similar to https://github.com/shard77/nix-config-personal/tree/14e94914cada6f388b050771b40dce4b6eefd49a/temp/home-manager/utils/nixvim

# Some fantastic inspiration for this config
# https://seniormars.com/posts/neovim-workflow/

{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./plugins
    ./colorschemes.nix
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true; # install man pages for nixvim options

    clipboard.register = "unnamedplus"; # use system clipboard instead of internal registers

    opts = {
      # # Lua reference:
      # vim.o behaves like :set
      # vim.go behaves like :setglobal
      # vim.bo for buffer-scoped options
      # vim.wo for window-scoped options (can be double indexed)

      #
      # ========= General Appearance =========
      #
      hidden = true; # Makes vim act like all other editors, buffers can exist in the background without being in a window. http://items.sjbach.com/319/configuring-vim-right
      number = true; # show line numbers
      relativenumber = true; # show relative linenumbers
      laststatus = 0; # Display status line always
      history = 1000; # Store lots of :cmdline history
      showcmd = true; # Show incomplete cmds down the bottom
      showmode = true; # Show current mode down the bottom
      autoread = true; # Reload files changed outside vim
      lazyredraw = true; # Redraw only when needed
      showmatch = true; # highlight matching braces
      ruler = true; # show current line and column
      visualbell = true; # No sounds

      listchars = "trail:·"; # Display tabs and trailing spaces visually

      wrap = false; # Don't wrap lines
      linebreak = true; # Wrap lines at convenient points

      # ========= Font =========
      guifont = "NotoSansMono:h9"; # fontname:fontsize

      # ========= Cursor =========
      guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,n-v-i:blinkon0";

      # ========= Redirect Temp Files =========
      # backup
      backupdir = "$HOME/.vim/backup//,/tmp//,.";
      writebackup = false;
      # swap
      directory = "$HOME/.vim/swap//,/tmp//,.";

      # ================ Indentation ======================
      autoindent = true;
      cindent = true; # automatically indent braces
      smartindent = true;
      smarttab = true;
      shiftwidth = 4;
      softtabstop = 4;
      tabstop = 4;
      expandtab = true;

      # ================ Folds ============================
      foldmethod = "indent"; # fold based on indent
      foldnestmax = 3; # deepest fold is 3 levels
      foldenable = false; # don't fold by default

      # ================ Splits ============================
      splitbelow = true;
      splitright = true;

      # ================ Completion =======================
      wildmode = "list:longest,list:full"; # for tab completion in : command mode
      wildmenu = true; # enable ctrl-n and ctrl-p to scroll thru matches
      # stuff to ignore when tab completing
      wildignore = "*.o,*.obj,*~,vim/backups,sass-cache,DS_Store,vendor/rails/**,vendor/cache/**,*.gem,log/**,tmp/**,*.png,*.jpg,*.gif";

      # ================ Scrolling ========================
      scrolloff = 4; # Start scrolling when we're 4 lines away from margins
      sidescrolloff = 15;
      sidescroll = 1;

      # ================ Search and Replace ========================
      incsearch = true; # searches incrementally as you type instead of after 'enter'
      hlsearch = true; # highlight search results
      ignorecase = true; # search case insensitive
      smartcase = true; # search matters if capital letter
      inccommand = "split"; # preview incremental substitutions in a split

      # ================ Movement ========================
      backspace = "indent,eol,start"; # allow backspace in insert mode
    };

    # Load Plugins that aren't provided as modules by nixvim
    extraPlugins = builtins.attrValues {
      inherit (pkgs.vimPlugins)
        # linting and fixing (config in extraConfigVim below)
        #   https://github.com/dense-analysis/ale
        #   TODO: nixvim: revamp setup to lua
        #   there is also a lightline-ale  plugin/extension for lightline when you get around to it
        #   by default ALE completion is disabled. need to determine if it's worth enabling and ditching youcompleteme ... it likely is for simplicity!
        ale

        vim-illuminate # Highlight similar words as are under the cursor
        vim-numbertoggle # Use relative number on focused buffer only
        range-highlight-nvim # Highlight range as specified in commandline e.g. :10,15
        vimade # Dim unfocused buffers
        vim-twiggy # Fugitive plugin to add branch control
        vimwiki # Vim Wiki
        YouCompleteMe # Code completion engine

        # TODO: nixvim: make sure this is working and not conflicting with YCM
        # supertab # Use <tab> for insert completion needs - https://github.com/ervandew/supertab/

        # Keep vim-devicons as last entry
        vim-devicons
        ;
    };

    # ========= Mapleader =========
    globals.mapleader = ";";

    # ========= Key binds =========
    #
    # MODES Key:
    #    "n" Normal mode
    #    "i" Insert mode
    #    "v" Visual and Select mode
    #    "s" Select mode
    #    "t" Terminal mode
    #    ""  Normal, visual, select and operator-pending mode
    #    "x" Visual mode only, without select
    #    "o" Operator-pending mode
    #    "!" Insert and command-line mode
    #    "l" Insert, command-line and lang-arg mode
    #    "c" Command-line mode
    keymaps = [
      # TODO: nixvim: Test sudo save
      # {
      #   # sudo save
      #   mode= ["c"];
      #   key = "w!!";
      #   action = "<cmd>w !sudo tee > /dev/null %<CR>";
      # }
      {
        mode = [ "n" ];
        key = "<Leader>ve";
        action = "<cmd>e ~/nix-config/home/ta/common/core/nixvim/default.nix<CR>";
        options = {
          desc = "Edit nix-config/home/ta/common/core/nixvim/default.nix";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<Leader>vr";
        action = "<cmd>so $MYVIMRC<CR>";
        options = {
          desc = "Reload vimrc";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<space><space>";
        action = "<cmd>nohlsearch<CR>";
        options = {
          desc = "Clear search highlighting";
          noremap = true;
        };
      }

      # ======== Movement ========
      {
        mode = [ "n" ];
        key = "j";
        action = "gj";
        options = {
          desc = "Move down through wrapped lines";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "k";
        action = "gk";
        options = {
          desc = "Move up through wrapped lines";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<C-j>";
        action = "<C-d>";
        options = {
          desc = "Add bind for 1/2 page down";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<C-k>";
        action = "<C-u>";
        options = {
          desc = "Add bind for 1/2 page up";
          noremap = true;
        };
      }
      #      {
      #        mode = [ "n" ];
      #        key = "E";
      #        action = "$";
      #        options = {
      #          desc = "Add bind for move to end of line";
      #          noremap = true;
      #        };
      #      }
      # {
      #   # disable default move to beginning/end of line
      #   mode = ["n"];
      #   key = "$";
      #   action = "<nop>";
      # }

      # =========== Editing =========
      {
        mode = [ "n" ];
        key = "<Leader>sr";
        action = ":%s/<C-r><C-w>//g<Left><Left>";
        options = {
          desc = "Substitute the word you are currently on";
          noremap = true;
        };
      }
      # =========== Undo and Redo =========
      {
        mode = [ "n" ];
        key = "<Leader>u";
        action = ":UndotreeToggle<cr>";
        options = {
          desc = "Toggle undotree"; # see undotree plugin
          noremap = true;
        };
      }
      {
        mode = [ "i" ];
        key = ",";
        action = ",<C-g>U";
        options = {
          desc = "Update undo when , operator is used in Insert mode";
          noremap = true;
        };
      }
      {
        mode = [ "i" ];
        key = ".";
        action = ".<C-g>U";
        options = {
          desc = "Update undo when . operator is used in Insert mode";
          noremap = true;
        };
      }
      {
        mode = [ "i" ];
        key = "!";
        action = "!<C-g>U";
        options = {
          desc = "Update undo when ! operator is used in Insert mode";
          noremap = true;
        };
      }
      {
        mode = [ "i" ];
        key = "?";
        action = "?<C-g>U";
        options = {
          desc = "Update undo when ? operator is used in Insert mode";
          noremap = true;
        };
      }
      # =========== Fugitive Plugin =========
      {
        mode = [ "n" ];
        key = "<Leader>gs";
        action = "<cmd>G<CR>";
        options = {
          desc = "quick git status";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<Leader>gj";
        action = "<cmd>diffget //3<CR>";
        options = {
          desc = "quick merge command: take from right page (tab 3) upstream";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<Leader>gf";
        action = "<cmd>diffget //2<CR>";
        options = {
          desc = "quick merge command: take from left page (tab 2) head";
          noremap = true;
        };
      }

      # ========== Telescope Plugin =========
      {
        mode = [ "n" ];
        key = "<Leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options = {
          desc = "find files";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<Leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options = {
          desc = "live grep";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<Leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options = {
          desc = "buffers";
          noremap = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<Leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options = {
          desc = "help tags";
          noremap = true;
        };
      }

      # ========= Twiggy =============
      {
        mode = [ "n" ];
        key = "<Leader>tw";
        action = ":Twiggy<CR>";
        options = {
          desc = "toggle display twiggy";
          noremap = true;
        };
      }
    ];
    extraConfigVim = ''
           " ================ Persistent Undo ==================
           " Keep undo history across sessions, by storing in file.
           " Only works all the time.
           if has('persistent_undo')
               silent !mkdir ~/.vim/backups > /dev/null 2>&1
               set undodir=~/.vim/backups
               set undofile
           endif

           " ================ Vim Wiki config =================
           " See :h vimwiki_list for info on registering wiki paths
           let wiki_0 = {}
           let wiki_0.path = '~/src/dotfiles.wiki/'
           let wiki_0.index = '0_home'
           let wiki_0.syntax = 'markdown'
           let wiki_0.ext = '.md'

           " fill spaces in page names with _ in pathing
       let wiki_0.links_space_char = '_'

           " TODO: nixvim: CONFIRM THESE PATHS FOR NIXOS
           let wiki_1 = {}
           let wiki_1.path = '~/doc/foundry/thefoundry.wiki/'
           let wiki_1.index = 'home'
           let wiki_1.syntax = 'markdown'

           let wiki_1.ext = '.md'
           " fill spaces in page names with _ in pathing
           let wiki_1.links_space_char = '_'

           let g:vimwiki_list = [wiki_0, wiki_1]
           " let g:vimwiki_list = [wiki_0, wiki_1, wiki_2]

           " ================ Ale ========================
      "     let g:ale_linters = {
      "                 \ 'c': ['clang-tidy'],
      "                 \ 'python': ['flake8'],
      "                 \ 'vim': ['vint'],
      "                 \ 'markdown': ['markdownlint'],
      "     \ }

      "     let g:ale_fixers = {
      "           \ 'c': ['clang-format'],
      "           \ 'javascript': ['prettier', 'eslint'],
      "           \ 'json': ['fixjson', 'prettier'],
      "           \ 'python': ['black', 'isort'],

      "           \ }

      "     " Set global fixers for all file types except Markdown
      "     " Why? because double spaces at the end of a line in markdown indicate a
      "     " linebreak without creating a new paragraph
      "     function! SetGlobalFixers()
      "       let g:ale_fixers['*'] = ['trim_whitespace', 'remove_trailing_lines']
      "     endfunction

      "     augroup GlobalFixers
      "       autocmd!
      "       autocmd VimEnter * call SetGlobalFixers()
      "     augroup END

      "     " Set buffer-local fixers for Markdown files
      "     augroup MarkdownFixers
      "       autocmd!
      "       autocmd FileType markdown let b:ale_fixers = ['prettier']
      "     augroup END

      "     let g:ale_fix_on_save = 1
    '';

    # extraConfigLua = ''
    # -- ========= Colorscheme Overrides ==========
    # -- Override cursor color and blink for nav and visual mode
    # vim.cmd("highlight Cursor guifg=black guibg=orange");
    #
    # -- Override cursor color for insert mode
    # vim.cmd("highlight iCursor guifg=black guibg=orange");
    # '';
  };
}
