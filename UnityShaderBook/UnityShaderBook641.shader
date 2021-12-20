
Shader "UnityShaderBook/641"
{
	Properties
	{
		//������ϵ��
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
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
				//�任���ü��ռ�
				o.pos = UnityObjectToClipPos(v.vertex);
				//��ȡ������
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//������λ�Ƶ���������ϵ
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//�����Դλ��, ��һ��Ϊ����
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//������ = ���������ɫ��ǿ�� * ����������ϵ�� * (max(������������Դ����))
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