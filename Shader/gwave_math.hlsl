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


void GerstnerWave(float3 position, float3 direction, float wavelength, float steepness, inout float3 displacement, inout float3 tangent, inout float3 binormal)
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
    float amplitude = steepness / wavenumber;

    // #8 Km is equal to the wave number.
    float km = wavenumber;

    displacement.x += -(k.x/km * amplitude * sin(theta));
    displacement.y += amplitude * cos(theta);
    displacement.z += -(k.z/km * amplitude * sin(theta));

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


void gw(float3 position, float4 wave, inout float3 displacement, inout float3 tangent, inout float3 binormal)
{

    float wl = wave.x;
    float s = wave.y;
    float3 direction;

    direction.x = wave.z;
    direction.y = 0;
    direction.z = wave.w;

    float3 normalized_direction = normalize(direction);

    GerstnerWave(position, normalized_direction, wl, s, displacement, tangent, binormal);
}

void  gwaves_math_float(float3 position, float4 w1, float4 w2, float4 w3, float4 w4, float4 w5, out float3 displacement, out float3 normal, out float3 tangent)
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

    gw(position, w1, displacement, tangent, binormal);
    gw(position, w2, displacement, tangent, binormal);
    gw(position, w3, displacement, tangent, binormal);
    gw(position, w4, displacement, tangent, binormal);
    gw(position, w5, displacement, tangent, binormal);

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
#endif //GWAVEHLSLINCLUDE_INCLUDED