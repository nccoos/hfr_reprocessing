 #!/bin/bash

# check how many files in YYYY_MM/Radials_qcd
# for given site and year
#
#  usage:
# $ test_check_qcd_done SITE YYYY
#  example:
# $ test_check_qcd_done CORE 2014

#
now="$(date)"
echo "==============  Current date and time %s\n" "$now\n"
SITE=$1
YYYY=$2
pattern_type="IdealPattern"
# pattern_type="MeasPattern"
months="01 02 03 04 05 06 07 08 09 10 11 12"

echo "cd /Volumes/TRANSFER/reprocess_${SITE}"
cd /Volumes/TRANSFER/reprocess_${SITE}

for mm in ${months}
do
    monthstr="${YYYY}_${mm}"
    echo "ls -1 ${monthstr}/Radials_qcd/${pattern_type} | wc"
    ls -1 ${monthstr}/Radials_qcd/${pattern_type} | wc
done
