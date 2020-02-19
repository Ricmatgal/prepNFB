# prepNFB
This is a Matlab based tool to prepare for and coregister between OpenNFT Neurofeedback session(s).<br/> 

The tool aims to simplify and automatize the pre NFB steps needed to setup a neurofeedback run. The architecture is such that the different modules are launched from one main user interface which is fully adaptable to accomodate any NFB experiment individually. When properly setup, one can run and analyze a functional localizer task within the same scanning session as the first neurofeedback training. As such, regions of interest can be delineated and prepared while the participant is waiting in the scanner for the first NFB run. Furthermore, it allows the user to coregister the ROIs between NFB sessions and to project the coregistration results onto the relevant EPI or structural images.
It is a combination of my own code as well as a few adapted SPM functions.<br/>
<br/>
Several modules are available:
1) Region of interest tool<br/>
  A) Automated analyses of functional localizer data<br/> 
  B) ROI delineation tool based on SPM contrasts with visualizations<br/>
2) Automated Motion Correction template creation<br/> 
3) Autmoated .ini file creation<br/>
4) Running PTB experiments and creating experiments parameters<br/>
5) Session to session coregistration with visualization<br/>
   A) based on structural scans<br/>
   B) based on epi scans<br/>

Dependencies: SPM12 

The GUI is build with guide from matlab

![Overview of prepNFB tool ](https://github.com/lucp88/prepNFB/raw/master/Others/all_features_prepNFB.PNG)
