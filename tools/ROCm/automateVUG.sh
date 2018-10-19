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

# Install Ubuntu Linux OS 18.04.1 LTS or 16.04.5.
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
# Copy automateVUG.sh from ROCm folder to VegaToolsNConfigs folder if you intend to
# use xmrig-amd 2.8.1+ or xmr-stak 2.5.0+. Comment out the MINER that your are not
# going to use.  By default it is set to XMRIGAMD to compile. 
# Make sure the scripts are runnable.
# chmod 770 *.sh
# Now run this script as root by typing cd /root/VegaToolsNConfigs; ./autoConfigure.sh 

#MINER="XMRSTAK"
MINER="XMRIGAMD"


ECHO=/bin/echo
SCRIPT=/usr/bin/script
APTGET=/usr/bin/apt-get
APTKEY=/usr/bin/apt-key
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
WGET=/usr/bin/wget
USERMOD=/usr/sbin/usermod
TEE=/usr/bin/tee

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
  ${SLEEP} 30
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
  ${SLEEP} 30
  ${APTGET} update
  ${ECHO} "apt-get updated..." 
  ${APTGET} install -y lm-sensors 
  ${ECHO} "lm-sensors installed..." 
  ${SENSORSDETECT} --auto
  ${ECHO} "Done sensors-detect..." 
  ${ECHO} "Performing dist-upgrade ..." 
  ${APTGET} dist-upgrade 
  ${ECHO} "Installing libnuma-dev..." 
  ${APTGET} install -y libnuma-dev 
  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi

if [[ "$STAGE" == "STAGE3" ]]
then
  ${ECHO} "STAGE4" > /root/stagefile
  ${ECHO} "Setting up stage 3" 
  ${SLEEP} 30
  ${WGET} -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | ${APTKEY} add -
  ${ECHO} 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main' | ${TEE} /etc/apt/sources.list.d/rocm.list
  ${APTGET} update
  ${ECHO} "apt-get updated..." 
  ${APTGET} install -y rocm-dkms
  ${USERMOD} -a -G video $LOGNAME
  ${ECHO} 'ADD_EXTRA_GROUPS=1' | ${TEE} -a /etc/adduser.conf
  ${ECHO} 'EXTRA_GROUPS=video' | ${TEE} -a /etc/adduser.conf
  ${ECHO} 'export LD_LIBRARY_PATH=/opt/rocm/opencl/lib/x86_64:/opt/rocm/hsa/lib:$LD_LIBRARY_PATH' | ${TEE} -a /etc/profile.d/rocm.sh
  ${ECHO} 'export PATH=$PATH:/opt/rocm/bin:/opt/rocm/profiler/bin:/opt/rocm/opencl/bin/x86_64' | ${TEE} -a /etc/profile.d/rocm.sh
  ${ECHO} 'export HSA_ENABLE_SDMA=0' | ${TEE} -a /etc/profile.d/rocm.sh
  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi

if [[ "$STAGE" == "STAGE4" ]]
then
  ${ECHO} "STAGE5" > /root/stagefile
  cd
  ${ECHO} "Setting up stage 4" 
  ${SLEEP} 30
  ${APTGET} update
  ${ECHO} "apt-get updated..."
  ${APTGET} install -y git libuv1-dev libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev 
  ${ECHO} "Tools installed..." 
  cd; ${MKDIR} git
  cd git
  GIT=$( ${WHICH} git )
  CMAKE=$( ${WHICH} cmake )

  if [[ "$MINER" == "XMRIGAMD" ]]
  then
    ${ECHO} "Cloning xmrig-amd for Ubuntu..." 
    ${GIT} clone https://github.com/xmrig/xmrig-amd.git
    cd /root/git/xmrig-amd/ 
    ${ECHO} "Compiling xmrig-amd for Ubuntu..." 
    ${MKDIR} build; cd build; ${CMAKE} ..; ${MAKE} 
  else
    ${ECHO} "Cloning xmr-stak for Ubuntu..." 
    ${GIT} clone https://github.com/fireice-uk/xmr-stak.git 
    cd /root/git/xmr-stak/
    ${ECHO} "Compiling xmr-stak for Ubuntu..." 
    ${MKDIR} build; cd build; ${CMAKE}  -DCMAKE_CXX_FLAGS="-march=native -O3" -DOpenCL_INCLUDE_DIR=/opt/rocm/opencl/include -DOpenCL_LIBRARY=/opt/rocm/opencl/lib/x86_64/libOpenCL.so.1 -DCUDA_ENABLE=OFF ..; ${MAKE} 
  fi

  ${ECHO} "rebooting..." 
  ${REBOOT} 
fi


if [[ "$STAGE" == "STAGE5" ]]
then
  ${ECHO} "STAGE5PROCESSING..." > /root/stagefile
  cd
  ${ECHO} "Setting up stage 5" 
  ${SLEEP} 30
  ${APTGET} update
  ${ECHO} "apt-get updated..."
  cd /root/Downloads
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
