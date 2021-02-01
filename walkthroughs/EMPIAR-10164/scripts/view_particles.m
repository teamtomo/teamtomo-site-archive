function gui = view_particles(table)
    % read the table
    table = dread(table)
    % get unique keys of each volume
    keys = unique(table(:, 20));

    % open the viewer gui
    gui = mbgraph.montage();

    % loop through volume keys
    for key_idx = 1:size(keys)
        key = keys(key_idx);
        % extract the table corresponding to this volume
        idx = table(:, 20) == key_idx;
        subtable = table(idx, :);
        % draw the particles as points and lines
        ax = gui.gca;
        sketch = dpktbl.plots.sketch(subtable, 'haxis', ax);
        % create a new frame for the next volume
        if key_idx~=size(keys, 1)
            gui.step;
        end
    end
end
