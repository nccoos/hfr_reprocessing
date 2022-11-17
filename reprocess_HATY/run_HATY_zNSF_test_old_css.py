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

inpath='/Volumes/PASSPORT/Spectra/Haty'
outpath='/Volumes/PASSPORT/reprocess_HATY/'

#################
os.chdir(outpath)

# Replace YYYY with year to process and XXXX with next year (e.g. YYYY=2018 and XXXX=2019
#
# Be sure that PASSPORT is "mounted" from New Vector by logging into New Vector under Shared resources.
# OR PASSPORT mounted locally
# Test with 'ls /Volumes/PASSPORT/Spectra'
#


cmdstr03 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2003/12/01 00:00" -2 "2003/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2003_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2003_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2003_12' 
            ]

cmdstr04 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2004/12/01 00:00" -2 "2004/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2004_10_15 -t '+outpath,
            renametool + ' . "Reprocess_*" "2004_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2004_12' 
            ]

# no data in 2005 from mid-Aug thru Dec -- using July
cmdstr05 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2005/07/01 00:00" -2 "2005/07/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2005_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2005_07"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2005_07' 
            ]

cmdstr06 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2006/12/01 00:00" -2 "2006/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2006_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2006_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2006_12' 
            ]

cmdstr07 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2007/12/01 00:00" -2 "2007/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2007_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2007_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2007_12' 
            ]

cmdstr08 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2008/12/01 00:00" -2 "2008/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2008_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2008_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2008_12' 
            ]

cmdstr09 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2009/12/01 00:00" -2 "2009/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2009_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2009_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2009_12' 
            ]

cmdstr10 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2010/12/01 00:00" -2 "2010/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2010_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2010_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2010_12' 
            ]

cmdstr11 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2011/12/01 00:00" -2 "2011/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2011_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2011_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2011_12' 
            ]

cmdstr12 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2012/12/01 00:00" -2 "2012/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2012_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2012_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2012_12' 
            ]

cmdstr13 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2013/12/01 00:00" -2 "2013/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2013_09_04 -t '+outpath,
            renametool + ' . "Reprocess_*" "2013_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2013_12' 
            ]

cmdstr14 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2014/12/01 00:00" -2 "2014/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2014_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2014_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2014_12' 
            ]

cmdstr15 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2015/12/01 00:00" -2 "2015/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2015_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2015_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_12' 
            ]

cmdstr16 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2016/12/01 00:00" -2 "2016/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2016_06_15 -t '+outpath,
            renametool + ' . "Reprocess_*" "2016_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2016_12' 
            ]

cmdstr17 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2017/12/01 00:00" -2 "2017/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2017_10_03 -t '+outpath,
            renametool + ' . "Reprocess_*" "2017_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_12' 
            ]

cmdstr18 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2018/12/01 00:00" -2 "2018/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2018_08_02 -t '+outpath,
            renametool + ' . "Reprocess_*" "2018_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2018_12' 
            ]

cmdstr19 = [soptool + ' -s '+inpath+' -b CSS_ -1 "2019/12/01 00:00" -2 "2019/12/06 00:00" -c /users/codar/documents/reprocess_HATY/RadialConfigs_HATY_2019_01_01 -t '+outpath,
            renametool + ' . "Reprocess_*" "2019_12"',
            '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2019_12' 
            ]

############################
x = []

# x.extend(cmdstr03) # NOPE, too much uncertainty in Rx location
x.extend(cmdstr04) # OK start of reliable location Oct 15, 2004
# x.extend(cmdstr05) # OK
# x.extend(cmdstr06) # OK
# x.extend(cmdstr07) # OK
# x.extend(cmdstr08) # OK
# x.extend(cmdstr09) # OK
# x.extend(cmdstr10) # OK
# x.extend(cmdstr11) # OK
# x.extend(cmdstr12) # OK
# x.extend(cmdstr13) # OK
# x.extend(cmdstr14) # OK
# x.extend(cmdstr15) # OK
# x.extend(cmdstr16) # OK
# x.extend(cmdstr17) # OK
# x.extend(cmdstr18) # OK
# x.extend(cmdstr19) # NOPE, SS8 data throws errors in SS7


print 'Running all commands ...'
for xcmdstr in x:
    print xcmdstr
    subprocess.call(xcmdstr, shell=True)


