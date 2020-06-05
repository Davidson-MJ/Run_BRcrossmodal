% RunEYEandTONEcalibration;   
%This script runs the visual calibration of contrast values:
% Grating_Calibration, as well as equate the output intensity of low and
% high frequency tones, to be phenomenlogically equivalent.

%Note that both calibration processes require exoperimenter input, into the command
%window.

%Q: mjd070 at gmail dot com

if CalibrateON==1
        
        %% Individual visual flicker, contrast calibration
        
        % if first day of experimentation, calibrate visual stimuli.
        
        if strcmp(params.Day1_2,'1')
            
            params= Grating_Calibration(params); %use same visual input for day 1 and 2.
        
        else % if second day of testing, load previous days' calibration.
           
            loadprevBRcalibration;
        end
               
        %% Calibrate tones
        cd(params.savedatadir)
        
        %saves a separate multiplier for low / high and aud/tac, to be sensory matched.
        %if running only auditory stimuli (no tactile), this can bes
        %skipped.
        
%         Tone_Calibration 

        %%
        cd(params.namedir)
        save('Seed_Data', 'params', '-append')
else
    %basic parameters (e.g. for debugging)
        
        if params.stereoMode==4
        params.downContrRed_condLG = 1; %multiply outgoing colour and audio by what contrast mod? (1 = full contrast colour, need GG correction?).
        params.downContrGreen_condLG = .49; %
        params.downContrRed_condHG = .64; %%high green conditon, so differnece not as strong.
        params.downContrGreen_condHG = .64; %
        params.downContrRed_condLR=.64; %high green conditon, so differnece not as strong.
        params.downContrGreen_condLR=.64;
        params.downContrRed_condHR=1;
        params.downContrGreen_condHR=.49;
                
        else
            % for anaglyph presentation, contrast is set in screenPREPS.            
        params.downContrRed_condLG = 1; %multiply outgoing colour and audio by what contrast mod? (1 = full contrast colour, need GG correction?).
        params.downContrGreen_condLG = 1; %
        params.downContrRed_condHG = 1; %%high green conditon, so differnece not as strong.
        params.downContrGreen_condHG = 1; %
        params.downContrRed_condLR=1; %high green conditon, so differnece not as strong.
        params.downContrGreen_condLR=1;
        params.downContrRed_condHR=1;
        params.downContrGreen_condHR=1;
        end
        
        %these are shared:
        params.LowHzAmpMulti_AUD = 1; %start at normal amplitude, can be adjusted in Tone Calibration
        params.LowHzAmpMulti_TAC = 1; %
        params.HighHzAmpMulti_AUD = 1; %
        params.HighHzAmpMulti_TAC = 1; %
    end