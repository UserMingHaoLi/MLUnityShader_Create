
Shader "UnityShaderBook/641"
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
				float3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//变换到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//将顶点位移到世界坐标系
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//世界光源位置, 归一化为方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射 = 入射光线颜色和强度 * 材质漫反射系数 * (max(法线向量·光源方向))
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				o.color = ambient + diffuse;
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