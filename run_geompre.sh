#!/bin/bash

RAS_LIB_PATH=../libs:../libs/mkl:../libs/centos_7
#RAS_LIB_PATH=../libs:../libs/mkl:../libs/rhel_8

export LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

#RAS_EXE_PATH=/home/richard/Ras_v61_tests/Ras_v61/Debug
RAS_EXE_PATH=../Ras_v61/Release
export PATH=$RAS_EXE_PATH:$PATH
echo $PATH

# remove old results
rm Muncie.c04

RasGeomPreprocess Muncie.x04

cp Muncie.c04.tmp Muncie.c04

