#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --account=def-adagher
#SBATCH --mem-per-cpu 18G

module load singularity/3.8
singularity exec --overlay /lustre03/project/6008063/neurohub/ukbb/imaging/.tractoflow/neurohub_ukbb_tractoflow_1.squashfs:ro --bind /home/hayabusa/scratch/:/OUT ~/wma_done/SlicerJN27.sif ./fetch_data.sh

