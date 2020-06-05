function [params]=Grating_Calibration(params)
% This function cycles through Eye conditions to perceptually equate periods of
% dominance. Requires User Input after each trial.
% Note that the user input defines the contrast multiplier for red and
% green colours separately. 
% Importantly: BR dominance durations are not always equal between colours,
% and the saliency of low-frequency flicker also has the possibility to
% skew dominance durations. Hence we calibrate for each combination of:
% 1) left/right eye 
% 2) red/green colour
% 3) Low/High flicker 
% (8 conditions) to get approximately equal dominance durations, using adjusted contrast
% values.

% See command window for details.
% Q's: mjd070 at gmail dot com

dbstop if error
removemixedperiods=0;           % for plotting, show the periods of dual/or
                                % no key presss.
fontsize=30;
% MD 19-09-16

ListenChar( 2 ); %turn off key echo to matlab.

try Screen('TextSize', params.windowPtr, fontsize);
catch
    screenPREPs
    Screen('TextSize', params.windowPtr, fontsize);
end

%set up response collection and amplification.
% quitkey     = KbName('Q');
% rampUp_Audio = KbName('UpArrow');
% rampDown_Audio = KbName('DownArrow');
% rampUp_Tactile = KbName('RightArrow');
% rampDown_Tactile = KbName('LeftArrow');


%%

    
%for colour creation across eyes and stimulus conditions.
%Start with a low contrast to increase percept durations. 
params.downContrRed_condLG = .81; % multiply outgoing colour and audio by what contrast mod? (1 = full contrast colour, need GG correction?).
params.downContrGreen_condLG = .36; %

params.downContrRed_condHG = .36; %%high green conditon, so differnece not as strong.
params.downContrGreen_condHG = .36; %

params.downContrRed_condLR=.36; %high green conditon, so differnece not as strong.
params.downContrGreen_condLR=.36;

params.downContrRed_condHR=.81;
params.downContrGreen_condHR=.36;
%% %
% this determines the step increments to take when adjusting contrast values

if params.calibrateinLog==0 
    MultiScale=[1:10]/100;
else
    MultiScale=([1:10].^2)/100;
end


%% instructions for participant:

DrawCalibrationInstructions_visual


%% There are a number of conditions to equate.
%Low red vs High Green (Left/Right)
%Low Green vs High Red (Left/Right)
%4 trialtypes to repeat.


itypetotest=1;
%For a maximum of 15 trials of calibration, adjust the contrast values in
%each eye until approximately equal predominance is acheived.

