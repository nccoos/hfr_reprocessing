#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

HATY 2010
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

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/01/01 00:00" -2 "2010/02/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2010_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/02/01 00:00" -2 "2010/03/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_02"',
            ]

cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/03/01 00:00" -2 "2010/04/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_03"',
            ]

cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/04/01 00:00" -2 "2010/05/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_04"',
            ]

cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/05/01 00:00" -2 "2010/06/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/06/01 00:00" -2 "2010/07/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/07/01 00:00" -2 "2010/08/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_07"',
            ]

# NO DATA -- after Aug 05 @ 22 UTC -- monopole and loop1 out
# phase change after after this 
cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/08/01 00:00" -2 "2010/08/05 22:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_08"',
            ]

# NO DATA -- whole month -- monopole and loop1 out
## cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/09/01 00:00" -2 "2010/10/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_01_01 -t '+outpath,
##            renametool + ' . "Reprocess_*" "2010_09"',
##            ]

# NO DATA -- until Oct 22 @ 16 UTC
# new cables ?? -- phases now 40/05 
cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/10/22 16:00" -2 "2010/11/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_10_22 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_10"',
            ]

# NO DATA -- between Nov 19 @ 00 UTC until Nov 22 @ 16 UTC
cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/11/01 00:00" -2 "2010/11/19 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_10_22 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/11/22 16:00" -2 "2010/12/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_10_22 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2010/12/01 00:00" -2 "2011/01/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2010_10_22 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_12"',
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
## x.extend(cmdstr09) # <------------ no data
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
    qccodartool + ' manual --datadir ./2010_01' + ' --configfile ./qccodar_HATY_config.plist > ./2010_01/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_02' + ' --configfile ./qccodar_HATY_config.plist > ./2010_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_03' + ' --configfile ./qccodar_HATY_config.plist > ./2010_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_04' + ' --configfile ./qccodar_HATY_config.plist > ./2010_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_05' + ' --configfile ./qccodar_HATY_config.plist > ./2010_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_06' + ' --configfile ./qccodar_HATY_config.plist > ./2010_06/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_07' + ' --configfile ./qccodar_HATY_config.plist > ./2010_07/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_08' + ' --configfile ./qccodar_HATY_config.plist > ./2010_08/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_09' + ' --configfile ./qccodar_HATY_config.plist > ./2010_09/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_10' + ' --configfile ./qccodar_HATY_config.plist > ./2010_10/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_11' + ' --configfile ./qccodar_HATY_config.plist > ./2010_11/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2010_12' + ' --configfile ./qccodar_HATY_config.plist > ./2010_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

