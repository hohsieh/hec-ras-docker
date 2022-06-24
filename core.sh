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
	## Determine the hardware specs. If you want to exclude threads in the the math, remove it from the array below.
	search=("Socket" "Core" "Thread")
	## Set this to 1, because 1*anything=$anything
	threads="1"

	for i in "${search[@]}"
	do

        	found=$(lscpu | grep -e $i | grep -v "Intel" | awk -F ":" '{print $2}' | tr -d '[:blank:]')
        	threads=$(($threads*$found))

	done

fi

if [[ "$memory" != ""  ]]
then

	echo "Memory override configured, using new value"

else

	memory=$(cat /proc/meminfo | grep "MemTotal" | awk -F ":" '{print $2}' | tr -d '[:blank:]'| tr -d 'kB')

fi

echo "Total available threads: "$threads
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
#s3fs $S3_BUCKET_NAME $S3_MOUNT_PROJECT -o passwd_file=/root/.passwd-s3fs
#s3fs $S3_BUCKET_NAME $S3_MOUNT_RESULT -o passwd_file=/root/.passwd-s3fs

## sync the project data into the appropriate directory
echo "Syncing project data into container env"
rsync -a /project/* /hecras/project


## run the provided run scripts in the order they appear within the directory structure. 
cd /hecras/project && chmod +x ./*.sh && ./*.sh


