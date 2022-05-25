#!/bin/bash
#
#SBATCH --array=1-995
#SBATCH --time=03:30:00
#SBATCH --account=rpp-aevans-ab
#SBATCH --requeue
#SBATCH --mem-per-cpu=80GB

#pll lookup dir ## OBS* make sure SID has list of subject without _ses2 appended

SID=$(sed -n "$SLURM_ARRAY_TASK_ID"p SID_3350.txt)

# Get the options
QL=""
VAL=1 # default QC will be done

while getopts ":hq:" option; do
   case $option in
      h) # display Help
         echo "Usage: CNPLLC.sh 
### Creates read-output input and output dir in wma_pipe for pll 
(Alexandre_Pastor_Jan2022 - McGill MNI-BIC)

### Requirements:

- Input 

1) scratch containing the directory WMA_tutorial_data, found in p.2 from Lauren ODonnells whitematter analysis documentation
https://github.com/SlicerDMRI/whitematteranalysis/blob/master/doc/subject-specific-tractography-parcellation.md
This directory contains ORG atlas contains an 800-cluster parcellation of the entire white matter and an anatomical fiber tract parcellation (~2.5GB)

2) Ofer Pasternak Free-Water libraries (Not freely distributed and hardwired for now)

3) Path to the singularity image 
** Hardwired for now
IMG=~/wma_done/SJN_4AP22.sif

4) Path to squashfs
** Hardwired for now
RR=/lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs
NOTE- the number of files determines the size of the array.

5) Subject List for slurm: e.g SID.txt subjects:
txt file #rows per subj. 
e.g sub-3513788
    sub-3538534
    pipe will run with two subjects - set SBATCH --array accordingly
 
- Output 


# Additional info: singularity image main dependencies
#################################################
# 3DSlicer
# trk2vtk_sls.py
# xvfb-run-safe.sh
# pyradiomics
# Pasternak's Free-Water analysis

# Matlab (Is not inside singularity - loads as module Matlab 2020a * Verify user license is up to date)
https://docs.alliancecan.ca/wiki/MATLAB

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
      elif [ $QL -eq 1 ]; then
        echo "*****Quality control will be performed"
      elif [ $QL -eq 2 ]; then
        echo "*****ONLY Quality control will be performed"  
      fi
      ;;
      :)                                    # If expected argument omitted:
        echo "Error: -${OPTARG} requires an argument."
        exit_abnormal                       # Exit abnormally.
      ;;
      *)                                    # If unknown (any other) option:
                exit_abnormal                       # Exit abnormally.
      ;;
   esac
done

cleanS=$(export SINGULARITY_BIND="")

START="$(date +%s)"

# Load Modules
module load singularity/3.8 matlab/2020a

# clear sing bindings
$cleanS

# working dirs
OD=$SLURM_TMPDIR/${SID}
SD=${OD}/trk2vtk/
MV=${OD}/vtk2vtp/
ATLAS=~/scratch/WMA_tutorial_data
# singularity image
IMG=~/wma_done/SJN_4AP22.sif

# Diffusion measure dirs
IN=${OD}/${SID}_pp/AnatomicalTracts

RR='--overlay /lustre03/project/6008063/ahutton/tractoflow_out/tractoflow_3150.squashfs:ro --overlay /lustre03/project/6008063/ahutton/tractoflow_out/tractoflow_3200.squashfs:ro --overlay /lustre03/project/6008063/ahutton/tractoflow_out/tractoflow_3250.squashfs:ro --overlay /lustre03/project/6008063/ahutton/tractoflow_out/tractoflow_3300.squashfs:ro --overlay /lustre03/project/6008063/ahutton/tractoflow_out/tractoflow_3350.squashfs:ro'

RT=/tractoflow_results/${SID}_ses-2

