%% Touch & Audio

%audio settings
carFreq = params.carFreq;      % lower carrier freq will produce less noise from tactile driver
modIdx = 1;         % depth of modulation
phaseC = 0;         %
phaseM = 0;         %

audRate = 44100;   % Audio sampling rate
tRamp = 0.01;      % duration in seconds of on/off cosine ramps
% tRamp = 0.005;      % duration in seconds of on/off cosine ramps

for triallength = 1:4
    switch triallength
        case 1
            TrialTime= params.Trialdurs.vonly;
        case 2
            TrialTime= params.Trialdurs.short;
        case 3
            TrialTime= params.Trialdurs.med;
        case 4
            TrialTime= params.Trialdurs.long;
    end
    % make tones for XMODAL stim
    [ outputamLow ] = makeAMtone(params.FreqLow, modIdx, phaseM, carFreq, phaseC, TrialTime, audRate,tRamp);
    
    
    [ outputamHigh ] = makeAMtone(params.FreqHigh, modIdx, phaseM, carFreq, phaseC, TrialTime, audRate,tRamp);
    
    %%
    tonelengthframes = (((1:length(outputamLow))/audRate)*scrRate);
    %%
    clearvars amTone1 amTone2
    % Deletes channels if we want
    
    nosoundvector = zeros(1, size(outputamLow,2));
    
    
    switch Xmodaltype  %multipliers set by Tone Calibration per ppant.
        
        case 0 %visual only, no stimulus to output.
            outputLow=[nosoundvector; nosoundvector];
            outputHigh=[nosoundvector; nosoundvector];
            
        case {1, 2} %A+T so left and right channel for output In phase (Left is AUDIO)
            outputLow = [outputamLow * params.LowHzAmpMulti_AUD; outputamLow *params.LowHzAmpMulti_TAC];
            outputHigh= [outputamHigh * params.HighHzAmpMulti_AUD; outputamHigh * params.HighHzAmpMulti_TAC];
            
        case {3, 4} %Aud only %using LEFT CHANNEL for  audio splitter. In phase
            outputLow = [params.LowHzAmpMulti_AUD * outputamLow; nosoundvector]; %multiplier set by Tone Calibration per ppant.
            outputHigh= [params.HighHzAmpMulti_AUD * outputamHigh; nosoundvector];
            
        case {5, 6} %Tac only ,  %In Phase
            outputLow = [nosoundvector;outputamLow *params.LowHzAmpMulti_TAC];
            outputHigh= [ nosoundvector;outputamHigh *params.HighHzAmpMulti_TAC];
            
    end
    
    
    switch  triallength
        case 1
            outputvisonly = outputLow;
        case 2
            outputLow_short=outputLow;
            outputHigh_short=outputHigh;
        case 3
            
            outputLow_med=outputLow;
            outputHigh_med=outputHigh;
        case 4
            
            outputLow_long=outputLow;
            outputHigh_long=outputHigh;
    end
    
    
end


