#!/bin/bash

filelistname='filelist1.sh'
current=`date +"%Y-%m-%d"`;

if [ "$1" == "" ]; then
    echo "Error, please provide a location where to save the backup files! More info run command with -h"
    exit 1
fi;

if [ "$1" == "-h" ]; then                                                        
    echo "Backup the selected files in the specified location"                  
    echo "Example #1: sh ${0} init [run the first time to create a sample file list]"                                
	echo "Example #2: sh ${0} backups/ [will download all specified list in the backups directory]"
    exit 0                                                                      
fi;

if [ ! -f $filelistname ] && [ "$1" == "init" ]; then                                                      
    echo "Creating file ${filelistname}..."                  
    touch ${filelistname} 
	echo "#Custom file name = Absolute path to the filename" > ${filelistname}
	echo "filelist['custom.filename.php']='~/filename.php'" >> ${filelistname}
	echo 'File list created...'
	exit 0                                                                      
fi;

if [ ! -f $filelistname ]; then                                                 
    echo "File list is missing!"                                                      
    exit 1                                                                      
fi; 

if [ ! -d "${1}" ]; then
  mkdir ${1}
fi;

declare -A filelist
source $(dirname $0)/$filelistname

cd ${1}

if [ -d .git ]; then
    echo ""
else
    git init
fi;

echo '[$] Start downloading files....'

for i in ${!filelist[@]}; do
    filename="${filelist[$i]}"
    echo "[+] scp ${filename} $1/$i"
    scp ${filename} "${i}"
done

echo '[>] All files have been downloaded!'

git add --all
filesAdded=`git status --s`

if [ -z "${filesAdded}" ]; then
	echo '[>] No file changes were detected!'
else
	echo '[$] Adding modified files to git...'
	git commit -m "Backup run for files ${filesAdded}"
	echo '[>] All modified files have been commited!'
fi;

echo "[>] Backup completed!"

exit 0
