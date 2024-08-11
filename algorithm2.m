% for each song number of subband will be different to get accurate BPM's
% song: sevdacicegi.wav, numSubband = 26
% song: dudu.wav, numSubband = 45
% song: beat.wav, numSubband = 45
% song: aleph.wav, numSubband = 56

% change the input_file_path during testing
input_file_path = '/Users/asligok/Desktop/362_project_n/sevdacicegi.wav';
[audioData, fs] = audioread(input_file_path);

% change numSubbands for each song with the respective values above
numSubbands = 26;

% select the middle 5 sec.
midPoint = floor(length(audioData) / 2);
duration = 5; 
N = duration * fs;

startIndex = midPoint - floor(N / 2);
endIndex = startIndex + N - 1;

a = audioData(startIndex:endIndex, 1);  % left part
b = audioData(startIndex:endIndex, 2);  % right part

% Differentiate the a[k] and b[k] signals using (R21 formula)
da = zeros(size(a));
db = zeros(size(b));

for k = 2 : N-1
    da(k) = 1/2 * fs * (a(k+1) - a(k-1));
    db(k) = 1/2 * fs * (b(k+1) - b(k-1));
end

% Compute the FFT of the complex signal
complexSignal = da + 1i * db;
fftResult = fft(complexSignal);
ta = real(fftResult);
tb = imag(fftResult);

% Generate the subbands array values
% for ease of use numSubbands is defined at the begining of the code

subbandEdges = logspace(log10(1), log10(N/2), numSubbands + 1);
tas = cell(numSubbands, 1);
tbs = cell(numSubbands, 1);

for s = 1:numSubbands
    startIdx = round(subbandEdges(s));
    endIdx = round(subbandEdges(s+1)) - 1;
    tas{s} = ta(startIdx:endIdx);
    tbs{s} = tb(startIdx:endIdx);
end

% Compute the energy of the correlation between the train of impulses and the signal
bpmRange = 60:10:200;
E = zeros(length(bpmRange), numSubbands);

for s = 1:numSubbands
    ws = length(tas{s});
    for bpmIdx = 1:length(bpmRange)
        BPMc = bpmRange(bpmIdx);
        Ti = floor(fs * 60 / BPMc);  % Calculate Ti

        % Generate train of impulses
        l = zeros(ws, 1);
        j = zeros(ws, 1);
        l(1:Ti:end) = max(da);
        j(1:Ti:end) = max(db);

        % Compute FFT of the train of impulses
        fftImpulse = fft(l + 1i * j, ws);

        % Compute correlation energy
        energy = sum(abs(fftImpulse .* conj(tas{s} + 1i * tbs{s})).^2);
        E(bpmIdx, s) = energy;
    end
end

% Determine the BPM for each subband and compute the final BPM
BPMmaxs = zeros(numSubbands, 1);
EBPMmaxs = zeros(numSubbands, 1);

for s = 1:numSubbands
    [EBPMmaxs(s), maxIdx] = max(E(:, s));
    BPMmaxs(s) = bpmRange(maxIdx);
end

% Compute the final BPM
finalBPM = sum(BPMmaxs .* EBPMmaxs) / sum(EBPMmaxs);

% Display the result
disp(['The detected BPM is: ', sprintf('%.1f', finalBPM)]);