for itrial=1:15 
    
    
    if itypetotest>4
        break
    end
    % screen may have been closed between receiving user input.
    try Screen('TextSize', params.windowPtr, fontsize);
    catch
        screenPREPs
        Screen('TextSize', params.windowPtr, fontsize);
    end
    
    %randomize grating orientation. %each new trial
    x=rand(1);
    if x>.5
        Orien = '-45';
    else
        Orien= '+45';
    end
    
    switch itypetotest
        case 1
            Speed='L'; Color='G';
            
            GreenMulti = params.downContrGreen_condLG;
            Gtracker = find(MultiScale==GreenMulti);
            
            RedMulti=params.downContrRed_condLG;
            Rtracker = find(MultiScale==RedMulti);
        case 2
            Speed='L'; Color='R'; %opp eyes to above
            GreenMulti = params.downContrGreen_condLR;
            Gtracker = find(MultiScale==GreenMulti);
            
            RedMulti=params.downContrRed_condLR;
            Rtracker = find(MultiScale==RedMulti);
        case 3
            Speed='H'; Color='G';
            GreenMulti = params.downContrGreen_condHG;
            Gtracker = find(MultiScale==GreenMulti);
            
            RedMulti=params.downContrRed_condHG;
            Rtracker = find(MultiScale==RedMulti);
        case 4
            Speed='H'; Color='R';
            GreenMulti = params.downContrGreen_condHR;
            Gtracker = find(MultiScale==GreenMulti);
            
            RedMulti=params.downContrRed_condHR;
            Rtracker = find(MultiScale==RedMulti);
    end
    Colour=Color;
    
    
    %% the visual gratings based on chosen multiplier of contrast:
    
    CreateVisGratings;
    
 
    %find max for aligning stereoscope
    [~,showL]= (max(amLeft));
    [~ ,showR] = (max(amRight));
    
    %% Draw adjustment screen with max colour values to align steresoscope
    % Changes the size of the text
    
    
    for drawLR=0:1
        Screen('TextSize', params.windowPtr, fontsize);
        
        ptris = drawLR; %for slecting LHS/RHS buffer
        
        switch drawLR
            case 0 %LHS
                
                texturetodraw=gratTex1(showL);
                
            case 1 %RHS
                texturetodraw=gratTex2(showR);
                
                
        end
        
        
        %DRAW on both sides of screen.
        
        % Select appropriate-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', params.windowPtr, ptris);
        
        %draw oval for alignment
        imCenter = windowRect/2;
        %%
        %     texturetodraw = Screen('MakeTexture', params.windowPtr, Rcol.*raisedCosMask);
        
        % Drawing the texture
        Screen('DrawTexture', params.windowPtr, texturetodraw);%
        
        %     Screen('Flip', params.windowPtr)
        %%    %
        %Draw the frame
        Screen('FrameRect', params.windowPtr,[255 255 255], [(imCenter(3) -imSize/2-10), (imCenter(4)-imSize/2-10 ), (imCenter(3)+imSize/2+10), (imCenter(4)+imSize/2+10)], 10);
        
        
        % Drawing instructions for the user
        DrawFormattedText(params.windowPtr, ['Press any key when ready' '\n' 'Eye Condition = ' num2str(itypetotest)],...
            'center', 'center', [255 255 255],15,[],[],[],[],...
            [0 0 windowRect(3) windowRect(4)+400]);
        
        
            %Draw Fix cross
            drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
        
        
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
    KbWait;
    
    % begin presentation.
    Trials=[1:60*scrRate]; % 60second trial.
    % Prepares for tracking of data
    rivTrackingData = NaN(length(Trials),3);
    
    
    disp(['RedMulti:' num2str(RedMulti)])
    disp(['GreenMulti:' num2str(GreenMulti)])
    
    InitialTime = GetSecs;
    iTest = -1;
    
    %begin presentation.
    while 1
        %
        
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
        
        
        %% Drawing
        for drawLR=0:1% draw our gratings.
            % Changes the size of the text
            Screen('TextSize', params.windowPtr,60);
            
            
            switch drawLR
                case 0
                    numFrame = mod(i,length(gratTex1))+1;
                    texturetodraw=  gratTex1(numFrame);
                    
                case 1
                    numFrame = mod(i,length(gratTex2))+1;
                    texturetodraw=  gratTex2(numFrame);
                    
            end
            
            
            % Select left-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
            imCenter = windowRect/2;
            
            %Draw the frame
            Screen('FrameRect', params.windowPtr,[255 255 255], [(imCenter(3) -imSize/2-10), (imCenter(4)-imSize/2-10 ), (imCenter(3)+imSize/2+10), (imCenter(4)+imSize/2+10)], 10);
            
            % Drawing the texture
            Screen('DrawTexture', params.windowPtr, texturetodraw); % May need to add [stimRect] in.
            
            
            
                %     % Only if you want a cross in the circles
                drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
            
            
            
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
        
        %% Time and recording of data
        % Tracks the time from the start and now, which'll be given in seconds
        % (accurate to milliseconds)
        rivTrackingData(i,3) = GetSecs - InitialTime;
        
        % collect key press data frame by frame
        [~,~,keys] = KbCheck;
        
        
        %ensures that first column is left eye data.
        
        if Color == 'G' % Same direction as arrows
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
    %%
    Screen('TextSize', params.windowPtr, fontsize);
    
    for iDrawLR = 0:1
        
        
        %>>>>>>>>>>> LEFT EYE
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
        
        %find center
        imCenter = params.windowRect/2;
        
        %Draw the frame in center.
        Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
        
        
        DrawFormattedText(params.windowPtr, [ '\n' '\n'...
            'Plotting Button Press Activity' '\n' ] , 'center', 'center', [255 255 255],50,[],[],[],[],...
            [0 0 params.windowRect(3) params.windowRect(4)]);
        
    end
    
    Screen('Flip', params.windowPtr);
    
    pause(2);
    
    
    %% plot activity.
    skswitch=0;
    %specify values for figures etc
    if Colour == 'R';
        Leftc = Colour;
        Rightc = 'Green';
    else
        Leftc=Colour;
        Rightc ='Red';
    end
    if Speed=='L'
        Lspeed = 'Low Speed';
        Rspeed = 'High Speed';
    else
        Lspeed='High Speed';
        Rspeed='Low Speed';
    end
    
    %Prepare the data into easy matrix
    Timing = rivTrackingData(:,3);
    
