carFreq = 120;      % lower carrier freq will produce less noise from tactile driver
modIdx = 1;         %
phaseC = 0;         %
phaseM = 0;         %

audRate = 44100;   % Audio sampling rate
tRamp = 0.010;      % duration in seconds of on/off cosine ramps


TrialTime=params.Trialdurs;

% make tones for XMODAL stim
[ audamLow ] = makeAMtone(params.FreqLow, modIdx, phaseM, carFreq, phaseC, TrialTime, audRate,tRamp);

[ audamHigh ] = makeAMtone(params.FreqHigh, modIdx, phaseM, carFreq, phaseC, TrialTime, audRate,tRamp);


%
InitializePsychSound(1)
%
devs=PsychPortAudio('GetDevices');
% %
%  PsychPortAudio('Close', dev.handle);
dev=[]
mode=1;
latency_class=1;
sfreq=44100;
channels=2
%%
 idev= 13%:length(devs)  14 15 
    disp(['Trying device ' num2str(idev)])
    
    dev_index=devs(idev).DeviceIndex;
        
    dev.handle = PsychPortAudio('Open', dev_index, mode, latency_class, [], channels);
%
    PsychPortAudio('RunMode', dev.handle, 1);   % keep device in "hot standby" state...
%     PsychPortAudio(
    PsychPortAudio('FillBuffer', dev.handle, [audamLow;audamLow]);
   PsychPortAudio('Start',dev.handle);
%    Waitsecs(2)
pause(2)
    PsychPortAudio('DeleteBuffer');
    %%
     PsychPortAudio('Close', dev.handle);
