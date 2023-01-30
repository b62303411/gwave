using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CreateDisplacementTexture : MonoBehaviour
{
    public RenderTexture displacementTexture;
    public RenderTexture previousTexture;
    public ComputeShader computeShader;
    public Vector3 speed;
    public Vector3 position;
    public float value;
    public int nx = 255;
    public int ny = 255;
    public float c = 1f;
    RenderTexture Result;
    RenderTexture old_z_tex;
    RenderTexture z_tex;
    Texture2D dataTexture;
    Vector3[] data;
    
        // Start is called before the first frame update
    void Start()
    {
    
        dataTexture = new Texture2D(nx, ny, TextureFormat.RG32, false);
        //dataTexture.enableRandomWrite = true;
        //dataTexture.Create();

        data = new Vector3[nx * ny];
        InitWave((int)position.x-1, (int)position.y, 200f, new Vector2(-1, 0));
        InitWave((int)position.x+1, (int)position.y, 200f, new Vector2(1, 0));
        InitWave((int)position.x, (int)position.y-1, 200f, new Vector2(0, -1));
        InitWave((int)position.x, (int)position.y+1, 200f, new Vector2(0, 1));

        dataTexture.Apply();
        //write data back to the RenderTextures
        Graphics.Blit(dataTexture, displacementTexture);
        
        Result = new RenderTexture(256, 256, 24);
        Result.enableRandomWrite = true;
        Result.Create();

        old_z_tex = new RenderTexture(256, 256, 24);
        old_z_tex.enableRandomWrite = true;
        old_z_tex.Create();

        // Create the texture
        z_tex = new RenderTexture(256, 256, 24);
        z_tex.enableRandomWrite = true;
        z_tex.Create();

    }

    void InitWave(int x, int y,float amplitude,Vector2 direction)
    {
   
        //get data from the RenderTextures
        //displacementTexture.GetData(data);
        
        data[y * nx + x] = new Vector3(amplitude, direction.x,direction.y);

        dataTexture.SetPixel(x, y, new Color(amplitude, direction.x, direction.y, 0));


    }
    
    Vector3 getData(int x, int y) 
    {
        return data[y * nx + x];
    }

    Vector3 getData(Vector2 pos) 
    {
        return data[(int)pos.y * nx + (int)pos.x];
    }
    void setData(Vector2 pos, Vector3 value)
    {
         data[(int)pos.y * nx + (int)pos.x] = value;
    }

    void setData(int x, int y, Vector3 value)
    {
        data[y* nx + x] = value;
    }

    void updateCpu() 
    {
        float dt = Time.deltaTime;
        int width = 255 - 1;
        for (int y = 0; y < 255; y++)
        {
            for (int x = 0; x < 255; x++)
            {
                if (x >= 1 && x < width && y >= 1 && y < width)
                {
                    Vector2 id = new Vector2();
                    id.x = x;
                    id.y = y;
                    Vector3 cell = getData(id);
                    // Update the amplitude, velocity and phase based on the values of the surrounding pixels
                    Vector2 vel = new Vector2(cell.y,cell.z);
                    Vector2 right = new Vector2(x + 1, y);
                    Vector2 left = new Vector2(x - 1, y);
                    Vector2 top = new Vector2(x, y + 1);
                    Vector2 bottum = new Vector2(x, y - 1);
                    Vector3 right_cell = getData(right);
                    Vector3 top_cell = getData(top);
                    Vector3 left_cell = getData(left);
                    Vector3 bottum_cell = getData(bottum);


                    cell.x += dt * (right_cell.y + left_cell.y + top_cell.z + bottum_cell.z - 4 * vel.x);
                    Vector2 dvel = new Vector2();
                    dvel.x = vel.x + c * c * dt * (right_cell.x + left_cell.x + top_cell.x + bottum_cell.x - 4 * cell.x);
                    dvel.y = vel.y + c * c * dt * (right_cell.x + left_cell.x + top_cell.x + bottum_cell.x - 4 * cell.x);
                    cell.y = dvel.x;
                    cell.z = dvel.y;

                    //phaseTex[x, y] += dt * vel.x;
                    setData(x,y,cell);
                }
            }
        }

    }

    // Update is called once per frame
    void Update()
    {

        
        RenderTexture land_texture = new RenderTexture(256, 256, 24);
        land_texture.enableRandomWrite = true;
        land_texture.Create();
        RenderTexture old_collision_texture = new RenderTexture(256, 256, 24);
        old_collision_texture.enableRandomWrite = true;
        old_collision_texture.Create();
        RenderTexture collision_texture = new RenderTexture(256, 256, 24);
        collision_texture.enableRandomWrite = true;
        collision_texture.Create();
        //texture.updateMode = RenderTextureUpdateMode.Always;
        //texture.Create();

        // Find the kernel
        int kernel = computeShader.FindKernel("CSMain");
        Graphics.Blit(displacementTexture, Result);
        Graphics.Blit(displacementTexture, z_tex);
        // Set the texture as a global variable
        computeShader.SetTexture(kernel, "Result", Result);
        computeShader.SetTexture(kernel, "z_tex", z_tex);
        computeShader.SetTexture(kernel, "land_texture", land_texture);
        computeShader.SetTexture(kernel, "old_z_tex", old_z_tex);
        computeShader.SetTexture(kernel, "old_collision_texture", old_collision_texture);
        computeShader.SetTexture(kernel, "collision_texture", collision_texture);
        computeShader.SetFloat("a", 2);
        computeShader.SetFloat("amplitude", 2);
        computeShader.SetFloat("grid_points", 2);

        //RWTexture2D<float4> land_texture;
        //RWTexture2D<float4> z_tex;
        //RWTexture2D<float4> old_z_tex;
        //RWTexture2D<float4> collision_texture;
        //RWTexture2D<float4> old_collision_texture;

        // Set the speed and position variables
        //computeShader.SetVector("_Speed", new Vector4(speed.x, speed.y, 0,0));
        //computeShader.SetVector("_Position", new Vector4(position.x, position.y, 0,0));
        //computeShader.SetFloat("_Time", Time.time);
        //computeShader.SetFloat("c", c);
        //computeShader.SetFloat("dt", Time.deltaTime);
        value = 255*Mathf.Sin(Time.time / 500);
        // Dispatch the compute shader
        computeShader.Dispatch(kernel, 256 / 8, 256 / 8, 1);// Create the texture
        Graphics.Blit(Result, displacementTexture);
        Graphics.Blit(Result, old_z_tex);
        Graphics.Blit(collision_texture, old_collision_texture);
        
        //texture = new RenderTexture(256, 256, 24);
        //texture.enableRandomWrite = true;
        //texture.Create();

    }
}
