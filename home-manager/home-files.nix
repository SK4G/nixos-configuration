{ config, pkgs, ... }:

{
  programs = {
    kitty = {
      enable = true;
      settings = {
        background_opacity = "0.8";
        confirm_os_window_close = "0";
        cursor_shape = "beam";
        enable_audio_bell = "no";
        enabled_layouts = "grid,vertical";
        hide_window_decorations = "no";
        update_check_interval = "0";
        copy_on_select = "no";
        wayland_titlebar_color = "background";
        include = "current-theme.conf";
      };
      font.name = "JetBrainsMono Nerd Font";
      font.size = 10;
      themeFile = "Tomorrow_Night";        
    };

    mangohud = {
      enable = true;
      # Mangohud config
      settings = {
        output_folder = "~/.config/MangoHud/";
        horizontal = true;
        hud_no_margin = true;
        font_size = 25;
        table_columns = 25;
        background_alpha = 0.5;
        gpu_stats = true;
        gpu_temp = true;
        cpu_stats = true;
        cpu_temp = true;
        ram = true;
        vram = true;
        fps = true;
        frame_timing = true;
        frametime = false;
        toggle_hud = "Shift_R+F12";
        version = false;
        vulkan_driver = false;
        text_outline = true;
        text_outline_thickness = 2;
        resolution = false;
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # ".screenlayout/monitor.sh".text = ''
    #   #!/usr/bin/env bash
    #   xrandr --output eDP --mode 800x1280 --pos 1080x1440 --rotate right \
    #   --output DisplayPort-0 --primary --mode 3440x1440 --pos 0x0 --rotate normal
    # '';
    ".config/kitty/current-theme.conf".text = ''
      background #1d1f21
      foreground #c4c8c5
      cursor #c8c8c8
      selection_background #666666
      color0 #3f3f3f
      color8 #545454
      color1 #cc0000
      color9 #fc5454
      color2 #4e9a06
      color10 #8ae234
      color3 #c4a000
      color11 #fce94f
      color4 #80a1bd
      color12 #94bff3
      color5 #85678f
      color13 #b294bb
      color6 #8abdb6
      color14 #93e0e3
      color7 #dcdccc
      color15 #ffffff
      selection_foreground #F9F9F9
    '';
  };
}
