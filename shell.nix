# Build environment for the linux-x86_64 preset on a NixOS host.
# The library list follows nixpkgs' sdl3 package, so SDL enables the same
# video and audio backends as the distribution build.
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
    wayland-scanner
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
