#!/bin/bash                                     
#SBATCH -t 00:30:00                 
#SBATCH --job-name=compress_wma                          
#SBATCH --export=ALL                
#SBATCH --nodes=1           
#SBATCH --output="compress_out.txt"             
#SBATCH --cpus-per-task=1
#SBATCH --account=def-jbpoline
#SBATCH --mem-per-cpu 20MB
#SBATCH --ntasks=1
#SBATCH --array=1-10
#SBATCH --requeue

SID=$(sed -n "$SLURM_ARRAY_TASK_ID"p SID10.txt)

#use multicore compression pigz 2.4 (pre-installed in Narval cluster)
tar cf - ~/scratch/sdone_master/${SID} | pigz -1 -p 1 > ~/scratch/sdone_master/${SID}.tar.gz

