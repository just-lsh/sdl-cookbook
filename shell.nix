# Build environment for the Linux presets on a NixOS host.
# It provides every SDL backend that the desktop recipe requires on Linux
# (COOKBOOK_SDL3_REQUIRE in cmake/presets/recipe/desktop.json), which are the
# ones the Steam Runtime SDK has headers for. The satellite libraries build
# their codecs from vendored sources and need no libraries from here.
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cmake
    git
    ninja
    pkg-config
    wayland-scanner
    # Assembly in SDL_image's vendored dav1d and aom.
    nasm
    # SPIRV-Tools and DirectXShaderCompiler, vendored by SDL_shadercross.
    python3
  ];

  buildInputs = with pkgs; [
    # Audio
    alsa-lib
    libjack2
    libpulseaudio
    pipewire

    # Video: Wayland, X11, KMS/DRM, OpenGL, Vulkan
    libdecor
    libxkbcommon
    wayland
    libx11
    libxcb
    libxscrnsaver
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    libxtst
    libdrm
    libgbm
    libGL
    vulkan-headers
    vulkan-loader

    # Text shaping for bidirectional and Thai text
    fribidi
    libthai

    # System integration
    dbus
    ibusMinimal
    libayatana-appindicator
    libusb1
    systemdLibs
  ];
}
