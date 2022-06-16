#! /bin/bash

## Consider overriding the thread and memory values in the project runscript rather than here, unless you have other hard requirements to consider

## If you need to hard set the number of threads before the project script is executed, do that here. 
threads=""
## If you need to hard set the amount of memory before the project script is executed, you can do that here. requires KB value
memory=""

if [[ "$threads" != "" ]]
then
	echo "Thread override configured, using new value"

else 	
	## Determine the hardware specs. If you want to include threads in the the math, add it to the array below.
	search=("Socket" "Core")
	## Set this to 1, because 1*anything=$anything
	threads="1"

	for i in "${search[@]}"
	do

        	found=$(lscpu | grep -e $i | awk -F ":" '{print $2}' | tr -d '[:blank:]')
        	threads=$(($threads*$found))

	done

fi

if [[ "$memory" != ""  ]]
then

	echo "Memory override configured, using new value"

else

	memory=$(cat /proc/meminfo | grep "MemTotal" | awk -F ":" '{print $2}' | tr -d '[:blank:]'| tr -d 'kB')

fi

echo "Total # of CPU cores: "$threads
echo "Total system memory: "$memory"K"

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

## run the provided run script
cd /project && ./*.sh


