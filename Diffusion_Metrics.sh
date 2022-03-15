#!/bin/bash

START="$(date +%s)"

cleanS=$(export SINGULARITY_BIND="")

eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"

# work directory = Test

# Extract filename in Lookup dir. #can be vtk or vtp if using downsampling
#cd $1/ && SBJ="$(ls *.vtk | sort -V | cut -d'.' -f1)"


SBJ=sub-3602428

#if dir for diffusion measures does not exist create it 


echo $SID $SD $MV $OD


IN=/home/hayabusa/Documents/sdone_master/$SBJ/${SBJ}_pp/AnatomicalTracts
REF=/home/hayabusa/${SBJ}/ses-2/DTI_Metrics/${SBJ}_ses-2__fa.nii.gz
REF2=/home/hayabusa/${SBJ}/ses-2/DTI_Metrics/${SBJ}_ses-2__rd.nii.gz
REF3=/home/hayabusa/${SBJ}/ses-2/DTI_Metrics/${SBJ}_ses-2__md.nii.gz
REF4=/home/hayabusa/${SBJ}/ses-2/DTI_Metrics/${SBJ}_ses-2__ad.nii.gz
REF5=/home/hayabusa/${SBJ}/ses-2/DTI_Metrics/${SBJ}_ses-2__ga.nii.gz
OUT=/home/hayabusa/Documents/sdone_master/${SBJ}/${SBJ}_mask   
BOUT=/home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_bmask


mkdir -p -m777 $BOUT $OUT

# singularity image
IMG=/home/hayabusa/Documents/singularity-master/SJN_5M22.sif

#check if working dirs are present
cd $IN || exit
cd $OUT || exit
cd $BOUT || exit



## Parallelize Fans script (ODonnell)
#python3 tract2vol2.py $IN $REF $OUT   

## Obtain binarized masks - parallelized
#python3 mask2bin.py $OUT ./Slicer/Slicer $BOUT $SBJ


# Needs conda activate radiomics ##
conda activate radiomics
##batch pyradiomics - 1 batch/diffusion metric (FA, RD etc)
python3 ~/pyradio.py $BOUT $REF $BOUT/${SBJ}_FA_diffusion_measures.csv  
python3 ~/pyradio.py $BOUT $REF2 $BOUT/${SBJ}_RD_diffusion_measures.csv  
python3 ~/pyradio.py $BOUT $REF3 $BOUT/${SBJ}_MD_diffusion_measures.csv  
python3 ~/pyradio.py $BOUT $REF4 $BOUT/${SBJ}_AD_diffusion_measures.csv  
python3 ~/pyradio.py $BOUT $REF5 $BOUT/${SBJ}_GA_diffusion_measures.csv  

#Remove duplicated headers
#awk 'NR==1 || NR%2==0' /home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_mask/sub-3602428_FA_diffusion_measures.csv > /home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_mask/sub-3602428_FA_dmeasures.csv

awk 'NR==1 || NR%2==0' $BOUT/${SBJ}_FA_diffusion_measures.csv  > $BOUT/${SBJ}_FA_dmeasures.csv 
awk 'NR==1 || NR%2==0' $BOUT/${SBJ}_RD_diffusion_measures.csv  > $BOUT/${SBJ}_RD_dmeasures.csv 
awk 'NR==1 || NR%2==0' $BOUT/${SBJ}_MD_diffusion_measures.csv  > $BOUT/${SBJ}_MD_dmeasures.csv 
awk 'NR==1 || NR%2==0' $BOUT/${SBJ}_AD_diffusion_measures.csv  > $BOUT/${SBJ}_AD_dmeasures.csv 
awk 'NR==1 || NR%2==0' $BOUT/${SBJ}_GA_diffusion_measures.csv  > $BOUT/${SBJ}_GA_dmeasures.csv 

DURATION=$[ $(date +%s) - ${START} ]
echo "tract2vol_pll took: $((DURATION/60))min and $((DURATION%60))sec to execute"
