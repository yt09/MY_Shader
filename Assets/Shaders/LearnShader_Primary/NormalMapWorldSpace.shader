//使用法线纹理在世界空间下进行光照计算  逐像素高光反射 BlinnPhong 光照模型
Shader "Learn/NormalMapInWorldSpace"
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

				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
			};

		
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				//世界空间顶点坐标
				float3 worldPos=mul(_Object2World,v.vertex).xyz;
				fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
			    fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;

				o.TtoW0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);


				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

				fixed3 LightDir=normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 ViewDir=normalize(UnityWorldSpaceViewDir(worldPos));

				fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;

				tangentNormal=UnpackNormal(packedNormal);
				tangentNormal.xy*=_BumpScale;
				//因为采样转换后的法线是单位矢量 所以 a^2+b^2+c^2=|n|=1
				//tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));  不好理解看下面
				tangentNormal.z=sqrt(1.0-tangentNormal.x*tangentNormal.x-tangentNormal.y*tangentNormal.y);

				//----tangentNormal转化到世界空间下----
				tangentNormal=normalize(half3(dot(i.TtoW0.xyz,tangentNormal),dot(i.TtoW1.xyz,tangentNormal),dot(i.TtoW2.xyz,tangentNormal)));

				fixed3 albedo=tex2D(_MainTex,i.uv.xy).rgb*_Color.rgb;
				
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT*albedo;

				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,LightDir));

				fixed3 tempDir=normalize(LightDir+ViewDir);

				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow((max(0,dot(tangentNormal,tempDir))),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
