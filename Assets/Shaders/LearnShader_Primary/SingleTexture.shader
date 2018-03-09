//逐像素高光反射 BlinnPhong 光照模型
Shader "Learn/SingleTexture"
{
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex("Main Tex",2D)="white"{}
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
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;//顶点纹理坐标 uv 存入变量
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//o.worldNormal=mul(v.normal,(float3x3)_World2Object);
				o.worldNormal=UnityObjectToWorldNormal(v.normal);

				o.worldPos=mul(_Object2World,v.vertex).xyz;
				//o.worldPos=UnityObjectToWorldDir(v.vertex.xyz);
						
				o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;


				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//世界空间顶点法向量方向
				fixed3 worldNormal=normalize(i.worldNormal);
				//世界空间顶点光源方向
				//fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;


				//得到环境光
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT*albedo;

				//计算漫反射部分光照
				fixed3 diffuse=_LightColor0.rgb*albedo*saturate(dot(worldNormal,worldLightDir));
				
				//计算世界空间 视角方向 =世界空间摄像机坐标-世界空间顶点坐标 (即 从顶点 指向 摄像机的方向向量)
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));

				//计算世界空间反射光方向 入射光方向是反向的光源方向
				fixed3 tempDir=normalize(worldLightDir+viewDir);

				//计算高光反射部分光照
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tempDir,worldNormal)),_Gloss);

				fixed3 color=ambient+diffuse+specular;


				return fixed4(color,1.0);
			}

			ENDCG

		}
	}

	Fallback "Specular"
}
