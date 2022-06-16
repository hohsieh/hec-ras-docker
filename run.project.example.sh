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


time RasUnsteady WhiskyChitto.c02 b08
mv WhiskyChitto.p08.tmp.hdf /results/WhiskyChitto.p08.hdf
echo "Finished"
