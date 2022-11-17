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

sopstr1 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/09/01 00:00" -2 "2014/10/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_09"'
       ]

sopstr2 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/10/01 00:00" -2 "2014/11/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_10"'
       ]

sopstr3 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/11/01 00:00" -2 "2014/12/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_11"'
       ]

sopstr4 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/12/01 00:00" -2 "2015/01/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_12"'
       ]

############################
# QC and merge, and produce month summary plots

# cmdstr1 = ['../qc-codar-radialmetric/qcutils.py ./2014_09 IdealPattern',
#            '../qc-codar-radialmetric/run_LLUVMerger.py ./2014_09 IdealPattern qcd',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_09 IdealPattern codar Radials',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_09 IdealPattern qcd Radials',        
#        ]
# cmdstr2 = ['../qc-codar-radialmetric/qcutils.py ./2014_10 IdealPattern',
#            '../qc-codar-radialmetric/run_LLUVMerger.py ./2014_10 IdealPattern qcd',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_10 IdealPattern codar Radials',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_10 IdealPattern qcd Radials',        
#        ]
# cmdstr3 = ['../qc-codar-radialmetric/qcutils.py ./2014_11 IdealPattern',
#             '../qc-codar-radialmetric/run_LLUVMerger.py ./2014_11 IdealPattern qcd',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_11 IdealPattern codar Radials',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_11 IdealPattern qcd Radials',
#        ]
# cmdstr4 = ['../qc-codar-radialmetric/qcutils.py ./2014_12 IdealPattern',
#            '../qc-codar-radialmetric/run_LLUVMerger.py ./2014_12 IdealPattern qcd',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_12 IdealPattern codar Radials',
#            '../qc-codar-radialmetric/run_SeaDisplayTool.py ./2014_12 IdealPattern qcd Radials',
#        ]

############################

cmdstr1 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/06/01 00:00" -2 "2014/07/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_06"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2014_06'           
       ]

cmdstr2 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/07/01 00:00" -2 "2014/08/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_07"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2014_07'           
       ]

cmdstr3 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2014/08/01 00:00" -2 "2014/09/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2014_08"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2014_08'           
       ]

############################

cmdstr4 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2015/01/01 00:00" -2 "2015/02/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2015_01"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_01'           
       ]

cmdstr5 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2015/02/01 00:00" -2 "2015/03/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2015_02"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_02'
       ]

cmdstr6 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2015/03/01 00:00" -2 "2015/04/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2015_03"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_03'           
       ]

cmdstr7 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2015/04/01 00:00" -2 "2015/05/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2015_04"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_04'           
       ]

cmdstr8 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2015/05/01 00:00" -2 "2015/06/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2015_05"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_05'           
       ]

cmdstr9 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/LACIE/Spectra/Core -b CSS_ -1 "2015/06/01 00:00" -2 "2015/07/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2014_03_26 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2015_06"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2015_06'           
       ]

# 2017
cmdstr10 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/01/01 00:00" -2 "2017/02/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_01"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_01' 
       ]

cmdstr11 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/02/01 00:00" -2 "2017/03/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_02"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_02' 
       ]

cmdstr12 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/03/01 00:00" -2 "2017/04/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_03"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_03' 
       ]

cmdstr13 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/04/01 00:00" -2 "2017/05/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_04"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_04' 
       ]


cmdstr14 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/05/01 00:00" -2 "2017/06/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_05"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_05' 
       ]

cmdstr15 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/06/01 00:00" -2 "2017/07/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_06"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_06' 
       ]

cmdstr16 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/07/01 00:00" -2 "2017/08/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_07"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_07' 
       ]

cmdstr17 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/08/01 00:00" -2 "2017/09/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_08"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_08' 
       ]

cmdstr18 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/09/01 00:00" -2 "2017/10/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_09"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_09' 
       ]

cmdstr19 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/10/01 00:00" -2 "2017/11/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_10"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_10' 
       ]

cmdstr20 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/11/01 00:00" -2 "2017/12/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_11"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_11' 
       ]

cmdstr21 = ['/Codar/SeaSonde/Apps/RadialTools/SpectraOfflineProcessing.app/Contents/Resources/BatchReprocess_R7U1.pl -s /Volumes/TRANSFER/Spectra/Core -b CSS_ -1 "2017/12/01 00:00" -2 "2017/01/01 00:00" -c /users/codar/documents/reprocess_CORE/RadialConfigs_CORE_2017_01_01 -t /users/codar/documents/reprocess_CORE',
           '../qc-codar-radialmetric/run_RenameReprocess.py . "Reprocess_*" "2017_12"',
           '/Users/codar/anaconda/envs/qccodar/bin/qccodar manual --datadir ./2017_12' 
       ]

############################
x = []
# x.extend(sopstr1)
# x.extend(sopstr2)
# x.extend(sopstr3)
# x.extend(sopstr4)

# x.extend(cmdstr1)
# x.extend(cmdstr2)
# x.extend(cmdstr3)

# x.extend(cmdstr4)
# x.extend(cmdstr5)
# x.extend(cmdstr6)
# x.extend(cmdstr7)
# x.extend(cmdstr8)
# x.extend(cmdstr9)

# x.extend(cmdstr10)
# x.extend(cmdstr11)
# x.extend(cmdstr12)
# x.extend(cmdstr13)
# x.extend(cmdstr14) # Done already
# x.extend(cmdstr15)
# x.extend(cmdstr16)
# x.extend(cmdstr17)
# x.extend(cmdstr18)
x.extend(cmdstr19)
x.extend(cmdstr20)
x.extend(cmdstr21)

print 'Running all commands ...'
for cmdstr in x:
    print cmdstr
    subprocess.call(cmdstr, shell=True)


