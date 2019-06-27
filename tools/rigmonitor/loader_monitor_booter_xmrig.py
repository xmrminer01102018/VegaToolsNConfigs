#!/usr/bin/python3

"""Run xmrig, monitor, reboot machine."""
import os
#from subprocess import call
import subprocess, select
import re
import sys, signal
import time
import argparse
import string
from os.path import isfile, join
import re
import time, datetime

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
TIME_STARTED=datetime.datetime.now()

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
    execute_xmrig_amd_command = binary + " -S -B --no-color -c " + config + " -l " + log
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

def get_last_lines(filename):
    p = os.popen('tail -n 10 ' + filename).read()
    ansi_escape = re.compile(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]')
    p = ansi_escape.sub('', p)
    lines = p.split('\n')
    return(lines)

def get_time_and_speeds(lastlines):
    # TO DO - read list from last to first
    for line in lastlines:
        search = re.search('\[(.*?)\]\s+speed\s+10s\/60s\/15m\s+(\S+)\s+(\S+)\s+(\S+)\s+H\/s\s+max\s+(\S+)\s+H\/s',
                line)
        if search:
            timeline = search.group(1)
            datetime_obj = datetime.datetime.strptime(timeline, '%Y-%m-%d %H:%M:%S')
            #print('TimeStarted: {:%Y-%m-%d %H:%M:%S}'.format(TIME_STARTED))
            print('Datetime: {:%Y-%m-%d %H:%M:%S}'.format(datetime_obj))
            #elapsed_minutes = (datetime_obj - TIME_STARTED).days * 24 * 60
            #elapsed_hours = (datetime_obj - TIME_STARTED).days * 24
            #print('Elapsed minutes: {}'.format(elapsed_minutes))
            #print('Elapsed hours: {}'.format(elapsed_hours))
            speed_10 = search.group(2)
            speed_60 = search.group(3)
            speed_15m = search.group(4)
            print("speed_10:{} speed_60:{} speed_15m:{}".format(speed_10, speed_60, speed_15m))
    if datetime_obj and speed_10 and speed_60 and speed_15m:
        return([datetime_obj, speed_10, speed_60, speed_15m])
    else:
        return(None)

def reboot(time_speeds:list):
    print('TimeStarted: {:%Y-%m-%d %H:%M:%S}'.format(TIME_STARTED))
    print('Datetime: {:%Y-%m-%d %H:%M:%S}'.format(time_speeds[0]))
    elapsed_minutes = (datetime_obj - TIME_STARTED).days * 24 * 60
    print('Elapsed minutes: {}'.format(elapsed_minutes))
    if elapsed_minutes < 15:
        return 0
    else:
        if time_speeds[3] == 'n/a':
            return 1
    #elapsed_hours = (datetime_obj - TIME_STARTED).days * 24
    #print('Elapsed hours: {}'.format(elapsed_hours))

def terminate(amd_pid, cpu_pid):
    os.kill(int(amd_pid), signal.SIGTERM)
    os.kill(int(cpu_pid), signal.SIGTERM)
    try: 
       os.kill(int(amd_pid), 0)
       os.kill(int(cpu_pid), 0)
       #raise Exception("""wasn't able to kill the process 
       #                   HINT:use signal.SIGKILL or signal.SIGABORT""")
       return 0
   except OSError as ex:
       return 1
    
def monitor_xmrig_amd(log):
    running = 1
    sleeptime = 120
    cicles = 0
    nonstop_times = ['0', '0', '0']
    while running:
        cicles += 1 # each cicle is 2 min
        time.sleep(sleeptime)
        lastlines = get_last_lines(log)
        time_speeds = get_time_and_speeds(lastlines)
        if time_speeds not None:
            if reboot(time_speeds) or (cicles == 90):
               #erminate(XMRIG_AMD_PID, XMRIG_CPU_PID)
               # os.system('reboot')
        else:
               terminate(XMRIG_AMD_PID, XMRIG_CPU_PID)
               running = 0
               # os.system('reboot')
            


                





# RUNNING THE SCRIPT
parser = argparse.ArgumentParser(description="Run xmrig, monitor, reboot machine.")
#group = parser.add_mutually_exclusive_group()
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

for i in amd_gpus:
    retcode_fan.append(set_fan_speed(i, str(15)))
