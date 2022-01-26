#!/bin/bash
#
#SBATCH --array=1
#SBATCH --time=00:10:00
#SBATCH --account=def-adagher
#SBATCH --requeue
#SBATCH --mem-per-cpu 2GB                                                                                                                                     
#pll lookup dir
SID=$(sed -n "$SLURM_ARRAY_TASK_ID"p SID1S.txt)


if [ "$1" == "-h" ]; then
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
    pipe will run with two subjects - set SBATCH --array accordingly"
  exit 1
fi

cleanS=$(export SINGULARITY_BIND="")

START="$(date +%s)"
module load singularity/3.8

# clear sing bindings
$cleanS

# working dirs
SD=~/scratch/trk2vtk/${SID}/
MV=~/scratch/vtkpp/${SID}/
ATLAS=~/scratch/WMA_tutorial_data
OD=~/scratch/sdone_master/${SID}/
# singularity image
IMG=~/wma_done/SJN22.sif

mkdir -p -m777 $SD $MV $OD
echo $SID $SD $MV $OD

### trk2vtk conversion : trk2vtk_sls.py invoke - save streamlines
#singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind $SD:/OUT $IMG trk2vtk_sls.py -i /neurohub/ukbb/imaging/derivatives/tractoflow/${SID}/ses-2/PFT_Tracking/${SID}_ses-2__pft_tracking_prob_wm_seed_0.trk -o /OUT/${SID}.vtk

$cleanS

### 1M fibs. downsampling 40mm thresholding
#singularity exec --bind ${SD}:/IN,${MV}:/OUT $IMG wm_preprocess_all.py -f 1000000 -l 40 /IN/ /OUT/

$cleanS

### Master script
#singularity exec --bind $MV:/mnt_in,$ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_apply_ORG_atlas_to_subject.sh -i /mnt_in/${SID}_pp.vtp -o /mnt_out -a /mnt_atlas/ORG-Atlases-1.1.1 -s /home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/Slicer


$cleanS

##### QC - VTK INPUT DATA ## TO DO -- FINDS PATHS FOR MASTER SC. GEN FOLDERS
#singularity exec --bind $MV:/mnt_in,$ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tractography.py /mnt_in /mnt_out/QC/InputTractography

$cleanS

### TRACT OVERLAP
#singularity exec --bind $MV:/mnt_in,$ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tract_overlap.py /mnt_atlas/ORG-Atlases-1.1.1/ORG-800FC-100HCP/atlas.vtp /mnt_in/${SID}_pp.vtp /mnt_out/QC/InputTractOverlap/

$cleanS

### QC TRACT REG. TO ATLAS ## NEED call dir subjects TWICE
#singularity exec --bind $ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tract_overlap.py /mnt_atlas/ORG-Atlases-1.1.1/ORG-800FC-100HCP/atlas.vtp /mnt_out/${SID}_pp/TractRegistration/${SID}_pp/output_tractography/${SID}_pp_reg.vtk /mnt_out/QC/RegTractOverlap/

$cleanS

###IDENTIFICATION ANATOMICAL TRACTS QC
#singularity exec --bind $MV:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tractography.py /mnt_out/${SID}_pp/AnatomicalTracts/ /mnt_out/QC/AnatomicalTracts/

DURATION=$[ $(date +%s) - ${START} ]
echo "wma_ms_pll.sh took: $((DURATION/60))min and $((DURATION%60))sec to execute"

