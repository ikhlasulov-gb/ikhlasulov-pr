{ config, pkgs, osConfig, ... }:
{
  imports = [
    ./plasma.nix
  ];

  home.stateVersion = "25.11";

  programs.bash = {
    enable = true;

    shellAliases = {
      alexey = "llama-cli -m /var/lib/ai/alexey.gguf";
    };
  };

  home.packages = with pkgs; [
    qbittorrent
    llama-cpp
    polkit
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
    gimp
    pdfarranger
    steam
    gnome-boxes
    motrix
    steam-run
    labwc
    kitty
    telegram-desktop
    prismlauncher
  ];

  programs.kitty.enable = true;

  home.sessionVariables = {
    XKB_DEFAULT_MODEL = "pc105";
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:alt_shift_toggle";
  };

  xdg.configFile = {
    "labwc/autostart".text = ''
      ${pkgs.kitty}/bin/kitty --start-as=fullscreen &
    '';

    "labwc/environment".text = ''
      XKB_DEFAULT_MODEL=pc105
      XKB_DEFAULT_LAYOUT=us,ru
      XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle
    '';

    "labwc/rc.xml".text = ''
      <?xml version="1.0"?>
      <labwc_config>
        <windowRules>
          <windowRule identifier="*" serverDecoration="no"/>
        </windowRules>
      </labwc_config>
    '';
  };
}
