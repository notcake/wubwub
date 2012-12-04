local self = {}
WubWub.FFTSource = WubWub.MakeConstructor (self)

function self:ctor ()
	self.FrequencyAmplitudes = {}
	self.SampleAmplitudes    = {}
end

function self:BucketFromFrequency (frequency)
	return frequency * #self.FrequencyAmplitudes / 44100 + 1
end

function self:GetBassAmplitude ()
	local bassCutoff = self:BucketFromFrequency (220)
	local amplitude = 0
	for i = 1, math.min (#self.FrequencyAmplitudes, bassCutoff) do
		amplitude = amplitude + 10 ^ (self.FrequencyAmplitudes [i] / 20)
	end
end

function self:GetFrequencyAmplitudes ()
	return self.FrequencyAmplitudes
end

function self:GetSampleAmplitudes ()
	return self.SampleAmplitudes
end

function self:FrequencyFromBucket (bucketIndex)
	return (bucketIndex - 1) * 44100 / #self.FrequencyAmplitudes
end