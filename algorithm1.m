% for each song number of C will be different to get accurate BPM's
% song: sevdacicegi.wav, C = 34.2
% song: dudu.wav, C = 79
% song: beat.wav, C = 615.4
% song: aleph.wav, C = 134.27

% change the input_file_path during testing
input_file_path = '/Users/asligok/Desktop/362_project_n/sevdacicegi.wav';
[y, Fs] = audioread(input_file_path);

% change C for each song with the respective values above
C = 34.2;

y = mean(y, 2); % Convert to mono by averaging the stereo channels

% Parameters
windowSize = 1024;
numSubbands = 32;
numSegments = 43;

% Initialize variables
numSamples = length(y);
numWindows = floor(numSamples / windowSize);
Es = zeros(numSubbands, 1);
EWin = zeros(numSubbands, numSegments);
count = 0;

% Process each window
for i = 1:numWindows
    startIndex = (i-1) * windowSize + 1;
    endIndex = i * windowSize;
    windowData = y(startIndex:endIndex);

    % Compute FFT and obtain the frequency spectrum
    fftData = fft(windowData, windowSize);
    fftData = abs(fftData(1:windowSize/2+1)) / windowSize; % Normalize FFT

    % Divide the spectrum into subbands and compute energy in each subband
    for j = 1:numSubbands
        bandStart = (j-1) * floor(length(fftData) / numSubbands) + 1;
        bandEnd = j * floor(length(fftData) / numSubbands);
        Es(j) = (32 / windowSize) * sum(fftData(bandStart:bandEnd).^2);
    end

    % Compare each subband energy to its average energy in the buffer
    for j = 1:numSubbands
        avgE = mean(EWin(j, :));
        if Es(j) > C * avgE
            count = count + 1;
        end
    end

    % Update energy buffer
    EWin(:, 2:end) = EWin(:, 1:end-1); % Shift right
    EWin(:, 1) = Es; % Insert new energy values
end

% Calculate BPM
tsec = numSamples / Fs; % Total length in seconds
tmin = tsec / 60;
numBPM = count / tmin;

% Display the calculated BPM
fprintf('The calculated BPM is: %.1f\n', numBPM);