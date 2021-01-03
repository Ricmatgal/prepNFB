# prepNFB
This is a Matlab based toolbox to prepare for and coregister between [OpenNFT](https://github.com/OpenNFT/OpenNFT "Named link title") Neurofeedback session(s).<br/> 

The prepNFB toolbox aims to simplify and automatize (some of) the pre NFB steps needed to setup an OpenNFT based neurofeedback session. The architecture is such that the different modules are launched from one main user interface which is fully adaptable to accomodate any NFB experiment individually. When properly setup, one can run and analyze a functional localizer task within the same scanning session as the first neurofeedback training. As such, regions of interest can be delineated and prepared while the participant is waiting in the scanner for the first NFB run. Furthermore, it allows the user to coregister the ROIs between NFB sessions and to project the coregistration results onto the relevant EPI or structural images for visual quality assessment.
It is a combination of my own code as well as a few adapted SPM functions.<br/>
As it's a work in progress more functionalities are planned for the future. If you have ideas, would like to contribute or have any questions about the toolbox or how to set it up, please contact me at: <br/><br/> lucaspeek@live.nl<br/> 

For more information on [OpenNFT](https://github.com/OpenNFT/OpenNFT "Named link title") please visit:
* [OpenNFT website](http://www.OpenNFT.org "Named link title") 
* [OpenNFT GitHub](https://github.com/OpenNFT/OpenNFT "Named link title") 

### prepNFB toolbox

Several modules are are currently implemented:<br/>
1) Region of interest tool<br/>
   * Automated and flexible analyses of functional localizer data<br/> 
   * ROI delineation tool based on SPM contrasts with visualizations<br/>
2) Automated Motion Correction template creation based on for instance resting state acquisition<br/> 
3) Automated .ini file creation</b><br/>
4) Running PTB experiments and creating experiments parameters<br/>
5) Session to session coregistration with visualization</b><br/>
   * based on structural scans<br/>
   * based on epi scans<br/>
6) OpenNFT protocol tool that allows for:<br/>
   * Flexible creation and visualization of a NFB protocol that the user can then save as a .json file<br/>
   * Loading and subsequent eddititing of pre-exisiting .json protocol file<br/>
   

Dependencies: SPM12, JSONLab

Works best on Windows (some small adjustments have to be implemented to make in macOS compatible)

The GUI is build with guide from matlab. While guide generated code can apear messy, changing and adding elements and routines to the interface is more efficient and accesible. For all SPM based computations the generic spm_jobman(matlabbatch, 'run') structure is maintained. 

To run the toolbox with example_session data: <br/>
1) Unzip the example data in: <b>'...\prepNFB-master\example_session\rtData'</b> <br/>
2) Open Matlab and set current working directory to: prepNFB-master<br/>
3) Call the main interface from the Matlab command window by typing <i>'prep_NFB'</i><br/> 
4) In the main GUI:<br/>
    * Specify the project folder: <b>'...\prepNFB-master\example_session\NFB_Project'</b><br/>
       <i>This is the directory of the NFB project where OpenNFT will expect the subject specific folder strutcure</i><br/>
    * The watch folder: <b>'...\prepNFB-master\example_session\rtData\rtMRdata_sess1'</b><br/>
       <i>This is directory where the MRI images will or have arrive(d) (e.g. rtData folder)</i><br/>
    * Save settings<br/>
5) Initialize a subject (e.g. 01) which will create a subject folder structure in the project folder<br/>
    * Put the SPM_onset file <b>(prepNFB/example_session/NFB_project)</b> inside the subject folder:<br/>
        <b>(prepNFB/example_session/NFB_project/01/Localizer/beh)</b><br/>
        <i>When the toolbox is properly set up the onset file will be automatically created in this directory</i><br/>
6) Use the dcm series numbers specified in the txt file 'dcm_sequences.txt' in the rtData folder<br/>
   to direct the toolbox to the right images for each step

<b>Some examples:</b>
* Region of Interest Delineation using prepNFB: [Short Demo (YouTube)](https://youtu.be/bswgG1_mOtE "Named link title")<br/>
* <b>Overview prepNFB tool</b><br/>
<i>Screenshot of the main interface and the different modules available</i>
</b>![Overview of prepNFB tool ](https://github.com/lucp88/prepNFB/raw/master/Others/all_features_prepNFB_2.PNG)

* <b>Protocol Manager</b><br/>
<i>The protocol manager where users can load and adjust or create a new OpenNFT neurfeedback protocol and save it as a .json file</i><br/>
![Protocol Manager](https://github.com/lucp88/prepNFB/raw/master/Others/PRT_manager.PNG)<br/>

