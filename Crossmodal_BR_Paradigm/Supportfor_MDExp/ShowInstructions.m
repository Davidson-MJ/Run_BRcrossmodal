% ShowInstructions


switch Xmodaltype
    case {1 2}
        blockis='Auditory and Tactile';
    case {3 4}
        blockis='Auditory';
    case {5 6}
        blockis='Tactile';
    case 0
        blockis='Visual only';
end

%Determine the type of tone to 'count' in Attend conditions.
switch Orien
    case 'V'
        listento = 'Low frequency';
    case 'H'
        listento='High frequency';
end

Screen('TextSize', params.windowPtr, 20);

if iblock==3


for iDrawLR = 0:1
    
    
%>>>>>>>>>>> LEFT EYE
% Select left-eye image buffer for drawing:
Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);

%find center
imCenter = params.windowRect/2;

%Draw the frame in center.
Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);


% Drawing instructions for the user
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'End of Practice Blocks' '\n' 'Press any key when ready'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
end%>>>>>>>>>>>> SHOW INSTRUCTIONS

Screen('Flip', params.windowPtr);
pause(0.2);
KbWait; %wait till ready.
end

for iDrawLR = 0:1
    
    
%>>>>>>>>>>> LEFT EYE
% Select left-eye image buffer for drawing:
if params.stereoMode~=6
Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
else
Screen('SelectStereoDrawBuffer', params.windowPtr);
end
%find center
imCenter = params.windowRect/2;

%Draw the frame in center.
Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);


% Drawing instructions for the user
if params.AttendEXP==0 % passive conditions, no listening or counting.
    
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'Constantly report your dominant' '\n' 'visual percept using the arrow keys- ' '\n' '\n' 'Green = "Left"'  '\n' '\n' 'Red = "Right"'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
else
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'Constantly report your dominant' '\n' 'visual percept using the arrow keys- ' '\n' '\n' 'Green = "Left"'  '\n' 'Red = "Right"' ...
        '\n' '\n' 'AND' '\n' '\n' 'At the end of each ' num2str(blockis) ' stimuli, count(+1) whenever the speed matches your percept'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
end
end%>>>>>>>>>>>> SHOW INSTRUCTIONS

Screen('Flip', params.windowPtr);
pause(0.2);
KbWait; %wait till ready.
