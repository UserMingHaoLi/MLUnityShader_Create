
Shader "UnityShaderBook/7122"
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
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;//���ڴ洢���߿ռ䵽����ռ�ı任����
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				//ת�þ�����������
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				//tangentNoraml.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNoraml.z = sqrt(1.0 - saturate(dot(tangentNoraml.xy, tangentNoraml.xy)));
				fixed3 bump = UnpackNormal(packedNormal);//Unity��ѹ���Ż�, �Լ���ֵ����һ����ȷ
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				//����
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				//������
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//������
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));
				//����h=�ӽǷ���͹�Դ����ȡƽ������һ������
				fixed3 halfDir = normalize(lightDir + viewDir);
				//Blinn-Phongģ�� �߹ⷴ��=(�������ɫ��ǿ�ȡ��߹ⷴ��ϵ��)*max(0,���߷���h) 
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);
				float4 color = float4(ambient + diffuse + specular, 1.0);
				return color;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}