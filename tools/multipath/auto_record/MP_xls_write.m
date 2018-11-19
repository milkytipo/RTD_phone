function MP_xls_write(xlsName, multiPara, sheetName, multipathNum, xlsLine, sys, prn)

% column{1} = {strcat('B',xlsLine),strcat('C',xlsLine),strcat('D',xlsLine),strcat('E',xlsLine),strcat('F',xlsLine),strcat('G',xlsLine),strcat('H',xlsLine),strcat('I',xlsLine),strcat('J',xlsLine)};
% column{2} = {strcat('N',xlsLine),strcat('O',xlsLine),strcat('P',xlsLine),strcat('Q',xlsLine),strcat('R',xlsLine),strcat('S',xlsLine),strcat('T',xlsLine),strcat('U',xlsLine),strcat('V',xlsLine)};
% column{3} = {strcat('Z',xlsLine),strcat('AA',xlsLine),strcat('AB',xlsLine),strcat('AC',xlsLine),strcat('AD',xlsLine),strcat('AE',xlsLine),strcat('AF',xlsLine),strcat('AG',xlsLine),strcat('AH',xlsLine)};


xlswrite(xlsName, {strcat(sys,'_',num2str(prn))}, sheetName,strcat('A',xlsLine));
for i = 1 : multipathNum
    if ~isempty(multiPara(i).timeLen)
        xlsLine_end = num2str(str2double(xlsLine)+length(multiPara(i).timeLen)-1);
        column{1} = {strcat('B',xlsLine, ':', 'K', xlsLine_end)};
        column{2} = {strcat('N',xlsLine, ':', 'W', xlsLine_end)};
        column{3} = {strcat('Z',xlsLine, ':', 'AI', xlsLine_end)};
        
        matrixWrite = [multiPara(i).pathIndex_Auto, multiPara(i).delay_sect, multiPara(i).atten_sect,...
            multiPara(i).dopp_sect, multiPara(i).timeLen, multiPara(i).el_sect, ...
            ones(length(multiPara(i).timeLen), 1), multiPara(i).lifeTime_Flag, multiPara(i).multiCNR_sect];
        xlswrite(xlsName, matrixWrite, sheetName, column{1,i}{1,1});
    end
end