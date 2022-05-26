#!/bin/bash


IN=$1 # reference
REF=$2 # input
OUT=$3 #output


cd $IN
for f in *
do
 echo "Processing $f - reference is $REF - saving $OUT/$f"
 pyradiomics $REF $IN/$f -o $OUT -f 'csv' --format-path 'basename' --setting 'geometryTolerance: 0.00001'
done


        


