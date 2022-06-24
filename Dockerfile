## RHEL 8 / CENTOS 8 based linux container
## Rocky chosen as CentOS is currently undergoing changes due to IBM buyout of Red Hat.
FROM rockylinux:8

## Required ENV
ENV RAS_LIB_PATH=/hecras/libs:/hecras/libs/mkl:/hecras/libs/rhel_8
ENV LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
ENV RAS_EXE_PATH=/hecras/Ras_v61/Release
ENV PATH=$RAS_EXE_PATH:$PATH

## Load the hecras application. Make sure you have the zip file of HEC-RAS in the same directory as this dockerfile!  
COPY HEC-RAS_610_Linux.zip /tmp
## Optionally, you can download the latest version from the internet. This may take a while, depending on your connection.
#RUN yum install -y wget && wget -O /tmp/HEC-RAS_610_Linux.zip https://www.hec.usace.army.mil/software/hec-ras/downloads/HEC-RAS_610_Linux.zip

## Load the project files directly, with run script.  Make sure you have this directory in the same directory as this dockerfile!
## This is handy if you need to troubleshoot, or send out a completely isolated container.
#COPY /home/$(whoami)/project/ /hecras/project

## Create needed directories
RUN mkdir /hecras /project /results

## Load core.sh for container management
COPY core.sh /hecras

## Load Readme to make documentation available within the container for troubleshooting.
COPY README.md /hecras

## Move to a better location to do some work.
WORKDIR /root/

## Install packages
RUN yum install -y epel-release && \
	yum install -y unzip rsync bc vim nano automake python39 python39-pip s3fs-fuse && \
	pip3 install --upgrade pip && pip3 --no-cache-dir install --upgrade awscli

## Uncompress and move HEC-RAS
RUN	unzip /tmp/HEC-RAS_610_Linux.zip && \
	unzip HEC-RAS_610_Linux/RAS_Linux_test_setup.zip && \
	unzip HEC-RAS_610_Linux/remove_HDF5_Results.zip && \
	rsync -a RAS_Linux_test_setup/* /hecras/ && \
	rsync -a remove_HDF5_Results.py /hecras/ && \
	chmod +x /hecras/Ras_v61/Debug/* ; \
	chmod +x /hecras/Ras_v61/Release/*

## Cleanup
RUN	rm -rf /tmp/HEC-RAS_610_Linux.zip HEC-RAS_610_Linux/ RAS_Linux_test_setup/ Python_script_for_removing_Results_HDF_datagroup.docx /hecras/Muncie; \
	chmod +x /hecras/Ras_v61/Debug/* ; \
	chmod +x /hecras/Ras_v61/Release/* ; \

## Where the shell scripts are. Execution happens here. 
WORKDIR /hecras/

## Actual work being done. 
CMD ["/bin/bash", "./core.sh"]