REF=${RT}/DTI_Metrics/${SID}_ses-2__fa.nii.gz
REF2=${RT}/DTI_Metrics/${SID}_ses-2__rd.nii.gz
REF3=${RT}/DTI_Metrics/${SID}_ses-2__md.nii.gz
REF4=${RT}/DTI_Metrics/${SID}_ses-2__ad.nii.gz
REF5=${RT}/DTI_Metrics/${SID}_ses-2__ga.nii.gz
OUT=${OD}/${SID}_mask
BOUT=${OD}/${SID}_bmask
MOUT=${OD}/${SID}/Diffusion_Measures
FWOUT=${OD}/FW_Measures
MOUT2=${MOUT}/${SID}
#Pasternaks DWI,BVAL,BVEC and seeding Mask
OP=${OD}/FW_Source
DWI=${OP}/${SID}_ses-2__dwi_dti.nii.gz
Bval=${OP}/${SID}_ses-2__bval_dti
Bvec=${OP}/${SID}_ses-2__bvec_dti
Mask=${OP}/${SID}_ses-2__pft_seeding_mask.nii.gz

LOCAL=~/scratch/sdone_master_0t3350

Choco="cd('~/wma_done/Free-Water');addpath(genpath(cd));FreeWater_OneCase('$SID', '$DWI', '$Bval', '$Bvec', '$Mask', '$FWOUT');exit;"

mkdir -p -m777 $SD $MV $BOUT $OUT $MOUT $OP $MOUT2 $FWOUT
echo $SID $SD $MV $BOUT $OUT $MOUT 

if [ $QL -ne 2 ];
then

 	### trk2vtk conversion : trk2vtk_sls.py invoke - save streamlines
	singularity exec ${RR} --bind $SD:/OUT $IMG trk2vtk_sls.py -i ${RT}/PFT_Tracking/${SID}_ses-2__pft_tracking_prob_wm_seed_0.trk -o /OUT/${SID}.vtk

	$cleanS

	### 1M fibs. downsampling 40mm thresholding
	singularity exec --bind ${SD}:/IN,${MV}:/OUT $IMG wm_preprocess_all.py -f 1000000 -l 40 /IN/ /OUT/

	$cleanS

	### Master script
	singularity exec --bind $MV:/mnt_in,$ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_apply_ORG_atlas_to_subject.sh -i /mnt_in/${SID}_pp.vtp -o /mnt_out -a /mnt_atlas/ORG-Atlases-1.1.1 -s /home/sliceruser/Slicer-4.10.2-linux-amd64/Slicer

        ## PASTERNAK FW - APB 27MAR2022#
        $cleanS

 singularity exec ${RR} --bind $OP:/Mount_OP $IMG cp -n $RT/Extract_DTI_Shell/${SID}_ses-2__dwi_dti.nii.gz $RT/Extract_DTI_Shell/${SID}_ses-2__bval_dti $RT/Extract_DTI_Shell/${SID}_ses-2__bvec_dti $RT/PFT_Seeding_Mask/${SID}_ses-2__pft_seeding_mask.nii.gz /Mount_OP

        matlab -nodisplay -nojvm -nosplash -r "$Choco"

	 ##MASK VOXELIZATION
        $cleanS
	
	singularity exec ${RR} --bind $IN:/Mount_in,$OUT:/Mount_Out $IMG xvfb-run-safe.sh tract2vol_Simple.sh /Mount_in $REF /Mount_Out


	##BINARY MASKS
        $cleanS

	singularity exec ${RR} --bind $BOUT:/mnt_bout,$OUT:/mnt_out $IMG wm_mask2bin_Simple.sh /mnt_out /home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/Slicer /mnt_bout $REF
	

       ## Cleaning intermediate processing files
       rm -r $SD $OUT
	
	$cleanS
	
	 ## Run Pyradiomics serially
	singularity exec ${RR} --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF /mnt_mout/${SID}_FA_diffusion_measures.csv

	awk 'NR==1 || NR%2==0' $MOUT2/${SID}_FA_diffusion_measures.csv  > $MOUT2/${SID}_FA_dmeasures.csv

	rm $MOUT2/${SID}_FA_diffusion_measures.csv
      
       $cleanS

       singularity exec ${RR} --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF2 /mnt_mout/${SID}_RD_diffusion_measures.csv

	awk 'NR==1 || NR%2==0' $MOUT2/${SID}_RD_diffusion_measures.csv  > $MOUT2/${SID}_RD_dmeasures.csv

	rm $MOUT2/${SID}_RD_diffusion_measures.csv

	$cleanS

       singularity exec ${RR} --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF3 /mnt_mout/${SID}_MD_diffusion_measures.csv

	awk 'NR==1 || NR%2==0' $MOUT2/${SID}_MD_diffusion_measures.csv  > $MOUT2/${SID}_MD_dmeasures.csv

	rm $MOUT2/${SID}_MD_diffusion_measures.csv

	$cleanS

	singularity exec ${RR} --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF4 /mnt_mout/${SID}_AD_diffusion_measures.csv

	awk 'NR==1 || NR%2==0' $MOUT2/${SID}_AD_diffusion_measures.csv  > $MOUT2/${SID}_AD_dmeasures.csv

	rm $MOUT2/${SID}_AD_diffusion_measures.csv

        $cleanS

      singularity exec ${RR} --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF5 /mnt_mout/${SID}_GA_diffusion_measures.csv

	awk 'NR==1 || NR%2==0' $MOUT2/${SID}_GA_diffusion_measures.csv  > $MOUT2/${SID}_GA_dmeasures.csv

	rm $MOUT2/${SID}_GA_diffusion_measures.csv
       
       $cleanS

	singularity exec --bind $BOUT:/mnt_bout,$FWOUT:/mnt_fwout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout /mnt_fwout/${SID}_FW.nii.gz /mnt_mout/${SID}_FW_diffusion_measures.csv

	awk 'NR==1 || NR%2==0' $MOUT2/${SID}_FW_diffusion_measures.csv  > $MOUT2/${SID}_FW_dmeasures.csv

	rm $MOUT2/${SID}_FW_diffusion_measures.csv

       $cleanS
       
        ## Compress

        tar --use-compress-program="pigz -k -p1" -cf $LOCAL/${SID}.tar.gz $OD

        echo "CNPLL in ${SID} processing completed"
