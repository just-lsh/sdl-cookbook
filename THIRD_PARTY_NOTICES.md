# Third-party notices

The release archives of this project contain unmodified builds of the libraries
listed below. None of them were written by this project; all rights belong to
their respective authors.

The full license text of every component included in an archive is installed
alongside it under `share/licenses/`:

- `share/licenses/<library>/LICENSE.txt` for each SDL library
- `share/licenses/<library>/optional/` for the third-party libraries that SDL
  library bundles in that build. SDL3_image and SDL3_mixer install these
  themselves; for SDL3_ttf and SDL3_shadercross, whose upstream install rules
  only cover their own license, this project's packaging copies them in from
  the vendored sources
- `THIRD_PARTY_NOTICES.md` (this file) at the root of every archive

The exact upstream commit of every component is recorded by the git submodules
of this repository at the tag the release was built from. A complete source
archive is attached to every release.

## SDL libraries

All are licensed under the [zlib license](https://zlib.net/zlib_license.html),
Copyright (C) 1997-2026 Sam Lantinga and contributors.

| Library | Upstream |
|---|---|
| SDL3 | https://github.com/libsdl-org/SDL |
| SDL3_image | https://github.com/libsdl-org/SDL_image |
| SDL3_mixer | https://github.com/libsdl-org/SDL_mixer |
| SDL3_ttf | https://github.com/libsdl-org/SDL_ttf |
| SDL3_net | https://github.com/libsdl-org/SDL_net |
| SDL3_shadercross | https://github.com/libsdl-org/SDL_shadercross |

## Bundled third-party libraries

Which of these an archive contains depends on the library and the build
flavour (see the last column). The archive's `share/licenses/` folder is the
authoritative list for that archive.

### SDL3_image

| Component | License | Included |
|---|---|---|
| [libavif](https://github.com/AOMediaCodec/libavif) | BSD-2-Clause | all builds |
| [dav1d](https://code.videolan.org/videolan/dav1d) | BSD-2-Clause | all builds |
| [libaom](https://aomedia.googlesource.com/aom) | BSD-2-Clause + AOM Patent License 1.0 | all builds |
| [libpng](http://www.libpng.org/pub/png/libpng.html) | libpng License v2 | all builds |
| [libtiff](https://libtiff.gitlab.io/libtiff/) | libtiff License | all builds |
| [libwebp](https://chromium.googlesource.com/webm/libwebp) | BSD-3-Clause | all builds |
| [zlib](https://zlib.net) | zlib | all builds |

JPEG images are decoded with the public-domain stb_image, which is part of
SDL3_image itself; libjpeg and libjxl are not built.

### SDL3_mixer

| Component | License | Included |
|---|---|---|
| [libogg](https://xiph.org/ogg/) | BSD-3-Clause | all builds |
| [libvorbis](https://xiph.org/vorbis/) | BSD-3-Clause | all builds |
| [libopus](https://opus-codec.org) | BSD-3-Clause | all builds |
| [opusfile](https://opus-codec.org) | BSD-3-Clause | all builds |
| [libFLAC](https://xiph.org/flac/) | BSD-3-Clause (Xiph.Org) | all builds |
| [WavPack](https://www.wavpack.com) | BSD-3-Clause | all builds |
| [libxmp](https://xmp.sourceforge.net) | MIT | all builds |
| [Game_Music_Emu (libgme)](https://github.com/libgme/game-music-emu) | LGPL-2.1-or-later | shared builds only |
| [mpg123](https://www.mpg123.de) | LGPL-2.1 | shared builds only |

libgme and mpg123 are shipped as separate shared libraries that SDL3_mixer
loads at runtime, so they can be replaced with any compatible build. Their
corresponding source code is in the source archive attached to each release
and at the upstream links above. libgme is built with the Nuked OPN2 YM2612
emulator (LGPL-2.1-or-later).

### SDL3_ttf

| Component | License | Included |
|---|---|---|
| [FreeType](https://freetype.org) | FreeType License (FTL) | all builds |
| [HarfBuzz](https://harfbuzz.github.io) | Old MIT | all builds |
| [PlutoSVG](https://github.com/sammycage/plutosvg) | MIT | all builds |
| [PlutoVG](https://github.com/sammycage/plutovg) | MIT | all builds |

FreeType is used under the terms of the FreeType License:

> Portions of this software are copyright © 2026 The FreeType Project
> (www.freetype.org). All rights reserved.

### SDL3_shadercross

| Component | License | Included |
|---|---|---|
| [SPIRV-Cross](https://github.com/KhronosGroup/SPIRV-Cross) | Apache-2.0 | all builds |
| [SPIRV-Tools](https://github.com/KhronosGroup/SPIRV-Tools) | Apache-2.0 | all builds |
| [SPIRV-Headers](https://github.com/KhronosGroup/SPIRV-Headers) | MIT / Khronos | all builds |
| [DirectXShaderCompiler](https://github.com/microsoft/DirectXShaderCompiler) | University of Illinois/NCSA, see its `ThirdPartyNotices.txt` | all builds |
| [DirectX-Headers](https://github.com/microsoft/DirectX-Headers) | MIT | all builds |
