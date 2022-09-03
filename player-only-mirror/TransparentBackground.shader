// By iigo丸 https://vrchat.com/home/user/usr_a50ae639-1908-4184-af6c-345f2c54b8e2
Shader "Mirror/TransparentBackground" 
{
    Properties 
    {
    [Header(Shader by iigo version 3.0)]
	// You can't have a header without a property lol this does nothing
    [Space(10)]
    [ToggleUI(iigo)] _iigo ("iigo", Int) = 1
    }

    SubShader
    {   
        
        Tags { "RenderType"="Transparent" "Queue" = "AlphaTest" "IgnoreProjector"="True"}
        // This pass is only needed to fix issues with opaque geometry on avatars with non one alpha
        
        Pass
        {
            Blend Zero One , One Zero
            ZWrite Off
            ZTest Always

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                if (unity_CameraProjection[2][0] == 0.f || unity_CameraProjection[2][1] == 0.f)
                {
                    o.vertex = -1;
                }
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {   
                float4 col = float4(1,0,0,1);

                return col;
            }
            ENDCG
        } 
        


        //Transparent Background Mask Pass
        Pass
        {      
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct appdata{
                float4 vertex : POSITION;
            };

            struct v2f{
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                if (unity_CameraProjection[2][0] == 0.f || unity_CameraProjection[2][1] == 0.f)
                {
                    o.vertex = -1;
                }
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return float4(0,0,0,0);
            }

        ENDCG
        } 
    }
}
