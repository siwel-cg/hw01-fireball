// #version 300 es
// precision highp float;

// uniform vec4 u_Color; 
// in vec4 fs_Nor;
// in vec4 fs_LightVec;
// in vec4 fs_Col;

// out vec4 out_Col;

// // vec3 random3(vec3 p) {
// //     return fract(vec3(dot(p, vec3(113.48875, 2311.7, 592.123)),
// //                        dot(p, vec3(931.215, 2531.737, 14212.22)),
// //                        dot(p, vec3(6421.253, 46123.73, 83.11))));

// // }

// // float noise( in vec3 x ) {
// //     // grid
// //     vec3 p = floor(x);
// //     vec3 w = fract(x);
    
// //     // quintic interpolant
// //     vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    
// //     // gradients
// //     vec3 ga = random3( p+vec3(0.0,0.0,0.0) );
// //     vec3 gb = random3( p+vec3(1.0,0.0,0.0) );
// //     vec3 gc = random3( p+vec3(0.0,1.0,0.0) );
// //     vec3 gd = random3( p+vec3(1.0,1.0,0.0) );
// //     vec3 ge = random3( p+vec3(0.0,0.0,1.0) );
// //     vec3 gf = random3( p+vec3(1.0,0.0,1.0) );
// //     vec3 gg = random3( p+vec3(0.0,1.0,1.0) );
// //     vec3 gh = random3( p+vec3(1.0,1.0,1.0) );
    
// //     // projections
// //     float va = dot( ga, w-vec3(0.0,0.0,0.0) );
// //     float vb = dot( gb, w-vec3(1.0,0.0,0.0) );
// //     float vc = dot( gc, w-vec3(0.0,1.0,0.0) );
// //     float vd = dot( gd, w-vec3(1.0,1.0,0.0) );
// //     float ve = dot( ge, w-vec3(0.0,0.0,1.0) );
// //     float vf = dot( gf, w-vec3(1.0,0.0,1.0) );
// //     float vg = dot( gg, w-vec3(0.0,1.0,1.0) );
// //     float vh = dot( gh, w-vec3(1.0,1.0,1.0) );
	
// //     // interpolation
// //     return va + 
// //            u.x*(vb-va) + 
// //            u.y*(vc-va) + 
// //            u.z*(ve-va) + 
// //            u.x*u.y*(va-vb-vc+vd) + 
// //            u.y*u.z*(va-vc-ve+vg) + 
// //            u.z*u.x*(va-vb-ve+vf) + 
// //            u.x*u.y*u.z*(-va+vb+vc-vd+ve-vf-vg+vh);
// // }

// // float fbm(vec3 p, int oct) {
// //     float total = 0.0;
// //     int octaves = oct;
// //     float freqScale = 2.0;
// //     float ampScale = 0.5;
// //     float amplitude = 0.5;
// //     float frequency = 1.0;
   
// //     for (int i = 0; i < octaves; i++) {
// //         total += amplitude * noise(p * frequency);
// //         frequency *= freqScale;
// //         amplitude *= ampScale;
// //     }
// //     return total;
// // }

// void main()
// {

//         // Material base color (before shading)
//         vec4 diffuseColor = u_Color;

//         // Calculate the diffuse term for Lambert shading
//         float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
//         // Avoid negative lighting values
//         // diffuseTerm = clamp(diffuseTerm, 0, 1);
//         //test
//         float ambientTerm = 0.2;

//         float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
//                                                             //to simulate ambient lighting. This ensures that faces that are not
//                                                             //lit by our point light are not completely black.

//         // Compute final shaded color
//         out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
//     // vec4 diffuseColor = vec4(1.0, 0.0, 1.0, 1.0);//fbm(fs_Pos, 8);
//     // out_Col = vec4(diffuseColor.rgb, 1.0);
// }










#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);
        //test
        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
