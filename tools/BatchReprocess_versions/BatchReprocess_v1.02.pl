#!/usr/bin/perl
#
#  BatchReprocess.pl
#
#  Created by Chad Whelan on 2008-01-10.
#  Copyright (c) 2008. All rights reserved.
#
#	Requirements:
#		COS radial processing tools Release 5 Update 3
#	
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
#				> BatchReprocess.pl -s /Codar/SeaSonde/Archives/Spectra -b CSS_CBBT -1 "2007/08/22 21:00"
#
#	v 1.02	2008-06-20 (CWW)
#			-handles folder paths with spaces in folder names
#			-cleaned up some undeclared variables
#			-changed all of the processing tool calls to premade strings for better debugging
#			-Logs error and quits if it cannot find Header.txt or AnalysisOptions.txt
#			-Updated to support extra argument for config folder in RadialDiagnostic call
#
#
use File::Copy;
use File::Find;
use POSIX qw(strftime);
use Time::Local;

########################################################################
#### #### ####  File/Folder Configuration Defaults   #### #### #### ####  
########################################################################

$sourceFolder = "/Codar/Seasonde/Archives/Spectra";
$fileToProcBegins = 'CSS_';
$fileToProcEnds = '';
$targetFolder = "$ENV{HOME}/Desktop";
$configsFolder = '/Codar/Seasonde/Configs/RadialConfigs';
$procToolsFolder = '/Codar/Seasonde/Apps/RadialTools/SpectraProcessing';
$startTime = 0;
$stopTime = 0;

########################################################################
#### #### #### ####    Handle Command Line Args	     #### #### #### ####  
########################################################################

for (my $n = 0; $n<=$#ARGV; $n++) {
	if ($ARGV[$n] =~ /-h/) {help();exit;}
	if ($ARGV[$n] =~ /-s/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$sourceFolder = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-t/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$targetFolder = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-b/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$fileToProcBegins = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-e/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$fileToProcEnds = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-c/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$configsFolder = $ARGV[$n];}}
	if ($ARGV[$n] =~ /-t/) {$n++;if ($ARGV[$n] =~ /^-/) {$n--;next;} else {$procToolsFolder = $ARGV[$n];}}
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

$targetFolder = sprintf "%s/Reprocess_%s", $targetFolder, strftime("%y%m%d_%H%M%S", localtime $^T);
unless (-e $targetFolder) {$out = `mkdir -p $targetFolder`;}

$logfile = "$targetFolder/ReprocessLog.txt";	# Define Log File name
open(LOG, ">", $logfile) or die "$!\n"; 		# open/create log file

@logtargets = (STDOUT,LOG); # Where do messages go? (default = stdout & log file)

foreach (@logtargets) {print { $_ } "\n";}
foreach (@logtargets) {print { $_ } "CSS Reprocessing Info:\n\n";}
foreach (@logtargets) {print { $_ } "Data Source Folder:\n\t$sourceFolder\n\n";}
foreach (@logtargets) {print { $_ } "Data Target Folder:\n\t$targetFolder\n\n";}
foreach (@logtargets) {print { $_ } "Process only files Beginning with:\n\t$fileToProcBegins\n\n";}
if ($fileToProcEnds) {foreach (@logtargets) {print { $_ } "Process only files Ending with:\n\t$fileToProcEnds\n\n";}}
if ($startString) {foreach (@logtargets) {print { $_ } "Process only files time stamped at or after:\n\t$startString\n\n";}}
if ($stopString) {foreach (@logtargets) {print { $_ } "Process only files time stamped at or before:\n\t$stopString\n\n";}}
foreach (@logtargets) {print { $_ } "Use Radial Config Files from:\n\t$configsFolder\n\n";}
foreach (@logtargets) {print { $_ } "Use Spectra Processing Tools in:\n\t$procToolsFolder\n\n";}

########################################################################
#### #### #### ####  Read From Configuration Files   #### #### #### ####
########################################################################

$status = `cp -pR "$configsFolder" "$targetFolder"`;

## Config File Names
$CosOptionsFile = $configsFolder."/AnalysisOptions.txt";
$CosHeaderFile = $configsFolder."/Header.txt";

## Check if AnalysisOptions file exists and get parameters from it
if (-e $CosOptionsFile) {

	open (FID, "< $CosOptionsFile");
	
	$line = <FID>;		# Line 1: Process Radials (1/0)
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doRads = $params[0];
	
	$line = <FID>;		# Line 2: Process Waves (1/0)
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doWaves = $params[0];

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
	
	$line = <FID>;		# Line 8: Elliptical Processing: 0(Off),1(On)
	$line = <FID>;		# Line 9: Ionospheric Noise: 0(Ignore), 1(Remove Offending RangeCells)

	$line = <FID>;		# Line 10: ShortTime Rad/Ellipticals: 0(Off), 1(Output) 
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$doShortRads = $params[0];

	close(FID);
} else {
	foreach (@logtargets) {print { $_ } "Can't continue: AnalysisOptions.txt does not exist in $configsFolder\n";}
	exit;
}

