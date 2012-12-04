local self = {}
WubWub.HTMLFFTSource = WubWub.MakeConstructor (self, WubWub.FFTSource)

function self:ctor ()
	self.SampleRate = 192000
	self.FFTSize = 2048
end

function self:BucketFromFrequency (frequency)
	return frequency * #self.FrequencyAmplitudes / self.SampleRate + 1
end

function self:FrequencyFromBucket (bucketIndex)
	return (bucketIndex - 1) * self.SampleRate / #self.FrequencyAmplitudes
end

function self:SetFrequencyAmplitudes (frequencyAmplitudes)
	self.FrequencyAmplitudes = frequencyAmplitudes or {}
end

function self:SetFFTSize (fftSize)
	self.FFTSize = fftSize
end

function self:SetSampleAmplitudes (sampleAmplitudes)
	self.SampleAmplitudes = sampleAmplitudes or {}
end

function self:SetSampleRate (sampleRate)
	self.SampleRate = sampleRate
end

WubWub.HTMLFFTSource = WubWub.HTMLFFTSource ()