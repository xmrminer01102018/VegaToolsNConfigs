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

"""Run xmrig, monitor, reboot machine."""
import os
import subprocess, select
import re
import sys, signal
import time
import argparse
import string
from os.path import isfile, join
import datetime
import logging

FNULL = open(os.devnull, 'w')
WORKING_DIR = '/root/VegaToolsNConfigs/'
LOG = WORKING_DIR + 'loader_monitor_booter.log' # you should erase this from time to time
XMRIG_AMD_BIN = WORKING_DIR + "xmrig-amd.bin"
XMRIG_AMD_PID = WORKING_DIR + "xmrig-amd.pid"
XMRIG_AMD_CONFIG = WORKING_DIR + "xmrig-amd.config.json"
XMRIG_AMD_LOG = WORKING_DIR + "xmrig-amd.config.log"
XMRIG_CPU_BIN = WORKING_DIR + "xmrig-cpu.bin"
XMRIG_CPU_PID = WORKING_DIR + "xmrig-cpu.pid"
XMRIG_CPU_CONFIG = WORKING_DIR + "xmrig-cpu.config.json"
XMRIG_CPU_LOG = WORKING_DIR + "xmrig-cpu.config.log"
SET_FAN_SPEED_BIN = WORKING_DIR + "setAMDGPUFanSpeed.sh"
SET_PPT_BIN = WORKING_DIR + "setPPT.sh"
PPT = WORKING_DIR + "V56GIG1"
TIME_STARTED = datetime.datetime.now()

# check monitor_xmrig_amd() below
CICLES_TIL_REBOOT = 120
CICLES_LENGTH = 120

def validate(file_path: str) -> None:
    """Invoke all validations."""
    _exists(file_path)
    _is_file(file_path)
    _is_readable(file_path)

def _exists(file_path: str) -> None:
    """Check whether a file exists."""
    if not os.path.exists(file_path):
        raise ImportError("{} does not exist".format(file_path))

def _is_file(file_path: str) -> None:
    """Check whether file is actually a file type."""
    if not os.path.isfile(file_path):
        raise ImportError("{} is not a file".format(file_path))

def _is_readable(file_path: str) -> None:
    """Check file is readable."""
    try:
        f = open(file_path, "r")
        f.close()
    except IOError:
        raise ImportError("{} is not readable".format(file_path))

def remove_log(log):
    try:
        os.remove(log)
    except IOError as e:
        print("Could not remove file because: {}".format(e))

def get_gpus():
    return((subprocess.getoutput("ls /sys/class/drm/ | grep 'card[0-9]$'")))

def get_amd_gpus():
    gpu_numbers = get_gpus().split("\n")
    amd_gpus = []
    for card in gpu_numbers:
        command = "ls /sys/kernel/debug/dri/" + card[-1:] + " | grep amd | wc -l"
        #print(command)
        output = subprocess.getoutput(command)
        # print(output)
        if int(output):
            amd_gpus.append(card[-1:])
    print("AMD GPU card numbers{}".format(amd_gpus))
    return(amd_gpus)

def set_fan_speed(n, speed):
    execute_set_fan_speed_command = SET_FAN_SPEED_BIN + " -g " + n + " -s " + speed
    print(execute_set_fan_speed_command)
    args = execute_set_fan_speed_command.split(" ")
    retcode = subprocess.call(args, stdout=FNULL, stderr=subprocess.STDOUT)
    return(retcode)

def set_ppt_table(n):
    set_ppt_command = SET_PPT_BIN + " " + n + " " + PPT
    print(set_ppt_command)
    args = set_ppt_command.split(" ")
    retcode = subprocess.call(args, stdout=FNULL, stderr=subprocess.STDOUT)
    return(retcode)

def run_xmrig(binary, config, log, pid):
    execute_xmrig_amd_command = binary + " -B -S --no-color -c " + config + " -l " + log
    args = execute_xmrig_amd_command.split(" ")
    try:
        process = subprocess.Popen(args, stdout=subprocess.PIPE, shell=False, preexec_fn=os.setsid)
    except OSError as e:
        raise e
    return(process.pid)

def condemn_process(pid, pidfile):
    try:
        outpidfile = open(pidfile, 'w')
        outpidfile.write(str(pid))
        outpidfile.close()
    except OSError as e:
        raise e

def get_last_lines(filename):
    lines = []
    try:
        p = os.popen('tail -n 15 ' + filename).read()
        ansi_escape = re.compile(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]')
        p = ansi_escape.sub('', p)
        lines = p.split('\n')
    except OSError as e:
        print(e)
        logging.info("Could not get last lines from xmrig log: " + e)
    return(lines)

