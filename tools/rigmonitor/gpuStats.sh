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

OIFS=$IFS
IFS=','

LR='\033[1;31m' #Light Red 
LG='\033[1;32m' #Light Green
LY='\033[1;33m' #Light Green
LB='\033[1;34m' #Light Blue 
NC='\033[1;0m' # No Color

HEAD=/usr/bin/head
TAIL=/usr/bin/tail
CAT=/bin/cat
SED=/bin/sed
AWK=/usr/bin/awk
GREP=/bin/grep
PS=/bin/ps
WC=/usr/bin/wc
ECHO=/bin/echo

MINER="unknown"

HASHLOG=/var/log/hashrate.log


get_castxmr_hashrate () {
gpusA=$(  ${PS} -aef | ${GREP} "\-G" | ${GREP} -v "${GREP}" | ${AWK} -F"G" '{print $2}' | ${AWK} -F " " '{print $1}' )

hashrate=0
if [ -z "$gpusA" ];
then
  #No -G parameter in cast-xmr command line.  Assuming only one GPU
  thishashrate=$( ${CAT} ${HASHLOG} | ${GREP} "GPU0" | tail -n 1 | ${AWK} '{print $10}' | ${AWK} -F'.' '{print $1}' ) 
  hashrate=$(( ${hashrate}+${thishashrate} ))
else 
  for gpu in $gpusA
  do
    thishashrate=$( ${CAT} ${HASHLOG} | ${GREP} "GPU$gpu" | tail -n 1 | ${AWK} '{print $10}' | ${AWK} -F'.' '{print $1}' ) 
    hashrate=$(( ${hashrate}+${thishashrate} ))
  done  
fi
  echo "$hashrate"
}


if [ -e  ${HASHLOG} ]
then
  XACOUNT=$( ${CAT} ${HASHLOG} | ${GREP} speed | ${WC} -l )
  CECOUNT=$( ${CAT} ${HASHLOG} | ${GREP} "Total Speed" | ${WC} -l )
  XSCOUNT=$( ${CAT} ${HASHLOG} | ${GREP} "Totals (ALL)" | ${WC} -l )
  CXCOUNT=$( ${PS} -aef | ${GREP} "cast_xmr-vega" | ${GREP} -v "grep" | ${WC} -l )
  TRCOUNT=$( ${CAT} ${HASHLOG} | ${GREP} "\/s" | ${GREP} pool | ${WC} -l )
fi

#echo "XACOUNT: ${XACOUNT}"

if [[ $XACOUNT > 1 ]]; then
  MINER="xmrigamd"
else
  #echo "CECOUNT: ${CECOUNT}"
  if [[ $CECOUNT > 1 ]]; then
    MINER="claymoreeth"
  else
    #echo "XSCOUNT: ${XSCOUNT}"
    if [[ $XSCOUNT > 1 ]]; then
      MINER="xmrstak"
    else
      #echo "CXCOUNT: ${CXCOUNT}"
      if [[ $CXCOUNT == 1 ]]; then
        MINER="castxmr"
      else
        #echo "TRCOUNT: ${TRCOUNT}"
        if [[ $TRCOUNT > 1 ]]; then
          MINER="teamred"
        fi
      fi
    fi
  fi
fi

#echo "HASHLOG: ${HASHLOG}"
#echo "MINER: ${MINER}"

if [ -e  ${HASHLOG} ]
then
  if [[ "$MINER" == "xmrigamd" ]]; then
    #xmrig-amd
    HR=$( ${CAT} ${HASHLOG} | ${GREP} speed | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} '{print $5}' | ${AWK} -F'.' '{print $1}' )
  elif [[ "$MINER" == "claymoreeth" ]]; then
    #Claymore Miner for Ethereum
    HR=$( ${CAT} ${HASHLOG} | ${GREP} "Total Speed" | ${TAIL} -n 2 | ${HEAD} -n 1 | ${AWK} '{print $7}' | ${SED} 's/,//g' )
  elif [[ "$MINER" == "xmrstak" ]]; then
    #xmr-stak
    HR=$( ${CAT} ${HASHLOG} | ${GREP} "Totals (ALL)" | ${TAIL} -n 1 | ${AWK} '{print $3}' | ${AWK} -F'.' '{print $1}' )
    echo "HR: ${HR}"
  elif [[ "$MINER" == "castxmr" ]]; then
    HR=$(get_castxmr_hashrate)
  else
    #TeamRedMiner
    #Report Total
    #HR=$(  ${CAT} ${HASHLOG} | ${GREP} Total | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} '{print $10}' | awk -F'k' '{print $1}' )
    HR=$(  ${CAT} ${HASHLOG} | ${GREP} Total | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} -F'pool' '{print $2}' | ${AWK} -F'k' '{print $1}' )
    if [[ "$HR" == "" ]]; then
      #The rig has one gpu only
      #HR=$(  ${CAT} ${HASHLOG} | ${GREP} "kh/s" | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} '{print $11}' | awk -F'k' '{print $1}' )
      HR=$(  ${CAT} ${HASHLOG} | ${GREP} "kh/s" | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} -F'pool' '{print $2}' | ${AWK} -F'k' '{print $1}' )

    fi 
  fi
else
  HR="dne"
fi

#Make sure that array is separated by space
#In get_castxmr_hashrate, the array is separated by comma(",") 
IFS=$OIFS

gpus=$( ls /sys/class/drm/ | grep 'card[0-9]$' )
gpus=$( echo $gpus | sed "s/\n/ /g" )
gpus=$( echo $gpus | sed "s/card//g" )
read -a arr <<<$gpus
i=0

#echo "Array: ${arr[@]}"

HOSTNAME=$( hostname )

#Remove everything after the last comma from a line
UPTIME=$( uptime | awk -F"user" '{print $1}' | awk -F"up " '{print "up "$2}'| perl -0777pe 's/(.*)\,([^\n]+)/$1/s' )
if [[ "$MINER" == "xmrigamd" ]]; then
  INFO="${HOSTNAME}: ${LY}${HR}${NC} H/s - ${UPTIME}\n[xmrig-amd CN]"
elif [[ "$MINER" == "xmrstak" ]]; then
  INFO="${HOSTNAME}: ${LY}${HR}${NC} H/s - ${UPTIME}\n[xmr-stak CN]"
elif [[ "$MINER" == "castxmr" ]]; then
  INFO="${HOSTNAME}: ${LY}${HR}${NC} H/s - ${UPTIME}\n[cast-xmr CN]"
elif [[ "$MINER" == "claymoreeth" ]]; then
  INFO="${HOSTNAME}: ${LY}${HR}${NC} Mh/s - ${UPTIME}\n[claymore Ethash]"
elif [[ "$MINER" == "teamred" ]]; then
  #teamredminer
  INFO="${HOSTNAME}: ${LY}${HR}${NC} kH/s - ${UPTIME}\n[teamredminer CN]"
else
  INFO="${HOSTNAME} UNK: ${LY}${HR}${NC} kH/s - ${UPTIME}\n[Waiting for results...]"
fi
echo -e "${INFO}" 

for gpunumber in "${arr[@]}"
do
  if [ -e  /sys/class/drm/card${gpunumber}/device/pp_dpm_sclk ]; then
    ./gpuInfo.sh ${gpunumber} 
  fi
done

