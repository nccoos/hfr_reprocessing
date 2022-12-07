#!/bin/bash
#
 
now="$(date)"
echo "==============  Current date and time %s\n" "$now"

# yyyy="2014"
# years="2015 2016 2017 2018 2019 2020"
years="2005 2006 2007 2008 2009 2010 2011 2012 2013"
months="01 02 03 04 05 06 07 08 09 10 11 12"
sites="HATY"
# sites="HATY CORE"

# test on site one month
# yyyy="2018"
# months="10"
# sites="CORE"

pattern_type=IdealPattern
# pattern_type=MeasPattern

for site in $sites
do
    sitestr=$site
    for yyyy in $years
    do
        for mm in $months
	do
	    monthstr="${yyyy}_${mm}" 

	    # push all the radial data (.ruv files) up to cromwell
	    export ruv_src="/Volumes/TRANSFER/reprocess_${sitestr}/${monthstr}/Radials_qcd/${pattern_type}"
	    export all_src="${ruv_src}/RDL*.ruv"
	    export dest_dir="/seacoos/data/chatts/level0/${sitestr}/Radials_qcd/${pattern_type}/${monthstr}/"
	    export all_dest="haines@cromwell.oasis.unc.edu:${dest_dir}"
	    if [ -d "${ruv_src}" ]; then
		echo "rsync -avh --rsync-path="mkdir -p ${dest_dir} && rsync" $all_src $all_dest"
		# rsync -avh --dry-run --rsync-path="mkdir -p ${dest_dir} && rsync" $all_src $all_dest
		rsync -avh --rsync-path="mkdir -p ${dest_dir} && rsync" $all_src $all_dest
	    else
		echo "Source not found -- skipping -- ${ruv_src}"
	    fi
	done #months
    done #years
done #sites

# scratch
# lower_sitestr=$(echo $sitestr | tr '[:upper:]' '[:lower:]')
#
# test simple
# rsync -avh --dry-run --rsync-path="mkdir -p /seacoos/data/chatts/level0/HATY/Radials_qcd/IdealPattern/2017_04/ && rsync"\
#  /Volumes/TRANSFER/reprocess_HATY/2017_04/Radials_qcd/IdealPattern/RDLi_*.ruv \
#  haines@cromwell.oasis.unc.edu:/seacoos/data/chatts/level0/HATY/Radials_qcd/IdealPattern/2017_04/
