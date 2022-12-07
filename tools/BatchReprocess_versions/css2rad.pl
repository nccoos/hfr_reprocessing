#!/usr/bin/perl
#
#  css2rad.pl
#
#  Created by Chad Whelan on 2008-01-10.
#  Copyright (c) 2007. All rights reserved.
#
#	Requirements:
#		COS radial processing tools Release 5 Update 3
#	
#	
#	

use File::Copy;
use File::Find;
use POSIX qw(strftime);

## Processing Configuration 
$topFolder = '/Codar/SeaSonde/Data/Spectra/SpectraToProcess';

$fileToProcBegins = 'CSS';
$fileToProcEnds = '.cs4';

$logdatefmt = "%F %T %Z";
$logdatefilename = "%Y%m%d_%H%M%S";
$logFile = sprintf "%s/Logs/SpecToRad_%s\.log", $CosRootFolder, strftime($logdatefilename, localtime);

## Assign Config, Output folders
$CosRootFolder = "/Codar/Seasonde";
$CosBinFolder = $CosRootFolder."/Apps/RadialTools/SpectraProcessing";
$CosSetupFolder = $CosRootFolder."/Configs/RadialConfigs";
$CosDataFolder = $CosRootFolder."/Data";
$CosProcFolder = $CosDataFolder."/Processing";
$CosRadialFolder = $CosDataFolder."/Radials";
$CosShortRadialFolder = $CosDataFolder."/RadialShorts";
$CosWaveFolder = $CosDataFolder."/Waves";
$CosSpectraFolder = $CosDataFolder."/Spectra";
$CosSpectraInFolder = $CosSpectraFolder."/SpectraToProcess";
$CosSpectraOutFolder = $CosSpectraFolder."/SpectraProcessed";

## Config File Names
$CosOptionsFile = $CosSetupFolder."/AnalysisOptions.txt";
$CosHeaderFile = $CosSetupFolder."/Header.txt";

## Files/Folders in Processing folder
$CosProcRadFile = $CosProcFolder."/RadialData.txt";
$CosProcRadSaveFile = $CosProcFolder."/RadialDataSave.txt";
$CosProcRadListFile = $CosProcFolder."/RadialSlider.list";
$CosProcSpectraAver = $CosProcFolder."/SpectraSliders/CSA_AVER_00_00_00_0000";
$CosProcRadResult = $CosProcFolder."/RdlsXXXX_00_00_00_0000.rv";

## Some other definitions
$CosVerboseFile = $CosSetupFolder."/AnalysisVerbocity.txt";
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

## Default parameters
$timeCoverage = 75;
$timeOutput = 60;
$OffsetMin = 0;
$IgnoreSpan = 0;
$pattParam = 0; 

$outputLLUV = 1;	## -1=use pref, 0=classic, 1=LLUV,
$radProc = 1;		## 1 = on, 0 = off

## Check if AnalysisOptions file exists and get parameters from it
if (-e $CosSetupFolder."/AnalysisOptions.txt") {

	open (FID, "< $CosSetupFolder/AnalysisOptions.txt");

	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$radProc = $params[0];
	
	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$wavProc = $params[0];

	@params = split(/\s+/,<FID>);

	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$pattParam = $params[0];

	close(FID);
}

