function y = index5(thisfft,fs,N)

%The function used to find the Index-5 of a frame. 
%The function is called by the 3 following scripts.  

Y = thisfft;
allPhases = angle(Y);

f = (0:N-1)*fs/N;


Y = abs(Y(1:ceil(N/2))); % throw away redundant half of fft
Xi = [];

%We first seek for a threshold of 30 dB for the peak
%if less than 5 peaks is found, we go for 20 dB, etc.
threshold = 10^(30/20);  % 30 dB 

for n = 2:length(Y)-2 % search for peak indices
   if Y(n+1) <= Y(n) && Y(n-1) < Y(n) && Y(n) > threshold   
    Xi = [Xi, [n,Y(n)]'];
  end
end


if size(Xi)<5
    Xi = [];
    threshold = 10^(20/20);
    for n = 2:length(Y)-2 % search for peak indices
      if Y(n+1) <= Y(n) && Y(n-1) < Y(n) && Y(n) > threshold
        Xi = [Xi, [n,Y(n)]'];
      end
    end
end

if size(Xi)<5
    Xi = [];
    threshold = 10^(10/20);
    for n = 2:length(Y)-2 % search for peak indices
      if Y(n+1) <= Y(n) && Y(n-1) < Y(n) && Y(n) > threshold
        Xi = [Xi, [n,Y(n)]'];
      end
    end
end

if size(Xi)<5
    Xi = [];
    threshold = 10^(0/20);
    for n = 2:length(Y)-2 % search for peak indices
      if Y(n+1) <= Y(n) && Y(n-1) < Y(n) && Y(n) > threshold
        Xi = [Xi, [n,Y(n)]'];
      end
    end
end

if size(Xi)<5
    ErrorReport = 'error: The Index-5 cannot be used for this signal'
end

[B,I] = maxk(Xi(2,:),5);


DaPhase = zeros(3,5);

for peakNumber = 1:5
    
    Jin = Xi(1,I(peakNumber));
    phaseAndAplitude = zeros(3,1);
    
    for numba = -1:1
        oneValue = allPhases(Jin+numba);
        phaseAndAplitude(numba+2) = oneValue;
    end
    
    DaPhase(:,peakNumber) = phaseAndAplitude;


end


doublesizePhase = size(DaPhase);
allPhaseDifferences = zeros(2,5);
for p = 1:doublesizePhase(2)
    phaseDifferences = zeros(2,1);
    for q = 1:doublesizePhase(1)-1
        phaseDifference = DaPhase(q,p)-DaPhase(q+1,p);
        if (-pi < phaseDifference)&&(phaseDifference<= 0)
            phaseDifference = -phaseDifference;
        elseif (-2*pi < phaseDifference)&&(phaseDifference<= -pi)
            phaseDifference = 2*pi + phaseDifference;
        elseif (pi < phaseDifference)&&(phaseDifference<= 2*pi)
            phaseDifference = 2*pi - phaseDifference;
        end
        phaseDifferences(q) = phaseDifference;        
    end
    allPhaseDifferences(:,p) = phaseDifferences; 

end


listMean = mean(pi-allPhaseDifferences);

overallMean = mean(listMean);

y = overallMean;
