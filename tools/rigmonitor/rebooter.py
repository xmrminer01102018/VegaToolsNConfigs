#!/usr/bin/python3

#BSD 3-Clause License
#
#Copyright (c) 2019, mmudado
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

"""Kill PIDs  and reboot machine."""

import os, signal
import logging
import time

LOG = '/root/VegaToolsNConfigs/rebooter.log'
XMRIG_AMD_PID="/root/VegaToolsNConfigs/xmrig-amd.pid"
XMRIG_CPU_PID="/root/VegaToolsNConfigs/xmrig-cpu.pid"


def validate(file_path: str) -> None:
    """Invoke all validations."""
    if _exists(file_path) and _is_file(file_path) and  _is_readable(file_path):
        return True
    else:
        return False

def _exists(file_path: str) -> None:
    """Check whether a file exists."""
    if not os.path.exists(file_path):
        return False
    else:
        return True

def _is_file(file_path: str) -> None:
    """Check whether file is actually a file type."""
    if not os.path.isfile(file_path):
        return False
    else:
        return True

def _is_readable(file_path: str) -> None:
    """Check file is readable."""
    try:
        f = open(file_path, "r")
        f.close()
        return True
    except IOError:
        return False


def check_pid(pid):        
    """ Check For the existence of a unix pid. """
    try:
        os.kill(int(pid), 0)
    except OSError:
        return False
    else:
        return True

def get_pid_fromfile(pidfile):
    pid = 0
    try:
        logging.info("Reading file " + pidfile)
        pidf = open(pidfile,'r')
        pid = pidf.read()
        logging.info("PID is :" + str(pid))
        pidf.close()
        try:
            os.remove(pidfile)
        except OSError as e:
            logging.info(e)
            raise e
        logging.info("Done.")
    except OSError as e:
        logging.info("could not read pidfile 1")
    return pid


# RUNNING THE SCRIPT

logging.basicConfig(filename=LOG, format='%(asctime)s - %(message)s', level=logging.INFO)
logging.info('Started.')

logging.info("Checking files ... ")
if validate(XMRIG_AMD_PID) and validate(XMRIG_CPU_PID):
    pid1 = 0
    pid2 = 0
    logging.info("Trying to kill PID from :" + XMRIG_AMD_PID)
    pid1 = get_pid_fromfile(XMRIG_AMD_PID)

    if check_pid(pid1):
        logging.info("Excuting:" + str(pid1))
        os.kill(int(pid1), signal.SIGKILL)
    
    logging.info("Trying to kill PID from :" + XMRIG_CPU_PID)
    pid2 = get_pid_fromfile(XMRIG_CPU_PID)
    if check_pid(pid2):
        logging.info("Excuting:" + str(pid1))
        os.kill(int(pid2), signal.SIGKILL)
    logging.info("Rebooting in 4 secs.")
    time.sleep(4)
    try:
        # First shot.
        logging.info("Goodbye.")
        os.system('sudo shutdown -r now')
    except OSError as e:
        logging.info("could not reboot: " + e)
        raise(e)
    time.sleep(4)
    try:
        # Second shot.
        logging.info("Really.Goodbye.")
        os.system('reboot')
    except OSError as e:
        logging.info("could not reboot: " + e)
        raise(e)
else:
    logging.info("Nothing to do.")
    exit
