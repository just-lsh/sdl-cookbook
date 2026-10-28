# sdl-cookbook

CMake recipes for building [SDL3](https://libsdl.org) from source. You pick a
preset, and CMake fetches SDL, builds it, installs it into `out/<preset>/` and
checks that the install is usable.

> [!NOTE]
> This project is not affiliated with or endorsed by the SDL project. Please
> report bugs in SDL itself upstream.

## Requirements

- CMake 3.25+
- Ninja
- A C compiler
- SDL's [platform build dependencies](https://wiki.libsdl.org/SDL3/README-linux#build-dependencies)

On NixOS, [`shell.nix`](shell.nix) provides all of these:

```sh
nix-shell
```

## Usage

```sh
cmake --workflow --preset x64-linux-gcc-release
```

The workflow runs three steps, each also available as its own preset:

1. `cmake --preset <name>` configures `build/<name>/` and fetches SDL.
2. `cmake --build --preset <name>` builds SDL and installs it into `out/<name>/`.
3. `ctest --preset <name>` builds [`tests/consumer`](tests/consumer) against
   the install and runs it.

To use the result from another CMake project, point `CMAKE_PREFIX_PATH` at
`out/<name>/` and call `find_package(SDL3)`.

## Presets

Preset names follow `<host>-<compiler>-<build type>`.

| Preset | Host | Compiler | Generator |
|---|---|---|---|
| `x64-linux-gcc-debug` | Linux x86_64 | GCC | Ninja |
| `x64-linux-gcc-release` | Linux x86_64 | GCC | Ninja |

[`CMakePresets.json`](CMakePresets.json) only includes the files in
[`cmake/presets/platform/`](cmake/presets/platform). Each platform file
combines small hidden presets from the other directories:

| Directory | Hidden presets | Sets |
|---|---|---|
| `config/` | `config-layout`, `config-ninja`, `config-debug`, `config-release` | build and install directories, generator, build type |
| `compiler/` | `compiler-gcc` | C and C++ compilers |
| `host/` | `host-x64-linux` | the host where the preset is available |

## SDL version

[`cmake/SDL3.cmake`](cmake/SDL3.cmake) fetches SDL with `FetchContent`. By
default it builds the `release-3.4.18` tag. To build a different tag or commit,
set `COOKBOOK_SDL_GIT_TAG`:

```sh
cmake --preset x64-linux-gcc-release -DCOOKBOOK_SDL_GIT_TAG=release-3.4.16
```

To build a local SDL checkout instead, set
`FETCHCONTENT_SOURCE_DIR_SDL3=/path/to/SDL`.

SDL's own options (`SDL_SHARED`, `SDL_STATIC`, `SDL_WAYLAND`, ...) can be
passed the same way.

## License

The recipes in this repository are licensed under the [MIT License](LICENSE).
SDL itself is licensed under the zlib license.
