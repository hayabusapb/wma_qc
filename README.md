# wma_pipeline
SJN22.sif  basic documentation. Alexandre Pastor-Bernier 26 Jan 2022 (McGill University)
########################################################################################
                                
**# Original slicer recipe based on Lex (10 Dec 2021)**                                                                                                        
wma_slicer
https://github.com/hayabusapb/wma_qc/blob/Singularity/wma_slicer                                                                                                                                            

Performance:

Fails when running within singularity in cluster sessions but succeds running in local builds.
Errors concern dynamic library links in QT-loadable module -QT-gui framework and NA-MIC modules (even running Slicer with xvfb-run which solves x-server connection probs.).  Slicer can work disabling selective modules (CLI), but those are required for  wma harden transform step.                                                                                                                        
             
e.g
QStandardPaths: error creating runtime directory /run/user/3115426 (No such file or directory) /Slicer/lib/Slicer-4.11/qt-loadable-modules/vtkSlicerCropVolumeModuleLogicPython.so: failed to map .


#A case was open in slicer community:
https://discourse.slicer.org/t/using-slicer-from-command-line-singularity-container/21035

STeve Pieper recommended using
X-term and strace to look at Slicer readouts:                                                                                                                                                            
** slicer does not set paths for qt-loadable modules right from the recipe (LD_LIBRARY_PATH). It attempts to write in a usr-local-conf file but has no permissions to write to singularity root. 
We cannot do ldconfig (ld.so.config) post-hoc on a frozen image and fix links to dynamic libraries.
                                                                                                        
WORKAROUND: Decided to work on singularity sandbox version instead
                                                                                                                                    
Sandbox is a better option than building non-editable .sif images iteratively for debugging purposes, because changes can be done on the run. Otherwise have to build from image and globus sync each time to destination for testing. Building from sandbox from within Beluga is not advised (sudo privileges revoked). The image is minimum 700MBs, our current is 2GB which is manageable. The working container can be frozen as a normal .sif files --                                                             
**Sandbox recipe based on Docker image** 

SlicerBuilt image based on Iassons (Andras Lasso, Queens U.)
runs Slicer 4.11.0 (11-2020 version) from within container and works both within container in cluster and in local.
Specs:

Linux Bulleye 11.2
Python 3.9.5
Jupyter Notebook support

Iassons https://github.com/Slicer/SlicerJupyter
                                                                              
https://hub.docker.com/r/slicer/slicer-notebook

The procedure followed was : importing the docker image into singularity and build it as sandbox
https://sylabs.io/guides/2.6/user-guide/singularity_and_docker.html
                                                                                                                    
From sandbox:
Added miniconda support, wmatteranalysis libraries (py),  Dipy (for trk2vtk conversion), Slicer DMRI extensions. Added miscellaneous sh and py libraries  to run the pipe and attempt of parallelization (xvfb-run-safe.sh, trk2vtk.py trk2vtk_sll.py)


Details on Slicer Built:
                                                                                                          
* Slicer 4.11.0 is used in harden transformed fiber clusters back into the input tractography space and
SlicerDMRI is used further for diffusion measurements – but those do not apply here since our file comes from Tractoflow.
--there are no diffusion measurements stored in the input files ---  The wma diffusionmeasuremnts tool was developed for the case when the tractography is run with a tool like ukftractography from Yogesh Rathi, which stores diffusion information in the vtk file.
