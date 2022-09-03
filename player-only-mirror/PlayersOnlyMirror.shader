// By iigo丸 https://vrchat.com/home/user/usr_a50ae639-1908-4184-af6c-345f2c54b8e2
Shader "Mirror/VRCPlayersOnlyMirror"
{
    Properties
    { 
        [Header(Shader by iigo version 3.0)]
        [HideInInspector] _ReflectionTex0("", 2D) = "white" {}
        [HideInInspector] _ReflectionTex1("", 2D) = "white" {}
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
        ZWrite off
        Blend One OneMinusSrcAlpha
        LOD 100

        //Mirror Pass
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma warning (default : 3206) // implicit truncation
            #include "UnityCG.cginc"
            #include "UnityInstancing.cginc"

            sampler2D_float _ReflectionTex0;
            sampler2D_float _ReflectionTex1;

            struct appdata 
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f 
            {
                float4 refl : TEXCOORD0;
                float4 pos : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct Input 
            {
                float2 _ReflectionTex0;
                float2 _ReflectionTex1;
            };

            v2f vert(appdata v) 
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);

                // Gets the screen pos for the mirrors
                o.refl = ComputeNonStereoScreenPos(o.pos);
                
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                // Samples the reflection textures
                float4 refl = unity_StereoEyeIndex == 0 ? tex2Dproj(_ReflectionTex0, UNITY_PROJ_COORD(i.refl)) : tex2Dproj(_ReflectionTex1, UNITY_PROJ_COORD(i.refl));

                return (float4(refl));
            }

            ENDCG
        }
    }
}
