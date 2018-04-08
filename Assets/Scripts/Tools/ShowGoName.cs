using UnityEngine;
using System.Collections;
using UnityEngine.UI;

[RequireComponent(typeof(MeshCollider))]
public class ShowGoName : MonoBehaviour
{
    public string GoName;
    private GameObject InfoTextBG;
    private Text InfoText;

    private void Awake()
    {
        InfoTextBG = GameObject.FindGameObjectWithTag("Explain").transform.GetChild(0).gameObject;
        InfoText = InfoTextBG.transform.GetChild(0).GetComponent<Text>();
    }

    private void OnMouseOver()
    {
        InfoTextBG.SetActive(true);
        InfoText.text = GoName;
        InfoTextBG.gameObject.transform.position = Input.mousePosition + new Vector3(0, 40);
    }

    private void OnMouseExit()
    {
        InfoText.text = null;
        InfoTextBG.SetActive(false);
    }
}

//public class ShowGoName : MonoBehaviour
//{
//    public string GoName;
//    private GameObject InfoTextBG;
//    private Text InfoText;

//    void Awake()
//    {
//        InfoTextBG = GameObject.Find("界面").transform.Find("GoNameBG").gameObject;
//        InfoText = InfoTextBG.transform.Find("GoNameText").GetComponent<Text>();
//    }

//    void OnMouseOver()
//    {
//        if (GameSelect.IsTest)
//        {
//            InfoTextBG.SetActive(true);
//            InfoText.text = GoName;
//            InfoTextBG.gameObject.transform.position = Input.mousePosition + new Vector3(0, 40);
//        }
//    }

//    void OnMouseExit()
//    {
//        InfoText.text = null;
//        InfoTextBG.SetActive(false);
//    }
//}