fi

if [ $QL -ne 0 ];
then

        $cleanS

        ##### QC - VTK INPUT DATA ## TO DO -- FINDS PATHS FOR MASTER SC. GEN FOLDERS
        singularity exec --bind $MV:/mnt_in,$ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tractography.py /mnt_in /mnt_out/QC_${SID}/InputTractography

        $cleanS

        ### TRACT OVERLAP
        singularity exec --bind $MV:/mnt_in,$ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tract_overlap.py /mnt_atlas/ORG-Atlases-1.1.1/ORG-800FC-100HCP/atlas.vtp /mnt_in/${SID}_pp.vtp /mnt_out/QC_${SID}/InputTractOverlap/

        $cleanS

        ### QC TRACT REG. TO ATLAS ## NEED call dir subjects TWICE
        singularity exec --bind $ATLAS:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tract_overlap.py /mnt_atlas/ORG-Atlases-1.1.1/ORG-800FC-100HCP/atlas.vtp /mnt_out/${SID}_pp/TractRegistration/${SID}_pp/output_tractography/${SID}_pp_reg.vtk /mnt_out/QC_${SID}/RegTractOverlap/

        $cleanS

        ###IDENTIFICATION ANATOMICAL TRACTS QC
        singularity exec --bind $MV:/mnt_atlas,$OD:/mnt_out $IMG xvfb-run-safe.sh wm_quality_control_tractography.py /mnt_out/${SID}_pp/AnatomicalTracts/ /mnt_out/QC_${SID}/AnatomicalTracts/
        
exit;
fi



DURATION=$[ $(date +%s) - ${START} ]
echo "CNPLL.sh took: $((DURATION/60))min and $((DURATION%60))sec to execute"

