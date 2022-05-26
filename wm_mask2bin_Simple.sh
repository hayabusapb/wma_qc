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



