#include <SDL3/SDL.h>
#include <SDL3_mixer/SDL_mixer.h>

/* Decoders backed by a vendored codec library. MIX_Init only registers them
 * if their library loads, so a missing one means a broken install. */
static const char *const required_decoders[] = {
    "VORBIS", "OPUS", "FLAC", "WAVPACK", "GME", "XMP", "MPG123"
};

static bool has_decoder(const char *name)
{
    for (int i = 0; i < MIX_GetNumAudioDecoders(); i++) {
        if (SDL_strcmp(MIX_GetAudioDecoder(i), name) == 0) {
            return true;
        }
    }
    return false;
}

int main(void)
{
    const int linked = MIX_Version();
    SDL_Log("SDL_mixer %d.%d.%d",
            SDL_VERSIONNUM_MAJOR(linked),
            SDL_VERSIONNUM_MINOR(linked),
            SDL_VERSIONNUM_MICRO(linked));
    if (linked != SDL_MIXER_VERSION) {
        return 1;
    }

    if (!MIX_Init()) {
        SDL_Log("MIX_Init failed: %s", SDL_GetError());
        return 1;
    }

    bool ok = true;
    for (size_t i = 0; i < SDL_arraysize(required_decoders); i++) {
        const bool found = has_decoder(required_decoders[i]);
        SDL_Log("%-7s %s", required_decoders[i], found ? "ok" : "MISSING");
        ok &= found;
    }

    MIX_Quit();
    return ok ? 0 : 1;
}
