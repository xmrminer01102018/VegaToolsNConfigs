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

# Install Ubuntu MATE Linux OS 18.04.1 LTS.
# URL: https://ubuntu-mate.org/ (Only tested version)
# Set up ssh and root user
# $ sudo su -
# [sudo]  password for user jdoe: ********  <-- Enter your jdoe's password
# passwd
# Enter new UNIX password: ********  <-- Enter your root's password here
# Retype new UNIX password: ********  <-- Confirm your root's password here
# passwd: password updated successfully
# exit
# logout
# $ su -
# Password: ********  <-- Enter your root's password that you have created above
# Download amdgpu-pro drivers  and put them in /root/Downloads
# NOTE: the tar.xz file name is the same for amdgpu-pro 18.30 for Ubuntu 18.04.1 and Ubuntu 16.04.5
# For Ubuntu MATE 18.04.1
# amdgpu-pro-18.30-633530.tar.xz for Ubuntu 18.04.1 
# or
# amdgpu-pro-18.30-641594.tar.xz for Ubuntu 18.04.1

# For Ubuntu MATE 16.04.5
# amdgpu-pro-18.30-641594.tar.xz for Ubuntu 16.04.5

# URL: https://www2.ati.com/drivers/

# Use the same amdgpu-pro 18.10 driver for both Ubuntu 18.04.1 and Ubuntu 16.04.5
# amdgpu-pro-18.10-572953.tar.xz for Ubuntu 16.04.4
# URL: https://support.amd.com/en-us/kb-articles/Pages/Radeon-Software-for-Linux-18.10-Release-Notes.aspx
# Make sure that network has been configured and connected.
# Download a zip file from GitHub.
# cd
# unzip VegaToolsNConfigs-master.zip
# mv VegaToolsNConfigs-master VegaToolsNConfigs
# mv VegaToolsNConfigs /root/
# If you clone the VegaToolsNConfigs, move the directory to /root/.
# Move all the files from config, tools and PPTDIR folders to VegaToolsNConfigs folder.
# cd VegaToolsNConfigs
# mv config/* .
# mv tools/* .
# mv PPTDIR/* .
# Make the scripts are runnable.
# chmod 770 *.sh
# Now run this script as root by typing cd /root/VegaToolsNConfigs; ./autoConfigure.sh 

# Put the driver version that you have, as the last DRIVER_TO_RUN without .tar.xz
# In this case it is amdgpu-pro-18.30-641594
DRIVER_TO_RUN="amdgpu-pro-18.30-633530"
DRIVER_TO_RUN="amdgpu-pro-18.30-641594"

ECHO=/bin/echo
SCRIPT=/usr/bin/script
APTGET=/usr/bin/apt-get
REBOOT=/sbin/reboot
GIT=/usr/bin/git
CAT=/bin/cat
PWD=/bin/pwd
FIND=/usr/bin/find
GREP=/bin/grep
TAIL=/usr/bin/tail
DIRNAME=/usr/bin/dirname
CRONTAB=/usr/bin/crontab
SENSORSDETECT=/usr/sbin/sensors-detect
TAR=/bin/tar
WHICH=/usr/bin/which
MV=/bin/mv
LN=/bin/ln
MKDIR=/bin/mkdir
MAKE=/usr/bin/make
CP=/bin/cp
SLEEP=/bin/sleep
SED=/bin/sed
AWK=/usr/bin/awk
EGREP=/bin/egrep
PS=/bin/ps
KILL=/bin/kill
PERL=/usr/bin/perl
UPDATEGRUB=/usr/sbin/update-grub
POWEROFF=/sbin/poweroff
WC=/usr/bin/wc

FNDNAME=$( ${FIND} /root -name "autoConfigure.sh" | ${GREP} Configure | ${TAIL} -n 1 )

STAGE=""
if [ -e /root/stagefile ]
then
  STAGE=$( ${CAT} /root/stagefile ) 
else
  ${ECHO} "STAGE2" > /root/stagefile
  STAGE="STAGE1"
fi

if [[ "$STAGE" == "STAGE1" ]]
then
  cd
  ${ECHO} "Setting up stage 1"
