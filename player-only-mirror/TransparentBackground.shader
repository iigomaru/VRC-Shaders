Shader "iigo/Mirror/TransparentBackground" {
Properties {
    
}

SubShader {
    Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue"="Geometry"}
    ColorMask RGBA
    Cull front

    Pass {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_t v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                if (unity_CameraProjection[2][0] == 0.f || unity_CameraProjection[2][1] == 0.f){
                    o.vertex = -1;
                }
                return o;
            }

            fixed4 frag (v2f i) : COLOR {
                return float4(-0.00000001,-0.00000001,-0.00000001,0);
            }
        ENDCG
    }
}
}