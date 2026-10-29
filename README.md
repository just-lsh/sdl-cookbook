# sdl-cookbook

CMake recipes for building [SDL3](https://libsdl.org) and its satellite
libraries from source. A recipe chooses the libraries, their versions and
their options. You pick a preset for a recipe, and CMake fetches the
libraries, builds them, installs them together into `out/<preset>/` and checks
that the install is usable.

> [!NOTE]
> This project is not affiliated with or endorsed by the SDL project. Please
> report bugs in the libraries themselves upstream.

## Libraries

| Library | Version in the recipes | Definition |
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
- Git
- A C and C++ compiler
- `nasm`, for the AV1 codecs of SDL_image
- Python 3, for SPIRV-Tools and DirectXShaderCompiler of SDL_shadercross
- SDL's [platform build dependencies](https://wiki.libsdl.org/SDL3/README-linux#build-dependencies)

On NixOS, [`shell.nix`](shell.nix) provides all of these:

```sh
nix-shell
```

## Usage

```sh
cmake --workflow --preset desktop-x64-linux-gcc
```

The workflow runs three steps, each also available as its own preset:

1. `cmake --preset <name>` configures `build/<name>/`.
2. `cmake --build --preset <name>` fetches, builds and installs every library
   into `out/<name>/`.
3. `ctest --preset <name>` builds a small program per library,
   `tests/<library>/main.c`, against the install and runs it. The programs check that
   the codecs load, for example by encoding and decoding a PNG, JPEG, WebP and
   AVIF image with SDL_image, or compiling an HLSL shader with SDL_shadercross.

The result has one directory per preset:

```text
out/desktop-x64-linux-gcc/
├── bin/       # shadercross, with the desktop-shadercross recipe
├── include/   # SDL3/, SDL3_image/, SDL3_mixer/, SDL3_ttf/, SDL3_net/, ...
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

Each library has a definition, `cmake/<library>.cmake`, with what every
build of it needs: where to fetch it, what it depends on, and the options that
keep the install small and relocatable (no tests or samples). Everything else
comes from the recipe.

Each version of a library gets its own build tree in
`build/<preset>/<library>/<tag>/`, and is never updated from the remote once
cloned. Rebuilding without changes does no work, changing a `GIT_TAG` starts
from a fresh clone, and switching back to a version that was built before only
installs it again. To rebuild a version from scratch, for example a branch
name used as `GIT_TAG` that has new commits, delete its directory. A local
checkout set with `COOKBOOK_<LIBRARY>_SOURCE_DIR` is built on every build instead,
so its own build system picks up your edits.

Each step writes its output to a log file in
`build/<preset>/<library>/<tag>/src/<library>-stamp/` and prints it only if the
step fails.

## Recipes

| Recipe | Libraries | Platforms |
|---|---|---|
| `desktop` | all of the above except SDL_shadercross, with their codecs and dependencies built from the vendored sources | Linux |
| `desktop-shadercross` | `desktop` plus SDL_shadercross | Linux |

A recipe is a set of hidden presets in
[`cmake/presets/recipe/`](cmake/presets/recipe): `recipe-<name>` sets what is
the same on every platform, and `recipe-<name>-<platform>` the rest. A recipe
can build on another one: `recipe-desktop-shadercross` inherits
`recipe-desktop` and uses its Linux part. They set cache variables:

| Variable | Effect |
|---|---|
| `COOKBOOK_<LIBRARY>` | build that library; all are `OFF` unless a recipe turns them on |
| `COOKBOOK_<LIBRARY>_GIT_TAG` | tag or commit to build |
| `COOKBOOK_<LIBRARY>_SOURCE_DIR` | build a local checkout instead of fetching, e.g. `COOKBOOK_SDL3_SOURCE_DIR=/path/to/SDL`; it must already have its git submodules |
| the library's own options | passed on to the library, by prefix: `SDL_*` to SDL, `SDLIMAGE_*` to SDL_image, `SDLMIXER_*`, `SDLTTF_*`, `SDLNET_*`, `SDLSHADERCROSS_*` |
| `COOKBOOK_SDL3_REQUIRE` | defines that SDL's generated `SDL_build_config.h` must contain, such as `SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC`; the build fails if one is missing |
| `COOKBOOK_TESTS` | add the consumer tests; `ON` by default |

`<LIBRARY>` is the library name in upper case: `SDL3`, `SDL3_IMAGE`,
`SDL3_MIXER`, `SDL3_TTF`, `SDL3_NET` or `SDL3_SHADERCROSS`. Turning on a
library without the libraries it needs fails, as does a library without a
version.

SDL compiles in a backend only if it finds its development headers, and
silently leaves it out otherwise. The `desktop` recipe lists every Linux
backend it wants in `COOKBOOK_SDL3_REQUIRE`, all loaded at runtime (`_DYNAMIC`)
so the build runs on systems that lack some of them. If the build stops
there, install the missing development packages. SDL_image, SDL_mixer and
SDL_ttf fail on a missing codec by themselves, with their `STRICT` options.

SDL_shadercross has its own recipe because most games only need it while
they are developed: it compiles shaders, usually ahead of time. It builds
DirectXShaderCompiler, a fork of LLVM, which takes longer than any other
library and makes up most of the install size (its library is about 40 MB of
the 94 MB `desktop-shadercross` install).

## Presets

The project has presets for the builds it publishes, named
`<recipe>-<host>-<compiler>`. They build everything as `Release`, and add
debug information to the SDL libraries' own code only, the way SDL ships its
Windows builds. A debugger can step into SDL, while the vendored dependencies
stay small. [`cmake/DebugInfo.cmake`](cmake/DebugInfo.cmake) does this.

| Preset | Recipe | Host | Compiler | Generator |
|---|---|---|---|---|
| `desktop-x64-linux-gcc` | `desktop` | Linux x86_64 | GCC | Ninja |
| `desktop-shadercross-x64-linux-gcc` | `desktop-shadercross` | Linux x86_64 | GCC | Ninja |

[`CMakePresets.json`](CMakePresets.json) only includes the files in
[`cmake/presets/platform/`](cmake/presets/platform). Each platform file
combines small hidden presets from the other directories:

| Directory | Hidden presets | Sets |
|---|---|---|
| `recipe/` | `recipe-desktop`, `recipe-desktop-linux`, `recipe-desktop-shadercross` | libraries, versions and options |
| `config/` | `config-layout`, `config-ninja`, `config-release` | build and install directories, generator, build type |
| `compiler/` | `compiler-gcc` | C and C++ compilers |
| `host/` | `host-x64-linux` | the host where the preset is available; configuring fails on another processor |

The build type, compilers, toolchain file, library directory and RPATH are
passed on to every library.

### Your own build

To change a recipe, write your own preset in `CMakeUserPresets.json`, which
git ignores. It inherits a project preset and overrides single cache
variables; all others keep the recipe's values. Start from
[`CMakeUserPresets.example.json`](CMakeUserPresets.example.json):

```sh
cp CMakeUserPresets.example.json CMakeUserPresets.json
cmake --workflow --preset my-game
```

Its `my-game` preset builds the `desktop` recipe with an older SDL, without
SDL_net, and with JPEG XL support in SDL_image:

```json
{
  "name": "my-game",
  "inherits": "desktop-x64-linux-gcc",
  "cacheVariables": {
    "COOKBOOK_SDL3_GIT_TAG": "release-3.4.16",
    "COOKBOOK_SDL3_NET": false,
    "SDLIMAGE_JXL": true
  }
}
```

The build, test and workflow presets in the example only repeat the name: a
workflow preset needs them to run all three steps with one command. Each
preset builds into `build/<preset>/` and installs into `out/<preset>/`, so
your builds never mix with the project's.

A variable keeps its value in an existing build directory after you remove it
from a preset. Configure with `--fresh` to start from the preset's values
again:

```sh
cmake --preset my-game --fresh
```

For a one-off change, `-D` on the command line overrides the preset:

```sh
cmake --preset desktop-x64-linux-gcc -DCOOKBOOK_SDL3_GIT_TAG=release-3.4.16
```

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
