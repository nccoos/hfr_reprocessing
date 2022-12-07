#!/usr/bin/perl
#############Copyright (c) 2008-2016. All rights reserved.############

#
#  BatchReprocess_R8  v 4.0
#
#  v1.x Created by Chad Whelan on 2008-01-10.
#  v2.x Modified v1.x by Hardik Parikh starting from 2013-01-26 for Release 7 Radial Suite.
#  v3.0 Major revisions from v2.0 by Hardik Parikh. Read notes below. Compatible with R7u2 and above only.
#  v4.0 Revised for compatibility with Release 8. Some major revisions. 
#
#	Minimum Requirements:
#		At-least Release 7 update 1 Radial processing tools.
#  		Mac OS 10.5.8, 10.6.8, 10.7.5,10.8.x,10.9.x
#	    Intel Only. 
#	v 1.00	2008-05-09 (CWW)
#			-Reprocesses CSS files into Merged Radials, Short Radials and/or Wave (Model) Data
#			-Input/Output/Configs/Processing Tools folders can be chosen by user
#			-Input CSS files remain in place - no moving CSS files around
#			-File list generated once at the beginning
#			-Run multiple processing streams
#			-Creates a date & time stamped subfolder in the target folder for all output data
#
#	v 1.01	2008-05-14 (CWW)
#			-Copies entire Radialconfigs folder to target folder
#			-logs exact same messages to screen and log file
#			-Filters out files not matching site code in Header.txt
#			-Handles Command Line Arguments:
#				-s folder (source)
#					folder is the top folder of the entire tree to search for CSS (input) files
#				-t folder (target)
#					target folder under which a subfolder specific to this instance of reprocessing
#				-b text (CSS_ or CSS_XXXX or CSS_XXXX_07_08_)
#					filter files by matching the text at the beginning of the filenames
#				-e text
#					filter files by matching the text at the end of the filenames
#				-c folder (RadialConfigs)
#					folder containing the config files to be used
#				-p folder (SpectraProcessing)
#					folder containing the processing tools to be used
#				-1 date string (starting)
#					only data occurring after date text string shall be processed
#						e.g. -1 "yyyy/mm/dd HH:MM"
#				-2 date string (stopping)
#					only data occurring before date text string shall be processed
#						e.g. -2 "yyyy/mm/dd HH:MM"
#
#			e.g.
#				> BatchReprocess.pl -s /Codar/SeaSonde/Archives/Spectra -b CSS_CBBT -1 "2007/08/22 21:00" -R 1 -W 0 -E 1 
#
#	v 1.02	2008-06-20 (CWW)
#			-handles folder paths with spaces in folder names
#			-cleaned up some undeclared variables
#			-changed all of the processing tool calls to premade strings for better debugging
#			-Logs error and quits if it cannot find Header.txt or AnalysisOptions.txt
#			-Updated to support extra argument for config folder in RadialDiagnostic call
#
#	v 1.03	2009-02-23 (CWW)
#			-Archives First Order Line limit solutions in individual files corresponding to each CSS
#			 file processed.  Files are found in the target folder under ./FirstOrderLimits/
#
#	v 1.04	2010-07-12 (CWW)
#			- Updated to work with Release 6, update 2
#			- Still no ellipticals & no image creation

############New Version number starting from Release 7.################
#   v 2.0   2012-05-04 (HP)
#			- Updated to work with Release 7 tools. 
#			- If using R7,requires a license key for operation and CheckForSpectra v11.3.0 and above. 
#			- Minor fixes related to processing folder files.  
#			- Now,has Radial Metric and Radial Filler outputs also.  
#			- Now,has Elliptical Outputs and Image creation.  
#			- Moves configs folder to target folder and uses configs from this target folder for processing. 
#	v 2.0 	2013-01-26 (HP)
#			- Works with the StartBatchReprocessing Application
#			- Can be called from command line or from the StartBatchReprocessing Application
#			- Accepts -t or -d both for target folder arguments
#   v 2.0   2013-02-27 (HP)
#			- Renamed StartBatchReprocessing to SpectraOfflineProcessing application. 
#			- Disabled latest image file creation.(Not needed for Batch Reprocessing).Serial image creation still enabled.
#			- Add script version file in Processing folder. 
#			- Add error handling if RadialConfigs folder does not exist or Picture creation is not enabled or matching CSS files not found.
#	v 2.0   2013-03-18 (HP)
#			- Added check for /Codar/SeaSonde folder
#	v 2.0 	2013-03-20 (HP)
#			- Added use of AnalysisVerbocity.txt file. Using diag values for applications from this file now.
#			- Writing verbose messages to log file in /Codar/SeaSonde/Logs/BatchReprocessingLogs
#	v 2.0   2013-04-02 (HP)
#			- Writing verbose messages to log file in Targetfolder/Debuglog.txt instead of logs folder.
#   v 2.1   2014-05-01 (HP)
#			- Fixed bug where processing was not working in absence of AnalysisVerbocity.txt file.(diagnostic variable assignment was incorrect)
#			- Added reading of lines 23 to 26 of AnalysisVerbocity.txt file.
#			- Added reading of line 11,12 of AnalysisOptions.txt file. 
#   v 2.1   2014-06-11 (HP)
#			- ToDo: Fix Elliptical processing issue
#			- Started using UseBragg and dodopplerclassic(not used anywhere currently) from AnalysisOptions.
#			- Started reading all diagnostic values from AnalysisVerbocity.txt
#	v 3.0   2014-07-01 (HP)
#			- Added FOL smoothing param <nDopMult> when doppler interpolation is on for SpectraToRadial. This will fix elliptical processing bug.
#   v 3.0   2014-07-03 (HP)
#			- ToDo: SpectraToElliptical still showing fortran error due to doppler interpolation.
# 	v 3.0   2014-07-14 (HP)
#			- Added spectra archiving feature to show FOLs on spectra files. Works with new SpectraArchiver v 11.3.1
# 	v 3.0	2014-07-17 (HP)
#			- Added changes to handle spectra archiving flags passed through main GUI or through command line. 
#			- Changed log file extension to .log
# 	v 3.0 	2014-09-08	(HP)
#			- Added the missing SpectraArchiver call.(Accidentally deleted when saving final version earlier. 
# 			- Added check for SpectraArchiver version.
# 			- FirstOrder folder now created only if not using SpectraArchiver option.
#
############ New Version number starting from Release 8 ################
#   v 4.0  2016-08-14 (HP)
#			- Made changes for compatibility with Release 8 tools. 
#			- Keep RadialInfo.txt to see if helps rare missing meta in radials. Now matches AnalyzeSpectra 150523 change.(Not related to R8.)
#			- New Wave Output: filtered de-ranged, filter ranges, unfiltered
#			- Radial Metric Output disabled in v 4.0
############ Modifications made by UNC ###############
#  v 4.0_UNC 2022-06-01 (SMH) 
#                       - reinstate Radial Metric Output in v 4.0
#


use File::Copy;
use File::Find;
use POSIX qw(strftime);
use Time::Local;
#use warnings;
########################################################################
#### #### ####  File/Folder Configuration Defaults   #### #### #### ####  
########################################################################

$sourceFolder = "/Codar/Seasonde/Archives/Spectra";
$fileToProcBegins = 'CSS_';
$fileToProcEnds = '';
$targetFolder = "$ENV{HOME}/Desktop";
$configsFolder = '/Codar/Seasonde/Configs/RadialConfigs';
$procToolsFolder = '/Codar/Seasonde/Apps/RadialTools/SpectraProcessing';
$ssservicefolder = '/Codar/SeaSonde/Apps/Installations';
$CosRootFolder = '/Codar/SeaSonde';  ##added for image creation tools' path.
$CosLogFolder = '/Codar/SeaSonde/Logs/BatchReprocessingLogs';
$CosEllipticalFolder=$targetFolder."/Ellipticals";
$CosShortEllipticalFolder=$targetFolder."/EllipticalShorts";
$CosSpectraOutFolder=$targetFolder."/SpectraProcessed/";


#$enableRadials = 0;
#$enableWaves = 0;
#$enableEllipticals = 0;
#$enableRadialShorts = 0;
#$enableRadialMetrics = 0;
#$cmdlineRadials = 0;
#$cmdlineWaves = 0;
#$cmdlineEllipticals = 0;
#$cmdlineRadialShorts = 0;
#$cmdlineRadialMetrics = 0;

$startTime = 0;
$stopTime = 0;
$UseBragg = 0; #default: use both bragg peaks. 
$firstMerge = 1; #HP
$SAmove = 3; # Spectra Archiver move flag. 0 = Keep CSS where it is with determined FOL. 1 = Move to Processed folder. 2 = Copy to Processed folder.  3 = Leave CSS untouched.

########################################################################
## Image tools

$CosSpectraImageTool = $CosRootFolder."/Apps/Viewers/SpectraPlotterMap.app/Contents/MacOS/SPMTool";
$CosRadImageTool = $CosRootFolder."/Apps/Viewers/SeaDisplay.app/Contents/MacOS/SeaDisplayTool";
$CosElpImageTool = $CosRootFolder."/Apps/Viewers/SeaDisplay.app/Contents/MacOS/SeaDisplayTool";
$CosWaveImageTool = $CosRootFolder."/Apps/Viewers/WaveDisplay.app/Contents/MacOS/WDTool";


########################################################################
#### #### #### ####    Handle Command Line Args	     #### #### #### ####  
########################################################################
my $as = 'AppleScript' ;
if (grep {$_ eq $as} @ARGV) 
{$asfound = 1;}

for (my $n = 0; $n<=$#ARGV; $n++) {
	if ($ARGV[$n] =~ /-h/) {help();exit;}
	if ($ARGV[$n] =~ /-s/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$sourceFolder = $ARGV[$n];}}
	if (($ARGV[$n] =~ /-t/) || ($ARGV[$n] =~ /-d/)){$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$targetFolder = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-b/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$fileToProcBegins = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-e/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$fileToProcEnds = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-c/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$configsFolder = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-p/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$procToolsFolder = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-R/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$enableRadials = $ARGV[$n];$cmdlineRadials = 1;}}
	if ($ARGV[$n] =~ /-W/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$enableWaves = $ARGV[$n];$cmdlineWaves = 1;}}
	if ($ARGV[$n] =~ /-E/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$enableEllipticals = $ARGV[$n];$cmdlineEllipticals = 1;}}
	if ($ARGV[$n] =~ /-S/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$enableRadialShorts = $ARGV[$n];$cmdlineRadialShorts = 1;}}
	if ($ARGV[$n] =~ /-M/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$enableRadialMetrics = $ARGV[$n];$cmdlineRadialMetrics = 1;}}
	if ($ARGV[$n] =~ /-D/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$SAmove = $ARGV[$n];$cmdlineSAmove = 1;}}

	if ($ARGV[$n] =~ /-1/) {
		$n++;
		if ($ARGV[$n] =~ /^-/) {
			$n--;
			next;
		} else {
			$startString = $ARGV[$n];
			if ($startString =~ /(\d{4})[\/-](\d{1,2})[\/-](\d{1,2})\s(\d{1,2}):(\d\d)/) {
				$startTime = timelocal(0,$5,$4,$3,$2-1,$1);
			}
		}
	}
	if ($ARGV[$n] =~ /-2/) {
		$n++;
		if ($ARGV[$n] =~ /^-/) {
			$n--;
			next;
		} else {
			$stopString = $ARGV[$n];
			if ($stopString =~ /(\d{2,4})[\/-](\d{1,2})[\/-](\d{1,2})\s(\d{1,2}):(\d\d)/) {
				$stopTime = timelocal(0,$5,$4,$3,$2-1,$1);
			}
		}
	}
}


