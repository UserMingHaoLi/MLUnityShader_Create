
Shader "UnityShaderBook/651"
{
	Properties
	{
		//漫反射系数
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
		_Specular("Specular", Color) = (1.0,1.0,1.0,1.0)
		_Gloss("Gloss", Range(8.0, 256)) = 20
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

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//顶点法线转换到世界坐标系
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//光源方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				//反射方向 = 2*(法线向量·光源方向)*法线向量-光源方向
				//fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));//使用自带函数, 需要光源指向交点处
				fixed3 reflectDir = normalize(dot(worldNormal,worldLightDir) * 2 * worldNormal - worldLightDir);
				//视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//高光反射 = (入射光颜色和强度·高光反射系数)*max(0,视角方向·反射方向)
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				o.color = ambient + diffuse + specular;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}