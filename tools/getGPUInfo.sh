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
LB='\033[1;34m' #Light Blue
NC='\033[1;0m' # No Color

if [ $# != 1 ];
then
  echo "$0 cardnumber"
  echo "Example: For slot 0"
  echo "$0 0"
  exit;
fi
#readarray -td '' a < <(awk '{ gsub(/,[ ]*|$/,"\0"); print }' <<<"$1, "); unset 'a[-1]';
#declare -p a;
# Not all "readarray" versions act the same but "read" does
IFS=',' read -ra a <<< "$1"

cinfoA=()
sinfoA=()
vinfoA=()

    gpunumber=$1
    cinfo=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep GFX -A 10 )
    colorinfo=$( echo "$cinfo" | sed "s/Power:/Power:\\${LG}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/(MCLK)/\\${NC}(MCLK)\\${LG}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/(SCLK/\\${NC}(SCLK/" )
    colorinfo=$( echo "$colorinfo" | sed "s/(VDDGFX)/\\${NC}(VDDGFX)\\${LG}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/(average/\\${NC}(average/" )
    colorinfo=$( echo "$colorinfo" | sed "s/Temperature:/Temperature:\\${LG}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/GPU Load:/\\${NC}GPU Load:\\${LG}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/%/%\\${NC}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/(max GPU)/(max GPU)\\${LG}/" )
    colorinfo=$( echo "$colorinfo" | sed "s/(average GPU)/\\${NC}(average GPU)/" )

    cinfoA[$gpunumber]="$colorinfo"

SINFO=$( sensors | grep amd -A 4 )
VINFO=$( lspci -vnn | grep VGA -A 2 | grep AMD -A 2 | grep Vega -A 2 | grep -v "Vega 8" )
PCIS=$( cat  /sys/kernel/debug/dri/$1/name | awk '{print $2}' | awk -F':' '{print $2$3}' | sed 's/\..*//g' )
PCIV=$( cat  /sys/kernel/debug/dri/$1/name | awk '{print $2}' | awk -F':' '{print $2":"$3}' )


sinfo=$( sensors | grep amdgpu-pci-$PCIS -A 4 )
sinfo=$( echo $sinfo | sed "s/fan1:/fan1:\\${LG}/" )
sinfo=$( echo $sinfo | sed "s/RPM/\\${NC}RPM/" )
sinfoA[$gpunumber]=$sinfo
vinfoA[$gpunumber]=$( echo "$VINFO" | grep "$PCIV VGA" -A 2 )
echo -e "${LB}Status Window${NC}"
echo -e "${LR}Ctrl-C${NC}: Switch to another GPU"
PSTR="\n${LG}GPU$gpunumber${NC}\n${cinfoA[$gpunumber]} \n ${sinfoA[$gpunumber]}\n${vinfoA[$gpunumber]}\n\n"
echo -e "$PSTR" 

