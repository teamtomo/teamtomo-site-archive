v = dread('average_ref_001_ite_0008.em');

rod_radius = 2;
rod_height = 4;
membrane_thickness = 15;
box_size = 32;

% Create fake membrane
mr = dpktomo.examples.motiveTypes.Membrane();   % create membrane object
mr.thickness  = membrane_thickness;       % choose thickness of membrane
mr.sidelength = box_size; % choose sidelength of box
mr.fillData();

mem = mr.getData().*-1;

% Create cylinder in center to represent hole in center of structure to align to
cyl = dynamo_cylinder([rod_radius, floor(rod_height / 2)], 32, [16, 16, 21]);
cyl = dynamo_sym(cyl, 9);

cyl_shift = dynamo_shift_rot(cyl, [8, 0, 0], [0,0,0]);
cyl_shift(isnan(cyl_shift)) = 0;
cyl_shift_sym = dynamo_sym(cyl_shift, 6) .* 6;

% Combine membrane and hole
template = mem - cyl - cyl_shift_sym + 1;

% normalise both volumes
template = dynamo_normalize_roi(template);
v = dynamo_normalize_roi(v);

% Align average to synthetic template
sal = dalign(v, template ,'cr',60,'cs',20,'ir',90, 'is', 30, 'rf', 5, 'dim', box_size,'limm',1,'lim',[4,4,4]);
v_aligned = sal.aligned_particle;
v_aligned_c6 = dynamo_sym(v_aligned, 'c6');

dmapview{v, template, v_aligned, v_aligned_c6}

% write out averages
dwrite(template, 'synthetic_template.em');
dwrite(v_aligned, 'average_aligned_along_z.em');
dwrite(v_aligned_c6, 'average_aligned_along_z_c6.em');
