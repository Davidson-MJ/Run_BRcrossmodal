% TrainingAccuracy
% ChunkPresentation(AttendCount,Speed,rivTrackingData, Chunks)

rivTrackingData=blockout.rivTrackingData;
Chunks=blockout.Chunks;
Order=blockout.Order;
TotalExp = rivTrackingData(:,2)- rivTrackingData(:,1); %-1 is left eye.
ChunkEndtimes=[];

for i = 1:length(Chunks)
    if mod(i,2)==0 %even numbers
        ChunkEndtimes = [ChunkEndtimes, Chunks(i)];
    end
end

buttonpressatChunkEND=[];
for i = 1:length(ChunkEndtimes)
    prepresstime = ChunkEndtimes(i) - 1; %1/scrRate frames in seconds
    prebutton = TotalExp(prepresstime,1);
    buttonpressatChunkEND = [buttonpressatChunkEND, prebutton];
end
%%
congruentpresentation = [];
chcounter=1;

for ich = 1:length(Order)
    
    stimpresent = Order(ich);
    buttontmp = buttonpressatChunkEND(ich);
    switch stimpresent
        case 1
            congruentpresentation(1,chcounter) = 0;%fail
        case {82 83 84} %low
            if strcmp(Speed, 'L') %-1 is left eye and low hz.
                if buttontmp ==-1
                    congruentpresentation(1,chcounter) = 1; %success
                else
                    congruentpresentation(1,chcounter) = 0;%fail
                end
            else %-1 is actually high hz
                if buttontmp ==1
                    congruentpresentation(1,chcounter) = 1;%success
                   
                else
                    congruentpresentation(1,chcounter) = 0;%fail
                end
            end
            
        case {92 93 94} %high hz
            if strcmp(Speed, 'H') %-1 is left eye and high hz.
                if buttontmp ==-1
                    congruentpresentation(1,chcounter) = 1; %success
                else
                    congruentpresentation(1,chcounter) = 0;%fail
                end
            else %-1 is actually low hz
                if buttontmp ==1
                   congruentpresentation(1,chcounter) = 1;%success
                else
                    congruentpresentation(1,chcounter) = 0;%fail
                end
            end
    end
    chcounter=chcounter+1;
end



try Screen('TextSize', params.windowPtr,20);
catch
    screenPREPs
    Screen('TextSize', params.windowPtr,20);
end
for drawLR=0:1
    
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
    imCenter = params.windowRect/2;
    
    
    
    
    %Draw Ask
    DrawFormattedText(params.windowPtr, ['How many tones did you count?'], 'center', 'center', [255 255 255],[],[],[],[],[]);
    
    
end
Screen('Flip', params.windowPtr);
%%
pause(3)
sca
ListenChar(0)
AttendCount= (input('How many tones did you count?'));
ListenChar(2)

ActualCongr = sum(congruentpresentation); %num opportunities

Diffcount = abs((AttendCount - ActualCongr)); %offset between 'seen' and actual
%%
BlockAttnAccuracy = abs(ActualCongr-Diffcount)/ActualCongr;
% save(blockIN, 'BlockAttnAccuracy', '-append')
%
AttnperBlock(iblock,1) =  ActualCongr;
AttnperBlock(iblock, 2) = AttendCount;
AttnperBlock(iblock,3) = Diffcount;
AttnperBlock(iblock, 4) = BlockAttnAccuracy;















