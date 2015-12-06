data_root = '/Users/lisihan969/Desktop/data'

froms = {
    'ct'
    'pet'
};

patients = {
    'patient_001'
    'patient_002'
    'patient_003'
    'patient_004'
    'patient_005'
    'patient_006'
    'patient_007'
    'patient_008'
    'patient_009'
    'patient_101'
    'patient_102'
    'patient_103'
    'patient_104'
    'patient_105'
    'patient_106'
    'patient_107'
    'patient_108'
    'patient_109'
};

for patient = patients'
    patient = patient{1};
    disp(patient);
    for from = froms'
        from = from{1};
        from_dir = [data_root '/' patient '/' from];

        if ~exist(from_dir, 'dir')
            continue;
        end
        disp(['    ' from]);

        header = helperReadHeaderRIRE([from_dir '/header.ascii']);
        x_max = header.Columns - 1;
        y_max = header.Rows - 1;
        z_max = header.Slices - 1;

        points = [
            0       0       0
            x_max   0       0
            0       y_max   0
            x_max   y_max   0
            0       0       z_max
            x_max   0       z_max
            0       y_max   z_max
            x_max   y_max   z_max
        ];

        file = fopen([from_dir '/points.txt'], 'w');
        fprintf(file, 'index\n8\n');
        fprintf(file, '%4d %4d %4d\n', points');
        fclose(file);
    end
end