if isnan(Timing(1)) %start off with nans, find when the timing kicked in
    firstframe = length(find(isnan(Timing)));
    
    timestep = mean(diff(Timing(firstframe+2:end)));
    
    for ifix = 1:firstframe
        rivTrackingData(ifix, 1:2) = 0; %fill start of trial with zeros,
        rivTrackingData(ifix, 3) = ifix*timestep; % fill timing
    end
end

    %Total Exp is difference between button presses.
    TotalExp = rivTrackingData(:,2) - rivTrackingData(:, 1);
    
    
    %remove zeros at start of trial. if button press was late.
    if TotalExp(1)==0
        firstvalue=find(TotalExp, 1, 'first'); %finds first nonzero
        for i=1:firstvalue
            TotalExp(i,1)=TotalExp(firstvalue);
        end
    end
    
    %remove single frame 'mixed' reponses, as they mess up the calculations
    for i = 2:length(TotalExp)-1
        if TotalExp(i)==0
            if TotalExp(i+1)~=0 && TotalExp(i-1)~=0
                TotalExp(i) = TotalExp(i-1);
            end
        end
    end
    if removemixedperiods==1
        %remove periods of mixed response
        for i =2:length(TotalExp)-1
            if TotalExp(i)==0
                TotalExp(i) = TotalExp(i-1); %removes mixed periods
            end
        end
    end
    
    % finds 'switch' time points in button press (when changing from left to
% right eye)
if removemixedperiods==0
switchpoint=[];
switchtime=[];
switchFROM=[];
mixed_durationALL=[];

mixedperceptsindx = (find(TotalExp==0)); %whenever both or no buttons pressed
mixedperceptsindx(end+1) = mixedperceptsindx(end)+2; % allows for last if mixed percept not held till end of trial
mixedperceptsdur= diff(mixedperceptsindx); %of all those indexed, how long? (to find middle point of mixed periods)
%
endmixedcounter=1; %start counter
%
endmixedperceptsindx = find(mixedperceptsdur>1);

%%
for iframe = 2:length(Timing)-1 %switch point in frames
    
    if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
        if TotalExp(iframe)==0 %coming to mixed dominance, so find middle point of zeros
            
            %find the details of this period of mixed dominance.
            startmixedindx = iframe;
            endindxtmp = endmixedperceptsindx(endmixedcounter);
            endindx = mixedperceptsindx(endindxtmp);
            
            mixed_duration = endindx - startmixedindx;
            switchpointtmp= startmixedindx + round(mixed_duration/2);
            endmixedcounter=endmixedcounter+1;
            
            switchFROMp = TotalExp(iframe-1);%= what the person was seeing before they switched
            
            try switchTOp = TotalExp(endindx+1);
            catch
                switchTOp= TotalExp(end);
            end
            
            if switchFROMp ~=switchTOp; %actual swich around zeros not false switch [-1 0 0 0 -1] etc
                
                %should also be a switch which resulted in a long enough
                %change (not quick switch then switch back)
                %thus:
                
                if ~isempty(switchpoint)
                    if (switchpointtmp - (switchpoint(end))) > skswitch; %ie if (newswitch point - the previous) is longer than minimum required.
                        
                        switchFROM = [switchFROM, switchFROMp];
                        switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                        mixed_durationALL=[ mixed_durationALL, mixed_duration];
                    else
