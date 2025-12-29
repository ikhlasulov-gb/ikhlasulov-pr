{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ "kvm-amd" ];

    initrd = {
      luks.devices."luks-f69f8097-e1ac-4741-b04c-370a100a1263".device =
        "/dev/disk/by-uuid/f69f8097-e1ac-4741-b04c-370a100a1263";
      systemd.enable = true;
      verbose = false;
    };

    plymouth = {
      enable = true;
      theme = "spinner";
    };

    consoleLogLevel = 3;

    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  networking = {
    hostName = "ikhlasulov-pr";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

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

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "ru_RU.UTF-8";

  users.users = {
    ikhlasulov = {
      isNormalUser = true;
      description = "Ихлас Викулов";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
      shell = pkgs.bash;
    };

    ikhlasulov-dt = {
      isNormalUser = true;
      description = "Ихлас Викулов";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
      shell = pkgs.bash;
    };
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      configFile = ''
        Defaults rootpw
        Defaults timestamp_timeout=0
      '';
    };

    polkit = {
      enable = true;
      adminIdentities = [ ];
    };

    rtkit.enable = true;

    apparmor.enable = true;
  };

  programs = {
    labwc.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    firefox.enable = true;

    gamemode.enable = true;

    virt-manager.enable = true;

    bash = {
      enable = true;

      shellAliases = {
        alexey = "llama-cli -m /var/lib/ai/alexey.gguf";
      };
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    winePackages.fonts
    corefonts
  ];

  environment.systemPackages = with pkgs; [
    wineWowPackages.stagingFull
    dxvk
    vkd3d-proton
    qbittorrent
    llama-cpp
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

  services = {
    fail2ban.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings.Users.HideUsers = "ikhlasulov";
    };

    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

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

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/shared 01777 root root - -"
    "L /home/ikhlasulov/Совместные - - - - /srv/shared"
    "L /home/ikhlasulov-dt/Совместные - - - - /srv/shared"
  ];
}
