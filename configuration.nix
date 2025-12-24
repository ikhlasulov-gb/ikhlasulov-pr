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
    kernelModules = [ "kvm-amd" ]; # AMD [ "kvm-amd" ]; Intel [ "kvm-intel" ]

    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    initrd = {
      luks.devices."luks-f69f8097-e1ac-4741-b04c-370a100a1263".device =
        "/dev/disk/by-uuid/f69f8097-e1ac-4741-b04c-370a100a1263"; # UUID
      systemd.enable = true;
      verbose = false;
    };

    plymouth = {
      enable = true;
      theme = "spinner";
    };
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
    virt-manager.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    firefox.enable = true;
    gamemode.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    winePackages.fonts
    corefonts
  ];

  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [ pygame-ce ]))
    curtail
    dxvk
    exfatprogs
    gimp
    git
    kdePackages.ghostwriter
    kdePackages.isoimagewriter
    kdePackages.kdenlive
    kdePackages.kcalc
    kdePackages.kate
    kdePackages.partitionmanager
    kitty
    labwc
    llama-cpp
    motrix
    ntfs3g
    onlyoffice-desktopeditors
    pdfarranger
    peazip
    prismlauncher
    qbittorrent
    qview
    sedutil
    smartmontools
    steam
    steam-run
    telegram-desktop
    textcompare
    vlc
    vkd3d-proton
    wget
    wineWowPackages.stagingFull
    zapzap
  ];

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