## Check if Header file exists and get parameters from it
if (-e $CosHeaderFile) {
	open (FID, "< $CosHeaderFile");

	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$siteCode = $params[1];

	for (my $i = 2; $i < 21; $i++) {
		@params = split(/\s+/,<FID>);
	}

	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$timeCoverage = $params[0];
	$timeOutput = $params[1];
	$OffsetMin = $params[2];
	$IgnoreSpan = $params[3];
	
	close(FID);
} else {
	foreach (@logtargets) {print { $_ } "Can't continue: Header.txt does not exist in $configsFolder\n";}
	exit;
}

########################################################################
#### #### #### ####  Define Other Files & SubFolders #### #### #### ####
########################################################################

$outputLLUV = 1;	## -1=use pref, 0=classic, 1=LLUV,
$logdatefmt = "%F %T %Z";

## Define/Create Necessary output subfolders
$CosProcFolder = $targetFolder."/Processing";
unless (-e $CosProcFolder) {$out = `mkdir -p $CosProcFolder`;}
if ($doRads) {
	$CosRadialFolder = $targetFolder."/Radials";
	unless (-e $CosRadialFolder) {$out = `mkdir -p $CosRadialFolder`;}
	}
if ($doShortRads) {
	$CosShortRadialFolder = $targetFolder."/RadialShorts";
	unless (-e $CosShortRadialFolder) {$out = `mkdir -p $CosShortRadialFolder`;}
}
if ($doWaves) {
	$CosWaveFolder = $targetFolder."/Waves";
	unless (-e $CosWaveFolder) {$out = `mkdir -p $CosWaveFolder`;}
	}
$CosDiagFolder = $targetFolder."/Diagnostics";
unless (-e $CosDiagFolder) {$out = `mkdir -p $CosDiagFolder`;}

## Files/Folders in Processing folder
$CosProcRadFile = $CosProcFolder."/RadialData.txt";
$CosProcRadSaveFile = $CosProcFolder."/RadialDataSave.txt";
$CosProcRadListFile = $CosProcFolder."/RadialSlider.list";
$CosProcSpectraAver = $CosProcFolder."/SpectraSliders/CSA_AVER_00_00_00_0000";
unless (-e "$CosProcFolder/SpectraSliders") {$out = `mkdir -p "$CosProcFolder/SpectraSliders"`;}
$CosProcRadResult = $CosProcFolder."/RdlsXXXX_00_00_00_0000.rv";

## Some other definitions
$CosVerboseFile = $configsFolder."/AnalysisVerbocity.txt";
$nextFileOutput = $CosProcFolder.'/SpectraToProcess.txt';

