#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

CORE 2020
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

# NO DATA -- no signals in CSS -- not processed below
cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/01/01 00:00" -2 "2020/02/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2020_01"',
            ]

# NO DATA -- no signals in CSS -- not processed below
cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/02/01 00:00" -2 "2020/03/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_02"',
            ]

# NO DATA -- no signals in CSS -- until March 26 at 1400 UTC
cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/03/26 14:00" -2 "2020/04/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/04/01 00:00" -2 "2020/05/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/05/01 00:00" -2 "2020/06/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/06/01 00:00" -2 "2020/07/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/07/01 00:00" -2 "2020/08/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/08/01 00:00" -2 "2020/09/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_08"',
            ]

cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/09/01 00:00" -2 "2020/10/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/10/03 11:00" -2 "2020/11/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_10"',
            ]

cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/11/01 00:00" -2 "2020/12/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2020/12/01 00:00" -2 "2021/01/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2020_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2020_12"',
            ]

############################
# Run SOP and rename folders
############################
x = []

# extend list of command strings for each month to run
# uncomment to run the month
## x.extend(cmdstr01) # <--- no CSS -- do not process
## x.extend(cmdstr02) # <--- no CSS -- do not process

# x.extend(cmdstr03)
# x.extend(cmdstr04)
# x.extend(cmdstr05) 
x.extend(cmdstr06)
# x.extend(cmdstr07)
# x.extend(cmdstr08)
# x.extend(cmdstr09)
# x.extend(cmdstr10)
# x.extend(cmdstr11)
# x.extend(cmdstr12)

if do_sop:
    print('Running SOP commands ...')
    for cmdstr in x:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

#############################
# Run qccodar -- specify config file
############################
y =  [
##     qccodartool + ' manual --datadir ./2020_01', # <--- no CSS -- do not process
##     qccodartool + ' manual --datadir ./2020_02', # <--- no CSS -- do not process
    qccodartool + ' manual --datadir ./2020_03',
    qccodartool + ' manual --datadir ./2020_04',
    qccodartool + ' manual --datadir ./2020_05',
    qccodartool + ' manual --datadir ./2020_06',
    qccodartool + ' manual --datadir ./2020_07',
    qccodartool + ' manual --datadir ./2020_08',
    qccodartool + ' manual --datadir ./2020_09',
    qccodartool + ' manual --datadir ./2020_10',
    qccodartool + ' manual --datadir ./2020_11',
    qccodartool + ' manual --datadir ./2020_12',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

