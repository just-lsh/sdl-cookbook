# Plan

Where sdl-cookbook is heading and what comes next. Read this before changing
the build; [`README.md`](README.md) describes how the build works today.

## Goal

Publish prebuilt SDL3 libraries (SDL plus its satellite libraries) built in
CI from **recipes**: opinionated, named configurations chosen by this project.
People who clone the repo can write their own recipe for their requirements,
the same way the project writes its own.

Targets for the published binaries:

- Linux: built in a Steam Runtime SDK image (sniper, maybe also steamrt4).
- Windows: MSVC on a Windows CI runner.
- macOS: a macOS CI runner.

CI is too slow to iterate on build configuration, so the build is developed
locally first, on Linux x86_64.

## Roadmap

Work the steps in order. Each step is done when its criterion holds.

1. **Recipe mechanism and the Linux recipe.** _Current step._ A recipe
   selects the libraries to build, their versions and the options passed to
   each one. Done when: the Linux presets build from a named recipe, a preset
   in `CMakeUserPresets.json` can change any library's version or options
   without editing `cmake/`, and the README documents both. Design the recipe
   format and get it approved before implementing it.
2. **Faster local builds.** Measure first: time per library and per step
   (download, configure, build, install), then caching (e.g. ccache) and
   whatever else the measurements point at. Done when: a benchmark command
   exists and each optimisation is backed by before/after numbers from it.
3. **CI and published binaries**, Linux first, then Windows and macOS.

## Decisions

- **Recipes are deliberate.** A recipe states the features it wants; it does
  not rely on "everything on" or on whatever the build machine has installed.
- **Recipes are defined entirely in CMake presets**, with no recipe script
  files. A user customises a build by writing a preset in
  `CMakeUserPresets.json` that inherits a project preset and overrides its
  `cacheVariables`. The README's "Recipes" and "Presets" sections describe
  the mechanics.
- **Every recipe setting is its own cache variable**, so a user preset
  overrides one setting without repeating the others: library options use the
  library's own names and are passed on by prefix (`SDLIMAGE_*` to
  SDL_image), and each library has a `COOKBOOK_<LIBRARY>` switch.
- **A recipe is two kinds of hidden preset**: `recipe-<name>` for what every
  platform shares, `recipe-<name>-<platform>` for the rest.
- **`cmake/<library>.cmake` files are "library definitions"**: only what
  every build of the library needs. Versions and feature choices (such as
  `*_VENDORED` and `*_STRICT`) belong to recipes.
- **A recipe owns the library versions**, and chooses which libraries are
  built, not only their options. Example: an sdl2-compat recipe builds SDL3,
  sdl2-compat and the SDL2 versions of the satellite libraries (separate
  projects from the SDL3 ones: same repos, other tags, `SDL2IMAGE_*` style
  option names).
- **One recipe per purpose, not per platform.** A recipe means the same thing
  on every platform; only its platform-specific options and required
  features differ.
- **The project ships presets only for the combinations it publishes**,
  named `<recipe>-<platform>-<compiler>`. Other combinations are user
  presets.
- **Recipes so far: `desktop` and `desktop-shadercross`.** SDL_shadercross
  (with DirectXShaderCompiler) is left out of `desktop`: most games only need
  it during development, and it is about half of the install. An
  `sdl2-compat` recipe is planned.
- **One build type, `Release`, with debug information for SDL's own code
  only**, instead of separate debug and release builds. Users can step into
  SDL; the vendored dependencies get no debug information. Upstream SDL does
  the same for MSVC: a `Release` build that ships `SDL3.pdb` and
  `SDL3_image.pdb`, but no debug files for dependencies.
- **The Linux part of a recipe matches the Steam Runtime SDK**:
  `recipe-desktop-linux` requires every SDL3 backend sniper has headers for
  (all but sndio and liburing).
- **[`shell.nix`](shell.nix) is the maintainer's personal dev setup**, not a
  build environment for recipes. It provides the same SDL3 backends as the
  Steam Runtime SDK, so the Linux recipe also builds locally. Builds made in
  it link against a very recent glibc (the current SDL3 build needs
  `GLIBC_2.43`).
- The Steam Runtime build environment is **parked** until step 3. Building
  on the host is fine for steps 1 and 2.

## Facts behind the decisions

Verified against SDL 3.4.18, CMake 4.4 and the sniper SDK
`3.0.20261021.266025`. Re-check them when those versions change.

- **SDL3 drops missing backends silently.** It loads its Linux backends
  (X11, Wayland, PipeWire, PulseAudio, ALSA, ...) at runtime, so one build
  runs on many distros, but each backend is compiled in only if its headers
  are found at configure time. SDL3 has no strict switch; its configure
  summary prints `(Wanted: ON): OFF` for dropped ones. The satellite
  libraries do have one (`*_STRICT`), and their recipes turn it on.
- **SDL's own CI uses the Steam images**:
  `registry.gitlab.steamos.cloud/steamrt/sniper/sdk:latest` and
  `steamrt/steamrt4/sdk` (x86_64 and arm64). Sniper jobs may fail there
  (`allow_failure`). The steamrt4 jobs link backends directly
  (`more_hard_deps`), which a portable build should leave at the default.
- **Sniper SDK contents** (from Valve's published package manifest): Debian
  11, glibc 2.31, CMake 3.25.1 (this repo's minimum), default GCC 10, plus
  GCC 14 and clang 11. Its `libstdc++6` is 10.3, so C++ built with `g++-14`
  likely needs a newer libstdc++ than older distros have. It has headers for
  every SDL3 Linux backend except sndio and liburing.
- **steamrt4** is unverified: Debian 13 based, glibc presumably 2.41.
- **Preset `cacheVariables` merge per variable** across `inherits`: a preset
  overrides single variables of its parents, the earlier parent in
  `inherits` wins a conflict, `null` unsets an inherited variable, and `-D`
  on the command line overrides them all. A variable cannot extend its
  parent's value, so overriding a list means repeating it.
- **SDL3 records what it built in** in its generated
  `include-config-<build type>/build_config/SDL_build_config.h` (e.g.
  `SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC "libwayland-client.so.0"`). A dropped
  backend has no define; a `_DYNAMIC` suffix means it is loaded at runtime.
- **Changing a library's cache arguments** re-runs only its configure step:
  ExternalProject writes them to a cache script (`set(... CACHE ... FORCE)`,
  so a later duplicate wins) that the configure step depends on.
- **Local podman needs setup** before it can pull the Steam images: a
  `policy.json` and sub-UID/GID ranges for the user.

## Open questions

- Whether to split SDL's debug information into separate files for
  published builds. On Linux it is embedded in each library; the whole
  install is 94 MB, of which `libSDL3.so` is 21 MB.
- Turning a library off leaves the files it installed in `out/<preset>/`,
  and deleting `out/` alone breaks the build directory, whose install stamps
  still say installed. Today the fix is deleting both directories.
- Whether steamrt4 has every SDL3 backend that `recipe-desktop-linux`
  requires. Only sniper's package list has been checked.
