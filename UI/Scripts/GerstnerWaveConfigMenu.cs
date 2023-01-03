using System.Globalization;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class GerstnerWaveConfigMenu : MonoBehaviour
{
    public Game game;
    public WaterController waterController;
    public UISettingsData settingsData;
    public UIData GerstnerUI1;
    public UIData GerstnerUI2;
    public UIData GerstnerUI3;
    bool valueHasChanged=false;
    [SerializeField] private TMPro.TextMeshProUGUI debugText;
   

    // Start is called before the first frame update
    void Start()
    {
        GameObject go = GameObject.Find("WaterController");
        if (null == go)
        {
            Debug.LogError("Could not find WaterController");
        }
        else 
        {
            waterController = go.GetComponent<WaterController>();
            if (null == waterController)
            {
                Debug.LogError("WaterController does not contains the WaterController script !!");
            }
            else 
            {
                GetData();
            }
        }
  
        
     
        settingsData.activateTextureNormals.onValueChanged.AddListener(delegate {
            //changeActivateTextureNormals(settingsData.activateTextureNormals);
            valueHasChanged = true;
        });
        settingsData.depth.onValueChanged.AddListener(delegate {
            //changeActivateTextureNormals(settingsData.activateTextureNormals);
            valueHasChanged = true;
        });

        settingsData.waveLenght.onValueChanged.AddListener(delegate {
            //changeActivateTextureNormals(settingsData.activateTextureNormals);
            valueHasChanged = true;
        });

        settingsData.refraction.onValueChanged.AddListener(delegate {
            //changeActivateTextureNormals(settingsData.activateTextureNormals);
            valueHasChanged = true;
        });

        settingsData.waveSelection.onValueChanged.AddListener(delegate {
            //changeActivateTextureNormals(settingsData.activateTextureNormals);
            valueHasChanged = true;
        });

    }

    void updateFromUiValue() 
    {
        changeActivateTextureNormals(settingsData.activateTextureNormals);
        setDepth(settingsData.depth);
        //setWaveHeight(settingsData.waveHeight);
        setRefraction(settingsData.refraction);
        valueHasChanged = false;
    }
    void setWaveHeight(Slider slider) 
    {
        waterController.setWaveHeight(slider.value);
    }
    void setDepth(Slider slider) 
    {
        waterController.set_depth(slider.value);
    }
    void changeActivateTextureNormals(Toggle toggle) 
    {
        waterController.setActivateTextureNormals(toggle.isOn);
    }

    void setRefraction(Slider slider) 
    {
        waterController.setRefraction(slider.value);
    }

    private void Update() {
   

        if (valueHasChanged && game.isGamePaused == true) 
        {
            updateFromUiValue();
        }

    }

    void GetData()
    {
        if((null == waterController)==false) { 
        GerstnerData[] waveData = waterController.GetDataFromMaterial();
        WaveSettingsData settings = waterController.getSettingsFromMaterial();
            if (null == settings)
            {
                Debug.LogError("Returning null from material !!");
            }
            else
            {
                if (null == settingsData)
                {
                    Debug.LogError("settingsData is null");
                }
                else
                {
                    settingsData.activateTextureNormals.isOn = settings.activateTextureNormals;
                    settingsData.depth.value = settings.depth;
                    settingsData.waveLenght.value = settings.waveLenght;
                }
            }
        }
    
    //GerstnerUI1.speed.text = waveData[0].Speed.ToString();
    //GerstnerUI1.steepness.text = waveData[0].Steepness.ToString();
    //GerstnerUI1.wavelength.text = waveData[0].WaveLength.ToString();
    //GerstnerUI1.dir_x.text = waveData[0].Direction.x.ToString();
    //GerstnerUI1.dir_y.text = waveData[0].Direction.y.ToString();

    //GerstnerUI2.speed.text = waveData[1].Speed.ToString();
    //GerstnerUI2.steepness.text = waveData[1].Steepness.ToString();
    //GerstnerUI2.wavelength.text = waveData[1].WaveLength.ToString();
    //GerstnerUI2.dir_x.text = waveData[1].Direction.x.ToString();
    //GerstnerUI2.dir_y.text = waveData[1].Direction.y.ToString();

    //GerstnerUI3.speed.text = waveData[2].Speed.ToString();
    //GerstnerUI3.steepness.text = waveData[2].Steepness.ToString();
    //GerstnerUI3.wavelength.text = waveData[2].WaveLength.ToString();
    //GerstnerUI3.dir_x.text = waveData[2].Direction.x.ToString();
    //GerstnerUI3.dir_y.text = waveData[2].Direction.y.ToString();
    }

    public void SetData()
    {
        if (Single.TryParse(GerstnerUI1.wavelength.text, out float wavelength_1)
            && Single.TryParse(GerstnerUI1.steepness.text, out float steepness_1)
            && Single.TryParse(GerstnerUI1.speed.text, out float speed_1)
            && Single.TryParse(GerstnerUI1.dir_x.text, out float dir_x_1)
            && Single.TryParse(GerstnerUI1.dir_y.text, out float dir_y_1)

            && Single.TryParse(GerstnerUI2.wavelength.text, out float wavelength_2)
            && Single.TryParse(GerstnerUI2.steepness.text, out float steepness_2)
            && Single.TryParse(GerstnerUI2.speed.text, out float speed_2)
            && Single.TryParse(GerstnerUI2.dir_x.text, out float dir_x_2)
            && Single.TryParse(GerstnerUI2.dir_y.text, out float dir_y_2)
            
            && Single.TryParse(GerstnerUI3.wavelength.text, out float wavelength_3)
            && Single.TryParse(GerstnerUI3.steepness.text, out float steepness_3)
            && Single.TryParse(GerstnerUI3.speed.text, out float speed_3)
            && Single.TryParse(GerstnerUI3.dir_x.text, out float dir_x_3)
            && Single.TryParse(GerstnerUI3.dir_y.text, out float dir_y_3))
        {
            debugText.text = "";

            GerstnerData data1 = new GerstnerData(wavelength_1, speed_1, steepness_1, new Vector2(dir_x_1, dir_y_1));
            GerstnerData data2 = new GerstnerData(wavelength_2, speed_2, steepness_2, new Vector2(dir_x_2, dir_y_2));
            GerstnerData data3 = new GerstnerData(wavelength_3, speed_3, steepness_3, new Vector2(dir_x_3, dir_y_3));

            // Set Material Data
            waterController.SetData(data1, data2, data3);
            // Update CPU Data
            waterController.GetDataFromMaterial();
        }
        else
        {
            debugText.text = "error in input!";
        }
    }

}


[System.Serializable]
public class UIData 
{
    public TMPro.TMP_InputField steepness;
    public TMPro.TMP_InputField wavelength;
    public TMPro.TMP_InputField speed;
    public TMPro.TMP_InputField dir_x;
    public TMPro.TMP_InputField dir_y;
}

[System.Serializable]
public class UISettingsData
{
    public Dropdown waveSelection;
    public Toggle activateTextureNormals;
    public Toggle waveHeightTransparency;
    public Toggle alphaDepth;
    public Slider refraction;
    public Slider depth;
    public Slider waveLenght;
    public Slider steepness;
}
