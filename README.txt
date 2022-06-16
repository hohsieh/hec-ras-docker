Notes:

- there is no muncie directory. provide your own test. 
- auto-scaling works, mostly. look below to know how to override

-----

Important paths:

/hecras : default work directory, this is where everything related to hecras lives. 

/hecras/run.sh : This file is executed when the container starts. It looks for number of threads and amount of memory available, to then set the threading and memory perameters within the environment. 

/hecras/project : default project directory, this is where the provided files live. Needs to include a ru
n.sh script to do the actual execution of the required function.

/hecras/project/run.sh : This is the user-provided run script. It just needs to execute the binary against the required files, and decide what to do with the results. YOU CAN OVERRIDE THREADING AND MEMORY VARS by setting them in this file, as it is executed last. 

-----

Required Vars:

Pre-set environment vars that are REQUIRED for this container. Do not change these unless you know what you are doing:

ENV RAS_LIB_PATH=/hecras/libs:/hecras/libs/mkl:/hecras/libs/rhel_8
ENV LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
ENV RAS_EXE_PATH=/hecras/Ras_v61/Release
ENV PATH=$RAS_EXE_PATH:$PATH

-----

Optional Vars:

Set the below vars at the top of /hecras/project/run.sh to override the default values before execution:

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


You can also hard set these values in /hecras/run.sh, but the above will likely be required in a prod-like environment since /hecras/run.sh wont always be available to the user. 

-----


