#version 300 es
uniform mat4 u_Model;       
uniform mat4 u_ModelInvTr;  
uniform mat4 u_ViewProj;    
uniform float u_Time;
uniform vec3 u_CamPos;

in vec4 vs_Pos;             
in vec4 vs_Nor;             
in vec4 vs_Col;  
          
out vec4 fs_Nor;            
out vec4 fs_LightVec;       
out vec4 fs_Col;  
out float fs_Time;  
out vec4 fs_Pos;  
out vec4 fs_camPos; 
out float hwarp;
out float fbmNoise;
 
const vec4 lightPos = vec4(5, 5, 3, 1); 

vec3 random3(vec3 p) {
    return fract(vec3(dot(p, vec3(113.48875, 2311.7, 592.123)),
                       dot(p, vec3(931.215, 2531.737, 14212.22)),
                       dot(p, vec3(6421.253, 46123.73, 83.11))));

}

float smoothsetp(float p) {
    return 6.0 * pow(p, 5.0) - 15.0 * pow(p, 4.0) + 10.0 * pow(p, 3.0);
}

float noise(vec3 x) {
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    
    // gradients
    vec3 ga = random3(p + vec3(0.0,0.0,0.0));
    vec3 gb = random3(p + vec3(1.0,0.0,0.0));
    vec3 gc = random3(p + vec3(0.0,1.0,0.0));
    vec3 gd = random3(p + vec3(1.0,1.0,0.0));
    vec3 ge = random3(p + vec3(0.0,0.0,1.0));
    vec3 gf = random3(p + vec3(1.0,0.0,1.0));
    vec3 gg = random3(p + vec3(0.0,1.0,1.0));
    vec3 gh = random3(p + vec3(1.0,1.0,1.0));
    
    // projections
    float va = dot(ga, w - vec3(0.0,0.0,0.0));
    float vb = dot(gb, w - vec3(1.0,0.0,0.0));
    float vc = dot(gc, w - vec3(0.0,1.0,0.0));
    float vd = dot(gd, w - vec3(1.0,1.0,0.0));
    float ve = dot(ge, w - vec3(0.0,0.0,1.0));
    float vf = dot(gf, w - vec3(1.0,0.0,1.0));
    float vg = dot(gg, w - vec3(0.0,1.0,1.0));
    float vh = dot(gh, w - vec3(1.0,1.0,1.0));
	
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

float fbm(vec3 p, int oct) {
    float total = 0.0;
    int octaves = oct;
    float freqScale = 2.0;
    float ampScale = 0.5;

    float amplitude = 0.5;
    float frequency = 1.0;
    //
    // Loop of octaves
    for (int i = 0; i < octaves; i++) {
        total += amplitude * noise(p * frequency);
        frequency *= freqScale;
        amplitude *= ampScale;
    }
    return total;
}

//lerpaderpadoo wahooo
vec4 lerp(vec4 min, vec4 max, float t) {
    return min + t * (max - min);
}

//idk if this is right
float fit(float var, float imin, float imax, float omin, float omax) {
    return (var / (imax - imin)) * (omax - omin);
}

float bias(float t, float bias) {
  return (t / ((((1.0 / bias) - 2.0) * (1.0 - t)) + 1.0));
}

float trianlge(float x) {
    float pi = 3.141592;
    return ((2.0*18.0*(sin(3.0*2.0)))/pi) * asin(sin((2.0 * pi / 2.0) * x));
}

vec2 swirl(vec2 p, float swirlFactor) {
    float r = length(p);
    float theta = atan(p.y, p.x) - u_Time*0.01; 

    theta += swirlFactor * r;
    return vec2(r * cos(theta), r * sin(theta));
}

void main()
{
    fs_Col = vs_Col;    
    fs_Time = u_Time;

    vec4 normal = vs_Nor;
    vec4 position = vs_Pos;

    mat3 invTranspose = mat3(u_ModelInvTr);
    float yScaler = 1.0 - abs(vs_Pos.y);

    float a = atan(vs_Pos.x, vs_Pos.z) - cos(u_Time*0.01) * yScaler;
    float pi = 3.141592;

    vec4 magic = vec4(vs_Nor.x, 0.0, vs_Nor.z, 0.0); 
    vec3 cross = cross(vs_Nor.xyz, abs(vs_Pos.xyz - u_CamPos));

    //replace magic with lerp(magic, vec4(cross, 1.0), 1.0 - yScaler)
    vec4 warpPos = vs_Pos + magic * bias(abs(length(vec2(vs_Nor.x, vs_Nor.z))), 0.02); // initial warp
    warpPos += magic * (noise(vec3(position))) * 0.1 * (yScaler);

    vec2 swirlPos = swirl(vec2((position.x), (position.z)), 8.0);
    vec3 inpos = vec3(swirlPos.x + (u_Time*0.01) , vs_Pos.y, swirlPos.y + (u_Time*0.01) );

    warpPos += normal * fbm(inpos + yScaler, 5) * (yScaler);

    hwarp = length(magic * bias(abs(length(vec2(vs_Nor.x, vs_Nor.z))), 0.02));
    fbmNoise = fbm(inpos + yScaler, 5) * (yScaler);

    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0); 
    vec4 modelposition = u_Model * warpPos;
    
    fs_LightVec = lightPos - modelposition;
    fs_Pos = modelposition;
    gl_Position = u_ViewProj * modelposition;
    vec4 camPos = vec4(u_CamPos, 1.0);
    fs_camPos = camPos - vs_Pos;
}
