#!/usr/bin/env bash

para_file='default0.txt'
out_dir='test'
tmp_dir='/tmp/elastix/working'
tmp_trans='/tmp/elastix/transform.txt'

froms="ct pet"
tos="mr_MP-RAGE
     mr_PD
     mr_PD_rectified
     mr_T1
     mr_T1_rectified
     mr_T2
     mr_T2_rectified"

dashes="----------------------------------------------------------------------"

before_data="\
Transformation Parameters

Patient number: %s
From: %s
To: %s

Point      x          y          z        new_x       new_y       new_z

"

after_data="
(All distances are in millimeters.)"

if [[ ! -d $tmp_dir ]]; then
    mkdir -p $tmp_dir
fi

for patient; do
    echo $patient
    patient_num=${patient: -3}

    for from in $froms; do
        from_dir=${patient}/${from}
        if [[ ! -d $from_dir ]]; then
            continue
        fi
        echo "    $from"
        from_img=$(ls ${from_dir}/*.mhd | head -1)

        for to in $tos; do
            to_dir=${patient}/${to}
            if [[ ! -d $to_dir ]]; then
                continue
            fi
            echo "        => $to"
            to_img=$(ls ${to_dir}/*.mhd | head -1)

            elastix -f $from_img -m $to_img -p $para_file -out $tmp_dir > /dev/null

            # Transform points.
            points="${from_dir}/points.txt"

            cp ${tmp_dir}/TransformParameters.0.txt $tmp_trans
            transformix -def $points -out $tmp_dir -tp $tmp_trans > /dev/null

            # Generate result.
            result_file="${out_dir}/patient${patient_num}_${from}_${to}.txt"
            data=${tmp_dir}/outputpoints.txt

            echo "$dashes" > $result_file
            printf "$before_data" $patient_num $from $to >> $result_file
            cat $data | awk '{print NR, $15, $16, $17, $31, $32, $33}' \
                >> $result_file
            echo "$after_data" >> $result_file
            echo "$dashes" >> $result_file
        done
    done
done