#$targetFolder = sprintf "%s/Reprocess_%s", $targetFolder, strftime("%y%m%d_%H%M%S", localtime $^T);

# if not called from AppleScript app, then create timestamp for target folder here
if (!$asfound) {$targetFolder = sprintf "%s/Reprocess_%s", $targetFolder, strftime("%y%m%d_%H%M%S", localtime $^T);}

unless (-e $targetFolder) {$out = `mkdir -p $targetFolder`;}

if ($targetFolder =~ /(Reprocess)(_\d{6}_\d{6})$/) #check for Reprocess_DDDDDD_DDDDDD pattern
{
$foldertime = $2;
$logfile = $targetFolder . "/Reprocesslog" . $foldertime . ".log";
#$full_logfile = "/Codar/SeaSonde/Logs/BatchReprocessingLogs/BatchReprocessingLog" . $foldertime . ".txt";
$full_logfile = $targetFolder . "/Debuglog" . $foldertime . ".log";
}
else # if not using AppleScript app
{ 
$logfile = "$targetFolder/ReprocessLog.log";	# Define Log File name
$full_logfile = $targetFolder . "/Debuglog.log"; # Define verbose log file
}

## set file label to red if any error occurs
$filelabel = 'set thelogfile to posix path of "' . $logfile . '"
set filetolabel to posix file' . ' thelogfile ' . '
try
tell application "Finder" to set label index of (filetolabel as alias) to 2
end try
';

$sourceFolder =~ s/\/\//\//g; #substituting double slashes with single slash
$configsFolder =~ s/\/\//\//g;  #substituting double slashes with single slash
$configsFolder =~ s/\/$//; #removing the last /
$targetFolder =~ s/\/\//\//g;  #substituting double slashes with single slash

unless (-e $CosLogFolder) {$out = `mkdir -p $CosLogFolder`;}
open(LOG, ">>", $logfile) or die "$!\nProblem creating or opening $logfile\n"; 		# open/create log file
open(FLOG, ">>", $full_logfile) or die "$!\nProblem creating or opening $full_logfile\n"; 		# open/create log file

@logtargets = (STDOUT,LOG,FLOG); # Where do messages go? (default = stdout & log file)

