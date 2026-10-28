RWStructuredBuffer<float> values : register(u0, space1);

[numthreads(64, 1, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    values[id.x] *= 2.0;
}
