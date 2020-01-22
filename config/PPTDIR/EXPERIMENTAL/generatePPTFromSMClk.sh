#!/bin/bash

#BSD 3-Clause License
#
#Copyright (c) 2018-2020, xmrminer01102018
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
  echo "$0 SMClkFile CopyOfPPTTemplate PowerPercent"
  echo "Example: $0 SMClkFile CopyOfPPTTemplate 125"
  echo "Do not use more than 100 percent of the PowerPercent if you do not know what you are doing..."
  exit;
fi

SED=$( which sed )
SMCF=$1
PPTT=$2
PWPCT=$( printf '%02x' $3 )
CTR=0
declare -A mVArray 

reverseItByTwo() {
  hxs="$1"
  len=${#hxs}
  for (( i=$len-2; i>=0; i=i-2 ))
  do 
    reverse="$reverse${hxs:$i:2}"
  done
  echo "$reverse"
}

getIndex() {
  Index=-1 
  A=("${!1}")
  #A="$1"
  j="$2"
  k=0
  Index=-1
  for i in ${A[@]}
  do
    if [ "${i}" == "${j}" ]
    then
      if [ "$Index" == "-1" ]
      then
        Index=$k
      fi
    fi
   let k=$k+1
  done
  echo "$Index"
}

while read line 
do
  #echo ${line}
  let CTR=$CTR+1
  n=0
  VVal=""
  CVal=""
  MVal=""
  mVI=""
  for i in $line
  do
    let n=$n+1
    if [ $n == 2  ];
    then
      #echo "$n: $i"
      if [ $CTR -lt 9  ];
      then
        VVal="V${i}v${i}"
        #echo $VVal
        CVal="C${i}c${i}a${i}"
        #echo $CVal
      else
        MVal="M${i}m${i}a${i}"
        mVI="I${i}i${i}"
        #echo $MVal
      fi
    fi
    if [ $n == 3  ];
    then
      let clk=$i*100
      #echo $clk
      hVal=$( printf '%06x' ${clk} )
      #echo $hVal
      rVal=$( reverseItByTwo $hVal )
      if [ $CTR -lt 9  ];
      then
        echo "$CVal<->$rVal"
        ${SED} -i "s/${CVal}/${rVal}/g" ${PPTT}
      else
        echo "$MVal<->$rVal"
        ${SED} -i "s/${MVal}/${rVal}/g" ${PPTT}
      fi 
    fi
    if [ $n == 4  ];
    then
      if [ $CTR -lt 9  ];
      then
        let j=$CTR-1
        mVArray[$j]="$i" 
      fi
      let mV=$i
      #echo $mV
      hVal=$( printf '%04x' ${mV} )
      #echo $hVal
      rVal=$( reverseItByTwo $hVal )
      if [ $CTR -lt 9  ];
      then
        echo "$VVal<->$rVal"
        ${SED} -i "s/${VVal}/${rVal}/g" ${PPTT}
      else
        #echo "Getting Index for $mV"
        I=$( getIndex mVArray[@] $mV )
        iVal=$( printf '%04x' ${I} )
        echo "$mVI<->$iVal for $rVal Index: $I"
        if (( $I != -1 ));
        then
          ${SED} -i "s/${mVI}/${iVal}/g" ${PPTT}
        else
          echo "ERROR generating PPT text file!  Exiting..."
          exit
        fi
      fi
    fi
  done
done < $SMCF
#for i in "${mVArray[@]}"; do echo "$i"; done 
echo "PP<->$PWPCT" 
${SED} -i "s/PP/${PWPCT}/g" ${PPTT}
