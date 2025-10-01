%% Sensory Panel - Music Processing
% Scott Bannister, 17.10.2022
% Script compression, bandwidth filtering,
% and determining the SNRs of music and noise (to keep consistent across
% samples)

%% Set working directory and prepare data and variables

cd("Your Directory Here")

% Get list of audio files for iteration
files = dir(cd);

% Set up Single channel WDRC, -40dB threshold, 10:1 ratio, 5ms attack, 70ms release
dRC = compressor(-40, 10, 'AttackTime', 0.005, 'ReleaseTime', 0.07);

% Set sample rate
fs = 44100;

%% Loop through to generate alternative music sample conditions (original, compressed, bandpass, car noise)

for i = 1:length(files)
    tmp = files(i);
    songName = split(tmp.name, '_');

    % Work with original audio to create original/compressed/bandpass
    if contains(tmp.name, 'Original')
        original = audioread(tmp.name);
        original = LUFSNorm(original, -23, fs);
        originalName = char(append('MATLAB_Exports\', songName(1,1),'_Original.wav'));
        audiowrite(originalName, original, fs);

        % Compression
        compAudio = dRC(original);
        compAudio = LUFSNorm(compAudio, -23, fs);
        compName = char(append('MATLAB_Exports\', songName(1,1),'_Comp.wav'));
        audiowrite(compName, compAudio, fs);

        % Bandpass filter
        bandAudio = bandpass(original, [300, 5000], 44100, Steepness = 0.95);
        bandAudio = LUFSNorm(bandAudio, -23, fs);
        bandName = char(append('MATLAB_Exports\', songName(1,1), '_Bandpass_0.3_5kHz.wav'));
        audiowrite(bandName, bandAudio, fs);

    % Work with RIR audio to create car noise samples
    elseif contains(tmp.name, 'RIR')
        audioIR = audioread(tmp.name);
        noiseName = char(append(songName(1,1), '_Noise.wav'));
        noise = audioread(noiseName);
        audioNoise = audioIR + noise;
        r = snr(audioNoise, noise);
        l = (r <= 5.05) & (r >= 4.95);

        while l == 0
            if r > 5.05
                noise = noise * 1.01;
                audioNoise = audioIR + noise;
                r = snr(audioNoise, noise);
                disp(r);
                l = (r <= 5.05) & (r >= 4.95);
            elseif r < 4.95
                noise = noise / 1.01;
                audioNoise = audioIR + noise;
                r = snr(audioNoise, noise);
                disp(r);
                l = (r <= 5.05) & (r >= 4.95);
            end    
        end
        audioNoise = LUFSNorm(audioNoise, -23, fs);
        noiseName = char(append('MATLAB_Exports\', songName(1,1), '_Car.wav'));
        audiowrite(noiseName, audioNoise, fs)
    end

    % LUFS Normalization for all OBA samples
    %if contains(tmp.name, '_-6')
        %oba = audioread(tmp.name);
        %oba = LUFSNorm(oba, -23, fs);
        %obaName = char(append('MATLAB_Exports\', tmp.name));
        %audiowrite(obaName, oba, fs);

    %elseif contains(tmp.name, '_+6')
        %oba = audioread(tmp.name);
        %oba = LUFSNorm(oba, -23, fs);
        %obaName = char(append('MATLAB_Exports\', tmp.name));
        %audiowrite(obaName, oba, fs);
    %end   
 
end

%% Generate volume reference sample

tester = audioread("Volume_Reference.wav");
tester = LUFSNorm(tester, -23, fs);
testerName = char(append('MATLAB_Exports\', 'Volume_Reference.wav'));
audiowrite(testerName, tester, fs);