(
  ${ECHO} "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" 
  ${ECHO} "@reboot ${FNDNAME}"
) | ${CRONTAB} -u root -

  ${ECHO} "crontab modified..." 

  ${APTGET} update
  ${ECHO} "apt-get updated..." 
  ${APTGET} install -y openssh-server
  ${ECHO} "ssh server installed..." 
  WCCOUNT=$( ${CAT} /etc/ssh/sshd_config | ${GREP} "^PermitRootLogin" | ${WC} -l )
  if [ $WCCOUNT != 0 ]; then
    ${ECHO} "Commenting out the existing rule..."
    ${PERL} -i.bak -npe 's/^PermitRootLogin/\#PermitRootLogin/g' /etc/ssh/sshd_config 
  fi
  ${ECHO} "PermitRootLogin yes" >> /etc/ssh/sshd_config
  ${ECHO} "sshd_config updated..." 
  ${ECHO}  "vm.nr_hugepages = 128" >> /etc/sysctl.conf
  ${ECHO} "sysctl.conf updated..." 
  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi

if [[ "$STAGE" == "STAGE2" ]]
then
  ${ECHO} "STAGE3" > /root/stagefile
  cd
  ${ECHO} "Setting up stage 2" 
  ${APTGET} update
  ${ECHO} "apt-get updated..." 
  ${APTGET} install -y lm-sensors 
  ${ECHO} "lm-sensors installed..." 
  ${SENSORSDETECT} --auto
  ${ECHO} "Done sensors-detect..." 
  cd /root/Downloads
  ${TAR} -Jxvf amdgpu-pro-18.10-572953.tar.xz
  ${ECHO} "Done tar amdgpu-pro-18.10-572953.tar.xz..." 
  cd amdgpu-pro-18.10-572953
  ${ECHO} "Installing amdgpu-pro-18.10-572953.tar.xz..." 
  ./amdgpu-pro-install -y --opencl=pal
  ${ECHO} "Done installing amdgpu-pro-18.10-572953.tar.xz..." 
  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi

if [[ "$STAGE" == "STAGE3" ]]
then
  ${ECHO} "STAGE4" > /root/stagefile
  cd
  ${ECHO} "Setting up stage 3" 
  ${APTGET} update
  ${ECHO} "apt-get updated..."
  ${APTGET} install -y git libuv1-dev libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev opencl-headers 
  ${ECHO} "Tools installed..." 
  cd; ${MKDIR} git
  cd git
  GIT=$( ${WHICH} git )
  CMAKE=$( ${WHICH} cmake )
  ${ECHO} "Cloning already modified xmrig-amd for Ubuntu..." 
  ${GIT} clone https://github.com/xmrminer01102018/xmrig-amd.git
  cd xmrig-amd
  cd src/3rdparty
  ${MV} CL CL_original
  ${LN} -s /usr/include/CL CL
  cd /root/git/xmrig-amd/
  ${ECHO} "Compiling xmrig-amd for Ubuntu..." 
  ${MKDIR} build; cd build; ${CMAKE} ..; ${MAKE} 
  CdJ=$( ${FIND} /root -name "config.json" | ${GREP} config | ${TAIL} -n 1 )
  ${CP} ${CdJ} .
  XMRIGAMD=$( ${FIND} /root -name "startXmrigAmd.sh" | ${GREP} startXmrigAmd | ${TAIL} -n 1 )
  ${ECHO} "Running xmrig-amd test run..." 
  ( ${XMRIGAMD} & )
  ${ECHO} "Pausing for 100 seconds to get hash rates..."
  ${SLEEP} 100 
  HASHLOG=/root/hashrate
  if [ -e  ${HASHLOG} ]
  then
    ${ECHO} "Getting hash rate..." 
    HR=$( ${CAT} ${HASHLOG} | ${GREP} speed | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} '{print $5}' | ${AWK} -F'.' '{print $1}' )
  else
    ${ECHO} "Hash log does not exist" 
  fi
  ${ECHO} "Hash rate is ${HR}." 
  ${ECHO} "Killing xmrig-amd process..." 
  PSR=$( ${PS} -aef | ${GREP} xmr | ${GREP} -v ${GREP} )
  ${ECHO} "${PSR}"
  PSN=$( ${PS} -aef | ${GREP} xmr | ${GREP} -v ${GREP} | ${AWK} '{print $2}' )
  ${ECHO} "PSN: ${PSN}"
  STATUS=$( ${KILL} -9 ${PSN} )
  REGEX='^[0-9]+$'
  if [[ ${HR} =~ ${REGEX} ]] ; then
     ${ECHO} "Initial slow hash rate ${HR}."
     /usr/bin/amdgpu-pro-uninstall -y
  else
     ${ECHO} "Something wrong with xmrig-amd program."
     ${ECHO} "STAGEHASHRATECHECK" > /root/stagefile
     ${ECHO} "Rebooting..."
     ${REBOOT}
  fi
  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi

