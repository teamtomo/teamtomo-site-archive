function n_neighbours = dtneighbours_in_range(table, min_dist, max_dist)
    % read table
    if ischar(table)
        table = dread(table);
    end
    % prep output
    n_neighbours = zeros(size(table, 1), 1);
    % get unique tomogram index values
    tomogram_idxs = unique(table(:,20));
    for i = 1:size(tomogram_idxs)
        % get table per volume
        tomo_idx = tomogram_idxs(i);
        table_idx = table(:, 20) == tomo_idx;
        current_table = table(table_idx, :);
        % get xyz coords
        xyz = current_table(:, 4:6) + current_table(:, 24:26);
        % get neighbours in range
        distance_matrix_ = squareform(pdist(xyz));
        neighbours_ = distance_matrix_ >= min_dist & distance_matrix_ <= max_dist;
        n_neighbours_ = sum(neighbours_, 1);
        % insert in output
        n_neighbours(table_idx) = n_neighbours_;
    end
end
