# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, meta, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  networking = {
    hostName = meta.hostname; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ 80 ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "Africa/Addis_Ababa";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };
  security = {
    sudo.configFile = ''
    rekcah ALL=(ALL) NOPASSWD: ALL
    '';
  };

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = /var/lib/rancher/k3s/server/token;
    extraFlags = toString ([
      "--write-kubeconfig-mode \"0644\""
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
    ] ++ (if meta.hostname == "master0" then [] else [
        "--server https://master0:6443"
      ]));
    clusterInit = (meta.hostname == "master0");
  };
  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };
  services.openssh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rekcah = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    # Created using mkpasswd
    hashedPassword = "$y$j9T$Wgf9H5M/.GSp5yT95mfMX/$lba.zkukcaO8JGZxnxFFi/D5dTOvi55YCLRZIvLtBr8";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjKOWhQH1fDcs58zEBpIXNZZxkDkVXBcsq1sliJAnngFKuLwFYUH4FX+Pc62bDMEEvAhdiM+81Si8yYUAp1QpZd5/e5g5ahslcSTXmthG+GwvWc9YQlvOCAVgaJF0k6pGQhbQYMpNL/0vGeynO5S9/fphtXTeOQZ1MfEIcwWjULQSWTnvgWilfV9YHDS61Y42BIvFKvzjBS1u8yIsEapvahLLjCljs5R/8gMVY0u3TeJ7J54q0h2B+ZURxnbzbJCD+9Ppm49jy9aaOzUvd6Mj2+l71w+A9JYn7uyvlI2t44b7W+qqiT40aVo8bM/Ljs1+VV86UVqcgn5VMuLQ1bhp3dXNlYy3R6v6X1zYdKLWWGkYfGHhZcytO1XOf66QyAJibuf1MvouZmCQqq//F4Nd9F2qJk+lsgffpVUAShPI94dVetoETehGXk4IiqKkTN5+1Rfq0YZlMVU+g3tUyEO7BbJlgVm4Gnxtz9Ib20Pt3P3pg3BeNM4wSwG0jSdBVB04ToKRnh3NM+plw8Ujcb32EubmHmY8bAcon1PLw6OytHzGGo3kLVW3elZISTpMZTHA8Nh4zn5laehlQcKJ3w3/yyiErq+PnxwB/SXC1ohmlgl/oTH2UaUSIBRXDJ00Vu8SB3JG3n6xCPd3z6kJ4ut54MjNvwitB31b2o2D//ub0aQ== booba@003ee1ccdfc5"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    htop
    helm
    helmfile
    lazygit
    lazydocker
    lynx
    neovim
    tmux
    k3s
    cifs-utils
    nfs-utils
    git
    gh
    sing-box
  ];

  programs.git = {
    enable = true;
    config = {
      user.name = "philingood";
      user.email = "98781376+philingood@users.noreply.github.com";
    };
  };
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      bufferline.enable = true;
      oil.enable = true;
      neoscroll.enable = true;
      treesitter.enable = true;
      web-devicons.enable = true;
      nvim-autopairs.enable = true;
      lazygit.enable = true;
      commentary.enable = true;
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };
      which-key = {
        enable = false;
      };
      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
          };
        };
      };
      nix.enable = true;
      none-ls = {
        enable = true;
        settings = {
          cmd = ["bash -c nvim"];
          debug = true;
        };
        sources = {
          code_actions = {
            statix.enable = true;
            gitsigns.enable = true;
          };
          diagnostics = {
            statix.enable = true;
            deadnix.enable = true;
            checkstyle.enable = true;
          };
          formatting = {
            alejandra.enable = true;
            stylua.enable = true;
            shfmt.enable = true;
            nixpkgs_fmt.enable = true;
          };
          completion = {
            luasnip.enable = true;
            spell.enable = true;
          };
        };
      };
      lint = {
        enable = true;
        lintersByFt = {
          text = ["vale"];
          json = ["jsonlint"];
          markdown = ["vale"];
          dockerfile = ["hadolint"];
        };
      };
      lsp = {
        enable = true;
        servers = {
          marksman.enable = true; # Markdown
          nil_ls.enable = true; # Nix
          dockerls.enable = true; # Docker
          bashls.enable = true; # Bash
          yamlls.enable = true; # YAML
          lua_ls = { # Lua
            enable = true;
            settings.telemetry.enable = false;
          };
        };
      };
      cmp = {
        enable = true;
        settings = {
          completion = {
            completeopt = "menu,menuone,noinsert";
          };
          autoEnableSources = true;
          experimental = { ghost_text = true; };
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 30;
          };
          snippet = { 
            expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
            '';
          };
          formatting = { fields = [ "kind" "abbr" "menu" ]; };
          sources = [
            { name = "nvim_lsp"; }
            {
              name = "buffer"; # text within current buffer
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              keywordLength = 3;
            }
            # { name = "copilot"; } # enable/disable copilot
            {
              name = "path"; # file system paths
              keywordLength = 3;
            }
          ];
          window = {
            completion = { border = "solid"; };
            documentation = { border = "solid"; };
          };
          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-e>" = "cmp.mapping.abort()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
            "<C-l>" = ''
            cmp.mapping(function()
              if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              end
            end, { 'i', 's' })
            '';
            "<C-h>" = ''
            cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { 'i', 's' })
            '';
          };
        };
      };
      cmp-nvim-lsp.enable = true; # LSP
      cmp-buffer.enable = true;
      cmp-path.enable = true; # file system paths
      cmp_luasnip.enable = true; # snippets
      cmp-cmdline.enable = true; # autocomplete for cmdline
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
