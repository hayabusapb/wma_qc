#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 11 16:38:45 2022

@author: hayabusa
"""
# if env is necessary -- refer to singularity image -- This is 4 Local
#conda activate radiomics

#Iterate through files in folder - use designated reference - convert 
import os
import argparse 
import subprocess
import multiprocessing

try:
    from joblib import Parallel, delayed
except:
    print("<wm_laterality.py> Error importing joblib package\n")
    raise

 ############################Explicit module
 # import required module
 # iterate over files in
 # that directory
def pipeline(in_data, reference, out_data, filename):	
 		fi = os.path.join(in_data, filename)     
 		if os.path.isfile(fi):
 			print(fi)   
 			subprocess.call(['pyradiomics', str(reference), str(fi), '-o', str(out_data), '-f', 'csv', '--format-path', 'basename'])		

 
def main():
    #-----------------
    # Parse arguments
    #-----------------
    parser = argparse.ArgumentParser(
        description="Calls iteratively pyradiomics / alternative multiprocessing to 'batches'",
        epilog="Written by Alexandre Pastor-Bernier")
    
    parser.add_argument("-v", "--version",
        action="version", default=argparse.SUPPRESS,
        version='1.0',
        help="Show program's version number and exit")
    
    parser.add_argument(
        'inputbin',
        help='Input bin directory that is going to be processed.')
    parser.add_argument(
        'refvolume',
        help='A volume image that the cluster will be converted upon.')
    parser.add_argument(
        'outputVol',
        help='Output csv')
    parser.add_argument(
        '-j', action="store", dest="numberOfJobs", type=int,
        help='Number of processors to use.')    
    
    args = parser.parse_args()
    
    in_data = args.inputbin  
    reference = args.refvolume 
    out_data = args.outputVol
    
    
    print('CPUs detected:', multiprocessing.cpu_count())
    if args.numberOfJobs is not None:
           parallel_jobs = args.numberOfJobs
    else:
           parallel_jobs = multiprocessing.cpu_count()
           print('Using N jobs:', parallel_jobs)    
    
    
    # loop over all inputs
    Parallel(n_jobs=parallel_jobs, verbose=0)(
            delayed(pipeline)(in_data, reference, out_data, filename)
            for filename in os.listdir(in_data))
    
    exit()   
    
   
if __name__ == '__main__':
    main()    
    
