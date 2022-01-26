#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  2 09:17:51 2021

@author: Alexandre Pastor -- hayabusa
"""

# HEADER OF TRK FILE SEEMS INCOMPATIBLE . . . WHY 

import os
import vtk
from dipy.tracking.streamline import Streamlines
from dipy.io.streamline import load_tractogram

path = os.getcwd()
#os.chdir(os.path.dirname(os.path.abspath(__file__)))
fname= 'sub3602428_copy/ses-2/PFT_Tracking/sub-3602428_ses-2__pft_tracking_prob_wm_seed_0.trk'
absolutepath = os.path.join(path,fname)
atlas = 'Documents/WMA_tutorial_data/ORG-Atlases-1.1.1/ORG-RegAtlas-100HCP/registration_atlas.vtk'

seed = 'sub3602428_copy/ses-2/PFT_Seeding_Mask/sub-3602428_ses-2__pft_seeding_mask.nii'
#load_trk needs 2 arg, positional atlas and file?
streams, hdr = load_tractogram(fname,'same')
streamlines = Streamlines(streams)
saveStreamlinesVTK(streamlines,'sub-3602428.vtk')

def saveStreamlinesVTK(streamlines, pStreamlines):
    polydata = vtk.vtkPolyData()

    lines = vtk.vtkCellArray()
    points = vtk.vtkPoints()
    
    ptCtr = 0
       
    for i in range(0,len(streamlines)):
        if((i % 10000) == 0):
                print(str(i) + '/' + str(len(streamlines)))
        
        
        line = vtk.vtkLine()
        line.GetPointIds().SetNumberOfIds(len(streamlines[i]))
        for j in range(0,len(streamlines[i])):
            points.InsertNextPoint(streamlines[i][j])
            linePts = line.GetPointIds()
            linePts.SetId(j,ptCtr)
            
            ptCtr += 1
            
        lines.InsertNextCell(line)
                               
    polydata.SetLines(lines)
    polydata.SetPoints(points)
    
    writer = vtk.vtkPolyDataWriter()
    writer.SetFileName(pStreamlines)
    writer.SetInputData(polydata)
    writer.Write()
    
    print('Wrote streamlines to ' + writer.GetFileName())


#--
#Dr. rer. nat. Nico Hoffmann
#Computational Radiation Physics
