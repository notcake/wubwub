if CLIENT and not file.Exists ("wubwub/wubwub.lua", "LCL") then return end
if CLIENT and not GetConVar ("sv_allowcslua"):GetBool () then return end
include ("wubwub/wubwub.lua")