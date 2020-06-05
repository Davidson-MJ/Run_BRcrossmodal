function DisplayBhlTracking(params)
cd(params.namedir);


stimoffsetwindow = 180;    
load('Seed_Data.mat', 'ExpOrder');

    for iXMtype = 1:6
        
        LowHzTrace=[];
        HighHzTrace=[];
        
    %now to concatenate by type, stim, low-high, etc
    allblocks = dir([pwd filesep 'Block*' '*.mat']);
    
    
    for iblock = 1:length(allblocks)
        inblock =num2str( allblocks(iblock).name);
        load(num2str(inblock))
        
        stimType = params.CaseType;
        realblock = checkme.block;
        
        if strcmp(stimType, needtype) %check blocks are same type
        
        Trialdur = TrialTime*scrRate;
        %for each block,
        
        Chunkstmp=[];
        
        % Checks where in the entire 2 minutes is the stimulus period
        for i = 1:length(Trials)-1
            if Trials(i) == 0 && Trials(i+1) >= 1   % Detects start of chunk
                Chunkstmp = [Chunkstmp i+1];
                %         Chunks = [Chunks i];
            elseif Trials(i) >= 1 && Trials(i+1) == 0 % Detects end of chunk
                %         Chunks = [Chunks i+1];
                Chunkstmp = [Chunkstmp i];
            end
        end
        
       
        %create a secondary 'chunks' file, that includes a
        %stimoffsetwindow to see button press activity post stimulus
        %offset.
        Chunkstart=[];
        for i=1:length(Chunkstmp)
            if mod(i,2)>0 %odd numbers are 'start' of chunks
                Chunkstart= [Chunkstart Chunkstmp(i)];
            end
        end
        
        ChunkPLUSwindow = [];
        
        for i = 1:length(Chunkstart)
            try ChunkPLUSwindow(i, :) = procTotalExp(Chunkstart(i):Chunkstart(i) + Trialdur+ stimoffsetwindow)';
            catch
%                ChunkPLUSwindow(i, :) = TotalExp(Chunkstart(i):Chunkstart(i) + Trialdur+ stimoffsetwindow)';
            end
        end
        
        processedblock.ChunkedDatawOffset = ChunkPLUSwindow;
        
        
        %now chunk according to each switch type that occurs, noting
        %both the perceptual tracking (trace) and timestamps.
        
        chunkedTracedata = processedblock.ChunkedDatawOffset;
    %%    
        %concatenating by datatype, then average to plot a trace.
        for iStim = 1:size(chunkedTracedata,1)
            crossstim = Order(iStim);
            tracedata = chunkedTracedata(iStim,:);
            
            timeof = rivTrackingData(Chunkstart(iStim),3);
            switch crossstim
                case 2; %lowinphase,
                    LOWINphasetrace= [LOWINphasetrace; tracedata];
                    LOWINphasetime= [LOWINphasetime; timeof];
                    
                case 3; %highinphase,
                    HIGHINphasetrace= [HIGHINphasetrace; tracedata];
                    HIGHINphasetime = [HIGHINphasetime; timeof];
                    
                case 4 %low outphase
                    LOWOUTphasetrace =[LOWOUTphasetrace; tracedata];
                    LOWOUTphasetime = [LOWOUTphasetime; timeof];
                    
                    
                    
                case 5 %high outphase
                    HIGHOUTphasetrace =[HIGHOUTphasetrace; tracedata];
                    HIGHOUTphasetime = [HIGHOUTphasetime; timeof];
            end
            
            
            
        end
        
        processedblock.traceoffsetwindow = stimoffsetwindow;
        
        %resave with new chunkeddataplusoffset
        savename = num2str(inblock);
        save(savename, 'chunkedTracedata', '-append')
        end
    end
      %for each block, store based on trialtype
       savefilename = ['ppanttrace_' num2str(needtype) '_bystimtype'];
            
            
               save(savefilename, 'LOWINphasetrace', 'LOWINphasetime',...
                   'HIGHINphasetime', 'HIGHINphasetrace',...
                   'LOWOUTphasetime', 'LOWOUTphasetrace',...
                   'HIGHOUTphasetime', 'HIGHOUTphasetrace');
    end


end