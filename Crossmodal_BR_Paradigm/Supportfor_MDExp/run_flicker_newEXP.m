function [blockout] = run_flicker_newEXP(Orien, Colour, Speed, Xmodaltype, params, iblock)
dbstop if error
%Shows the binocular rivalry images over an entire block, with
%Audio/Tactile output if needed.

%% Text code
% needed for DrawFormattedText with Exp.winRect ... otherwise text is not drawn
global ptb_drawformattedtext_disableClipping;
ptb_drawformattedtext_disableClipping=1;

stereoMode=params.stereoMode;
%% important: for now I will change Xmodaltype to auditory and tactile, 
% so that the sound comes through both audio channels. 
Xmodaltype=1;
% to revert to original comparisons, uncomment below:

% switch Xmodaltype
%     case 0
%         blockis='Visual only';
%     case {1 2}
%         blockis='Auditory and Tactile';
%     case {3 4}
        blockis='Auditory';
%     case {5 6}
%         blockis='Tactile';
%         
% end

% if mod(Xmodaltype,2)==0
%     phasetype='Out';
% else
    phasetype='In';
% end


%% Establish multiplier for visual contrast values, then create vis stim:

GreenMulti=params.downContrGr_block;
RedMulti = params.downContrRed_block;

CreateVisGratings;



%% Trial making
% Creates the trial order for all stim types (including vis only).

duration = params.blockduration; % Length of block (in seconds)
InitialTime = 5; % Beginning adjusting time
MinInterTrial = params.minITI; % Minimum time between trials (stim presentation).
Order = ExpInRand_new(params); % Runs the command to randomise trial presentation
Trials = zeros(1, duration*scrRate); % Makes a trial vector


%% Need different jitter lengths to maintain in/out of phase.

% For amounts of frames needed per 1 second cycle.
tspanLow = 0:scrRate/params.FreqLow-1;
tspanHigh = 0:scrRate/params.FreqHigh-1;


leftflicker = repmat(amLeft,1,length(Trials)); %create long vector (longer than we need)
leftflicker=leftflicker(1:length(Trials)); %then shrink to block length

rightflicker = repmat(amRight,1,length(Trials));
rightflicker=rightflicker(1:length(Trials));

switch Speed
    case 'L'
        congruentLow_Pos = find(leftflicker<.01); %congruent start points
        congruentHigh_Pos=find(rightflicker<.01);
    case 'H'
        congruentLow_Pos = find(rightflicker<.01); %congruent start points
        congruentHigh_Pos=find(leftflicker<.01);
        
end
% %%
if mod(Xmodaltype,2)==0 %even numbers are out of phase.
    %%
    Low_shiftIncongr = length(tspanLow)/2;
    High_shiftIncongr= length(tspanHigh)/2; % gives the number of frames needed to move 180deg out of phase.
    
    useLow = congruentLow_Pos+Low_shiftIncongr;
    useHigh = congruentHigh_Pos+High_shiftIncongr;
    if params.debugg==1
        %%
%         %check em
%         figure(1);
%         clf
%         subplot(2,1,1)
%         for i=1:10;
%             plot([useLow(i) useLow(i)], ylim, 'b');
%             hold on;
%             plot([congruentLow_Pos(i) congruentLow_Pos(i)], ylim, 'r')
%         end
%         title('Low timing')
%         subplot(2,1,2)
%         for i=1:10;
%             plot([useHigh(i) useHigh(i)], ylim, 'b');
%             hold on;
%             plot([congruentHigh_Pos(i) congruentHigh_Pos(i)], ylim, 'r')
%         end
%         title('High timing')
        %%
    end
    
    
else
    useLow=congruentLow_Pos;
    useHigh= congruentHigh_Pos;
end
%% Touch & Audio
Create_alltones;


%In case there is an audio_offset for the sound card, adjust all
%accordingly.
%e.g. 40ms delay, means the sound appears 40ms after it is called in the
%code
oneframeduration = 1000/scrRate; %in ms.

adjustframes= ceil(params.audiooffset/oneframeduration);

useLow = useLow- adjustframes; %subtracted, so that the start time is earlier, to accommodate lag.
useHigh = useHigh-adjustframes;


%%
Pos = InitialTime*scrRate+1;


