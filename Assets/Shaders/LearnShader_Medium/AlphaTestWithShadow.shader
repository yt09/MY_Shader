//透明度测试+阴影

Shader "Learn Medium/AlphaTestWithShadow"
{
Properties
	{
		_Color("Main Tint",Color)=(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Cutoff("Alpha Cutoff",Range(0,1))=0.5
	}
	SubShader
	{
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }
		LOD 100


		Pass
		{
			Tags {"LightMode"="ForwardBase"}

			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
			
				float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

		
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldNormal=UnityObjectToWorldNormal(v.vertex);

				o.worldPos=mul(_Object2World,v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor=tex2D(_MainTex,i.uv);

				//透明度测试 如果texColor.a-_Cutoff<0 则舍弃片元
				clip(texColor.a-_Cutoff);

				fixed3 albedo=texColor.rgb*_Color.rgb;

				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));

				//计算光照衰减和阴影 将数值赋予atten
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			 	
				return fixed4(ambient+diffuse*atten,1.0);
			}
			ENDCG
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
	//Fallback "VertexLit"
}

