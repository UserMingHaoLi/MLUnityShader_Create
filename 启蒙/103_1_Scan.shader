// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "C0102/103_1_Scan"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}//细节贴图-用于补充自发光效果
		_MainTexPow("MainTexPow", float) = 5.0//细节强度
		_RimMin("RimMin", Range(-1, 1)) = 0.0
		_RimMax("RimMax", Range(0, 2)) = 1.0//边缘光强度区间
		_InnerColor("InnerColor", Color) = (0.0,0.0,0.0,0.0)
		_RimColor("RimColor", Color) = (0.0,0.0,0.0,0.0)//自发光的颜色,两种
		_RimIntensity("RimIntensity", float) = 1.0
		_FlowTex("FlowTex", 2D) = "white" {}//流光贴图
		_FlowMul("FlowMul", Vector) = (1.0,1.0,0.0,0.0)//流光偏移
		_FlowSpeed("FlowSpeed", Vector) = (1.0,1.0,0.0,0.0)//流光速度
		_FlowIntensity("FlowIntensity", float) = 0.5//流光颜色强度
		_FlowAlpha("FlowAlpha", float) = 0.0//流光透明度强度
	}
	SubShader
	{
		Tags{"Queue"="Transparent"}
		LOD 100

		Pass
		{
			ZWrite Off
			Blend SrcAlpha One
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 normal_world : TEXCOORD1;
				float3 pos_world : TEXCOORD2;
				float3 pivot_world : TEXCOORD3;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _RimMin;
			float _RimMax;
			float _MainTexPow;
			float4 _InnerColor;
			float4 _RimColor;
			float _RimIntensity;
			sampler2D _FlowTex;
			float4 _FlowTex_ST;
			float4 _FlowMul;
			float4 _FlowSpeed;
			float _FlowIntensity;
			float _FlowAlpha;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				float3 normal_world = mul(float4(v.normal,0.0), unity_WorldToObject);
				o.normal_world = normalize(normal_world);
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.pivot_world = mul(unity_ObjectToWorld, float4(0.0,0.0,0.0,1.0)).xyz;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half3 normal_world = normalize(i.normal_world);
				half3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half NdotV = dot(normal_world, view_world);
				half NdotV_Normal = normalize(NdotV);
				half fresnel = 1.0 - NdotV;//边缘光
				fresnel = smoothstep(_RimMin, _RimMax, fresnel);
				half emiss = tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw).r;
				emiss = pow(emiss,_MainTexPow);
				half final_fresnel = saturate(fresnel + emiss);

				half3 final_rim_color = lerp(_InnerColor.xyz, _RimColor.xyz * _RimIntensity, final_fresnel);//插值算颜色
				half final_rim_alpha = final_fresnel;

				half2 uv_flow = i.pos_world.xy - i.pivot_world.xy * _FlowMul.xy;
				uv_flow = uv_flow + _Time.y * _FlowSpeed.xy;
				half4 flow_rgba = tex2D(_FlowTex,uv_flow * _FlowTex_ST.xy + _FlowTex_ST.zw) * _FlowIntensity;

				half3 final_color = final_rim_color + flow_rgba.rgb;
				half final_alpha = saturate(final_rim_alpha + flow_rgba.a + _FlowAlpha);
				return half4(final_color, final_alpha);
			}
			ENDCG
		}
	}
}
