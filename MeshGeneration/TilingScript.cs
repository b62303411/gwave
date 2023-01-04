using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TilingScript : MonoBehaviour
{

    // The width and length of the tile grid
    public int gridWidth = 10;
    public int gridLength = 10;

    // The resolution of each tile
    public int tileResolution = 10;

    // The prefab for the tiles
    public GameObject tilePrefab;
    Vector3 getPosition(int x, int z, float tileSize,float totalWidth,float totalLength) 
    {
        Vector3 position = new Vector3(transform.position.x + x * tileSize - (totalWidth / 2), 0, transform.position.z+z * tileSize - (totalLength / 2));
        return position;
    }
    void Start()
    {
        // Calculate the size of each tile
        float tileSize = tileResolution;
        // Calculate the total size of the grid
        float totalWidth = tileSize * gridWidth;
        float totalLength = tileSize * gridLength;

        // Calculate the center of the grid
        Vector3 center = new Vector3(totalWidth / 2, 0, totalLength / 2);
        Vector3 myCenter = getPosition(5, 5, tileSize,totalWidth,totalLength);
        Vector3 test = getPosition(5, 9, tileSize, totalWidth, totalLength);
        float distance_test = Vector3.Distance(test, myCenter);
        // Instantiate the tiles
        for (int z = 0; z < gridLength; z++)
        {
            for (int x = 0; x < gridWidth; x++)
            {
                // Create a new tile at the correct position
                Vector3 position = getPosition(x, z, tileSize, totalWidth, totalLength);
                //float p_x = x * tileSize - (totalWidth / 2);
                //float p_z = z * tileSize - (totalLength / 2);

                GameObject tile = Instantiate(tilePrefab, position, Quaternion.identity);
                PlaneGeneration planeGen = tile.GetComponent<PlaneGeneration>();
                planeGen.width = tileResolution;
                planeGen.length = tileResolution;
                // Set the tile's parent to be this object
                tile.transform.parent = transform;
                tile.name = "Tile (" + x + ", " + z + ")";
                float distance = Mathf.Sqrt(Mathf.Pow(position.x, 2) + Mathf.Pow(position.z, 2));
                float distanceV = Vector3.Distance(position, myCenter);
                Debug.Log(distance);
                if (distance >= 250 && distance < 350)
                {
                    planeGen.setLod(25);
                }
                else if(distance >= 350 && distance < 550)
                {
                    planeGen.setLod(20);
                }
                else if (distance >= 550 && distance < 700)
                {
                    planeGen.setLod(10);
                }
                else if (distance >= 700 && distance < 1000)
                {
                    planeGen.setLod(5);
                }
                else if (distance >= 1000 && distance < 2000)
                {
                    planeGen.setLod(2);
                }
                else if (distance >= 3000)
                {
                    planeGen.setLod(2);
                }
                planeGen.generateMesh();
            }


        }
    }
}
