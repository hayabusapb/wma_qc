#!/bin/bash
#
#SBATCH --array=1-2
#SBATCH --time=02:20:00
#SBATCH --account=def-jbpoline
#SBATCH --requeue
#SBATCH --mem-per-cpu 80GB                                                                                                                                     
#pll lookup dir

SID=$(sed -n "$SLURM_ARRAY_TASK_ID"p SID2.txt)

# Get the options
QL=""
VAL=1 # default QC will be done

while getopts ":hq:" option; do
   case $option in
      h) # display Help
         echo "Usage: wma_ms_pll.sh 
### Creates read-output input and output dir in wma_pipe for pll 
(Alexandre_Pastor_Jan2022 - McGill MNI-BIC)
### Requires: 2 predef. writable output dirs: 
e.g trk2vtk/ and vtkpp/ dirs on scratch--
### Input dir with image container: e.g wma_done/
# Dependencies (provided in image):
#################################################
# 3DSlicer
# trk2vtk_sls.py
# xvfb-run-safe.sh
# Subject List for slurm: e.g SID.txt subjects:
txt file #rows per subj. 
e.g sub-3513788
    sub-3538534
    pipe will run with two subjects - set SBATCH --array accordingly
### QC argument -q[0-2] specify prcss. being not performed (0), performed (1), or exclussively performed (2) after wma_pipeline    "

        exit 0
        ;;
      q) # quality control opts
      QL=${OPTARG}
      re_isanum='^[0-9]+$'                # Regex: match whole numbers only
      if ! [[ $QL =~ $re_isanum ]] ; then   # if $QC not whole:
        echo "Error: Quality Control:q must be a positive, whole number."
        exit_abnormal
        exit 1
      elif [ $QL -eq 0 ]; then       # If it's zero:
        echo "*****Quality control will NOT be performed"
Type  :qa  and press <Enter> to exit Vim                      1,1           Top
