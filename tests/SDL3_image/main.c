#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>

typedef bool (*save_fn)(SDL_Surface *surface, SDL_IOStream *dst);

static bool save_png(SDL_Surface *s, SDL_IOStream *dst) { return IMG_SavePNG_IO(s, dst, false); }
static bool save_jpg(SDL_Surface *s, SDL_IOStream *dst) { return IMG_SaveJPG_IO(s, dst, false, 90); }
static bool save_webp(SDL_Surface *s, SDL_IOStream *dst) { return IMG_SaveWEBP_IO(s, dst, false, 90.0f); }
static bool save_avif(SDL_Surface *s, SDL_IOStream *dst) { return IMG_SaveAVIF_IO(s, dst, false, 90); }

/* Encodes the surface and decodes it again, which loads the vendored codec. */
static bool round_trip(SDL_Surface *surface, const char *type, save_fn save)
{
    SDL_IOStream *io = SDL_IOFromDynamicMem();
    bool ok = io && save(surface, io) && SDL_SeekIO(io, 0, SDL_IO_SEEK_SET) == 0;
    SDL_Surface *loaded = ok ? IMG_LoadTyped_IO(io, false, type) : NULL;

    ok = loaded && loaded->w == surface->w && loaded->h == surface->h;
    SDL_Log("%-4s %s%s", type, ok ? "ok" : "FAILED: ", ok ? "" : SDL_GetError());
    SDL_DestroySurface(loaded);
    SDL_CloseIO(io);
    return ok;
}

int main(void)
{
    const int linked = IMG_Version();
    SDL_Log("SDL_image %d.%d.%d",
            SDL_VERSIONNUM_MAJOR(linked),
            SDL_VERSIONNUM_MINOR(linked),
            SDL_VERSIONNUM_MICRO(linked));
    if (linked != SDL_IMAGE_VERSION) {
        return 1;
    }

    SDL_Surface *surface = SDL_CreateSurface(16, 16, SDL_PIXELFORMAT_RGBA32);
    if (!surface || !SDL_FillSurfaceRect(surface, NULL, SDL_MapSurfaceRGBA(surface, 255, 128, 0, 255))) {
        SDL_Log("Creating the test surface failed: %s", SDL_GetError());
        return 1;
    }

    bool ok = true;
    ok &= round_trip(surface, "PNG", save_png);
    ok &= round_trip(surface, "JPG", save_jpg);
    ok &= round_trip(surface, "WEBP", save_webp);
    ok &= round_trip(surface, "AVIF", save_avif);

    SDL_DestroySurface(surface);
    return ok ? 0 : 1;
}
