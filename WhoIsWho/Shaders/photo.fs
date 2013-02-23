// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)


uniform sampler2D kImageTex;
uniform lowp float kImageAlpha;
uniform sampler2D kMaskTex[2];
uniform lowp float kMaskWeight[2];

varying lowp vec2 gUV;

void main()
{
    gl_FragColor = texture2D(kImageTex, gUV);
    for( int i=0; i<2; i++ ) {
        lowp vec4 mask = texture2D(kMaskTex[i], gUV);
        gl_FragColor = mix(gl_FragColor, mask, mask.a * vec4(kMaskWeight[i]));
    }
    
    gl_FragColor.a = gl_FragColor.a * kImageAlpha;
    
    lowp vec3 fogColor = vec3(0.65, 0.65, 0.65);
    gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, pow(max(0.0, 1.0 - gl_FragCoord.w/gl_FragCoord.z), 2.0));
}
