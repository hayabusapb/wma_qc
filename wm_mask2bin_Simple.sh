#!/bin/bash


IN=$1 # nii file from dir e.g T_CST_lect.nii 
Slicer_path=$2 # ./Slicer/Slicer
OUT=$3
REF=$4


for f in "$1"*
do
echo "Processing $f"
/home/conda/bin/xvfb-run-safe.sh ${Slicer_path} --testing --python-code "import numpy as np;Vol1 = slicer.util.loadVolume('${REF}');b = slicer.util.arrayFromVolume(Vol1);Vol2 = slicer.util.loadVolume('${f}');b2 = slicer.util.arrayFromVolume(Vol2);b_b2 = b2; b_b2[b_b2>0]=1;volumeNode = slicer.modules.volumes.logic().CloneVolume(slicer.mrmlScene, Vol2, '${f}_bin_Vol2');volumeNode.CreateDefaultDisplayNodes();updateVolumeFromArray(volumeNode,b_b2);slicer.util.saveNode(volumeNode,'${OUT}${f##*/}');"
done




##e.g Backlashes in dir IN important, OUT should be a file
#SID=sub-3602428
#IN=/home/hayabusa/Documents/sdone_master/${SID}/${SID}_mask/
#Slicer_path=/home/hayabusa/Slicer/Slicer 
#OUT=/home/hayabusa/Documents/sdone_master/${SID}/${SID}_bmask/
#REF=/home/hayabusa/${SID}/ses-2/DTI_Metrics/${SID}_ses-2__fa.nii.gz




## Issues strange error Slicer_11:
#No writer found to write file QVariant(QString, "/home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_bmask") of type "VolumeFile"


