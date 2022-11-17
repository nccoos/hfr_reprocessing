#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

DUCK YYYY
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
do_qccodar = False

#################
os.chdir(outpath)

# Replace YYYY with year to process (e.g. YYYY=2018)
# Replace XXXX with next year (e.g. XXXX=2019) for December
#
# PASSPORT and TRANSFER must be mounted locally
# Test with 'ls /Volumes/PASSPORT/Spectra'
# Test with 'ls /Volumes/TRANSFER/reprocess_DUCK'
#

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/01/01 00:00" -2 "YYYY/02/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "YYYY_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/02/01 00:00" -2 "YYYY/03/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_02"',
            ]

cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/03/01 00:00" -2 "YYYY/04/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/04/01 00:00" -2 "YYYY/05/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/05/01 00:00" -2 "YYYY/06/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/06/01 00:00" -2 "YYYY/07/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/07/01 00:00" -2 "YYYY/08/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/08/01 00:00" -2 "YYYY/09/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_08"',
            ]

cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/09/01 00:00" -2 "YYYY/10/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/10/03 11:00" -2 "YYYY/11/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_10"',
            ]

cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/11/01 00:00" -2 "YYYY/12/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "YYYY/12/01 00:00" -2 "XXXX/01/01 00:00" -c ' + configpath + 'RadialConfigs_DUCK_YYYY_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "YYYY_12"',
            ]

############################
# Run SOP and rename folders
############################
x = []

# extend list of command strings for each month to run
# uncomment to run the month
x.extend(cmdstr01)
# x.extend(cmdstr02)
# x.extend(cmdstr03)
# x.extend(cmdstr04)
# x.extend(cmdstr05) 
# x.extend(cmdstr06)
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
    qccodartool + ' manual --datadir ./YYYY_01' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_01/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_02' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_03' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_04' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_05' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_06' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_06/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_07' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_07/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_08' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_08/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_09' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_09/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_10' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_10/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_11' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_11/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./YYYY_12' + ' --configfile ./qccodar_DUCK_config.plist > ./YYYY_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

