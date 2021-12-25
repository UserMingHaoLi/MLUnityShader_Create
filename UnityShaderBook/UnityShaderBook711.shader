
Shader "UnityShaderBook/711"
{
	Properties
	{
		//漫反射系数
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
		_Specular("Specular", Color) = (1.0,1.0,1.0,1.0)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color",Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		Pass
		{
			//定义正确的LightMode,才能获取一些Unity内置光照变量
			Tags {"LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//顶点法线转换到世界坐标系
				fixed3 worldNormal = normalize(i.worldNormal);
				//光源方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//纹理
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
				//视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//其中h=视角方向和光源方向取平均并归一化而来
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				//Blinn-Phong模型 高光反射=(入射光颜色和强度·高光反射系数)*max(0,法线方向·h) 
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
				float4 color = float4(ambient + diffuse + specular, 1.0);
				return color;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}