if params.tryBLPos==0
    %align stimuli to PD trace.
    for i = 1:length(Order) %for each trial
        
        %%
        
        switch Order(i)
            case 1 % Nothing, just visual
                % Nothing here
                
            case 82 %Low short
                
                [~, start_tmp]= (min(abs(useLow-Pos))); %index the nearest frame that fits specifications (in or out of phase)
                Pos = useLow(start_tmp);
                TrialTime=params.Trialdurs.short;
                
            case 83% Low medium
                
                [~, start_tmp]= (min(abs(useLow-Pos))); %index the nearest frame that fits specifications (in or out of phase)
                Pos = useLow(start_tmp);
                TrialTime=params.Trialdurs.med;
                
            case  84 % Low long
                
                [~, start_tmp]= (min(abs(useLow-Pos))); %index the nearest frame that fits specifications (in or out of phase)
                Pos = useLow(start_tmp);
                TrialTime=params.Trialdurs.long;
                
            case 92
                [~, start_tmp]= (min(abs(useHigh-Pos)));
                Pos = useHigh(start_tmp);
                TrialTime=params.Trialdurs.short;
                
            case 93
                [~, start_tmp]= (min(abs(useHigh-Pos)));
                Pos = useHigh(start_tmp);
                TrialTime=params.Trialdurs.med;
                
            case 94 % High Freq
                [~, start_tmp]= (min(abs(useHigh-Pos)));
                Pos = useHigh(start_tmp);
                TrialTime=params.Trialdurs.long;
                
                
        end
        %%
        % Saves the specific trial in the vector
        Trials(1,Pos:Pos + ceil(TrialTime * scrRate)) = Order(i);
        
        % Moves the position to place the next trial in the vector
        newPos = Pos + ceil( (TrialTime+MinInterTrial+ 3*rand()) * scrRate);
        %
        %     %quick check of plot for sanity. make sure phase is aligned.
        if params.debugg==1
%             plot(Trials); hold on; plot(leftflicker,'b'); plot(rightflicker,'r');
%             legend('stim onset', 'left flicker', 'right flicker');
%             %plot tones in frames to see if congruent/in / out phase
%             switch Order(i)
%                 case {82,83,84}
%                     plot(tonelengthframes+Pos, outputamLow)
%                 case {92, 93 , 94}
%                     plot(tonelengthframes+Pos,outputamHigh)
%             end
%             title(['Audio and visual should be ' num2str(phasetype) ' phase'])
%             ylim([-1 3.5]); xlim([Pos-10 Pos+10])
%             xlabel('frames');
            
        end
        
        Pos=newPos;
        
    end
else
    if mod(Xmodaltype,2)==0; %out of phase
        shiftmeL = ceil(length(tspanLow)/2);
        shiftmeH=ceil(length(tspanHigh)/2);
    else
        shiftmeL = length(tspanLow);
        shiftmeH=length(tspanHigh);
    end
    % Adds all trials into a vector
    for i = 1:length(Order)
        switch Order(i)
            case 1 % Nothing, just visual
                % Nothing here
            case {82, 83, 84} % Low Freq
                
                Pos = Pos + shiftmeL - mod(Pos, length(tspanLow));
                
            case {92,93,94} % High Freq
                Pos = Pos + shiftmeH - mod(Pos, length(tspanHigh));
                
        end
        
        switch Order(i)
            case {82, 92}
                TrialTime=params.Trialdurs.short;
            case {83, 93}
                TrialTime=params.Trialdurs.med;
            case {84,94}
                TrialTime=params.Trialdurs.long;
        end
        
        % Saves the specific trial in the vector
        Trials(Pos:Pos + ceil(TrialTime * scrRate)) = Order(i);
        
        % Moves the position to place the next trial in the vector
        newPos = Pos + ceil( (TrialTime+MinInterTrial+ 3*rand()) * scrRate);
        %
        %     %quick check of plot for sanity. make sure phase is aligned.
        if params.debugg==1
            plot(Trials); hold on; plot(leftflicker,'b'); plot(rightflicker,'r');
            %plot tones in frames to see if congruent/in / out phase
            switch Order(i)
                case {82,83,84}
                    plot(tonelengthframes+Pos, outputamLow)
                case {92, 93 , 94}
                    plot(tonelengthframes+Pos,outputamHigh)
            end
            ylim([-1 3.5]); xlim([Pos-10 Pos+10])
        end
        
        Pos=newPos;
    end
end

