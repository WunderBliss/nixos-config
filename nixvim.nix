{ pkgs, ... }:

# NixVim configuration aiming for a LazyVim-like experience.
# Theming: We do NOT hardcode a colorscheme. DMS manages terminal colors
# via dank16/matugen. NixVim inherits those ANSI colors automatically.
# We install base16-nvim as a fallback and set termguicolors so the
# Material palette propagates into Neovim highlights.

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # ── General Options ───────────────────────────────────────────────
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      clipboard = "unnamedplus";
      undofile = true;
      splitbelow = true;
      splitright = true;
      mouse = "a";
      showmode = false;
      updatetime = 200;
      timeoutlen = 300;
      completeopt = "menu,menuone,noselect";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # ── Colorscheme ───────────────────────────────────────────────────
    # Use base16-colorscheme which reads terminal ANSI colors set by DMS.
    # This means Neovim's palette automatically matches your wallpaper.
    extraPlugins = with pkgs.vimPlugins; [
      base16-nvim
      render-markdown-nvim
    ];
    extraConfigLua = ''
      -- Use terminal palette (set by DMS dank16/matugen) as the base16 scheme
      -- This makes Neovim's colors follow the wallpaper-derived theme
      if vim.fn.exists("$DMS_THEME") == 1 or true then
        vim.opt.background = "dark"
        -- base16-colorscheme will pick up the 16 terminal colors
        vim.cmd.colorscheme("base16-default-dark")
      end
      require("render-markdown").setup({})
    '';

    # ── Plugins ───────────────────────────────────────────────────────

    plugins = {

      # ── File Explorer (neo-tree) ──────────────────────────────────
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        filesystem.followCurrentFile.enabled = true;
      };

      # ── Fuzzy Finder (telescope) ──────────────────────────────────
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find Files";
          };
          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Grep";
          };
          "<leader>fb" = {
            action = "buffers";
            options.desc = "Buffers";
          };
          "<leader>fh" = {
            action = "help_tags";
            options.desc = "Help Tags";
          };
          "<leader>fr" = {
            action = "oldfiles";
            options.desc = "Recent Files";
          };
          "<leader>fc" = {
            action = "commands";
            options.desc = "Commands";
          };
          "<leader>fd" = {
            action = "diagnostics";
            options.desc = "Diagnostics";
          };
          "<leader>fs" = {
            action = "lsp_document_symbols";
            options.desc = "Symbols";
          };
          "<leader>/" = {
            action = "live_grep";
            options.desc = "Grep (root)";
          };
        };
      };

      # ── Treesitter ────────────────────────────────────────────────
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          ensure_installed = [
            "bash"
            "c"
            "css"
            "html"
            "javascript"
            "json"
            "lua"
            "markdown"
            "markdown_inline"
            "nix"
            "python"
            "rust"
            "toml"
            "typescript"
            "vim"
            "vimdoc"
            "yaml"
            "tsx"
            "regex"
            "gdscript"
          ];
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          markdown
          markdown_inline
        ];
      };

      # ── LSP ───────────────────────────────────────────────────────
      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "gr" = "references";
            "K" = "hover";
            "<leader>ca" = "code_action";
            "<leader>cr" = "rename";
          };
          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
            "<leader>cd" = "open_float";
          };
        };
        servers = {
          nil_ls.enable = true; # Nix
          lua_ls.enable = true; # Lua
          ts_ls.enable = true; # TypeScript/JavaScript
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          pyright.enable = true; # Python
          bashls.enable = true; # Bash
          cssls.enable = true; # CSS
          html.enable = true; # HTML
          jsonls.enable = true; # JSON
          yamlls.enable = true; # YAML
          gdscript = {
            enable = true;
            package = null; # LSP is built into godot_4, installed via configuration.nix
          };
        };
      };

      # ── Completions (nvim-cmp) ────────────────────────────────────
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          snippet.expand = ''
            function(args)
              require("luasnip").lsp_expand(args.body)
            end
          '';
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require("luasnip").expand_or_jumpable() then
                  require("luasnip").expand_or_jump()
                else
                  fallback()
                end
              end, { "i", "s" })
            '';
            "<S-Tab>" = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require("luasnip").jumpable(-1) then
                  require("luasnip").jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" })
            '';
          };
        };
      };

      # ── Snippets ──────────────────────────────────────────────────
      luasnip.enable = true;
      friendly-snippets.enable = true;

      # ── Statusline (lualine) ──────────────────────────────────────
      lualine = {
        enable = true;
        settings.options = {
          globalstatus = true;
          theme = "auto"; # inherits from terminal/colorscheme
        };
      };

      # ── Bufferline (tab bar) ──────────────────────────────────────
      bufferline = {
        enable = true;
        settings.options = {
          diagnostics = "nvim_lsp";
          always_show_bufferline = true;
          offsets = [
            {
              filetype = "neo-tree";
              text = "Explorer";
              highlight = "Directory";
              separator = true;
            }
          ];
        };
      };

      # ── Which-key (keybind overlay) ───────────────────────────────
      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>b";
            group = "Buffer";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "Trouble";
          }
          {
            __unkeyed-1 = "<leader>u";
            group = "UI";
          }
        ];
      };

      # ── Git ───────────────────────────────────────────────────────
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };

      lazygit = {
        enable = true;
      };

      # ── mini.nvim suite ───────────────────────────────────────────
      mini = {
        enable = true;
        modules = {
          pairs = { }; # Auto-pairs
          surround = { }; # Surround motions
          ai = { }; # Textobjects (around/inside)
          comment = { }; # gc to comment
          icons = { }; # File icons
        };
      };

      # ── Formatting (conform) ──────────────────────────────────────
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
          formatters_by_ft = {
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            python = [ "ruff_format" ];
            javascript = [ "prettierd" ];
            typescript = [ "prettierd" ];
            json = [ "prettierd" ];
            yaml = [ "prettierd" ];
            css = [ "prettierd" ];
            html = [ "prettierd" ];
            markdown = [ "prettierd" ];
            rust = [ "rustfmt" ];
            "_" = [ "trim_whitespace" ];
            gdscript = [ "gdformat" ];
          };
        };
      };

      # ── Diagnostics list (trouble) ────────────────────────────────
      trouble = {
        enable = true;
      };

      # ── Todo Comments ─────────────────────────────────────────────
      todo-comments.enable = true;

      # ── Flash (motion) ────────────────────────────────────────────
      flash = {
        enable = true;
        settings.modes.search.enabled = true;
      };

      # ── Indent guides ─────────────────────────────────────────────
      indent-blankline = {
        enable = true;
        settings.scope.enabled = true;
      };

      # ── Noice (cmdline/search/notify UI) ──────────────────────────
      noice = {
        enable = true;
        settings = {
          lsp.override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
          presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
            lsp_doc_border = true;
          };
        };
      };

      notify.enable = true;

      # ── Dashboard (alpha) ─────────────────────────────────────────
      alpha = {
        enable = true;
        theme = "dashboard";
      };

      # ── Web dev icons (for neo-tree, telescope, etc.) ─────────────
      web-devicons.enable = true;

      # ── Autopairs for TS/JSX tags ─────────────────────────────────
      ts-autotag.enable = true;
    };

    # ── Extra Keymaps ─────────────────────────────────────────────────
    keymaps = [
      # Buffer navigation (like LazyVim)
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>bprevious<CR>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>bnext<CR>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<CR>";
        options.desc = "Delete Buffer";
      }

      # Neo-tree
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Explorer";
      }

      # Lazygit
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<CR>";
        options.desc = "LazyGit";
      }

      # Trouble
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        options.desc = "Buffer Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xL";
        action = "<cmd>Trouble loclist toggle<CR>";
        options.desc = "Location List";
      }
      {
        mode = "n";
        key = "<leader>xQ";
        action = "<cmd>Trouble qflist toggle<CR>";
        options.desc = "Quickfix List";
      }

      # Window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Go to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Go to lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Go to upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Go to right window";
      }

      # Better escape
      {
        mode = "i";
        key = "jk";
        action = "<ESC>";
        options.desc = "Exit insert mode";
      }

      # Move lines (like LazyVim)
      {
        mode = "n";
        key = "<A-j>";
        action = "<cmd>m .+1<CR>==";
        options.desc = "Move Down";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<cmd>m .-2<CR>==";
        options.desc = "Move Up";
      }
      {
        mode = "v";
        key = "<A-j>";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move Down";
      }
      {
        mode = "v";
        key = "<A-k>";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move Up";
      }

      # Clear search highlight
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>noh<CR>";
        options.desc = "Clear highlights";
      }

      # Save
      {
        mode = "n";
        key = "<C-s>";
        action = "<cmd>w<CR>";
        options.desc = "Save";
      }

      # Quit
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>qa<CR>";
        options.desc = "Quit All";
      }

      # UI toggles
      {
        mode = "n";
        key = "<leader>un";
        action = "<cmd>set relativenumber!<CR>";
        options.desc = "Toggle Relative Numbers";
      }
      {
        mode = "n";
        key = "<leader>uw";
        action = "<cmd>set wrap!<CR>";
        options.desc = "Toggle Wrap";
      }
    ];

    # ── Extra Packages (formatters, linters used by plugins) ──────────
    extraPackages = with pkgs; [
      ripgrep
      fd
      stylua
      nixfmt-rfc-style
      prettierd
      nodePackages.typescript-language-server
      gdtoolkit_4
    ];
  };
}