def get_time_and_speeds(filename):
    lastlines = get_last_lines(filename)
    for line in reversed(lastlines):
        search = re.search('\[(.*?)\]\s+speed\s+10s\/60s\/15m\s+(\S+)\s+(\S+)\s+(\S+)\s+H\/s\s+max\s+(\S+)\s+H\/s',
                line)
        if search:
            timeline = search.group(1)
            datetime_obj = datetime.datetime.strptime(timeline, '%Y-%m-%d %H:%M:%S')
            datestring = "{:%Y-%m-%d %H:%M:%S}"
            logging.info('Datetime: ' + datestring.format(datetime_obj))
            print('Datetime: {:%Y-%m-%d %H:%M:%S}'.format(datetime_obj))
            speed_10 = search.group(2)
            speed_60 = search.group(3)
            speed_15m = search.group(4)
            print("speed_10: {} H/s speed_60: {} H/s speed_15m: {} H/s".format(speed_10, speed_60, speed_15m))
            logging.info("speed_10: " + speed_10 + " H/s speed_60: " + speed_60 + " H/s speed_15m: " + speed_15m + " H/s")
            if datetime_obj and speed_10 and speed_60 and speed_15m:
                return([datetime_obj, speed_10, speed_60, speed_15m])
    return(None)

def need_reboot(time_speeds:list, threshold):
    datestring = "{:%Y-%m-%d %H:%M:%S}"
    logging.info('TimeStarted: ' + datestring.format(TIME_STARTED))
    logging.info('TimeNow: ' + datestring.format(time_speeds[0]))
    print('TimeStarted: {:%Y-%m-%d %H:%M:%S}'.format(TIME_STARTED))
    print('TimeNow: {:%Y-%m-%d %H:%M:%S}'.format(time_speeds[0]))
    time_subtracted = time_speeds[0] - TIME_STARTED
    elapsed_minutes = divmod(time_subtracted.days * 86400 + time_subtracted.seconds, 60)[0]
    print('Elapsed minutes since start: {} min.'.format(elapsed_minutes))
    logging.info('Elapsed minutes since start: ' + str(elapsed_minutes) + " min.")
    #if elapsed_minutes < 2:
    if elapsed_minutes < 20:
        logging.info('Not over the 20 min. threshold.')
        return 0
    else:
        # 15m == n/a means rig is not working for 15 min straight - reboot is needed.
        # Easier and most straightforward reboot implementation.
        # TODO - use another implementation for reboot like elapsed time threshold with
        # speed_10 or speed_60 below the threshold
        if time_speeds[3] == 'n/a' or time_speeds[3] < threshold:
            logging.info('Need to reboot. 15m speed ' + time_speeds[3] + ' is lower than threshold: ' + threshold)
            print('Need to reboot. 15m speed {} is lower than threshold {} '.format(time_speeds[3], threshold))
            return 1
        else:
            return 0

def terminate(pid):
    logging.info("Terminating XMRIG pid: " + str(pid))
    print("Terminating XMRIG PID:{} ".format(pid))
    os.killpg(os.getpgid(pid), signal.SIGTERM)
    #os.kill(int(amd_pid), signal.SIGKILL)
    #os.kill(int(cpu_pid), signal.SIGKILL)
    
def monitor_xmrig_amd(log, amd_pid, cpu_pid, threshold):
    running = 1
    sleeptime = CICLES_LENGTH #default is 120 secs.
    cicles = 0
    while running:
        cicles += 1 # each cicle is 2 min
        print("Cicle number {}:".format(cicles))
        print("Sleeping for {}s.:".format(sleeptime))
        logging.info("Cicle number: " + str(cicles))
        logging.info("Sleeping for: " + str(sleeptime) + "s.")
        time.sleep(sleeptime)
        time_speeds = get_time_and_speeds(log)
        if time_speeds is not None:
            ## will reboot every CICLES_TIL_REBOOT (default is 120 cicles or ~4 hours).
            if need_reboot(time_speeds, threshold) or (cicles > CICLES_TIL_REBOOT):
                logging.info("Cicles: " + str(cicles))
                print("Cicles: {}".format(cicles))
                print("Got a reboot signal. Rebooting because you said so.")
                logging.info("Got a reboot signal. Rebooting because you said so.")
                condemn_process(amd_pid, XMRIG_AMD_PID)
                condemn_process(cpu_pid, XMRIG_CPU_PID)
                logging.info("Done.")
                FNULL.close()
                running = 0
        else:
            print("Could not get time and speeds, rebooting...")
            logging.info("Could not get time and speeds, rebooting...")
            condemn_process(amd_pid, XMRIG_AMD_PID)
            condemn_process(cpu_pid, XMRIG_CPU_PID)
            running = 0


