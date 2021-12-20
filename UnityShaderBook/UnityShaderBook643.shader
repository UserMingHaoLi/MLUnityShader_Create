
Shader "UnityShaderBook/643"
{
	Properties
	{
		//漫反射系数
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
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

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//变换到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//半兰伯特公式 入射光强度和颜色 * 材质漫反射值 * (α*(法线·光源方向)+β)
				//其中αβ常用值为0.5
				fixed3 halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
				//这使得光线在背面也能看到明暗变化,这并没有物理依据而是一种视觉加强技术
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}