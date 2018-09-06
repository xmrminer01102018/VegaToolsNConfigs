#!/usr/bin/env bash

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

# read the options
TEMP=`getopt -o g:r:s: --long gpusequence:,rpm:,speed: -n $0 -- "$@"`
eval set -- "$TEMP"

RPM=""
# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -r|--rpm)
            case "$2" in
                "") shift 2 ;;
                *) RPM=$2 ; shift 2 ;;
            esac ;;
        -s|--speed)
            case "$2" in
                "") shift 2 ;;
                *) FANSPEED=$2 ; shift 2 ;;
            esac ;;
        -g|--gpusequence)
            case "$2" in
                "") shift 2 ;;
                *) GPUSEQ=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Error parsing args!" ; exit 1 ;;
    esac
done

#echo "FANSPEED = $FANSPEED"
#echo "RPM = $RPM"
#echo "GPUSEQ = $GPUSEQ"


MAXRPM=3200

getGPUSequence() {
  total=$(lspci | grep VGA | wc -l)
  gpuSeq=""
  for ((i=0;i<${total};i++)); 
  do 
    if [ $i != 0 ]; then
      gpuSeq="${gpuSeq},${i}"
    else
      gpuSeq="${i}"
    fi
  done
  echo ${gpuSeq} 
} 

if [[ ($FANSPEED != "" && $RPM != "") ]];
then
  echo "Cannot have both RPM and % fan speed"
  exit;
fi
if [[ ($FANSPEED == "" && $RPM == "")  || $GPUSEQ == "" ]];
then
  echo "$0 -s %[fanspeed] -r[RPM] -g gpu(s)"
  echo "Example Set GPU at card 0 to 50%"
  echo "$0 -s 50 -g 0"
  echo "Example Set GPU at card 0 and 2 to 50%"
  echo "NOTE: DO NOT PUT SPACES BETWEEN COMMA(S) AND NUMBER(S)"
  echo "$0 -s 50 -g 0,2"
  echo "Example Set all GPU(s) to 50%"
  echo "$0 -r 3000 -g all"
  echo "Example Set all GPU(s) to 50%"
  echo "$0 -s 50 -g all"
  exit;
fi

if [[ $FANSPEED == "" ]];
then
  if [[ ( ${RPM} != "" && "${RPM}" -le "${MAXRPM}" ) ]];
  then
    #echo "Setting RPM"
    SPEED=$RPM
    TYPE=" RPM"
  else
    echo "RPM shoud be less than or equal to ${MAXRPM}"
    exit;
  fi
else
  SPEED=$FANSPEED
  TYPE="%" 
fi

gpusequence=$GPUSEQ

if [  "$GPUSEQ" == "all" ]; then
  gpusequence=$( getGPUSequence )
fi

enable="1"
# Simplify readarray parsing for simple CSV string
readarray -td, a <<<"$gpusequence, "; unset 'a[-1]';
#readarray -td '' a < <(awk '{ gsub(/,[ ]*|$/,"\0"); print }' <<<"$gpusequence, "); unset 'a[-1]';

for gpunumber in "${a[@]}"
do
    #gpudir is not always at hwmon${gpunumber}
    #gpudir="/sys/class/drm/card${gpunumber}/device/hwmon/hwmon${gpunumber}"
    FHWMON=$( find /sys/class/drm/card${gpunumber}/device/hwmon/ -name "pwm1_max" )
    gpudir=$( dirname $FHWMON )
    echo "Setting GPU${gpunumber} speed to ${SPEED}${TYPE}"
    pwm1max=$(head -1 ${gpudir}/pwm1_max)
    if [[ $FANSPEED == "" ]]; then
      DEC=$( bc -l <<< $RPM/$MAXRPM )
      PCT=$( bc -l <<< $DEC*100 )
      FANSPEED=${PCT%.*}
    fi
    #echo "Fan speed: $FANSPEED"
    fanspeed=$(( (pwm1max * $FANSPEED)/100 ))
    #Do not set fanspeed more than allowed
    if [ ${fanspeed} -le ${pwm1max} ]; then
      echo $enable > ${gpudir}/pwm1_enable
      echo $fanspeed > ${gpudir}/pwm1
    else
      echo "Error: Fan speed more than 100%"
    fi
done
