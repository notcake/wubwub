if WubWub then return end
WubWub = WubWub or {}

include ("glib/glib.lua")
include ("gooey/gooey.lua")

GLib.Initialize ("WubWub", WubWub)
GLib.AddCSLuaPackFile ("autorun/wubwub.lua")
GLib.AddCSLuaPackFolderRecursive ("wubwub")
GLib.AddCSLuaPackSystem ("WubWub")

include ("volume.lua")

include ("fftsource.lua")
include ("htmlfftsource.lua")
include ("streamfftsource.lua")
include ("visualizer.lua")

include ("player.lua")
include ("htmlplayerhtml.lua")
include ("htmlplayer.lua")

WubWub.Visualizer:SetFFTSource (WubWub.HTMLFFTSource)

WubWub.AddReloadCommand ("wubwub/wubwub.lua", "wubwub", "WubWub")

CreateClientConVar ("wubwub_hud_enabled", 1, true, false)

concommand.Add ("wubwub_fft_source",
	function (_, _, args)
		local sourceName = args [1]
		if sourceName == "wubwub" then
			WubWub.Visualizer:SetFFTSource (WubWub.HTMLFFTSource)
		elseif sourceName == "ukgamer" or sourceName == "stream" then
			WubWub.Visualizer:SetFFTSource (WubWub.StreamFFTSource)
		else
			print ("wubwub_fft_source <source>")
			print ("\tsource: wubwub|stream")
		end
	end
)