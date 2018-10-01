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


if [ $# != 3 ];
then
  echo "$0 gpu_number_separated_by_comma %SCLK %MCLK"
  echo "Example: (Overclock GPU 0 with 8% gpu clock increase and 6% memory clock increase)"
  echo "$0 0 8 6"
  exit;
fi

echo "Starting setup..."

#readarray -td '' a < <(awk '{ gsub(/,[ ]*|$/,"\0"); print }' <<<"$1, "); unset 'a[-1]';
#declare -p a;
# Not all "readarray" versions act the same but "read" does
IFS=',' read -ra a <<< "$1"


for gpunumber in "${a[@]}"
do
  echo "Before OC for GPU${gpunumber}"
  SCLKVAL=$( cat /sys/class/drm/card${gpunumber}/device/pp_sclk_od )
  echo "SCLK Value: ${SCLKVAL}"
  MCLKVAL=$( cat /sys/class/drm/card${gpunumber}/device/pp_mclk_od )
  echo "MCLK Value: ${MCLKVAL}"
  echo $2 > /sys/class/drm/card${gpunumber}/device/pp_sclk_od 
  echo $3 > /sys/class/drm/card${gpunumber}/device/pp_mclk_od
done

for gpunumber in "${a[@]}"
do
  echo "After OC for GPU${gpunumber}"
  SCLKVAL=$( cat /sys/class/drm/card${gpunumber}/device/pp_sclk_od )
  echo "SCLK Value: ${SCLKVAL}"
  MCLKVAL=$( cat /sys/class/drm/card${gpunumber}/device/pp_mclk_od )
  echo "MCLK Value: ${MCLKVAL}"
done

echo "Done setup..."

