% read table
table = dread('refined_table_ref_001_ite_0001.tbl');

% remove duplicates
threshold = 4;
nodup = dpktbl.exclusionPerVolume(table, threshold)

% write out table
dwrite(nodup, 'result_10Apx_nodup.tbl');
