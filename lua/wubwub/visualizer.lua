local self = {}
WubWub.Visualizer = WubWub.MakeConstructor (self)

function self:ctor ()
	self.FFTSource = nil
	
	self.LastBeatTime = 0
	self.LastBeatAmplitude = 0
	
	hook.Add ("HUDPaint", "WubWub.Visualizer",
		function ()
			if not self.FFTSource then return end
			if not GetConVar ("wubwub_hud_enabled") then return end
			if not GetConVar ("wubwub_hud_enabled"):GetBool () then return end
			
			local frequencyAmplitudes = self.FFTSource:GetFrequencyAmplitudes ()
			local maxI = math.min (#frequencyAmplitudes, math.floor (self.FFTSource:BucketFromFrequency (22050)))
			local screenWidth = ScrW ()
			local dx = screenWidth / (maxI - 1)
			local x = -dx
			local y = 0
			local newY = 0
			
			local bassCutoff = self.FFTSource:BucketFromFrequency (220)
			
			local bassAmplitude = 0
			local amplitude = 0
			for i = 1, maxI do
				amplitude = amplitude + 10 ^ (frequencyAmplitudes [i] / 20)
				if i < bassCutoff then
					bassAmplitude = bassAmplitude + 10 ^ (frequencyAmplitudes [i] / 20)
				end
			end
			if bassAmplitude > 0.3 then
				self:Beat (bassAmplitude * 10)
			end
			
			self:PushMatrix ()
			
			xpcall (
				function ()
					local frequencyAmplitudes = self.FFTSource:GetFrequencyAmplitudes ()
					local maxI = math.min (#frequencyAmplitudes, math.floor (self.FFTSource:BucketFromFrequency (22050)))
					local screenWidth = ScrW ()
					local dx = screenWidth / (maxI - 1)
					local x = -dx
					local y = 0
					local newY = 0
					
					surface.SetDrawColor (GLib.Colors.White)
					
					for i = 1, maxI do
						newY = (frequencyAmplitudes [i] + 100) * 0.5 * ScrH () / 100
						
						--[[
						surface.DrawLine (
							(i - 2) * dx,
							0.5 * ScrH () - y,
							(i - 1) * dx,
							0.5 * ScrH () - newY
						)
						]]
						
						y = newY
					end
					
					surface.SetDrawColor (GLib.Colors.CornflowerBlue)
					
					self:RenderTimeAmplitudes ()
				end,
				print
			)
			
			self:PopMatrix ()
			
			--local r = bassAmplitude * 200
			local r = bassAmplitude * 200
			local rotationOffset = -self:GetBeatRotation ()
			surface.SetTexture (-1)
			surface.SetDrawColor (GLib.Colors.Red)
			for i = 0, 7 do
				surface.DrawTexturedRectRotated (
					ScrW () * 0.5 + r * math.sin ((i * 45 + rotationOffset) * math.pi / 180),
					ScrH () * 0.5 + r * math.cos ((i * 45 + rotationOffset) * math.pi / 180),
					math.min (r * 0.5, 40),
					math.min (r * 0.5, 10),
					i * 45 + rotationOffset
				)
			end
			-- surface.DrawCircle (ScrW () * 0.5, ScrH () * 0.5, r, GLib.Colors.Red)
		end
	)
	
	WubWub:AddEventListener ("Unloaded", tostring (self),
		function ()
			self:dtor ()
		end
	)
end

function self:dtor ()
	hook.Remove ("HUDPaint", "WubWub.Visualizer")
	WubWub:RemoveEventListener ("Unloaded", tostring (self))
end

function self:Beat (amplitude)
	self.LastBeatTime = SysTime ()
	self.LastBeatAmplitude = amplitude
end

function self:GetLastBeatAmplitude ()
	return self.LastBeatAmplitude
end

function self:GetLastBeatTime ()
	return self.LastBeatTime
end

function self:GetFFTSource ()
	return self.FFTSource
end

function self:SetFFTSource (fftSource)
	self.FFTSource = fftSource
end

-- Internal, do not call
function self:GetBeatRotation ()
	local dt = SysTime () - self:GetLastBeatTime ()
	local rotationEnvelope = math.exp (-dt * 5) * self:GetLastBeatAmplitude () * 2
	
	return rotationEnvelope * math.sin (CurTime () * math.pi * 16)
end

function self:GenerateMatrix ()
	local recenter = Matrix ()
	recenter:Translate (Vector (-ScrW () * 0.5, -ScrH () * 0.5, 0))
	
	local c = 1
	local dt = SysTime () - self:GetLastBeatTime ()
	
	local rotation = Matrix ()
	--rotation:Rotate (Angle (0, self:GetBeatRotation (), 0))
	
	local scale = Matrix ()
	c = 1 + math.exp (-dt * 5) * self:GetLastBeatAmplitude () * 0.2
	scale:Scale (Vector (c, c, 1))
	
	local uncenter = Matrix ()
	uncenter:Translate (Vector (ScrW () * 0.5, ScrH () * 0.5, 0))
	return uncenter * rotation * scale * recenter
end

function self:PopMatrix ()
	cam.PopModelMatrix ()
	render.CullMode (MATERIAL_CULLMODE_CCW)
end

function self:PushMatrix ()
	local matrix = self:GenerateMatrix ()
	cam.PushModelMatrix (matrix)
	
	local scale = matrix:GetScale ()
	scale = scale.x * scale.y * scale.z
	
	render.CullMode (scale < 0 and MATERIAL_CULLMODE_CW or MATERIAL_CULLMODE_CCW)
end

function self:RenderTimeAmplitudes ()
	local sampleAmplitudes = self.FFTSource:GetSampleAmplitudes ()
	local maxI = math.min (#sampleAmplitudes / 2, 1024)
	local dx = ScrW () / (maxI - 1)
	local x = -dx
	local y = 0
	local newY = 0
	
	surface.SetDrawColor (GLib.Colors.Silver)
	surface.DrawLine (0, ScrH () * 0.5, ScrW (), ScrH () * 0.5)
	
	surface.SetDrawColor (GLib.Colors.Orange)
	for i = 1, maxI do
		newY = sampleAmplitudes [i * 2] * ScrH () * 0.5 / 128
		newY = newY * 0.5
		
		surface.DrawLine (
			(i - 2) * dx,
			0.5 * ScrH () - y,
			(i - 1) * dx,
			0.5 * ScrH () - newY
		)
		
		y = newY
	end
end

WubWub.Visualizer = WubWub.Visualizer ()