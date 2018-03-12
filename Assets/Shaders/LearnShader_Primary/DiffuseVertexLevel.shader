//逐顶点漫反射光照模型
Shader "Learn/Lighting Model/DiffuseVertexLevel"
{
	Properties
	{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
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
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;	
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 color:COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)_World2Object));
				//应该使用(float3x3)_Object2World的逆转置矩阵变换法线
				//所以变换mul参数位置,使用_Object2World的逆矩阵_World2Object
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse =_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));
				
				o.color= ambient + diffuse;
				
				return o;
			}

			fixed3 frag(v2f i):SV_Target
			{
				return fixed4(i.color,1.0);
			}
		
			ENDCG
		}
	
	}
	Fallback "Diffuse"
}