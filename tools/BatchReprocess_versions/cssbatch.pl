#!/usr/bin/perl -w

#Load modules
use Getopt::Std;
use File::Copy;
use File::Find;
use POSIX qw(strftime);

################################################################################
sub HELP_MESSAGE {
	my ($fh) = @_;
	$fh ||= \*STDOUT;
	print $fh <<'EOH';
################################################################################
cssbatch.pl will call COS spectra processing tools found in
    /Codar/SeaSonde/Apps/RadialTools/SpectraProcessing/ -- i.e. you must have
    COS software release 5 update 2 or later installed in this location for this
    script to work. The script allows for diverse locations of CSS on an internal
    or externally mounted hard drive and speeds up processing by bypassing the 
    need for list building after each processed CSS file. At present this script
    only works for CSS files and not for any other type of COS "raw data" files 
    (i.e. CSA, CSQ, Rng, or Lvl).
    This script will generate a list of the CSS files in a given directory at the
    beginning of the process and then iteratively process each CSS file in that
    list. The script will leave these CSS files untouched.
    It has only been tested to have one process running at a time -- i.e. we don''t
    suggest spawing this script off on several different directories at once.
    Lastly in the attempt to provide the minimal amount of modification
    two parameters (configuration) files are required to run the processing. These
    are AnalysisOptions.txt and Header.txt, which are loaded from there COS default
    location in /Codar/SeaSonde/Configs/RadialConfigs/
 
Usage: cssbatch.pl [OPTIONS] <BASEDIRNAME>
 
 <BASEDIRNAME> is the directory at the base of the data hierarchy -- i.e. the default
 location is /Codar/SeaSonde/Data/Spectra/SpectraToProcess . However, this could be
 any directory for which CSS files exist, either internally or externally, and correspond
 to the configuration files found in /Codar/SeaSonde/Configs/RadialConfigs/
 
Options: [OPTIONS] are as follows:
  -h: print this help message and exit
  -v: verbose

################################################################################
Authors Chad Whalen and Daniel Atwater January 2008
Revision Notes:
080112 -- dpath2o: wave processing added, and clean up of code
080115 -- dpath2o: help message, verbosity, and functional capability

################################################################################
 
 Copyright (C) 2008
 Licence: GPL
 
################################################################################
EOH
exit 0; 
}
################################################################################
################################ MAIN ROUTINE ##################################
################################################################################
#GET OPTIONS:
use vars qw/ %opts /;
getopts('hv', \%opts);
HELP_MESSAGE() if (defined($opts{'h'}));

#For display
my $datefmt = "%F %T %Z"; #date format

#Directories
my $topFolder            = $ARGV[0];
my $CosRootFolder        = "/Codar/Seasonde";
my $CosBinFolder         = $CosRootFolder."/Apps/RadialTools/SpectraProcessing";
my $CosSetupFolder       = $CosRootFolder."/Configs/RadialConfigs";
my $CosDataFolder        = $CosRootFolder."/Data";
my $CosProcFolder        = $CosDataFolder."/Processing";
my $CosRadialFolder      = $CosDataFolder."/Radials";

#Spectral file prefix and suffix
my $fileToProcBegins = 'CSS';
my $fileToProcEnds   = '.cs4';

#Some static files in the processing folder that are easier to reference in a variable
my $CosProcRadFile     = $CosProcFolder."/RadialData.txt";
my $CosProcRadSaveFile = $CosProcFolder."/RadialDataSave.txt";
my $CosProcRadListFile = $CosProcFolder."/RadialSlider.list";
my $CosProcSpectraAver = $CosProcFolder."/SpectraSliders/CSA_AVER_00_00_00_0000";
my $CosProcRadResult   = $CosProcFolder."/RdlsXXXX_00_00_00_0000.rv";
my $nextFileOutput     = $CosProcFolder.'/SpectraToProcess.txt';

