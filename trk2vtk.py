#!/home/hayabusa/miniconda3/bin/python

import os
import argparse

try:
    from dipy.io.streamline import load_trk, save_tractogram
except:
    print("<dipy> Error importing trk packages")
    raise


def main():
    #-----------------
    # Parse arguments
    #-----------------
    parser = argparse.ArgumentParser(
        description="Applies trk2vtk conversion to input directory",
        epilog="Written by Alex Pastor alexandre.pastor@mcgill.ca")
    
    parser.add_argument(
        'inputFile',
        help='Contains whole-brain tractography as Trackvis TRK file(s).')
    parser.add_argument(
        'outputDir',
        help='The output directory should be a new empty directory. It will be created if needed.')
    args = parser.parse_args() 
    
    if not os.path.exists(args.inputFile):
        print("Error: Input File", args.inputFile, "does not exist.")
        exit()
    in_data = args.inputFile   
    out_data = args.outputDir
    if not os.path.exists(out_data):
        print("Output Directory", out_data, "does not exist, creating it.")
        os.makedirs(out_data)
    
    out1 = os.path.basename(args.inputFile)
    out2 = os.path.splitext(out1)[0]
    
    print("Starting TRK to VTK computation.")
    print("")
    print("=====input file======\n", in_data)
    print("=====output file=====\n", os.path.join(out_data, out2 + '.vtk'))
    print("==========================")    

######################
## Does conversion and saves
    tracto = load_trk(in_data,in_data,bbox_valid_check=False)
    save_tractogram(tracto,os.path.join(out_data, out2 + '.vtk'),bbox_valid_check=False)
    

if __name__ == '__main__':
    main()
