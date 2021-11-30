// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "CS0102/05Rim"
{
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_Float("Float",Float) = 0
		_Range("Range",Range(0.0,5.0)) = 0.5
		_Vector("Vector",Vector) = (1,1,1,1)
		_Color("Color",Color) = (0.5,0.5,0.5,0.5)
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
		_Cutout("Cutout",Range(-0.1,1.1)) = -0.1
		_Speed("Speed",Vector) = (1,1,1,1)
		_NoiseTex("NoiseTex",2D) = "white"{}
	}
		SubShader
	{
		Tags {"Queue" = "Transparent"}
		Pass
		{
			Cull Off
			Zwrite On
			ColorMask 0
			CGPROGRAM
			float4 _Color;
			#pragma vertex vert
			#pragma fragment frag

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}
			float4 frag(void) : COLOR
			{
				return _Color;
			}
			ENDCG
		}
		Pass
		{
			Zwrite On
			Blend SrcAlpha One
			Cull[_CullMode]
			CGPROGRAM
			//定义顶点Shader
			# pragma vertex vert 
			//定义片元Shader
			# pragma fragment frag 
			//导入UnityCG命名空间
			#include "UnityCG.cginc" 
			//CPU输入值
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;//第一套uv,最多四套
				float3 normal : NORMAL;
				float color : COLOR;
			};
			//顶点Shader返回值
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;//非UV,是通用储存器,可自定义用于存储什么内容, 0-15共16个
				//会被光栅化阶段做插值处理
				float3 normal_world : TEXCOORD1;
				float3 view_world : TEXCOORD2;
			};
			float4 _Color; //从`Properties`拿过来的数据
			sampler2D _MainTex;
			float4 _MainTex_ST;//关联Unity中_MainTex下的四个数值
			float _Cutout;
			float4 _Speed;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Range;
			float _Float;
			//顶点Shader
			v2f vert(appdata v)
			{
				v2f o;
				//UNITY_INITIALIZE_OUTPUT(v2f, o); //初始化,消除警告
				////MVP矩阵转化模型空间为裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex); 
				o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));
				float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);
				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;//使用Unity设置的缩放和偏移
				return o;//返回的值将在片元Shader作为参数使用
			}
			//片元Shader
			float4 frag(v2f f) : SV_Target //SV_Target表示输出的目的地(渲染目标)
			{
				float3 normal_world = normalize(f.normal_world);
				float3 view_world = normalize(f.view_world);
				float NdotV = saturate(dot(normal_world, view_world));
				float fresnel = pow((1.0 - NdotV), _Float);
				float rim_alpha = saturate(fresnel * _Range);
				float3 color = _Color.xyz * _Range;
				return float4(color, rim_alpha);
			}
			ENDCG
		}
	}
}