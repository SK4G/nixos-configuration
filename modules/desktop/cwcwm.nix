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
    net-tools
    pango
    xcb-util-cursor
  ] ++ commonDeps;

  propagatedBuildInputs = commonDeps;

  doCheck = true;

  GI_TYPELIB_PATH = "${pango.out}/lib/girepository-1.0";

  postInstall = ''
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