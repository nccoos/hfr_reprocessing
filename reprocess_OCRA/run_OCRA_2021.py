#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

OCRA 2021
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
configpath='/Users/codar/documents/reprocess_OCRA/'
inpath='/Volumes/PASSPORT/Spectra/Ocra'
outpath='/Volumes/TRANSFER/reprocess_OCRA/'

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
# Test with 'ls /Volumes/TRANSFER/reprocess_OCRA'
#

# NO DATA -- not setup
cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/01/01 00:00" -2 "2021/02/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2021_01"',
            ]

# NO DATA -- not setup
cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/02/01 00:00" -2 "2021/03/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_02"',
            ]

# NO DATA -- until March 21 @ 2000 UTC
# Site Setup and online March 18-22
cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/03/21 20:00" -2 "2021/04/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/04/01 00:00" -2 "2021/05/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/05/01 00:00" -2 "2021/06/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/06/01 00:00" -2 "2021/07/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/07/01 00:00" -2 "2021/08/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/08/01 00:00" -2 "2021/09/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_08"',
            ]

cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/09/01 00:00" -2 "2021/10/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/10/03 11:00" -2 "2021/11/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_10"',
            ]

cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/11/01 00:00" -2 "2021/12/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/12/01 00:00" -2 "2021/12/03 21:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_03_21 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2021/12/03 22:00" -2 "2022/01/01 00:00" -c ' + configpath + 'RadialConfigs_OCRA_2021_12_03 -t '+outpath,
            renametool + ' . "Reprocess_*" "2021_12"',
            ]

############################
# Run SOP and rename folders
############################
x = []

# extend list of command strings for each month to run
# uncomment to run the month
## NO DATA until March 21 2021
## x.extend(cmdstr01)
## x.extend(cmdstr02)
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
##    qccodartool + ' manual --datadir ./2021_01',
##    qccodartool + ' manual --datadir ./2021_02',
    qccodartool + ' manual --datadir ./2021_03',
    qccodartool + ' manual --datadir ./2021_04',
    qccodartool + ' manual --datadir ./2021_05',
    qccodartool + ' manual --datadir ./2021_06',
    qccodartool + ' manual --datadir ./2021_07',
    qccodartool + ' manual --datadir ./2021_08',
    qccodartool + ' manual --datadir ./2021_09',
    qccodartool + ' manual --datadir ./2021_10',
    qccodartool + ' manual --datadir ./2021_11',
    qccodartool + ' manual --datadir ./2021_12',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

