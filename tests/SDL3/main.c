#include <SDL3/SDL.h>

/* Fails if the program loaded a different SDL than the one it compiled against. */
int main(void)
{
    const int linked = SDL_GetVersion();

    SDL_Log("SDL %d.%d.%d (%s)",
            SDL_VERSIONNUM_MAJOR(linked),
            SDL_VERSIONNUM_MINOR(linked),
            SDL_VERSIONNUM_MICRO(linked),
            SDL_GetRevision());

    return linked == SDL_VERSION ? 0 : 1;
}
