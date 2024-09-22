#version 300 es
uniform mat4 u_Model;       
uniform mat4 u_ModelInvTr;  
uniform mat4 u_ViewProj;    
uniform float u_Time;

in vec4 vs_Pos;             
in vec4 vs_Nor;             
in vec4 vs_Col;             

out vec4 fs_Nor;            
out vec4 fs_LightVec;       
out vec4 fs_Col;  
out float fs_Time;  
out vec4 fs_Pos;      

const vec4 lightPos = vec4(5, 5, 3, 1); 

void main()
{
    fs_Col = vs_Col;    
    fs_Time = u_Time;  
    
    vec4 modelposition = u_Model * vs_Pos;
    fs_LightVec = lightPos - modelposition;
    fs_Pos = modelposition;
    gl_Position = u_ViewProj * modelposition;
}
