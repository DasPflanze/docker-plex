#!/bin/csh

set path = ($path /usr/local/bin)
set lockFile = '/tmp/dvrProcessing.lock'
set origFile = "$1"
set tmpFile = "$1.tmp"
set dvrPostLog = '/tmp/dvrProcessing.log'
set presetFile = '/opt/PlexComskip/PlexScriptPreset.json'
set SUFF = 'ts'
set suff = 'mp4'

#Wait if post processing is already running
while ( -f $lockFile )
    echo "'$lockFile' exists, sleeping processing of '$origFile'" | tee $dvrPostLog
    sleep 10
end

#Create lock file to prevent other post-processing from running simultaneously
echo "Creating lock file for processing '$origFile'" | tee -a $dvrPostLog
touch $lockFile

#Remove commercials
echo "Creating Backup File:'$origFile.backup'" | tee -a $dvrPostLog
cp "$origFile" "$origFile.backup"
echo "Removing commercials from '$origFile'" | tee -a $dvrPostLog
nice +19 /comchap/comcut --ffmpeg=/usr/bin/ffmpeg --comskip=/root/Comskip/comskip --lockfile=/tmp/comchap.lock --comskip-ini=/opt/PlexComskip/comskip.ini "$origFile"

#Encode file to H.264 with mkv container using Handbrake
echo "Re-encoding '$origFile' to '$tmpFile'" | tee -a $dvrPostLog
nice +19 HandBrakeCLI --preset-import-file $presetFile -Z "Plex Script" -i "$origFile" -o "$tmpFile"

#Overwrite original mkv file with the transcoded file.
echo "Renaming '$tmpFile' to '$origFile:r.mp4' and deleting '$origFile'" | tee -a $dvrPostLog
mv -f "$tmpFile" "$origFile:r.mp4"
rm "$origFile"

#Remove lock file
echo "Done processing '$origFile' removing lock" | tee -a $dvrPostLog
rm $lockFile

exit 0
