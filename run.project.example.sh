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

## Uncomment and set the below vars if you are moving data to/from an s3 bucket
#export AWS_ACCESS_KEY=YOURAWSACCESSKEY
#export AWS_SECRET_ACCESS_KEY=YOURAWSSECRETACCESSKEY
#export S3_MOUNT_RESULT=/results
#export S3_MOUNT_PROJECT=/project
#export S3_BUCKET_NAME=your-s3-bucket-name

## setting aws access credentials
#echo $AWS_ACCESS_KEY:$AWS_SECRET_ACCESS_KEY > /root/.passwd-s3fs &&
#chmod 600 /root/.passwd-s3fs

## mounting the s3 bucket to above locations
#s3fs $S3_BUCKET_NAME $S3_MOUNT_PROJECT
#$S3_BUCKET_NAME $S3_MOUNT_RESULT


## REQUIRED: move your project data into the correct location within the container
rsync -av /project/* /hecras/project/

## Execute the Unsteady binary. Include the "time" command to receive a printout of the time it took to run start to finish.
time RasUnsteady Project.c02 b08

## Once the run is complete, copy the needed files to the results directory to be offloaded from the container. 
rsync -av Project.p08.tmp.hdf /results/your-project-results-folder/Project.p08.hdf

## Not required, but helps to see the end of your script sometimes. 
echo "Finished"
