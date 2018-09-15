#!/bin/bash

#BSD 3-Clause License
#
#Copyright (c) 2018, xmrminer01102018
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#* Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#
#* Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#
#* Neither the name of the copyright holder nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


LR='\033[1;31m' #Light Red 
LG='\033[1;32m' #Light Green
LY='\033[1;33m' #Light Green
LB='\033[1;34m' #Light Blue 
NC='\033[1;0m' # No Color

TAIL=/usr/bin/tail
CAT=/bin/cat
SED=/bin/sed
AWK=/usr/bin/awk
GREP=/bin/grep
HASHLOG=/root/git/xmrig-amd/build/hashrate.log
if [ -e  ${HASHLOG} ]
then
  #HR=$( ${CAT} ${HASHLOG} | ${GREP} speed | ${TAIL} -n 1 | ${AWK} '{print $5}' | ${AWK} -F'.' '{print $1}' )
  HR=$( ${CAT} ${HASHLOG} | ${GREP} speed | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} '{print $5}' | ${AWK} -F'.' '{print $1}' )
else
  HR="dne" #Does not exist
fi

gpus=$( ls /sys/class/drm/ | grep 'card[0-9]$' )
gpus=$( echo $gpus | sed "s/\n/ /g" )
gpus=$( echo $gpus | sed "s/card//g" )
read -a arr <<<$gpus
i=0

#echo "Array: ${arr[@]}"

HOSTNAME=$( hostname )

#Remove everything after the last comma from a line
UPTIME=$( uptime | awk -F"user" '{print $1}' | awk -F"up " '{print "up "$2}'| perl -0777pe 's/(.*)\,([^\n]+)/$1/s' )
INFO="${HOSTNAME}: ${LY}${HR}${NC} H/s - ${UPTIME}"
echo -e "${INFO}" 

for gpunumber in "${arr[@]}"
do
  if [ -e  /sys/class/drm/card${gpunumber}/device/pp_dpm_sclk ]; then
    ./gpuInfo.sh ${gpunumber} 
  fi
done


