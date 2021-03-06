# White Matter and Diffusion Metrics Pipeline
Singularity image basic documentation. Alexandre Pastor-Bernier 26 Jan 2022 (McGill University)
########################################################################################
                                
**# Original slicer recipe provided by Lex Hutton (10 Dec 2021)**                                                                                                        
wma_slicer
https://github.com/hayabusapb/wma_qc/blob/Singularity/wma_slicer                                                                                                                                            

Performance:

Fails when running within singularity in cluster sessions but succeds running in local builds.
Errors concern dynamic library links in QT-loadable module -QT-gui framework and NA-MIC modules (even running Slicer with xvfb-run which solves x-server connection probs.).  Slicer can work disabling selective modules (CLI), but those are required for  wma harden transform step.                                                                                                                        
             
e.g
QStandardPaths: error creating runtime directory /run/user/3115426 (No such file or directory) /Slicer/lib/Slicer-4.11/qt-loadable-modules/vtkSlicerCropVolumeModuleLogicPython.so: failed to map .


#A case was open in slicer community:
https://discourse.slicer.org/t/using-slicer-from-command-line-singularity-container/21035

Steve Pieper recommended using
X-term and strace to look at Slicer readouts:                                                                                                                                                            
** slicer does not set paths for qt-loadable modules right from the recipe (LD_LIBRARY_PATH). It attempts to write in a usr-local-conf file but has no permissions to write to singularity root. 
We cannot do ldconfig (ld.so.config) post-hoc on a frozen image and fix links to dynamic libraries.
                                                                                                        
WORKAROUND: Decided to work on singularity sandbox version instead
                                                                                                                                    
Sandbox is a better option than building non-editable .sif images iteratively for debugging purposes, because changes can be done on the run. Otherwise have to build from image and globus sync each time to destination for testing. Building from sandbox from within Beluga is not advised (sudo privileges revoked). The image is minimum 700MBs, our current is 2GB which is manageable. The working container can be frozen as a normal .sif files --                                                             
**19 Dec 2021 - Sandbox recipe approach based on a working build of Slicer: Docker image** 

Slicer Built image based on Iassons (Andras Lasso, Queens U.)
runs Slicer 4.11.0 (11-2020 version) from within container and works both within container in cluster and in local.
Specs:

Linux Bulleye 11.2
Python 3.9.5
Jupyter Notebook support

Iassons https://github.com/Slicer/SlicerJupyter
                                                                              
https://hub.docker.com/r/slicer/slicer-notebook

The procedure followed was : importing the docker image into singularity and convert it to sandbox
https://sylabs.io/guides/2.6/user-guide/singularity_and_docker.html
                                                                                                                    
From sandbox:
Added miniconda support, wmatteranalysis libraries (py),  Dipy (for trk2vtk conversion), Slicer DMRI extensions. Added miscellaneous sh and py libraries  to run the pipe and incremental attempts of parallelization (xvfb-run-safe.sh, trk2vtk.py trk2vtk_sll.py)


Details on Slicer Built:
                                                                                                          
* Slicer 4.11.0 is used in harden transformed fiber clusters back into the input tractography space and
SlicerDMRI is used further for diffusion measurements ??? but those do not apply here since our file comes from Tractoflow and does not store diffusion information in the trk or converted vtk input file.
--there are no diffusion measurements stored in the input files ---  The wma diffusionmeasuremnts tool was developed for the case when the tractography is run with a tool like ukftractography from Yogesh Rathi, which stores diffusion information in vtk file.

UPDATES 7Mar2022: 
3DSlicer above version 4.10 loads Models by default as LPS. This causes problems on the inverse transform step because Slicer assumes LPS when it should take the file as RAS. A short-term work around is to use an older build of Slicer 4.10.2 and build it in the container.
A long-term approach (not done yet) is to upgrade the wma libraries which are called in the pipe with # 3D Slicer output. SPACE=RAS # embedding in the header. That applies to created vtp files, whose header in xml can be changed by adding the following lines:
?? ?? <FieldData>
  ?? ?? <Array type="String" Name="SPACE" NumberOfTuples="1" format="ascii">
?? ?? ?? ?? 82 65 83 0
?? ?? ?? </Array>
?? ?? </FieldData>
 
The most recent image is SJN_7M22.sif which incorporates a build of the older slicer version 4.10.2, loads correctly as RAS.

UPDATES 25May2022
SJN_25M22.sif This image incorporates Diffusion Measure libraries, that run after ODonnell's segmentation:
              Ofer Pasternak Free Water analysis scripts (MIT License 2022)
              Pyradiomics libraries
              https://pyradiomics.readthedocs.io/en/latest/
