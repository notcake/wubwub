WubWub.Volume = 1

function WubWub.GetVolume ()
	return WubWub.Volume
end

function WubWub.SetVolume (volumeFraction)
	volumeFraction = math.Clamp (volumeFraction, 0, 1)
	if WubWub.Volume == volumeFraction then return end
	
	WubWub.Volume = volumeFraction
	RunConsoleCommand ("wubwub_volume", tostring (WubWub.Volume))
	WubWub.DispatchEvent ("VolumeChanged", WubWub.Volume)
end

CreateClientConVar ("wubwub_volume", 1, true, false)
WubWub.SetVolume (GetConVar ("wubwub_volume"):GetFloat ())

cvars.AddChangeCallback ("wubwub_volume",
	function (_, _, value)
		WubWub.Volume = math.Clamp (tonumber (value), 0, 1)
		WubWub:DispatchEvent ("VolumeChanged", WubWub.Volume)
	end
)