% check number of neighbours in radial shells, 1 px thick shells

% read table
table = dread('result_10Apx_nodup.tbl');

% check average number of neighbours in shells
% initialise result vector
neighbours_in_shells = zeros(20, 1);
shell_starts = linspace(0, 19, 20);

% check number of neighbours in shell, count and append to result
for shell_start_idx = 1:size(shell_starts, 2)
    min_dist = shell_starts(1, shell_start_idx);
    max_dist = min_dist + 1;
    n_neighbours = dtneighbours_in_range(table, min_dist, max_dist);
    neighbours_in_shells(shell_start_idx) = mean(n_neighbours);
end

plot(shell_starts + 0.5, neighbours_in_shells)

% plot shows most particles have more neighbours at 5.5-8.5px distance
