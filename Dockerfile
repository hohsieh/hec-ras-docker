## RHEL 8 / CENTOS 8 based linux container
## Rocky chosen as CentOS is currently undergoing changes due to IBM buyout of Red Hat. Feel free to change this to CentOS, as the commands/scripts should all translate correctly.
FROM rockylinux:8

## Define the HEC-RAS version
ENV HEC_RAS_FILE=HEC-RAS_610_Linux
ENV HEC_RAS_FOLDER=Ras_v61

## Required ENV, can be overriden at runtime if needed. 
ENV RAS_LIB_PATH=/hecras/libs:/hecras/libs/mkl:/hecras/libs/rhel_8
ENV LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
ENV RAS_EXE_PATH=/hecras/Ras_v61/Release
ENV PATH=$RAS_EXE_PATH:$PATH

## Load the hecras application. Make sure you have the zip file of HEC-RAS in the same directory as this dockerfile!  
COPY ${HEC_RAS_FILE}.zip /tmp
## Optionally, you can download the latest version from the internet. This may take a while, depending on your connection.
#RUN yum install -y wget && wget -O /tmp/HEC-RAS_610_Linux.zip https://www.hec.usace.army.mil/software/hec-ras/downloads/HEC-RAS_610_Linux.zip

## Load the project files directly, with run script.  Make sure you have this directory in the same directory as this dockerfile!
## This is handy if you need to troubleshoot, or send out a completely isolated container.
#COPY /home/$(whoami)/project/ /hecras/project

## Create needed directories
RUN mkdir /hecras /project /results

## Load core.sh for container management
COPY core.sh /hecras

## Load Readme to make documentation available within the container for troubleshooting with a bash session.
COPY README.md /hecras

## Move to a better location to do some work, keep working directories clean.
WORKDIR /root/

## Install packages
RUN yum install -y epel-release && \
	yum install -y unzip rsync bc vim nano automake python39 python39-pip s3fs-fuse && \
	pip3 install --upgrade pip && pip3 --no-cache-dir install --upgrade awscli

## Uncompress and set up HEC-RAS
RUN	unzip /tmp/${HEC_RAS_FILE}.zip && \
	unzip ${HEC_RAS_FILE}/RAS_Linux_test_setup.zip && \
	unzip ${HEC_RAS_FILE}/remove_HDF5_Results.zip && \
	rsync -a RAS_Linux_test_setup/* /hecras/ && \
	rsync -a remove_HDF5_Results.py /hecras/ && \
	chmod +x /hecras/${HEC_RAS_FOLDER}/Debug/* ; \
	chmod +x /hecras/${HEC_RAS_FOLDER}/Release/* ; \
	chmod +x /hecras/${HEC_RAS_FOLDER}/Debug/* ; \
	chmod +x /hecras/${HEC_RAS_FOLDER}/Release/* 

## Cleanup
RUN	rm -rf \ 
	/tmp/${HEC_RAS_FILE}.zip ${HEC_RAS_FILE}/ \ 
	RAS_Linux_test_setup/ \ 
	Python_script_for_removing_Results_HDF_datagroup.docx \ 
	/hecras/Muncie


## Where the shell scripts are. Execution happens here. 
WORKDIR /hecras/

## Actual work being done. 
CMD ["/bin/bash", "./core.sh"]
