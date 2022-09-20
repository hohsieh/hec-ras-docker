#!/bin/bash
## Prep-work: Remove files, execute other scripts within the project directory structure, create directories, etc. 
echo "Begin Runscript"
rm -rf results/$Project/old_results/

## You will likely want to make sure you have the appropriate path for your results pre-populated
current_time = $(date +'%m_%d_%H')
mkdir -p results/$Project/results/$current_time/

## Execute the Unsteady binary. Include the "time" command to receive a printout of the time it took to run start to finish.
time RasUnsteady MyProject.c02 b08

## Once the run is complete, copy the needed files to the results directory to be offloaded from the container. 
rsync -av MyProject.p08.tmp.hdf results/$PROJECT/results/$current_time/Project.p08.hdf

## Not required, but helps to see the end of your script sometimes. 
echo "Runscript Complete"
