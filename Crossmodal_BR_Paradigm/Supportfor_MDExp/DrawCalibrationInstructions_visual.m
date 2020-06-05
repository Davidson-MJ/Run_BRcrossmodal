
%>>>>>>>>>>>> Draw MAX contrast for pre-flicker instructions. 
%first draw the frame.
for iDrawLR = 0:1 % draw left and right eye.    
   
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
    
    %find center
    imCenter = params.windowRect/2;
    
    %Draw the frame in center.
    Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
    
    
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'Press any key to begin Grating Calibration' '\n' ] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
    
end

Screen('Flip', params.windowPtr);
KbWait;
pause(2);

%% DRAW INSTRUCTIONS

for iDrawLR = 0:1    
    % Select left/right eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
    
    %find center
    imCenter = params.windowRect/2;
    
    %Draw the frame in center.
    Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
    
    
    % Drawing instructions for the user
    
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'Constantly report your dominant' '\n' 'visual percept using the arrow keys- ' '\n' '\n' 'Green = "Left"'  '\n' '\n' 'Red = "Right"'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
end%>>>>>
Screen('Flip', params.windowPtr);
KbWait;
pause(2);
