#ifndef CUSTOMHLINCLUDE_INCLUDED
#define CUSTOMHLINCLUDE_INCLUDED

void triplanar_float(UnityTexture2D colorMap, UnitySamplerState sampleState, float3 _worldPos, float Tile, out float4 result)
{
    float3 Node_UV = _worldPos * Tile;
    float2 uv = _worldPos.xz;
    result = SAMPLE_TEXTURE2D(colorMap, sampleState, Node_UV.xz);
}
#endif //GWAVEHLSLINCLUDE_INCLUDED