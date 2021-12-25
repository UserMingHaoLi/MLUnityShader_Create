
Shader "UnityShaderBook/714"
{
	Properties
	{
		//漫反射系数
		_Color("Color",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTex",2D) = "white" {}
		_BumpMap("BumpMap",2D) = "bump" {}
		_BumpScale("BumpScale",Float) = 1.0
		_SpecularMask("SpecularMask",2D) = "white" {}
		_SpecularScale("SpecularScale",Float) = 1.0
		_Specular("Specular",Color) = (1.0,1.0,1.0,1.0)
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
			//float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _SpecularMask;
			//float4 _SpecularMask_ST;
			float _SpecularScale;
			fixed4 _Specular;
			half _Gloss;
		

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;//叉积
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);//切线空间
				//TANGENT_SPACE_ROTATION //Unity提供的宏定义,等同意上面两行代码
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz; 
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv)); 
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)),_Gloss) * specularMask;
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}