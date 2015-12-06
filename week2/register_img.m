function result = register_img(data_set_dir, from, to, method_name)
    patient_num = data_set_dir(end-2:end);
    moving_dir = [data_set_dir '/' from];
    fixed_dir = [data_set_dir '/' to];

    [moving_header, moving_volume] = read_rire(moving_dir);
    [fixed_header, fixed_volume] = read_rire(fixed_dir);

    % Compare.
    % helperVolumeRegistration(moving_volume, fixed_volume);

    % Construct spatial referencing objects.
    moving_ref = imref3d(size(moving_volume), ...
                         moving_header.PixelSize(2), ...
                         moving_header.PixelSize(1), ...
                         moving_header.SliceThickness);
    fixed_ref = imref3d(size(fixed_volume), ...
                        fixed_header.PixelSize(2), ...
                        fixed_header.PixelSize(1), ...
                        fixed_header.SliceThickness);

    moving_ref = fix_ref(moving_ref);
    fixed_ref = fix_ref(fixed_ref);

    % [optimizer, metric] = imregconfig('multimodal');
    % optimizer.InitialRadius = 0.004;
    optimizer = registration.optimizer.OnePlusOneEvolutionary;
    metric = registration.metric.MeanSquares;
    % metric = registration.metric.MattesMutualInformation;
    optimizer.InitialRadius = 0.0005;
    optimizer.Epsilon = 1.5e-4;
    optimizer.GrowthFactor = 1.01;
    optimizer.MaximumIterations = 300;

    % % Compare & exit.
    % registered_volume = imregister(moving_volume, moving_ref, ...
    %                                fixed_volume, fixed_ref, ...
    %                                'rigid', optimizer, metric, ...
    %                                'DisplayOptimization', true);
    % % Compare.
    % helperVolumeRegistration(moving_volume, fixed_volume);
    % return

    % Get transformation.
    transformation = imregtform(moving_volume, moving_ref, ...
                                fixed_volume, fixed_ref, ...
                                'rigid', optimizer, metric, 'PyramidLevels', 3);

    x = [1; 2; 1; 2; 1; 2; 1; 2];
    y = [1; 1; 2; 2; 1; 1; 2; 2];
    z = [1; 1; 1; 1; 2; 2; 2; 2];
    x(x == 2) = moving_ref.ImageSize(2);
    y(y == 2) = moving_ref.ImageSize(1);
    z(z == 2) = moving_ref.ImageSize(3);
    [x, y, z] = intrinsicToWorld(moving_ref, x, y, z);

    [new_x, new_y, new_z] = transformPointsForward(transformation, x, y, z);
    result = [x y z new_x new_y new_z];

    % Save result.
    file = fopen( ...
        [method_name '/patient' patient_num '_' from '_' to '.txt'], 'w');

    fprintf(file, [ ...
        '-------------------------------------------------------------\n' ...
        'Transformation Parameters\n' ...
        '\n' ...
        'Patient number: %s\n' ...
        'From: %s\n' ...
        'To: %s\n' ...
        '\n' ...
        'Point      x          y          z        new_x       new_y       new_z\n' ...
        '\n' ...
    ], patient_num, from, to);

    fprintf(file, '  %d %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n', ...
            [(1:8)', result]');

    fprintf(file, [ ...
        '\n' ...
        '(All distances are in millimeters.)\n' ...
        '-------------------------------------------------------------\n' ...
    ]);

    fclose(file);
end

function fixed_ref = fix_ref(ref)
    ref.XWorldLimits = ref.XWorldLimits - [1 1] * ref.PixelExtentInWorldX;
    ref.YWorldLimits = ref.YWorldLimits - [1 1] * ref.PixelExtentInWorldY;
    ref.ZWorldLimits = ref.ZWorldLimits - [1 1] * ref.PixelExtentInWorldZ;

    fixed_ref = ref;
end
