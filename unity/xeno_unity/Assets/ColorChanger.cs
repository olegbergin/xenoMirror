using UnityEngine;

public class ColorChanger : MonoBehaviour
{
    // Этот метод мы вызовем из Flutter
    public void SetColor(string message)
    {
        if (message == "red")
        {
            GetComponent<Renderer>().material.color = Color.red;
        }
        else if (message == "blue")
        {
            GetComponent<Renderer>().material.color = Color.blue;
        }
        else 
        {
             // Если пришло что-то странное - ставим зеленый
            GetComponent<Renderer>().material.color = Color.green;
        }
    }
}