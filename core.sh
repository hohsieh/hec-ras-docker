#! /bin/bash

## Determine the hardware specs. If you want to exclude threads in the the math, remove it from the array below.
search=("Socket" "Core" "Thread")
## Set this to 1, because 1*anything=$anything
threads="1"

for i in "${search[@]}"
do
    	found=$(lscpu | grep -e $i | grep -v "Intel" | awk -F ":" '{print $2}' | tr -d '[:blank:]')
       	threads=$(($threads*$found))
done

memory=$(cat /proc/meminfo | grep "MemTotal" | awk -F ":" '{print $2}' | tr -d '[:blank:]'| tr -d 'kB')

## Set ENV based on hardware available
ulimit -s unlimited
export MKL_SERIAL=OMP
export MKL_DOMAIN_PARDISO=$threads
export MKL_DOMAIN_BLAS=$threads
export MKL_BLAS=$threads
export OMP_DYNAMIC=FALSE
export OMP_NUM_THREADS=$threads
export OMP_THREAD_LIMIT=$threads
export OMP_STACKSIZE=$memory
export OMP_PROC_BIND=TRUE

## source config file
source /hecras/project/config

echo "Configured thread count: "$threads
echo "Configured memory allocation: "$memory"K"

## sync the project data into the appropriate directory
echo "Syncing project data into container env. This may take a bit."
rsync -a /project/* /hecras/project

## run the provided run scripts in the order they appear within the directory structure. 
cd /hecras/project && chmod +x ./$PROJECT.sh && ./$PROJECT.sh


