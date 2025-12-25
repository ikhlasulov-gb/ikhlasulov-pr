{ config, pkgs, ... }:

{
  # imports
  imports = [
    ./hardware-configuration.nix
  ];

  # system.stateVersion
  system.stateVersion = "25.11"; # Version

  # nix.settings.experimental-features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # boot
  boot = {
    # boot.loader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

  # kernelPackages
    kernelPackages = pkgs.linuxPackages_latest;

  # kernelModules
    kernelModules = [ "kvm-amd" ]; # AMD

  # initrd
    initrd = {
      # initrd.luks.devices."luks-f69f8097-e1ac-4741-b04c-370a100a1263".device
      luks.devices."luks-f69f8097-e1ac-4741-b04c-370a100a1263".device =
        "/dev/disk/by-uuid/f69f8097-e1ac-4741-b04c-370a100a1263"; # UUID
      systemd.enable = true;
      verbose = false;
    };

    # initrd.plymouth
    plymouth = {
      enable = true;
      theme = "spinner";
    };
    # initrd.consoleLogLevel
    consoleLogLevel = 3;

    # initrd.kernelParams
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  # networking
  networking = {
    hostName = "ikhlasulov-pr";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # hardware.bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    # hardware.bluetooth.settings
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = false;
      };
    };
  };

  # time.timeZone
  time.timeZone = "Asia/Jakarta";

  # i18n.defaultLocale
  i18n.defaultLocale = "ru_RU.UTF-8";

  # users.users
  users.users = {
    # users.users.ikhlasulov
    ikhlasulov = {
      isNormalUser = true;
      description = "Ихлас Викулов";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
      shell = pkgs.bash;
    };

    # users.users.ikhlasulov-dt
    ikhlasulov-dt = {
      isNormalUser = true;
      description = "Ихлас Викулов";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
      shell = pkgs.bash;
    };
  };

  # security
  security = {
    # security.sudo
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      configFile = ''
        Defaults rootpw
        Defaults timestamp_timeout=0
      '';
    };

    # security.polkit
    polkit = {
      enable = true;
      adminIdentities = [ ];
    };

    # security.rtkit.enable
    rtkit.enable = true;

    # security.apparmor.enable
    apparmor.enable = true;
  };

  # programs
  programs = {
    # programs.labwc.enable
    labwc.enable = true;

    # programs.steam
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # programs.firefox.enable
    firefox.enable = true;

    # programs.gamemode.enable
    gamemode.enable = true;

    # programs.virt-manager.enable
    virt-manager.enable = true;

    # programs.bash
    bash = {
      enable = true;

      # programs.bash.shellAliases
      shellAliases = {
        alexey = "llama-cli -m /var/lib/ai/alexey.gguf";
      };
    };
  };

  # fonts.packages
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    winePackages.fonts
    corefonts
  ];

  # environment.systemPackages
  environment.systemPackages = with pkgs; [
    wineWowPackages.stagingFull
    dxvk
    vkd3d-proton
    qbittorrent
    llama-cpp
    polkit
    git
    kdePackages.kate
    (python3.withPackages (ps: with ps; [ pygame-ce ]))
    kdePackages.kcalc
    kdePackages.isoimagewriter
    kdePackages.ghostwriter
    zapzap
    qview
    curtail
    textcompare
    kdePackages.kdenlive
    onlyoffice-desktopeditors
    vlc
    prismlauncher
    gimp
    pdfarranger
    steam
    motrix
    steam-run
    smartmontools
    kdePackages.partitionmanager
    exfatprogs
    peazip
    sedutil
    ntfs3g
    wget
    labwc
    kitty
    telegram-desktop
  ];

  # environment.etc
  environment.etc = {
    "xdg/labwc/autostart".text = ''
      /run/current-system/sw/bin/kitty --start-as=fullscreen &
    '';

    "xdg/labwc/environment".text = ''
      XKB_DEFAULT_MODEL=pc105
      XKB_DEFAULT_LAYOUT=us,ru
      XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle
    '';

    "xdg/labwc/rc.xml".text = ''
      <?xml version="1.0"?>
      <labwc_config>
        <windowRules>
          <windowRule identifier="*" serverDecoration="no"/>
        </windowRules>
      </labwc_config>
    '';
  };

  # services
  services = {
    # services.fail2ban.enable
    fail2ban.enable = true;

    # services.displayManager.sddm
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings.Users.HideUsers = "ikhlasulov";
    };

    # services.desktopManager.plasma6.enable
    desktopManager.plasma6.enable = true;

    # services.pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

    # services.pipewire.extraConfig
      extraConfig = {
        pipewire."99-custom-quantum.conf" = {
          "context.properties" = {
            "default.clock.min-quantum" = 1024;
            "default.clock.max-quantum" = 8192;
          };
        };

        pipewire-pulse."99-custom-quantum.conf" = {
          "context.properties" = {
            "pulse.min.quantum" = "1024/48000";
            "pulse.default.quantum" = "1024/48000";
            "pulse.max.quantum" = "8192/48000";
          };
        };
      };
    };
  };

  # virtualisation.libvirtd
  virtualisation.libvirtd = {
    enable = true;

    # virtualisation.libvirtd.qemu
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  # systemd.tmpfiles.rules
  systemd.tmpfiles.rules = [
    "d /srv/shared 01777 root root - -"
    "L /home/ikhlasulov/Совместные - - - - /srv/shared"
    "L /home/ikhlasulov-dt/Совместные - - - - /srv/shared"
  ];
}
