Shader "Gerstner Wave Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveAmplitude1 ("Wave Amplitude 1", Range(0, 1)) = 0.1
        _WaveFrequency1 ("Wave Frequency 1", Range(0, 1)) = 0.1
        _WaveDirection1 ("Wave Direction 1", Vector) = (1, 0, 0)
        _WaveAmplitude2 ("Wave Amplitude 2", Range(0, 1)) = 0.1
        _WaveFrequency2 ("Wave Frequency 2", Range(0, 1)) = 0.1
        _WaveDirection2 ("Wave Direction 2", Vector) = (1, 0, 0)
        _WaveAmplitude3 ("Wave Amplitude 3", Range(0, 1)) = 0.1
        _WaveFrequency3 ("Wave Frequency 3", Range(0, 1)) = 0.1
        _WaveDirection3 ("Wave Direction 3", Vector) = (1, 0, 0)
        _WaveAmplitude4 ("Wave Amplitude 4", Range(0, 1)) = 0.1
        _WaveFrequency4 ("Wave Frequency 4", Range(0, 1)) = 0.1
        _WaveDirection4 ("Wave Direction 4", Vector) = (1, 0, 0)
        _WaveAmplitude5 ("Wave Amplitude 5", Range(0, 1)) = 0.1
        _WaveFrequency5 ("Wave Frequency 5", Range(0, 1)) = 0.1
        _WaveDirection5 ("Wave Direction 5", Vector) = (1, 0, 0)
        _WaveAmplitude6 ("Wave Amplitude 6", Range(0, 1)) = 0.1
        _WaveFrequency6 ("Wave Frequency 6", Range(0, 1)) = 0.1
        _WaveDirection6 ("Wave Direction 6", Vector) = (1, 0, 0)
        _WaveAmplitude7 ("Wave Amplitude 7", Range(0, 1)) = 0.1
        _WaveFrequency7 ("Wave Frequency 7", Range(0, 1)) = 0.1
        _WaveDirection7 ("Wave Direction 7", Vector) = (1, 0, 0)
    }

    SubShader
    {
        // Set up the material and render queues
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        // Set up the passes and blending mode
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Set up the vertex and fragment shaders
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCO
			}
		}


// Define the custom function CalculateNormal
float3 CalculateNormal(float2 uv)
{
    // Calculate the normal using the partial derivatives of the Gerstner wave formula
    float3 normal;
    normal.x = (_WaveAmplitude1 * _WaveFrequency1 * cos(dot(uv, _WaveDirection1) + _Time.y * _WaveFrequency1) * _WaveDirection1.x) +
               (_WaveAmplitude2 * _WaveFrequency2 * cos(dot(uv, _WaveDirection2) + _Time.y * _WaveFrequency2) * _WaveDirection2.x) +
               (_WaveAmplitude3 * _WaveFrequency3 * cos(dot(uv, _WaveDirection3) + _Time.y * _WaveFrequency3) * _WaveDirection3.x) +
               (_WaveAmplitude4 * _WaveFrequency4 * cos(dot(uv, _WaveDirection4) + _Time.y * _WaveFrequency4) * _WaveDirection4.x) +
               (_WaveAmplitude5 * _WaveFrequency5 * cos(dot(uv, _WaveDirection5) + _Time.y * _WaveFrequency5) * _WaveDirection5.x) +
               (_WaveAmplitude6 * _WaveFrequency6 * cos(dot(uv, _WaveDirection6) + _Time.y * _WaveFrequency6) * _WaveDirection6.x) +
               (_WaveAmplitude7 * _WaveFrequency7 * cos(dot(uv, _WaveDirection7) + _Time.y * _WaveFrequency7) * _WaveDirection7.x);
    normal.y = (_WaveAmplitude1 * _WaveFrequency1 * cos(dot(uv, _WaveDirection1) + _Time.y * _WaveFrequency1) * _WaveDirection1.y) +
               (_WaveAmplitude2 * _WaveFrequency2 * cos(dot(uv, _WaveDirection2) + _Time.y * _WaveFrequency2) * _WaveDirection2.y) +
               (_WaveAmplitude3 * _WaveFrequency3 * cos(dot(uv, _WaveDirection3) + _Time.y * _WaveFrequency3) * _WaveDirection3.y) +
               (_WaveAmplitude4 * _WaveFrequency4 * cos(dot(uv, _WaveDirection4) + _Time.y * _WaveFrequency4) * _WaveDirection4.y) +
               (_WaveAmplitude5 * _WaveFrequency5 * cos(dot(uv, _WaveDirection5) + _Time.y * _WaveFrequency5) * _WaveDirection5.y) +
               (_WaveAmplitude6 * _WaveFrequency6 * cos(dot(uv, _WaveDirection6) + _Time.y * _WaveFrequency6) * _WaveDirection6.y) +
               (_WaveAmplitude7 * _WaveFrequency7 * cos(dot(uv, _WaveDirection7) + _Time.y * _WaveFrequency7) * _WaveDirection7.y);
    normal.z = 1.0;
    return normalize(normal);
}

fixed4 frag (v2f i) : SV_Target
{
    // Calculate the wave height at the current position
    float waveHeight = (_WaveAmplitude1 * sin(dot(i.uv, _WaveDirection1) + _Time.y * _WaveFrequency1)) +
                       (_WaveAmplitude2 * sin(dot(i.uv, _WaveDirection2) + _Time.y * _WaveFrequency2)) +
                       (_WaveAmplitude3 * sin(dot(i.uv, _WaveDirection3) + _Time.y * _WaveFrequency3)) +
                       (_WaveAmplitude4 * sin(dot(i.uv, _WaveDirection4) + _Time.y * _WaveFrequency4)) +
                       (_WaveAmplitude5 * sin(dot(i.uv, _WaveDirection5) + _Time.y * _WaveFrequency5)) +
                       (_WaveAmplitude6 * sin(dot(i.uv, _WaveDirection6) + _Time.y * _WaveFrequency6)) +
                       (_WaveAmplitude7 * sin(dot(i.uv, _WaveDirection7) + _Time.y * _WaveFrequency7));

    // Offset the vertex position by the wave height
    float3 vertexPos = i.vertex.xyz + _ObjectToWorld.up * waveHeight;

    // Calculate the normal using the custom function CalculateNormal
    float3 normal = CalculateNormal(i.uv);

    // Calculate the lighting for the current pixel
    fixed4 lighting = LightingStandard(vertexPos, normal, -_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.w);

    // Sample the texture at the current UV coordinates
    fixed4 tex = tex2D(_MainTex, i.uv);

    // Multiply the texture color by the lighting value
    tex *= lighting;

    // Return the final pixel color
    return tex;
}
ENDCG
    }
}