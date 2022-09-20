[//]: # (Consider viewing this document here: https://github.com/nullcap/hec-ras-docker)
# HEC-RAS docker

A simple docker container that runs HEC-RAS provided by the USACE. You can find more information about HEC-RAS and its applications [on the official HEC-RAS webpage](https://www.hec.usace.army.mil/software/hec-ras/)

-----

## Notes

- there is no muncie directory. provide your own test. 
- Release and Debug binaries are available, the default path points to the Release directory. You can execute the debug binaries directly if you have that need. They can be found in the `/hecras/Ras_v61/Debug/*` directory.
- included remove_HDF5_Results.py as `/hecras/remove_HDF5_Results.py`
- all tests were using pubically available projects. Your milage may very, depending on your workflow and requirements. 
- auto-scaling for threading and memory works, mostly. hard-set these in your config file if you have issues. 
- check the example.project.run.sh file for information on what your project bash script should look like.
- If you are using s3 buckets to move data into and out of the container, you will not need to mount the directories at runtime. This configuration will take effect when the container is launched.
  - It is assumed that the project data is housed in the $PROJECT directory of the s3 bucket. It is advised to use a single bucket to house cloud data, as you will have to build a new container for each new s3 bucket otherwise. 
- This image is built on rocky linux, see [their docker hub page](https://hub.docker.com/_/rockylinux) for more information.
- 

-----

## TL;DR: Quickstart

build the container:

```
docker build .
```

load your project files, config file, and project bash script into some directory. decide where your results need to live. 

run the container:

```
docker run -it --name hec-ras \
-v /your/local/project/data/dir:/project \
-v /your/local/results/dir:/results \
-e PROJECT="YOURPROJECTNAME" \
-e NUM_THREADS="8" \
-e NUM_MEMORY="16g" \
<containerid>
```

If you want to use an S3 bucket for data storage, you can configure it in `core.sh` when you build the container, or you can set the vars at runtime:

```
docker run -it --name hec-ras \
-e PROJECT="YOURPROJECTNAME" \
-e NUM_THREADS="8" \
-e NUM_MEMORY="16g" \
-e AWS_ACCESS_KEY="YOURAWSACCESSKEY" \
-e AWS_SECRET_ACCESS_KEY="YOURAWSSECRETACCESSKEY" \
-e S3_BUCKET_NAME="YOURS3BUCKETNAME" \
<containerid>
```

-----

## Important paths within container:

- /hecras
  - default work directory, this is where everything related to hecras lives.
- /hecras/core.sh
  - This file is executed when the container starts. It loads the user provided `config` file, attempts to configure thread and memory limits, attempts to mount s3 buckets, then runs the user provided project bash script 
- /hecras/project
  - Houses the user provided project files which are used in the run. Files are moved from their mounted directory to this location for execution (see /project below) so that there is no reliance on remotely mounted directories.
- /hecras/project/$PROJECT.sh
  - This is the user-provided run script, which should look similar to the provided `example.project.run.sh`. This script executes the actual RAS binaries and sync's your files into the appropriate results location.
- /hecras/project/config
  - _Optional_. This is where the user configures the name of the project ($PROJECT), any threading or memory overrides, overriding linux variables etc. You can also set your env vars in your `docker run` command, rather than using this file. 
- /hecras/project/results
  - this is a symlink to the `/results` directory to make it easier for users to reach from within their project bash script.
- /project
  - This is the expected mount path where external (to the container) data is loaded from. This is the mount location used for S3 buckets.
- /results
  - This is the expected mount path where internal (to the container) data is offloaded to. This is the mount location used for S3 buckets.

-----

## Required Vars:


### Dockerfile
These variables are pre-set within the Dockerfile and are requrired for this specific setup. Do not change these unless you know what you are doing:

```
ENV RAS_LIB_PATH=/hecras/libs:/hecras/libs/mkl:/hecras/libs/rhel_8
ENV LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
ENV RAS_EXE_PATH=/hecras/Ras_v61/Release
ENV PATH=$RAS_EXE_PATH:$PATH
```

### Config file
This optional file can be used to override vars and set new vars in a repeatable manner. See the example `project/config` file included in this repo for more info. 

```
# Project Name
# this is used to define the name of the project bash script to execute. 
export PROJECT=YOURPROJECTNAME
```

### Limiting/Unlimiting CPU threads and Memory
Set the below vars in `/hecras/project/config` or in your `docker run` command to override the dynamic threading behavior before execution:

```

## Uncomment and set the below vars to override the auto-scaling 
## this should be an integer of some kind, represented as a string.
# NUM_THREADS="8"
## this defaults to KB, use G to set to GB
# NUM_MEMORY="16G"

```

### Mounting S3 Buckets for data
If you want to mount s3 buckets for your data, you will need to either configure the bucket details in the `core.sh` file, or configure them in your `docker run` command. Note that if you decide to mount an s3 bucket, you do not need to mount the local directories as well. 

```
## Uncomment and set the below vars if you are moving data to/from an s3 bucket. 
#export AWS_ACCESS_KEY=YOURAWSACCESSKEY
#export AWS_SECRET_ACCESS_KEY=YOURAWSSECRETACCESSKEY
#export S3_BUCKET_NAME=your-s3-bucket-name
```

-----

## Moving Data

To get data in or out of the container, you will need to mount the appropriate directories in your `docker run` command. By default, this container expects your project data to be available at `/project` and your results to be dumped into `/results` _within the container_ :

```
docker run -it --name hec-ras \
-v /local/system/path/to/project/data:/project \
-v /local/system/path/to/results/dir:/results \
$(your-image-id)

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
docker run -it --name hec-ras \
-v /your/project/data/dir:/project \
-v /your/results/dir:/results \
-e PROJECT="YOURPROJECTNAME" \
hec-ras
```

The container will run until the provided project bash script has completed. If you want to have your container run without seeing the output, you can replace the `-it` portion of your `docker run` command with `-d`. 
