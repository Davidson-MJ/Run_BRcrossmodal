%Tone / sound calibration script.
beep off %disable system beep for extended key press.
% screenPREPs

calibratejustAUDIO=1;


Screen('TextSize', params.windowPtr, 20);
KbName('UnifyKeyNames')

switch params.calibrateinLog
    case 0
        MultiScale = [([1:10])/100, 2, 3, 4 , 5]; 
    case 1
        MultiScale = [([1:10].^2)/100, 4, 9, 16]; %avoids distortion. 
        %=[.01 .04 .09 .16 .25 .36 .49 .64 .81, 1, 4, 9, 16]
end
%change to half screen?

%>>>>>>>>>>>> SHOW INSTRUCTIONS
for iDrawLR = 0:1
    
    
    %>>>>>>>>>>> LEFT EYE
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
    
    %find center
    imCenter = params.windowRect/2;
    
    %Draw the frame in center.
    Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
    
    
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'Press any key to begin Tone Calibration' '\n''\n'...
        'Your task is to equate the perceptual intensity of Auditory and Tactile input.' ...
        '\n \n Hold "q" to quit'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
    
end

Screen('Flip', params.windowPtr);
KbWait;
pause(2);


for iLowandHigh= 1:4
    
    if mod(iLowandHigh,2)~=0
        testingtones='Low hz tones';
    else
            testingtones='High hz tones';
    end
    