## Check if Header file exists and get parameters from it
if (-e $CosSetupFolder."/Header.txt") {
	open (FID, "< $CosSetupFolder/Header.txt");

	$line = <FID>;
	$line =~ s/^\s+//;
	@params = split(/\s+/,$line);
	$siteCode = $params[1];

	for (my $i = 2; $i < 21; $i++) {
	# for ($i=2,$i++,$i=21) {
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
}

if ($pattParam == 0) {
	@pattsToUse = ('ideal');
	printf "%s - Processing radials using ideal pattern\n", strftime($logdatefmt, localtime);
} elsif ($pattParam == 1) {
	@pattsToUse = ('meas');
	printf "%s - Processing radials using measured pattern\n", strftime($logdatefmt, localtime);
} elsif ($pattParam == 2) {
	@pattsToUse = ('ideal', 'meas');
	printf "%s - Processing radials using ideal & measured patterns\n", strftime($logdatefmt, localtime);
} else {
	# Insert error handling here
}

printf "%s - Generating Files-To-Process List from %s\n", strftime($logdatefmt, localtime), $topFolder;

## Create master list of all files matching criteria in folder tree
find \&wanted, $topFolder;
## Sub function filter for files that begin with CSS & end with .cs4
sub wanted {if ($_ =~ /^$fileToProcBegins/ & $_ =~ /$fileToProcEnds$/ & ! -d) {$flist{$_} = $File::Find::name;}}
printf "%s - File-To-Process List complete.\n", strftime($logdatefmt, localtime);


## Processing Loop
@cssToProcess = keys %flist;
printf "%s - Begin processing %d files.\n", strftime($logdatefmt, localtime), $#cssToProcess+1;

if ($#cssToProcess >= 0) {
	foreach (sort @cssToProcess) {
	
		unlink @filesToDelete;
		
		# Write each filename into SpectraToProcess.txt
		open (OUT, "> $nextFileOutput");
		print OUT "$flist{$_}\n";
		close (OUT);
	
		if (-e $CosProcSpectraAver) {rename $CosProcSpectraAver, $CosProcSpectraAver.'.old';}
		
		printf "%s - Processing file %s\n", strftime($logdatefmt, localtime), $_;
		
		# SpectraSlider args: <nDiagnostic> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sProcFolder> <sCSAFolder> <bMakeCSA>
		$output = `$CosBinFolder/SpectraSlider 1 $timeCoverage $timeCoverage $timeOutput $IgnoreSpan $OffsetMin "$CosProcFolder" "" 0`;

		if ($radProc) {
		
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
				$output = `$CosBinFolder/SpectraToRadial 0 $patt "$suffix" 0 0 "$CosSetupFolder/" "$CosProcFolder/"`;
				$didCurrent=1;
	
				## RadialDiagnostic args: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
				$output = `$CosBinFolder/RadialDiagnostic 0 $radType "$CosProcFolder/"`;
				
				## RadialSlider args: <nDiagnostic> <sSuffix> <nKeepMins> <nCoverageMins> <nOutputMinutes> <bIgnoreSpan> <nOffsetMin> <sCfgFolder> <sProcFolder>
				$output = `$CosBinFolder/RadialSlider 0 "$suffix" $timeCoverage $timeCoverage $timeOutput $IgnoreSpan $OffsetMin "$CosSetupFolder/" "$CosProcFolder/"`;
				
				unless ($?) {  # if $? (status from most recent system call) is zero, then merge radials
			
					printf "%s - Merging %s radial files.\n", strftime($logdatefmt, localtime), $pattType;
					
					rename $CosProcFolder.$CosProcRadResult, $procFolder.$outSaveBase."sr.rv";
					
					## Usage: RadialMerger <nDiag> <fSpanMinutes> <sRadListFile> <sCfgFolder> <sProcFolder>
					$output = `$CosBinFolder/RadialMerger 0 $timeOutput "$CosProcRadListFile$suffix" "$CosSetupFolder/" "$CosProcFolder/"`;
					
					$rt=$radType + 4;
					
					## Usage: <nDiag> <nRadType> <sProcFolder> <sDiagFolder>
					$output = `$CosBinFolder/RadialDiagnostic 0 $rt "$CosProcFolder" ""`;
					
					## Usage: <nDiag> <cProcChar> <sOwner> <sRadFolder> <sProcFolder> <bLLUV> <bOpen> <sCfgFolder> <nPattern> <sDiagFolder>
					$output = `$CosBinFolder/RadialArchiver 0 "$oldChar" "RadD" "$CosRadialFolder/" "$CosProcFolder/" $outputLLUV 1 "$CosSetupFolder/" $patt ""`;
			
					rename $CosProcRadFile,$CosProcRadSaveFile;
					copy($CosProcFolder.$CosProcRadResult,$CosProcFolder.$outSaveBase."rm.rv");
					$didRadMerge=1;
			
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
		
		if ($wavProc) {
		
			######################################################################
			####
			####	Insert Wave Processing Here
			####
			######################################################################
		
		}
	} ## foreach (sort @cssToProcess) 

	printf "%s - Processing complete.\n", strftime($logdatefmt, localtime);
	printf "%s - %.1f minutes total processing time.\n", strftime($logdatefmt, localtime), (time - $^T)/60;

} else { ## if ($#cssToProcess >= 0) 

	printf "%s - Sorry, no %s files to process.\n", strftime($logdatefmt, localtime), ;

}