## Files to delete before each CSS is processed ##
@filesToDelete = (	$CosProcRadFile,
					$CosProcFolder."/RadialInfo.txt",
					$CosProcFolder."/RadialData.txt",
					$CosProcFolder."/ALim.txt",
					$CosProcFolder."/NoiseFloorNew.txt",
					$CosProcFolder."/CsMark.txt",
					$CosProcFolder."/AmpNew.txt",
					$CosProcFolder."/PhaseNew.txt",
					$CosProcFolder."/RadialDiagInfo.txt",
					$CosProcFolder."/RadialProcessed.txt",
					$CosProcFolder."/RadialXYProcessed.txt",
					$CosProcRadResult
);
if ($pattParam == 0) {
	@pattsToUse = ('ideal');
	foreach (@logtargets) {print { $_ } "Processing radials using ideal pattern\n\n";}
} elsif ($pattParam == 1) {
	@pattsToUse = ('meas');
	foreach (@logtargets) {print { $_ } "Processing radials using measured pattern\n\n";}
} elsif ($pattParam == 2) {
	@pattsToUse = ('ideal', 'meas');
	foreach (@logtargets) {print { $_ } "Processing radials using ideal & measured patterns\n\n";}
} else {
	# Insert error handling here
}
if ($doWaves) {
	foreach (@logtargets) {print { $_ } "Processing for wave data\n\n";}
}

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
	
		if (-e $CosProcSpectraAver) {rename $CosProcSpectraAver, $CosProcSpectraAver.'.old';}
		
		foreach (@logtargets) {printf { $_ } "  Processing file: %s (%d of %d) %3.1f%%\n", $csfile, $filesProcessed, $#cssToProcess+1, ($filesProcessed/($#cssToProcess+1))*100;}
		
		# SpectraSlider args: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sProcFolder> <sCSAFolder> <bMakeCSA>
		my $execStr = "$procToolsFolder/SpectraSlider 0 $timeCoverage $timeOutput $timeOutput 1 0 \"$CosProcFolder\" \"\" 0";
		my $output = `$execStr`;


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
					$patt=0;
					$radType=1;
				} elsif ($pattType eq 'meas') {
					$suffix=".meas";
					$procChar="m";
					$shortChar="y";
					$oldChar="z";
					$csaChar="p";
					$patt=1;
					$radType=2;
				}
				
				$outSaveBase="Rdl".$procChar."XXXX_00_00_00_0000";
	
				## SpectraToRadial args: <bAppend> <bPattern> <sSuffix> <nDiag> <bWaveOnly> <sCfgFolder> <sProcFolder>
				my $execStr = "$procToolsFolder/SpectraToRadial 0 $patt \"$suffix\" 0 0 \"$configsFolder/\" \"$CosProcFolder/\"";
				my $output = `$execStr`;
				$didCurrent=1;
				
				## RadialDiagnostic args: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
				$execStr = "$procToolsFolder/RadialDiagnostic 0 $radType \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder\"";
				$output = `$execStr`;
				if ($doShortRads) {
					## Usage: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
					my $execStr = "$procToolsFolder/RadialArchiver 0 \"$shortChar\" \"RadD\" \"$CosShortRadialFolder/\" \"$CosProcFolder/\" $outputLLUV 0 \"$configsFolder\" $patt \"\"";
					my $output = `$execStr`;
				}
				
				if ($doRads) {
					## RadialSlider args: <nDiagnostic> <sSuffix> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
					my $execStr = "$procToolsFolder/RadialSlider 0 \"$suffix\" $timeCoverage $timeCoverage $timeOutput $IgnoreSpan $OffsetMin \"$configsFolder/\" \"$CosProcFolder/\"";
					my $output = `$execStr`;
				
					unless ($?) {  # if $? (status from most recent system call) is zero, then merge radials

						rename $CosProcFolder.$CosProcRadResult, $CosProcFolder.$outSaveBase."sr.rv";
						
						## Usage: RadialMerger <nDiag> <fSpanMinutes> <sRadListFile> <sCfgFolder> <sProcFolder>
						my $execStr = "$procToolsFolder/RadialMerger 0 $timeOutput \"$CosProcRadListFile$suffix\" \"$configsFolder/\" \"$CosProcFolder/\"";
						my $output = `$execStr`;
	
						$rt=$radType + 4;
						
						## Usage: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
						$execStr = "$procToolsFolder/RadialDiagnostic 0 $rt \"$CosProcFolder/\" \"$CosDiagFolder/\" \"$configsFolder\"";
						$output = `$execStr`;
						
						## Usage: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
						$execStr = "$procToolsFolder/RadialArchiver 10 \"$oldChar\" \"RadD\" \"$CosRadialFolder/\" \"$CosProcFolder/\" $outputLLUV 1 \"$configsFolder/\" $patt \"$CosDiagFolder/\"";
						$output = `$execStr`;
						$output =~ /Writing LLUV (RDL.+)/;
						foreach (@logtargets) {printf { $_ } "  **Merged radial: %s\n", $1;}
						
						rename $CosProcRadFile,$CosProcRadSaveFile;
						copy($CosProcFolder.$CosProcRadResult,$CosProcFolder.$outSaveBase."rm.rv");
						$didRadMerge=1;
				
					} # unless ($?) 
				}
				copy($CosProcFolder."/RadialDiagNew.txt",$CosProcFolder."/RadialDiag.txt");
				copy($CosProcFolder."/ALim.txt",$CosProcFolder."/ALim$suffix.txt");
				copy($CosProcFolder."/FirstOrderLimits.txt",$CosProcFolder."/FirstOrderLimits$suffix.txt");
				copy($CosProcFolder."/NoiseFloor.txt",$CosProcFolder."/NoiseFloor$suffix.txt");
		
				if (-e $CosProcFolder."/CsMark.txt")    {rename $CosProcFolder."/CsMark.txt", $CosProcFolder."/CsMark$suffix.txt";}
				if (-e $CosProcFolder."/IrMarkNew.txt") {rename $CosProcFolder."/IrMarkNew.txt", $CosProcFolder."/IrMark$suffix.txt";}
				if (-e $CosProcFolder."/IrListNew.txt") {rename $CosProcFolder."/IrListNew.txt", $CosProcFolder."/IrList$suffix.txt";}
	
			} ## foreach (@pattsToUse)
		} ## if ($doRads or ...)
		
		######################################################################
		#### #### #### ####       Wave Processing 	  #### #### #### #### #### 
		######################################################################

		if ($doWaves and $doingCSS) {

			# Usage: WaveModelForFive <nDiag> <sCfgFolder> <sOutFolder> <sProcFolder>'			
			my $execStr = "$procToolsFolder/WaveModelForFive 1 \"$configsFolder/\" \"$configsFolder/\" \"$CosProcFolder/\"";
			my $output = `$execStr`;
			
			if ($output =~ /Computing new wave cutoff/) {
				foreach (@logtargets) {print { $_ } "Created New WaveForFiveModel.txt\n";}
				# Copy new WMFF file to processing folder w/ time stamp on it
				copy($configsFolder."/WaveForFiveModel.txt",$CosProcFolder."/WFFM_$fsite_$ftime.txt");
				foreach (@logtargets) {print { $_ } "Copied new WaveForFiveModel.txt to $CosProcFolder/WFFM_$fsite_$ftime.txt\n";}
				}
			
			@filesToDelete = (	$CosProcFolder."/WaveModelData.txt",
								$CosProcFolder."/WavesModelData.txt");
			unlink @filesToDelete;
			
			# Look into second test argument on next line
			if (-e "$procToolsFolder/SpectraToWaveModel" and not -e "$procToolsFolder/SpectraToWavesModel") {
				## Usage: <nDiag> <sCfgFolder> <sProcFolder>
				my $execStr = "$procToolsFolder/SpectraToWaveModel 0 \"$configsFolder/\" \"$CosProcFolder/\"";
				my $output = `$execStr`;
			} else {
				## Usage: <nDiag> <sCfgFolder> <sProcFolder>
				my $execStr = "$procToolsFolder/SpectraToWavesModel 0 \"$configsFolder/\" \"$CosProcFolder/\"";
				my $output = `$execStr`;
			}
			
			if (-e $CosProcFolder."/WaveModelData.txt") {
				copy($CosProcFolder."/WaveModelData.txt",$CosProcFolder."/WaveModelDataSave.txt");
				}
				
			if (-e $CosProcFolder."/WavesModelData.txt") {
				copy($CosProcFolder."/WavesModelData.txt",$CosProcFolder."/WavesModelDataSave.txt");
				}
				
			## Usage: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
			$execStr = "$procToolsFolder/WaveModelSlider 0 1440 \"\" \"\" \"\" \"\" \"$configsFolder/\" \"$CosProcFolder/\"";
			$output = `$execStr`;
			
			unless ($?) {
				## Usage: <nDiag> <sSuffix> <sOwner> <sWaveFolder> <sProcFolder> <sCfgFolder>
				my $execStr = "$procToolsFolder/WaveModelArchiver 0 \"\" 0 \"$CosWaveFolder\" \"$CosProcFolder/\" \"$configsFolder/\"";
				my $output = `$execStr`;
			}
		} ## if ($doWaves and $doingCSS)

	} ## foreach (sort @cssToProcess) 

	foreach (@logtargets) {printf { $_ } "Processing complete at %s\n", strftime($logdatefmt, localtime);}
	foreach (@logtargets) {printf { $_ } "%.1f minutes total processing time\n", (time - $^T)/60;}

} else { ## if ($#cssToProcess >= 0) 
	foreach (@logtargets) {print { $_ } "Sorry, no $fileToProcBegins files to process.\n";}
}

foreach (@logtargets) {print { $_ } "\n";}

close LOG;

######################################################################
##						Subroutines									#
######################################################################

sub help {
	print "\n
  BatchReprocess.pl command line options:
  -s folder (source)
       folder is the top folder of the CSS (input) file search tree
  -t folder (target)
       target folder (time-stamped sub folder will contain all output)
  -b text (CSS_ or CSS_XXXX or CSS_XXXX_07_08_)
       filter files by matching the text at beginning of filenames
  -e text
       filter files by matching the text at  end of filenames
  -c folder (RadialConfigs)
       folder containing the config files to be used
  -p folder (SpectraProcessing)
       folder containing the processing tools to be used
  -1 date string (start processing)
       only data occurring after date text string will be processed
       e.g. -1 \"yyyy/mm/dd HH:MM\"
  -2 date string (stop processing)
       only data occurring before date text string will be processed
       e.g. -2 \"yyyy/mm/dd HH:MM\"
  -h help

  e.g.
  > BatchReprocess.pl -s /Codar/SeaSonde/Archives/Spectra -b CSS_CBBT -1 \"2007/08/22 21:00\"\n\n\n";
}

