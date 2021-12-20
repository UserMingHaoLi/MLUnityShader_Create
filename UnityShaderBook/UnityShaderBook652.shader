
Shader "UnityShaderBook/652"
{
	Properties
	{
		//������ϵ��
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				//������
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//���㷨��ת������������ϵ
				fixed3 worldNormal = normalize(i.worldNormal);
				//��Դ����
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//������
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				//���䷽�� = 2*(������������Դ����)*��������-��Դ����
				//fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));//ʹ���Դ�����, ��Ҫ��Դָ�򽻵㴦
				fixed3 reflectDir = normalize(dot(worldNormal,worldLightDir) * 2 * worldNormal - worldLightDir);
				//�ӽǷ���
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//�߹ⷴ�� = (�������ɫ��ǿ�ȡ��߹ⷴ��ϵ��)*max(0,�ӽǷ��򡤷��䷽��)
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				float4 color = float4(ambient + diffuse + specular, 1.0);
				return color;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}