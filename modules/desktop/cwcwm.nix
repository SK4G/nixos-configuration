{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  git,
  wayland-protocols,
  cairo,
  hyprcursor,
  libdrm,
  libinput,
  libxcb,
  libxkbcommon,
  lua,
  luajit,
  makeWrapper,
  wayland,
  wayland-scanner,
  python3,
  wlroots,
  xxHash,
  xcbutilwm,
  xcbutilxrm,
  gobject-introspection,
  gdk-pixbuf,
  pango,
  glib,
  libstartup_notification,
  wrapGAppsHook,
  swaybg,
  waybar,
  playerctl,
  swayidle,
  aria2,
  gtk3Support ? false,
  gtk3 ? null,
  librsvg,
  dbus,
  libpthreadstubs,
  libxdg_basedir,
  net-tools,
  xcb-util-cursor,
}:

# needed for beautiful.gtk to work
assert gtk3Support -> gtk3 != null;

let
  luaEnv = luajit.withPackages (ps: [
    ps.lgi
  ]);

  commonDeps = [
    gtk3
    gdk-pixbuf
    pango
    glib
    libstartup_notification
  ] ++ lib.optional gtk3Support gtk3;
in

stdenv.mkDerivation rec {
  pname = "cwcwm";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Cudiph";
    repo = pname;
    rev = "v${version}";
    sha256 = "2pIoxiBxFTm/UzcQNE4AiZVkIFv6FDLv1DsfzPtHUpo=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    wayland-protocols
    wayland-scanner
    makeWrapper
    wrapGAppsHook
    gobject-introspection
  ];

  buildInputs = [
    cairo
    git
    hyprcursor
    libdrm
    libinput
    libxcb
    libxkbcommon
    luaEnv
    wayland
    wlroots
    xxHash
    xcbutilwm
    xcbutilxrm
    librsvg
    dbus
    gdk-pixbuf
    libpthreadstubs
    libstartup_notification
    libxdg_basedir
    lua
    net-tools
    pango
    xcb-util-cursor
  ] ++ commonDeps;

  propagatedBuildInputs = commonDeps;

  cmakeFlags = [
    #"-DGENERATE_MANPAGES=ON"
    "-DOVERRIDE_VERSION=${version}"
  ]
  ++ lib.optional lua.pkgs.isLuaJIT "-DLUA_LIBRARY=${lua}/lib/libluajit-5.1.so";

  GI_TYPELIB_PATH = "${pango.out}/lib/girepository-1.0";
  # LUA_CPATH and LUA_PATH are used only for *building*, see the --search flags
  # below for how awesome finds the libraries it needs at runtime.
  LUA_CPATH = "${luaEnv}/lib/lua/${lua.luaversion}/?.so";
  LUA_PATH = "${luaEnv}/share/lua/${lua.luaversion}/?.lua;;";
  
  postPatch = ''
    # Fix plugin path detection for Nix environment
    substituteInPlace defconfig/oneshot.lua \
      --replace 'local plugins_folder = cwc.is_nested() and "./build/plugins" or cwc.get_datadir() .. "/plugins"' \
                'local function find_plugins_folder()
      if cwc.is_nested() then
          return "./build/plugins"
      end

      local data_dirs = (os.getenv("XDG_DATA_DIRS") or "/usr/local/share:" + "${placeholder "out"}/share"):split(":")

      for _, base in ipairs(data_dirs) do
          local path = base .. "/cwc/plugins"
          local f = io.open(path .. "/cwcle.so", "r")
          if f then
              f:close()
              return path
          end
      end

      return cwc.get_datadir() .. "/plugins"
    end
    local plugins_folder = find_plugins_folder()'

    # Optional: patch any hardcoded paths in rc.lua if needed
  '';

  postInstall = ''
    mkdir -p "$out/lib/cwc/plugins"
    mkdir -p "$out/share/cwc"

    # Copy default config
    cp -r ${src}/defconfig "$out/share/cwc/"

    # Copy plugins if available
    if [ -d "$out/share/cwc/plugins" ]; then
        cp "$out/share/cwc/plugins"/*.so "$out/lib/cwc/plugins/" || true
    fi
    if [ -d "plugins" ] && [ -n "$(ls plugins/*.so 2>/dev/null)" ]; then
        cp plugins/*.so "$out/lib/cwc/plugins/" || true
    fi

    # Wrap the binary with all required environment variables
    wrapProgram "$out/bin/cwc" \
      --prefix PATH : "${lib.makeBinPath [
        luaEnv
        swaybg
        waybar
        playerctl
        swayidle
        aria2
      ]}" \
      --prefix LUA_PATH : "${luaEnv}/share/lua/5.1/?.lua;${luaEnv}/share/lua/5.1/?/init.lua;${placeholder "out"}/share/cwc/?.lua" \
      --prefix LUA_CPATH : "${luaEnv}/lib/lua/5.1/?.so;${placeholder "out"}/lib/cwc/plugins/?.so" \
      --prefix GI_TYPELIB_PATH : "${lib.makeSearchPath "lib/girepository-1.0" [ gobject-introspection gtk3 pango gdk-pixbuf ]}" \
      --prefix XDG_DATA_DIRS : "$out/share:${gtk3}/share:${gdk-pixbuf}/share:${pango}/share" \
      --prefix GIO_MODULE_DIR : "${glib}/lib/gio/modules" \
      --set gdk-pixbuf_MODULE_FILE "${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"

    # Create desktop entry for Wayland session
    mkdir -p "$out/share/wayland-sessions"
    cat > "$out/share/wayland-sessions/cwcwm.desktop" <<EOF
[Desktop Entry]
Name=CwCwm
Comment=CwC Wayland Compositor
Exec=$out/bin/cwc
TryExec=$out/bin/cwc
Type=Application
DesktopNames=CwCwm
X-WL-Session=true
EOF
  '';
  passthru = {
    inherit lua;
  };
  passthru.providedSessions = [ "cwcwm" ];

  meta = with lib; {
    description = "CwC is an extensible Wayland compositor with dynamic window management based on wlroots. Highly influenced by awesome window manager, CwC uses Lua for its configuration and C plugins for extensions.";
    homepage = "https://github.com/Cudiph/cwcwm";
    license = licenses.mit;
    maintainers = with maintainers; [ sk4g ];
    platforms = platforms.linux;
    mainProgram = "cwc";
  };
}