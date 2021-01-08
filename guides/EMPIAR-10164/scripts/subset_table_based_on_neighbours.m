% read table
table = dread('result_10Apx_nodup.tbl');

% calculate neighbours around peak at 7.5px
peak = 7.5;
delta = 1;
neighbours = dtneighbours_in_range(table, peak-delta, peak+delta);

% see which particles have more than 3 neighbours, save as indices to
% access table
idx = neighbours > 3;
subset = table(idx, :);

% write out table
dwrite(subset, 'result_10Apx_nodup_neighbourcleaning.tbl');
compare_two_tables(table, subset);
