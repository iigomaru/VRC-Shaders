Shader "iigo/2D-Hologram" {
    //Shader by iigo丸 version 1.2
    //A simple 2D hologram shader, originally made for Ostinyo

    Properties {
        [Header(Shader by iigo version 1.2)]
        [Space]
       [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
       _Color ("Color" , Color) = (1,1,1,1)
        [Header(Hologram Bars)]
        [Space]
        _Frequency ("Frequency", float) = 250
        _BarThickness ("Bar Thickness", Range(-.5,2)) = 1.3
        _Speed ("Speed", Range(-100,100)) = 5
        [Space]
        [Header(Opacity Fade)]
        [Space]
        _Alpha ("Maximum Alpha", Range(0,1)) = .5
        _MinDistance ("Minimum Fade Distance", Float) = 2
        _MaxDistance ("Maximum Fade Distance", Float) = 6
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 0

    }
    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        ZWrite off
        
        Cull[_CullMode]

        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;  
            };
            
            //declarations
            sampler2D _MainTex;
            float  _Frequency;
            float _BarThickness;
            float _Speed;
            float _Alpha;
            float _MinDistance;
            float _MaxDistance;
            float4 _Color;
            

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            
            float4 frag (Interpolators i) : SV_Target {
            
                float  AbsDist = i.screenPos.w;

                float RelativeDist = smoothstep(_MaxDistance,_MinDistance,AbsDist);

                float2 UV = i.uv;

                float Frequency = UV.y * _Frequency;

                float Speed = _Time.y * _Speed;

                float Panning = Frequency+Speed;

                float Bar = sin(Panning);

                float BarThickness = lerp(-.45,_BarThickness,RelativeDist);

                float BarAlpha = saturate(Bar+BarThickness);

                float MaximumAlpha = lerp(0,_Alpha,RelativeDist);

                float2 TextureUV = ((UV - 0.5)/(lerp(.25,1,RelativeDist))) + 0.5;

                float4 TextureMain = tex2D( _MainTex, TextureUV );

                float Alpha = BarAlpha * MaximumAlpha * TextureMain.a;

                float3 Color = lerp(0,TextureMain.rgb,RelativeDist);

                Color = Color * _Color.rgb;

                // Fixes issue with edge clamping, there is probably a more elegent way to do this
                if ( TextureUV.x > 1 || TextureUV.x < 0 || TextureUV.y > 1 || TextureUV.y < 0 ) {
                    Alpha = 0;
                }

                return float4 (Color,Alpha);

            }
            ENDCG
        }
        
        
    }
}
