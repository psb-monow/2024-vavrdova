In brief, the script (run_tm_dir.ijm) allows one to run the TrackMate (Tinevez et al., 2017, doi: 10.1016/j.ymeth.2016.09.016) LoG detector algorithm on a series of images in a directory (xyz stacks, .tif or .lsm format) to count in each the number of spots (eg nuclei) in a single channel.
The results (annotated maximum intensity projections and xml tables) are written to a chosen output directory. 
A single run of the TrackMate algorithm can be triggered from **Plugins > Run TM LoGDetector** (to help tweak the settings).

Requirements:
    - TrackMate plugin installed (https://github.com/trackmate-sc/TrackMate)
    - Run_TM_LoG_Detector.py, saved in \Fiji.app\plugins

A test run can be toggled from within the script (test = true). Three-channel test files are provided in repo. The channels contain various amounts of noise.

The output can be read using the R script spot_analysis.R.

Last tested with ImageJ ver. 1.54f.
