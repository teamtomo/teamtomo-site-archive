function m = compare_two_tables(tblCell1,tblCell2);

if ~iscell(tblCell1)
    tblCell1 = dtsplit(tblCell1, 'column', 20, 'v', 0);
end

if ~iscell(tblCell2)
    tblCell2 = dtsplit(tblCell2, 'column', 20, 'v', 0);
end
    
for i = 1:length(tblCell1)
    u{i}{1} = tblCell1{i};
    u{i}{2} = tblCell2{i};
    u{i}{3} = i;
end
 

m = mbvid.guis.montages.cells.Inline();
m.setVideo(u); % 
m.rows = 1;
m.columns = 1;
m.depictorOnPanelFcn = @(x,hPanel) localPlot(x,hPanel);
m.show();
 

 function localPlot(x,hPanel);
  if isempty(x)
      disp('no table for this tomogram'); 
    return
  end
 ti1 = x{1};
 if isempty(ti1)
    disp('no table for this tomogram'); 
    return
 end
 

 % rescues the number
 number = x{3};
 

 mbgraph.delete(hPanel,'Children');
 haxis1 = subplot(1,2,1,'Parent',hPanel);
 d = dpktbl.plots.sketch(ti1,'haxis',haxis1);
 title(haxis1,sprintf('tomogram number %d (crop)',number));
 

 d.zlength.value = 15;
 d.xlength.value = 2;
 

 %
 ti2 = x{2};
  haxis2 = subplot(1,2,2,'Parent',hPanel);
 d2 = dpktbl.plots.sketch(ti2,'haxis',haxis2);
 title(haxis2,sprintf('tomogram number %d (aligned)',number));
 

 d2.zlength.value = d.zlength.value;
 d2.xlength.value = d.xlength.value;
 

 linkaxes([haxis1,haxis2]);
