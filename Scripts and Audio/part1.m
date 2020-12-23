%Time stretching with ¦Á = 1.52, without phase locking, 
%generating a reverberant output signal. 

%[d,sr]=audioread('clarinet.wav');
[d,sr]=audioread('check.wav');
%[d,sr]=audioread('bobDylan.wav');

alpha = 1.52;
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

%this part obtains all the frames of t
allFFTt = zeros(N,numberFrame);
for p = 0:numberFrame-1
    eachHop2 = HopA * p;
    ti = eachHop2+HopS+1;
    oneFFT2 = fft(hann(M).*d(ti:ti+M-1));
    allFFTt(:,p+1) = oneFFT2;
end

Yu0 = allFFTs(:,1);
alliFFT = zeros(N,numberFrame);
alliFFT(:,1) = hann(M).*real(ifft(Yu0));
Yui_m1 = Yu0;

for p = 1:numberFrame-1
    Yui = zeros(N,1);
    for k = 1:N
        Xtik = allFFTt(k,p);
        Xsik = allFFTs(k,p);
        Yuik_m1 = Yui_m1(k);
        Yuik = Xtik*(Yuik_m1/Xsik)*abs(Xsik/Yuik_m1);
        Yui(k) = Yuik;
    end
    Yui_m1 = Yui;
    alliFFT(:,p+1) = hann(M).*real((ifft(Yui)));
    
end

y = zeros(HopS*(numberFrame-1)+M,1); 
for p = 0:numberFrame-1
    y(p*HopS+1:p*HopS+M) = y(p*HopS+1:p*HopS+M) + alliFFT(:,p+1);
end

if max(y) > 1
    y = y/(max(y)+0.05);
end

sound(y,sr)

%audiowrite('unlockedClarinet.wav',y,sr)
%audiowrite('unlockedCheck.wav',y,sr)
%audiowrite('unlockedBobDylan.wav',y,sr)
