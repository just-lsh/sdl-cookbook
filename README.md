# sdl-cookbook

CMake recipes for building [SDL3](https://libsdl.org) and its satellite
libraries from source. You pick a preset, and CMake fetches the libraries,
builds them, installs them together into `out/<preset>/` and checks that the
install is usable.

> [!NOTE]
> This project is not affiliated with or endorsed by the SDL project. Please
> report bugs in the libraries themselves upstream.

## Libraries

| Library | Default version | Recipe |
|---|---|---|
| [SDL](https://github.com/libsdl-org/SDL) | `release-3.4.18` | [`cmake/SDL3.cmake`](cmake/SDL3.cmake) |
| [SDL_image](https://github.com/libsdl-org/SDL_image) | `release-3.4.8` | [`cmake/SDL3_image.cmake`](cmake/SDL3_image.cmake) |
| [SDL_mixer](https://github.com/libsdl-org/SDL_mixer) | `release-3.2.4` | [`cmake/SDL3_mixer.cmake`](cmake/SDL3_mixer.cmake) |
| [SDL_ttf](https://github.com/libsdl-org/SDL_ttf) | `release-3.2.2` | [`cmake/SDL3_ttf.cmake`](cmake/SDL3_ttf.cmake) |
| [SDL_net](https://github.com/libsdl-org/SDL_net) | `release-3.2.0` | [`cmake/SDL3_net.cmake`](cmake/SDL3_net.cmake) |
| [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross) | `1ff05be` (no releases yet) | [`cmake/SDL3_shadercross.cmake`](cmake/SDL3_shadercross.cmake) |

The satellite libraries build their third-party dependencies (image and audio
codecs, FreeType, HarfBuzz, SPIRV-Cross, DirectXShaderCompiler, ...) from the
sources they vendor as git submodules. Codecs are installed as shared libraries next to the SDL library
that loads them.

## Requirements

- CMake 3.25+
- Ninja
- A C and C++ compiler
- `nasm`, for the AV1 codecs of SDL_image
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

1. `cmake --preset <name>` configures `build/<name>/`.
2. `cmake --build --preset <name>` fetches, builds and installs every library
   into `out/<name>/`.
3. `ctest --preset <name>` builds a small program per library from
   [`tests/`](tests) against the install and runs it. The programs check that
   the codecs load, for example by encoding and decoding a PNG, JPEG, WebP and
   AVIF image with SDL_image, or compiling an HLSL shader with SDL_shadercross.

The result has one directory per preset:

```text
out/x64-linux-gcc-release/
├── bin/       # shadercross
├── include/   # SDL3/, SDL3_image/, SDL3_mixer/, SDL3_ttf/, SDL3_net/, SDL3_shadercross/
├── lib/       # libSDL3.so, libSDL3_image.so, ..., and the codec libraries
│   ├── cmake/
│   └── pkgconfig/
└── share/     # licenses/<library>/
```

The libraries find each other relative to their own location, and programs in
`bin/` find them in `lib/`, so the directory can be moved. To use it from another CMake project, point
`CMAKE_PREFIX_PATH` at it and find SDL before the satellite libraries:

```cmake
find_package(SDL3 REQUIRED)
find_package(SDL3_image REQUIRED)
target_link_libraries(app PRIVATE SDL3_image::SDL3_image SDL3::SDL3)
```

## How it works

The top-level [`CMakeLists.txt`](CMakeLists.txt) is a superbuild: it compiles
nothing itself. [`cmake/Cookbook.cmake`](cmake/Cookbook.cmake) adds each library
with `ExternalProject` as its own top-level project, the way upstream builds
it. SDL is installed first, and each satellite library then finds it in the
install directory with `find_package(SDL3)`. The libraries share nothing but
that directory.

Each version of a library gets its own build tree in
`build/<preset>/<library>/<tag>/`, and is never updated from the remote once
cloned. Rebuilding without changes does no work, changing a `GIT_TAG` starts
from a fresh clone, and switching back to a version that was built before only
installs it again. To rebuild a version from scratch, for example a branch
name used as `GIT_TAG` that has new commits, delete its directory.

Each step writes its output to a log file in
`build/<preset>/<library>/<tag>/src/<library>-stamp/` and prints it only if the
step fails.

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

The build type, compilers, toolchain file, library directory and RPATH are
passed on to every library.

## Options

Set these when configuring, for example:

```sh
cmake --preset x64-linux-gcc-release -DCOOKBOOK_SDL_GIT_TAG=release-3.4.16 -DCOOKBOOK_SDL_NET=OFF
```

| Option | Default | Effect |
|---|---|---|
| `COOKBOOK_SDL_IMAGE`, `COOKBOOK_SDL_MIXER`, `COOKBOOK_SDL_TTF`, `COOKBOOK_SDL_NET`, `COOKBOOK_SDL_SHADERCROSS` | `ON` | build that satellite library |
| `COOKBOOK_<LIB>_GIT_TAG` | see [Libraries](#libraries) | tag or commit to build, e.g. `COOKBOOK_SDL_IMAGE_GIT_TAG` |
| `COOKBOOK_<LIB>_SOURCE_DIR` | empty | build a local checkout instead of fetching, e.g. `COOKBOOK_SDL_SOURCE_DIR=/path/to/SDL` |
| `COOKBOOK_TESTS` | `ON` | add the consumer tests |

`<LIB>` is `SDL`, `SDL_IMAGE`, `SDL_MIXER`, `SDL_TTF`, `SDL_NET` or
`SDL_SHADERCROSS`.

SDL_shadercross builds DirectXShaderCompiler, a fork of LLVM, which takes
longer than all other libraries together and makes up most of the install
size (about 1.2 GB for a debug build, 75 MB for release). Turn it off with
`-DCOOKBOOK_SDL_SHADERCROSS=OFF` if you don't need it.

The libraries' own options (`SDL_WAYLAND`, `SDLIMAGE_AVIF`, ...) are set in
`CMAKE_CACHE_ARGS` of their recipe, since each library is a separate CMake
project.

## Formatting

The CMake files are formatted with [cmakefmt](https://cmakefmt.dev), using its
defaults with a line width of 100, plus the shape of `cookbook_add_library`,
in [`.cmakefmt.toml`](.cmakefmt.toml):

```sh
cmake -P cmake/Format.cmake             # format in place
cmake -DCHECK=ON -P cmake/Format.cmake  # only report files that would change
```

[`cmake/Format.cmake`](cmake/Format.cmake) downloads the pinned cmakefmt
release for your platform into `.cache/cmakefmt/` on first use and verifies
its checksum, so nothing else needs to be installed.

## License

The recipes in this repository are licensed under the [MIT License](LICENSE).
The SDL libraries are licensed under the zlib license. The libraries they
vendor carry their own licenses. SDL_image and SDL_mixer install those into
`share/licenses/`; SDL_ttf does not install the licenses of FreeType,
HarfBuzz and PlutoSVG, which it links statically.
