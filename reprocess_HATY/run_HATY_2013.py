#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

HATY 2013
"""

import sys
import os
import re
import glob
import subprocess

############################
# Run SpectraOfflineProcessing (sop)
# for first hourly output file of each run start one hour ahead of desired output time to get all CSS (5) needed in spectra average

# paths to tools ---------------
soptool='/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R8_UNC.pl'
renametool='/Users/codar/documents/qccodar_dev/tools/run_RenameReprocess.py'

qccodartool='/Users/codar/miniconda3/envs/qccodar/bin/qccodar' # installed with pip in env 
#
# paths for data ---------------
configpath='/Users/codar/documents/reprocess_HATY/'
inpath='/Volumes/PASSPORT/Spectra/Haty'
outpath='/Volumes/TRANSFER/reprocess_HATY/'

# Toggle what's processed
do_sop = True
do_qccodar = False

#################
os.chdir(outpath)

# Replace YYYY with year to process (e.g. YYYY=2018)
# Replace XXXX with next year (e.g. XXXX=2019) for December
#
# PASSPORT and TRANSFER must be mounted locally
# Test with 'ls /Volumes/PASSPORT/Spectra'
# Test with 'ls /Volumes/TRANSFER/reprocess_HATY'
#

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/01/01 00:00" -2 "2013/02/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2013_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/02/01 00:00" -2 "2013/03/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_02"',
            ]

# Moved Rx antenna back from beach on Mar 13-14, change in Header.txt
cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/03/01 00:00" -2 "2013/03/14 14:00" -c ' + configpath + 'RadialConfigs_HATY_2013_01_01 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/03/14 15:00" -2 "2013/04/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/04/01 00:00" -2 "2013/05/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/05/01 00:00" -2 "2013/06/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/06/01 00:00" -2 "2013/07/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/07/01 00:00" -2 "2013/08/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/08/01 00:00" -2 "2013/09/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_08"',
            ]

# Change in phases on Sept 03 @ 11UTC from 40/05 to 70/35 but no info on what was done/happened in site logs 
cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/09/01 00:00" -2 "2013/09/03 09:00" -c ' + configpath + 'RadialConfigs_HATY_2013_03_14 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/09/03 11:00" -2 "2013/10/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_09_03 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/10/03 11:00" -2 "2013/11/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_09_03 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_10"',
            ]

# Frequency change on Nov 06 at 18UTC so change in Header.txt -- no change in phases
cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/11/01 00:00" -2 "2013/11/06 18:00" -c ' + configpath + 'RadialConfigs_HATY_2013_09_03 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/11/06 19:00" -2 "2013/12/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_11_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2013/12/01 00:00" -2 "2014/01/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2013_11_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_12"',
            ]

############################
# Run SOP and rename folders
############################
x = []

# extend list of command strings for each month to run
# uncomment to run the month
x.extend(cmdstr01)
x.extend(cmdstr02)
x.extend(cmdstr03)
x.extend(cmdstr04)
x.extend(cmdstr05) 
x.extend(cmdstr06)
x.extend(cmdstr07)
x.extend(cmdstr08)
x.extend(cmdstr09)
x.extend(cmdstr10)
x.extend(cmdstr11)
x.extend(cmdstr12)

if do_sop:
    print('Running SOP commands ...')
    for cmdstr in x:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

#############################
# Run qccodar -- specify config file
############################
y =  [
    qccodartool + ' manual --datadir ./2013_01' + ' --configfile ./qccodar_HATY_config.plist > ./2013_01/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_02' + ' --configfile ./qccodar_HATY_config.plist > ./2013_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_03' + ' --configfile ./qccodar_HATY_config.plist > ./2013_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_04' + ' --configfile ./qccodar_HATY_config.plist > ./2013_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_05' + ' --configfile ./qccodar_HATY_config.plist > ./2013_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_06' + ' --configfile ./qccodar_HATY_config.plist > ./2013_06/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_07' + ' --configfile ./qccodar_HATY_config.plist > ./2013_07/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_08' + ' --configfile ./qccodar_HATY_config.plist > ./2013_08/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_09' + ' --configfile ./qccodar_HATY_config.plist > ./2013_09/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_10' + ' --configfile ./qccodar_HATY_config.plist > ./2013_10/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_11' + ' --configfile ./qccodar_HATY_config.plist > ./2013_11/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2013_12' + ' --configfile ./qccodar_HATY_config.plist > ./2013_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

