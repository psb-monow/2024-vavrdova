/*
Author: 	madur (madur@psb.vib-ugent.be)
Modified:	2024-08-09
Requires:	
	-	TrackMate (Plug-in, https://github.com/trackmate-sc/TrackMate)
	-	Run_TM_LoG_Detector.py (Plug-in, this repo) (saved in \Fiji.app\plugins)
Description:
	Applies the TrackMate (Tinevez et al., 2017, doi: 10.1016/j.ymeth.2016.09.016) LoG detector algorithm on a series of images in a directory (xyz stacks, .tif or .lsm format) to count in each the number of spherical objects (eg nuclei) in a single channel.
	The results (annotated maximum intensity projections and xml tables) are written to a chosen output directory. 
*/

test = true; // test the macro as a whole, for a single test for detector settings call the plugin 'Run TM LoG Detector' directly

if (test) {
	input_dir = "Insert path to test data folder";
	output_dir = "Insert path to test data folder";
	channel = 2;
	file_type = ".lsm";
	adjust = false;
}
else {
	Dialog.create("Choose Parameters");
	Dialog.addDirectory("Input directory", "");
	Dialog.addChoice("Files to process:", newArray(".lsm", ".tif"));
	Dialog.addDirectory("Output directory", "");
	Dialog.addNumber("Channel to use", 1);
	Dialog.addCheckbox("Auto-adjust image", false);
	Dialog.show();
	input_dir = Dialog.getString();
	file_type = Dialog.getChoice();
	output_dir = Dialog.getString();
	channel = Dialog.getNumber();
}

// detector settings
Dialog.create("Choose Parameters for LoG Detector");
Dialog.addCheckbox("Subpixel-localization", true);
Dialog.addNumber("Radius", 3.0, 1, 3, "micron");
Dialog.addNumber("Threshold", 1.0);
Dialog.addCheckbox("Apply median filter", false);
Dialog.show();
spl = Dialog.getCheckbox();
radius = Dialog.getNumber();
threshold = Dialog.getNumber();
mf = Dialog.getCheckbox();

files = getFileList(input_dir);

// logging
start_time_ms = getTime();

// echo settings
print("Processing files in " + input_dir);
print("Applying TM LoG detector with settings");
print("- Radius:", radius, " micron");
print("- Threshold:", threshold);
if(spl) print("- Subpixel-localization enabled");
if(mf) print("- Median filter applied");

// do for each file
for(ii = 0; ii < files.length; ii++) {
	if(endsWith(files[ii], file_type)) {
		print("Processing " + files[ii]);
		open(input_dir + '/' + files[ii]);
		run("Duplicate...", "duplicate channels=" + channel);
		close(files[ii]);
		if(nSlices > 1) {
			run("Z Project...", "projection=[Max Intensity]");
		}
		run("Grays");

		// adjust the image if required
		if(adjust) {
			getStatistics(area, mean, min, max, std, histogram);
			setMinAndMax(0, max); // rescale based on maximum value
			run("Apply LUT"); // set the values
			resetMinAndMax(); // reset the image for viewing
		}

		image_name = substring(files[ii], 0, lengthOf(files[ii]) -4);
		temp1 = image_name + "_max";
		rename(temp1);
		// saveAs("Tiff", output_dir + "/" + temp1 + ".tif"); // save intermediary files if required
		run("Run TM LoG Detector", "file_name="+ files[ii] + " output_dir=" + output_dir + " spl=" + spl + "radius=" + radius + " channel=" + 1 + " threshold=" + threshold + " mf=" + mf);
		run("RGB Color"); // make same type of combining later
		run("Flatten");
		temp2 = temp1 + "_detections";
		rename(temp2);		
		// saveAs("Tiff", output_dir + "/" + temp2 + ".tif"); // save intermediary files if required
		run("Combine...", "stack1=" + temp1 +  " stack2=" + temp2); // show original and result side by side
		saveAs("Tiff", output_dir + "/" + image_name + "_tm.tif");
		close("*");	
	}
}

end_time_ms = getTime();
print("Done");
print("Results written to " + output_dir);
print("Execution time: " + (end_time_ms - start_time_ms)/1000 + " s");