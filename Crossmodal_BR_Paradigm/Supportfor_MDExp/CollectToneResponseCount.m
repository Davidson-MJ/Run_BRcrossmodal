%             CollectToneResponseCount
switch Orien
    case 'V'
        listento = 'Low frequency';
    case 'H'
        listento='High frequency';
end
% Select left-eye image buffer for drawing:
Screen('SelectStereoDrawBuffer', windowPtr, 0);

%draw oval for alignment
 imCenter = windowRect/2;
 %Draw the frame
    Screen('FrameRect', windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);
    
   
% Drawing instructions for the user

  DrawFormattedText(windowPtr, ['How many times did the speed of auditory/tactile stimulation match your current percept?'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
    [0 0 windowRect(3) windowRect(4)]);
% Select right-eye image buffer for drawing:
Screen('SelectStereoDrawBuffer', windowPtr, 1);

Screen('FrameRect', windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);

  DrawFormattedText(windowPtr, ['How many times did the speed of auditory/tactile stimulation match your current percept?'], 'center', 'center', [255 255 255],50,[],[],[],[],...
    [0 0 windowRect(3) windowRect(4)]);

Screen('Flip', windowPtr);
    WaitSecs(0.2)

    KbWait