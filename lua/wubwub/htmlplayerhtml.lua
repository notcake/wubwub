WubWub.HTMLPlayerHTML =
[[
<!doctype html>
<html>
	<head>
		<meta charset="utf-8">
		<title>Radio</title>
		<script type="text/javascript">
			var loaded = false;
			function debugMessage (message)
			{
				if (loaded)
				{
					console.log (message);
					if (window.wubwub)
					{
						wubwub.debugMessage (message)
					}
				}
				else
				{
					setTimeout (
						function ()
						{
							debugMessage (message);
						},
						20
					);
				}
			}
			
			var audioContext = window.AudioContext || window.webkitAudioContext;
			audioContext = new audioContext;
			
			var audioSource;
			
			var audioAnalyser = audioContext.createAnalyser ();
			audioAnalyser.fftSize = 2048;
			audioAnalyser.smoothingTimeConstant = 0;
			
			var gainNode = audioContext.createGainNode ();
			
			var audioElement;
			
			var player = new Object ();
			player.playResource = function (uri)
			{
				if (audioSource)
				{
					audioElement.pause ();
					audioSource.disconnect ();
					
					audioElement = undefined;
					audioSource  = undefined;
				}
				
				audioElement = document.createElement ("audio");
				audioElement.addEventListener ("canplay",
					function ()
					{
						audioSource = audioContext.createMediaElementSource (audioElement);
						audioSource.connect (audioAnalyser);
						audioAnalyser.connect (gainNode);
						gainNode.connect (audioContext.destination);
						
						audioElement.play ();
					}
				);
				audioElement.src = uri;
				audioElement.load ();
			};
			player.onLuaApiLoaded = function ()
			{
				loaded = true;
				wubwub.setSampleRate (audioContext.sampleRate);
				wubwub.setFFTSize (audioAnalyser.fftSize);
			};
			player.pause = function ()
			{
				audioElement.pause ();
			};
			player.setVolume = function (volume)
			{
				gainNode.gain.value = volume / 100;
			};
			player.setVolumeFraction = function (volumeFraction)
			{
				gainNode.gain.value = volumeFraction;
			};
			player.unpause = function ()
			{
				audioElement.play ();
			};
			
			var sampleAmplitudeUInt8s = new Uint8Array (1024);
			var sampleAmplitudeInt8s  = new Int8Array (sampleAmplitudeUInt8s.length);
			var fftAmplitudeFloats    = new Float32Array (audioAnalyser.frequencyBinCount);
			setInterval (
				function ()
				{
					if (!loaded) { return; }
					
					audioAnalyser.getFloatFrequencyData (fftAmplitudeFloats);
					audioAnalyser.getByteTimeDomainData (sampleAmplitudeUInt8s);
					for (var i = 0; i < sampleAmplitudeUInt8s.length; i++)
					{
						sampleAmplitudeInt8s [i] = sampleAmplitudeUInt8s [i] - 128;
					}
					
					if (window.wubwub)
					{
						wubwub.setFFTAmplitudes.apply (wubwub, fftAmplitudeFloats);
						wubwub.setSampleAmplitudes.apply (wubwub, sampleAmplitudeInt8s);
					}
				},
				20
			);
			
			window.onerror = function (message, file, lineNumber)
			{
				debugMessage (file + ":" + lineNumber + ": " + message);
			};
		</script>
	</head>
	
	<body>
	</body>
</html>
]]