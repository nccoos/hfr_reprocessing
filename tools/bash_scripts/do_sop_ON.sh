#!/bin/bash

#  script to switch ON do_sop on all the processing scripts for a given site
#  usage:
# $ switch_do_sop_ON SITE
#  example:
# $ switch_do_sop_ON CORE
#
now = "$(date)"
echo "==============  Current date and time %s\n" "$now\n"
SITE=$1
echo "cd ~/Documents/reprocess_${SITE}"
cd ~/Documents/reprocess_${SITE}
for filename in `ls run_????_[0-9]*.py`
do
    sed -i.bak 's/do_sop = False/do_sop = True/g' ${filename} 
    # sed -i.bak 's/do_qccodar = False/do_qccodar = True/g' ${filename}
    # rm -f ${filename}.bak
    ls -l ${filename}*
done
