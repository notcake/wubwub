local self = {}
WubWub.HTMLPlayer = WubWub.MakeConstructor (self, WubWub.Player)

function self:ctor ()
	self.Messages = {}
	
	self.HTMLPanel = vgui.Create ("DHTML")
	self.HTMLPanel:SetSize (0, 0)
	
	self.HTMLPanel.OnCallback = function (_, objectName, methodName, args)
		if objectName == "wubwub" then
			if methodName == "debugMessage" then
				self.Messages [#self.Messages + 1] = tostring (args [1])
				print ("WubWub: " .. tostring (args [1]))
			elseif methodName == "setFFTAmplitudes" then
				WubWub.HTMLFFTSource:SetFrequencyAmplitudes (args)
			elseif methodName == "setFFTSize" then
				WubWub.HTMLFFTSource:SetFFTSize (args [1])
			elseif methodName == "setSampleAmplitudes" then
				WubWub.HTMLFFTSource:SetSampleAmplitudes (args)
			elseif methodName == "setSampleRate" then
				WubWub.HTMLFFTSource:SetSampleRate (args [1])
			end
		end
	end
	self.HTMLPanel:NewObjectCallback ("wubwub", "debugMessage")
	self.HTMLPanel:NewObjectCallback ("wubwub", "setFFTAmplitudes")
	self.HTMLPanel:NewObjectCallback ("wubwub", "setFFTSize")
	self.HTMLPanel:NewObjectCallback ("wubwub", "setSampleAmplitudes")
	self.HTMLPanel:NewObjectCallback ("wubwub", "setSampleRate")
	
	self.HTMLPanel:SetHTML (WubWub.HTMLPlayerHTML or "")
	self.HTMLPanel:QueueJavascript ("player.onLuaApiLoaded ()")
	self.HTMLPanel:QueueJavascript ("player.setVolumeFraction (" .. tostring (WubWub.GetVolume ()) .. ")")
	WubWub:AddEventListener ("VolumeChanged", self:GetHashCode (),
		function (_, volume)
			self.HTMLPanel:QueueJavascript ("player.setVolumeFraction (" .. tostring (volume) .. ")")
		end
	)
	
	WubWub:AddEventListener ("Unloaded", self:GetHashCode (),
		function ()
			self:dtor ()
		end
	)
end

function self:dtor ()
	if self.HTMLPanel and self.HTMLPanel:IsValid () then
		self.HTMLPanel:Remove ()
	end
	self.HTMLPanel = nil
	WubWub:RemoveEventListener ("Unloaded", self:GetHashCode ())
end

function self:Debug (expression)
	self.HTMLPanel:QueueJavascript ("wubwub.debugMessage (" .. expression .. ");")
end

function self:PlayResource (uri)
	self.HTMLPanel:QueueJavascript ("player.playResource (\"" .. GLib.String.Escape (uri) .. "\")")
end

local CreateHTMLPlayer
function CreateHTMLPlayer ()
	if DHTML then
		WubWub.HTMLPlayer = WubWub.HTMLPlayer ()
	else
		timer.Simple (1, CreateHTMLPlayer)
	end
end
CreateHTMLPlayer ()

concommand.Add ("wubwub_play",
	function (_, _, args)
		local uri = table.concat (args)
		if uri == "" then return end
		WubWub.HTMLPlayer:PlayResource (uri)
	end
)

concommand.Add ("wubwub_pause",
	function (_, _, args)
		WubWub.HTMLPlayer.HTMLPanel:QueueJavascript ("player.pause ()")
	end
)

concommand.Add ("wubwub_unpause",
	function (_, _, args)
		WubWub.HTMLPlayer.HTMLPanel:QueueJavascript ("player.unpause ()")
	end
)