self: super: {
  cwc = super.cwc.overrideAttrs (old: {
    nativeBuildInputs = with super; [
      meson
      ninja
      pkg-config
      wayland-protocols
      wayland-scanner
      git
      python3Minimal
      boost
      makeWrapper
      wrapGAppsHook3
      gobject-introspection
    ];
  });
}
