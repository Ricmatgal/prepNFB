# prepNFB
This is a Matlab based tool to prepare for and coregister between OpenNFT Neurofeedback session(s).<br/> 

The tool aims to simplify and automatize the pre NFB steps needed to setup an OpenNFT based neurofeedback session. The architecture is such that the different modules are launched from one main user interface which is fully adaptable to accomodate any NFB experiment individually. When properly setup, one can run and analyze a functional localizer task within the same scanning session as the first neurofeedback training. As such, regions of interest can be delineated and prepared while the participant is waiting in the scanner for the first NFB run. Furthermore, it allows the user to coregister the ROIs between NFB sessions and to project the coregistration results onto the relevant EPI or structural images for quality control.
It is a combination of my own code as well as a few adapted SPM functions.<br/>
<br/>
Several modules are available:
1) Region of interest tool<br/>
  A) Automated and flexible analyses of functional localizer data<br/> 
  B) ROI delineation tool based on SPM contrasts with visualizations<br/>
2) Automated Motion Correction template creation based on for instance resting state acquisition<br/> 
3) Autmoated .ini file creation<br/>
4) Running PTB experiments and creating experiments parameters<br/>
5) Session to session coregistration with visualization<br/>
   A) based on structural scans<br/>
   B) based on epi scans<br/>
6) OpenNFT protocol tool that allows for:<br/>
   A) Flexible creation and visualization of a NFB protocol that is the user can then save as a .json file<br/>
   B) Loading and subsequent eddititing of pre-exisiting .json protocol file<br/>
   

Dependencies: SPM12, JSONLab

Works best on Windows (some small adjustments have to be implemented to make in macOS compatible)

The GUI is build with guide from matlab. While guide generated code can apear messy, changing and adding elements and routines to the interface is more efficient and accesible. For all SPM based computations the generic spm_jobman(matlabbatch, 'run') structure is maintained. 

To run the toolbox:
1) Call the main interface from the Matlab command window by typing prep_NFB<br/> 
2) In the main GUI:<br/>
    a) Specify the project folder: directory to the NFB project where OpenNFT will expect the subject specific folder strutcure<br/>
    b) The watch folder: directory where the MRI images will arrive (e.g. dummy data folder)<br/>
3) Initialize a subject (e.g. 01) which will create a subject folder structure in the project folder<br/>
    a) Put the SPM_onset file (prepNFB/example_session/NFB_project) inside the subject folder<br/>
        (e.g. prepNFB/example_session/NFB_project/01/Localizer/beh)<br/>
4) Unzip the example data in: example_data/rtData<br/>

![Overview of prepNFB tool ](https://github.com/lucp88/prepNFB/raw/master/Others/all_features_prepNFB_2.PNG)

![Protocol Manager](https://github.com/lucp88/prepNFB/raw/master/Others/PRT_manager.PNG)
