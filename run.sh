#!/bin/sh

#delete old p04 hdf results and copy in fixed up one
rm Muncie.p04.hdf
rm Muncie.p04.tmp.hdf
cp wrk_source/Muncie.p04.tmp.hdf .

# remove old results
rm Muncie.dss

RasUnsteady Muncie.c04 b04

mv Muncie.p04.tmp.hdf Muncie.p04.hdf
