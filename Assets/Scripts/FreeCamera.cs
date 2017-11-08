using UnityEngine;
using System.Collections;

/************************************************************
  Copyright (C), 2007-2017,BJ Rainier Tech. Co., Ltd.
  FileName: FreeCamera.cs
  Author:杨涛       Version :1.0          Date:2017.6.15
  Description:控制摄像机自由移动的功能
************************************************************/

public class FreeCamera : MonoBehaviour
{
    public float moveSpeed;

    //public Vector3 max;
    //public Vector3 min;
    private Vector3 pos;

    // Update is called once per frame
    private void FixedUpdate()
    {
        CameraMove();
        CameraRotate();
    }

    private float delta_X;
    private float delta_Y;

    private void CameraMove()
    {
        float h = Input.GetAxis("Horizontal") * Time.deltaTime * moveSpeed;
        float v = Input.GetAxis("Vertical") * Time.deltaTime * moveSpeed;
        float w = Input.GetAxis("Mouse ScrollWheel") * Time.deltaTime * moveSpeed;
        //if (Input.GetKey(KeyCode.LeftShift))
        //{
        //    h = h * moveSpeed;
        //    v = v * moveSpeed;
        //}
        //pos = transform.position;
        if (Input.GetMouseButton(2))
        {
            delta_X = Input.GetAxis("Mouse X") * moveSpeed / 10;
            delta_Y = Input.GetAxis("Mouse Y") * moveSpeed / 10;
        }
        else
        {
            delta_X = 0;
            delta_Y = 0;
        }

        //transform.Translate(h, 0, v + w);

        transform.position = transform.position + transform.rotation * new Vector3(-delta_X, -delta_Y, 0) + transform.rotation * new Vector3(h, 0, v + w);
        //Vector3 toPosition = transform.position + transform.rotation * new Vector3(delta_X, delta_Y, 0);
        //transform.position = toPosition;
        //if (transform.position.x <= min.x || transform.position.x >= max.x)
        //{
        //    transform.position = pos;
        //}
        //else if (transform.position.y <= min.y || transform.position.y >= max.y)
        //{
        //    transform.position = pos;
        //}
        //else if (transform.position.z <= min.z || transform.position.z >= max.z)
        //{
        //    transform.position = pos;
        //}
    }

    public enum RotationAxes { MouseXAndY = 0, MouseX = 1, MouseY = 2 }

    public RotationAxes axes = RotationAxes.MouseXAndY;
    public float sensitivityX = 15F;
    public float sensitivityY = 15F;

    public float minimumX = -360F;
    public float maximumX = 360F;

    public float minimumY = -60F;
    public float maximumY = 60F;

    private float rotationX = 0F;
    private float rotationY = 0F;

    private void CameraRotate()

    {
        if (Input.GetMouseButton(1))
        {
            if (axes == RotationAxes.MouseXAndY)
            {
                // Read the mouse input axis
                rotationX += Input.GetAxis("Mouse X") * sensitivityX;
                rotationY -= Input.GetAxis("Mouse Y") * sensitivityY;

                rotationX = ClampAngle(rotationX, minimumX, maximumX);
                rotationY = ClampAngle(rotationY, minimumY, maximumY);
                Quaternion mRotation = Quaternion.Euler(rotationY, rotationX, 0);

                transform.localRotation = Quaternion.Slerp(transform.localRotation, mRotation, Time.deltaTime * sensitivityX);
            }
            else if (axes == RotationAxes.MouseX)
            {
                rotationX += Input.GetAxis("Mouse X") * sensitivityX;
                rotationX = ClampAngle(rotationX, minimumX, maximumX);
                Quaternion mRotation = Quaternion.Euler(rotationY, rotationX, 0);
                transform.localRotation = Quaternion.Slerp(transform.localRotation, mRotation, Time.deltaTime * sensitivityX);
            }
            else
            {
                rotationY -= Input.GetAxis("Mouse Y") * sensitivityY;
                rotationY = ClampAngle(rotationY, minimumY, maximumY);
                Quaternion mRotation = Quaternion.Euler(rotationY, rotationX, 0);
                transform.localRotation = Quaternion.Slerp(transform.localRotation, mRotation, Time.deltaTime * sensitivityX);
            }
        }
    }

    private void Start()
    {
        rotationX = transform.rotation.eulerAngles.x;
        rotationY = transform.rotation.eulerAngles.y;
    }

    public static float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360F)
            angle += 360F;
        if (angle > 360F)
            angle -= 360F;
        return Mathf.Clamp(angle, min, max);
    }
}