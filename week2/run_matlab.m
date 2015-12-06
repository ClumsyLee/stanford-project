data_root = '/Users/lisihan969/Desktop/data'

froms = {
    'ct'
    'pet'
};

tos = {
    'mr_MP-RAGE'
    'mr_PD'
    'mr_PD_rectified'
    'mr_T1'
    'mr_T1_rectified'
    'mr_T2'
    'mr_T2_rectified'
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
};

for patient = patients'
    patient = patient{1};
    disp(patient);
    for from = froms'
        from = from{1};
        if ~exist([data_root '/' patient '/' from], 'dir')
            continue;
        end
        disp(['    ' from]);

        for to = tos'
            to = to{1};
            if ~exist([data_root '/' patient '/' to], 'dir')
                continue;
            end
            disp(['        => ' to]);

            register_img([data_root '/' patient], from, to, ...
                         'matlab-MI');
        end
    end
end
