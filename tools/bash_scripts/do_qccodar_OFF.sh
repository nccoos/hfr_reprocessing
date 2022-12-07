 #!/bin/bash

#  script to switch OFF do_qccodar on all the processing scripts for a given site
#  usage:
# $ switch_do_qccodar_OFF SITE
#  example:
# $ switch_do_qccodar_OFF CORE
#
now = "$(date)"
echo "==============  Current date and time %s\n" "$now\n"
SITE=$1
echo "cd ~/Documents/reprocess_${SITE}"
cd ~/Documents/reprocess_${SITE}
for filename in `ls run_????_[0-9]*.py`
do
    sed -i.bak 's/do_qccodar = True/do_qccodar = False/g' ${filename} 
    # rm -f ${filename}.bak
    ls -l ${filename}*
done
