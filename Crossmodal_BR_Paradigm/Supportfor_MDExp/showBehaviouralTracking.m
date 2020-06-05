scrRate=60;
window = (7 * scrRate); %6 seconds at screen Rate
dbstop if error
ParticipantBehaviouralTracking=nan(3,2,2, 24, window+1);
%[xmod,phase, hz, trials, samps] = size(ParticipantBehaviouralTracking)
realblockcount=1;
usesmooth=1; %for smoothing output
useSherrbar=1; %plot single trace of trace with error bars?
%%

cd(params.savedatadir)
cd(params.namedir)
%%
for i =22%1:24
    
    filet = dir([pwd filesep 'Block' num2str(i) 'Exp*' '*.mat']);
    
    try filename = filet.name;
        load(num2str(filename), 'blockout')
        %%
        rivTrackingData=blockout.rivTrackingData;
        TotalExp = rivTrackingData(:,2)  - rivTrackingData(:,1);
        TotalExp=TotalExp';
        Data= [];
        Chunks=blockout.Chunks;
        
        for ich=1:length(Chunks)/2
            onsett=Chunks(2*ich-1);
            try tmp=TotalExp(1,onsett:onsett+window);
            catch
                tmp=TotalExp(1,onsett:length(TotalExp));
                epochfull= length(Data);
                plusme = epochfull - length(tmp);
                tmp2= zeros(1,plusme);
                tmp = [tmp,tmp2];
            end
            
            Data(ich,:) =tmp;
        end
        %%
        %convert to congruent
        try Speed = blockout.Speed;
        catch
            if length(filename)==20;
                tmp= str2num(filename(16));
            else
                tmp= str2num(filename(17));
            end
            
            switch tmp
                case {1, 3}
                    Speed='L';
                case {2, 4}
                    Speed='H';
            end
        end
        %%
        Tracking_by_type=[];
        
        congrData=Data;
        for itrial = 15%1:length(blockout.Order)
            trialwas= blockout.Order(itrial);
            trialtrace=congrData(itrial,:);
            switch trialwas
                case 1
                    congrData(itrial,:)=0;
                case {82, 83, 84}; %low Hz trial
                    if strcmp(Speed, 'L')
                        trialtrace(trialtrace~=-1)=0; %left eye low hz congruent
                        congrData(itrial,:)=abs(trialtrace);
                    else %left eye was high hz
                        trialtrace(trialtrace~=1)=0; %Right eye low hz congruent
                        congrData(itrial,:)=abs(trialtrace);
                    end
                    
                    %store for later.
                    try Tracking_by_type.LowHz = [Tracking_by_type.LowHz; abs(trialtrace)];
                    catch
                        Tracking_by_type.LowHz = abs(trialtrace);
                    end
                case {92, 93, 94}; %high Hz trial
                    if strcmp(Speed, 'L')
                        trialtrace(trialtrace~=1)=0; %left eye high hz congruent
                        congrData(itrial,:)=abs(trialtrace);
                    else %left eye was high hz
                        trialtrace(trialtrace~=-1)=0; %Right eye high hz congruent
                        congrData(itrial,:)=abs(trialtrace);
                    end
                    try Tracking_by_type.HighHz = [Tracking_by_type.HighHz; abs(trialtrace)];
                    catch
                        Tracking_by_type.HighHz = abs(trialtrace);
                    end
            end
        end
        blockout.trackingData= Data;
        blockout.congrtrackingData=congrData;
        blockout.window_framespostoffset=window;
        blockout.Tracking_by_type=Tracking_by_type;
        save(filename, 'blockout', '-append')
    catch
        disp(['Skipped block ' num2str(i)])
    end
end
%
for iblocktype=1:6
    trialcount=1;
    outdata=[];
    switch iblocktype
        case {1, 2}
            needxmod= 'Auditory and Tactile';
            xmod=1;
        case {3, 4}
            needxmod = 'Auditory';
            xmod=2;
        case {5, 6}
            needxmod = 'Tactile';
            xmod=3;
    end
    if mod(iblocktype,2)~=0 %odd numbers in phase
        needphase='In';
        phs=1;
        
    else
        needphase='Out';
        phs=2;
    end
    %cycle through for block types
    for i=1:24
        filet = dir([pwd filesep 'Block' num2str(i) 'Exp*' '*.mat']);
        try load(filet.name, 'blockout')
            if strcmp(blockout.Casetype, needxmod)==1
                if strcmp(blockout.Phasetype, needphase)==1
                    % then store
                    trialsin=[1:6] + 6*(trialcount-1);
                    ParticipantBehaviouralTracking(xmod, phs, 1, trialsin(1):trialsin(6),:)=blockout.Tracking_by_type.LowHz;
                    ParticipantBehaviouralTracking(xmod, phs, 2, trialsin(1):trialsin(6),:)=blockout.Tracking_by_type.HighHz;
                    trialcount=trialcount+1;
                    
                end
            end
            clear blockout
        catch
            disp(['Skipped block ' num2str(i)])
        end
    end
