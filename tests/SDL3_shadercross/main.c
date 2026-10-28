#include <SDL3/SDL.h>
#include <SDL3_shadercross/SDL_shadercross.h>

static const char hlsl[] =
    "RWStructuredBuffer<float> values : register(u0, space1);\n"
    "[numthreads(64, 1, 1)]\n"
    "void main(uint3 id : SV_DispatchThreadID)\n"
    "{\n"
    "    values[id.x] *= 2.0;\n"
    "}\n";

/* Compiles HLSL to SPIR-V with DXC, then transpiles the SPIR-V to MSL and
 * back to HLSL with SPIRV-Cross. */
int main(void)
{
    if (!SDL_ShaderCross_Init()) {
        SDL_Log("SDL_ShaderCross_Init failed: %s", SDL_GetError());
        return 1;
    }

    const SDL_ShaderCross_HLSL_Info hlsl_info = {
        .source = hlsl,
        .entrypoint = "main",
        .shader_stage = SDL_SHADERCROSS_SHADERSTAGE_COMPUTE,
    };
    size_t spirv_size = 0;
    Uint8 *spirv = SDL_ShaderCross_CompileSPIRVFromHLSL(&hlsl_info, &spirv_size);
    SDL_Log("HLSL -> SPIR-V %s (%zu bytes)", spirv ? "ok" : "FAILED", spirv_size);

    char *msl = NULL;
    char *hlsl_again = NULL;
    if (spirv) {
        const SDL_ShaderCross_SPIRV_Info spirv_info = {
            .bytecode = spirv,
            .bytecode_size = spirv_size,
            .entrypoint = "main",
            .shader_stage = SDL_SHADERCROSS_SHADERSTAGE_COMPUTE,
        };
        msl = SDL_ShaderCross_TranspileMSLFromSPIRV(&spirv_info);
        SDL_Log("SPIR-V -> MSL  %s", msl ? "ok" : "FAILED");
        hlsl_again = SDL_ShaderCross_TranspileHLSLFromSPIRV(&spirv_info);
        SDL_Log("SPIR-V -> HLSL %s", hlsl_again ? "ok" : "FAILED");
    }

    const bool ok = spirv && msl && hlsl_again;
    if (!ok) {
        SDL_Log("%s", SDL_GetError());
    }

    SDL_free(hlsl_again);
    SDL_free(msl);
    SDL_free(spirv);
    SDL_ShaderCross_Quit();
    return ok ? 0 : 1;
}
