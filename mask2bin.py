#!/usr/bin/env python3

import os
import argparse 
import subprocess
import multiprocessing

try:
    from joblib import Parallel, delayed
except:
    print("<wm_laterality.py> Error importing joblib package\n")
    raise

#./xvfb-run-safe.sh ./Slicer/Slicer --testing --python-code "import numpy as np;Vol1 = slicer.util.loadVolume('/home/hayabusa/sub-3602428/ses-2/DTI_Metrics/sub-3602428_ses-2__fa.nii.gz');b = slicer.util.arrayFromVolume(Vol1);Vol2 = slicer.util.loadVolume('/home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_mask/T_CST_left.nii');b2 = slicer.util.arrayFromVolume(Vol2);b_b2 = b2; b_b2[b_b2>0]=1;volumeNode = slicer.modules.volumes.logic().CloneVolume(slicer.mrmlScene, Vol2, 'T_CST_left_bin_Vol2');volumeNode.CreateDefaultDisplayNodes();updateVolumeFromArray(volumeNode,b_b2);slicer.util.saveNode(volumeNode,'/home/hayabusa/BUJABUJA3.nii');"


#python3 mask2bin.py /home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_mask/ ./Slicer/Slicer /home/hayabusa/Documents/sdone_master/sub-3602428/sub-3602428_bmask/ sub-3602428

def pipeline(in_data, SDir, out_data, filename, SBJ):	
# in is the file from text file? yes its filename in dir _mask
 		fi = os.path.join(in_data, filename) # that gets Directory Path
 		ft = filename.rsplit(".", 1)[0] + "_bin.nii" # that modifies ouput file only
 		fo = os.path.join(out_data, ft)   # sets output path
 		if os.path.isfile(fi):
 			print(fi)   
 			print(fo)
 			subprocess.call(['/home/hayabusa/wm_mask2bin.sh', str(fi), str(SDir), str(fo), str(SBJ)])
 						
def main():
    #-----------------
    # Parse arguments
    #-----------------
    parser = argparse.ArgumentParser(
        description="Convert a nii mask to a binary mask. ",
        epilog="Written by Alexandre Pastor")
    
    parser.add_argument("-v", "--version",
        action="version", default=argparse.SUPPRESS,
        version='1.0',
        help="Show program's version number and exit")
    parser.add_argument(
        'Input_Directory',
        help='Input nii file to binarize.')
    parser.add_argument(
        'Slicer_Directory',
        help='Path to Slicer.')
    parser.add_argument(
        'Output',
        help='Path to Output binarized file.')
    parser.add_argument(
        'Subject',
        help='SBJ_ID')
    parser.add_argument(
        '-j', action="store", dest="numberOfJobs", type=int,
        help='Number of processors to use.')  
    
    args = parser.parse_args()
    
    in_data = args.Input_Directory 
    SDir = args.Slicer_Directory
    out_data = args.Output
    SBJ = args.Subject
    
    if not os.path.exists(SDir):
        print("Error: Slicer Input directory", SDir, "does not exist.")
        exit()
    
    print('CPUs detected:', multiprocessing.cpu_count())
    if args.numberOfJobs is not None:
           parallel_jobs = args.numberOfJobs
    else:
           parallel_jobs = multiprocessing.cpu_count()
           print('Using N jobs:', parallel_jobs)    
    
    
    # loop over all inputs
    Parallel(n_jobs=parallel_jobs, verbose=0)(
            delayed(pipeline)(in_data, SDir, out_data, filename, SBJ)
            for filename in os.listdir(in_data))
    
    exit()   


if __name__ == '__main__':
    main()    
