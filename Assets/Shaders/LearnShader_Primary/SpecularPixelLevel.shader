//逐像素高光反射 光照模型
Shader "Learn/Lighting Model/SpecularPixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.worldNormal=mul(v.normal,(float3x3)_World2Object);

				o.worldPos=mul(_Object2World,v.vertex).xyz;
		
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//得到环境光
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT;
				
				//世界空间顶点法向量方向
				fixed3 worldNormal=normalize(i.worldNormal);
				//世界空间顶点光源方向
				fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);

				//计算漫反射部分光照
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));
				
				//计算世界空间反射光方向 入射光方向是反向的光源方向
				fixed3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));

				//计算世界空间 视角方向 =世界空间摄像机坐标-世界空间顶点坐标 (即 从顶点 指向 摄像机的方向向量)
				fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);

				//计算高光反射部分光照
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				fixed3 color=ambient+diffuse+specular;


				return fixed4(color,1.0);
			}

			ENDCG

		}
	}

	Fallback "Specular"
}
