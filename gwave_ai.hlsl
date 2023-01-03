#ifndef GWAVEHLSLINCLUDE_INCLUDED
#define GWAVEHLSLINCLUDE_INCLUDED

float3 Direction(float4 wave)
{
	float3 direction;
	direction.x = wave.y;
	direction.y = 0;
	direction.z = wave.z;
	direction = normalize(direction);
	return direction;
}

float3 norm(float4 wave, float3 uv) 
{
	float3 normal;
	float _WaveAmplitude = wave.x;

	float3 _WaveDirection = Direction(wave);

	float _WaveFrequency = wave.w;
	
	// Calculate the partial differential of the Gerstner wave formula in the x direction
	float xDisplacement = _WaveAmplitude * _WaveDirection.x * cos(dot(uv, _WaveDirection.xy) + _Time.y * _WaveFrequency);

	// Calculate the partial differential of the Gerstner wave formula in the y direction
	float yDisplacement = _WaveAmplitude * _WaveDirection.y * cos(dot(uv, _WaveDirection.xy) + _Time.y * _WaveFrequency);

	// Calculate the partial differential of the Gerstner wave formula in the z direction
	float zDisplacement = _WaveAmplitude * _WaveDirection.z * cos(dot(uv, _WaveDirection.xy) + _Time.y * _WaveFrequency);

	normal.x = xDisplacement;
	normal.y = yDisplacement;
	normal.z = zDisplacement;
	//normal.x = (amplitude * frequency * cos(dot(uv, direction) + _Time.y * frequency) * direction.x);
	//normal.y = (amplitude * frequency * cos(dot(uv, direction) + _Time.y * frequency) * direction.y);

	return normal;
}

float3 CalculateNormal(float3 uv, float4 w1, float4 w2, float4 w3, float4 w4, float4 w5, float4 w6, float4 w7)
{
	// Calculate the normal using the partial derivatives of the Gerstner wave formula
	float3 normal;
	float3 norm_w1 = norm(w1, uv);
	float3 norm_w2 = norm(w2, uv);
	float3 norm_w3 = norm(w3, uv);
	float3 norm_w4 = norm(w4, uv);
	float3 norm_w5 = norm(w5, uv);
	float3 norm_w6 = norm(w6, uv);
	float3 norm_w7 = norm(w7, uv);

	normal.x = norm_w1.x + norm_w2.x + norm_w3.x+norm_w4.x+norm_w5.x+norm_w6.x+norm_w7.x;

	normal.y = norm_w1.y + norm_w2.y + norm_w3.y + norm_w4.y + norm_w5.y + norm_w6.y + norm_w7.y;

	normal.z = norm_w1.z + norm_w2.z + norm_w3.z + norm_w4.z + norm_w5.z + norm_w6.z + norm_w7.z;

	return normalize(normal);
}


float3 Displacement(float4 wave, float3 uv)
{
	float _WaveAmplitude = wave.x;
	float3 _WaveDirection= Direction(wave);
	float _WaveFrequency = wave.w;

	// Calculate the wave displacement in the x direction
	float xDisplacement = 0;//_WaveAmplitude * sin(dot(uv, _WaveDirection.xy) + _Time.y * _WaveFrequency);

	// Calculate the wave displacement in the y direction
	float yDisplacement = _WaveAmplitude * sin(uv.x + uv.z + _Time.y);//_WaveAmplitude * sin(dot(uv, _WaveDirection.yz) + _Time.y * _WaveFrequency);

	// Calculate the wave displacement in the z direction
	float zDisplacement = 0;//_WaveAmplitude * sin(dot(uv, _WaveDirection.xz) + _Time.y * _WaveFrequency);
	
	float3 displacement;
	displacement.x = xDisplacement;
	displacement.y = yDisplacement;
	displacement.z = zDisplacement;

	return displacement;
}

float3 CalculateDisplacement(float3 uv, float4 w1, float4 w2, float4 w3, float4 w4, float4 w5, float4 w6, float4 w7)
{
	float3 displacement;
	float3 disp_w1 = Displacement(w1, uv);
	float3 disp_w2 = Displacement(w2, uv);
	float3 disp_w3 = Displacement(w3, uv);
	float3 disp_w4 = Displacement(w4, uv);
	float3 disp_w5 = Displacement(w5, uv);
	float3 disp_w6 = Displacement(w6, uv);
	float3 disp_w7 = Displacement(w7, uv);

	displacement = disp_w1 + disp_w2 + disp_w3+disp_w4+disp_w5+disp_w6+disp_w7;

	return displacement;
}

void gwaves_float(float3 vertex, float4 w1, float4 w2, float4 w3, float4 w4, float4 w5, float4 w6, float4 w7, out float3 displacement, out float3 normal)
{
	displacement = CalculateDisplacement(vertex, w1, w2, w3, w4, w5, w6, w7);

	normal = CalculateNormal(vertex, w1, w2, w3, w4, w5, w6, w7);
}

void sinwave_float(float3 vertex,out float3 displacement) 
{
	float dy = sin(vertex.x + vertex.z);
	float3 tempVariable;
	tempVariable.x = 0;
	tempVariable.y = dy;
	tempVariable.z = 0;

	displacement = tempVariable;
}
#endif //GWAVEHLSLINCLUDE_INCLUDED