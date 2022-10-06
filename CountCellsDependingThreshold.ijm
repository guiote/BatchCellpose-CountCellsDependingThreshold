var ImageID;
var nbChannels;
var DAPIcells;
var GreenCells;
var GreenThr;
var RedCells;
var RedThr;
var GreenRedCells;
var GreenRedThr;
var dirPath;		
var	BaseName;
var count;
var IntCh2 = newArray (count);
var IntCh3 = newArray (count);
var Ch2Thr;
var Ch3Thr;
var Ch2CellPositive;
var Ch3CellPositive;
var Ch2Ch3CellPositive;
//var newCountCh2 =0;
//var newCountCh3 = 0;

macro "Load ROIlist Measure and Plot[1]"{

	roiManager("reset");
	selectWindow("ROI Manager");
	run("Close");
	while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      	} 
      	
	print("\\Clear");
	selectWindow("Log");
	run("Close");

run("Set Measurements...", "mean stack redirect=None decimal=0");

// open image and load the ROI list
	open();										/* ouvre la premi?re image Ch1*/
	dirPath = File.directory;			/*recup pathway*/
	ImageName = getTitle();
	BaseName	= substring(ImageName, 0, lastIndexOf(ImageName, ".tif")); 
	ROIlist = "C1-"+ BaseName + "ROI.zip";
	roiManager("open", ROIlist);
	roiManager("show all without labels");

	ImageID= getImageID();
	selectImage(ImageID);
	getDimensions(width, height, channels, slices, frames);
	nbChannels = slices;
	//run("Brightness/Contrast...");
	//run("Enhance Contrast", "saturated=0.35");
	Table.create("IntensityValues");
	
	
	/* remove all ROI in contact with image border */
		count = roiManager('count');
		compteur = 0;
		
		for (i = 0; i < count; i++) {
			
			roiManager("select", i);
			Roi.getCoordinates(xpoints, ypoints);
			test = borderTest (xpoints, 0);
			if (test == true) {
				compteur = compteur+1;
				roiManager("rename", "bord");
				roiManager("Set Fill Color", "red");
				}
			test = borderTest (xpoints, width-1);
			if (test == true) {
				compteur = compteur+1;
				roiManager("rename", "bord");
				roiManager("Set Fill Color", "red");
			}
			test = borderTest (ypoints, 0);
			if (test == true) {
				compteur = compteur+1;
				roiManager("rename", "bord");
				roiManager("Set Fill Color", "red");
			}
			test = borderTest (ypoints, height-1);
			if (test == true) {
				compteur = compteur+1;
				roiManager("rename", "bord");
				roiManager("Set Fill Color", "red");
			}
			
		}
		roiManager("Sort");
		borderCell = newArray(compteur);
		for (k = 0; k < compteur; k++) {
		borderCell [k] = count - compteur + k;
		}
		roiManager("select", borderCell );
		roiManager("delete");
	/*_________________________________________________________________*/		
	
	run("Channels Tool...");

	Stack.setDisplayMode("color");
	
	setSlice(1);
	run("Enhance Contrast", "saturated=0.35");
	
	setSlice(2);
	run("Enhance Contrast", "saturated=0.35");
		
	setSlice(3);
	run("Enhance Contrast", "saturated=0.35");
	
	setSlice(2);
	roiManager("Select All");
	roiManager("multi-measure");

	Plot.create("Cell Intensity in the Channel2", "x", "Mean");
	Plot.add("Circle", Table.getColumn("Mean", "Results"));
	Plot.setStyle(0, "green,green,1.0,Circle");
	Plot.show();
	
	IntCh2 = Table.getColumn("Mean", "Results");
	Table.setColumn("IntCh2", IntCh2,"IntensityValues")  ;
	Table.update;
	close ("Results");
	
	selectImage(ImageID);
	setSlice(3);
	roiManager("Select All");
	roiManager("multi-measure");

	Plot.create("Cell Intensity in the Channel3", "x", "Mean");
	Plot.add("Circle", Table.getColumn("Mean", "Results"));
	Plot.setStyle(0, "Red,Red,1.0,Circle");
	Plot.show();
	IntCh3 = Table.getColumn("Mean", "Results");
	Table.setColumn("IntCh3", IntCh3,"IntensityValues")  ;
	Table.update;
	close ("Results");

/*	if (nbChannels >3 ){
	selectImage(ImageID);
	setSlice(4);
	roiManager("Select All");
	roiManager("multi-measure append");

	Plot.create("Cell Intensity in the FarRed Channel", "x", "Mean");
	Plot.add("Circle", Table.getColumn("Mean", "Results"));
	Plot.setStyle(0, "Grey,Grey,1.0,Circle");
	Plot.show();
	close ("Results");

		}*/
	run("Cascade");
	setTool("hand");
	TablePath = dirPath + "IntensityValues_" + BaseName+".txt";
	Table.save(TablePath);
	}


