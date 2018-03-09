//开启深入写入的透明效果,处理模型自遮挡半透明效果出错问题
Shader "Learn/AlphaBlendZWrite"
{
	Properties
	{
		_Color("Main Tint",Color)=(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1))=1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			ZWrite On
			ColorMask 0 //颜色通道掩码,不写入颜色通道, 不输出任何颜色
		}


		Pass
		{
			Tags {"LightMode"="ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha//设置混合因子

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

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
			};

		
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldNormal=UnityObjectToWorldNormal(v.vertex);

				o.worldPos=mul(_Object2World,v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor=tex2D(_MainTex,i.uv);

				

				fixed3 albedo=texColor.rgb*_Color.rgb;

				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));

			
				return fixed4(ambient+diffuse,texColor.a*_AlphaScale);
			}
			ENDCG
		}
	}
	Fallback "Transparent/VertexLit"
}