%                         switchpoint(end)=[]; %and if not then remove the previous switchpoitn, since we've captured a 'false'
%                         switchFROM(end) =[];
                    end
                else %its the first switchpoint
                    switchFROM = [switchFROM, switchFROMp];
                    switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                    mixed_durationALL=[ mixed_durationALL, mixed_duration];
                end
            end
        else %coming out of mixed dominance (which we skip), or a clean switch (rare)
            switchpointtmp = iframe;
            %clean switch
            if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
                if length(switchpoint)>0
                    if(switchpointtmp-(switchpoint(end))) > skswitch
                        switchpoint=[switchpoint, iframe];
                        switchFROM = [switchFROM, TotalExp(iframe-1)];
                        mixed_duration=0;
                        mixed_durationALL=[ mixed_durationALL, mixed_duration];
                    else
                        switchpoint(end)=[];
                        switchFROM(end)=[];
                    end
                else %first switch  (length(switchpoint)=0)
                    switchpoint=[switchpoint, iframe];
                    switchFROM = [switchFROM, TotalExp(iframe-1)];
                    mixed_duration=0;
                    mixed_durationALL=[ mixed_durationALL, mixed_duration];
                end
            end
        end
        
    end
end

if length(switchpoint) ~=length(switchFROM)
    error('count off between switchpoint and switchFROM')
end

if TotalExp(end)==0 ; %ended in mixed, so don;t count in calculations
switchpoint=switchpoint(1:length(switchpoint)-1);
switchFROM=switchFROM(1:length(switchpoint));
end
else
    switchpoint=[];
switchtime=[];
switchFROM=[];


%%
for iframe = 2:length(Timing)-1 %switch point in frames
    
    if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
        %coming out of mixed dominance (which we skip), or a clean switch (rare)
        switchpointtmp = iframe;
        %clean switch
        if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
            if length(switchpoint)>0
                if(switchpointtmp-(switchpoint(end))) > skswitch
                    switchpoint=[switchpoint, iframe];
                    switchFROM = [switchFROM, TotalExp(iframe-1)];
                    
                    
                else
                    switchpoint(end)=[];
                    switchFROM(end)=[];
                end
            else %first switch  (length(switchpoint)=0)
                switchpoint=[switchpoint, iframe];
                switchFROM = [switchFROM, TotalExp(iframe-1)];
                
                
            end
        end
        
        
    end
end

if length(switchpoint) ~=length(switchFROM)
    error('count off between switchpoint and switchFROM')
