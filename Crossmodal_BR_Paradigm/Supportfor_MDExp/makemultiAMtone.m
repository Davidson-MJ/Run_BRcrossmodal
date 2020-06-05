% function  [ AMtone ] = makeAMtone(Fm, modIdx, phaseM, Fc, phaseC, TrialTime, audRate,tRamp);

 %%for debug
  Fc = 300;      % lower carrier freq will produce less noise from tactile driver. Try 120 Hz% modIdx = 1;         %
 phaseC = 0;         %
 phaseM = 0;         %
 audRate = 44100;   % Audio sampling rate
 tRamp = 0.010; % duration in seconds of on/off cosine ramps
 TrialTime=6;
Fm=15;

clf

Fc2= 250;

% make the  CARRIER (vector for sinusoid)
cLam = 1/Fc; % wavelength in seconds
cMat = 1:(TrialTime * audRate);
c = .5 * sin(2*pi * cMat/ (cLam*audRate) + phaseC); %carrier

cLam = 1/Fc2; % wavelength in seconds
cMat = 1:(TrialTime * audRate);
c2 = .5 * sin(2*pi * cMat/ (cLam*audRate) + phaseC); %carrier



cmulti= c.*c2;

%check
% subplot(3,1,1)
% plot(c);
% xlim([0 1000])

subplot(3,1,1)
plot(cmulti)
xlim([0 44100])
title('1second of carrier tone')

% make the MODULATOR
mLam = 1/Fm;
mMat = 1:(TrialTime * audRate);
m = 1 + modIdx * cos(2*pi * mMat/ (mLam*audRate) - pi + phaseM );


% combine them and add soft on/off ramps
AMtone = (cmulti .* m);
rampMat = makeOnOffRamp(tRamp,length(mMat),audRate);
AMtone = AMtone.* rampMat;

AMtone=abs(AMtone);

subplot(3,1,2)
plot(AMtone)
xlim([0 44100])
title('1 second of AM tone')


params.tapers= [1, 1];
params.Fs= 44100;
params.fpass = [];
params.pad=[1];
[Spec, Freq] = mtspectrumc(AMtone, params);

% %plot mtspectrum for comparison

 subplot(3,1,3)
plot(Freq, 10*log10(Spec))
hold on
plot([Fm Fm], ylim, ['r' '--'])
  xlim([0 30])
title('mtspectrum')
%  end
 