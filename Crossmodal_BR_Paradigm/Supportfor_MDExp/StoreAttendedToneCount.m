% StoreAttendedToneCount
CountedTones=[];
cd(params.namedir)
for iblock = 1:24
    AttendCount = input(['How many counted for block ' num2str(iblock) '?']);
    CountedTones(iblock,1) = AttendCount;
    savename = dir([pwd filesep 'Block' num2str(iblock) 'Exp*']);
    savefile = savename(1).name;
    
    save(savefile, 'AttendCount', '-append')
end
save('CountedTones', 'CountedTones');
cd(basedir);
