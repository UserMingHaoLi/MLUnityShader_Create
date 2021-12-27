
Shader "UnityShaderBook/831"
{
	Properties
	{
		//漫反射系数
			_Color("Color",Color) = (1.0,1.0,1.0,1.0)
			_MainTex("MainTex",2D) = "white" {}
			_Cutoff("Cutoff",Range(-0.1,2.0)) = 0.5
	}
		SubShader
			{
			//透明度测试需要的Tags
			Tags {"Queue" = "AlphaTest" "Ignoreprojector" = "True" "RenderType" = "TransparentCutout"}
			Pass
			{
			//定义正确的LightMode,才能获取一些Unity内置光照变量
			Tags {"LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);

				clip(texColor.a - _Cutoff);
				//if(texColor.a - _Cutoff > 0.0) discard;

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

				return fixed4(ambient + diffuse, 1.0);
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}