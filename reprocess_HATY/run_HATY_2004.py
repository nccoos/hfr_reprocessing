#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

HATY 2004
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

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/01/01 00:00" -2 "2004/02/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2004_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/02/01 00:00" -2 "2004/03/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_02"',
            ]

# No known Rx position until March 12 
cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/03/12 00:00" -2 "2004/04/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_03_12 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/04/01 00:00" -2 "2004/05/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_03_12 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_04"',
            ]

# Move Rx May 26 -- No time indicated in 2007 notes -- 
cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/05/01 00:00" -2 "2004/05/25 23:00" -c ' + configpath + 'RadialConfigs_HATY_2004_03_12 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/05/26 00:00" -2 "2004/06/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_05_26 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/06/01 00:00" -2 "2004/07/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_05_26 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_06"',
            ]

# NO DATA -- Jul 2 @ 22 UTC until Jul 7 @ 15 UTC -- No signal in CSS
cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/07/01 00:00" -2 "2004/07/02 22:00" -c ' + configpath + 'RadialConfigs_HATY_2004_05_26 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/07/07 15:00" -2 "2004/08/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_05_26 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/08/01 00:00" -2 "2004/09/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_05_26 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_08"',
            ]

# NO DATA-- Sept 24 @ 11 UTC until end of month
cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/09/01 00:00" -2 "2004/09/24 11:00" -c ' + configpath + 'RadialConfigs_HATY_2004_05_26 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_09"',
            ]

# NO DATA -- no css -- Until Oct 15 -- Rx Moved Oct 15
cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/10/15 11:00" -2 "2004/11/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_10_15 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_10"',
            ]

cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/11/01 00:00" -2 "2004/12/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_10_15 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2004/12/01 00:00" -2 "2005/01/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2004_10_15 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_12"',
            ]

############################
# Run SOP and rename folders
############################
x = []

# extend list of command strings for each month to run
# uncomment to run the month
## x.extend(cmdstr01)
## x.extend(cmdstr02) # <-- No known position before March 12,2004
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
##     qccodartool + ' manual --datadir ./2004_01' + ' --configfile ./qccodar_HATY_config.plist > ./2004_01/Reprocess_qccodar_log.txt', # <-- No knonw Rx posn until Mar 12, 2004
##     qccodartool + ' manual --datadir ./2004_02' + ' --configfile ./qccodar_HATY_config.plist > ./2004_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_03' + ' --configfile ./qccodar_HATY_config.plist > ./2004_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_04' + ' --configfile ./qccodar_HATY_config.plist > ./2004_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_05' + ' --configfile ./qccodar_HATY_config.plist > ./2004_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_06' + ' --configfile ./qccodar_HATY_config.plist > ./2004_06/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_07' + ' --configfile ./qccodar_HATY_config.plist > ./2004_07/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_08' + ' --configfile ./qccodar_HATY_config.plist > ./2004_08/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_09' + ' --configfile ./qccodar_HATY_config.plist > ./2004_09/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_10' + ' --configfile ./qccodar_HATY_config.plist > ./2004_10/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_11' + ' --configfile ./qccodar_HATY_config.plist > ./2004_11/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2004_12' + ' --configfile ./qccodar_HATY_config.plist > ./2004_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

