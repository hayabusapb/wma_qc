#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Convert TRK to VTK other format
Etienne St-Onge 2022 - Sherbrooke University
"""

import argparse
# import nibabel as nib
import numpy as np

# import trimeshpy.vtk_util as vtk_u
# from trimeshpy.vtk_util import vtk_to_vox, vtk_to_voxmm, vox_to_vtk, voxmm_to_vtk, save_polydata

from dipy.io.streamline import load_tractogram, save_tractogram, save_vtk_streamlines
from dipy.io.stateful_tractogram import Origin, Space, StatefulTractogram

import vtk
from vtk.util import numpy_support


def _build_arg_parser():
    p = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('in_trk',
                   help='Input tractogram, assumed in RASmm from Dipy')

    p.add_argument('ref',
                   help='DWI Reference image (ex: fa.nii.gz)')

    p.add_argument('out_vtk',
                   help='Output transformed surface file .')

    savev = p.add_mutually_exclusive_group()
    savev.add_argument('--vtkoffset', action='store_true', help='Save with vtk offset (fury)')
    savev.add_argument('--vtkline', action='store_true',  help='Save with vtkLine (line)')

    p.add_argument('--disable_check', action='store_true',
                   help='disable trk loading check')

    p.add_argument('--binary', action='store_true',
                   help='Save in vtk binary format')

    p.add_argument('--use_float32', action='store_true',
                   help='Use float32 for vertices, instead of float64')

    p.add_argument('--use_int32', action='store_true',
                   help='Use int32 for offset, instead of int64')
                   
    p.add_argument('--hybrid', action='store_true', 
    		    help='Use sls_vtk_save_streamlins')               
    return p
     

def main():
    parser = _build_arg_parser()
    args = parser.parse_args()

    input_test = ~args.disable_check
    # Load in rasmm
    tracto = load_tractogram(args.in_trk, args.ref, to_space=Space.RASMM, to_origin=Origin.NIFTI,
                             bbox_valid_check=input_test, trk_header_check=input_test)

    slines = tracto.streamlines
    nb_slines = len(slines)
    print(nb_slines)

    float_type = np.float64
    if args.use_float32:
        float_type = np.float32

    int_type = np.int64
    if args.use_int32:
        int_type = np.int32

    # Generate VTK vertices / points
    vtk_points = vtk.vtkPoints()
    vtk_points.SetData(numpy_support.numpy_to_vtk(np.vstack(slines).astype(float_type), deep=True))

    # Generate VTK cells / lines
    vtk_cells = vtk.vtkCellArray()
    if args.vtkline:
        # from "slicer"
        vts_id = 0
        for i in range(len(slines)):
            vtk_line = vtk.vtkLine()
            vtk_line.GetPointIds().SetNumberOfIds(len(slines[i]))
            for j in range(len(slines[i])):
                line_ids = vtk_line.GetPointIds()
                line_ids.SetId(j, vts_id)
                vts_id += 1
            vtk_cells.InsertNextCell(vtk_line)
    elif args.vtkoffset:
        # from "dipy / fury"
        connectivity = []
        offset = [0, ]
        current_position = 0

        for i in range(len(slines)):
            current_len = len(slines[i])
            offset.append(offset[-1] + current_len)

            end_position = current_position + current_len
            connectivity += list(range(current_position, end_position))
            current_position = end_position

        connectivity = np.array(connectivity, int_type)
        offset = np.array(offset, dtype=int_type)

        vtk_array_type = numpy_support.get_vtk_array_type(int_type)
        vtk_cells.SetData(numpy_support.numpy_to_vtk(offset, deep=True, array_type=vtk_array_type),
                          numpy_support.numpy_to_vtk(connectivity, deep=True, array_type=vtk_array_type))
    elif args.hybrid:
    
        save_vtk_streamlines(slines,args.out_vtk,to_lps=True, binary=False) 
    
    else:
        # from "trimeshpy"
        lines_array = []
        points_per_line = np.zeros([len(slines)], dtype=int_type)
        current_position = 0
        for i in range(len(slines)):
            current_len = len(slines[i])
            points_per_line[i] = current_len

            end_position = current_position + current_len
            lines_array += [current_len]
            lines_array += range(current_position, end_position)
            current_position = end_position

        # Set Points to vtk array format
        vtk_array_type = numpy_support.get_vtk_array_type(int_type)
        lines_array = numpy_support.numpy_to_vtk(lines_array, deep=True, array_type=vtk_array_type)

        # Set Lines to vtk array format
        vtk_cells.GetData().DeepCopy(lines_array)
        vtk_cells.SetNumberOfCells(len(slines))

    # Generate VTK polydata
    polydata = vtk.vtkPolyData()
    polydata.SetLines(vtk_cells)
    polydata.SetPoints(vtk_points)

    file_name = args.out_vtk
    file_extension = file_name.split(".")[-1].lower()
    if file_extension == "vtk":
        writer = vtk.vtkPolyDataWriter()
    elif file_extension == "fib":
        writer = vtk.vtkPolyDataWriter()
    elif file_extension == "vtp":
        writer = vtk.vtkXMLPolyDataWriter()
    else:
        raise NotImplementedError()

    writer.SetFileName(file_name)
    writer.SetInputData(polydata)

    if args.binary:
        writer.SetFileTypeToBinary()
    writer.Update()
    writer.Write()

    print("saved")


if __name__ == '__main__':
    main()