#Get rid of these files each time in the loop
my @filesToDelete = (	$CosProcRadFile,
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

#Setup some parameters just in case ...
my $timeCoverage = 75;
my $timeOutput   = 60;
my $OffsetMin    = 0;
my $IgnoreSpan   = 0;
my $pattParam    = 0; 
my $outputLLUV   = 1;	## -1=use pref, 0=classic, 1=LLUV,
my $radProc      = 1;	## 1 = on, 0 = off

## Check if AnalysisOptions file exists and get parameters from it
my($line,@params);
if (-e $CosSetupFolder."/AnalysisOptions.txt") {
	open (FID, "< $CosSetupFolder/AnalysisOptions.txt");
	$line      = <FID>;
	$line      =~ s/^\s+//;
	@params    = split(/\s+/,$line);
	$radProc   = $params[0]; #are we doing radials
	$line      = <FID>;
	$line      =~ s/^\s+//;
	@params    = split(/\s+/,$line);
	$wavProc   = $params[0]; #are we doing waves and what kind or all
	@params    = split(/\s+/,<FID>);
	$line      = <FID>;
	$line      =~ s/^\s+//;
	@params    = split(/\s+/,$line); #what type of radial are we doing or both
	$pattParam = $params[0];
	close(FID);
}

## Check if Header file exists and get parameters from it
if (-e $CosSetupFolder."/Header.txt") {
	open (FID, "< $CosSetupFolder/Header.txt");
	$line   = <FID>;
	$line   =~ s/^\s+//;
	@params = split(/\s+/,$line); 
	for (my $i = 2; $i < 21; $i++) { #do we care about this ??? it doesn't appear so
		@params = split(/\s+/,<FID>);
	}
	$line         = <FID>;
	$line         =~ s/^\s+//;
	@params       = split(/\s+/,$line);
	$timeCoverage = $params[0]; #averaging time
	$timeOutput   = $params[1]; 
	$OffsetMin    = $params[2];
	$IgnoreSpan   = $params[3];
	close(FID);
}

#Display the type of radial processing and check to see if it's valid else exit.
my(@pattsToUse);
unless ($radProc==0) {
    if ($pattParam == 0) {
        @pattsToUse = ('ideal');
        printf "%s - Processing radials using ideal pattern\n", strftime($datefmt, localtime) if defined $opts{v};
    } elsif ($pattParam == 1) {
        @pattsToUse = ('meas');
        printf "%s - Processing radials using measured pattern\n", strftime($datefmt, localtime) if defined $opts{v};
    } elsif ($pattParam == 2) {
        @pattsToUse = ('ideal', 'meas');
        printf "%s - Processing radials using ideal & measured patterns\n", strftime($datefmt, localtime) if defined $opts{v};
    } else {
        printf "!!!Unknown radial processing parameter. Must be 0, 1, or 2 ... exiting!!!\n";
        exit;
    }
} else { printf "\n--> Radials are NOT being processed <-- OK, just doing waves ...\n\n"; }

## Create master list of all files matching criteria in folder tree
printf "%s - Generating Files-To-Process List from %s\n", strftime($datefmt, localtime), $topFolder if defined $opts{v};
find \&wanted, $topFolder;
## Sub function filter for files that begin with CSS & end with .cs4
sub wanted {if ($_ =~ /^$fileToProcBegins/ & $_ =~ /$fileToProcEnds$/ & ! -d) {$flist{$_} = $File::Find::name;}}
printf "%s - File-To-Process List complete.\n", strftime($datefmt, localtime) if defined $opts{v};

## Processing Loop
my($output);
my @cssToProcess = keys %flist;
printf "%s - Begin processing %d files.\n", strftime($datefmt, localtime), $#cssToProcess+1 if defined $opts{v};
if ($#cssToProcess >= 0) {
	foreach (sort @cssToProcess) {
		unlink @filesToDelete; #get rid of the files defined in the the above array
		# Write each filename into SpectraToProcess.txt
		open (OUT, "> $nextFileOutput");
		print OUT "$flist{$_}\n";
		close (OUT);
		if (-e $CosProcSpectraAver) {rename $CosProcSpectraAver, $CosProcSpectraAver.'.old';}
		printf "%s - Processing file %s\n", strftime($datefmt, localtime), $_;
#SpectraSlider# SpectraSlider args: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sProcFolder> <sCSAFolder> <bMakeCSA>
		$output = `$CosBinFolder/SpectraSlider 1 $timeCoverage $timeCoverage $timeOutput $IgnoreSpan $OffsetMin "$CosProcFolder" "" 0`;
		printf "%s", $output if defined $opts{v};
		if ($radProc) {
			foreach $pattType (@pattsToUse) {
			    #deal with the characters first ... very important
			    my($suffix,$procChar,$shortChar,$oldChar,$csaChar,$patt,$radType);
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
				my $outSaveBase="Rdl".$procChar."XXXX_00_00_00_0000";
#SpectraToRadial## SpectraToRadial args: <bAppend> <bPattern> <sSuffix> <nDiag> <bWaveOnly> <sCfgFolder> <sProcFolder>
				$output = `$CosBinFolder/SpectraToRadial 0 $patt "$suffix" 0 0 "$CosSetupFolder/" "$CosProcFolder/"`;
			        printf "%s", $output if defined $opts{v};
#RadialDiagnostic## RadialDiagnostic args: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
				$output = `$CosBinFolder/RadialDiagnostic 0 $radType "$CosProcFolder/"`;
			        printf "%s", $output if defined $opts{v};
#RadialSlider## RadialSlider args: <nDiagnostic> <sSuffix> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
				$output = `$CosBinFolder/RadialSlider 0 "$suffix" $timeCoverage $timeCoverage $timeOutput $IgnoreSpan $OffsetMin "$CosSetupFolder/" "$CosProcFolder/"`;
			        printf "%s", $output if defined $opts{v};
				unless ($?) {  # if $? (status from most recent system call) is zero, then merge radials			
					printf "%s - Merging %s radial files.\n", strftime($datefmt, localtime), $pattType if defined $opts{v};
					rename $CosProcFolder.$CosProcRadResult, $CosProcFolder.$outSaveBase."sr.rv";
#RadialMerger## RadialMerger args: <nDiag> <fSpanMinutes> <sRadListFile> <sCfgFolder> <sProcFolder>
					$output = `$CosBinFolder/RadialMerger 0 $timeOutput "$CosProcRadListFile$suffix" "$CosSetupFolder/" "$CosProcFolder/"`;
					printf "%s", $output if defined $opts{v};
					$rt=$radType + 4;
#RadialDiagnostic## RadialDiagnostic args: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
					$output = `$CosBinFolder/RadialDiagnostic 0 $rt "$CosProcFolder" ""`;
					printf "%s", $output if defined $opts{v};
#RadialArchiver## RadialArchiver args: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
					$output = `$CosBinFolder/RadialArchiver 0 "$oldChar" "RadD" "$CosRadialFolder/" "$CosProcFolder/" $outputLLUV 1 "$CosSetupFolder/" $patt ""`;
					printf "%s", $output if defined $opts{v};
					rename $CosProcRadFile,$CosProcRadSaveFile;
					copy($CosProcFolder.$CosProcRadResult,$CosProcFolder.$outSaveBase."rm.rv");		
				} # unless ($?) 
				copy($CosProcFolder."/RadialDiagNew.txt",$CosProcFolder."/RadialDiag.txt");
				copy($CosProcFolder."/ALim.txt",$CosProcFolder."/ALim$suffix.txt");
				copy($CosProcFolder."/FirstOrderLimits.txt",$CosProcFolder."/FirstOrderLimits$suffix.txt");
				copy($CosProcFolder."/NoiseFloor.txt",$CosProcFolder."/NoiseFloor$suffix.txt");
				if (-e $CosProcFolder."/CsMark.txt")    {rename $CosProcFolder."/CsMark.txt", $CosProcFolder."/CsMark$suffix.txt";}
				if (-e $CosProcFolder."/IrMarkNew.txt") {rename $CosProcFolder."/IrMarkNew.txt", $CosProcFolder."/IrMark$suffix.txt";}
				if (-e $CosProcFolder."/IrListNew.txt") {rename $CosProcFolder."/IrListNew.txt", $CosProcFolder."/IrList$suffix.txt";}	
			} ## foreach (@pattsToUse)
		} ## if ($radProc)
		if ($wavProc>0) { #this will be an integer from zero to three
		    # First lets concern ourselves with spectral wave method
		    if (($wavProc eq 2) || ($wavProc eq 3)) {
#WaveForFive ## WaveForFive args: <nDiag>
		        $output = `$CosBinFolder/WaveForFive 1`;
			printf "%s", $output if defined $opts{v};
		        unlink $CosProcFolder."WALim.txt";
		        unlink $CosProcFolder."WaveData.txt";
#SpectraToWave ## SpectraToWave args: ?
		        $output = `$CosBinFolder/SpectraToWave 1`;
			printf "%s", $output if defined $opts{v};
#WaveArchiver ## WaveArchiver args: <nDiagnostic> <nKeepMin> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin>
		        $output = `$CosBinFolder/WaveArchiver 1`;
			printf "%s", $output if defined $opts{v};
		        copy($CosProcFolder."WALim.txt",$CosProcFolder."WALimSave.txt");
		        copy($CosProcFolder."WaveData.txt",$CosProcFolder."WaveDataSave.txt");
		    }
		    # Now lets do the new wave model fit method
		    if (($wavProc eq 1) || ($wavProc eq 3)) { #assume that disabling CSA is turned on
#WaveModelForFive ## WaveModelForFive args: ?
		        $output = `$CosBinFolder/WaveModelForFive 1`;
			printf "%s", $output if defined $opts{v};
		        unlink $CosProcFolder."WavesModelData.txt";
		        #assume only SpectraToWavesModel and not SpectraToWaveModel
#SpectraToWavesModel ## SpectraToWavesModel args: <nDiag> <sCfgFolder> <sProcFolder>
		        $output = `$CosBinFolder/SpectraToWavesModel 1`;
			printf "%s", $output if defined $opts{v};
		        copy($CosProcFolder."WavesModelData.txt",$CosProcFolder."WavesModelDataSave.txt");
#WaveModelSlider ## WaveModelSlider args: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
		        $output = `$CosBinFolder/WaveModelSlider 1 1440`;
			printf "%s", $output if defined $opts{v};
#WaveModelArchiver ## WaveModelArchiver args:  <nDiag> <sSuffix> <sOwner> <sWaveFolder> <sProcFolder> <sCfgFolder>
		        unless ($?) { $output = `$CosBinFolder/WaveModelArchiver 0`; }
		    }
		}
	} ## foreach (sort @cssToProcess) 
	printf "%s - Processing complete.\n", strftime($datefmt, localtime) if defined $opts{v};
	printf "%s - %.1f minutes total processing time.\n", strftime($datefmt, localtime), (time - $^T)/60 if defined $opts{v};
} else { ## if ($#cssToProcess >= 0) 
	printf "%s - Sorry, no %s files to process.\n", strftime($datefmt, localtime);
}
