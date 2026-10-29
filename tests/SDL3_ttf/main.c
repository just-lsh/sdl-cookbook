#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>

int main(void)
{
    const int linked = TTF_Version();
    SDL_Log("SDL_ttf %d.%d.%d",
            SDL_VERSIONNUM_MAJOR(linked),
            SDL_VERSIONNUM_MINOR(linked),
            SDL_VERSIONNUM_MICRO(linked));
    if (linked != SDL_TTF_VERSION) {
        return 1;
    }

    if (!TTF_Init()) {
        SDL_Log("TTF_Init failed: %s", SDL_GetError());
        return 1;
    }

    int major, minor, patch;
    TTF_GetFreeTypeVersion(&major, &minor, &patch);
    SDL_Log("FreeType %d.%d.%d", major, minor, patch);
    const bool freetype = major > 0;
    TTF_GetHarfBuzzVersion(&major, &minor, &patch);
    SDL_Log("HarfBuzz %d.%d.%d", major, minor, patch);
    const bool harfbuzz = major > 0;

    TTF_Quit();

    /* SDL_ttf reports version 0.0.0 for a library it was built without. */
    return freetype && harfbuzz ? 0 : 1;
}