%%
% clearvars tspanLow tspanHigh
%% Chunk Calcs
% Initialise the chunk recording (chunks are stimulus presentations)
Chunks = [];

% Checks where in the entire 2 minutes is the stimulus period
for i = 1:length(Trials)-1
    if Trials(i) == 0 && Trials(i+1) >= 1   % Detects start of chunk
        Chunks = [Chunks i+1];
        %         Chunks = [Chunks i];
    elseif Trials(i) >= 1 && Trials(i+1) == 0 % Detects end of chunk
        %         Chunks = [Chunks i+1];
        Chunks = [Chunks i];
    end
end

%% Creating the animation by sequencing texture handles .

for i = 1:length(amLeft)
    % Makes the frames ahead of time
    textureis= Lcol .* raisedCosMask * amLeft(i);
    %     imshow(textureis);
    %     title(['amLeftframe' num2str(i)])
    
    gratTex1(i)= Screen('MakeTexture', params.windowPtr, textureis);
    
    diodeis = LDiode * amLeft(i);
    % Makes the frames for the diodes
    LDiodeTex(i) = Screen('MakeTexture', params.windowPtr, diodeis);
end
%%

for i = 1:length(amRight)
    gratTex2(i) = Screen('MakeTexture', params.windowPtr, Rcol .* raisedCosMask * amRight(i) );
    RDiodeTex(i) = Screen('MakeTexture', params.windowPtr, RDiode * amRight(i) );
end
%%
if stereoMode~=4
%place together, overlapping for use with glasses.

for igrat=1:2
    allGratTex=[];
    switch igrat
        case 1
            
            gratis= gratTex1;
        case 2
           
            gratis= gratTex2;
    end
% Puts all the screens together
% nSecondsPerAnimationCycle = nFramesPerAnimationCycle/scrRate;
% nAnimationReps = duration/nSecondsPerAnimationCycle;

% allDiodeTexR = [];
% allDiodeTexG = [];

for i = 1:(10500/length(gratis))
    allGratTex = [ allGratTex gratis];
    
    %     allDiodeTexR = [ allDiodeTexR redDiodeTex ];
    %     allDiodeTexG = [ allDiodeTexG greenDiodeTex ];
end

switch igrat
    case 1
        allGratTex1=allGratTex;
    case 2
        allGratTex2=allGratTex; %used in analglyph mode.
end

end

end



%find max for aligning stereoscope
[~,showL]= (max(amLeft));
[~ ,showR] = (max(amRight));

% Prepares for tracking of data
rivTrackingData = NaN(length(Trials),3);

%% Playing sound
% InitializePsychSound(1)

% audio_dev = audio_device_initMBI(outputchans, inputchans, 44100, wantlowlatency);  % device handle with two channels (signals can be transmitted through stereo splitters for tactile and audio)

audRate=44100;
audio_dev = audio_device_init( [], [], audRate, 1);  % device handle with two channels (signals can be transmitted through stereo splitters for tactile and audio)
%%
priorityLevel=MaxPriority(params.windowPtr); %returns the maximum priorityLevel for named functions in this program

Priority(priorityLevel);



%% Draw adjustment screen with max colour values to align steresoscope
% Changes the size of the text

%To avoid colour/image adaptation on the retina, also shift the image Center slightly,
%every second block.
%%
imCenter = windowRect/2 ;

if mod(iblock,2)==0
    shiftImage = ceil(10*rand()); %10 pixel max
    % which direction to move?
    directionmv = randi(4); %4 diagonal directions.
    switch directionmv
        case 1 %diagonal upleft.
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) -shiftImage), (imCenter(4)-shiftImage)]; %[00--]
        case 2 %diagonal upRight
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) +shiftImage), (imCenter(4)-shiftImage)]; %[00+-]
        case 3 %diagonal downleft
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) -shiftImage), (imCenter(4)+shiftImage)]; %[00-+]
        case 4 % diagonal down Right
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) +shiftImage), (imCenter(4)+shiftImage)]; %[00+]
    end
