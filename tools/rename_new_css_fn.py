#!/Users/codar/miniconda3/bin/python

"""Rename newer (2021- onward) CSS files saved with seconds in filename from 'CSS_SITE_YY_MM_DD_HHMMSS' to CSS_SITE_YY_MM_DD_HHMM.cs4

Usage:
  rename_new_css_fn.py [DIR] [SITE]
Examples:
  rename_new_css_fn.py /Volumes/PASSPORT/Spectra/Duck/css/2021 DUCK

Options:
  DIR   Data directory to process [e.g. /Volumes/PASSPORT/Spectra/Duck/css/2021]
  SITE  Site name [e.g. DUCK]


"""

import os
import sys

import re
import fnmatch
import datetime
import time

def recursive_glob(treeroot, pattern):
    """ Glob-like search for filenames based on pattern by recursve walk 
    subdirectories starting in treeroot.
    Parameters
    ----------
    treeroot : string
       The top most directory path to begin search.
    pattern : string
       The pattern to match file in search.
    Return
    ------
    results : list of paths from treeroot
       The results of search.
    >>> files = os.path.join(os.path.curdir, 'test', 'files')
    >>> recursive_glob(files, 'RDLx*.*')
    
    """
    # fnmatch gives you exactly the same patterns as glob, so this is
    # really an excellent replacement for glob.glob with very close
    # semantics.  Pasted from
    # <http://stackoverflow.com/questions/2186525/use-a-glob-to-find-files-recursively-in-python>
    results = [] 
    for base, dirs, files in os.walk(treeroot): 
        goodfiles = fnmatch.filter(files, pattern) 
        results.extend(os.path.join(base, f) for f in goodfiles)
    results.sort()
    return results 

def this_month():
    """Return this month (GMT) as formatted string (yyyy_mm) """
    this_month_str = "%4d_%02d" % time.gmtime()[0:2]
    return this_month_str

def filt_datetime(input_string, pattern=None):
    """Attempts to filter date and time from input string based on regex pattern.

    With 4-digit year pattern
    
    Default pattern follows the template, YYYY(-)MM(-)DD(-)(hh(:)(mm(:)(ss)))
    with minimum of YYYY MM and DD (date) supplied in descending order to 
    return its datetime object, otherwise returns None.
    Typical matches include, YYYYMMDD-hhmmss, YYYY-MM-DD-hh:mm:ss All
    the following will produce the corresponding datetime object. 
    Requires date with all three (year, month, day) in decreasing
    order as integers. Time is optional.
    
    filt_datetime('CSS_DUCK_2021_08_01_023000')
   """

    #  the default pattern for a typical codar time stamp format
    if not pattern:
        pattern = r"""
        # YYYY(-)MM(-)DD(-)(hh(:)(mm(:)(ss)))
        (\d{4})           # 4-digit YEAR 
        \D?               # optional 1 character non-digit separator (e.g. ' ' or '-')
        (\d{2})           # 2-digit MONTH 
        \D?               # optional 1 character non-digit separator
        (\d{2})           # 2-digit DAY 
        \D?               # optional 1 character non-digit separator (e.g. ' ' or 'T')
        (\d{2})?          # optional 2-digit HOUR 
        \D?               # optional 1 character non-digit separator (e.g. ' ' or ':')
        (\d{2})?          # optional 2-digit MINUTE 
        \D?               # optional 1 character non-digit separator (e.g. ' ' or ':')
        (\d{2})?          # optional 2-digit SECOND
        """
    #         
    p = re.compile(pattern, re.VERBOSE)
    m = p.search(input_string) 
    # m.groups() # should be ('2013', '11', '05', '00', '00', None) for 'RDLv_HATY_2013_11_05_0000.ruv'
    if m:
        values = [int(yi) for yi in m.groups() if yi is not None] # [2013, 11, 5, 0, 0]
        # datetime.datetime(*v) requires mininum of year, month, day
        dt = datetime.datetime(*values) # datetime.datetime(2013, 11, 5, 0, 0)
    else:
        dt = None
    return dt


def main():
    """Rename old CSS"""
    
    datadir = sys.argv[1]
    site = sys.argv[2]

    print(datadir)
    print(site)
    
    # get filenames with CSS and site in filename-- input dir
    ifullfns = recursive_glob(datadir, 'CSS*'+ site + '*')
    ifullfns.sort()
    for ifn in ifullfns:
        #
        odir = os.path.dirname(ifn) # output dir is same as dir found by recursive_glob
        fn = os.path.basename(ifn)
        _, fn_extension = os.path.splitext(fn)
        dt = filt_datetime(fn)
        if dt is not None:
            # newfn = 'CSS_' + site + '_' + dt.strftime('%y_%m_%d_%H%M') +  '.cs4'
            newfn = 'CSS_' + site + '_' + dt.strftime('%y_%m_%d_%H%M') +  fn_extension
            # 
            ofn = os.path.join(odir, newfn)
            print(' ... Rename %s to %s' % (fn, newfn))
            # based on https://python.omics.wiki/file-operations/file-commands/os-rename-vs-shutil-move
            # using os.rename() for this utility instead of shutil.move()
            os.rename(ifn, ofn)
        

    return

if __name__ == "__main__":
    print('--- %s ---' % (datetime.datetime.now(),))
    main()


# THIS WORKS
# $ cd /Users/codar/Documents/chatts/test_rename_2003_css
# $ cd CSS_HATY_2004_W01_Jan
# $ mv "CSS HATY 04:01:01 0000" CSS_HATY_04_01_01_0000.cs4
#
# need SITE
# need YY, MM, DD and HHMM
