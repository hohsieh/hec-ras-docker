## Using CentOS7 as a base, since it is supported by the software. 
FROM centos:7

## Load the hecras application. Make sure you have the zip file of HEC-RAS in the same directory as this dockerfile!  
COPY HEC-RAS_610_Linux.zip /tmp

## Load the run script to be executed.  Make sure you have this script of HEC-RAS in the same directory as this dockerfile!
COPY run.sh /tmp

## Required ENV's
ENV RAS_LIB_PATH=../libs:../libs/mkl:../libs/centos_7
ENV LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
ENV RAS_EXE_PATH=../Ras_v61/Release
ENV PATH=$RAS_EXE_PATH:$PATH

## Install unzip, uncompress the software, place it in the correct location, cleanup unneeded files. 
RUN yum install -y unzip; \
	unzip /tmp/HEC-RAS_610_Linux.zip; \
	unzip HEC-RAS_610_Linux/RAS_Linux_test_setup.zip; \
	mkdir /hecras ; \
	mv RAS_Linux_test_setup/* /hecras/; \
	rm -rf /tmp/HEC-RAS_610_Linux.zip HEC-RAS_610_Linux/ RAS_Linux_test_setup/ ; \
	chmod +x /hecras/Ras_v61/Release/* ; \
	rm -rf /hecras/Muncie/*.sh ; \
	mv /tmp/run.sh /hecras/Muncie/

## Where the shell scripts are. Execution happens here. 
WORKDIR /hecras/Muncie

## Actual work being done. 
CMD ["/bin/bash", "./run.sh"]
