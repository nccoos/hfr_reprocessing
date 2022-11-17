#!/usr/bin/python

"""
run_all
"""

import sys
import os
import re
import glob
import subprocess

############################
# Run SpectraOfflineProcessing (sop)
# for first hourly output file of each run start one hour ahead of desired output time to get all CSS (5) needed in spectra average

soptool='/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl'
# soptool='/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7u2.pl'
renametool='/Users/codar/documents/qc-codar-radialmetric/run_RenameReprocess.py'
outpath='/Volumes/TRANSFER/reprocess_DUCK/'

#################
os.chdir(outpath)

# 2018 -- Be sure that PASSPORT is "mounted" from New Vector by logging into New Vector under Shared resources.
#         Test with 'ls /Volumes/PASSPORT/Spectra'
cmdstr01 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/01/01 00:00" -2 "2018/02/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_01"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_01' 
            ]

cmdstr02 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/02/01 00:00" -2 "2018/03/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_02"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_02' 
            ]

cmdstr03 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/03/01 00:00" -2 "2018/04/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_03"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_03' 
            ]

cmdstr04 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/04/01 00:00" -2 "2018/05/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_04"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_04' 
            ]

# Lightning strike -- Rx cables replaced -- slight change in phases -- outage thru end of April unil May 1
cmdstr05 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/05/01 00:00" -2 "2018/06/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_05"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_05' 
            ]

cmdstr06 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/06/01 00:00" -2 "2018/07/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_06"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_06' 
            ]

cmdstr07 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/07/01 00:00" -2 "2018/08/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_07"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_07' 
            ]

cmdstr08 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/08/01 00:00" -2 "2018/09/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_08"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_08' 
            ]

cmdstr09 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/09/01 00:00" -2 "2018/10/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_09"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_09' 
            ]

cmdstr10 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/10/01 00:00" -2 "2018/11/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_10"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_10' 
            ]

cmdstr11 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/11/01 00:00" -2 "2018/12/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_11"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_11' 
            ]

cmdstr12 = [soptool + ' -s /Volumes/PASSPORT/Spectra/Duck -b CSS_ -1 "2018/12/01 00:00" -2 "2019/01/01 00:00" -c /users/codar/documents/reprocess_DUCK/RadialConfigs_DUCK_2018_05_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_12' 
            ]

############################
x = []

x.extend(cmdstr01)
x.extend(cmdstr02)
x.extend(cmdstr03)
x.extend(cmdstr04)
# x.extend(cmdstr05) 
# x.extend(cmdstr06)
# x.extend(cmdstr07)
# x.extend(cmdstr08)
# x.extend(cmdstr09)
# x.extend(cmdstr10)
# x.extend(cmdstr11)
# x.extend(cmdstr12)

print 'Running all commands ...'
for cmdstr in x:
    print cmdstr
    subprocess.call(cmdstr, shell=True)