end
%%
% if stereomode~=6
for drawLR=0:1
    Screen('TextSize', params.windowPtr, 20);
    
    ptris = drawLR; %for slecting LHS/RHS buffer
    
    switch drawLR
        case 0 %LHS
            
            texturetodraw=gratTex1(showL);
            DiodeisL=LDiodeTex(showL);
            DiodeplaceL =diodeMVrectL;
            
            DiodeisR=RDiodeTex(showR);
            DiodeplaceR=diodeMVrectR;
        case 1 %RHS
            texturetodraw=gratTex2(showR);
            %             Diodeis=RDiodeTex(showR);
            %             Diodeplace=diodeMVrectR;
            
    end
    
    
    %DRAW on both sides of screen.
    
    % Select appropriate-eye image buffer for drawing:
    
    if stereoMode==4
        Screen('SelectStereoDrawBuffer', params.windowPtr, ptris);
    else
        Screen('SelectStereoDrawBuffer', params.windowPtr);
    end
    
    %
    
    % Drawing the texture
    Screen('DrawTexture', params.windowPtr, texturetodraw,[], [(imCenter(3) -imSize/2), (imCenter(4)-imSize/2 ), (imCenter(3)+imSize/2), (imCenter(4)+imSize/2)]);%
    
    %     Screen('Flip', params.windowPtr)
    %    %
    %Draw the frame
    Screen('FrameRect', params.windowPtr,[255 255 255], [(imCenter(3) -imSize/2-10), (imCenter(4)-imSize/2-10 ), (imCenter(3)+imSize/2+10), (imCenter(4)+imSize/2+10)], 10);
    
    % Put the Diode on the screen
    if drawLR==0 %only on left side, place both.
        
        Screen('DrawTexture', params.windowPtr, DiodeisL, diodeStimRect, DiodeplaceL);
        Screen('DrawTexture', params.windowPtr, DiodeisR, diodeStimRect, DiodeplaceR);
    end
    
    % Drawing instructions for the user
    DrawFormattedText(params.windowPtr, ['Align stereoscope. \n Press any key when ready. Block ' num2str(iblock) ' of 24' '\n' '(' num2str(blockis) ')'],...
        'center', 'center', [255 255 255],15,[],[],[],[],...
        [0 0 windowRect(3) windowRect(4)+400]);
    
    if params.drawfixcross
        %Draw Fix cross
        drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
    end
    
    %Draw arrows
    Screen('TextSize', params.windowPtr, 60);
    switch drawLR
        case 0
            DrawFormattedText(params.windowPtr, '<', 'center', 'center', [0 200 0],[],[],[],[],[],...
                [0 0 windowRect(3)-(imSize*1.4) windowRect(4)]);
        case 1
            DrawFormattedText(params.windowPtr, '>', 'center', 'center', [200 0 0],[],[],[],[],[],...
                [0 0 windowRect(3)+(imSize*1.4) windowRect(4)]);
    end
    
end


Screen('Flip', params.windowPtr);
pause(0.2);
KbWait;

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


%% Start the Experimental Trials
if mod(Xmodaltype,2)==0
    congrMulti=-1; %out of phase
else
    congrMulti=1; %in phase.
end

% Preparing for timing
InitialTime = GetSecs;
iTest = -1;

% Trial Sound
SndPos = 1;


