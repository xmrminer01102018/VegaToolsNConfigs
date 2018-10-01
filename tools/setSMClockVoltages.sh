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


#This program is made for Vega 56 cards only.  It may work with Vega Frontier Edition and Vega64 but has not been tested.
#Add gpu type and modify it every time "VEGA" is used.
VEGA="VFE" #Vega Frontier 
VEGA="V64" #Vega 64
VEGA="V56" #Vega 56 Default value

#Add and modify everywhere "clkArr" is used.
declare -A clkArr
#Clock values are from publicly available gpu specs.
clkArr["ASUSRXVEGA56B"]=1297 #ASUS Base Clock
clkArr["ASUSRXVEGA56T"]=1573 #ASUS Boost Clock
clkArr["PCRDVRXVEGA56B"]=1417 #PowerColor Red Devil Base Clock
clkArr["PCRDVRXVEGA56T"]=1607 #PowerColor Red DevilBoost Clock
clkArr["PCRDGRXVEGA56B"]=1177 #PowerColor Red Dragon Base Clock
clkArr["PCRDGRXVEGA56T"]=1478 #PowerColor Red Dragon Boost Clock
clkArr["MSIRXVEGA56B"]=1156 #MSI 8G Base Clock
clkArr["MSIRXVEGA56T"]=1471 #MSI 8G Boost Clock
clkArr["MSIOCRXVEGA56B"]=1181 #MSI Air Boost 8G OC Base Clock
clkArr["MSIOCRXVEGA56T"]=1520 #MSI Air Boost 8G OC Boost Clock
clkArr["XFXRXVEGA56B"]=1156 #XFX Base Clock
clkArr["XFXRXVEGA56T"]=1471 #XFX Boost Clock
clkArr["SPULSERXVEGA56B"]=1208 #Sapphire Pulse Base Clock
clkArr["SPULSERXVEGA56T"]=1512 #Sapphire Pulse Boost Clock

#for key in ${!clkArr[@]}; do
#    echo ${key} ${clkArr[${key}]}
#done

getBoostClock () {
  gpunumber=$1
  SINFO=$( sensors | grep amd -A 4 )
  VINFO=$( lspci -vnn | grep VGA -A 2 )
  if [ ! -f /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info ]; then
    echo "GPU${gpunumber}'s info does not exist."
    exit 1
  fi
  T1=$( cat /sys/kernel/debug/dri/${gpunumber}/amdgpu_pm_info | grep Temperature | awk '{print $3}' )
  let I=$gpunumber+2
  let J=$gpunumber+1
  sinfo=$( echo $SINFO | awk -F"amd" -v x="$I" '{print "amd"$x}' )
  PCI1=$( echo $sinfo | awk '{print $1}' | awk -F'-' '{print $3}' )
  T2=$( echo $sinfo | awk '{print $12}' | awk -F'.' '{print $1}' | sed 's/[^0-9]*//g' )
  vinfo=$( echo $VINFO | awk -F" -- " -v y="$J" '{print $y}' )
  PCI2=$( echo $vinfo | awk '{print $1}' | sed 's/://g' | awk -F'.' '{print $1}' )
  if [[ "$T1" != "$T2" ]]; then
    if [[ "$T1" < "$T2" ]]; then
      let T1+=1
    else
      let T2+=1
    fi
    #Give 1 degree tolerance
    if [[ "$T1" != "$T2" ]]; then
      echo "Error: Cannot mix GPU info!"
      exit
    fi
  fi
  if [[ "$PCI1" != "$PCI2" ]]; then
    echo "Error: PCI BUS address do not match!"
    exit
  fi
  MNAME=${vinfo##*Subsystem}
  case $MNAME in
    *ASUS*)  echo ${clkArr["ASUSRXVEGA56T"]} 
             ;;
    *PowerColor*) echo ${clkArr["PCRDVRXVEGA56T"]} 
                  ;;
    *MSI*) echo ${clkArr["MSIOCRXVEGA56T"]} 
           ;;
    *XFX*) echo ${clkArr["XFXRXVEGA56T"]}
           ;;
    *) echo "1500";;
  esac
}