if [[ "$STAGE" == "STAGEHASHRATECHECK" ]]
then
  ${ECHO} "STAGE4" > /root/stagefile
  ${ECHO} "Re-running xmrig-amd again..." 
  XMRIGAMD=$( ${FIND} /root -name "startXmrigAmd.sh" | ${GREP} startXmrigAmd | ${TAIL} -n 1 )
  ${ECHO} "Running xmrig-amd test run..." 
  ( ${XMRIGAMD} & )
  ${ECHO} "Pausing for 100 seconds to get hash rates..."
  ${SLEEP} 100 
  HASHLOG=/root/hashrate
  if [ -e  ${HASHLOG} ]
  then
    ${ECHO} "Getting hash rate..." 
    HR=$( ${CAT} ${HASHLOG} | ${GREP} speed | ${TAIL} -n 1 | ${SED} 's/\x1B\[[0-9;]*[JKmsu]//g' | ${AWK} '{print $5}' | ${AWK} -F'.' '{print $1}' )
  else
    ${ECHO} "Hash log does not exist" 
  fi
  ${ECHO} "Hash rate is ${HR}." 
  ${ECHO} "Killing xmrig-amd process..." 
  PSR=$( ${PS} -aef | ${GREP} xmr | ${GREP} -v ${GREP} )
  ${ECHO} "${PSR}"
  PSN=$( ${PS} -aef | ${GREP} xmr | ${GREP} -v ${GREP} | ${AWK} '{print $2}' )
  ${ECHO} "PSN: ${PSN}"
  STATUS=$( ${KILL} -9 ${PSN} )
  REGEX='^[0-9]+$'
  if [[ ${HR} =~ ${REGEX} ]] ; then
     ${ECHO} "Initial slow hash rate ${HR}."
     /usr/bin/amdgpu-pro-uninstall -y
  else
     ${ECHO} "Something wrong with xmrig-amd program."
     ${ECHO} "STOP" > /root/stagefile
     ${ECHO} "Exiting..." 
     exit 
  fi
  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi

if [[ "$STAGE" == "STAGE4" ]]
then
  ${ECHO} "STAGE4PROCESSING..." > /root/stagefile
  cd
  ${ECHO} "Setting up stage 4" 
  ${APTGET} update
  ${ECHO} "apt-get updated..."
  cd /root/Downloads
  ${TAR} -Jxvf ${DRIVER_TO_RUN}.tar.xz
  ${ECHO} "Done tar ${DRIVER_TO_RUN}.tar.xz..." 
  cd ${DRIVER_TO_RUN} 
  ${ECHO} "Installing ${DRIVER_TO_RUN}.tar.xz..." 
  ./amdgpu-pro-install -y --opencl=pal
  ${ECHO} "Done installing ${DRIVER_TO_RUN}.tar.xz..." 
  cd /etc/default
  ${MV} grub grub.original
  ${CP} grub.original grub
  ${PERL} -i.bak -npe 's/quiet splash/quiet splash amdgpu.ppfeaturemask=0xffffffff/g' grub
  RESULT=$( ${CAT} grub | ${GREP} amdgpu )
  ${ECHO} "grep result is ${RESULT}."
  ${UPDATEGRUB}
  ${ECHO} "Done with updating grub..." 
# Cleanup auto script
(
  ${ECHO} ""
) | ${CRONTAB} -u root -
  ${ECHO} "Powering off to add GPUs..." 
  ${ECHO} "MINER_INSTALL_SUCCESSFUL" > /root/stagefile
  ${POWEROFF}
fi