%%
while 1
    % Calculates the current frame, ignoring frames if they lag.
    i = ceil( (GetSecs - InitialTime) * scrRate );
    
    % Breaks if we finished
    if i > length(Trials)
        % Just in case final frame is not recorded, because that would
        % break the frame fixing function
        if isnan(rivTrackingData(end, 3))
            rivTrackingData(end, :) = [1, 0, GetSecs - InitialTime];
        end
        break
    end
    
    % Waits for the next frame if we are getting ahead of ourselves
    if i == iTest
        pause(((i+1)/scrRate) - GetSecs);
        i = i + 1;
    end
    
    iTest = i;
    
    try
        if params.EEG && Trials(i)<length(Trials)
            if Trials(i) > 0
                io64(params.ioObj,params.port,Trials(i)); % send trigger code to eegtrace
            elseif Trials(i)==0 && Trials(i-1)>0
                io64(params.ioObj,params.port,55); % send trigger code to eegtrace
            end
        end
        
        
    end
    
    %% Drawing
 
    if stereoMode~=4
        for drawLR=0:1
            % Changes the size of the text
            Screen('TextSize', params.windowPtr,60);
            
            
            switch drawLR
                case 0
                    numFrame = mod(i,length(gratTex1))+1;
                    texturetodraw=  gratTex1(numFrame);
                    diodetodrawL=LDiodeTex(numFrame);
                    diodeisatL=diodeMVrectL;
                    
                    numFrame = mod(i,length(gratTex2))+1;
                    
                    diodetodrawR=RDiodeTex(numFrame);
                    diodeisatR=diodeMVrectR;
                case 1
                    numFrame = mod(i,length(gratTex2))+1;
                    texturetodraw=  gratTex2(numFrame);
                    %             diodetodraw=RDiodeTex(numFrame);
                    %             diodeisat=diodeMVrectR;
            end
            
            
            % Select left-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
            
            
            %Draw the frame
            Screen('FrameRect', params.windowPtr,[255 255 255], [(imCenter(3) -imSize/2-10), (imCenter(4)-imSize/2-10 ), (imCenter(3)+imSize/2+10), (imCenter(4)+imSize/2+10)], 10);
            
            % Drawing the texture
            Screen('DrawTexture', params.windowPtr, texturetodraw,[], [(imCenter(3) -imSize/2), (imCenter(4)-imSize/2 ), (imCenter(3)+imSize/2), (imCenter(4)+imSize/2)]);%
            
            % Put the diodes on the left side of the screen
            if drawLR==0
                Screen('DrawTexture', params.windowPtr, diodetodrawL , diodeStimRect, diodeisatL);
                Screen('DrawTexture', params.windowPtr, diodetodrawR , diodeStimRect, diodeisatR);
            end
            if params.drawfixcross
                %     % Only if you want a cross in the circles
                drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
            end
            
            
            switch drawLR
                case 0
                    DrawFormattedText(params.windowPtr, '<', 'center', 'center', [0 200 0],[],[],[],[],[],...
                        [0 0 windowRect(3)-(imSize*1.4) windowRect(4)]);
                case 1
                    DrawFormattedText(params.windowPtr, '>', 'center', 'center', [200 0 0],[],[],[],[],[],...
                        [0 0 windowRect(3)+(imSize*1.4) windowRect(4)]);
            end
        end
        Screen('Flip', params.windowPtr);
    else
        
       for drawLR=0:1
            % Changes the size of the text
            Screen('TextSize', params.windowPtr,60);
            
            
            switch drawLR
                case 0
                    numFrame = mod(i,length(gratTex1))+1;
                    texturetodraw=  gratTex1(numFrame);
                    diodetodrawL=LDiodeTex(numFrame);
                    diodeisatL=diodeMVrectL;
                    
                    numFrame = mod(i,length(gratTex2))+1;
                    
                    diodetodrawR=RDiodeTex(numFrame);
                    diodeisatR=diodeMVrectR;
                case 1
                    numFrame = mod(i,length(gratTex2))+1;
                    texturetodraw=  gratTex2(numFrame);
                    %             diodetodraw=RDiodeTex(numFrame);
                    %             diodeisat=diodeMVrectR;
            end
            
            
            % Select left-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
            
            
            %Draw the frame
            Screen('FrameRect', params.windowPtr,[255 255 255], [(imCenter(3) -imSize/2-10), (imCenter(4)-imSize/2-10 ), (imCenter(3)+imSize/2+10), (imCenter(4)+imSize/2+10)], 10);
            
            % Drawing the texture
            Screen('DrawTexture', params.windowPtr, texturetodraw,[], [(imCenter(3) -imSize/2), (imCenter(4)-imSize/2 ), (imCenter(3)+imSize/2), (imCenter(4)+imSize/2)]);%
            
