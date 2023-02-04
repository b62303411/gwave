#ifndef GWAVEHLSLINCLUDE_INCLUDED
#define GWAVEHLSLINCLUDE_INCLUDED



float CalculateWaveNumber(float wavelength)
{
    float g = 9.80665;
    float pi = 3.14159265358979323846;
    return 2 * pi / wavelength;
}

float CalculateFrequency(float wavelength, float steepness)
{
    float g = 9.80665;
    float pi = 3.14159265358979323846;
    float k = CalculateWaveNumber(wavelength);
    float omega = sqrt(g * k);
    return omega / (2 * pi);
}

float CalculatePeriod(float frequency)
{
    return 1 / frequency;
}

// Calculate the amplitude of a wave given its steepness and wavelength
float CalculateAmplitude(float steepness, float wavelength)
{
    float g = 9.80665;
    float pi = 3.14159265358979323846;

    // Calculate the wavenumber of the wave
    float wavenumber = 2 * pi / wavelength;

    // Calculate the amplitude of the wave using the formula provided above
    float amplitude = steepness / wavenumber;

    // Return the calculated amplitude
    return amplitude;
}

float CalculateAngularFrequency(float period)
{
    float g = 9.80665;
    float pi = 3.14159265358979323846;
    return 2 * pi / period;
}


void GerstnerWave(float h, float3 position, float3 direction, float wavelength, float steepness, inout float3 displacement, inout float3 tangent, inout float3 binormal)
{
    float g = 9.80665;
    float pi = 3.14159265358979323846;
    // Parameters for the wave

    // #1 Compute the wave frequency and speed from the steepness and wavelength
    float frequency = g / (2 * pi * wavelength);

    // #2 Compute the angularfrequency 
    float angularFrequency = sqrt(g * wavelength);

    // #3 Compute the wave number
    float wavenumber = 2 * pi / wavelength;

    // #4 Create vector k.
    float3 k = direction * wavenumber;

    // #5 Compute the speed.
    float w = sqrt(g * wavenumber);

    // #6 compute theta.
    float theta = dot(k.xz, position.xz) - (w * _Time.y);
    
    // #7 compute amplitude.
    //wavenumber*h
    float value = min(0.01, h * wavenumber);
    float amplitude = (steepness / wavenumber);

    // #8 Km is equal to the wave number.
    float km = wavenumber;
    float depthAttenuationFactor =h;
   
    displacement.x += depthAttenuationFactor * -(k.x/km * amplitude * sin(theta));
    displacement.y += depthAttenuationFactor * amplitude * cos(theta);
    displacement.z += depthAttenuationFactor * -(k.z/km * amplitude * sin(theta));

    // ds/dx partial derivative for the tengeant.
    tangent.x += -(amplitude * k.x * k.x * cos(theta)) / km;
    tangent.y += -amplitude * k.x * sin(theta);
    tangent.z += -(amplitude * k.x * k.z * cos(theta)) / km;

    // ds/dz partial derivative for the binormal.
    binormal.x += -((amplitude * k.x * k.z * cos(theta)) / km);
    binormal.y += -(amplitude * k.z * sin(theta));
    binormal.z += -((amplitude * k.z * k.z * cos(theta)) / km);

    // Return the displacement as a float3 value

}


void gw(float h, float3 position, float4 wave, inout float3 displacement, inout float3 tangent, inout float3 binormal)
{

    float wl = wave.x;
    float s = wave.y;
    float3 direction;

    direction.x = wave.z;
    direction.y = 0;
    direction.z = wave.w;

    float3 normalized_direction = normalize(direction);

    GerstnerWave(h,position, normalized_direction, wl, s, displacement, tangent, binormal);
}

void  heightFromPixel_float(float height, out float percent) 
{
    percent = 0;
}

