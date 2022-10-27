Shader "iigo/2D-Hologram" {
    //Shader by iigo丸 version 2.0
    //A simple unlit 2D hologram shader, originally made for Ostinyo

    //Uses the point to plane distance from the players center
    //camera position to vary the size of the texture, the size
    //of the 'hologram' bars and the saturation of the color.

    Properties {
        [Header(Shader by iigo version 2.1)]
        [Space]

        [HDR]_Color ("Color" , Color) = (1,1,1,1)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}

        [Header(Hologram Bars)]
        [Space]

        [IntRange] _NumberOfBars ("Number Of Bars", Range(0,100)) = 50
        _BarThickness ("Bar Thickness", Range(-.5,2)) = 1.5
        _Speed ("Speed", Range(-1,1)) = .5

        [IntRange] _Tiling ("Tiling Amount", Range(1,10)) = 1

        [Space]
        [Header(Distance Fade)]
        [Space]
        _Alpha ("Maximum Opacity", Range(0,1)) = .5
        _MinDistance ("Minimum Fade Distance", Float) = 2
        _MaxDistance ("Maximum Fade Distance", Float) = 6
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "PreviewType" = "Plane" }

        ZWrite off
        
        Cull[_CullMode]

        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 hologram : TEXCOORD1;
            };

            // Packing values into a single float4 TEXCOORD
            #define RELATIVEDIST hologram.x
            #define PANNING      hologram.y
            #define BARTHICKNESS hologram.z
            #define MAXIMUMALPHA hologram.w

            // Color and Texture
            float4 _Color;
            sampler2D _MainTex;

            // Hologram Bars
            float _NumberOfBars;
            float _BarThickness;
            float _Speed;
            int   _Tiling;

            // Distance Fade
            float _Alpha;
            float _MinDistance;
            float _MaxDistance;

            // Vrchat Global Properties
            float _VRChatMirrorMode;
            float3 _VRChatMirrorCameraPos;
            
            Interpolators vert (MeshData v) {

                Interpolators o;

                // gets the player center camera position based on if in vr or not
                #if defined(USING_STEREO_MATRICES)
                    float3 PlayerCenterCamera = ( unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1] ) / 2;
                #else
                    float3 PlayerCenterCamera = _WorldSpaceCameraPos.xyz;
                #endif

                if (_VRChatMirrorMode > 0)
                {
                    PlayerCenterCamera = _VRChatMirrorCameraPos;
                }

                // gets the point plane distance of the Z negative direction of the object
                float4 ObjectPos = mul( unity_ObjectToWorld, float4(0,0,0,1) );
                float3 WorldspaceNZ = UnityObjectToWorldNormal( float3(0,0,-1));
                float  PPDistance = dot(PlayerCenterCamera - ObjectPos, WorldspaceNZ);
                o.RELATIVEDIST = smoothstep(_MaxDistance,_MinDistance, PPDistance);

                // doing the hologram effect calculations in vertex function where possible

                o.uv = v.uv;

                float  Frequency = v.uv.y * _NumberOfBars * 8;
                float  Speed = _Time.y * (_Speed * _NumberOfBars);

                o.PANNING = Frequency + Speed;

                o.BARTHICKNESS = lerp(-.45, _BarThickness, o.RELATIVEDIST);

                o.MAXIMUMALPHA = lerp(0,_Alpha, o.RELATIVEDIST);

                // normal vertex function stuff
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
                
            }
            
            float4 frag (Interpolators i) : SV_Target {

                float2 UV = (((i.uv * _Tiling) - 0.5)) + 0.5;

                UV = glsl_mod(UV, 1.0);

                UV = ((UV - 0.5) / (lerp(.25,1, i.RELATIVEDIST))) + 0.5;

                float  Bar = sin(i.PANNING);

                float  BarAlpha = saturate(Bar + i.BARTHICKNESS);

                float4 TextureMain = tex2D( _MainTex, UV );

                float3 Color = lerp(float3(0,0,0), TextureMain.rgb, i.RELATIVEDIST);

                float3 FinalColor = Color * _Color.rgb;

                float  FinalAlpha = BarAlpha * i.MAXIMUMALPHA * TextureMain.a;

                // Fixes issue with edge clamping, there is probably a more elegent way to do this
                if ( UV.x > 1 || UV.x < 0 || UV.y > 1 || UV.y < 0 ) {
                    FinalAlpha = 0;
                }

                return float4 (FinalColor, FinalAlpha);

            }

            ENDCG
        }   
    }
}