for iDrawLR = 0:1
    
    
    %>>>>>>>>>>> LEFT EYE
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
    
    %find center
    imCenter = params.windowRect/2;
    
    %Draw the frame in center.
    Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
    
    if calibratejustAUDIO==1
    DrawFormattedText(params.windowPtr, [ 'Testing ' num2str(testingtones) '\n' '\n' 'Press and Hold ' '\n' 'Down(-)/Up(+) to change Audio Intensity'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
    else
    DrawFormattedText(params.windowPtr, [ 'Testing ' num2str(testingtones) '\n' '\n' 'Press and Hold ' '\n' 'Down(-)/Up(+) to change Audio,' '\n' 'Left(-)/Right(+) for Tactile'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
    end
end
Screen('Flip', params.windowPtr);


%audio settings
carFreq = params.carFreq;      % lower carrier freq will produce less noise from tactile driver
modIdx = 1;         %
phaseC = 0;         %
phaseM = 0;         %

audRate = 44100;   % Audio sampling rate
tRamp = 0.01;      % duration in seconds of on/off cosine ramps


TrialTime=params.Trialdurs.med;

% make tones for XMODAL stim
[ audamLow ] = makeAMtone(params.FreqLow, modIdx, phaseM, carFreq, phaseC, TrialTime, audRate,tRamp);

[ audamHigh ] = makeAMtone(params.FreqHigh, modIdx, phaseM, carFreq, phaseC, TrialTime, audRate,tRamp);


switch iLowandHigh
    case 1 %low tones, start audio above Tactile.
         AUDtonestoplay = audamLow;
        TACtonestoplay=audamLow;
        audfMultitracker = 11; %the audio output for "11" is much louder than tactile "11" to begin with.
        tacfMultitracker = 11; 
    case 2 %high tones, start audio below tactile 
        AUDtonestoplay = audamHigh;
        TACtonestoplay=audamHigh;
        audfMultitracker = 4;
        tacfMultitracker = 11;
    case 3 %low tones, start audio below tactile
        AUDtonestoplay = audamLow;
        TACtonestoplay=audamLow;
        audfMultitracker = 4;
        tacfMultitracker = 11;        

    case 4 %high tones, start audio above tactile.
        AUDtonestoplay = audamHigh;
        TACtonestoplay=audamHigh;
        audfMultitracker =11;
        tacfMultitracker =11;
end

quitkey     = KbName('Q');
rampUp_Audio = KbName('UpArrow');
rampDown_Audio = KbName('DownArrow');

rampUp_Tactile = KbName('RightArrow');
rampDown_Tactile = KbName('LeftArrow');


        
audfMulti = MultiScale(audfMultitracker);
tacfMulti=MultiScale(tacfMultitracker);
%open handle to audio device
%%
audio_dev = audio_device_init( [], [], audRate, 1);  % device handle with two channels (signals can be transmitted through stereo splitters for tactile and audio)

Trialc=1;
maxTrials=60;
ListenChar(2)
%
while Trialc<100
    WaitSecs(3)        
    
     if Trialc>maxTrials
        break
    end

    %auditory is left channel, tactile is right.
        PsychPortAudio('FillBuffer', audio_dev.handle, [AUDtonestoplay*audfMulti;TACtonestoplay*tacfMulti]);

         PsychPortAudio('DeleteBuffer');
    
    %play tone
        PsychPortAudio('Start',audio_dev.handle);
  %%
        WaitSecs(5)
    %check for response.
    [keyIsDown,secs, keyCode] = KbCheck();
    if keyIsDown
        
        if any(find(keyCode)==quitkey)
            break
        
        elseif any(find(keyCode)==rampUp_Audio)
        
            audfMultitracker = audfMultitracker+1; %ramp up the amplitude
            
            if audfMultitracker>length(MultiScale)
                audfMultitracker=audfMultitracker-1;
            end
            audfMulti= MultiScale(audfMultitracker);
            
            disp(['Audio =' num2str(audfMulti)]);
        
        elseif any(find(keyCode)==rampUp_Tactile)
            
            tacfMultitracker = tacfMultitracker+1; %ramp up the amplitude
            
            if tacfMultitracker>length(MultiScale)
                tacfMultitracker=tacfMultitracker-1;
            end
            tacfMulti = MultiScale(tacfMultitracker);
            
            disp(['Tactile =' num2str(tacfMulti)]);
            
        elseif any(find(keyCode)==rampDown_Audio)
            
            audfMultitracker = audfMultitracker-1; %ramp up the amplitude
            
            if audfMultitracker==0
                audfMultitracker=1; %minimum amp.
            end
            audfMulti = MultiScale(audfMultitracker);
            
            disp(['Audio =' num2str(audfMulti)]);
            
        elseif any(find(keyCode)==rampDown_Tactile)
            tacfMultitracker=tacfMultitracker-1;
            
            if tacfMultitracker==0
                tacfMultitracker=1; %minimum amp.
            end
            tacfMulti = MultiScale(tacfMultitracker);
            
            disp(['Tactile =' num2str(tacfMulti)]);
        end
    end
            
    
     
    Trialc=Trialc+1;
  
end
%%
%save new parameters
switch iLowandHigh
    case 1
        params.LowHzAmpMulti_AUD1=audfMulti;
        params.LowHzAmpMulti_TAC1=tacfMulti;
        params.calibLowtrials_n1=Trialc;
    case 2
        
        params.HighHzAmpMulti_AUD1=audfMulti;
        params.HighHzAmpMulti_TAC1=tacfMulti;
        params.calibHightrials_n2=Trialc;
    case 3
        params.LowHzAmpMulti_AUD2=audfMulti;
        params.LowHzAmpMulti_TAC2=tacfMulti;
        params.calibLowtrials_n2=Trialc;
    case 4
        params.HighHzAmpMulti_AUD2=audfMulti;
        params.HighHzAmpMulti_TAC2=tacfMulti;
        params.calibHightrials_n2=Trialc;
end


PsychPortAudio('DeleteBuffer');
PsychPortAudio('Close', audio_dev.handle);


end

pause(1);
%indicate end of calibration.
for iDrawLR = 0:1
    
    
    %>>>>>>>>>>> LEFT EYE
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
    
    %find center
    imCenter = params.windowRect/2;
    
    %Draw the frame in center.
    Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
    
    
    DrawFormattedText(params.windowPtr, [ 'Beginning Practice Blocks' ] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
    
end
Screen('Flip', params.windowPtr);

pause(3);
%%
%Calculate final tone difference, based on average. 
params.LowHzAmpMulti_AUD = (params.LowHzAmpMulti_AUD1 + params.LowHzAmpMulti_AUD2)/2;
params.LowHzAmpMulti_TAC = (params.LowHzAmpMulti_TAC1 + params.LowHzAmpMulti_TAC2)/2;

params.HighHzAmpMulti_AUD= (params.HighHzAmpMulti_AUD1 + params.HighHzAmpMulti_AUD2)/2;
params.HighHzAmpMulti_TAC= (params.HighHzAmpMulti_TAC1 + params.HighHzAmpMulti_TAC2)/2;

        
