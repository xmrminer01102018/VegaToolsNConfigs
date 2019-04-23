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

if [ $# != 1 ];
then
  echo "$0 cardnumber"
  echo "Example: For slot 0"
  echo "$0 0"
  exit;
fi

PCIS=$( cat  /sys/kernel/debug/dri/$1/name | awk '{print $2}' | awk -F':' '{print $2$3}' | sed 's/\..*//g' )
gpunumber=$1
##cinfo=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep GFX -A 10 )
#wInfo=$( echo $cinfo )
#echo "wInfo: ${wInfo}"
##W=$( echo $cinfo | awk '{print $20}'| awk -F'.' '{print $1}' )
W=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep "average GPU" |awk '{print $1}' | awk -F'.' '{print $1}' )
printf -v W "% 4d" $W
#echo "wVar: $W"
##T=$( echo $cinfo | awk '{print $26}'| awk -F'.' '{print $1}' )
T=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep Temperature |awk '{print $3}' )
printf -v T "% 4d" $T
#echo "tVar: $T"
##L=$( echo $cinfo | awk '{print $30}'| awk -F'.' '{print $1}' )
L=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep Load |awk '{print $3}' )
printf -v L "% 4d" $L
#echo "lVar: $L"
#wInfo=$( echo $cinfo | awk -v z="$lVar" '{print "\033[1;31m"$20"\033[1;0m "$21", \033[1;32m"$26"\033[1;0m "$27", \033[1;34m"$z"\033[1;0m "$31}' )
wInfo="${LR}$W${NC} W ${LG}$T${NC} C ${LB}$L${NC} %"
#echo "wInfo: ${wInfo}"


sinfo=$( sensors | grep amdgpu-pci-$PCIS -A 4 | grep fan )
#sInfo=$( echo $sinfo )
#echo "sInfo: ${sInfo}"
#R=$( echo $sinfo | awk '{print $6}'| awk -F'.' '{print $1}' )
R=$( echo $sinfo | awk '{print $2}'| awk -F'.' '{print $1}' )


REGEX='^[0-9]+([.][0-9]+)?$'
if [[ $R =~ $REGEX ]] ; then
  printf -v R "% 5d" $R
fi

#echo "rVar: $R"
#sInfo=$( echo $sinfo | awk '{print ", \033[1;36m"$9"\033[1;0m "$10}' )
sInfo=" ${LC}$R${NC} RPM" 
#echo "sInfo: ${sInfo}"

allInfo="GPU$1: ${wInfo}${sInfo}"
echo -e "${allInfo}"

