#! /bin/bash

## source config file
source /project/config

## If user hasnt overriden the threads var, attempt to use max number of threads available.
if [[ -v NUM_THREADS ]]
then
	echo "Thread override configured, using new value"
	echo "Configured thread count: "$NUM_THREADS

else 	
	## Determine the hardware specs. If you want to exclude threads in the the math, remove it from the array below.
	search=("Socket" "Core" "Thread")
	## Set this to 1, because 1*anything=$anything
	NUM_THREADS="1"

	for i in "${search[@]}"
	do

        	found=$(lscpu | grep -e $i | grep -v "Intel" | awk -F ":" '{print $2}' | tr -d '[:blank:]')
        	NUM_THREADS=$(($threads*$found))

	done

fi

## If user hasnt overriden the memory var, attempt to use all available memory.
if [[ -v NUM_MEMORY ]]
then

	echo "Memory override configured, using new value"
	echo "Configured memory allocation: "$NUM_MEMORY

else

	NUM_MEMORY=$(cat /proc/meminfo | grep "MemTotal" | awk -F ":" '{print $2}' | tr -d '[:blank:]'| tr -d 'kB')

fi

## If the user has configured Amazon s3 bucket storage, mount it
if [[ -v S3_BUCKET_NAME ]]
then 

	echo "S3 configured, mounting bucket"
	export S3_MOUNT_RESULT=/results
	export S3_MOUNT_PROJECT=/project
	s3fs $S3_BUCKET_NAME $S3_MOUNT_PROJECT -o passwd_file=/root/.passwd-s3fs
	s3fs $S3_BUCKET_NAME $S3_MOUNT_RESULT -o passwd_file=/root/.passwd-s3fs
	
fi

## Set ENV based on hardware available
ulimit -s unlimited
export MKL_SERIAL=OMP
export MKL_DOMAIN_PARDISO=$NUM_THREADS
export MKL_DOMAIN_BLAS=$NUM_THREADS
export MKL_BLAS=$NUM_THREADS
export OMP_DYNAMIC=FALSE
export OMP_NUM_THREADS=$NUM_THREADS
export OMP_THREAD_LIMIT=$NUM_THREADS
export OMP_STACKSIZE=$NUM_MEMORY
export OMP_PROC_BIND=TRUE

echo "Configured thread count: "$NUM_THREADS
echo "Configured memory allocation: "$NUM_MEMORY"K"

## sync the project data into the appropriate directory
echo "Syncing project data into container env. This may take a bit."
rsync -a /project/ /hecras/project
# symlink the results directory to make it easier for the user to reach within their project bash script.
ln -s /results /hecras/project/results

## run the provided run scripts in the order they appear within the directory structure. 
cd /hecras/project && chmod +x ./$PROJECT.sh && ./$PROJECT.sh


