local self = {}
WubWub.StreamFFTSource = WubWub.MakeConstructor (self, WubWub.FFTSource)

function self:ctor ()
	self.SampleRate = 192000
end

function self:BucketFromFrequency (frequency)
	return frequency * #self.FrequencyAmplitudes / self.SampleRate + 1
end

function self:FrequencyFromBucket (bucketIndex)
	return (bucketIndex - 1) * self.SampleRate / #self.FrequencyAmplitudes
end

function self:GetFrequencyAmplitudes ()
	self.FrequencyAmplitudes = {}
	for k, v in ipairs (stream.fft) do
		self.FrequencyAmplitudes [k] = v * 100 / 255 - 100
	end
	return self.FrequencyAmplitudes
end

function self:GetSampleAmplitudes ()
	self.SampleAmplitudes = stream.sampleamps or {}
	return self.SampleAmplitudes
end

WubWub.StreamFFTSource = WubWub.StreamFFTSource ()