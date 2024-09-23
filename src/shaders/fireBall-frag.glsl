#version 300 es
precision highp float;

uniform vec4 u_Color; 
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float fs_Time;

out vec4 out_Col; 

vec3 random3(vec3 p) {
    return fract(vec3(dot(p, vec3(113.48875, 2311.7, 592.123)),
                       dot(p, vec3(931.215, 2531.737, 14212.22)),
                       dot(p, vec3(6421.253, 46123.73, 83.11))));

}

float bias(float t, float bias) {
  return (t / ((((1.0 / bias) - 2.0) * (1.0 - t)) + 1.0));
}

float smoothsetp(float p) {
    return 6.0 * pow(p, 5.0) - 15.0 * pow(p, 4.0) + 10.0 * pow(p, 3.0);
}


float noise( in vec3 x ) {
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    
    // gradients
    vec3 ga = random3( p+vec3(0.0,0.0,0.0) );
    vec3 gb = random3( p+vec3(1.0,0.0,0.0) );
    vec3 gc = random3( p+vec3(0.0,1.0,0.0) );
    vec3 gd = random3( p+vec3(1.0,1.0,0.0) );
    vec3 ge = random3( p+vec3(0.0,0.0,1.0) );
    vec3 gf = random3( p+vec3(1.0,0.0,1.0) );
    vec3 gg = random3( p+vec3(0.0,1.0,1.0) );
    vec3 gh = random3( p+vec3(1.0,1.0,1.0) );
    
    // projections
    float va = dot( ga, w-vec3(0.0,0.0,0.0) );
    float vb = dot( gb, w-vec3(1.0,0.0,0.0) );
    float vc = dot( gc, w-vec3(0.0,1.0,0.0) );
    float vd = dot( gd, w-vec3(1.0,1.0,0.0) );
    float ve = dot( ge, w-vec3(0.0,0.0,1.0) );
    float vf = dot( gf, w-vec3(1.0,0.0,1.0) );
    float vg = dot( gg, w-vec3(0.0,1.0,1.0) );
    float vh = dot( gh, w-vec3(1.0,1.0,1.0) );
	
    // interpolation
    return va + 
           u.x*(vb-va) + 
           u.y*(vc-va) + 
           u.z*(ve-va) + 
           u.x*u.y*(va-vb-vc+vd) + 
           u.y*u.z*(va-vc-ve+vg) + 
           u.z*u.x*(va-vb-ve+vf) + 
           u.x*u.y*u.z*(-va+vb+vc-vd+ve-vf-vg+vh);
}

float WorleyNoise3D(vec3 pos) {
    pos *= 0.6; // Now the space is 10x10 instead of 1x1. Change this to any number you want.
    vec3 posInt = floor(pos);
    vec3 posFract = fract(pos);
    float minDist = 1.0; // Minimum distance initialized to max.
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            for (int z = -1; z <= 1; ++z) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 point = random3(posInt + neighbor);
                vec3 diff = neighbor + point - posFract;
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }
    return minDist;
}

//lerpaderpadoo wahooo
vec4 lerp(vec4 min, vec4 max, float t) {
    return min + t * (max - min);
}

//idk if this is right
float fit(float var, float imin, float imax, float omin, float omax) {
    return (var / (imax - imin)) * (omax - omin);
}


void main()
{   
    float baseNoise = fit(mod(WorleyNoise3D(vec3(fs_Pos.xyz) + fs_Time * 0.0001) + fs_Time * 0.001, 0.11), 0.0, 0.1, 0.0, 1.0);
    float MinNoise = 1.0 - baseNoise;
    float noise = max(baseNoise, MinNoise);
    float noise2 = min(baseNoise, MinNoise);

    float dist = sqrt(fs_Pos.x * fs_Pos.x + fs_Pos.y * fs_Pos.y + fs_Pos.z * fs_Pos.z);
    vec4 color = lerp(vec4(0, 0, 0, 1), vec4(1.0,1.0,1.0,1.0), fit(dist, 0.8, 2.0, 0.0, 0.3));
    vec4 diffuseColor = vec4(noise, noise, noise, 1.0) * color;

    diffuseColor += vec4(noise2, noise2,noise2, 1.0) * (color * 0.5);



    vec4 colorTest = lerp(vec4(0, 0, 0, 1), vec4(1.0,1.0,1.0,1.0), dot(vec3(0,0,1), fs_Nor.xyz));
    vec4 colooooor = fs_Col;
    out_Col = vec4(diffuseColor.rgb, diffuseColor.a);
}
