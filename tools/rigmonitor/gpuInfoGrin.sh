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
LY='\033[1;33m' #Light Yellow 
LB='\033[1;34m' #Light Blue
LC='\033[1;36m' #Light Blue
NC='\033[1;0m' # No Color


get_Info () {
 INFO=$1
 #echo "INFO: $INFO"
 W=$( grep Default <<< $INFO | awk -F'|' '{print $2 $4}' | awk '{print $4}' )
 #echo "W= ${W}"
 W=$( sed -e 's/[^0-9]//g' <<< $W )
 printf -v W "% 4d" $W
 T=$( grep Default <<< $INFO | awk -F'|' '{print $2 $4}' | awk '{print $2}' )
 #echo "T= ${T}"
 T=$( sed -e 's/[^0-9]//g' <<< $T )
 printf -v T "% 4d" $T
 L=$( grep Default <<< $INFO  | awk -F'|' '{print $2 $4}' | awk '{print $7}' )
 #echo "L= ${L}"
 L=$( sed -e 's/[^0-9]//g' <<< $L )
 printf -v L "% 4d" $L
 F=$( grep Default <<< $INFO  | awk -F'|' '{print $2 $4}' | awk '{print $1}' )
 #echo "F= ${F}"
 F=$( sed -e 's/[^0-9]//g' <<< $F )
 printf -v F "% 4d" $F
 info="${LR}$W${NC} W ${LG}$T${NC} C ${LB}$L${NC} % SPEED:${LC}$F${NC}%"
 echo "$info"
}





if [ $# != 2 ];
then
  echo "Number is $#"
  echo "$0 cardnumber status"
  echo "Example: For slot 0" 
  echo "$0 0 status"
  exit;
fi

gpunumber=$1
STATUS=$2

GC=$( cat  /sys/kernel/debug/dri/$1/name | grep amdgpu | wc -l )
if [[ $GC > 0 ]]
then
  MAKE="amd"
else
  MAKE="nvidia"
fi

if [[ "$MAKE" == "amd" ]]; then
  PCIS=$( cat  /sys/kernel/debug/dri/${gpunumber}/name | awk '{print $2}' | awk -F':' '{print $2$3}' | sed 's/\..*//g' )
  W=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep "average GPU" |awk '{print $1}' | awk -F'.' '{print $1}' )
  printf -v W "% 4d" $W
  T=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep Temperature |awk '{print $3}' )
  printf -v T "% 4d" $T
  L=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep Load |awk '{print $3}' )
  printf -v L "% 4d" $L
  wInfo="${LR}$W${NC} W ${LG}$T${NC} C ${LB}$L${NC} %"


  sinfo=$( sensors | grep amdgpu-pci-$PCIS -A 4 | grep fan )
  R=$( echo $sinfo | awk '{print $2}'| awk -F'.' '{print $1}' )


  REGEX='^[0-9]+([.][0-9]+)?$'
  if [[ $R =~ $REGEX ]] ; then
    printf -v R "% 5d" $R
  fi

  sInfo=" ${LC}$R${NC} RPM" 
  allInfo="GPU$1: ${wInfo}${sInfo} [${STATUS}]"
else
  gInfo=$( nvidia-smi | grep Default | head -$(( ${gpunumber}+1 )) | tail -1 )
  #echo "GINFO:$gInfo"
  aInfo=$( get_Info "${gInfo}" )
  allInfo="GPU$1: ${aInfo} [${STATUS}]"
fi
echo -e "${allInfo}"