end
save('PpanttrackingbyType(xmod,phase,hz,trials,samps)', 'ParticipantBehaviouralTracking');
%% Print them all.
clf
%%
% separate in phase and out of phase
for iphase=1:2
    % for iplot=1:2
    %
    subplot(2,1,iphase)
    %in phase first
    %
    switch iphase
        case 1
            titlep = 'In phase ';
        case 2
            titlep='Out of phase ';
    end
    
    
    plcounter=1;
    %
    for xmod=1:3
        switch xmod
            case 1
                marker='-.';
            case 2
                marker = '-';
            case 3
                marker = ':';
        end
        for ihz = 1:2
            switch ihz
                case 1
                    colorin = 'b'; %low hz
                case 2
                    colorin = 'r'; %low hz
            end
            
            tmp=squeeze(ParticipantBehaviouralTracking(xmod,iphase,ihz,:,:));
            stErr = std(tmp)/sqrt(size(tmp,1));
            plotme= mean(tmp,1);
            if usesmooth==1
                plotme = smooth(plotme,15);
                stErr=smooth(stErr,15);
            end
            timing = [1:length(tmp)]/scrRate;
            if useSherrbar==1
                p=shadedErrorBar(timing, plotme, stErr, [colorin marker],1);
                pl(plcounter).mainLine=p.mainLine;
                
            else
                pl(plcounter)=plot(timing, plotme, [colorin marker], 'linewidth', 3);
            end
            hold on
            plcounter=plcounter+1;
            ylim([.1 .9])
            xlim([0 timing(end)])
            
        end
        title(titlep,'fontsize', 15)
        xlabel('Time (secs)', 'fontsize', 15)
        ylabel('Prob')
        plot(xlim, [0.5 0.5], ['k' '-'])
        
        
        
    end
    if useSherrbar==1
        legend([pl(1).mainLine, pl(2).mainLine, pl(3).mainLine, pl(4).mainLine, pl(5).mainLine, pl(6).mainLine], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'})
    else
        legend([pl(1), pl(2), pl(3), pl(4), pl(5), pl(6)], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'})
    end
end
shg
%%
if usesmooth==1
    print('-dpng', 'In Phase vs Out of phase Tracking, Smoothed')
else
    print('-dpng', 'In Phase vs Out of phase Tracking')
end
%%
%Now print combined In phase and out of phase.

plcounter=1;
figure()
for xmod=1:3
    switch xmod
        case 1
            marker='-.';
        case 2
            marker = '-';
        case 3
            marker = ':';
    end
    for ihz = 1:2
        switch ihz
            case 1
                colorin = 'b'; %low hz
            case 2
                colorin = 'r'; %low hz
        end
        
        tmp1=squeeze(ParticipantBehaviouralTracking(xmod,:,ihz,:,:));
        tmp=squeeze(mean(tmp1,1)); %take mean of both in phase and out of phase.
        stErr = std(tmp)/sqrt(size(tmp,1));
        plotme= mean(tmp,1);
        if usesmooth==1
            plotme=smooth(plotme,15);
            stErr=smooth(stErr,15);
        end
        
        timing = [1:length(tmp)]/scrRate;
        if useSherrbar==1
            p=shadedErrorBar(timing, plotme, stErr, [colorin marker],1);
            pl(plcounter).mainLine = p.mainLine;
        else
            pl(plcounter)=plot(timing, plotme, [colorin marker], 'linewidth', 3);
        end
        hold on
        plcounter=plcounter+1;
        ylim([.1 .9])
        xlim([0 timing(end)])
        
    end
    title('Combined In and Out of phase','fontsize', 15)
    xlabel('Time (secs)', 'fontsize', 15)
    ylabel('Prob')
    
    plot(xlim, [0.5 0.5], ['k' '-'])
    
    
    
end
if useSherrbar==0
    legend([pl(1), pl(2), pl(3), pl(4), pl(5), pl(6)], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'})
else
    legend([pl(1).mainLine, pl(2).mainLine, pl(3).mainLine, pl(4).mainLine, pl(5).mainLine, pl(6).mainLine], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'})
end
shg
if usesmooth==1
    print('-dpng', 'Combined Tracking, Smoothed')
else
    print('-dpng', 'Combined Tracking')
end