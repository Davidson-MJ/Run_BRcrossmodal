%Load and run the parameters for each block.


Xmodaltype = params.ExpOrder(iblock,1); %
    
    %0= visual only practice
    %1= AnT Inphase
    %2= AnT Out
    %3= Aud In
    %4= Aud Out
    %5= Tactile Inphase
    %6= Tactile Out of phase
    
    Eyeconds = params.ExpOrder(iblock,2); %
    
    switch Eyeconds %for left eye. Parameters calibrated per ppant.
        case 1
            Speed = 'L';Colour = 'G';
            
            params.downContrGr_block = params.downContrGreen_condLG;
            params.downContrRed_block = params.downContrRed_condLG;
        case 2
            Speed = 'H';Colour = 'G';
            params.downContrGr_block = params.downContrGreen_condHG;
            params.downContrRed_block = params.downContrRed_condHG;
            
        case 3
            Speed = 'L';Colour = 'R';
            params.downContrGr_block = params.downContrGreen_condLR;
            params.downContrRed_block = params.downContrRed_condLR;
        case 4
            Speed = 'H';Colour = 'R';
            params.downContrGr_block = params.downContrGreen_condHR;
            params.downContrRed_block = params.downContrRed_condHR;
    end
    
    %randomize grating orientation.
    x=rand(1);
    if x>.5
        Orien = '-45';
    else
        Orien= '+45';
    end
    %%
    ShowInstructions %different instructions based on the AttendEXP ver
    
    realblock=iblock-2;
    if realblock<1
        realblock=0;
    end
    
    
    % perform stimulus  presentation, collect button press data.    
    [blockout] = run_flicker_newEXP(Orien, Colour, Speed, Xmodaltype, params, realblock);
    
    %% check user accuracy and present block outline on screen
    if iblock<3 && params.AttendEXP==1 %for Practice blocks, show trace.
        %
        TrainingAccuracy
        
        miniBlockTrace
        %%
        cd(params.savedatadir)
        cd(params.namedir)
        save('Seed_Data.mat', 'AttnperBlock', '-append')
    else
        %%
        cd(params.savedatadir)
        cd(params.namedir)
    end
    
    % Specifies the file name for rest of data save
    %%
    filename = ['Block' num2str(realblock) 'Exp' num2str(Xmodaltype)...
        '_Cond' num2str(Eyeconds)];
    % Saves all the data as a .mat file
    save(filename, 'blockout', 'params');
    
    % Deletes all buffers to free up space
    PsychPortAudio('DeleteBuffer');
    % Deletes textures
    Screen('Close');
    %%
    
    switch realblock
        case {6, 12, 18} %save at 4 points. (6 blocks each EEG recording)
            if params.EEG==1 % This is only needed if we are using the EEG
                % Tells the user to wait
                SavingTextShow(params.windowPtr, params.windowRect);
                
                % TIME TO SAVE YOUR DATA
                pause(2)
                KbWait()
            end
    end
    
    
    
    % Flip to Grey screen.
    try   Screen('Flip', params.windowPtr);
    catch
        screenPREPs
    end