#!/bin/bash
# ============================================================================
# Script for unzipping appliances exported from SUSE Studio
# (http://susestudio.com) on your local system.
#
# Author:  Antonio Vinicius Menezes Medeiros <vinyanalista@gmail.com>
# Contact: linuxkamarada@gmail.com
# ============================================================================

TAR_GZ=`ls *.tar.gz`
tar -zxvf $TAR_GZ
rm $TAR_GZ
rm -rf source
rm create_appliance.sh
rm README.md
FOLDER=`echo $TAR_GZ | sed 's/.tar.gz//'`
mv $FOLDER source
mv source/create_appliance.sh .
mv source/README ./README.md
cd source
tar -xvf source.kiwi.txz
rm source.kiwi.txz
cd ..
