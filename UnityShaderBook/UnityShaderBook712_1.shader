
Shader "UnityShaderBook/7121"
{
	Properties
	{
		//������ϵ��
		_Color("Color",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "bump" {} //"bump"��Unity�еĹؼ���,��ʾģ���Դ�������Ϣ
		_BumpScale("BumpScale", Float) = 1.0
		_Specular("Specular", Color) = (1.0,1.0,1.0,1.0)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
	SubShader
	{
		Pass
		{
			//������ȷ��LightMode,���ܻ�ȡһЩUnity���ù��ձ���
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
				float4 tangent : TANGENT;//���߷���, float4��Ϊ�˴洢������
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
				//��w���Ը�����ȷ������
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;//���
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				//TANGENT_SPACE_ROTATION //Unity�ṩ�ĺ궨��,��ͬ���������д���
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
				tangentNoraml = UnpackNormal(packedNormal);//Unity��ѹ���Ż�, �Լ���ֵ����һ����ȷ
				tangentNoraml.xy *= _BumpScale;
				tangentNoraml.z = sqrt(1.0 - saturate(dot(tangentNoraml.xy, tangentNoraml.xy)));
				//����
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				//������
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//������
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNoraml, tangentLightDir));
				//����h=�ӽǷ���͹�Դ����ȡƽ������һ������
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				//Blinn-Phongģ�� �߹ⷴ��=(�������ɫ��ǿ�ȡ��߹ⷴ��ϵ��)*max(0,���߷���h) 
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNoraml, halfDir)), _Gloss);
				float4 color = float4(ambient + diffuse + specular, 1.0);
				return color;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}