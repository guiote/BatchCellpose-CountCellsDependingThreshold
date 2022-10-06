/* July 2022
 *  Elvire Guiot 
 *  guiote@igbmc.fr
 *  Adaptation de la macro "Open.lif_Split&Save" from Erwan Grandgirard  & Bertand Vernay Aout 2019
 * 
 *  
 *  1- Open .lif serie, Split Channel  
 *  2- save as *.*Tiff the first Channel (DAPI channel for nuclei segmentation)
 *  3- save as *.*Tiff the multyichannel images ( considering 2D images , noZstack,  3 or 4 channels)
 *  
 *  
*/ 
macro "SaveImagesToTif[F2]" {

// INITIALISE MACRO
print("\\Clear");
               
run("Bio-Formats Macro Extensions");	//enable macro functions for Bio-formats Plugin
print("select folder with your Data")
dir1 = getDirectory("Choose a Directory");
print("Select the Save Folder")
dir2 = getDirectory("Choose a Directory");
list = getFileList(dir1);
listToProcess= newArray();
setBatchMode(true);
// PROCESS LIF FILES

j=0;
for (i=0; i<list.length; i++) {
						
	test = list[i].contains(".lif");		// don't consider files that doent't end with .lif
		if (test == "true"){
				listToProcess[j]=list[i];     
				j=j+1;
			}
	}

for (i = 0; i < listToProcess.length; i++) {
		processFile(listToProcess[i]);
		
}
}
/// Requires run("Bio-Formats Macro Extensions");
function processFile(fileToProcess){
	path=dir1+fileToProcess;
	Ext.setId(path);
	Ext.getCurrentFile(fileToProcess);
	Ext.getSeriesCount(seriesCount); // this gets the number of series
	print("Processing the file = " + fileToProcess);
	
	for (j=0; j<seriesCount; j++) {
        Ext.setSeries(j);
        Ext.getSeriesName(seriesName);
          if (startsWith(seriesName, "Image")){
		run("Bio-Formats Importer", "open=&path color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j+1); 
		nbChannels = nSlices;
		fileNameWithoutExtension = File.nameWithoutExtension;
		//print(fileNameWithoutExtension);
		run("Split Channels");
		image1= "C1-"+fileNameWithoutExtension+".lif - "+seriesName;
		selectWindow(image1);
		
		saveAs("tiff", dir2+"C1-"+fileNameWithoutExtension+"-"+seriesName+".tif");
		rename("DAPI");
		//print(image1);
		image2="C2-"+fileNameWithoutExtension+".lif - "+seriesName;
		selectWindow(image2);
		//saveAs("tiff", dir2+image2+"_GFP.tif");
		rename("ch2");
		//print(image2);		
		image3= "C3-"+fileNameWithoutExtension+".lif - "+seriesName;
		selectWindow(image3);
		//saveAs("tiff", dir2+image3+"_Cy3.tif");
		rename("ch3");
		//print(image3);	
		if (nbChannels == 4) {
			image4= "C4-"+fileNameWithoutExtension+".lif - "+seriesName;
			selectWindow(image4);
			rename("ch4");
			run("Merge Channels...", "c1=[DAPI] c2=[ch2] c3=[ch3] c4= [ch4]create")
			}
		if (nbChannels == 3 ) run("Merge Channels...", "c1=[DAPI] c2=[ch2] c3=[ch3] create");
		
		
		saveAs("tiff", dir2+fileNameWithoutExtension+"-"+seriesName+".tif");
		run("Close");
	}
  }
}


