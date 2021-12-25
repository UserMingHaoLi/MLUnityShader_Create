
Shader "UnityShaderBook/7121"
{
	Properties
	{
		//漫反射系数
		_Color("Color",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "bump" {} //"bump"是Unity中的关键字,表示模型自带法线信息
		_BumpScale("BumpScale", Float) = 1.0
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
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			half _Gloss;
		

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;//切线方向, float4是为了存储副切线
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//乘w是以副切线确定方向
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;//叉积
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				//TANGENT_SPACE_ROTATION //Unity提供的宏定义,等同意上面两行代码
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNoraml;
				//tangentNoraml.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNoraml.z = sqrt(1.0 - saturate(dot(tangentNoraml.xy, tangentNoraml.xy)));
				tangentNoraml = UnpackNormal(packedNormal);//Unity由压缩优化, 自己求值并不一定正确
				tangentNoraml.xy *= _BumpScale;
				tangentNoraml.z = sqrt(1.0 - saturate(dot(tangentNoraml.xy, tangentNoraml.xy)));
				//纹理
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNoraml, tangentLightDir));
				//其中h=视角方向和光源方向取平均并归一化而来
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				//Blinn-Phong模型 高光反射=(入射光颜色和强度·高光反射系数)*max(0,法线方向·h) 
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNoraml, halfDir)), _Gloss);
				float4 color = float4(ambient + diffuse + specular, 1.0);
				return color;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}