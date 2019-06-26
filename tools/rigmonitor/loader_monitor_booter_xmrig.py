#!/usr/bin/python3

"""Run xmrig, monitor, reboot machine."""
import os
#from subprocess import call
import subprocess, select
import re
import sys, signal
import time
import argparse
from os.path import isfile, join

FNULL = open(os.devnull, 'w')
XMRIG_AMD_BIN="/root/VegaToolsNConfigs/xmrig-amd.bin"
XMRIG_AMD_PID="/root/VegaToolsNConfigs/xmrig-amd.pid"
XMRIG_AMD_CONFIG="/root/VegaToolsNConfigs/xmrig-amd.config.json"
XMRIG_AMD_LOG="/root/VegaToolsNConfigs/xmrig-amd.config.log"
XMRIG_CPU_BIN="/root/VegaToolsNConfigs/xmrig-cpu.bin"
XMRIG_CPU_PID="/root/VegaToolsNConfigs/xmrig-cpu.pid"
XMRIG_CPU_CONFIG="/root/VegaToolsNConfigs/xmrig-cpu.config.json"
XMRIG_CPU_LOG="/root/VegaToolsNConfigs/xmrig-cpu.config.log"
SET_FAN_SPEED_BIN='/root/VegaToolsNConfigs/setAMDGPUFanSpeed.sh'
SET_PPT_BIN='/root/VegaToolsNConfigs/setPPT.sh'
PPT='/root/VegaToolsNConfigs/V56GIG1'


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
    execute_xmrig_amd_command = binary + " -B -c " + config + " -l " + log
    args = execute_xmrig_amd_command.split(" ")
    try:
        process = subprocess.Popen(args, stdout=subprocess.PIPE, shell=False, preexec_fn=os.setsid)
    except OSError as e:
        raise e
    try:
        outpidfile = open(pid, 'w')
        outpidfile.write(str(process.pid))
        outpidfile.close()
    except OSError as e:
        raise e
    return(process.pid)

def kill_xmrig(pid):
    try:
        os.killpg(os.getpgid(int(pid)), signal.SIGTERM)
    except OSError as e:
        print("could not kill pid {}".format(pid))
        raise e

def monitor_xmrig_amd(log):
    f = subprocess.Popen(['tail','-F', log],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p = select.poll()
    p.register(f.stdout)

    while True:
        if p.poll(1):
            print(f.stdout.readline())
        time.sleep(1)

# RUNNING THE SCRIPT
parser = argparse.ArgumentParser(description="Run xmrig, monitor, reboot machine.")
group = parser.add_mutually_exclusive_group()
#group.add_argument("-v", "--verbose", action="store_true")
# parser.add_argument("-n", "--nGPU", required=True, type=str, help="number of GPU cards")
parser.add_argument("-t", "--threshold", required=True, type=str, help="Hash rate threshold (H/s) for rebooting. Default is 1900 H/s.", default="1900")
args = parser.parse_args()
amd_gpus = []
retcode_fan = []
retcode_ppt = []
xmrig_amd_pid = 0
xmrig_cpu_pid = 0
print("Checking files ... ")
try:
    validate(XMRIG_AMD_BIN)
    validate(XMRIG_AMD_CONFIG)
    validate(XMRIG_CPU_BIN)
    validate(XMRIG_CPU_CONFIG)
    validate(SET_FAN_SPEED_BIN)
except OSError as e:
    raise e
print("done.")

print("Getting number of AMD GPU cards available... ")
amd_gpus = get_amd_gpus()
print("done.")

print("Altering fan speeds and starting XMRIG AMD GPUS..")
for i in amd_gpus:
    retcode_fan.append(set_fan_speed(i, str(85)))
print("Fan return codes {}".format(retcode_fan))

xmrig_amd_pid = run_xmrig(binary=XMRIG_AMD_BIN,
        config=XMRIG_AMD_CONFIG,
        log=XMRIG_AMD_LOG,
        pid=XMRIG_AMD_PID)
print("Xmrig AMD pid {}". format(xmrig_amd_pid))

xmrig_cpu_pid = run_xmrig(binary=XMRIG_CPU_BIN,
        config=XMRIG_CPU_CONFIG,
        log=XMRIG_CPU_LOG,
        pid=XMRIG_CPU_PID)
print("Xmrig CPU pid {}". format(xmrig_cpu_pid))

time.sleep(40)

print("Altering PPT tables..")
for i in amd_gpus:
    retcode_ppt.append(set_ppt_table(i))
    retcode_fan.append(set_fan_speed(i, str(85)))
print("PPT return codes {}".format(retcode_ppt))
print("Fan return codes {}".format(retcode_fan))

time.sleep(60)

monitor_xmrig_amd(XMRIG_AMD_LOG)

print("Group killing AMD pid {}".format(xmrig_amd_pid))
kill_xmrig(xmrig_amd_pid)
print("Group killing CPU pid {}".format(xmrig_cpu_pid))
kill_xmrig(xmrig_cpu_pid)
