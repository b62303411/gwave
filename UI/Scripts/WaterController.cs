using UnityEngine;
using System.Collections;
using System.Collections.Generic;
//Controlls the water
public class WaterController : MonoBehaviour
{

    [Header("Gerstner Waves Variables")]

    [SerializeField]
    private GerstnerData[] waveData;

    //[SerializeField]
    public Material material;

    public Game game;

    public void Start()
    {
        game = GetComponentInParent<Game>();

    }
    public void Update() {
        waveData = GetDataFromMaterial();
    }
    void Awake()
    {
        waveData = GetDataFromMaterial();
    }

    private GerstnerData genData(float _Wavelength, float steepness, Vector2 direction)
    {
        float k = 2 * 3.1416f / _Wavelength;
        float w = Mathf.Sqrt(9.81f * k);
        float c = Mathf.Sqrt(9.81f / k);
        return new GerstnerData(_Wavelength, w, steepness, direction);
    }
    public GerstnerData[] GetDataFromMaterial()
    {
        if (material != null)
        {
            GerstnerData[] data = getDataV2();
            return data;
        }

        // Debug.LogError("GetDataFromMaterial(): Material is NULL!");
        return waveData;
    }
    public GerstnerData getData(int wave)
    {
        Vector4 vector_w = material.GetVector("_w" + wave);
        return genData(vector_w.x, vector_w.y, new Vector2(vector_w.z, vector_w.w));
    }

    public GerstnerData[] getDataV2()
    {
        List<GerstnerData> list = new List<GerstnerData>();
        for (int i = 1; i < 5; i++)
        {
            Vector4 vector_w = material.GetVector("_w" + i);
            list.Add(getData(i));
        }

        return list.ToArray();
    }

    public GerstnerData[] getDataV1()
    {

        List<GerstnerData> list = new List<GerstnerData>();
        for (int i = 1; i < 5; i++)
        {
            list.Add(genData(material.GetFloat("_w" + i + "_wl"), material.GetFloat("_w" + i + "_s"), material.GetVector("_w" + i + "_d_n")));
        }
        return list.ToArray();

    }

    public void setWaveLenght(int selectedWave, float wl)
    {
        string vectorName = "_w" + selectedWave;
        Vector4 waveData = material.GetVector(vectorName);
        waveData.x = wl;
        material.SetVector(vectorName, waveData);
    }

    public void setSteepness(int selectedWave, float steepness)
    {
        string vectorName = "_w" + selectedWave;
        Vector4 waveData = material.GetVector(vectorName);
        waveData.y = steepness;
        material.SetVector(vectorName, waveData);
    }

    public void SetData(GerstnerData data1, GerstnerData data2, GerstnerData data3)
    {
        /*
        if (material != null)
        {
            GerstnerData[] data = { data1, data2, data3 };
            waveData = data;

            material.SetFloat("Wavelength1", data1.WaveLength);
            material.SetFloat("Speed1", data1.Speed);
            material.SetFloat("Steepness1", data1.Steepness);
            material.SetVector("Direction1", data1.Direction);

            material.SetFloat("Wavelength2", data2.WaveLength);
            material.SetFloat("Speed2", data2.Speed);
            material.SetFloat("Steepness2", data2.Steepness);
            material.SetVector("Direction2", data2.Direction);

            material.SetFloat("Wavelength3", data3.WaveLength);
            material.SetFloat("Speed3", data3.Speed);
            material.SetFloat("Steepness3", data3.Steepness);
            material.SetVector("Direction3", data3.Direction);
        }
        else
        {
            Debug.LogError("SetDataInMaterial(): Material is NULL!");
        }
        */
    }

    public Vector3 getDisplacement(Vector3 position) 
    {
        float time = Time.timeSinceLevelLoad;
        Vector3 displacement = GetWaveAddition(position, time);
        /*
        for (int i = 0; i < 3; i++)
        {
            Vector3 diff = new Vector3(position.x - currentPosition.x, 0, position.z - currentPosition.z);
            currentPosition = GetWaveAddition(diff, time);
        }*/

        return displacement;
    }

    public float getHeightAtPosition(Vector3 position)
    {
        Vector3 displacement = getDisplacement(position);

        return displacement.y;
    }

    public Vector3 GetWaveAddition(Vector3 position, float timeSinceStart)
    {
        Vector3 result = new Vector3();

        foreach (GerstnerData data in waveData)
        {
            result += WaveTypes.GerstnerWave(position, data.Direction, data.Steepness, data.WaveLength, data.Speed, timeSinceStart);
        }

        return result;
    }

    public void setActivateTextureNormals(bool isActive)
    {
        int _isActive = 0;
        if (isActive)
            _isActive = 1;
        material.SetInt("_Activate_Texture_Normal", _isActive);
    }

    public void set_depth(float _depth)
    {
        material.SetFloat("_depth", _depth);
    }

    public void setWaveHeight(float height)
    {
        material.SetFloat("_wave_height", height);
    }

    public void setRefraction(float refraction)
    {
        material.SetFloat("_refraction", refraction);
    }

    public WaveSettingsData getSettingsFromMaterial()
    {
        WaveSettingsData data = new WaveSettingsData();
        data.activateTextureNormals = material.GetInt("_Activate_Texture_Normal") > 0;
        data.alphaDepth = material.GetInt("_alpha_depth") > 0;
        data.depth = material.GetFloat("_depth");
        data.waveHeight = material.GetFloat("_wave_height");
        data.refraction = material.GetFloat("_refraction");
        return data;
    }
}

[System.Serializable]
public class GerstnerData
{
    [Header("Gerstner Data")]
    public float WaveLength = 0.1f;
    public float Speed = 0.1f;
    [Range(0.0f, 1.0f)] public float Steepness = 0.5f;
    public Vector2 Direction = new Vector2(1, 0);

    public GerstnerData(float WaveLength, float Speed, float Steepness, Vector2 Direction)
    {
        this.WaveLength = WaveLength;
        this.Speed = Speed;
        this.Steepness = Steepness;
        this.Direction = Direction;
    }
}
public class WaveSettingsData
{
    public bool activateTextureNormals;
    public bool waveHeightTransparency;
    public bool alphaDepth;
    public float depth;
    public float waveHeight;
    public float refraction;
    public float waveLenght;


}