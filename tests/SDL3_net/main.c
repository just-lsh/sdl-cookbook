#include <SDL3/SDL.h>
#include <SDL3_net/SDL_net.h>

int main(void)
{
    const int linked = NET_Version();
    SDL_Log("SDL_net %d.%d.%d",
            SDL_VERSIONNUM_MAJOR(linked),
            SDL_VERSIONNUM_MINOR(linked),
            SDL_VERSIONNUM_MICRO(linked));
    if (linked != SDL_NET_VERSION) {
        return 1;
    }

    if (!NET_Init()) {
        SDL_Log("NET_Init failed: %s", SDL_GetError());
        return 1;
    }
    NET_Quit();
    return 0;
}
