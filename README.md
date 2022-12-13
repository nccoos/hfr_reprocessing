# hfr_reprocessing
Python scripts for reprocessing CODAR HFR for all NC stations (DUCK, HATY, CORE, OCRA) from 2003 to 2022.

### Overview
Python scripts run reprocessing from spectra to radial velocities for each site for each year (e.g. run_SITE_YYYY.py).  Each site has its own set of run scripts and CODAR RadialConfig files. Each script can run SpectraOfflineProcessing (SOP) or qccodar processing step or both. Each script has 12 command string lists that allow the processing to transition to a new set of RadialConfigs mid-month.  Each annual run script can then be tailored to follow the history of changes that occurred at the site.  These changes might include the following:
   - moving the position of the Rx antenna or changing it's orientation -- change made in `Header.txt`.
   - replacement of Rx cables or repaired cut resulting in change in phases and a new measured pattern -- change in `Phases.txt` and new `MeasPattern.txt`

Run a script from the command line 

```
$ cd /Users/codar/Documents/reprocess_HATY
$ run_HATY_2021.py
```

or place in crontab being careful that each one has time to finish before the next one starts.  

```
mm hh dd month weekday
00 13 04 08 * cd /Users/codar/Documents/reprocess_OCRA; ./run_OCRA_2022.py  2>&1
00 13 06 08 * cd /Users/codar/Documents/reprocess_OCRA; ./run_OCRA_2021.py  2>&1
```

Each run_SITE_YYYY.py takes 2-3 days to run the SpectraOfflineProcessing (4-6 hours for each month) and ~1 day to run qccodar (2 hours for each month). The above crontab example will run the run_OCRA_2022.py first with only SOP (do_sop=True) and (do_qccodar=False) on Aug 4 at 1300 so should take about 2 days, so the next script is set to run 2 days later. These times are for output generated using only the IdealPattern. The amount of time will increase (likely double) for both if processing both IdealPattern and MeasPattern output.  

### CODAR RadialConfig Settings

To enable RadialMetric output for SOP:
   - Edit line 21 of `AnalysisOptions.txt` in each RadialConfig folder /User/codar/Documents/reprocess_SITE/RadialConfigs_SITE_YYYY_MM_DD.
```
   1           !21 Enable Radial Metric Output: 0(Off), 1(Enable), 2(Enable MaxVel.)
```

To enable IdealPattern __only__ output for SOP:
   - Ensure `Phases.txt` set accordingly in each RadialConfig folder /User/codar/Documents/reprocess_SITE/RadialConfigs_SITE_YYYY_MM_DD.
   - Edit line 4 of of `AnalysisOptions.txt` in each RadialConfig folder.
```
0 0         ! 4 Antenna Pattern: 0(Ideal),1(Measured),2(Both); ForceAmplitudes: 0(Off),
```

To enable MeasPattern __only__ output for SOP:
   - Ensure correct `MeasPattern.txt` in each RadialConfig folder /User/codar/Documents/reprocess_SITE/RadialConfigs_SITE_YYYY_MM_DD.
   - Edit line 4 of of `AnalysisOptions.txt` in each RadialConfig folder.
```
1 0         ! 4 Antenna Pattern: 0(Ideal),1(Measured),2(Both); ForceAmplitudes: 0(Off),
```

##
### Setup for Offline Processing with RadialMetric Output

SSR8 requires a key file now that you obtain from CODAR.  Be sure to install SeaSonde Services on initial install to recognize key files.  Test install by running AnalyzeSpectra as you would on a CODAR site computer. 

Be sure to request these 2 things from CODAR -- not standard in SSR8u5. 
- Special key for RadialMetric ouput 
- Special addon RadialMetric R2 

Drop key file onto SeaSonde Key app.  Once the key is recognized and it has RadialMetric output allowed the SeaSondeKey app will show "Met"  and OFFLINE for the offline version of this key.

![image](https://user-images.githubusercontent.com/4511520/206293100-a4f7f8da-aea6-4040-84cb-3080a62b0841.png)

Install RadialMetric R2 addon. 
You should now see release notes and documentation  
- /Codar/RadialMetric_Notes.rtf 
- /Codar/SeaSonde/Docs/Guide_RadialMetric 

And programs added  
- /Codar/SeaSonde/Apps/Bin/RadialfromMetric 
- /Codar/SeaSonde/Apps/SpectraTools/SpectraProcessing/SpectraToRadialMetric  

#### Disable RadialResponse output with RadialMetric (RM) processing

With RadialMetric processing you still get the RM output that are 3-4 Mb each. 
/Data/RadialMetric/IdealPatthern/RDLv_HATY_YYYY_MM_DD_HHMM.ruv  

However, there is a (new) additional output file with RM called the RadialResponse File. These are huge at 30-50 Mb each.
/Data/RadialResponses/IdealPattern/ASRP_HATY_YYYY_MM_DD_HHMM.rsp

Disable generating this ouput by editing AnalyzeSpectra script in /Codar/SeaSonde/Apps/RadialTools/SpectraProcessing/  

Find original line call when RadialArchiver runs for RadialMetric that inlcudes `$outResponseFolder`

``` 
$CosExec/RadialArchiver "$diagRA" "$metChar" "RadD" "$outMetricFolder" "$procFolder" "$outputLLUV" 0 "$cfgFolder" "$patt" "$diagFolder" 1 1 "$nDopplerInterp" "$nRangeInterp" "$outResponseFolder"
``` 

Remove this ouput folder location from the command line
```
$CosExec/RadialArchiver "$diagRA" "$metChar" "RadD" "$outMetricFolder" "$procFolder" "$outputLLUV" 0 "$cfgFolder" "$patt" "$diagFolder" 1 1 "$nDopplerInterp" "$nRangeInterp"
```

#### Offline RadialMetric processing 

SpectraOfflineReprocessing app (underlying BatchReprocess_R8.pl) has the RadialMetric processing all commented out and disabled. Please see [BatchReprocess_R8_UNC.pl](https://github.com/nccoos/hfr_reprocessing/blob/main/tools/BatchReprocess_versions/BatchReprocess_R8_UNC.pl) for the chanages to make to reactivate RadialMetric processing in this script.

Besides uncommenting -- re-enabling code (in BatchReprocess_R8.pl) ) to output RadialMetric data, we added the new call that runs SpectraToRadialMetric (temporary processing files) and RadialArchiver to store and format data in /Codar/SeaSonde/Data/RadialMetric.  Note that `$outResponseFolder` is omitted in the RadialArchiver call (as done for AnalyzeSpectra script above) to avoid producing the huge RadialResponse files.

```
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
```


