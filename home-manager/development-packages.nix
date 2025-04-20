{ pkgs, config, ... }:

# let

#   pkgsUnstable = import <nixpkgs-unstable> {};

# in

{
  home.packages = with pkgs; [
    android-tools
    # apkeditor
    # android-studio
    # android-file-transfer
    # android-backup-extractor
    # git
    # gh
    meld
    nodejs
    pnpm
    # sublime4
    # (import <nixpkgs-unstable> {}).vscode

    # python packages
    python3
    # (python3.withPackages(ps: with ps; [
    #     # python-lsp-server
    #     # pandas 
    #     # numpy # numerical computing library
    #     # matplotlib # plotting library
    #     pip
    #     # seaborn # data visualization library
    #     tkinter 
    #     pyusb
    #     # vtk 
    #     # pmw 
    # ]))
    # tk
    # tcl
  ];

  programs.git = {
    enable = true;
    userName = "Luiz Salazar";
    userEmail = "luizsalazar87@gmail.com";
    aliases = {
      # ap = "add -p";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      pull = {
        ff = "only";
      };
    };
        ignores = [
      # ---> VisualStudioCode
      ".vscode/*"
      "!.vscode/settings.json"
      "!.vscode/tasks.json"
      "!.vscode/launch.json"
      "!.vscode/extensions.json"
      "*.code-workspace"

      # Local History for Visual Studio Code"
      ".history/"

      # ---> Vim"
      # Swap"
      "[._]*.s[a-v][a-z]"
      "!*.svg  # comment out if you don't need vector files"
      "[._]*.sw[a-p]"
      "[._]s[a-rt-v][a-z]"
      "[._]ss[a-gi-z]"
      "[._]sw[a-p]"

      # Session"
      "Session.vim"
      "Sessionx.vim"

      # Temporary"
      ".netrwhist"
      "*~"
      # Auto-generated tag files"
      "tags"
      # Persistent undo"
      "[._]*.un~"

      # ignore pycache"
      "__pycache__/"

      # nix
      "*.egg-info"
      "*.py[cod]"
      "*.spec"
      "*.swp"
      "*venv/"
      "*~"
      ".DS_Store"
      "build"
      "dist"
      "result"

    ];
  };
  # raw files
  #home.file.".config/git/hooks".source = ./hooks;
  # home.shellAliases = {
  #   git-clean = ''
  #     echo "removing merged local branches";
  #     git fetch --all -p;
  #     git branch --merged origin/master | grep -v "\*" | xargs git branch -d;
  #     git branch -vv | grep -v '\[origin/'| grep -v "\*" | awk '{ print $1; }' | xargs -r git branch -D;
  #   '';
  # };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
    ];
    # userSettings = {
    #   "security.workspace.trust.enabled" = false;
    #   "explorer.confirmDelete" = false;
    # };
  };

  # nixpkgs.overlays = [
  #   (self: super: {
  #     vscode = pkgsUnstable.vscode;
  #   })
  # ];

}
