#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --account=def-adagher
#SBATCH --mem-per-cpu 18G

module load singularity/3.8
# clear sing bindings
export SINGULARITY_BIND=""
# work directory = Test
IN_D1=/home/hayabusa/wma_done/WMA_tutorial_data
# singularity image
IMG=/home/hayabusa/wma_done/SlicerJN27.sif
# Output prcss dir
OUT=/home/hayabusa/scratch/
# wma script invoke
WSI1=wm_quality_control_tractography.py
# Extract filename in Lookup dir. #can be vtk or vtp if using downsampling
cd $IN_D1/ && SBJ="$(ls *.vtp | sort -V | cut -d'.' -f1)"
#check if working dirs are present
cd $IN_D1 || exit
cd $OUT || exit


## QC - VTK INPUT DATA ## run with full dataset instead of downsample before thrsh.
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_quality_control_tractography.py /mnt_in /mnt_out/QC/InputTractography

## TRACT OVERLAP
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_quality_control_tract_overlap.py /mnt_in/ORG-Atlases-1.1.1/ORG-800FC-100HCP/atlas.vtp /mnt_in/$SBJ.vtp /mnt_out/QC/InputTractOverlap/

## REG. TO ATLAS
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_register_to_atlas_new.py -mode rigid_affine_fast /mnt_in/$SBJ.vtk /mnt_in/ORG-Atlases-1.1.1/ORG-RegAtlas-100HCP/registration_atlas.vtk /mnt_out/TractRegistration/

## QC TRACT REG. TO ATLAS
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_quality_control_tract_overlap.py /mnt_in/ORG-Atlases-1.1.1/ORG-800FC-100HCP/atlas.vtp /mnt_in/TractRegistration/$SBJ/output_tractography/${SBJ}_reg.vtk /mnt_out/QC/RegTractOverlap/

## FIBER CLUSTERING - INITIAL
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_cluster_from_atlas.py /mnt_out/TractRegistration/$SBJ/output_tractography/${SBJ}_reg.vtk /mnt_in/ORG-Atlases-1.1.1/ORG-800FC-100HCP/ /mnt_out/FiberClustering/InitialClusters/

## FIBER CLUSTERING - INITIAL 
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_quality_control_tractography.py /mnt_out/FiberClustering/InitialClusters/${SBJ}_reg/ /mnt_out/QC/FiberCluster-Initial/ 

## OUTLIER PROC.
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_cluster_remove_outliers.py /mnt_out/FiberClustering/InitialClusters/${SBJ}_reg/ /mnt_in/ORG-Atlases-1.1.1/ORG-800FC-100HCP/ /mnt_out/FiberClustering/OutlierRemovedClusters/

## OUTLIER PROC. # DIR NOT FOUND?
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_assess_cluster_location_by_hemisphere.py /mnt_out/FiberClustering/OutlierRemovedClusters/${SBJ}_reg_outlier_removed/ -clusterLocationFile /mnt_in/ORG-Atlases-1.1.1/ORG-800FC-100HCP/cluster_hemisphere_location.txt

## HARD TRANSFORM
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_harden_transform.py -i -t /mnt_out/TractRegistration/${SBJ}/output_tractography/itk_txform_${SBJ}.tfm /mnt_out/FiberClustering/OutlierRemovedClusters/${SBJ}_reg_outlier_removed/ /mnt_out/FiberClustering/TransformedClusters/${SBJ}/ /home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/Slicer 

## FIBER CLUSTERING - SEPARATE CLUSTERS BY HEMISPHERE
#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_separate_clusters_by_hemisphere.py /mnt_out/FiberClustering/TransformedClusters/${SBJ}/ /mnt_out/FiberClustering/SeparatedClusters/

## IDENTIFICATION ANATOMICAL TRACTS

#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_append_clusters_to_anatomical_tracts.py /mnt_out/FiberClustering/SeparatedClusters/ /mnt_in/ORG-Atlases-1.1.1/ORG-800FC-100HCP/ /mnt_out/AnatomicalTracts/

#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_quality_control_tractography.py /mnt_out/AnatomicalTracts/ /mnt_out/QC/AnatomicalTracts/

# FIBERTRACT_MEASUREMENTS

#export SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"/.singularity.d/libs:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Slicer-4.11:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Slicer-4.11/qt-loadable-modules:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Teem-1.12.0:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Python/lib"

#singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_diffusion_measurements.py /mnt_out/FiberClustering/SeparatedClusters/tracts_left_hemisphere/ /mnt_out/DiffusionMeasurements/left_hemisphere_clusters.csv /home/sliceruser/.config/NA-MIC/Extensions-29054/FiberTractMeasurements

export SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"/.singularity.d/libs:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Slicer-4.11:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Slicer-4.11/qt-loadable-modules:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Teem-1.12.0:/home/sliceruser/Slicer-4.11.0-2020-05-11-linux-amd64/lib/Python/lib"

singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_diffusion_measurements.py /mnt_out/FiberClustering/SeparatedClusters/tracts_right_hemisphere/ /mnt_out/DiffusionMeasurements/right_hemisphere_clusters.csv /home/sliceruser/.config/NA-MIC/Extensions-29054/FiberTractMeasurements

singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_diffusion_measurements.py /mnt_out/FiberClustering/SeparatedClusters/tracts_commissural/ /mnt_out/DiffusionMeasurements/commissural_clusters.csv /home/sliceruser/.config/NA-MIC/Extensions-29054/FiberTractMeasurements

singularity exec --bind $IN_D1:/mnt_in,$OUT:/mnt_out $IMG xvfb-run wm_diffusion_measurements.py /mnt_out/AnatomicalTracts/ /mnt_out/DiffusionMeasurements/anatomical_tracts.csv /home/sliceruser/.config/NA-MIC/Extensions-29054/FiberTractMeasurements


