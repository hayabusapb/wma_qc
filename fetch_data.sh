#!/bin/bash


## convert and process module _ Alexandre Pastor 26Dec2021
## can replace i<=${nfiles} by 1 for specific #
cd /home/conda/bin/
files=($(ls /neurohub/ukbb/imaging/derivatives/tractoflow/))
nfiles=${#files[@]}
for ((i=0 ; i<=1; i++)); do
  echo "File -> $i"
  echo ${files[$i]}
  trk2vtk.py /neurohub/ukbb/imaging/derivatives/tractoflow/${files[$i]}/ses-2/PFT_Tracking/${files[$i]}"_ses-2__pft_tracking_prob_wm_seed_0.trk" /OUT/trk2vtk_files
  wm_preprocess_all.py -f 500000 -l 40 /OUT/trk2vtk_files/ /OUT/vtkpp/
done

