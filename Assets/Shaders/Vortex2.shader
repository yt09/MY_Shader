//片段着色器扭曲
Shader "YT09/Vortex2"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		radius("Radius",Float) = 0.0//绑定到材质属性里面，作为初始输入数据
		angle("Angle",Float) = 0.0//绑定到材质属性里面，作为初始输入数据
	}
		SubShader
		{
			Tags{ "RenderType" = "Opaque" }
			LOD 100

			Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

			struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;//UV纹理坐标
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		float radius; //扭曲的半径
		float angle; //扭曲的角度

					 //顶点
		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.uv;
			return o;

			////自己干预纹理坐标，下面的代码就是UV坐标的变换
			//float2 uv = v.uv;//获取顶点的纹理坐标[0,1]

			//				 //这两个参数不能写死在Shader里面，我们要改变这个值，才会有旋涡的动画效果
			//				 //float radius = 0.5f; //半径，表示多少范围内的图像发生扭曲，纹理坐标才0到1，所以0.5挺大的了
			//				 //float angle = 1.0f;//角度，单位是弧度，表示扭曲的程度，正弦计算的时候要用到的角度

			//uv -= float2(0.5, 0.5);//把UV坐标的原点转移到图像中心，就是以中心点为UV的原点，左下角变成了[-0.5，-0.5]
			//float dist = length(uv);//计算出当前的坐标到纹理中心的距离
			//float percent = (radius - dist) / radius;//计算出当前的坐标到纹理中心的距离占半径的百分比
			//if (percent < 1.0 && percent >= 0.0) {//如果百分比在0到1，说明当前的坐标在扭曲的范围内，执行扭曲
			//									  //扭曲算法
			//	float theta = percent * percent * angle * 8.0;
			//	float s = sin(theta);
			//	float c = cos(theta);
			//	uv = float2(dot(uv, float2(c, -s)), dot(uv, float2(s, c)));
			//}

			//uv += float2(0.5, 0.5);//变换回纹理坐标寻址的原点

			//o.uv = uv;//这样，顶点就有了对应纹理的坐标
			//return o;
		}

		//着色
		fixed4 frag(v2f i) : SV_Target
		{
			fixed2 uv = i.uv;
			uv -= fixed2(0.5, 0.5);//把UV坐标的原点转移到图像中心，就是以中心点为UV的原点，左下角变成了[-0.5，-0.5]
			float dist = length(uv);//计算出当前的坐标到纹理中心的距离
			float percent = (radius - dist) / radius;//计算出当前的坐标到纹理中心的距离占半径的百分比
			if (percent < 1.0 && percent >= 0.0) {//如果百分比在0到1，说明当前的坐标在扭曲的范围内，执行扭曲
												  //扭曲算法
			float theta = percent * percent * angle * 8.0;
			float s = sin(theta);
			float c = cos(theta);
			uv = float2(dot(uv, float2(c, -s)), dot(uv, float2(s, c)));
			}
			uv += fixed2(0.5, 0.5);//变换回纹理坐标寻址的原点
			//o.uv = uv;//这样，顶点就有了对应纹理的坐标
			fixed4 col = tex2D(_MainTex, uv);
		return col;
		}
			ENDCG
		}
		}
}