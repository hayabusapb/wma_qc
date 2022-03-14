#!/bin/bash


IN=$1 # nii file from dir e.g T_CST_lect.nii 
Slicer_Directory=$2 # ./Slicer/Slicer
OUT=$3
SBJ=$4

#IN is not recognized -- it looks at directory -- and has on top of that wrong  _bin2.nii

./xvfb-run-safe.sh ${Slicer_Directory} --testing --python-code "import numpy as np;Vol1 = slicer.util.loadVolume('/home/hayabusa/${SBJ}/ses-2/DTI_Metrics/${SBJ}_ses-2__fa.nii.gz');b = slicer.util.arrayFromVolume(Vol1);Vol2 = slicer.util.loadVolume('${IN}');b2 = slicer.util.arrayFromVolume(Vol2);b_b2 = b2; b_b2[b_b2>0]=1;volumeNode = slicer.modules.volumes.logic().CloneVolume(slicer.mrmlScene, Vol2, '${IN}_bin_Vol2');volumeNode.CreateDefaultDisplayNodes();updateVolumeFromArray(volumeNode,b_b2);slicer.util.saveNode(volumeNode,'${OUT}');"
