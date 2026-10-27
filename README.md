# sdl3-prebuilt

Prebuilt binaries of [SDL3](https://libsdl.org) and its satellite libraries,
published as [GitHub releases](../../releases).

| Library                                                          | Pinned version           |
| ---------------------------------------------------------------- | ------------------------ |
| [SDL](https://github.com/libsdl-org/SDL)                         | `release-3.4.18`         |
| [SDL_image](https://github.com/libsdl-org/SDL_image)             | `release-3.4.8`          |
| [SDL_mixer](https://github.com/libsdl-org/SDL_mixer)             | `release-3.2.4`          |
| [SDL_ttf](https://github.com/libsdl-org/SDL_ttf)                 | `release-3.2.2`          |
| [SDL_net](https://github.com/libsdl-org/SDL_net)                 | `release-3.2.0`          |
| [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross) | `main` (no releases yet) |

> [!NOTE]
> These are **unofficial** builds. This project is not affiliated with or
> endorsed by the SDL project. The libraries are built from unmodified upstream
> sources; all credit goes to Sam Lantinga and the SDL contributors, and to the
> authors of the bundled third-party libraries. Please report bugs in the
> libraries themselves upstream, and only packaging problems here.

## Build flavours

Each release provides two flavours, configured by the CMake initial-cache files
in [`cmake/`](cmake):

- **shared** ([`cmake/shared.cmake`](cmake/shared.cmake)): shared libraries.
  Third-party dependencies are separate shared libraries that the SDL libraries
  load at runtime.
- **static** ([`cmake/static.cmake`](cmake/static.cmake)): static libraries.
  SDL3_mixer is built without libgme and mpg123 because they are LGPL-licensed.
  MP3 playback still works through the built-in dr_mp3 decoder; only the GME
  chiptune formats (NSF, SPC, VGM, ...) are unavailable.

All third-party dependencies are built from the sources vendored by the SDL
libraries; no system packages are bundled.

## Release archives

Every release has one archive per target and flavour, named
`sdl3-prebuilt-<target>-<flavour>`, for example
`sdl3-prebuilt-x86_64-linux-gnu-shared.tar.gz`. Windows targets use `.zip`.

| Target | Toolchain |
|---|---|
| `x86_64-linux-gnu`, `aarch64-linux-gnu` | GCC |
| `x86_64-windows-msvc`, `aarch64-windows-msvc` | MSVC |
| `x86_64-w64-mingw32` | MinGW-w64 |
| `aarch64-apple-darwin`, `x86_64-apple-darwin` | Apple Clang |

Each archive contains all libraries in the standard CMake install layout, so
`find_package(SDL3 ...)` and pkg-config work after pointing
`CMAKE_PREFIX_PATH` / `PKG_CONFIG_PATH` at the extracted directory:

```text
sdl3-prebuilt-x86_64-linux-gnu-shared/
├── bin/                    # DLLs (Windows) and the shadercross CLI
├── include/SDL3*/
├── lib/                    # .so / .dylib / .a / import .lib
│   ├── cmake/
│   └── pkgconfig/
├── share/licenses/         # license of every bundled library
├── THIRD_PARTY_NOTICES.md
└── VERSIONS.txt            # exact upstream commits
```

A source archive, `sdl3-prebuilt-<version>-src.tar.gz`, with every submodule
included, is attached to every release.

## Building locally

Requirements: CMake 3.21+, a C/C++ compiler, `nasm` (for dav1d and aom), and on
Linux the [SDL build dependencies](https://wiki.libsdl.org/SDL3/README-linux#build-dependencies).

```sh
git clone --recursive --shallow-submodules https://github.com/just-lsh/sdl3-prebuilt.git
cd sdl3-prebuilt

cmake -DTARGET=x86_64-linux-gnu -DFLAVOUR=shared -P scripts/package.cmake
cmake -P scripts/source-archive.cmake
```

Both scripts write to `build/`. Other targets pass toolchain settings through
the script, for example:

```sh
# Windows arm64 (Visual Studio)
cmake -DTARGET=aarch64-windows-msvc -DFLAVOUR=shared -DPLATFORM=ARM64 -P scripts/package.cmake
# MinGW, cross-compiled from Linux
cmake -DTARGET=x86_64-w64-mingw32 -DFLAVOUR=shared \
  -DTOOLCHAIN_FILE=SDL/build-scripts/cmake-toolchain-mingw64-x86_64.cmake -P scripts/package.cmake
# macOS, on an Apple Silicon and an Intel machine respectively
cmake -DTARGET=aarch64-apple-darwin -DFLAVOUR=shared -DOSX_DEPLOYMENT_TARGET=11.0 -P scripts/package.cmake
cmake -DTARGET=x86_64-apple-darwin -DFLAVOUR=shared -DOSX_DEPLOYMENT_TARGET=11.0 -P scripts/package.cmake
```

See the header of [`scripts/package.cmake`](scripts/package.cmake) for all
options. Building SDL_shadercross compiles DirectXShaderCompiler, which takes
much longer than all other libraries combined.

## Updating a library

```sh
git -C SDL fetch --depth 1 origin tag release-3.x.y
git -C SDL checkout release-3.x.y
git submodule update --init --recursive --depth 1 SDL
git add SDL
```

Update the version table above in the same commit.

## License

The build scripts and configuration in this repository are licensed under the
[MIT License](LICENSE).

The SDL libraries are licensed under the zlib license. The libraries bundled in
the release archives carry their own licenses, including LGPL-2.1 for libgme
and mpg123 in the shared flavour. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the full list and the
required attributions.
