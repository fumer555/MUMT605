%Time stretching without phase consideration, 
%very rough output signal. 

[d,sr]=audioread('check.wav');
alpha = 1.52;
N = 1024;
M = 1024;
HopS = M/4;
HopA = ceil(M/4/alpha);
numberFrame = floor(length(d)/HopA) - ceil(M/HopA)-1;

%this part obtains all the frames of s
Xsiks = zeros(N,numberFrame);
for p = 0:numberFrame-1
    eachHop = HopA * p;
    si = eachHop+1;
    oneFFT = hann(M).*d(si:si+M-1);
    Xsiks(:,p+1) = oneFFT;
end


y = zeros(HopS*(numberFrame-1)+M,1); 
for p = 0:numberFrame-1
    y(p*HopS+1:p*HopS+M) = y(p*HopS+1:p*HopS+M) + Xsiks(:,p+1);
end
if max(y) > 1
    y = y/max(y);
end

sound(y,sr)

%audiowrite('simpleVocoderCheck.wav',y,sr)
