#!/usr/bin/env python
# Last modified: Time-stamp: <2008-07-22 10:19:37 codar>

# test running sub process "AnalyzeSpectra" from python and kill
# initially thought we could copy required things in and out of
# ss/config/radialconfigs for batch processing of radials from
# cross-spectra but Chad at Codar came up with his own perl-script to
# do this batch process -- see BatchProcess.pl and emails from Chad.

from datetime import datetime, timedelta, tzinfo
# from dateutil.tz import tzlocal, tzutc
import time
import sys

start_dt = datetime.utcnow()
start_dt.replace(microsecond=0)

# print start_dt
print '\nStart time for css2rdl: %s\n' % start_dt.strftime("%Y-%b-%d %H:%M:%S UTC")
print 'Python %s\n' % sys.version

import subprocess
import signal
import os

subprocess.call('ps')
x = r'/Codar/SeaSonde/Apps/RadialTools/SpectraProcessing/AnalyzeSpectra'
p = subprocess.Popen(x)
print p.pid
subprocess.call('ps')



os.kill(p.pid, signal.SIGKILL)
subprocess.call('ps')

