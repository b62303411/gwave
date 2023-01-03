#ifndef GWAVEHLSLINCLUDE_INCLUDED
#define GWAVEHLSLINCLUDE_INCLUDED



float CalculateWaveNumber(float wavelength)
{
	float g = 9.81;
	float pi = 3.14159265358979323846;
	return 2 * pi / wavelength;
}

float CalculateFrequency(float wavelength, float steepness)
{
	float g = 9.81;
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
	float g = 9.81;
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
	float g = 9.81;
	float pi = 3.14159265358979323846;
	return 2 * pi / period;
}

float3 GerstnerWave(float3 position, float3 direction, float wavelength, float steepness, inout float3 tangent, inout float3 binormal)
{
	float g = 9.81;
	float pi = 3.14159265358979323846;

	float3 displacement;
	
	// Parameters for the wave

	// Compute the wave frequency and speed from the steepness and wavelength
	float frequency = g / (2 * pi * wavelength);
	
	float angularFrequency = sqrt(g * wavelength);
	
	//float waveNumber = CalculateWaveNumber(wavelength);
	float wavenumber = 2 * pi / wavelength;

	//km = sqrt(pow(k.x,2)+ pow(k.z,2));
	float3 k = direction * wavenumber;

	float w = sqrt(g * wavenumber);

	float theta = dot(k.xz, position.xz) - (w * _Time.y);

	float amplitude = CalculateAmplitude(steepness, wavelength);
	
	float km = wavenumber;

	displacement.x = position.x - direction.x * amplitude * sin(theta);
	displacement.y = amplitude * cos(theta);
	displacement.z = position.z - direction.z * amplitude * sin(theta);
	
    // ds/dx partial derivative for the tengeant.
    tangent.x = 1 - (amplitude* k.x * k.x * cos(theta))/km;
	tangent.y = -amplitude * k.x * sin(theta);
	tangent.z = -(amplitude * k.x * k.z * cos(theta))/km;
	
	// ds/dz partial derivative for the binormal.
	binormal.x = - ((amplitude * k.x * k.z * cos(theta))/km);
	binormal.y = - (amplitude * k.z * sin(theta));
	binormal.z = 1 - ((amplitude * k.z * k.z * cos(theta))/km);

	// Return the displacement as a float3 value
	return displacement;
}


float3  gerstnerwave(float3 vertex, float3 direction, float wl, float s, inout float3 tangent, inout float3 binormal)
{
	float gravity = 9.81;
	float steepness = s;
	float wavelength = wl;
	float k = 2 * 3.141592653589793238 / wavelength;
	float c = sqrt(gravity / k);
	float w = sqrt(gravity * k);
	float2 d = normalize(direction.xz);
	float f = k * dot(d, vertex.xz) - (w * _Time.y);
	float a = steepness / k;

	tangent += float3(
		-d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
		);
	binormal += float3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		-d.y * d.y * (steepness * sin(f))
		);
	return float3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
		);
}
float3  gerstnerwaveAi(float3 vertex, float3 direction, float wl, float s, inout float3 tangent, inout float3 binormal)
{
	float g = 9.81;
	float pi = 3.14159265358979323846;

	float3 normalized_direction = normalize(direction);

	// Calculate the wave amplitude using the steepness and wavelength
	float amplitude = s * wl / 2.0;

	// Calculate the wave frequency based on the steepness and wavelength
	float frequency = sqrt(g * wl / (2.0 * pi)) / wl;
	//float f = k * dot(d, vertex.xz) - (w * _Time.y);
	// Calculate the wave displacement using the Gerstner wave formula
	float3 displacement = amplitude * sin(dot(vertex, normalized_direction) + frequency * _Time.y);

	// Calculate the partial differential of the Gerstner wave formula in the x direction
	float xDisplacement = amplitude * normalized_direction.x * cos(dot(vertex, normalized_direction) + frequency * _Time.y);

	// Calculate the partial differential of the Gerstner wave formula in the y direction
	float yDisplacement = amplitude * normalized_direction.y * cos(dot(vertex, normalized_direction) + frequency * _Time.y);



	// Calculate the normal using the partial differential values and the cross product

	tangent.x = xDisplacement;
	tangent.y = yDisplacement;
	tangent.z = 0.0;
	float3 const_vect;
	const_vect.x = 0;
	const_vect.y = 0;
	const_vect.z = 1;
	binormal = cross(tangent, const_vect);


	float3 waveNormal = cross(tangent, binormal);

	float wn = CalculateWaveNumber(wl);
	float frq = CalculateFrequency(wl, s);
	float period = CalculatePeriod(frq);
	float angular_frq = CalculateAngularFrequency(period);
	// Normalize the normal vector
	//normal = waveNormal;
	return GerstnerWave(vertex, normalized_direction, wl,s, tangent,binormal);
	//return gerstnerwave(vertex, direction, wl, s, tangent, binormal);
}
void  gwave_float(float3 vertex, float3 direction, float wl, float s, inout float3 tangent, inout float3 binormal, out float3 displacement)
{
	tangent = 0;
	binormal = 0;
	displacement = gerstnerwave(vertex, direction, wl, s, tangent, binormal);
}

void  gwave_ai_float(float3 vertex, float3 direction, float wl, float s, out float3 tangent, out float3 binormal, out float3 displacement)
{
	displacement = gerstnerwaveAi(vertex, direction, wl, s, tangent,binormal);
}

void gwaves_float(float3 vertex,float3 d,float large_wl, float large_s, float small_wl, float small_s, out float3 displacement,out float3 tangent,out float3 normal)
{
	float3 gridPoint = vertex.xyz;
	tangent = 0;
	float3 binormal = 0;
	float3 p = 0;
	
	for (uint i = 0; i < 25; i++) 
	{
		float wl = large_wl - i;
		float s = large_s;
		float3 wave_dir = 0;
		wave_dir.x = sin(i);
		wave_dir.z = cos(i);
		p += gerstnerwave(vertex, wave_dir,wl,s,tangent, binormal);
	}
	
	normal = normalize(cross(binormal, tangent));
	displacement = p;
	
}
#endif //GWAVEHLSLINCLUDE_INCLUDED