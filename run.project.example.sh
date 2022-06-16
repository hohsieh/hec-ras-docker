## Uncomment and set the below vars to override the auto-scaling 

## this should be an integer of some kind.
#threads="8"
## this defaults to KB, use G to set to GB
#memory="16G"
#export MKL_SERIAL=OMP
#export MKL_DOMAIN_PARDISO=$threads
#export MKL_DOMAIN_BLAS=$threads
#export MKL_BLAS=$threads
#export OMP_DYNAMIC=FALSE
#export OMP_NUM_THREADS=$threads
#export OMP_THREAD_LIMIT=$threads
#export OMP_STACKSIZE=$memory
#export OMP_PROC_BIND=TRUE

## Execute the Unsteady binary. Include the "time" command to receive a printout of the time it took to run start to finish.
time RasUnsteady WhiskyChitto.c02 b08

## Once the run is complete, copy the needed files to the results directory to be offloaded from the container. 
rsync -av Project.p08.tmp.hdf /results/Project.p08.hdf

## Not required, but helps to see the end of your script sometimes. 
echo "Finished"
