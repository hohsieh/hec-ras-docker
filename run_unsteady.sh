#!/bin/sh

RAS_LIB_PATH=../libs:../libs/mkl:../libs/centos_7
#RAS_LIB_PATH=../libs:../libs/mkl:../libs/rhel_8

export LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

#RAS_EXE_PATH=../Ras_v61/Debug
RAS_EXE_PATH=../Ras_v61/Release
export PATH=$RAS_EXE_PATH:$PATH
echo $PATH

#delete old p04 hdf results and copy in fixed up one
rm Muncie.p04.hdf
rm Muncie.p04.tmp.hdf
cp wrk_source/Muncie.p04.tmp.hdf .

# remove old results
rm Muncie.dss

RasUnsteady Muncie.c04 b04

mv Muncie.p04.tmp.hdf Muncie.p04.hdf
