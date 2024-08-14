'''
Author: 	madur (madur@psb.vib-ugent.be)
Modified:	2024-08-09
Requires:
	-	TrackMate (Plug-in, https://github.com/trackmate-sc/TrackMate)
Description:
	Runs the TrackMate (Tinevez et al., 2017, doi: 10.1016/j.ymeth.2016.09.016) LoG detector algorithm once with the parameters provided. 
    The result are shown on screen and the results table is saved (.xml).
	
	This script is based on the scripts found in the TrackMate documentation: https://imagej.net/plugins/trackmate/
'''


#------------------------
# I/O
#------------------------
#@ String (label = 'File to process') file_name
#@ String (label = 'Output directory path') output_dir

#------------------------
# Pass detector settings
#------------------------
#@ Boolean (label = 'Subpixel localization') spl
#@ Float (label = 'Radius') radius
#@ Integer (label = 'Channel to use') channel
#@ Float (label = 'Threshold') threshold
#@ Boolean (label = 'Median filtering') mf

#------------------------
# Dependencies
#------------------------
import sys

from ij import WindowManager

from java.io import File

from fiji.plugin.trackmate import Model, Settings, TrackMate, SelectionModel, Logger
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettings
from fiji.plugin.trackmate.io import TmXmlWriter
from fiji.plugin.trackmate.detection import LogDetectorFactory
from fiji.plugin.trackmate.tracking.jaqaman import SparseLAPTrackerFactory
from fiji.plugin.trackmate.visualization.hyperstack import HyperStackDisplayer

#------------------------
# Run on current image
#------------------------

imp = WindowManager.getCurrentImage()

model = Model()
 
settings = Settings(imp)
 
# Configure detector
settings.detectorFactory = LogDetectorFactory()
settings.detectorSettings = {
    'DO_SUBPIXEL_LOCALIZATION' : spl,
    'RADIUS' : radius,
    'TARGET_CHANNEL' : channel,
    'THRESHOLD' : threshold,
    'DO_MEDIAN_FILTERING' : mf,
}

# Configure tracker
settings.trackerFactory = SparseLAPTrackerFactory()
settings.trackerSettings = settings.trackerFactory.getDefaultSettings()

settings.addAllAnalyzers()
trackmate = TrackMate(model, settings)

# Check
ok = trackmate.checkInput()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))
 
ok = trackmate.process()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))


# Display
selectionModel = SelectionModel( model )
 
# Read the default display settings.
ds = DisplaySettings.defaultStyle()
 
displayer = HyperStackDisplayer( model, selectionModel, imp, ds )
displayer.render()
displayer.refresh()

#----------------
# Write results
#----------------

print( "Writing results for " + file_name ) 
f = File( output_dir + '/' + file_name[: -4] + '.xml' ) # Replace last 4 characters
xml_writer = TmXmlWriter( f )

xml_writer.appendModel( model )
xml_writer.appendSettings( settings )
xml_writer.writeToFile()