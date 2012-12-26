if SERVER or
   file.Exists ("wubwub/wubwub.lua", "LUA") or
   file.Exists ("wubwub/wubwub.lua", "LCL") and GetConVar ("sv_allowcslua"):GetBool () then
	include ("wubwub/wubwub.lua")
end