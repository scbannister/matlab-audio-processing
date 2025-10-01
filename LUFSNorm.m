function normalizedAudio = LUFSNorm(x, y, fs)

%% Get integrated loudness levels of processed audio

loudness = integratedLoudness(x, fs);
gaindB = y - loudness;
gain = 10^(gaindB/20);
normalizedAudio = x.*gain;

end