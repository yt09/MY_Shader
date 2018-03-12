//前向渲染中处理不同的光照
Shader "Learn Medium/ForwardRendering"
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
			
			//为了获得正确的光照变量 在处理最亮平行光和所有顶点光照 的 pass里要添加这一句
			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

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

				//o.worldNormal=mul(v.normal,(float3x3)_World2Object);
				o.worldNormal=UnityObjectToWorldNormal(v.normal);

				o.worldPos=mul(_Object2World,v.vertex).xyz;
				//o.worldPos=UnityObjectToWorldDir(v.vertex.xyz);
						
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//得到环境光
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				//世界空间顶点法向量方向
				fixed3 worldNormal=normalize(i.worldNormal);
				//世界空间顶点光源方向
				//fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);


				//计算漫反射部分光照
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*max(0,dot(worldNormal,worldLightDir));
				
				//计算世界空间 视角方向 =世界空间摄像机坐标-世界空间顶点坐标 (即 从顶点 指向 摄像机的方向向量)
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));

				//计算中间值 
				fixed3 tempDir=normalize(worldLightDir+viewDir);

				//计算高光反射部分光照
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tempDir,worldNormal)),_Gloss);

				//衰减值 attenuation
				fixed atten=1.0;



				return fixed4(ambient+(diffuse+specular)*atten,1.0);
			}

			ENDCG

		}

		Pass
		{
			Tags{"LightMode"="ForwardAdd"}

			//每个逐像素光照到物体的结果颜色混合
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//为了获得正确的光照变量 在处理逐像素光照的pass里要添加这一句
			#pragma muti_compile_fwdadd

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

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

				//o.worldNormal=mul(v.normal,(float3x3)_World2Object);
				o.worldNormal=UnityObjectToWorldNormal(v.normal);

				o.worldPos=mul(_Object2World,v.vertex).xyz;
				//o.worldPos=UnityObjectToWorldDir(v.vertex.xyz);
						
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
			
				
				//世界空间顶点法向量方向
				fixed3 worldNormal=normalize(i.worldNormal);
				//世界空间顶点光源方向
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz-i.worldPos);
				#endif

				//计算漫反射部分光照
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*max(0,dot(worldNormal,worldLightDir));
				
				//计算世界空间 视角方向 =世界空间摄像机坐标-世界空间顶点坐标 (即 从顶点 指向 摄像机的方向向量)
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));

				//计算中间值 
				fixed3 tempDir=normalize(worldLightDir+viewDir);

				//计算高光反射部分光照
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tempDir,worldNormal)),_Gloss);

				//衰减值 attenuation
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten=1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(_LightMatrix0, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(_LightMatrix0, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif

				return fixed4((diffuse+specular)*atten,1.0);
			}


			ENDCG
		}
	}

	Fallback "Specular"
}
