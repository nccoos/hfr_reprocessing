#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

CORE 2018
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

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/01/01 00:00" -2 "2018/02/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2018_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/02/01 00:00" -2 "2018/03/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_02"',
            ]

cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/03/01 00:00" -2 "2018/04/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/04/01 00:00" -2 "2018/05/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/05/01 00:00" -2 "2018/06/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/06/01 00:00" -2 "2018/07/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/07/01 00:00" -2 "2018/08/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_07"',
            ]

# Tx amp power relay blows Aug 8 and Tony repaired and returned to service on Aug 30 (don't want any data inbetween as system was still running)
cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/08/01 00:00" -2 "2018/08/09 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/08/30 00:00" -2 "2018/09/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_08"',
            ]

# Hurricane Florence Sept 12-16 -- Data suspect after Sept 13 -- big waves -- Sept 14 lose loop1 and monopole noise level drops out
# We know the overwash on the island moved and buried antenna cables. Don't know status of antenna
cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/09/01 00:00" -2 "2018/09/13 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_09"',
            ]

# Don't process any of Oct Antenna/Site still down AND system was still collecting garbage data files until Oct 16
##  cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/10/03 11:00" -2 "2018/11/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_xx_xx -t '+outpath,
##             renametool + ' . "Reprocess_*" "2018_10"',
##            ]

# Nov 17 back up and running  -- New cables so change in phases, so new RadialConfig folder
cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/11/17 00:00" -2 "2018/12/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_11_16 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/12/01 00:00" -2 "2019/01/01 00:00" -c ' + configpath + 'RadialConfigs_CORE_2018_11_16 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_12"',
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
# x.extend(cmdstr07)
# x.extend(cmdstr08)
# x.extend(cmdstr09)
## x.extend(cmdstr10) # <----- system down
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
    qccodartool + ' manual --datadir ./2018_01',
    qccodartool + ' manual --datadir ./2018_02',
    qccodartool + ' manual --datadir ./2018_03',
    qccodartool + ' manual --datadir ./2018_04',
    qccodartool + ' manual --datadir ./2018_05',
    qccodartool + ' manual --datadir ./2018_06',
    qccodartool + ' manual --datadir ./2018_07',
    qccodartool + ' manual --datadir ./2018_08',
    qccodartool + ' manual --datadir ./2018_09',
##    qccodartool + ' manual --datadir ./2018_10', # <-- system down
    qccodartool + ' manual --datadir ./2018_11',
    qccodartool + ' manual --datadir ./2018_12',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

