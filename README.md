### About
Creates a backup, `YYYY-MM-DD_HH-MM{AM/PM}_{system_hostname}.tar.gz` in whatever you set the `backupdest` variable to. 

### Recovery / Extraction of the .tar.gz in Linux
`$ tar -xvzf 2017-09-12_07-38PM_nuc-ubuntu.tar.gz`

### Recovery / Extraction of the .tar.gz in Windows
`R. Click --> 7-Zip --> Extract here` once on the .tar.gz, then again on the .tar.

### Files To Exclude From Backups
Anything you want to exclude from backups, put it in `rsync_exclude.txt`