if [ $# != 3 ];
then
  echo "$0 <gpu number> <voltage profile file for gpu and memory> [skip range checking]"
  echo "Example: If third param is not \"skip\", range and error checking is on."
  echo "$0 0 SummerMode.data anything"
  echo "$0 0,2 SummerMode.data anyword"
  echo "If you know what you are doing, you may skip range and error  checking on clocks and voltages"
  echo "$0 0,2 SummerMode.data skip"
  exit;
fi

#readarray -td '' a < <(awk '{ gsub(/,[ ]*|$/,"\0"); print }' <<<"$1, "); unset 'a[-1]';
#declare -p a;
# Not all "readarray" versions act the same but "read" does
IFS=',' read -ra a <<< "$1"

#Read in sclk, mclk and mV values.
#mapfile -t MSVArray < $2 
#Read in sclk, mclk and mV values.  mapfile does not work older bash versions
I=0
while read eachline
do
  echo "$eachline"
  MSVArray[$I]=$eachline
  (( I++ )) 
done < $2 

if [[ "$3" == "skip" ]]; then
  echo "Skipping range and error(s) checking..."
else
  echo "Range and error(s) checking..."
  if [ -e $2 ]; then
    RCOUNT=$( wc -l $2 | awk '{print $1}' )
    #echo "Line count = ${RCOUNT}"
  else
    echo "No such file: $2."
    exit
  fi
  for gpunumber in "${a[@]}"
  do
    #echo "GPU${gpunumber}"
    if [ ! -f /sys/class/drm/card${gpunumber}/device/pp_od_clk_voltage ]; then
      echo "GPU${gpunumber} does not exist."
      exit 1
    fi
    RANGE=$( cat /sys/class/drm/card${gpunumber}/device/pp_od_clk_voltage | grep "OD_RANGE" -A 4 )
    #echo "$RANGE"
    SMIN=$( echo $RANGE | awk '{print $3}' | sed 's/[^0-9]*//g' )
    SMAX=$( echo $RANGE | awk '{print $4}' | sed 's/[^0-9]*//g' )
    MMIN=$( echo $RANGE | awk '{print $6}' | sed 's/[^0-9]*//g' )
    MMAX=$( echo $RANGE | awk '{print $7}' | sed 's/[^0-9]*//g' )
    VMIN=$( echo $RANGE | awk '{print $9}' | sed 's/[^0-9]*//g' )
    VMAX=$( echo $RANGE | awk '{print $10}' | sed 's/[^0-9]*//g' )
    #echo "SMIN: ${SMIN}"
    #echo "SMAX: ${SMAX}"
    #echo "MMIN: ${MMIN}"
    #echo "MMAX: ${MMAX}"
    if [[ "$VEGA" == "V56" ]]; then
      MMAX=950 #Samsung memory
      MMAX=930 #Hynix memory
    fi
    SMAX=$( getBoostClock ${gpunumber} )
    for i in "${MSVArray[@]}"
    do
      case "$i" in
        s*) read -a svalues <<< $i
            # [2]-clock [3]-mV
            #echo "SVal: ${svalues[2]} SMIN: $SMIN SMAX: $SMAX"
            if (( ${svalues[2]} <  $SMIN || $SMAX < ${svalues[2]} ));
            then
              echo "Error(sclk): Value ${svalues[2]} is not in range $SMIN .. $SMAX for GPU${gpunumber}."
              exit
            fi
            #echo "SVVal: ${svalues[3]} VMIN: $VMIN VMAX: $VMAX"
            if (( ${svalues[3]} <  $VMIN || $VMAX < ${svalues[3]} ));
            then
              echo "Error(smV): Value ${svalues[3]} is not in range $VMIN .. $VMAX for GPU${gpunumber}."
              exit
            fi
            ;;
        m*) read -a mvalues <<< $i
            # [2]-clock [3]-mV
            #echo "MVal: ${mvalues[2]} MMAX: $MMAX"
            if (( "${mvalues[2]}" <  "$MMIN" || "$MMAX" < "${mvalues[2]}" ))
            then
              echo "Error(mclk): Value ${mvalues[2]} is not in range $MMIN .. $MMAX for GPU${gpunumber}."
              exit
            fi
            #echo "MVVal: ${mvalues[3]} VMIN: $VMIN VMAX: $VMAX"
            if (( ${mvalues[3]} <  $VMIN || $VMAX < ${mvalues[3]} ));
            then
              echo "Error(mmV): Value ${mvalues[3]} is not in range $VMIN .. $VMAX for GPU${gpunumber}."
              exit
            fi
            ;;
        *) echo "Unknown";;
      esac
    done
  done
fi 
for gpunumber in "${a[@]}"
do
  if [ ! -f /sys/class/drm/card${gpunumber}/device/pp_od_clk_voltage ]; then
    echo "Voltage file does not exist."
    exit 1
  fi
  echo "Changing SCLK, MCLK and voltage values(s) for GPU${gpunumber}."  
  for i in "${MSVArray[@]}"
  do
    echo "echo \"$i\"  > /sys/class/drm/card${gpunumber}/device/pp_od_clk_voltage"
    echo "$i" > /sys/class/drm/card${gpunumber}/device/pp_od_clk_voltage
  done
  echo "c" > /sys/class/drm/card${gpunumber}/device/pp_od_clk_voltage
done
