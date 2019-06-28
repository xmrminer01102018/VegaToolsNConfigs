#!/usr/bin/python3

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
    logging.info("Rebooting")
    time.sleep(4)
    try:
        os.system('sudo shutdown -r now')
        os.system('reboot')
        logging.info("Goodbye.")
    except OSError as e:
        logging.info("could not reboot: " + e)
        raise(e)
    time.sleep(4)
    try:
        os.system('reboot')
        logging.info("Goodbye.")
    except OSError as e:
        logging.info("could not reboot: " + e)
        raise(e)
else:
    logging.info("Nothing to do.")
    exit
