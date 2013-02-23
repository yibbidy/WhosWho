// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

uniform lowp vec4 kColor;

uniform sampler2D kImageTexture;
uniform lowp float kImageWeight;

varying lowp vec2 gUV;

void main()
{
    const lowp vec3 fogColor = vec3(0.65, 0.65, 0.65);
    
    gl_FragColor = mix(kColor, texture2D(kImageTexture, gUV), kImageWeight);
    gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, pow(max(0.0, 1.0 - gl_FragCoord.w/gl_FragCoord.z), 2.0));
}
