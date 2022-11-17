#!/usr/bin/env python

"""
Script for running Spectra Offline Processing (SOP) and qccodar

HATY 2011
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

cmdstr01 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/01/01 00:00" -2 "2011/02/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+ outpath,
            renametool + ' . "Reprocess_*" "2011_01"',
            ]

cmdstr02 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/02/01 00:00" -2 "2011/03/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_02"',
            ]

# NO DATA -- after Mar 29 @ 16 UTC -- empty CSS
cmdstr03 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/03/01 00:00" -2 "2011/03/29 16:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_03"',
            ]
# NO DATA -- until Apr 05 @ 19 UTC -- empty CSS
# NO DATA -- after Apr 13 @ 00 UTC
cmdstr04 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/04/05 19:00" -2 "2011/04/13 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_04"',
            ]

# NO DATA -- until May 06 @ 16 UTC -- empty CSS
cmdstr05 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/05/06 16:00" -2 "2011/06/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_05"',
            ]

cmdstr06 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/06/01 00:00" -2 "2011/07/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_06"',
            ]

cmdstr07 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/07/01 00:00" -2 "2011/08/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_07"',
            ]

cmdstr08 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/08/01 00:00" -2 "2011/09/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_08"',
            ]

cmdstr09 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/09/01 00:00" -2 "2011/10/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_09"',
            ]

cmdstr10 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/10/03 11:00" -2 "2011/11/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_10"',
            ]

# Missing spectra (NO DATA from Nov 18 @ 14UTC until Nov 20 @ 17 UTC
cmdstr11 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/11/01 00:00" -2 "2011/11/18 14:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/11/20 17:00" -2 "2011/12/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_11"',
            ]

cmdstr12 = [soptool + ' -s ' + inpath + ' -b CSS_ -1 "2011/12/01 00:00" -2 "2012/01/01 00:00" -c ' + configpath + 'RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_12"',
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
    qccodartool + ' manual --datadir ./2011_01' + ' --configfile ./qccodar_HATY_config.plist > ./2011_01/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_02' + ' --configfile ./qccodar_HATY_config.plist > ./2011_02/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_03' + ' --configfile ./qccodar_HATY_config.plist > ./2011_03/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_04' + ' --configfile ./qccodar_HATY_config.plist > ./2011_04/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_05' + ' --configfile ./qccodar_HATY_config.plist > ./2011_05/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_06' + ' --configfile ./qccodar_HATY_config.plist > ./2011_06/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_07' + ' --configfile ./qccodar_HATY_config.plist > ./2011_07/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_08' + ' --configfile ./qccodar_HATY_config.plist > ./2011_08/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_09' + ' --configfile ./qccodar_HATY_config.plist > ./2011_09/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_10' + ' --configfile ./qccodar_HATY_config.plist > ./2011_10/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_11' + ' --configfile ./qccodar_HATY_config.plist > ./2011_11/Reprocess_qccodar_log.txt',
    qccodartool + ' manual --datadir ./2011_12' + ' --configfile ./qccodar_HATY_config.plist > ./2011_12/Reprocess_qccodar_log.txt',
]

if do_qccodar:
    print('Running qccodar commands ...')
    for cmdstr in y:
        print(cmdstr)
        subprocess.call(cmdstr, shell=True)