%             Put the diodes on the left side of the screen
            if drawLR==0
                Screen('DrawTexture', params.windowPtr, diodetodrawL , diodeStimRect, diodeisatL);
                Screen('DrawTexture', params.windowPtr, diodetodrawR , diodeStimRect, diodeisatR);
            end
            
            if params.drawfixcross
                %     % Only if you want a cross in the circles
                drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
            end
            
            
            switch drawLR
                case 0
                    DrawFormattedText(params.windowPtr, '<', 'center', 'center', [0 200 0],[],[],[],[],[],...
                        [0 0 windowRect(3)-(imSize*1.4) windowRect(4)]);
                case 1
                    DrawFormattedText(params.windowPtr, '>', 'center', 'center', [200 0 0],[],[],[],[],[],...
                        [0 0 windowRect(3)+(imSize*1.4) windowRect(4)]);
            end
        end
        Screen('Flip', params.windowPtr);
    end
    
    %% Sound playing
    
    try
        if i >= Chunks(SndPos)
            % PLAY SOUND
            switch Trials(i)
                case 1 % no sound
                    PsychPortAudio('FillBuffer', audio_dev.handle, [0; 0]);
                    stimtype = '1';
                case 82 % low freq sshort
                    PsychPortAudio('FillBuffer', audio_dev.handle, outputLow_short);
                    stimtype = '82';
                case 83 % Low medium
                    PsychPortAudio('FillBuffer', audio_dev.handle, outputLow_med);
                    stimtype = '83';
                case 84 % Low long
                    PsychPortAudio('FillBuffer', audio_dev.handle, outputLow_long);
                    stimtype = '84';
                case 92 % high freq sshort
                    PsychPortAudio('FillBuffer', audio_dev.handle, outputHigh_short);
                    stimtype = '92';
                case 93 % high medium
                    PsychPortAudio('FillBuffer', audio_dev.handle, outputHigh_med);
                    stimtype = '93';
                case 94 % high long
                    PsychPortAudio('FillBuffer', audio_dev.handle, outputHigh_long);
                    stimtype = '94';
                    
            end
            
            % Triggers for EEG
            if params.EEG
                io64(params.ioObj,params.port, num2str(stimtype)); % 88 = End of block
            end
            
%             PsychPortAudio('Start',audio_dev.handle);
            
            SndPos = SndPos + 2;
        end
    catch
    end
    
    %% Time and recording of data
    % Tracks the time from the start and now, which'll be given in seconds
    % (accurate to milliseconds)
    rivTrackingData(i,3) = GetSecs - InitialTime;
    
    % collect key press data frame by frame
    [~,~,keys] = KbCheck;
    
    
    %ensures that first column is left eye data.
    
    if Colour == 'G' % Same direction as arrows
        rivTrackingData(i,1:2) = [ keys(params.keyLeft) keys(params.keyRight) ]; % 80 & 79 are Left & Right arrows respectively (37 and 39 for windows)
        
    else % Opposite directions
        rivTrackingData(i,1:2) = [ keys(params.keyRight) keys(params.keyLeft) ]; % 80 & 79 are Left & Right arrows respectively
        
    end
    
end
%% Frame fixes
% Fixes missing frames by interpolating values for the time, and assuming
% that the user has not changed anything within those frames.

% Initialises the while loop

i=0;

while 1
    i = i + 1; % Next one
    
    % Ends the while loop for the end of the vector
    if i > length(rivTrackingData(:,3))
        break
    end
    
    % Replaces values if current value is NaN
    if isnan(rivTrackingData(i,3))
        
        % First time value
        t0 = rivTrackingData(i - 1, 3);
        
        % First i position
        iMark = i - 1;
        
        % Finds consecutive NaNs and fixes them
        while 1
            
            i = i + 1;
            
            % Starts the replacing when it finds a non-NaN value
            if ~isnan(rivTrackingData(i,3))
                Frames = i-iMark; % Finds the number of Frames in between
                t1 = rivTrackingData(i,3); % Second time value
                gap = (t1 - t0)/Frames; % The time gaps
                
                % Replaces all values
                for a = 1:Frames - 1
                    rivTrackingData(iMark + a,3) = ...
                        rivTrackingData(iMark + a - 1,3) + gap;
                    rivTrackingData(iMark + a,1:2) = ...
                        rivTrackingData(iMark + a - 1,1:2);
                end
                % Finally, breaks the entire loop
                break
            end
        end
    end
    
end



%% Trigger
if params.EEG
    io64(params.ioObj,params.port, 88); % 88 = End of block
end
%%
% Changes the size of the text back to small
Screen('TextSize', params.windowPtr,20);

% Deletes all buffers to free up space
PsychPortAudio('DeleteBuffer');
PsychPortAudio('Close', audio_dev.handle);
%% store output in structure
blockout.rivTrackingData= rivTrackingData;
blockout.Trials = Trials;
blockout.scrRate =scrRate;
blockout.Chunks =Chunks;
blockout.Order = Order;
blockout.useLow =useLow;
blockout.useHigh =useHigh;
blockout.adjustframes=adjustframes;
blockout.downcontrastG= params.downContrGr_block;
blockout.downcontrastR= params.downContrRed_block;
blockout.Casetype= blockis;
blockout.Phasetype= phasetype;
blockout.LeftEyeSpeed= Speed;
blockout.ppantblocknum=iblock;

% Deletes textures
%  Screen('Close');
%
% Screen('Close');
%Screen('CloseAll');
