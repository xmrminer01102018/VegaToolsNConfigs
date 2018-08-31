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


#This script supports up to 10 GPUs

LR='\033[1;31m' #Light Red 
LB='\033[1;34m' #Light Blue 
NC='\033[1;0m' # No Color

print_usage () {
  clear
  echo -e "${LB}MAIN${NC}"
  echo -e "Press ${LR}q${NC} to exit this program."
  echo -e "Press $gpus${NC} to watch gpu stats."
}


gpus=$( ls /sys/class/drm/ | grep 'card[0-9]$' )
gpus=$( echo $gpus | sed "s/\n/ /g" )
gpus=$( echo $gpus | sed "s/card//g" )
read -a arr <<<$gpus
gpus=""
pgpus=""
I=0
for gpunumber in "${arr[@]}"
do
  COUNT=$( ls /sys/kernel/debug/dri/$gpunumber | grep amd | wc -l )
  if [[ $COUNT != 0 ]]; then
     if [[ $I == 0 ]]; then
       gpus="$gpus ${LR}${gpunumber}${NC}"
       pgpus="$pgpus${gpunumber}"
       echo "GPUS: $gpus"
     else
       gpus="$gpus or ${LR}${gpunumber}${NC}" 
       pgpus="$pgpus,${gpunumber}"
       echo "GPUS: $gpus"
     fi
    let I=$I+1
  fi
done

print_usage

trap "" 2 
while true; do
    read -rsn1 gpunum 
    case $gpunum in
        [0]* ) clear; ./moniterGPU.sh 5 0; print_usage;;
        [1]* ) clear; ./moniterGPU.sh 5  1; print_usage;;
        [2]* ) clear; ./moniterGPU.sh 5  2; print_usage;;
        [3]* ) clear; ./moniterGPU.sh 5  3; print_usage;;
        [4]* ) clear; ./moniterGPU.sh 5  4; print_usage;;
        [5]* ) clear; ./moniterGPU.sh 5  5; print_usage;;
        [6]* ) clear; ./moniterGPU.sh 5  6; print_usage;;
        [7]* ) clear; ./moniterGPU.sh 5  7; print_usage;;
        [8]* ) clear; ./moniterGPU.sh 5  8; print_usage;;
        [9]* ) clear; ./moniterGPU.sh 5  9; print_usage;;
        [q]* ) exit;;
        * ) print_usage; echo -e "Valid gpu(s) are: $gpus${NC}";;
    esac
done


