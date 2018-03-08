//使用法线纹理在切线空间下进行光照计算  逐像素高光反射 BlinnPhong 光照模型
Shader "Learn/NormalMapInTangentSpace"
{
	Properties
	{	
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map",2D)="bump"{}
		_BumpScale("Bump Scale",Float)=1.0
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;


			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

		
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				//使用内置的宏 TANGENT_SPACE_ROTATION 会得到变量名为 rotation 4*4 模型空间到切线空间的变换矩阵
				TANGENT_SPACE_ROTATION;
				
				o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

				o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				
				//得到切线空间下的光线方向和视角方向
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir=normalize(i.lightDir);
				fixed3 tangentViewDir=normalize(i.viewDir);

				fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;

				tangentNormal=UnpackNormal(packedNormal);
				tangentNormal.xy*=_BumpScale;
				//因为采样转换后的法线是单位矢量 所以 a^2+b^2+c^2=|n|=1
				//tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));  不好理解看下面
				tangentNormal.z=sqrt(1.0-tangentNormal.x*tangentNormal.x-tangentNormal.y*tangentNormal.y);

				fixed3 albedo=tex2D(_MainTex,i.uv.xy).rgb*_Color.rgb;
				
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT*albedo;

				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));

				fixed3 tempDir=normalize(tangentLightDir+tangentViewDir);

				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow((max(0,dot(tangentNormal,tempDir))),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
