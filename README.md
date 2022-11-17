# hfr_reprocessing
Python scripts for reprocessing CODAR HFR for all NC stations (DUCK, HATY, CORE, OCRA) from 2003 to 2022.

### Overview
Python scripts run each site for each year (e.g. run_SITE_YYYY.py).  Each site has its own set of run scripts and CODAR config files. Run a script from the command line or place in crontab.

```
mm hh dd month weekday
51 13 04 08 * cd /Users/codar/Documents/reprocess_OCRA; ./run_OCRA_2022.py  2>&1
51 13 04 08 * cd /Users/codar/Documents/reprocess_OCRA; ./run_OCRA_2021.py  2>&1
```