# Exit if /Codar/SeaSonde folder does not exist
unless (-d $CosRootFolder) 
{ 
	foreach (@logtargets) {print { $_ } "\n\n\"/Codar/SeaSonde\" folder does not exist.\n\n*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}

if ($procToolsFolder =~ /\s+/) 
{
	foreach (STDOUT,LOG) {print { $_ } "\nThere is a space somewhere in the path of Processing tools. No space in folder names is allowed\n",
	"The default path for processing tools is /Codar/SeaSonde/Apps/RadialTools/SpectraProcessing\n*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}

if ($configsFolder =~ /\s+/)
{
	foreach (@logtargets) {print { $_ } "\nThere is a space somewhere in the path of the configs folder. No space in folder names is allowed\n",
	"*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}

if ($sourceFolder =~ /\s+/)
{
	foreach (@logtargets) {print { $_ } "\nThere is a space somewhere in the path of the source folder. No space in folder names is allowed\n",
	"*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}

if ($targetFolder =~ /\s+/)
{
	foreach (@logtargets) {print { $_ } "\nThere is a space somewhere in the path of the output folder. No space in folder names is allowed\n",
	"*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}

unless (-d $configsFolder)
{
	foreach (@logtargets) {print { $_ } "\nRadialConfigs folder $configsFolder does not exist.\n",
	"*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}

#####Copy configs folder to target folder and use those configs for processing. 
$origconfigsFolder = $configsFolder;
$status = `cp -pvR "$configsFolder" "$targetFolder"`;

# Exit if Processing Tools are missing
unless (-e $procToolsFolder)  
{
	foreach (@logtargets) {print { $_ } "\n\nSpectra Processing Tools are missing from:$procToolsFolder\n\n*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
} 

# Check if RadialConfigs folder name matches standard criteria.
# for example: RadialConfigs or RadialConfigs_XXXX

if ($configsFolder =~ /(\/{1})(\w*RadialConfigs[^\/]*$)/)
{
$firstmatch = $1;
$configextension = $2;
$configsFolder = $targetFolder.'/'.$configextension;
}
else 
{
foreach (@logtargets) {print { $_ } "RadialConfigs folder name is non-standard.\nExample:Can't have a '/'or '\\' in the folder name.\n\n*****Aborted Processing*****\n";}
$out = `osascript -e '$filelabel'`;
exit;
}

foreach (@logtargets) {print { $_ } "\n";}
foreach (@logtargets) {print { $_ } "CSS Reprocessing Info:\n\n";}
foreach (@logtargets) {print { $_ } "Data Source Folder:\n\t$sourceFolder\n\n";}
foreach (@logtargets) {print { $_ } "Data Target Folder:\n\t$targetFolder\n\n";}
foreach (@logtargets) {print { $_ } "Process only files Beginning with:\n\t$fileToProcBegins\n\n";}
if ($fileToProcEnds) {foreach (@logtargets) {print { $_ } "Process only files Ending with:\n\t$fileToProcEnds\n\n";}}
if ($startString) {foreach (@logtargets) {print { $_ } "Process only files time stamped at or after:\n\t$startString\n\n";}}
if ($stopString) {foreach (@logtargets) {print { $_ } "Process only files time stamped at or before:\n\t$stopString\n\n";}}
foreach (@logtargets) {print { $_ } "\nThe configs folder location you selected was: $origconfigsFolder and it was copied to output folder.\n\n";}
foreach (@logtargets) {print { $_ } "Use Radial Config Files from:\n\t$configsFolder\n\n";}
foreach (@logtargets) {print { $_ } "Use Spectra Processing Tools in:\n\t$procToolsFolder\n\n";}


########################################################################
#### #### #### ####  Read From Configuration Files   #### #### #### ####
########################################################################

## Config File Names
$CosOptionsFile = $configsFolder."/AnalysisOptions.txt";
$CosHeaderFile = $configsFolder."/Header.txt";
$CosVerbocityFile = $configsFolder."/AnalysisVerbocity.txt";
$CosImageOptionsFile = $configsFolder."/ImageOptions.txt";
$SDplist = $configsFolder."/SeaDisplay.plist";
$RDplist = $configsFolder."/RadialDisplay.plist";
$WDplist = $configsFolder."/WaveDisplay.plist";
$SPMplist = $configsFolder."/SpectraPlotterMap.plist";

$CosRadialImagePrefFile = $configsFolder."/Image_RadialDisplay.plist";
$CosEllipticalImagePrefFile = $configsFolder."/Image_EllipticalDisplay.plist";
$CosWaveImagePrefFile = $configsFolder."/Image_WaveDisplay.plist";
$CosSPMPrefFile = $configsFolder."/Image_SpectraPlotterMap.plist";

unless (-d $configsFolder)
{
	foreach (@logtargets) {print { $_ } "\nSeems, RadialConfigs folder $configsFolder does not exist.\n*****Aborted Processing*****\n";}
}

## Check if AnalysisOptions file exists and get parameters from it
if (-e $CosOptionsFile) {

	open (FID, "< $CosOptionsFile");
	
	$line = <FID>;		# Line 1: Process Radials (1/0)
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doRads = $params[0];
	#if (($cmdlineRadials) && ($doRads !=$enableRadials)) 
	if ($cmdlineRadials)
	{$doRads = $enableRadials;
	if (!$asfound)
    	{
    	foreach (@logtargets) {print { $_ } "Using command-line option for Enabling/Disabling Radials processing instead of setting in RadialConfigs Folder.\n";}
		}
	}	
	$line = <FID>;		# Line 2: Process Waves (1/0)
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doWaves = $params[0];
	if ($cmdlineWaves) 
	{$doWaves = $enableWaves;
		if (!$asfound)
    	{
    	foreach (@logtargets) {print { $_ } "Using command-line option for Enabling/Disabling Waves processing instead of setting in RadialConfigs Folder.\n";}
		}
	}
	$line = <FID>;		# Line 3: File Archiving: Ignored. No longer in use.
	$line = <FID>;		# Line 4: Antenna Pattern: 0(Ideal),1(Measured),2(Both); 
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$pattParam = $params[0];

	$line = <FID>;		# Line 5: Spectra Header Override: 0(Use CS Info),1(Use Header Info)
	$line = <FID>;		# Line 6: CSA Processing: 0(CSA->'Rad_'),1(CSS only)
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doingCSS = $params[0];

	$line = <FID>;		# Line 7: Wave Processing: OffShore 0(No),1(Yes); ApplySymetry 0(No),1(Yes); UseInnerWaves 0(No),1(Yes)
# 	$line =~ s/^\s+//;
# 	@params = split(/\s+/,$line);
# 	$OffShore = $params[0];
# 	$ApplySymmetry = $params[1];
# 	$UseInnerWaves = $params[2];
	
	$line = <FID>;		# Line 8:  Elliptical Processing: 0(Off),1(On)
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doEllipticals = $params[0];
	if ($cmdlineEllipticals) 
	{$doEllipticals = $enableEllipticals;
		if (!$asfound)
    	{
    	foreach (@logtargets) {print { $_ } "Using command-line option for Enabling/Disabling Elliptical processing instead of setting in RadialConfigs Folder.\n";}
		}
	}
	$line = <FID>;		# Line 9:  Ionospheric Noise: 0(Ignore), 1(Remove Offending RangeCells)

	$line = <FID>;		# Line 10: ShortTime Rad/Ellipticals: 0(Off), 1(Output) 
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doShortRads = $params[0];
	if ($cmdlineRadialShorts) 
	{$doShortRads = $enableRadialShorts;
		if (!$asfound)
    	{
    	foreach (@logtargets) {print { $_ } "Using command-line option for Enabling/Disabling Short time Radials/Ellipticals processing instead of setting in RadialConfigs Folder.\n";}
		}
	}	
		
    $line = <FID>;		# Line 11: Special First Order: 0(Off), 1(Enable)
    $line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$specialFirstOrder = $params[0];
	
    $line = <FID>;		# Line 12: Average CS FirstOrder: 0(On), 1(Off)
    $line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doSpectraSlider = $params[0]; # default is on, which means you average CS firstorder
	
    $line = <FID>;		# Line 13:
    $line = <FID>;		# Line 14:
    $line = <FID>;		# Line 15:
    $line = <FID>;		# Line 16:
    $line = <FID>;		# Line 17:
    $line = <FID>;		# Line 18:
    $line = <FID>;		# Line 19: DopplerInterpolation: 0(Off), 2(Double), 3(Triple), 4(Quadruple)
    $line =~ s/^\s+//;
    @params = split(/\s+/,$line);
    $doDopplerInterp = $params[0];
    $doRangeInterp = $params[1];    
    $doDopplerClassic = $params[2]; # this is not used anywhere now.
    if ($doDopplerInterp == 1) {$doDopplerInterp = 2;}

    $line = <FID>;		# Line 20: Use Bragg: 0(Both), 1(Pos/Left), 2(Neg/Right), 3(Both)
    $line =~ s/^\s+//;
    @params = split(/\s+/,$line);
    $UseBragg = $params[0];
    
    $line = <FID>;		# Line 21: Radial Metric Output: 0(Off), 1(Enable), 2(Enable MaxVel.)
    $line =~ s/^\s+//;
    @params = split(/\s+/,$line);
    $doRadialMetric = $params[0];
    if ($cmdlineRadialMetrics) 
    {$doRadialMetric = $enableRadialMetrics;
    	if (!$asfound)
    	{
    	foreach (@logtargets) {print { $_ } "Using command-line option for Enabling/Disabling Radial Metric processing instead of setting in RadialConfigs Folder.\n";}
		}
    }


    $line = <FID>;		# Line 22: Radial Filler Output: 0(Off), 1(Area Filter+Interp), 2(Area Filter Only)
    $line =~ s/^\s+//;
    @params = split(/\s+/,$line);
    $doRadialFiller = $params[0];
    
    if (($doRadialMetric == 0) && ($doShortRads == 0) && ($doWaves == 0) && ($doRads == 0))
	{
       if ($doEllipticals == 0)
       { foreach (@logtargets) {print { $_ } "*****ERROR: Radial,Waves and Ellipticals processing is turned off.\nAborted processing.\nCheck configs or Make correct selection through the GUI.\n";} $out = `osascript -e '$filelabel'`; exit;}
      # else 
       #{ foreach (@logtargets) {print { $_ } "*****ERROR: Radial & Waves processing is turned off\nAborted processing\nCheck configs  or Make correct selection through the GUI.\n";} $out = `osascript -e '$filelabel'`; exit;}
    }
	close(FID);
} 
else {
	foreach (@logtargets) {print { $_ } "Can't continue: AnalysisOptions.txt does not exist in $configsFolder\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
	 }

########################################################################
#	Print summary of processing Outputs
########################################################################
						
if (($cmdlineRadials | $cmdlineWaves | $cmdlineEllipticals | $cmdlineRadialShorts | $cmdlineRadialMetrics) && ($asfound))
	{ 
		foreach (@logtargets) {print { $_ } "\nUsing GUI selection for Enabling/Disabling Radial/Waves/Elliptical/Short-time Radials or Ellipticals/Radial Metric Output instead of settings in RadialConfigs folder.\n\n";}
	}
if ($cmdlineSAmove) 
{
if ($asfound) {foreach (@logtargets) {print { $_ } "\nUsing GUI selection for spectra archiving.\n";}}
		if ($SAmove == 0) {foreach (@logtargets) {print { $_ } "\nWill keep spectra in source folder but replace determined first order lines.\n\n";}}
		elsif ($SAmove == 2) {foreach (@logtargets) {print { $_ } "\nWill duplicate spectra to destination folder with determined first order lines\n\n";}}
		else {foreach (@logtargets) {print { $_ } "\nLeave spectra as-is in source folder untouched\n\n";}}
}


if ($doRads) {foreach (@logtargets) {print { $_ } "\nRadials:      On\n";}}
else {foreach (@logtargets) {print { $_ } "Radials:      Off\n";}}
if ($doWaves) {foreach (@logtargets) {print { $_ } "Waves:        On\n";}}
else {foreach (@logtargets) {print { $_ } "Waves:        Off\n";}}
if ($doEllipticals) {foreach (@logtargets) {print { $_ } "Ellipticals:  On\n";}}
else {foreach (@logtargets) {print { $_ } "Ellipticals:  Off\n";}}
if ($doRadialMetric) {foreach (@logtargets) {print { $_ } "Radial Metric:On\n";}}  # disabled for R8 by HP -- enabled by SMH
else {foreach (@logtargets) {print { $_ } "Radial Metric:Off\n";}}
#if ($doRadialMetric) {foreach (@logtargets) {print { $_ } "Radial Metric Output not supported.\n";}}


if ($doShortRads) { foreach (@logtargets) {print { $_ } "Short time Radial/Elliptical: On\n";}}
else { foreach (@logtargets) {print { $_ } "Short time Radial/Elliptical: Off\n";}}



########################################################################
# Analysis Verbocity Settings
# Verbose messages written to a log file in the output folder. 
########################################################################
if (-e $CosVerbocityFile) {
open (FID, "< $CosVerbocityFile");

$line = <FID>;	#Line 1: CheckForSpectra
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagCFS = $params[0];

$line = <FID>;	#Line 2: SpectraSlider
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSS = $params[0];

$line = <FID>;	#Line 3: SpectraToRadial
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSTR = $params[0];

$line = <FID>;	#Line 4: RadialSlider
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagRS = $params[0];

$line = <FID>;	#Line 5: RadialMerger
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagRM = $params[0];

$line = <FID>;	#Line 6: RadialArchiver
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagRA = $params[0];

$line = <FID>;	#Line 7: SpectraToWave
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSTW = $params[0];

$line = <FID>;	#Line 8: WaveArchiver
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagWA = $params[0];

$line = <FID>;	#Line 9: SpectraArchiver
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSA = $params[0];

$line = <FID>;	#Line 10: WaveForFive
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagWFF = $params[0];

$line = <FID>;	#Line 11: RadialDiagnostic
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagRD = $params[0];

$line = <FID>;	#Line 12: WaveModelForFive
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagWMFF = $params[0];

$line = <FID>;	#Line 13: SpectraToWavesModel
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSTWM = $params[0];

$line = <FID>;	#Line 14: WaveModelArchiver
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagWMA = $params[0];

$line = <FID>;	#Line 15: WaveModelFilter
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagWMS = $params[0];

$line = <FID>;	#Line 16: FirstOrderLimit
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagFOL = $params[0];

$line = <FID>;	#Line 17: SpectraPointExtractor
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSPE = $params[0];

$line = <FID>;	#Line 18: SpectraToEllipticals
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSTE = $params[0];

$line = <FID>;	#Line 19: EllipticalsSlider
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagES = $params[0];

$line = <FID>;	#Line 20: EllipticalsArchiver
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagEA = $params[0];

$line = <FID>;	#Line 21: EllipticalsDiagnostic
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagED = $params[0];

$line = <FID>;	#Line 22: EllipticalsMerger
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagEM = $params[0];

$line = <FID>;	#Line 23: SpectraDiagnostic
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSD = $params[0];

$line = <FID>;	#Line 24: Check Elliptical Setup
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagECS = $params[0];

$line = <FID>;	#Line 25: Radial Filler
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagRF = $params[0];

$line = <FID>;	#Line 26: SpectraDoubler
$line =~ s/^\s+//;
@params = split(/\s+/,$line);
$diagSDB = $params[0];

close (FID);
}
else {
foreach (FLOG){printf { $_ } "AnalysisVerbocity.txt file not found in RadialConfigs folder. Using default values.\n";}
$diagCFS = 10;
$diagSS = $diagSTR = $diagRS = $diagRM = $diagRA = $diagSTW = $diagWA = $diagSA = $diagWFF = $diagRD = $diagWMFF = $diagSTWM = $diagWMA = $diagWMS = 1;
$diagFOL = $diagSTE = $diagES = $diagEA = $diagED = $diagEM = $diagSD = $diagECS = $diagRF = $diagSDB = 1;
$diagSPE = 0; #spectra point extractor
}
########################################################################
# ImageOptions Settings
########################################################################
## Check if ImageOptions file exists and get parameters from it

if (-e $CosImageOptionsFile) {

	open (FIDI, "< $CosImageOptionsFile");
	
	$linei = <FIDI>;		# Line 1: Enable All Image Output: 0=off ; 1=enable
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doAllImage = $params[0];
	
	$linei = <FIDI>;		# Line 2: Latest Radial Plot: 0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageRadialLatest = $params[0];

	$linei = <FIDI>;		# Line 3: Latest Elliptical Plot: 0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageEllipticalLatest = $params[0];
	
	$linei = <FIDI>;		# Line 4: Latest Spectra Power Map:  0=off ; 1=on 
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageSpectraLatest = $params[0];

	$linei = <FIDI>;		# Line 5: Latest Spectra Range Plot:  0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageSpectraRangeLatest = $params[0];
	
	
	$linei = <FIDI>;		# Line 6: Latest Wave Plot:  0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageWaveLatest = $params[0];

	$linei = <FIDI>;		# Line 7: Serial Radial Plot: 0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageRadialSerial = $params[0];
	
	$linei = <FIDI>;		# Line 8:  Serial RadialShort Plot: 0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageRadialShortSerial = $params[0];
	
	$linei = <FIDI>;		# Line 9:  Serial Elliptical Plot: 0=off ; 1=on
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageEllipticalSerial = $params[0];

	$linei = <FIDI>;		# Line 10: Serial EllipticalShort Plot: 0=off ; 1=on 
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageEllipticalShortSerial = $params[0];
	
    $linei = <FIDI>;		# Line 11: Serial Spectra Power Map:  0=off ; 1=on
    $linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageSpectraSerial = $params[0];
	
    $linei = <FIDI>;		# Line 12: Serial Spectra Range Plot:  0=off ; 1=on
    $linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageSpectraRangeSerial = $params[0];
	
    $linei = <FIDI>;		# Line 13: Serial Wave Plot:  0=off ; 1=on
    $linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$doImageWaveSerial = $params[0];
	
    $linei = <FIDI>;		# Line 14: Spectra Range Plot Range cells
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
 	$imageSpectraRangeCell1 = $params[0];
	$imageSpectraRangeCell2 = $params[1];
 	$imageSpectraRangeCell3 = $params[2];
    
    $linei = <FIDI>;		# Line 15: Wave Plots Range cells
	$linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
 	$imageWaveCell1 = $params[0];
	$imageWaveCell2 = $params[1];
 	$imageWaveCell3 = $params[2];
	
    $linei = <FIDI>;		# Line 16: Wave Plots Latest Time Span follow with d=days h=hours
    $linei =~ s/^\s+//;
	@params = split(/\s+/,$linei);
	$imageWaveSpan = $params[0];
	$count = length ($imageWaveSpan); 
	$dayorhour = substr($imageWaveSpan, 1, 1);
	  if (($count = 0) | ($dayorhour != "d") | ($dayorhour != "h")) {$imageWaveSpan = "7d";}  # default is "7d"
	
	close(FIDI);
}
else 
{
	foreach (@logtargets) {print { $_ } "Seems, ImageOptions.txt file does not exist in RadialConfigs folder.\nNo Images will be created.\n";}
}

##########################


## Check if Header file exists and get parameters from it
if (-e $CosHeaderFile) 
{
	open (FID, "< $CosHeaderFile");

	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$siteCode = $params[1];

	for (my $i = 2; $i < 8; $i++) {
		@params = split(/\s+/,<FID>);
	}
	
	$line = <FID>; #Reading line 8: Doppler bins
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$dopplerbins = $params[0];
	##########
	if ((($doDopplerInterp * $dopplerbins) > 1024) && ($doEllipticals == 1))
{ foreach (@logtargets) {printf { $_ } "\n\n*****Error: Number of interpolated doppler points is greater than 1024.\nElliptical Processing will be turned off now. Disable doppler interpolation and restart elliptical processing.\n\nEllipticals:  Off\n";}
$out = `osascript -e '$filelabel'`; $doEllipticals = 0;}
if (($dopplerbins > 1024) && ($doEllipticals == 1))
{ foreach (@logtargets) {printf { $_ } "\n\n*****Error: Number of doppler points in spectra seems to be greater than 1024.\nElliptical Processing will be turned off. Elliptical processing only supports upto 1024 doppler points.\n\nEllipticals:  Off\n";}
$out = `osascript -e '$filelabel'`; $doEllipticals = 0;}
	##########
	
	for (my $i = 9; $i < 21; $i++) {
	@params = split(/\s+/,<FID>);
	}
	
	$line = <FID>; # Reading line 21
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$timeCoverage = $params[0];
	$timeOutput = $params[1];
	$OffsetMin = $params[2];
	$IgnoreSpan = $params[3];
	$timekeep = ($timeCoverage * 3);
	
	close(FID);
} 
else 
{
	foreach (@logtargets) {print { $_ } "Can't continue: Header.txt does not exist in $configsFolder\n*****Aborted Processing*****\n";}
	$out = `osascript -e '$filelabel'`;
	exit;
}
  
########################################################################
#### #### #### ####  Define Other Files & SubFolders #### #### #### ####
########################################################################

$outputLLUV = 1;	## -1=use pref, 0=classic, 1=LLUV,
$logdatefmt = "%F %T %Z";

if ($pattParam == 0) 
	{
	@pattsToUse = ('ideal');
	$CosRadSubFolder{ideal} = "IdealPattern";
	foreach (@logtargets) {print { $_ } "\nProcessing using ideal pattern\n\n";}
	} elsif ($pattParam == 1) 
    {
	@pattsToUse = ('meas');
	$CosRadSubFolder{meas} = "MeasPattern";
	foreach (@logtargets) {print { $_ } "\nProcessing using measured pattern\n\n";}
	} elsif ($pattParam == 2) 
	{

	@pattsToUse = ('meas','ideal');
	%CosRadSubFolder = (
							ideal => "IdealPattern",
							meas => "MeasPattern",
						);
	foreach (@logtargets) {print { $_ } "\nProcessing using ideal & measured patterns\n\n";}
	} 
	else {
	# Insert error handling here
    foreach (@logtargets) {print { $_ } "\nInvalid pattern setting for ideal and/or measured pattern.\nCheck configs\n";}
		 }
		 
		 

## Define/Create Necessary output subfolders
$CosProcFolder = $targetFolder."/Processing";


unless (-e $CosProcFolder) {$out = `mkdir -p $CosProcFolder`;}

############ Image Folders #############

$CosImageFolder = $targetFolder."/Pictures";
$CosImageLatestFolder = $CosImageFolder."/Latest";
$CosImageSpectraSerialFolder = $CosImageFolder."/Spectra";
$CosImageRadialSerialFolder = $CosImageFolder."/Radials";
$CosImageEllipticalSerialFolder = $CosImageFolder."/Ellipticals";
$CosImageWaveSerialFolder = $CosImageFolder."/Waves";

#########Create Output Folders##########
unless (-e $CosImageFolder) {$out = `mkdir -p $CosImageFolder`;}

if ($doRads) 
  {    
	$CosRadialFolder = $targetFolder."/Radials";
	foreach (keys %CosRadSubFolder) 
	    {
		unless (-e $CosRadialFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosRadialFolder/$CosRadSubFolder{$_}`;}
		}
		if ($doRadialFiller) 
		 {
			$CosRadialFilterSubFolder = $CosRadialFolder."/Filtered";
			foreach (keys %CosRadSubFolder) 
			{
			unless (-e $CosRadialFilterSubFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosRadialFilterSubFolder/$CosRadSubFolder{$_}`;}
		    }
		 }
	}

if ($doShortRads) 
   {
	$CosShortRadialFolder = $targetFolder."/RadialShorts";
	$CosShortEllipticalFolder = $targetFolder."/EllipticalShorts";

	foreach (keys %CosRadSubFolder) 
		{
		unless (-e $CosShortRadialFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosShortRadialFolder/$CosRadSubFolder{$_}`;}
		unless (-e $CosShortEllipticalFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosShortEllipticalFolder/$CosRadSubFolder{$_}`;}
		}
		if ($doRadialFiller) 
		 {
			$CosRadialShortFilterSubFolder = $CosShortRadialFolder."/Filtered";
			foreach (keys %CosRadSubFolder) 
			{
			unless (-e $CosRadialShortFilterSubFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosRadialShortFilterSubFolder/$CosRadSubFolder{$_}`;}
		    }
		 }
	}

if ($doWaves) {
				$CosWaveFolder = $targetFolder."/Waves";
				unless (-e $CosWaveFolder) {$out = `mkdir -p $CosWaveFolder`;}
				$CosWaveRawFolder = $CosWaveFolder."/WavesUnfiltered";
				$CosWaveFiltFolder = $CosWaveFolder."/WavesRanged";
				$CosWaveFinalFolder = $CosWaveFolder;
			  }
			  
if ($doEllipticals) {
		$CosEllipticalFolder = $targetFolder."/Ellipticals";
		foreach (keys %CosRadSubFolder) 
	    {
		unless (-e $CosEllipticalFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosEllipticalFolder/$CosRadSubFolder{$_}`;}
		}
					}

# disabled for R8 by HP, re-enable by SMH
if ($doRadialMetric) {
		$CosRadialMetricFolder = $targetFolder."/RadialMetric";
		foreach (keys %CosRadSubFolder) {
		unless (-e $CosRadialMetricFolder."/$CosRadSubFolder{$_}") {$out = `mkdir -p $CosRadialMetricFolder/$CosRadSubFolder{$_}`;}
		}
	}


$CosDiagFolder = $targetFolder."/Diagnostics";
unless (-e $CosDiagFolder) {$out = `mkdir -p $CosDiagFolder`;}

$CosFirstOrderFolder = $targetFolder."/FirstOrderLines";
if ($SAmove == 3)
{
unless (-e $CosFirstOrderFolder) {$out = `mkdir -p $CosFirstOrderFolder`;}
}

## Files/Folders in Processing folder
$CosProcRadFile = $CosProcFolder."/RadialData.txt";
$CosProcRadSaveFile = $CosProcFolder."/RadialDataSave.txt";
$CosProcRadListFile = $CosProcFolder."/RadialSlider.list";
unless (-e "$CosProcFolder/SpectraSliders") {$out = `mkdir -p "$CosProcFolder/SpectraSliders"`;}
$CosProcSpectraAver = $CosProcFolder."/SpectraSliders/CSA_AVER_00_00_00_0000";
$CosProcRadResult = $CosProcFolder."/RdlsXXXX_00_00_00_0000.rv";
$SpectraToProcessFile = $CosProcFolder."/SpectraToProcess.txt";
$CosProcElpResult = $CosProcFolder."/Elp_XXXX_00_00_00_0001.ev";

## Some other definitions
$CosVerboseFile = $configsFolder."/AnalysisVerbocity.txt";
$nextFileOutput = $CosProcFolder.'/SpectraToProcess.txt'; #HP: Not present in spectra analysis

## Print Script version to new file in processing folder.
	$reprocessingscriptversion = $CosProcFolder."/AnalyzeScriptVersion.txt"; 
	open (VERSION, "> $reprocessingscriptversion");
	print VERSION "SpectraOfflineProcessing 3.0\n";
	close VERSION;
	
## Files to delete before each CSS is processed ##
@filesToDelete = (	
					$CosProcRadResult,
					$CosProcRadFile, 
				   #$CosProcFolder."/RadialInfo.txt",
					$CosProcFolder."/ALim.txt",
					$CosProcFolder."/NoiseFloorNew.txt",
					$CosProcFolder."/CsMark.txt",
					$CosProcFolder."/AmpNew.txt",
					$CosProcFolder."/PhaseNew.txt",
					$CosProcFolder."/RadialDiagInfo.txt",
					$CosProcFolder."/RadialProcessed.txt",
					$CosProcFolder."/RadialXYProcessed.txt",
				 );
@ElpfilesToDelete =  (  $CosProcFolder."/Elp_AmpNew.txt",
						$CosProcFolder."/Elp_PhaseNew.txt",
						$CosProcFolder."/Elp_IrCells.txt",
						$CosProcFolder."/Elp_NoiseFloor.txt",
						$CosProcFolder."/Elp_FirstOrderLimits.txt",
						$CosProcFolder."/Elp_CsMark.txt",
						$CosProcFolder."/PhaseNew.txt",
						$CosProcFolder."/Elp_Info.txt",
						$CosProcElpResult
					  );
					  
########################################################################
#### #### #### ####   Search for Files to Process    #### #### #### ####
########################################################################

## Create master list of all files matching criteria in folder tree
find \&wanted, $sourceFolder;

## Sub function filter for files that begin with CSS & end with .cs4
sub wanted {if ($_ =~ /^$fileToProcBegins/ and $_ =~ /$fileToProcEnds$/ and ! -d) {$flist{$_} = $File::Find::name;}}
@cssFound = sort keys %flist;


@cssToProcess = ();
foreach my $cssFile (@cssFound) {
    
	my $fSite = substr $cssFile, 4, 4;
	unless ($fSite eq $siteCode) {next;}
    unless ($cssFile =~ /$fileToProcBegins_$siteCode_(\d\d_\d\d_\d\d_\d{4}\.cs)(|s|r|4)$/) {next;}
    
	my $fTimeString = substr $cssFile, 9, 13;
	my $fYear = substr $cssFile, 9, 2;
	my $fMon  = substr $cssFile, 12, 2;
	my $fDay  = substr $cssFile, 15, 2;
	my $fHour = substr $cssFile, 18, 2;
	my $fMin  = substr $cssFile, 20, 2;
	my $timeFile = timelocal(0,$fMin,$fHour,$fDay,$fMon-1,$fYear);

	if ($startTime and ($timeFile < $startTime)) {next;}
	if ($stopTime and ($timeFile > $stopTime)) {next;}
	push @cssToProcess, $cssFile;
}
    




foreach (@logtargets) {printf { $_ } "%d files found, %d files to process\n", $#cssFound+1, $#cssToProcess+1;}



########################################################################
#### #### #### ####      Begin Processing Loop       #### #### #### ####
########################################################################

$filesProcessed = 0;

if ($#cssToProcess >= 0) {

	foreach (@logtargets) {printf { $_ } "Processing beginning at %s\n", strftime($logdatefmt, localtime);}
	foreach my $csfile (sort @cssToProcess) {

		my $fsite = substr $csfile, 4, 4;
		my $ftime = substr $csfile, 9, 13;
		
		$filesProcessed++;

		unlink @filesToDelete;

		# Write each filename into SpectraToProcess.txt
		open (OUT, "> $nextFileOutput");
		print OUT "$flist{$csfile}\n";
		close (OUT);
	
		######################################################################
   		 # Check for correct CheckForSpectra(11.3.0),RadialArchiver(11.3.3),SpectraArchiver(11.3.1) Versions and for License Key
    	######################################################################
		my $execStr = "$procToolsFolder/RadialArchiver 2";
     	my $output = `$execStr`;
     	if ($output =~ m/Running\s+RadialArchiver\s+(\d\d)\.(\d)\.(\d)/)
     	{ 
     		unless (($1.$2.$3) >= 1133) { print "\n*****Error:Older RadialArchiver version($1.$2.$3) detected.\nRadialArchiver version 11.3.3 or higher is required.\nAborted Processing.\n";$out = `osascript -e '$filelabel'`; exit;}
     	}
     	
     	if ($cmdlineSAmove == 1)
     	{
     		my $execStr = "$procToolsFolder/SpectraArchiver 2";
     		my $output = `$execStr`;
     		if ($output =~ m/Running\s+SpectraArchiver\s+(\d\d)\.(\d)\.(\d)/)
     		{ 
     		unless (($1.$2.$3) >= 1131) { print "\n*****Error:Older SpectraArchiver version($1.$2.$3) detected.\nSpectraArchiver version 11.3.1 or higher is required.\nAborted Processing.\n";$out = `osascript -e '$filelabel'`; exit;}
     		}
     	}
     
		# Usage: CheckForSpectra  <nDiag> <sSourceFolder> <sProcFolder> <sOutFile> <sSpectra>
		# Passing each CS file in the parent folder to CheckForSpectra instead of previous method of passing
		# files only from the main sub-folder.
		my $execStr = "$procToolsFolder/CheckForSpectra 10 \"$CosProcFolder/\" \"$CosProcFolder/\" \"\" $flist{$csfile}";
		my $csoutput = `$execStr`;
	
     if (($csoutput =~ m/-50/) | ($csoutput =~ m/key\s*is\s*missing/i) | ($csoutput =~ m/Radial\s*[sS]uite\s*not\s*authorized/i))
        {  
        foreach (@logtargets){printf { $_ } "\n\nSeaSonde License Key with an authorized license not detected!\nContact CODAR support if you do not have a License key.\n\n*****Aborted Processing.*****\n\n";}
        $out = `osascript -e '$filelabel'`;
        exit;
        }
     else
        {
          if ( $csoutput =~ m/SeaSonde\s*service\s*needs\sto\sbe\sinstalled/i)
          {
          foreach (@logtargets){printf { $_ } "\n\nSeaSonde Service is not installed.\nRun InstallBillsScripting installer from $ssservicefolder\n\n*****Aborted Processing.*****\n";}
          $out = `osascript -e '$filelabel'`;
          exit;
          }
        }
        
     if ($csoutput =~ m/Running CheckForSpectra (\d\d)\.(\d)\.(\d)/)
     	{	
     		unless (($1.$2.$3) >= 1130) { print "Older CheckForSpectra version($1.$2.$3) detected.\nCheckForSpectra version 11.3.0 or higher is required.\nAborted Processing\n.";$out = `osascript -e '$filelabel'`;exit;}
     	}
     	
		foreach (@logtargets){printf { $_ } "  %s - %s (%d of %d) %3.1f%%\n", strftime("%T", localtime), $csfile, $filesProcessed, $#cssToProcess+1, ($filesProcessed/($#cssToProcess+1))*100;}
		
		## SpectraDoubler args: Usage <nDiagnostic> <sCSFile> <sOutFile> <nMode> <bProc> <bMultDoppler> <bMultRange>
		if (($doDopplerInterp > 1) | ($doRangeInterp > 1))
		{ my $execStr = "$procToolsFolder/SpectraDoubler $diagSDB \"$CosProcFolder/\" \"$CosProcFolder/\" 0 1 $doDopplerInterp $doRangeInterp";
		  my $output = `$execStr`;
		}
		
		#open(FLOG, ">>", $full_logfile) or die "$!\n"; 		# open/create log file
		foreach (FLOG){printf { $_ } "$output\n";}
		
		## Handle Merge CSSs for CSA which is necessory for Waves and for Alim in Currents tool
		if (-e $CosProcSpectraAver) {rename $CosProcSpectraAver, $CosProcSpectraAver.'.old';} 

		# SpectraSlider args: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder> <sCSAFolder> <bMakeCSA>
		my $execStr = "$procToolsFolder/SpectraSlider $diagSS $timeCoverage $timeOutput $timeOutput 1 0 \"$configsFolder/\" \"$CosProcFolder\" \"\" 0";
		
		#  print "SpectraSlider arguments are:\n";
# 		print "$execStr\n";
# 		exit;
		my $output = `$execStr`;
		foreach (FLOG){printf { $_ } "$output\n";}

		######################################################################
		#### #### #### ####     Radial Processing	  #### #### #### #### #### 
		######################################################################

		if ($doRads or $doShortRads) {
		
			foreach $pattType (@pattsToUse) {
				if ($pattType eq 'ideal') {
					$suffix=".ideal";
					$procChar="i";
					$shortChar="x";
					$oldChar="s";
					$csaChar="_";
					$metChar="v";
					$patt=0;
					$radType=1;
				} elsif ($pattType eq 'meas') {
					$suffix=".meas";
					$procChar="m";
					$shortChar="y";
					$oldChar="z";
					$csaChar="p";
					$metChar="w";
					$patt=1;
					$radType=2;
				}
				
				$outSaveBase="/"."Rdl".$procChar."XXXX_00_00_00_0000";
	
				## SpectraToRadial args: <bAppend> <bPattern> <sSuffix> <nDiag> <bWaveOnly> <sCfgFolder> <sProcFolder> <nAlim> <nBragg> <bKeepPatEnds> <nDopInterp> <nMetric>
				my $execStr = "$procToolsFolder/SpectraToRadial 0 $patt \"$suffix\" $diagSTR 0 \"$configsFolder/\" \"$CosProcFolder/\" 0 $UseBragg -1 0 -1 $doDopplerInterp";
				#$CosExec/SpectraToRadial 0 "$patt" "$suffix" "$diagSTR" "$waveOnly" "$cfgFolder" "$procFolder" "$bUseIntFOL" "$bUseBragg" -1 "$nDoppClassic" -1 "$nDopplerInterp"

				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				$didCurrent=1;
				
				## RadialDiagnostic args: <nDiag> <nRadType> <sProcFolder> <sDiagFolder> <sCfgFolder>
				$execStr = "$procToolsFolder/RadialDiagnostic $diagRD $radType \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder\"";
				$output = `$execStr`;				
				foreach (FLOG){printf { $_ } "$output\n";}
				
				### below section disabled for R8 by HP but re-enabled by SMH ###
				################## RadialMetric output  #################
				if ($doRadialMetric > 0)
 				{ 
				    ### SMH added running SpectraToRadialMetric here now required in SSR8 for RM output ###
				    ## SpectraToRadialMetric args: <bAppend> <bPattern> <sSuffix> <nDiag> <bWaveOnly> <sCfgFolder> <sProcFolder> <nAlim> <nBragg> <bKeepPatEnds> <nDopInterp> <nMetric>
				   my $execStr = "$procToolsFolder/SpectraToRadialMetric 0 $patt \"$suffix\" $diagSTR 0 \"$configsFolder/\" \"$CosProcFolder/\" 0 $UseBragg -1 0 -1 $doDopplerInterp 0";
 				   my $output = `$execStr`;
 				   foreach (FLOG){printf { $_ } "$output\n";}
				   
				   ## New RadialArchiver args: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder> <bRadInfo> <bRadSource> <nMultDoppler> <nMultRange> <outputResponseFolder>
				   ## RadialArchiver args: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder> <bRadInfo> <bRadSource>
				   my $execStr = "$procToolsFolder/RadialArchiver $diagRA \"$metChar\" \"RadD\" \"$CosRadialMetricFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder\" $patt \"$CosDiagFolder\" 1 1 $doDopplerInterp $doRangeInterp";
 				   my $output = `$execStr`;
 				   foreach (FLOG){printf { $_ } "$output\n";}
				}
				#########################################################
			
				if ($doShortRads) 
				{
					## Usage: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
					my $execStr = "$procToolsFolder/RadialArchiver $diagRA \"$shortChar\" \"RadD\" \"$CosShortRadialFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder\" $patt \"$CosDiagFolder\" 1 0 $doDopplerInterp $doRangeInterp";
					my $output = `$execStr`;
					foreach (FLOG){printf { $_ } "$output\n";}
					&DoRadialImage("Radial_Short_$pattType",$doImageRadialLatest,$doImageRadialShortSerial);					
			
					if ($doRadialFiller)
					# Usage: RadialFiller <nDiag> <bPattern> <sCfgFold> <sProcFold>
					{
						copy($CosProcRadResult,$CosProcFolder.$outSaveBase."sr.rv");
						my $execStr = "$procToolsFolder/RadialFiller $diagRF $patt \"$configsFolder\" \"$CosProcFolder/\"";
						my $output = `$execStr`;
						foreach (FLOG){printf { $_ } "$output\n";}
						my $execStr = "$procToolsFolder/RadialArchiver $diagRA \"$shortChar\" \"RadD\" \"$CosRadialShortFilterSubFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" \"$outputLLUV\" 0 \"$configsFolder\" $patt \"$CosDiagFolder\" 1 0 $doDopplerInterp $doRangeInterp";
				   		my $output = `$execStr`;
				   		foreach (FLOG){printf { $_ } "$output\n";}
				   		#system($execStr);
				   		
				        copy($CosProcRadResult,$CosProcFolder.$outSaveBase."rg.rv");
						rename $CosProcFolder.$outSaveBase."sr.rv",$CosProcRadResult;
					}
				}
		
				if ($doRads) 
				{
					## RadialSlider args: <nDiagnostic> <sSuffix> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
					my $execStr = "$procToolsFolder/RadialSlider $diagRS \"$suffix\" $timekeep $timeCoverage $timeOutput $IgnoreSpan $OffsetMin \"$configsFolder/\" \"$CosProcFolder/\"";
					my $output = `$execStr`;
					foreach (FLOG){printf { $_ } "$output\n";}
					#rename $CosProcRadResult, $CosProcFolder.$outSaveBase."sr.rv"; #HP
					unless ($?) 
					{  # ----- 1st unless
					    # if $? (status from most recent system call) is zero, then merge radials
					    #rename $CosProcFolder.$CosProcRadResult, $CosProcFolder.$outSaveBase."sr.rv";
						#print "Reached before the last rename statement";
						#print "Reached the end of last rename statement";

						## Usage: RadialMerger <nDiag> <fSpanMinutes> <sRadListFile> <sCfgFolder> <sProcFolder>
						my $execStr = "$procToolsFolder/RadialMerger $diagRM $timeOutput \"$CosProcRadListFile$suffix\" \"$configsFolder/\" \"$CosProcFolder/\" 1"; 
						my $output = `$execStr`;
						foreach (FLOG){printf { $_ } "$output\n";}
					  unless ($?)
					    {  # ----2nd unless
						$rt=$radType + 4;
						## Usage: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
						$execStr = "$procToolsFolder/RadialDiagnostic $diagRD $rt \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder\"";
						$output = `$execStr`;
						foreach (FLOG){printf { $_ } "$output\n";}
						
						## Usage: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
						#$execStr = "$procToolsFolder/RadialArchiver 10 \"$oldChar\" \"RadD\" \"$CosRadialFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 1 \"$configsFolder/\" $patt \"$CosDiagFolder/\" $doDopplerInterp $doRangeInterp";
						$execStr = "$procToolsFolder/RadialArchiver $diagRA \"$oldChar\" \"RadD\" \"$CosRadialFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder/\" $patt \"$CosDiagFolder/\" 0 0 $doDopplerInterp $doRangeInterp";
						$output = `$execStr`;	
						foreach (FLOG){printf { $_ } "$output\n";}
						$Radialimagecreated = &DoRadialImage("Radial_$pattType",$doImageRadialLatest,$doImageRadialSerial);
						
							if ($doRadialFiller)
							# Usage: RadialFiller <nDiag> <bPattern> <sCfgFold> <sProcFold>
							{
								copy($CosProcRadResult,$CosProcFolder.$outSaveBase."rm.rv");
								my $execStr = "$procToolsFolder/RadialFiller $diagRF $patt \"$configsFolder\" \"$CosProcFolder/\"";
								my $output = `$execStr`;
								foreach (FLOG){printf { $_ } "$output\n";}
								my $execStr = "$procToolsFolder/RadialArchiver $diagRA \"$oldChar\" \"RadD\" \"$CosRadialFilterSubFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder\" $patt \"$CosDiagFolder\" 0 0 $doDopplerInterp $doRangeInterp";
				   				my $output = `$execStr`;
				   				foreach (FLOG){printf { $_ } "$output\n";}
				       			copy($CosProcRadResult,$CosProcFolder.$outSaveBase."rh.rv");
								rename $CosProcFolder.$outSaveBase."rm.rv",$CosProcRadResult;
							}
							
						$output =~ /Writing LLUV (RDL.+)/;
						foreach (@logtargets) {printf { $_ } "  **Merged Radial: %s\n", $1;}
						
						rename $CosProcRadFile,$CosProcRadSaveFile;
						copy($CosProcRadResult,$CosProcFolder.$outSaveBase."rm.rv");
						} #---2nd unless ($?)
						else { unlink $CosProcFolder."/RadialSliderOutTime.txt$suffix";}  #else block for 2nd unless
						$didRadMerge=1;
					  } #  --- 1st unless ($?) 
					  
				      else #else block for 1st unless
				      {
				      	if ($waveonly = 0)
				      		{
				      			$rt = $radType +16;
				      			## Usage: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
								$execStr = "$procToolsFolder/RadialDiagnostic $diagRD $rt \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder\"";
								$output = `$execStr`;
								foreach (FLOG){printf { $_ } "$output\n";}
								## Usage: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
								$execStr = "$procToolsFolder/RadialArchiver $diagRA \"$csaChar\" \"RadD\" \"$CosRadialFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder/\" $patt \"$CosDiagFolder/\" 1 0 $doDopplerInterp $doRangeInterp";
								$output = `$execStr`;
								foreach (FLOG){printf { $_ } "$output\n";}	
								$Radialimagecreated = &DoRadialImage("Radial_$pattType",$doImageRadialLatest,$doImageRadialSerial);
								rename $CosProcRadFile,$CosProcRadSaveFile;
							}
						}
			
				}
				copy($CosProcFolder."/RadialInfo.txt",$CosProcFolder."/RadialInfoOld.txt");
				copy($CosProcFolder."/RadialDiagNew.txt",$CosProcFolder."/RadialDiag.txt");
				copy($CosProcFolder."/ALim.txt",$CosProcFolder."/ALim$suffix.txt");
				copy($CosProcFolder."/FirstOrderLimits.txt",$CosProcFolder."/FirstOrderLimits$suffix.txt");
				if ($SAmove == 3){copy($CosProcFolder."/FirstOrderLimits.txt",$CosFirstOrderFolder."/FOL_".$fsite."_".$ftime.".txt");}
				copy($CosProcFolder."/NoiseFloor.txt",$CosProcFolder."/NoiseFloor$suffix.txt");
		
				if (-e $CosProcFolder."/CsMark.txt")    {rename $CosProcFolder."/CsMark.txt", $CosProcFolder."/CsMark$suffix.txt";}
				if (-e $CosProcFolder."/IrMarkNew.txt") {rename $CosProcFolder."/IrMarkNew.txt", $CosProcFolder."/IrMark$suffix.txt";}
				if (-e $CosProcFolder."/IrListNew.txt") {rename $CosProcFolder."/IrListNew.txt", $CosProcFolder."/IrList$suffix.txt";}
	
			} ## foreach (@pattsToUse) 	
		} ## if ($doRads or $doShortRads...)
		
		######################################################################
		#### #### #### ####    Elliptical Processing  #### #### #### #### #### 
		######################################################################
		if ($doEllipticals == 1)
		{$ellipticalresults = &runellipticalprocessing}

  		
		######################################################################
		#### #### #### ####       Wave Processing 	  #### #### #### #### #### 
		######################################################################

		if ($doWaves and $doingCSS) {

			# Usage: WaveModelForFive <nDiag> <sCfgFolder> <sOutFolder> <sProcFolder>'			
			my $execStr = "$procToolsFolder/WaveModelForFive $diagWMFF \"$configsFolder/\" \"$configsFolder/\" \"$CosProcFolder/\"";
			my $output = `$execStr`;
			foreach (FLOG){printf { $_ } "$output\n";}
			
			if ($output =~ /Computing new wave cutoff/) {
				foreach (@logtargets) {print { $_ } "Created New WaveForFiveModel.txt\n";}
				# Copy new WMFF file to processing folder w/ time stamp on it
				copy($configsFolder."/WaveForFiveModel.txt",$CosProcFolder."/WFFM_$fsite_$ftime.txt");
				foreach (@logtargets) {print { $_ } "Copied new WaveForFiveModel.txt to $CosProcFolder/WFFM_$fsite_$ftime.txt\n";}
				}
			
			@filesToDelete = (	$CosProcFolder."/WaveModelData.txt",
								$CosProcFolder."/WavesModelData.txt",
								$CosProcFolder."/WaveModelProcessed.txt",);
			unlink @filesToDelete;
			
			rename $CosProcFolder."/WavesModelPrevRanged.txt", $CosProcFolder."/WavesModelPrevRangedSave.txt";
			rename $CosProcFolder."/WavesModelPrevFinal.txt", $CosProcFolder."/WavesModelPrevFinalSave.txt";
			rename $CosProcFolder."/WavesModelDataRanged.txt", $CosProcFolder."/WavesModelDataRangedSave.txt";
			rename $CosProcFolder."/WavesModelDataFinal.txt", $CosProcFolder."/WavesModelDataFinalSave.txt";
	
				## Usage: <nDiag> <sCfgFolder> <sProcFolder>
				my $execStr = "$procToolsFolder/SpectraToWavesModel $diagSTWM \"$configsFolder/\" \"$CosProcFolder/\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				
			if (-e $CosProcFolder."/WavesModelData.txt") {
				copy($CosProcFolder."/WavesModelData.txt",$CosProcFolder."/WavesModelDataSave.txt");
				}
			
			################This section from R7 commented out ################	
			## Usage: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder> <nMinAvePts> <nMethod>
			#$execStr = "$procToolsFolder/WaveModelSlider $diagWMS 1440 \"\" \"\" \"\" \"\" \"$configsFolder/\" \"$CosProcFolder/\" 1 \"\""; 
			#$output = `$execStr`;
			#foreach (FLOG){printf { $_ } "$output\n";}
			###################################################################
			
				## Usage: <nDiag> <sSuffix> <sOwner> <sWaveFolder> <sProcFolder> <sCfgFolder>
				my $execStr = "$procToolsFolder/WaveModelArchiver $diagWMA \"U\" 0 \"$CosWaveRawFolder\" \"$CosProcFolder/\" \"$configsFolder/\"";
			    my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				
			    ## Usage: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder> <nMinAvePts> <nMethod>
				my $execStr = "$procToolsFolder/WaveModelFilter $diagWMS 44640 \"\" \"\" \"\" \"\" \"$configsFolder/\" \"$CosProcFolder/\" 1 \"\""; 
				my $output = `$execStr`;
				$returnstatus = $?;
				$waveNotReady = $returnstatus/256;
				foreach (FLOG){printf { $_ } "$output\n";}
			### stopping here now
			
			if (($waveNotReady == 2) || ($waveNotReady == 3))
			{
				## Usage: <nDiag> <sSuffix> <sOwner> <sWaveFolder> <sProcFolder> <sCfgFolder> <sWaveFile>
				my $execStr = "$procToolsFolder/WaveModelArchiver $diagWMA \"R\" 0 \"$CosWaveFiltFolder\" \"$CosProcFolder/\" \"$configsFolder/\" \"WavesModelPrevRanged.txt\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				my $execStr = "$procToolsFolder/WaveModelArchiver $diagWMA \"\" 0 \"$CosWaveFinalFolder\" \"$CosProcFolder/\" \"$configsFolder/\" \"WavesModelPrevFinal.txt\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
			}
			
			if (($waveNotReady == 1) || ($waveNotReady == 3))
			{
				## Usage: <nDiag> <sSuffix> <sOwner> <sWaveFolder> <sProcFolder> <sCfgFolder> <sWaveFile>
				my $execStr = "$procToolsFolder/WaveModelArchiver $diagWMA \"R\" 0 \"$CosWaveFiltFolder\" \"$CosProcFolder/\" \"$configsFolder/\" \"WavesModelDataRanged.txt\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				my $execStr = "$procToolsFolder/WaveModelArchiver $diagWMA \"\" 0 \"$CosWaveFinalFolder\" \"$CosProcFolder/\" \"$configsFolder/\" \"WavesModelDataFinal.txt\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
			}
			
			$wave1File = $CosProcFolder."/WaveModelProcessed.txt";
    		
   				open (FIDW, "< $wave1File");
    			$file1 = <FIDW>;
    			$file2 = <FIDW>;
   				close FIDW;
    
   				chomp($basename1wave = $file1);
    			$mainwave1File = $basename1wave;
    			my ($wave1NameWithoutExtension)=$basename1wave=~/(WVL.+)\.\w+/;
   				$wave2File = $CosProcFolder."/WaveModelProcessed.txt";
    
    			chomp($basename2wave = $file2);
    			$mainwave2File = $basename2wave;
  
  ######### Below section from R7 disabled ##########  				 
		# 	unless ($?) {
# 				## Usage: <nDiag> <sSuffix> <sOwner> <sWaveFolder> <sProcFolder> <sCfgFolder>
# 				my $execStr = "$procToolsFolder/WaveModelArchiver $diagWMA \"\" 0 \"$CosWaveFolder\" \"$CosProcFolder/\" \"$configsFolder/\"";
# 				my $output = `$execStr`;
# 				foreach (FLOG){printf { $_ } "$output\n";}
# 				$wave1File = $CosProcFolder."/WaveModelProcessed.txt";
#     		
#    					 open (FIDW, "< $wave1File");
#     				 $file1 = <FIDW>;
#     				 $file2 = <FIDW>;
#    					 close FIDW;
#     
#    					 chomp($basename1wave = $file1);
#     				 $mainwave1File = $basename1wave;
#     				 my ($wave1NameWithoutExtension)=$basename1wave=~/(WVL.+)\.\w+/;
#    					 $wave2File = $CosProcFolder."/WaveModelProcessed.txt";
#     
#     				 chomp($basename2wave = $file2);
#     				 $mainwave2File = $basename2wave;
# 						}
			
			#######Optional Image Outputs
			##
			## Optional Wave Plots
			##
			if (($doAllImage != 0) && (-e $CosWaveImageTool))
			{
				$plist = "";
				if (-e $WDplist) { $plist = "-plist=\"$WDplist\"";} 
				if (-e $CosWaveImagePrefFile) { $plist = "-plist=\"$CosWaveImagePrefFile\"";} 
							    
			    if (($doImageWaveSerial != 0) && ($imageWaveCell1 > 0))
			    { $q1 = "-rangecell=1, $imageWaveCell1 -imagefile=\"${CosImageWaveSerialFolder}/${wave1NameWithoutExtension}_RC${imageWaveCell1}.png\" -plot";}
			    else {$q1 = "";}
			    
			    if (($doImageWaveSerial != 0) && ($imageWaveCell2 > 0))
			    { $q2 = "-rangecell=1, $imageWaveCell2 -imagefile=\"${CosImageWaveSerialFolder}/${wave1NameWithoutExtension}_RC${imageWaveCell2}.png\" -plot";}
			    else {$q2 = "";}
				
				if (($doImageWaveSerial != 0) && ($imageWaveCell3 > 0))
			    { $q3 = "-rangecell=1, $imageWaveCell3 -imagefile=\"${CosImageWaveSerialFolder}/${wave1NameWithoutExtension}_RC${imageWaveCell3}.png\" -plot";}
			    else {$q3 = "";}
			
				if ($doImageWaveSerial != 0)
				{
					my $execStr = "$CosWaveImageTool $mainwave1File $mainwave2File $plist -size=600,300 -pad=0,10,30,0 \ -timespan=$imageWaveSpan -depth=16 -multirange=off -axis=1,1 -axis=2,2 -axis=3,3 -axis=4,4\ $q1 $q2 $q3";
				}
			}
		
		## Optional Spectra Plots use new SpectraPlotterMap SPMTool
########################################################################
    		
    open (FIDS, "< $SpectraToProcessFile");    
	@lines = <FIDS>;
 	@mainspectrafile = grep(/s*CSS/,@lines);
 	$spectraFile = $mainspectrafile[0];
    close FIDS; 
    $mainspectraFile = $spectraFile; 
    my ($spectraNameWithoutExtension)=$spectraFile=~/(CSS.+)\.\w+/;

## Optional Spectra Plots use new SpectraPlotterMap SPMTool
########################################################################

	if (($doAllImage != 0) && (-e $CosSpectraImageTool))
	{
	   $plist="";
	   if (-e $SPMplist)
	   {	
	    	$plist = "-plist=\"$SPMplist\"";
	   }
	   
	   if (-e $CosSPMPrefFile)
	   {
	   		$plist = "-plist=\"$CosSPMPrefFile\"";
	   }
	    
		if ($doImageSpectraSerial != 0) 
				{
				my $execStr = "$CosSpectraImageTool $plist -plot=map -image=\"$CosImageSpectraSerialFolder/${spectraNameWithoutExtension}.png\" $mainspectraFile";
				my $output = `$execStr`;
				}
			
		if ($doImageSpectraRangeSerial != 0) 
		{
			if ($imageSpectraRangeCell1 > 0) 
			{
				my $execStr = "$CosSpectraImageTool $plist -plot=range -point=0,$imageSpectraRangeCell1 -size=600,300 -image=\"${CosImageSpectraSerialFolder}/${spectraNameWithoutExtension}_RC${imageSpectraRangeCell1}.png\" $mainspectraFile";
				my $output = `$execStr`;
			}
			if ($imageSpectraRangeCell2 > 0) 
			{
				my $execStr = "$CosSpectraImageTool $plist -plot=range -point=0,$imageSpectraRangeCell2 -size=600,300 -image=\"${CosImageSpectraSerialFolder}/${spectraNameWithoutExtension}_RC${imageSpectraRangeCell2}.png\" $mainspectraFile";
				my $output = `$execStr`;
			}
			if ($imageSpectraRangeCell3 > 0) 
			{
				my $execStr = "$CosSpectraImageTool $plist -plot=range -point=0,$imageSpectraRangeCell3 -size=600,300 -image=\"${CosImageSpectraSerialFolder}/${spectraNameWithoutExtension}_RC${imageSpectraRangeCell3}.png\" $mainspectraFile";
				my $output = `$execStr`;
			}
		}
	} ### end of SpectraImageLoop
######################################		

	}  ## if ($doWaves and $doingCSS)
	
########################################################################
 			##########	Spectra Diagnostic	##########
########################################################################
	## Usage: <nDiagnostic> <sProcFolder> <sDiagFolder> <sCfgFolder>
	my $execStr = "$procToolsFolder/SpectraDiagnostic $diagSD \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder/\"";
	my $output = `$execStr`;
	
	if ($SAmove == 0 | $SAmove == 2)
	{
	$CosSpectraOutFolder=$targetFolder."/SpectraProcessed/";
	#Usage:  SpectraArchiver <nDiag> <sSpectraFile> <sDestFolder> <sFirstOrderFile> <sWaveFirstOrderFile> <sNoiseFile> <nFOType> <sCfgFolder> <nMultDoppler> <nMultRange> <bMove>
	my $execStr = "$procToolsFolder/SpectraArchiver $diagSA \"$CosProcFolder/\" \"$CosSpectraOutFolder\" \"\" \"\" \"\" 1 \"$configsFolder/\" $doDopplerInterp 0 $SAmove";
	my $output = `$execStr`;

	}
	
	} ## foreach (sort @cssToProcess) 

	foreach (@logtargets) {printf { $_ } "\n\nProcessing completed at %s\n", strftime($logdatefmt, localtime);}
	foreach (@logtargets) {printf { $_ } "%.1f minutes total processing time\n", (time - $^T)/60;}

# Create an empty file indicating processing has finished.
	$processing_completed = $targetFolder."/_ProcessingComplete.txt"; 
	open (COMPLETE, "> $processing_completed");
	print COMPLETE "Processing Completed.\n";
	close COMPLETE;
	
} else { ## if ($#cssToProcess >= 0) 
	foreach (@logtargets) {print { $_ } "Sorry, no $fileToProcBegins files for $siteCode site code found to process.\n";}
	$out = `osascript -e '$filelabel'`;
}

foreach (@logtargets) {print { $_ } "\n";}

close LOG;




######################################################################
##						 Subroutines								##
######################################################################

##########
		sub runellipticalprocessing
		 {
		
			foreach $pattType (@pattsToUse) {
				if ($pattType eq 'ideal') {
					$suffix=".ideal";
					$procChar="i";
					$shortChar="x";
					$oldChar="s";
					$csaChar="a";
					$metChar="v";
					$patt=0;
					$elpType=1;
				} elsif ($pattType eq 'meas') {
					$suffix=".meas";
					$procChar="m";
					$shortChar="y";
					$oldChar="z";
					$csaChar="b";
					$metChar="w";
					$patt=1;
					$elpType=2;
				}
		unlink @ElpfilesToDelete; ## Delete any previous/leftover processing files
		    
		#$dopplerbins_interp = $doDopplerInterp * $dopplerbins;

		# if (($doDopplerInterp * $dopplerbins) > 1024)
 		#{ foreach (@logtargets) {printf { $_ } "\n*****Error: Doppler Interpolation is enabled and number of interpolated doppler points is greater than 1024.\n";}$out = `osascript -e '$filelabel'`;return 1;}
        #{ 
    	## SpectraDoubler args: Usage <nDiagnostic> <sCSFile> <sOutFile> <nMode> <bProc> <bMultDoppler> <bMultRange>
        #my $execStr = "$procToolsFolder/SpectraDoubler $diagSDB \"$CosProcFolder/\" \"$CosProcFolder/\" 0 1 0 $doRangeInterp";
 	   	#my $output = `$execStr`;
		#}
        
        
			
		#Usage: CheckEllipticalSetup <nDiag> <sElpFolder> <sProcFolder> <sCfgFolder> <bPreFlight>
		my $execStr = "$procToolsFolder/CheckEllipticalSetup $diagECS \"$CosEllipticalFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" \"$configsFolder/\"";
		my $output = `$execStr`;
		print "\n*****CheckEllipticalSetup out is: $output\n";
		
		$elpstate=$?;
		foreach (FLOG){printf { $_ } "$output\n";}
		if ($output =~ /key is not installed/i) 
		{ foreach (@logtargets) {printf { $_ } "\nSeaSonde License Key with Elliptical License not detected.\n\n*****Aborted Processing*****\n";}$out = `osascript -e '$filelabel'`;exit;}
 
		if ($elpstate == 1)
		{ foreach (@logtargets) {printf { $_ } "\nSpectra to Process are no longer available.\n";}$out = `osascript -e '$filelabel'`;exit;}
		
		if ($elpstate != 0)
		{ foreach (@logtargets) {printf { $_ } "\nElliptical Configuration is not ready.\nCheck your configs & Restart processing.\n";}}

		if ($elpstate == 0)
 		{			
        if ($doingCSS > 0)
        {
        ## Usage: <bAppend> <bPattern> <sProcChar> <nDiag> <bDiagOnly> <sCfgFolder> <sProcFolder> <internalFOL> <nBragg> <nPatEnd>
        my $execStr = "$procToolsFolder/SpectraToEllipticals 0 $patt $procChar $diagSTE 0 \"$configsFolder/\" \"$CosProcFolder/\" 1 $UseBragg 0";
        my $output = `$execStr`;
        print "\n*****SpectratoEllipticals out is: $output\n";
		#exit;
        foreach (FLOG){printf { $_ } "$output\n";}
        $didElliptical=1;
        ## Usage: <nDiag> <nElpType> <sProcFolder> <sDiagFolder> <sCfgFolder>
		my $execStr = "$procToolsFolder/EllipticalsDiagnostic $diagED $elpType \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder\"";
		my $output = `$execStr`;
		print "\n*****EllipticalsDiagnostic out is: $output\n";
		
		
		foreach (FLOG){printf { $_ } "$output\n";}
		
		if ($doShortRads)
		{
			## Usage: <nDiag> <cProcChar> <sOwner> <sElpFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
			my $execStr = "$procToolsFolder/EllipticalsArchiver $diagEA \"$shortChar\" 0 \"$CosShortEllipticalFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder/\" $patt \"$CosDiagFolder/\"";
			my $output = `$execStr`;
			print "\n*****EllipticalsArchiver out is: $output\n";
			foreach (FLOG){printf { $_ } "$output\n";}
			
			&DoEllipticalImage("Elliptical_Short_$pattType",$doImageEllipticalLatest,$doImageEllipticalShortSerial);
		}
			## Usage: <nDiagnostic> <sSuffix> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
			my $execStr = "$procToolsFolder/EllipticalsSlider $diagES $procChar $timekeep $timeCoverage $timeOutput $IgnoreSpan 0 \"$configsFolder/\" \"$CosProcFolder/\"";
        	my $output = `$execStr`;
			$mergeswitch = $?;
			#exit;
			
			foreach (FLOG){printf { $_ } "$output\n";}
			rename $CosProcElpResult, $CosProcElpResult.".ste";

			unless ($mergeswitch)
			{
			## Usage: <nDiag> <fSpanMinutes> <sElpListFile> <sCfgFolder> <sProcFolder>
			my $execStr = "$procToolsFolder/EllipticalsMerger $diagEM $timeOutput $procChar \"$configsFolder/\" \"$CosProcFolder/\"";
			my $output = `$execStr`;
			foreach (FLOG){printf { $_ } "$output\n";}
			
				unless ($?)
				{
				$et = ($elpType + 4);
				## Usage: <nDiag> <nElpType> <sProcFolder> <sDiagFolder>				
				my $execStr = "$procToolsFolder/EllipticalsDiagnostic $diagED $et \"$CosProcFolder/\" \"$CosDiagFolder/\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				## Usage: <nDiag> <cProcChar> <sOwner> <sElpFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
				my $execStr = "$procToolsFolder/EllipticalsArchiver $diagEA $procChar 0 \"$CosEllipticalFolder/$CosRadSubFolder{$pattType}/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder/\" $patt \"$CosDiagFolder/\"";
				my $output = `$execStr`;
				foreach (FLOG){printf { $_ } "$output\n";}
				&DoEllipticalImage("Elliptical_$pattType",$doImageEllipticalLatest,$doImageEllipticalSerial);
				
				$output =~ /Writing.*(ELT.+)/g;
				foreach (@logtargets) {printf { $_ } "  **Merged Elliptical: %s\n", $1;}
			
				#rename $CosProcFolder.$CosProcElpResult, $CosProcFolder.$CosProcElpResult.".em";
				rename $CosProcElpResult,$CosProcElpResult.".em";

				$didElpMerge = 1;
				} ## 2nd unless 
			} ## 1st unless 
		} ##doingCSS loop ends.
		} ## elpstate loop ends.
	} ## foreach loop ends.
} ## doelliptical loop ends. Main Elliptical processing loop ends
##########

######################################################################
## Subroutine DoRadialImage "Radial_Short_$pattType" "$doImageRadialLatest" "$doImageRadialShortSerial" "$pattType" "Short"
## Create Radial Plot Image
## $_[0]: Output Filename to use for latest image
## $_[1]: Output latest if ne 0
## $_[2]: Output serial if ne 0
######################################################################
sub DoRadialImage {
    $radFile = $CosProcFolder."/RadialProcessed.txt";
    
    if (!(-e $radFile))
    { return ;}  
      
    open (FIDR, "< $radFile");
    chomp($basename = <FIDR>);
    $mainradFile = $basename;
    
    my ($NameWithoutExtension)=$basename=~/(RDL.+)\.\w+/; 
    if (($doAllImage != 0) && (-e $CosRadImageTool))
    { 
    	$plist = "";
    	if (-e $SDplist)
    	 { $plist = "-pref=\"$SDplist\"";}
    	if (-e $RDplist)
    	 { $plist = "-pref=\"$RDplist\"";}
    	
    	if (-e $CosRadialImagePrefFile)
    	 { $plist = "-pref=\"$CosRadialImagePrefFile\"";}
    	
    	unless(-e $CosImageFolder) {$out = `mkdir -p $CosImageFolder`;}	
    	#if ($_[1] != 0)
    	 #{ 
	 		#$imgoutfolder = `mkdir -p $CosImageFolder`;
	 		#$imgoutfolder = `mkdir -p $CosImageLatestFolder`;
	 		#$imgoutfile = $CosImageLatestFolder."/".$_[0].".png";	 
	 		#my $execStr2 = "$CosRadImageTool -i=$mainradFile -o=$imgoutfile -imageformat=png -site=$siteCode $plist -v";
	 		#my $csoutput = `$execStr2`;	 		 
	 	  #}
	 	 
	 	if ($_[2] != 0)
	 	  {
	 	  	  $imgoutfolder = `mkdir -p $CosImageRadialSerialFolder`;
	 	  	  $imgoutfile = $CosImageRadialSerialFolder."/".$NameWithoutExtension.".png";
	 	  	 my $execStr2 = "$CosRadImageTool -imageformat=png -site=$siteCode -o=$imgoutfile -i=$mainradFile";
			 my $csoutput = `$execStr2`;
	 	  }
	 }
	 close FIDR;
	 return;
}
######################################################################
## Subroutine DoEllipticalImage "Radial_Short_$pattType" "$doImageRadialLatest" "$doImageRadialShortSerial" "$pattType" "Short"
## Create Elliptical Plot Image
## $_[0]: Output Filename to use for latest image
## $_[1]: Output latest if ne 0
## $_[2]: Output serial if ne 0
######################################################################
sub DoEllipticalImage {
    
    $elpFile = $CosProcFolder."/EllipticalsProcessed.txt";
    
    if (!(-e $elpFile))
    { return ;}
    
    open (FIDE, "< $elpFile");
    @lines = <FIDE>;
	$count = @lines;

    if (($doAllImage != 0) && (-e $CosRadImageTool))
    {       
    	$plist = "";
    	if (-e $SDplist)
    	 { $plist = "-pref=\"$SDplist\"";}
    	if (-e $RDplist)
    	 { $plist = "-pref=\"$RDplist\"";}
    	if (-e $EDplist)
    	 { $plist = "-pref=\"$EDplist\"";}
    	if (-e $RDplist)
    	 { $plist = "-pref=\"$RDplist\"";}
    	if (-e $CosRadialImagePrefFile)
    	 { $plist = "-pref=\"$CosRadialImagePrefFile\"";} 
    	if (-e $CosEllipticalImagePrefFile)
    	 { $plist = "-pref=\"$CosEllipticalImagePrefFile\"";}
    	 
    	unless(-e $CosImageFolder) {$out = `mkdir -p $CosImageFolder`;}
    	
    	$i = 0;
    	foreach $basename(@lines)
		{
   			 $i++;   			 
     		 chomp($mainelpFile = $basename);
     		 ($NameWithoutExtension)=$basename=~/(ELT.+)\.\w+/;	
    	# if ($_[1] != 0)
#     	  { 
# 	 		 $imgoutfolder = `mkdir -p $CosImageLatestFolder`;
# 	 		 $imgoutfile = $CosImageLatestFolder."/".$_[0]."_$i".".png";
# 	 		 	 		 
# 	 		 my $execStr2 = "$CosRadImageTool -i=$mainelpFile -o=$imgoutfile -imageformat=png -site=$siteCode $plist -v";
# 	 		 my $csoutput = `$execStr2`;
# 	 	  }
	 	 
	 	if ($_[2] != 0)
	 	  {
	 	  	 $imgoutfolder = `mkdir -p $CosImageEllipticalSerialFolder`;
	 	  	 $imgoutfile = $CosImageEllipticalSerialFolder."/".$NameWithoutExtension.".png";
	 	  	 my $execStr2 = "$CosRadImageTool -imageformat=png -site=$siteCode -o=$imgoutfile -i=$mainelpFile";
			 my $csoutput = `$execStr2`;
	 	  }
	 }
	}
	 close FIDE;
	 return;
}
#####################
# Help Subroutine
#####################
sub help {
	print "\n
  BatchReprocess_R8  v 4.0  2016-08-15 (HP)
   
  ***************************** Note ******************************
  -	This new v4.0 script works with Release 8 tools only. Will not work with Release 7 or earlier Release tools. 
  -	If using R8,requires a usb License Key for operation and
  	works with CheckForSpectra v11.3.0 and above only. 
  -	Includes new R7 Radial Metric and Radial Filler processing.
  -	Image creation also possible.
  -	Elliptical processing now possible in this version 4.0. Elliptical License key required. 
  *****************************************************************
  BatchReprocess_R8 available command line options:
  -h help
  -c Path to RadialConfigs folder
       folder containing the config files to be used
  -s Path to Source folder
       folder is the top folder of the CSS (input) file search tree
  -t Path to target/desination folder
       target folder (time-stamped sub folder will contain all output)
  -d Same as -t	
  -b text (CSS_ or CSS_XXXX or CSS_XXXX_07_08_)
       filter files by matching the text at beginning of filenames
  -e text
       filter files by matching the text at the end of filenames
  -1 date string (start processing)
       only data occurring after date text string will be processed
       e.g. -1 \"yyyy/mm/dd HH:MM\"
  -2 date string (stop processing)
       only data occurring before date text string will be processed
       e.g. -2 \"yyyy/mm/dd HH:MM\"
  -p folder (SpectraProcessing)
       folder containing the processing tools to be used
  -R 0/1 Turn on/off Radial processing. Overrides the RadialConfigs setting. 
       e.g. -R 0 will turn off Radial processing. 
  -W 0/1 Turn on/off Waves processing.
  -S 0/1 Turn on/off Short-time Radials/Elliptical processing. Overrides the RadialConfigs setting. 
  -E 0/1 Turn on/off Elliptical processing. Overrides the RadialConfigs setting. 
  -M 0/1 Turn on/off Radial Metric processing. Overrides the RadialConfigs setting. 
  -D 0/2/3 Leave spectra at source with determined first order lines or Duplicate spectra to destination folder or leave untouched.
  e.g.
  > BatchReprocess_R8.pl -s /Codar/SeaSonde/Archives/Spectra -b CSS_CBBT -1 \"2007/08/22 21:00\" -R 1 -W 1 -S 0 -E 1\n\n\n"  ;
}
