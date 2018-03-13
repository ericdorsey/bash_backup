#!/bin/bash

# An Ubuntu backup script

# What folders to backup
what_to_backup="
/something/important/
/home/foo/ 
"

# Location of *this* script (ubuntu-bak.sh) -- important when running in a crontab
scripthome="/foo/scripts/bak"

# Backup destination
backupdest="/mnt/myshare/backup/"

# Local temp / gathering location
templocaldir="/tmp/ubuntu-bkup/"

tardir="/tmp/tardir"

# General function to check if a directory exists
function dir_exists () {
    if [ ! -d $1 ];
    then
        echo -e "$1 doesn't exist! Exiting.."
        exit 1
    else
        echo -e "$1 exists. Moving on.."
    fi
}

# General function to create a directory if it doesn't exist
function dir_make () {
    if [ ! -d $1 ];
    then
        echo -e "$1 doesn't exist; creating $1"
        mkdir $1
    else
        echo -e "$1 exists. Moving on.."
    fi
}

# Check if /tmp/tardir/ exists; if not, create it
dir_make $tardir

# Check if /tmp/ubuntu-bkup/ exists; if not, create it
dir_make $templocaldir

# Check if /mnt/myshare/backup/ exits; this is all for naught if not
dir_exists $backupdest

# Go to script home first 
cd $scripthome

# Create backups of some system information
cat /var/spool/cron/crontabs/root > $templocaldir/root_crontab.bak
cat /var/spool/cron/crontabs/foo > $templocaldir/foo_crontab.bak
/sbin/ifconfig > $templocaldir/ifconfig.bak
/sbin/route -n > $templocaldir/route.bak
cat /etc/fstab > $templocaldir/fstab.bak

# Filename for the final .tar.gz backup
my_date=$(date +"%Y-%m-%d_%I-%M%p")
my_hostname=$(hostname)
tar_filename="${my_date}_${my_hostname}.tar.gz"

# rsync all the stuff to backup to one spot
for i in $what_to_backup;
do
    echo "Currently rsyncing $i to $templocaldir"
    rsync -aR --links --exclude-from="rsync_exclude.txt" $i $templocaldir
done

echo -e "Backup file name is: $tar_filename"

# Create the .tar.gz file 
echo -e "Creating $tar_filename in $templocaldir" 
tar -czf $tardir/$tar_filename -C $templocaldir .

# Move the backup over to the mounted CIFS share
echo -e "Now rsyncing $tardir/$tar_filename to $backupdest"
rsync -av $tardir/$tar_filename $backupdest

# Delete all files and folders in /tmp/ubuntu-bkup/ 
echo -e "Cleanup. Deleting everything under $templocaldir and $tardir"
rm -Rf /tmp/ubuntu-bkup/*
rm -Rf /tmp/tardir/*
