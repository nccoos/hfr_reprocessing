#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

CORE 2021
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
configpath='/Users/codar/documents/reprocess_CORE/'
inpath='/Volumes/PASSPORT/Spectra/Core'
outpath='/Volumes/TRANSFER/reprocess_CORE/'

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
# Test with 'ls /Volumes/TRANSFER/reprocess_CORE'
#

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/01/01 00:00" -2 "2021/02/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2021_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/02/01 00:00" -2 "2021/03/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_02"',
            ]

cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/03/01 00:00" -2 "2021/04/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/04/01 00:00" -2 "2021/05/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_04"',
            ]

# NO DATA May 3 @ 1200 UTC until May 6 @ 1600 UTC
# change on May 06 @ 1600 UTC -- reset Rx cables (??) caused phase changes 
cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/05/01 00:00" -2 "2021/05/03 12:00" -c ' + configpath + 'RadialConfigs_CORE_2021_01_01 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/05/06 16:00" -2 "2021/06/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_05"',
            ]

# Tx hardware failure on June 30 @ 0900 UTC so no data after 
cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/06/01 00:00" -2 "2021/06/30 09:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_06"',
            ]
## NO DATA -- Tx hardware failure thru end of year!
cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/07/01 00:00" -2 "2021/08/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_07"',
            ]
## NO DATA -- Tx hardware failure thru end of year!
cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/08/01 00:00" -2 "2021/09/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_08"',
            ]
## NO DATA -- Tx hardware failure thru end of year!
cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/09/01 00:00" -2 "2021/10/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_09"',
            ]
## NO DATA -- Tx hardware failure thru end of year!
cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/10/03 11:00" -2 "2021/11/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_10"',
            ]
## NO DATA -- Tx hardware failure thru end of year!
cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/11/01 00:00" -2 "2021/12/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_11"',
            ]
## NO DATA -- Tx hardware failure thru end of year!
cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/12/01 00:00" -2 "2022/01/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2021_05_06 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_12"',
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
## NO DATA
## x.extend(cmdstr07)
## x.extend(cmdstr08)
## x.extend(cmdstr09)
## x.extend(cmdstr10)
## x.extend(cmdstr11)
## x.extend(cmdstr12)

if do_sop:
    print('Running SOP commands ...')
    for cmdstr in x:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

#############################
# Run qccodar -- specify config file
############################
y =  [
    qccodartool + ' manual --datadir ./2021_01',
    qccodartool + ' manual --datadir ./2021_02',
    qccodartool + ' manual --datadir ./2021_03',
    qccodartool + ' manual --datadir ./2021_04',
    qccodartool + ' manual --datadir ./2021_05',
    qccodartool + ' manual --datadir ./2021_06',
## NO DATA
##   qccodartool + ' manual --datadir ./2021_07',
##    qccodartool + ' manual --datadir ./2021_08',
##    qccodartool + ' manual --datadir ./2021_09',
##    qccodartool + ' manual --datadir ./2021_10',
##    qccodartool + ' manual --datadir ./2021_11',
##    qccodartool + ' manual --datadir ./2021_12',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

