#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

HATY 2018
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

#
# PASSPORT and TRANSFER must be mounted locally
# Test with 'ls /Volumes/PASSPORT/Spectra'
# Test with 'ls /Volumes/TRANSFER/reprocess_HATY'
#


cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/01/01 00:00" -2 "2018/02/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2018_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/02/01 00:00" -2 "2018/03/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_02"',
            ]

cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/03/01 00:00" -2 "2018/04/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/04/01 00:00" -2 "2018/05/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/05/01 00:00" -2 "2018/06/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/06/01 00:00" -2 "2018/07/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_06"',
            ]

# Monopole out -- data no good from July 29 at 0800 until end of month so not included
cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/07/01 00:00" -2 "2018/07/29 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_07"',
            ]

# No monopole data and new Rx loop 1 and 2 cables intalled for start of Aug 2 -- so change of phases.txt in configs
cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/08/03 00:00" -2 "2018/09/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_08_02 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_08"',
            ]

cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/09/01 00:00" -2 "2018/10/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_08_02 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/10/03 11:00" -2 "2018/11/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_08_02 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_10"',
            ]

cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/11/01 00:00" -2 "2018/12/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_08_02 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2018/12/01 00:00" -2 "2019/01/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2018_08_02 -t '+outpath,
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
    qccodartool + ' manual --datadir ./2018_01' + ' --configfile ./qccodar_HATY_config.plist > ./2018_01/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_02' + ' --configfile ./qccodar_HATY_config.plist > ./2018_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_03' + ' --configfile ./qccodar_HATY_config.plist > ./2018_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_04' + ' --configfile ./qccodar_HATY_config.plist > ./2018_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_05' + ' --configfile ./qccodar_HATY_config.plist > ./2018_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_06' + ' --configfile ./qccodar_HATY_config.plist > ./2018_06/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_07' + ' --configfile ./qccodar_HATY_config.plist > ./2018_07/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_08' + ' --configfile ./qccodar_HATY_config.plist > ./2018_08/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_09' + ' --configfile ./qccodar_HATY_config.plist > ./2018_09/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_10' + ' --configfile ./qccodar_HATY_config.plist > ./2018_10/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_11' + ' --configfile ./qccodar_HATY_config.plist > ./2018_11/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2018_12' + ' --configfile ./qccodar_HATY_config.plist > ./2018_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