# RUNNING THE SCRIPT
parser = argparse.ArgumentParser(description="Run xmrig, monitor, reboot machine.")
parser.add_argument("-t", "--threshold", required=True, type=str, help="Hash rate threshold (H/s) for rebooting. Default is 1900 H/s (rig with two Vega 56 Cards)", default="1900")
args = parser.parse_args()
amd_gpus = []
retcode_fan = []
retcode_ppt = []
xmrig_amd_pid = 0
xmrig_cpu_pid = 0

logging.basicConfig(filename=LOG, format='%(asctime)s - %(message)s', level=logging.INFO)
logging.info('Started.')


logging.info("Changing directory ... ")
os.chdir(WORKING_DIR )
dir_now = os.getcwd()
print("Current mining dir : {}".format(os.getcwd()))
logging.info("Current mining dir :" + dir_now)

print("Threshold is {}".format(args.threshold))
print("Checking files ... ")
logging.info("Checking files ... ")
try:
    validate(XMRIG_AMD_BIN)
    validate(XMRIG_AMD_CONFIG)
    validate(XMRIG_CPU_BIN)
    validate(XMRIG_CPU_CONFIG)
    validate(SET_FAN_SPEED_BIN)
except OSError as e:
    raise e
logging.info("done.")
print("done.")

print("Removing PIDFILES if exist...")
remove_log(XMRIG_AMD_PID)
remove_log(XMRIG_CPU_PID)
print("done.")

print("Removing LOGs...")
remove_log(XMRIG_AMD_LOG)
remove_log(XMRIG_CPU_LOG)
print("done.")

print("Waiting for boot to complete. Sleeping for {}s".format(str(40)))
logging.info("Waiting for boot to complete. Sleeping for " + str(20))
time.sleep(20)

print("Getting number of AMD GPU cards available... ")
logging.info("Getting number of AMD GPU cards available... ")
amd_gpus = get_amd_gpus()
print("done.")
logging.info("done.")

print("Altering fan speeds and starting XMRIG AMD GPUS..")
logging.info("Altering fan speeds and starting XMRIG AMD GPUS..")
for i in amd_gpus:
    retcode_fan.append(set_fan_speed(i, str(85)))
print("Fan return codes {}".format(retcode_fan))
logging.info("Fan return codes " + str(retcode_fan))

print("Running XMRIG-AMD.")
logging.info("Running XMRIG-AMD.")
xmrig_amd_pid = run_xmrig(binary=XMRIG_AMD_BIN,
        config=XMRIG_AMD_CONFIG,
        log=XMRIG_AMD_LOG,
        pid=XMRIG_AMD_PID)
print("Xmrig AMD pid {}". format(xmrig_amd_pid))
logging.info("Xmrig AMD pid " + str(xmrig_amd_pid))

print("Running XMRIG-CPU.")
logging.info("Running XMRIG-CPU.")
xmrig_cpu_pid = run_xmrig(binary=XMRIG_CPU_BIN,
        config=XMRIG_CPU_CONFIG,
        log=XMRIG_CPU_LOG,
        pid=XMRIG_CPU_PID)
print("Xmrig CPU pid {}". format(xmrig_cpu_pid))
logging.info("Xmrig CPU pid " + str(xmrig_cpu_pid))

print("Sleeping for {}s".format(str(90)))
logging.info("Sleeping for " + str(90) + "s")
time.sleep(90)

get_time_and_speeds(XMRIG_AMD_LOG)

print("Altering PPT tables..")
logging.info("Altering PPT tables..")
for i in amd_gpus:
    retcode_ppt.append(set_ppt_table(i))
    retcode_fan.append(set_fan_speed(i, str(85)))
print("PPT return codes {}".format(retcode_ppt))
logging.info("PPT return codes " + str(retcode_ppt))
print("Fan return codes {}".format(retcode_fan))
logging.info("Fan return codes " + str(retcode_fan))

print("Sleeping for {}s to stabilize voltages.".format(str(90)))
logging.info("Sleeping for " + str(90) + " to stabilize voltages.")
time.sleep(90)

get_time_and_speeds(XMRIG_AMD_LOG)

print("Started monitoring...")
logging.info("Started monitoring...")
monitor_xmrig_amd(XMRIG_AMD_LOG, xmrig_amd_pid, xmrig_cpu_pid, args.threshold)
print("Stopped monitoring.")
logging.info("Stopped monitoring.")
