#!/bin/bash

#SBATCH --ntasks=6
#SBATCH --time=00:35:00
#SBATCH --array=1-1
#SBATCH --mem-per-cpu 2MB   
#SBATCH --account=def-jbpoline      
#SBATCH --nodes=1
#SBATCH --requeue

##try 50MB -- 200MB results in 1.2GB per core which is a waste APB 8AP2022

SID=$(sed -n "$SLURM_ARRAY_TASK_ID"p SID1S.txt)

srun --ntasks 1 ~/wma_done/Pyrtsid_1.sh $SID
srun --ntasks 1 ~/wma_done/Pyrtsid_2.sh $SID
srun --ntasks 1 ~/wma_done/Pyrtsid_3.sh $SID
srun --ntasks 1 ~/wma_done/Pyrtsid_4.sh $SID
srun --ntasks 1 ~/wma_done/Pyrtsid_5.sh $SID
srun --ntasks 1 ~/wma_done/Pyrtsid_6.sh $SID

##############
Pyrtsid_1.sh
##############
#!/bin/bash     

SID=$1
# working dirs
OD=~/scratch/sdone_master/${SID}
# singularity image
IMG=~/wma_done/SJN_4AP22.sif
# Diffusion measure dirs
RT=/neurohub/ukbb/imaging/derivatives/tractoflow/${SID}/ses-2
REF=${RT}/DTI_Metrics/${SID}_ses-2__fa.nii.gz
BOUT=${OD}/${SID}_bmask
MOUT=${OD}/${SID}/Diffusion_Measures
MOUT2=${MOUT}/${SID}

module load singularity/3.8

singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF /mnt_mout/${SID}_FA_diffusion_measures.csv

awk 'NR==1 || NR%2==0' $MOUT2/${SID}_FA_diffusion_measures.csv  > $MOUT2/${SID}_FA_dmeasures.csv

rm $MOUT2/${SID}_FA_diffusion_measures.csv                                      

#############
Pyrtsid_2.sh
#############                  
#!/bin/bash


# working dirs
SID=$1
OD=~/scratch/sdone_master/${SID}
# singularity image
IMG=~/wma_done/SJN_4AP22.sif
# Diffusion measure dirs

RT=/neurohub/ukbb/imaging/derivatives/tractoflow/${SID}/ses-2
REF2=${RT}/DTI_Metrics/${SID}_ses-2__rd.nii.gz
BOUT=${OD}/${SID}_bmask
MOUT=${OD}/${SID}/Diffusion_Measures
MOUT2=${MOUT}/${SID}

module load singularity/3.8

singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF2 /mnt_mout/${SID}_RD_diffusion_measures.csv

awk 'NR==1 || NR%2==0' $MOUT2/${SID}_RD_diffusion_measures.csv  > $MOUT2/${SID}_RD_dmeasures.csv

rm $MOUT2/${SID}_RD_diffusion_measures.csv
                                                                          
#############
Pyrtsid_3.sh
#############
#!/bin/bash     

SID=$1
# working dirs
OD=~/scratch/sdone_master/${SID}
# singularity image
IMG=~/wma_done/SJN_4AP22.sif
# Diffusion measure dirs

RT=/neurohub/ukbb/imaging/derivatives/tractoflow/${SID}/ses-2
REF3=${RT}/DTI_Metrics/${SID}_ses-2__md.nii.gz
BOUT=${OD}/${SID}_bmask
MOUT=${OD}/${SID}/Diffusion_Measures
MOUT2=${MOUT}/${SID}

module load singularity/3.8

singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF3 /mnt_mout/${SID}_MD_diffusion_measures.csv

awk 'NR==1 || NR%2==0' $MOUT2/${SID}_MD_diffusion_measures.csv  > $MOUT2/${SID}_MD_dmeasures.csv

rm $MOUT2/${SID}_MD_diffusion_measures.csv

#############
Pyrtsid_4.sh
#############

#!/bin/bash     

SID=$1
# working dirs
#SID=sub-3602428
OD=~/scratch/sdone_master/${SID}
# singularity image
IMG=~/wma_done/SJN_4AP22.sif
# Diffusion measure dirs

RT=/neurohub/ukbb/imaging/derivatives/tractoflow/${SID}/ses-2
REF4=${RT}/DTI_Metrics/${SID}_ses-2__ad.nii.gz
BOUT=${OD}/${SID}_bmask
MOUT=${OD}/${SID}/Diffusion_Measures
MOUT2=${MOUT}/${SID}

module load singularity/3.8

singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF4 /mnt_mout/${SID}_AD_diffusion_measures.csv

awk 'NR==1 || NR%2==0' $MOUT2/${SID}_AD_diffusion_measures.csv  > $MOUT2/${SID}_AD_dmeasures.csv

rm $MOUT2/${SID}_AD_diffusion_measures.csv

#############
Pyrtsid_5.sh
#############
#!/bin/bash     

SID=$1
# working dirs
OD=~/scratch/sdone_master/${SID}
# singularity image
IMG=~/wma_done/SJN_4AP22.sif
# Diffusion measure dirs

RT=/neurohub/ukbb/imaging/derivatives/tractoflow/${SID}/ses-2
REF5=${RT}/DTI_Metrics/${SID}_ses-2__ga.nii.gz
BOUT=${OD}/${SID}_bmask
MOUT=${OD}/${SID}/Diffusion_Measures
MOUT2=${MOUT}/${SID}

module load singularity/3.8

singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind $BOUT:/mnt_bout,$MOUT2:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout $REF5 /mnt_mout/${SID}_GA_diffusion_measures.csv

awk 'NR==1 || NR%2==0' $MOUT2/${SID}_GA_diffusion_measures.csv  > $MOUT2/${SID}_GA_dmeasures.csv

rm $MOUT2/${SID}_GA_diffusion_measures.csv
                                                                           

#############
Pyrtsid_6.sh
#############
#!/bin/bash     

SID=$1
# working dir
OD=~/scratch/sdone_master/${SID}
# singularity image
IMG=~/wma_done/SJN_4AP22.sif
# Diffusion measure dirs

BOUT=${OD}/${SID}_bmask
FWOUT=${OD}/FW_Measures
MOUT=${OD}/${SID}/Diffusion_Measures/${SID}

module load singularity/3.8

singularity exec --bind $BOUT:/mnt_bout,$FWOUT:/mnt_fwout,$MOUT:/mnt_mout $IMG xvfb-run-safe.sh /home/conda/bin/pyradio_Simple.sh /mnt_bout /mnt_fwout/${SID}_FW.nii.gz /mnt_mout/${SID}_FW_diffusion_measures.csv

awk 'NR==1 || NR%2==0' $MOUT/${SID}_FW_diffusion_measures.csv  > $MOUT/${SID}_FW_dmeasures.csv

rm $MOUT/${SID}_FW_diffusion_measures.csv


