savedatadir='C:\Users\EEGStim\Desktop\XM_Projects\DATA_newhope';
cd(savedatadir)
useSherrbar=1; %plot single trace of trace with error bars?
usesmooth=1;
scrRate=60;


for xmod=1:3
    figure();
   
    clf
    switch xmod
        case 1
            xmarker='AnT';
        case 2
            xmarker = 'AUD';
        case 3
            xmarker = 'TAC';
    end
    for iAttend=1:2
         plcounter=1;
    pl=[];
        switch iAttend
            case 1
                AcrossallPPANTs = AttendTracking;
                attendcond='Attending';
                
            case 2
                AcrossallPPANTs=nonAttendTracking;
                attendcond= 'non-Attending';
                
        end
        nppants=size(AcrossallPPANTs,1);
        subplot(1,2,iAttend)
        for ihz = 1:2
            switch ihz
                case 1
                    colorin = 'b'; %low hz
                case 2
                    colorin = 'r'; %low hz
            end
            for iph=1:2
                switch iph
                    case 1
                        marker = '-';
                    case 2
                        marker=':';
                end
                
                tmp1=squeeze(AcrossallPPANTs(:,xmod,iph,ihz,:));
                plotme=squeeze(mean(tmp1,1)); %take mean of both in phase and out of phase.
                stErr = std(tmp1)/sqrt(size(tmp1,1));
                if usesmooth==1
                    plotme=smooth(plotme,15);
                    stErr=smooth(stErr,15);
                end
                hold on
                
                timing = [1:length(tmp)]/scrRate;
                if useSherrbar==1
                    p=shadedErrorBar(timing, plotme, stErr, [marker, colorin] ,1);
                pl(plcounter).mainLine=p.mainLine;
                else
                    pl(plcounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                end
                
                hold on
                plcounter=plcounter+1;
            end
            
        end
        ylim([.3 1])
        xlim([0 timing(end)])
        title([attendcond ' ' num2str(xmarker) ' In and Out of phase'],'fontsize', 10)
        xlabel('Time (secs)', 'fontsize', 15)
        ylabel('Prob')
        
        plot(xlim, [0.5 0.5], ['k' '-'])
        
         if useSherrbar==0
            legend([pl(1), pl(2), pl(3), pl(4)], {'Low Hz In phase' , 'Low Hz Out of phase', 'High Hz In phase', 'High Hz Out of phase'})
         else
             legend([pl(1).mainLine, pl(2).mainLine, pl(3).mainLine, pl(4).mainLine], {'Low Hz In phase' , 'Low Hz Out of phase', 'High Hz In phase', 'High Hz Out of phase'})
         end
    end
        
       
        shg
        cd(savedatadir)
        cd('figs')
        if usesmooth==1
            print('-dpng', ['Across ' num2str(nppants) ' ppants, ' xmarker ' Tracking, Smoothed'])
        else
            print('-dpng', ['Across ' num2str(nppants) ' ppants, ' xmarker ' Tracking'])
        end
    end