void  gwaves_math_float(float3 position, float4 w1, float4 w2, float4 w3, float4 w4, float4 w5,float h, out float3 displacement, out float3 normal, out float3 tangent)
{
    tangent.x = 1;
    tangent.y = 0;
    tangent.z = 0;

    float3 binormal;
    binormal.x = 0;
    binormal.y = 0;
    binormal.z = 1;

    displacement.x = 0;
    displacement.y = 0;
    displacement.z = 0;

    gw(h,position, w1, displacement, tangent, binormal);
    gw(h,position, w2, displacement, tangent, binormal);
    gw(h,position, w3, displacement, tangent, binormal);
    gw(h,position, w4, displacement, tangent, binormal);
    gw(h,position, w5, displacement, tangent, binormal);

    normal = normalize(cross(tangent, binormal));
    tangent = normalize(tangent);



}

void getLightDirection_float(out float3 lightDir)
{

#if (SHADERPASS == SHADERPASS_FORWARD)
    lightDir = _WorldSpaceLightPos0;
#else
    lightDir = float3(0, 1, 0);
#endif
    //Light mainLight = GetMainLight();
    //Color = mainLight.color;
    //direction = mainLight.direction;
    //Attenuation = mainLight.distanceAttenuation;
    //direction = _WorldSpaceLightPos0;
    //direction = float3(1, 1, 1);
}

SAMPLER(sampler_MainTex);
void TriplanarSample_float(Texture2D _MainTex, float3 _WorldPos, float _Scale,out float4 result)
{
    float3 xaxis = normalize(_WorldPos + float3(1, 0, 0));
    float3 yaxis = normalize(_WorldPos + float3(0, 1, 0));
    float3 zaxis = normalize(_WorldPos + float3(0, 0, 1));
    float3 uv = _WorldPos.zyx;
    float3 uv2 = _WorldPos.yxz;
    float3 uv3 = _WorldPos.xyz;
    
    float3 diffuseTerm = (_MainTex.Sample(sampler_MainTex, uv.xy).rgb + _MainTex.Sample(sampler_MainTex, uv2.xy).rgb + _MainTex.Sample(sampler_MainTex, uv3.xy).rgb) / 3.0;
    float3 dTn = normalize(diffuseTerm);
    
    float3 absWPos = abs(_WorldPos);
    float3 nWPos = _WorldPos / max(absWPos.x, max(absWPos.y, absWPos.z));

    float3x3 rotation = float3x3(
        float3(1, 0, 0),
        float3(0, 0, -1),
        float3(0, 1, 0)
        );

    float3 pX = nWPos;
    float3 pY = mul(rotation, nWPos);
    float3 pZ = mul(rotation, pY);

    float3x3 scale = float3x3(
        float3(_Scale, 0, 0),
        float3(0, _Scale, 0),
        float3(0, 0, _Scale)
        );

    pX = mul(pX, scale);
    pY = mul(pY, scale);
    pZ = mul(pZ, scale);
    //Texture2D _MainTexA;

    // ...
    half4 colorCxz = _MainTex.Sample(sampler_MainTex, _WorldPos.xz);
    half4 colorCx = _MainTex.Sample(sampler_MainTex, pX.xy);
    half4 colorCy = _MainTex.Sample(sampler_MainTex, pX.yz);
    half4 colorCz = _MainTex.Sample(sampler_MainTex, pX.xz);

    //SamplerState sampler_MainTex;

    //float4 cX = _MainTex.Sample(sampler_MainTex,pX.xy);
    //float4 cY = _MainTex.Sample(sampler_MainTex,pY.yz);
    //float4 cZ = _MainTex.Sample(sampler_MainTex,pZ.xz);

    //float3 weight = (absWPos.x > absWPos.y && absWPos.x > absWPos.z) ? nWPos.xz : ((absWPos.y > absWPos.z) ? nWPos.xy : nWPos.yz);
    float2 weight = (absWPos.x > absWPos.y && absWPos.x > absWPos.z) ? nWPos.xz : ((absWPos.y > absWPos.z) ? nWPos.xy : nWPos.yz);
    weight = 0.5 * weight + 0.5;
    //float2 test = colorCx * weight.x + colorCy * weight.y;
    float2 test = colorCx + colorCy;
    float4 other_test = (test.x, test.y, 0, 0);
    float3 dif = diffuseTerm * _Scale;
    result = (dTn.x, dTn.y, dTn.z, .5);
}


#endif //GWAVEHLSLINCLUDE_INCLUDED