end
end
    %
    % sanity check of switch data(zero's removed)
    %set a decent size figure
    
    set(0, 'DefaultFigurePosition', [0 0 800 600]);
    set(gcf, 'visible', 'off');
    clf
    
    % subplot(2,2,1:2)
    plot(Timing, TotalExp, 'Color', 'k');
    ylim([-2 2]);
    xlim([0 length(Trials)/scrRate])
    
    %
    %% Calculate L/Right dominance
    Left_tot = abs(sum(TotalExp(TotalExp==-1)));
    Right_tot= sum(TotalExp(TotalExp==1));
    
    L_pct=100*(Left_tot/length(TotalExp));
    R_pct=100*(Right_tot/length(TotalExp));
    
    %mean percept dur
    m_dur = mean(diff(switchpoint))/scrRate;
    %
    L_pct=sprintf('%.2f', L_pct);
    R_pct=sprintf('%.2f', R_pct);
    M_dur=(sprintf('%.2f',m_dur)); %plotted in final image.
    %
    set(gca, 'yTick', [ -1 1], 'yTickLabel',...
        {[num2str(Lspeed) ', ' num2str(Leftc)];...
        [num2str(Rspeed) ', ' num2str(Rightc)]},...
        'Fontsize', fontsize);
    
    title([ 'Buttonpress Activity during Calibration' num2str(itrial)  ]);
    xlabel('Seconds');
    %
    % check switchpoints correlate
    hold on
    
    text(150, -1.5, ['Total switches = ' num2str(length(switchpoint))], 'Fontsize', fontsize)
    
    F = getframe(gcf);
    [X, Map] = frame2im(F);
    % Open Screen
    % screenPREPs
    %
    figtoshow=Screen('MakeTexture', params.windowPtr, X);
    Screen('TextSize', params.windowPtr,60);
    %
    for drawLR=0:1
        
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
        imCenter = params.windowRect/2;
        
        
        
        % Drawing the texture
        Screen('DrawTexture',params.windowPtr, figtoshow)
        
        DrawFormattedText(params.windowPtr, [Leftc '% ' L_pct '\n' Rightc '% ' R_pct '\n mean duration (s): ' M_dur], 'center',...
            [15],[],[],[],[],[],[]);
        
    end
    Screen('Flip', params.windowPtr);
    
    %%
    KbWait()
    pause(2);
    
    switch Color
        case 'R'
            RedDominance = L_pct;
            GreenDominance= R_pct;
        case 'G'
            RedDominance = R_pct;
            GreenDominance= L_pct;
    end
    
    
    sca
    ListenChar(0);
    GreenChange=upper(input(['Green % Dominance was ' num2str(GreenDominance) ', change? Y/N :'], 's'));
    if strcmp(GreenChange, 'Y')
        disp(['Green contrast tracker: ' num2str(Gtracker) ])
        disp(['Green prev contrast tracker: ' num2str(GreenMulti) ])
        disp(num2str([1:10]))
        disp(MultiScale)
        Gtracker= input('New contrast tracker 1:10  :');
        GreenMulti=MultiScale(Gtracker);
    end
    
    RedChange=upper(input(['Red % Dominance was ' num2str(RedDominance) ', change? Y/N :'], 's'));
    if strcmp(RedChange, 'Y')
      disp(['Red contrast tracker: ' num2str(Rtracker) ])
        disp(['Red prev contrast tracker: ' num2str(RedMulti) ])
        disp(num2str([1:10]))  
        disp(MultiScale)
        Rtracker= input('New contrast tracker 1:10  :');
        RedMulti=MultiScale(Rtracker);
    end
    
    
    %before moving on/repeating, make sure we save the 'new' multi values
    %per condition
    
    switch itypetotest
        case 1
            
            params.downContrGreen_condLG=GreenMulti ;
            
            params.downContrRed_condLG= RedMulti;
            
        case 2
            
            params.downContrGreen_condLR= GreenMulti;
            
            params.downContrRed_condLR= RedMulti;
            
        case 3
            
            params.downContrGreen_condHG= GreenMulti ;
            params.downContrRed_condHG = RedMulti;
            
        case 4
            
            params.downContrGreen_condHR= GreenMulti;
            
            params.downContrRed_condHR= RedMulti;
            
    end
    
    if strcmp(GreenChange, 'N') && strcmp(RedChange, 'N')
        moveon=num2str(upper(input('Move onto next Calibration condition? Y/N :' ,'s')));
        
        if strcmp(moveon,'Y')
            
            itypetotest=itypetotest+1; %onto next condition for eyes
        else %repeat same trial with new params.
        end
    end
    ListenChar( 2 ); 
end
screenPREPs
end