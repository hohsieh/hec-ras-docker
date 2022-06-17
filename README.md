# HEC-RAS docker

A simple docker container that runs HEC-RAS provided by the USACE. You can find more information about HEC-RAS and its applications [on the official HEC-RAS webpage](https://www.hec.usace.army.mil/software/hec-ras/)

-----

## Notes:

- there is no muncie directory. provide your own test. 
- auto-scaling for threading and memory works, mostly. look below to know how to override.
- check the example.project.run.sh file for information on what your project runscript should look like.
- This image is built on rocky linux, see [their docker hub page](https://hub.docker.com/_/rockylinux) for more information.

-----

## TL;DR: Quickstart

build the container:

```
docker build .
```

load your project files and your runscript into some directory. decide where your results need to live. 

run the container:

```
docker run -it --name hec-ras -v /your/project/data/dir:/project -v /your/results/dir:/results <containerid>
```

If you configured s3 buckets in your runscript, then skip mounting local directories:

```
docker run -it --name hec-ras <containerid>
```

-----

## Important paths within container:

- /hecras
  - default work directory, this is where everything related to hecras lives.
- /hecras/core.sh
  - This file is executed when the container starts. It looks for number of threads and amount of memory available, to then set the threading and memory perameters within the environment. 
- /hecras/project
  - Houses the user provided project files which are used in the run. Files are moved from their mounted directory to this location for execution (see /project below).
- /hecras/project/run.sh
  - This is the user-provided run script, which should look similar to the provided `example.project.run.sh`. This script handles any threading overrides, allows user to configure s3 bucket mounts, and then executes the actual project run.
  - **Note**: this file can be named anything, as long as it ends with `.sh`. 
- /project
  - This is the expected mount path where external (to the container) data is loaded from.
- /results
  - This is the expected mount path where internal (to the container) data is offloaded to.

-----

## Required Vars:

These variables are pre-set within the container environment and are REQUIRED for this specific setup. Do not change these unless you know what you are doing:

```
ENV RAS_LIB_PATH=/hecras/libs:/hecras/libs/mkl:/hecras/libs/rhel_8
ENV LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
ENV RAS_EXE_PATH=/hecras/Ras_v61/Release
ENV PATH=$RAS_EXE_PATH:$PATH
```

-----

## Optional Vars:


#### Limiting/Unlimiting CPU threads
Set the below vars at the top of /hecras/project/run.sh to override the dynamic threading behavior before execution:

```
## this should be an integer of some kind. 
threads="8"
## this defaults to KB, use G to set to GB
memory="16G"
export MKL_SERIAL=OMP
export MKL_DOMAIN_PARDISO=$threads
export MKL_DOMAIN_BLAS=$threads
export MKL_BLAS=$threads
export OMP_DYNAMIC=FALSE
export OMP_NUM_THREADS=$threads
export OMP_THREAD_LIMIT=$threads
export OMP_STACKSIZE=$memory
export OMP_PROC_BIND=TRUE
```

If you require overriding these values before user execution, you can set their values in the `core.sh` file. 

-----

## Moving Data

To get data in or out of the container, you will need to mount the appropriate directories in your `docker run` command. By default, this container expects your project data to be available at `/project` and your results to be dumped into `/results` _within the container_ :

```
docker run -it --name hec-ras \
-v /local/system/path/to/project/data:/project \
-v /local/system/path/to/results/dir:/results \
$(your-image-id)

```

If you want to mount s3 buckets for your data, add the relevant lines to the `core.sh` script. Note that if you decide to mount an s3 bucket, you do not need to mount the local directories as well. 

core.sh:

```
...

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

...

```


-----

## Examples

#### Local runs

If you want to build this container on your local system, you simply need to clone this repo, cd into the repo directory, then run the build command:

```
git clone git@github.com:nullcap/hec-ras-docker.git
cd ./hec-ras-docker
docker build -t hec-ras . 
```

You can then run the container with `docker run`. Note that if you are pulling the container from a repository directly, you will need to include that information at the end, rather than the build name we used above. 

```
docker run -it --name hec-ras-project -v /local/path/to/project/data:/project -v /local/path/to/results/dir:/results hec-ras
```

The container will run until the provided project runscript has completed. If you want to have your container run without seeing the output, you can replace the `-it` portion of your `docker run` command with `-d`. 



