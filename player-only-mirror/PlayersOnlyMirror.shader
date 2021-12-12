Shader "iigo/Mirror/PlayerOnlyMirror"
{
    Properties
    { 
        [HideInInspector] _ReflectionTex0("", 2D) = "white" {}
        [HideInInspector] _ReflectionTex1("", 2D) = "white" {}
        _MinDistance ("Minimum Fade Distance", Float) = 3
        _MaxDistance ("Maximum Fade Distance", Float) = 4

    }
    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="AlphaTest" "IgnoreProjector"="True"}
        ZWrite on
        AlphaToMask on
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "UnityInstancing.cginc"

            sampler2D _ReflectionTex0;
            sampler2D _ReflectionTex1;
            float     _MinDistance;
            float     _MaxDistance; 

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 refl : TEXCOORD1;
                float4 pos : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct Input {
                float2 _ReflectionTex0;
                float2 _ReflectionTex1;
            };

            v2f vert(appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.refl = ComputeNonStereoScreenPos(o.pos);

                return o;
            }

            half4 frag(v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float  AbsDist = i.refl.w;

                float RelativeDist = smoothstep(_MaxDistance,_MinDistance,AbsDist);

                half4 refl = unity_StereoEyeIndex == 0 ? tex2Dproj(_ReflectionTex0, UNITY_PROJ_COORD(i.refl)) : tex2Dproj(_ReflectionTex1, UNITY_PROJ_COORD(i.refl));

                if (refl.r < 0 && refl.g < 0 && refl.b < 0) {
                    refl.a = 0;
                }

                refl.a = lerp(0,refl.a,RelativeDist);
             
                return saturate(refl);
            }

            ENDCG
        }
    }
}
