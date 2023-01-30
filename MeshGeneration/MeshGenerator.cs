using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGenerator : MonoBehaviour
{
    Mesh mesh;
    Vector3[] vertices;
    int[] triangles;

    // Start is called before the first frame update
    void Start()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        GetComponent<MeshCollider>().sharedMesh = mesh;
        createShape();
        updateMesh();
    }
    void updateMesh()
    {
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();

    }
    void addPoint(Vector3 point)
    {

    }

    int getIndexOfCoordinate(int x, int y)
    {
        int indexOfCoordinate = y * 100 + x;
        return indexOfCoordinate;
    }

    void createShape()
    {

        List<Vector3> verticesArray = new List<Vector3>();
        for (int x = 0; x < 100; x++)
        {
            for (int y = 0; y < 100; y++)
            {
                verticesArray.Add(new Vector3(x, 0, y));
            }
        }

        vertices = verticesArray.ToArray();


        int nbcol = 50;
        int nbrow = 50;

        int t1_1;
        int t1_2;
        int t1_3;
        int t2_1;
        int t2_2;
        int t2_3;
        List<int> triangleArray = new List<int>();
        for (int y = 0; y < 99; y++)
        {
            for (int x = 0; x < 99; x++)
            {
                int indexOfCoordinate = getIndexOfCoordinate(x, y);
                t1_1 = indexOfCoordinate;
                t1_2 = indexOfCoordinate + 1;
                t1_3 = getIndexOfCoordinate(x, y + 1);

                t2_1 = indexOfCoordinate + 1;
                t2_2 = getIndexOfCoordinate(x + 1, y + 1);
                t2_3 = getIndexOfCoordinate(x, y + 1);

                triangleArray.Add(t1_1);
                triangleArray.Add(t1_2);
                triangleArray.Add(t1_3);
                triangleArray.Add(t2_1);
                triangleArray.Add(t2_2);
                triangleArray.Add(t2_3);

            }
        }

        triangles = triangleArray.ToArray();
    }
}
