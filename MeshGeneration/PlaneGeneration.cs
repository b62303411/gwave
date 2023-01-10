using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(MeshFilter))]
public class PlaneGeneration : MonoBehaviour
{
    public int Size = 20;
    public float scale = 1.0f;
    
    // The width and length of the plane
    public float width = 1.0f;
    public float length = 1.0f;

    // The number of segments in the plane's mesh
    public int widthSegments = 1;
    public int lengthSegments = 1;

    private Mesh mesh;
    private Vector3[] vertices;
    private int[] triangles;
    private Vector2[] uvs;
    private int verticiesLength = 0;
    public WaterController waterController;
    [SerializeField] private Transform debugSphere;
    [SerializeField] private bool isUpdatingOnCPU = false;


    // Start is called before the first frame update
    void Start()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        verticiesLength = (Size + 1) * (Size + 1);

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
        }


        generateMesh();
        //UpdatePlaneVerticies();
        //UpdateMesh();
    }
    public void setLod(int lod) 
    {
        widthSegments = lod;
        lengthSegments = lod;
    }
    public void generateMesh() 
    {
        // Create a new mesh for the plane
        //Mesh mesh = new Mesh();
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        // Create the vertices of the plane
        Vector3[] vertices = new Vector3[(widthSegments + 1) * (lengthSegments + 1)];
        for (int z = 0; z <= lengthSegments; z++)
        {
            for (int x = 0; x <= widthSegments; x++)
            {
                vertices[z * (widthSegments + 1) + x] = new Vector3(x * width / widthSegments - width / 2, 0, z * length / lengthSegments - length / 2);
            }
        }

        // Create the triangles of the plane
        int[] triangles = new int[widthSegments * lengthSegments * 6];
        for (int z = 0; z < lengthSegments; z++)
        {
            for (int x = 0; x < widthSegments; x++)
            {
                triangles[(z * widthSegments + x) * 6] = z * (widthSegments + 1) + x;
                triangles[(z * widthSegments + x) * 6 + 1] = (z + 1) * (widthSegments + 1) + x;
                triangles[(z * widthSegments + x) * 6 + 2] = (z + 1) * (widthSegments + 1) + x + 1;
                triangles[(z * widthSegments + x) * 6 + 3] = z * (widthSegments + 1) + x;
                triangles[(z * widthSegments + x) * 6 + 4] = (z + 1) * (widthSegments + 1) + x + 1;
                triangles[(z * widthSegments + x) * 6 + 5] = z * (widthSegments + 1) + x + 1;
            }
        }

        // Set the vertices and triangles of the mesh
        mesh.vertices = vertices;
        mesh.triangles = triangles;

        // Recalculate the normals of the mesh
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();

    }

    private void FixedUpdate() {

        if (isUpdatingOnCPU)
        {
            UpdatePlaneVerticies();
            UpdateMesh();
        }

        if (debugSphere != null) 
        {
            Vector3 newPos = debugSphere.position;
            float height = waterController.getHeightAtPosition(newPos) + transform.position.y;
            if(float.IsNaN(height) is false) 
            {
                newPos.y = height;
            }
            
            debugSphere.position = newPos;
        }
    }

    void UpdatePlaneVerticies()
    {
        vertices = new Vector3[verticiesLength];
        uvs = new Vector2[vertices.Length];

        float halfSizeX = (scale * Size) / 2;
        float halfSizeZ = (scale * Size) / 2;

		int i = 0;
		for (int z = 0; z <= Size; z++) 
        {
			for (int x = 0; x <= Size; x++) 
            {
                float xPos = (x * scale) - halfSizeX;
                float zPos = (z * scale) - halfSizeZ;
                float yPos = 0;

				vertices[i] = new Vector3(xPos, yPos, zPos);
                
                if (isUpdatingOnCPU)
                    vertices[i] += waterController.GetWaveAddition(vertices[i] + transform.position, Time.timeSinceLevelLoad);
				
                uvs[i] = new Vector2(vertices[i].x, vertices[i].z);
				i++;
			}
		}

        triangles = new int[Size * Size * 6];

		int vert = 0;
        int tris = 0;

		for (int z = 0; z < Size; z++) 
        {
			for (int x = 0; x < Size; x++) 
            {
				triangles[tris + 0] = vert + 0;
				triangles[tris + 1] = vert + Size + 1;
				triangles[tris + 2] = vert + 1;
				triangles[tris + 3] = vert + 1;
				triangles[tris + 4] = vert + Size + 1;
				triangles[tris + 5] = vert + Size + 2;

				vert++;
				tris += 6;
			}
			vert++;
		}
    }

    void UpdateMesh()
    {
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();
    }

}
