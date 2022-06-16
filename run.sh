#! /bin/bash


## If you need to hard set the number of threads, do that here. 
threads=""
## If you need to hard set the amount of memory, you can do that here. requires KB value
memory=""

if [[ "$threads" != "" ]]
then
	echo "Thread override configured, using new value"

else 	
	## Determine the hardware specs
	search=("Socket" "Core")
	threads="1"

	for i in "${search[@]}"
	do

        	found=$(lscpu | grep -e $i | awk -F ":" '{print $2}' | tr -d '[:blank:]')
        	threads=$(($threads*$found))

	done

fi

if [[ "$memory" != ""  ]]
then

	echo "Thread override configured, using new value"

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
cd /hecras/project && ./*.sh


