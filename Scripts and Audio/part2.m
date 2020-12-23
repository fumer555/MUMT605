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
 

%this part does the phase vocoder, outputing fragments that are windowed
Yu0 = allFFTs(:,1);
alliFFT = zeros(N,numberFrame);
alliFFT(:,1) = hann(M).*real(ifft(Yu0));
Yui_m1 = Yu0;
Yus = zeros(N,numberFrame);
Yus(:,1) = Yu0;
phases = zeros(N,numberFrame);
phases(:,1) = angle(Yu0);


for p = 1:numberFrame-1
    %To calculate the Yui, the value of Yui is not needed 
    %therefore it is ok to leave an empty vector here
    Yui = zeros(N,1);
    for k = 2:N-1
        Xtik = allFFTt(k,p);
        Xsik = allFFTs(k,p);
        Zuik_m1 = Yui_m1(k)-Yui_m1(k-1)-Yui_m1(k+1);
        Yuik= Xtik*(Zuik_m1/Xsik)*abs(Xsik/Zuik_m1);
        Yui(k) = Yuik;
    end
    Yui(1) = Yui(2)*exp(1i*pi);
    Yui(N) = Yui(1023)*exp(1i*pi);
    Yui_m1 = Yui;
    Yus(:,p+1) = Yui;
    phases(:,p+1) = angle(Yui);
    alliFFT(:,p+1) = hann(M).*real((ifft(Yui)));
end


%Here adds every windowed fragments up
y = zeros(HopS*(numberFrame-1)+M,1); 
for p = 0:numberFrame-1
    y(p*HopS+1:p*HopS+M) = y(p*HopS+1:p*HopS+M) + alliFFT(:,p+1);
end

if max(y) > 1
    y = y/(max(y)+0.05);
end

sound(y,sr)


%audiowrite('lockedClarinet.wav',y,sr)
%audiowrite('lockedCheck.wav',y,sr)
%audiowrite('lockedBobDylan.wav',y,sr)