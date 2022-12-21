#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

DUCK 2022
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
configpath='/Users/codar/documents/reprocess_DUCK/'
inpath='/Volumes/PASSPORT/Spectra/Duck'
outpath='/Volumes/TRANSFER/reprocess_DUCK/'

# Toggle what's processed
do_sop = True
do_qccodar = True

#################
os.chdir(outpath)

# Replace YYYY with year to process (e.g. YYYY=2018)
# Replace XXXX with next year (e.g. XXXX=2019) for December
#
# PASSPORT and TRANSFER must be mounted locally
# Test with 'ls /Volumes/PASSPORT/Spectra'
# Test with 'ls /Volumes/TRANSFER/reprocess_DUCK'
#

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/01/01 00:00" -2 "2022/02/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2022_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/02/01 00:00" -2 "2022/03/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_02"',
            ]

cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/03/01 00:00" -2 "2022/04/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/04/01 00:00" -2 "2022/05/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/05/01 00:00" -2 "2022/06/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/06/01 00:00" -2 "2022/07/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/07/01 00:00" -2 "2022/08/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/08/01 00:00" -2 "2022/09/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_08"',
            ]

cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/09/01 00:00" -2 "2022/10/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/10/03 11:00" -2 "2022/11/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_10"',
            ]

cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/11/01 00:00" -2 "2022/12/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2022/12/01 00:00" -2 "2023/01/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_2022_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2022_12"',
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
# x.extend(cmdstr07) ## only running Jan to June 2022 -- run others in 2023
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
    qccodartool + ' manual --datadir ./2022_01' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_01/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2022_02' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2022_03' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2022_04' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2022_05' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2022_06' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_06/Reprocess_qccodar_log.txt',
#     qccodartool + ' manual --datadir ./2022_07' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_07/Reprocess_qccodar_log.txt',
#     qccodartool + ' manual --datadir ./2022_08' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_08/Reprocess_qccodar_log.txt',
#    qccodartool + ' manual --datadir ./2022_09' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_09/Reprocess_qccodar_log.txt',
#    qccodartool + ' manual --datadir ./2022_10' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_10/Reprocess_qccodar_log.txt',
#    qccodartool + ' manual --datadir ./2022_11' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_11/Reprocess_qccodar_log.txt',
#    qccodartool + ' manual --datadir ./2022_12' + ' --configfile ./qccodar_DUCK_config.plist > ./2022_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