macro "Count Green cells [2]"{
	
	selectImage(ImageID);
	count = roiManager('count');

	roiManager("Select All");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
  //   roiManager('update');
     roiManager("Show All");    	//remet toute les roi jaunes pour reset si on relance la mesure
     		
			Ch2CellPositive = 0;
			listROIch2pos = newArray(count);
		
			 waitForUser("Determine the threshold for Ch2");
			
			 Dialog.create("Find ROI > Ch2 threshold");							//set an intensity threshold to change the ROi color
		 	//Dialog.addChoice("Colorize ROIs by", parameters, "Mean");
		  Dialog.addNumber("Thr",1000);
		  Dialog.show();
		  //parameter = Dialog.getChoice();
		 			 Ch2Thr = Dialog.getNumber();
 
			for (i = 0; i < count; i++) {
			    if (IntCh2[i] > Ch2Thr) {
			    	listROIch2pos[i]= i;
			    	Ch2CellPositive= Ch2CellPositive +1;
			    	}
			    }
			   	 roiManager("select", listROIch2pos);
			    	roiManager("Set Color", "green");
				roiManager("Set Line Width", 2);
			     	 roiManager('update');
			
			selectImage(ImageID);
			setSlice(2);
			roiManager("show all");
			//newCountCh2 = newCountCh2 +1;
			print("Number of nuclei =:", count);
			print("Ch2 Threshold = ", Ch2Thr, "PositiveCells in the Ch2 =", Ch2CellPositive );
}


macro "Count Red cells [3]"{
			
			selectImage(ImageID);
			ChannelToMeasure = 3;
			setSlice(ChannelToMeasure);
			
				count = roiManager('count');
				//if (newCountCh3 !=0) {
				roiManager("Select All");
				roiManager("Set Color", "yellow");
				roiManager("Set Line Width", 2);
			    //  roiManager('update');
			      roiManager("Show All");    	
			     // }
			     	 
			
				Ch3CellPositive = 0;
				listROIch3pos = newArray(count);
			
				 waitForUser("Determine the threshold for Ch3");
				
				 Dialog.create("Find ROI > Ch3 threshold");							//set an intensity threshold to change the ROi color
			 	//Dialog.addChoice("Colorize ROIs by", parameters, "Mean");&
			  Dialog.addNumber("Thr",2500);
			  Dialog.show();
			  //parameter = Dialog.getChoice();
			  Ch3Thr = Dialog.getNumber();
			 
			for (i = 0; i < count; i++) {
			    if (IntCh3[i] > Ch3Thr) {
			    	listROIch3pos[i]= i;
			    	Ch3CellPositive= Ch3CellPositive +1;
			    	}
			    }
			   	 roiManager("select", listROIch3pos);
			    	roiManager("Set Color", "Red");
				roiManager("Set Line Width", 2);
			     	 roiManager('update');
			
			selectImage(ImageID);
			setSlice(ChannelToMeasure);
			//newCountCh3 = newCountCh3 +1;
			//print("\\Clear");
			print("Number of nuclei =:", count);
			print("Ch2 Threshold = ", Ch2Thr, "PositiveCells in the Ch2 =", Ch2CellPositive );
			print("Ch3 Threshold = ", Ch3Thr,"PositiveCells in the Ch3 =", Ch3CellPositive );
}


macro "Count GreenRed cells [5]"{

selectImage(ImageID);

 Ch2Ch3CellPositive =0;
 count = roiManager('count');
 listROIch2ch3pos = newArray(count);

 for (i = 0; i < count; i++) {
			    if ((IntCh3[i] > Ch3Thr)&(IntCh2[i]> Ch2Thr)) {
			    	listROIch2ch3pos[i]= i;
			    	 Ch2Ch3CellPositive=  Ch2Ch3CellPositive +1;
			    	}
			    }
			   	 roiManager("select", listROIch2ch3pos);
			    	roiManager("Set Color", "pink");
				roiManager("Set Line Width", 2);
			     	 roiManager('update');
			     	 
			print("\\Clear");
 			print("Number of nuclei =:", count);
			print("Ch2 Threshold = ", Ch2Thr, "PositiveCells in the Ch2 =", Ch2CellPositive );
			print("Ch3 Threshold = ", Ch3Thr,"PositiveCells in the Ch3 =", Ch3CellPositive );
			print("Number of cells Positive in Ch2 And Ch3: ", Ch2Ch3CellPositive);
			resName = dirPath + "Cell_Counts_" + BaseName+".txt";
			selectWindow("Log");
			saveAs("Text", resName);
	
	}

/*______________________________________________________________________*/
	
/*   fonctions */
function borderTest ( array, value) {
    for (i=0; i<array.length; i++) 
        if (array[i] == value )  return true;
    return false;
}
  