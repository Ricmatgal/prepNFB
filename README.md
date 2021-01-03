# prepNFB
This is a Matlab based toolbox to prepare for and coregister between OpenNFT Neurofeedback session(s).<br/> 

OpenNFT website:  www.OpenNFT.org <br/> 
OpenNFT GitHub:   https://github.com/OpenNFT/OpenNFT

The prepNFB toolbox aims to simplify and automatize (some of) the pre NFB steps needed to setup an OpenNFT based neurofeedback session. The architecture is such that the different modules are launched from one main user interface which is fully adaptable to accomodate any NFB experiment individually. When properly setup, one can run and analyze a functional localizer task within the same scanning session as the first neurofeedback training. As such, regions of interest can be delineated and prepared while the participant is waiting in the scanner for the first NFB run. Furthermore, it allows the user to coregister the ROIs between NFB sessions and to project the coregistration results onto the relevant EPI or structural images for visual quality assessment.
It is a combination of my own code as well as a few adapted SPM functions.<br/>
As it's a work in progress more functionalities are planned for the future. If you have ideas, would like to contribute or have any questions about the toolbox or how to set it up, please contact me at: <br/><br/> lucaspeek@live.nl<br/> 
<br/>
Several modules are available:
1) Region of interest tool<br/>
  A) Automated and flexible analyses of functional localizer data<br/> 
  B) ROI delineation tool based on SPM contrasts with visualizations<br/>
2) Automated Motion Correction template creation based on for instance resting state acquisition<br/> 
3) Autmoated .ini file creation</b><br/>
4) Running PTB experiments and creating experiments parameters<br/>
5) Session to session coregistration with visualization</b><br/>
   A) based on structural scans<br/>
   B) based on epi scans<br/>
6) OpenNFT protocol tool that allows for:<br/>
   A) Flexible creation and visualization of a NFB protocol that is the user can then save as a .json file<br/>
   B) Loading and subsequent eddititing of pre-exisiting .json protocol file<br/>
   

Dependencies: SPM12, JSONLab

Works best on Windows (some small adjustments have to be implemented to make in macOS compatible)

The GUI is build with guide from matlab. While guide generated code can apear messy, changing and adding elements and routines to the interface is more efficient and accesible. For all SPM based computations the generic spm_jobman(matlabbatch, 'run') structure is maintained. 

To run the toolbox with example_session data: <br/>
1) Unzip the example data in: <b>'...\prepNFB-master\example_session\rtData'</b> <br/>
2) Open Matlab and set current working directory to: prepNFB-master<br/>
3) Call the main interface from the Matlab command window by typing <i>'prep_NFB'</i><br/> 
4) In the main GUI:<br/>
    a) Specify the project folder: <b>'...\prepNFB-master\example_session\NFB_Project'</b><br/>
       <i>This is the directory of the NFB project where OpenNFT will expect the subject specific folder strutcure</i><br/>
    b) The watch folder: <b>'...\prepNFB-master\example_session\rtData\rtMRdata_sess1'</b><br/>
       <i>This is directory where the MRI images will or have arrive(d) (e.g. rtData folder)</i><br/>
    c) Save settings<br/>
5) Initialize a subject (e.g. 01) which will create a subject folder structure in the project folder<br/>
    a) Put the SPM_onset file <b>(prepNFB/example_session/NFB_project)</b> inside the subject folder:<br/>
        <b>(prepNFB/example_session/NFB_project/01/Localizer/beh)</b><br/>
        <i>When the toolbox is properly set up the onset file will be automatically created in this directory</i><br/>
6) Use the dcm series numbers specified in the txt file 'dcm_sequences.txt' in the rtData folder<br/>
   to direct the toolbox to the right images for each step

<b>Overview prepNFB tool</b>
![Overview of prepNFB tool ](https://github.com/lucp88/prepNFB/raw/master/Others/all_features_prepNFB_2.PNG)
<i>Screenshot of the main interface and the different modules available</i>

https://youtu.be/bswgG1_mOtE

<b>Protocol Manager</b>
![Protocol Manager](https://github.com/lucp88/prepNFB/raw/master/Others/PRT_manager.PNG)<br/>
<i>The protocol manager where users can load and adjust or create a new OpenNFT neurfeedback protocol and save it as a .json file</i>
