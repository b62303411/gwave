#ifndef GWAVEHLSLINCLUDE_INCLUDED
#define GWAVEHLSLINCLUDE_INCLUDED
#include "UnityCG.cginc"


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

void  gwave_float(float3 vertex, float3 direction, float wl, float s, inout float3 tangent, inout float3 binormal, out float3 displacement)
{
	tangent = 0;
	binormal = 0;
	displacement = gerstnerwave(vertex, direction, wl, s, tangent, binormal);
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

void getLightDirection_float( out float3 direction)
{
	direction = float3(1, 1, 1);
}
#endif //GWAVEHLSLINCLUDE_INCLUDED