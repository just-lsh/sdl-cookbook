# Build environment for the x64-linux presets on a NixOS host.
# The library list follows nixpkgs' sdl3 package, so SDL enables the same
# video and audio backends as the distribution build. The satellite
# libraries build their codecs from vendored sources and need no libraries
# from here.
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

    # System integration
    dbus
    ibusMinimal
    libayatana-appindicator
    libusb1
    systemdLibs
  ];
}
