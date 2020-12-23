%For the FFT of a frame in the original signal, 
%the script outputs the phases and amplitudes of bins in 
%the surrounding of a peak to the console.  

[d,sr]=audioread('clarinet.wav');
alpha = 1;
fs = sr;

N = 1024;
M = 1024;
HopS = M/4;
HopA = ceil(M/4/alpha);
numberFrame = floor(length(d)/HopA) - ceil(M/HopA)-1;

%this part obtains all the frames of s
allFFTs = zeros(N,numberFrame);
for p = 0:numberFrame-1
    eachHop = HopA * p;
    si = eachHop+1;
    oneFFT = fft(hann(M).*d(si:si+M-1));
    allFFTs(:,p+1) = oneFFT;
end
frameChosen = allFFTs(:,100);

Y = frameChosen;
allPhases = angle(Y);

f = (0:N-1)*fs/N;
plot(f, 20*log10(abs(Y)))
xlim([0 15000])
grid
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')

Y = abs(Y(1:ceil(N/2))); % throw away redundant half of fft
Xi = [];
threshold = 10^(-1/20);  % 30 dB 


for n = 2:length(Y)-2 % search for peak indices
  if Y(n+1) <= Y(n) && Y(n-1) < Y(n) && Y(n) > threshold
    Xi = [Xi, n];
  end
end


Jin = Xi(1);
phaseAndAplitude = [];
for numba = -3:3
    upDate = [allPhases(Jin+numba) Y(Jin+numba)];
    phaseAndAplitude = [phaseAndAplitude
        upDate];
end

phaseAndAplitude




