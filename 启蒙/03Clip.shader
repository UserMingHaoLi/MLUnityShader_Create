// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "CS0102/03Clip"
{
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_Float("Float",Float) = 0
		_Range("Range",Range(0.0,1.0)) = 0.5
		_Vector("Vector",Vector) = (1,1,1,1)
		_Color("Color",Color) = (0.5,0.5,0.5,0.5)
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
		_Cutout("Cutout",Range(-0.1,1.1)) = -0.1
		_Speed("Speed",Vector) = (1,1,1,1)
		_NoiseTex("NoiseTex",2D) = "white"{}
	}
	SubShader
	{
		Pass
		{
			Cull[_CullMode]
			CGPROGRAM
			//���嶥��Shader
			# pragma vertex vert 
			//����ƬԪShader
			# pragma fragment frag 
			//����UnityCG�����ռ�
			#include "UnityCG.cginc" 
			//CPU����ֵ
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;//��һ��uv,�������
				float3 normal : NORMAL;
				float color : COLOR;
			};
			//����Shader����ֵ
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;//��UV,��ͨ�ô�����,���Զ������ڴ洢ʲô����, 0-15��16��
				//�ᱻ��դ���׶�����ֵ����
				float2 pos_uv : TEXCOORD1;
			};
			float4 _Color; //��`Properties`�ù���������
			sampler2D _MainTex;
			float4 _MainTex_ST;//����Unity��_MainTex�µ��ĸ���ֵ
			float _Cutout;
			float4 _Speed;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			//����Shader
			v2f vert(appdata v)
			{
				v2f o;
				//UNITY_INITIALIZE_OUTPUT(v2f, o); //��ʼ��,��������
				////MVP����ת��ģ�Ϳռ�Ϊ�ü��ռ�
				//float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
				//float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
				//float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
				float4 pos_clip = UnityObjectToClipPos(v.vertex);
				o.pos = pos_clip;
				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;//ʹ��Unity���õ����ź�ƫ��
				o.pos_uv = v.vertex.xz * _MainTex_ST.xy + _MainTex_ST.zw;
				return o;//���ص�ֵ����ƬԪShader��Ϊ����ʹ��
			}
			//ƬԪShader
			float4 frag(v2f f) : SV_Target //SV_Target��ʾ�����Ŀ�ĵ�(��ȾĿ��)
			{
				float4 gradient = tex2D(_MainTex, f.uv + _Time.y * _Speed.xy).r; //��MainTex����, ʹ��f��uv��Ϣ
				half noise = tex2D(_NoiseTex, f.uv + _Time.y * _Speed.zw).r;
				clip(gradient - noise - _Cutout);
				return _Color;
			}
			ENDCG
		}
	}
}