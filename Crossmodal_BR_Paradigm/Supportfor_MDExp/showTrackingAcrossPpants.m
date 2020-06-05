%plot across participant button press traces. 
scrRate=60;
window = (7 * scrRate); %6 seconds at screen Rate
dbstop if error
realblockcount=1;
usesmooth=1; %for smoothing output
useSherrbar=1; %plot single trace of trace with error bars?
%
savedatadir='C:\Users\EEGStim\Desktop\XM_Projects\DATA_newhope';
cd(savedatadir)
ppantdirs = dir;
%
icount=1;
Attendlist=[];
nAttendlist=[];
% remove non ppant directories.
for i=1:length(ppantdirs)    
    %
     tmp=length(ppantdirs(icount).name);
        if tmp<10 %remove shadow folders
        ppantdirs(icount)=[];
        
        else
            attendcase = num2str(ppantdirs(icount).name(end-1:end));
            if strcmp(attendcase, 'On')
                
                Attendlist = [Attendlist; {ppantdirs(icount).name}];
            else
            nAttendlist = [nAttendlist; {ppantdirs(icount).name}];
            end
            icount=icount+1;
        end
    
        
    
    
end
nppants=length(ppantdirs);
%%
%non attend first
for iAttend=1:2
    switch iAttend
        case 1
            nppants= length(Attendlist);
            attendcond='Attending';
            ppantdirs=Attendlist;
        case 2
            nppants=length(nAttendlist);
            attendcond='Non-Attending';
            ppantdirs=nAttendlist;
    end
            
AcrossallPPANTs = nan(nppants, 3,2,2, 421); % ppants, xmod, phase, hz, samps
for ippant = 1:nppants
    
    cd(savedatadir)
    folppant=(ppantdirs{ippant});
    cd(num2str(folppant))
    
                disp([ 'loading directory ' ppantdirs{ippant}])
                load('PpanttrackingbyType(xmod,phase,hz,trials,samps).mat')
                %take mean across trials.
                ppantmean = squeeze(mean(ParticipantBehaviouralTracking,4));
                if isnan(squeeze(mean(mean(mean(mean(ppantmean))))))
                    error('echeck for nan')
                end
                AcrossallPPANTs(ippant,:,:,:,:)=ppantmean;
                
            
            
end 
    
%% Print them all.
clf
pl=[];

% separate in phase and out of phase
for iphase=1:2
% for iplot=1:2
%
subplot(1,2,iphase)
%in phase first
%
switch iphase
    case 1
        titlep = 'In phase ';
    case 2
        titlep= 'Out of phase ';
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
                
        tmp=squeeze(AcrossallPPANTs(:,xmod,iphase,ihz,:));
        stErr = std(tmp)/sqrt(size(tmp,1));
        plotme= mean(tmp,1);
        if usesmooth==1
            plotme = smooth(plotme,15);
            stErr=smooth(stErr,15);
        end
        timing = [1:length(tmp)]/scrRate;
        if useSherrbar==1
            plt=shadedErrorBar(timing, plotme, stErr, [colorin marker],1);
            if plcounter==1
            pl=plt;
            else
                pl(plcounter)=plt;
            end
        else
            pl(plcounter)=plot(timing, plotme, [colorin marker], 'linewidth', 3);
        end
hold on
        plcounter=plcounter+1;
        ylim([.3 1])
        xlim([0 timing(end)])
        
    end
    title([attendcond ' ' titlep],'fontsize', 10)
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
cd(savedatadir)
cd('figs')
if usesmooth==1
print('-dpng', ['Across ' num2str(nppants) ' ppants, ' attendcond ' In Phase vs Out of phase Tracking, Smoothed'])
else
    print('-dpng', ['Across ' num2str(nppants) ' ppants ' attendcond ' In Phase vs Out of phase Tracking'])
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
                
        tmp1=squeeze(AcrossallPPANTs(:,xmod,:,ihz,:));
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
    title([attendcond ' Combined In and Out of phase'],'fontsize', 15)
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
cd(savedatadir)
cd('figs')
if usesmooth==1
print('-dpng', ['Across ' num2str(nppants) ' ppants, ' attendcond ' Combined Tracking, Smoothed'])
else
    print('-dpng', ['Across ' num2str(nppants) ' ppants ' attendcond ' Combined Tracking'])
end

cd(savedatadir)
cd('figs')
switch iAttend
    case 1
        AttendTracking= AcrossallPPANTs;
        save('TrackingAcrossAll(nppant,xmod,iph,ihz,samps)', 'AttendTracking')
    case 2
        nonAttendTracking=AcrossallPPANTs;
save('TrackingAcrossAll(nppant,xmod,iph,ihz,samps)', 'nonAttendTracking', '-append')
end

end