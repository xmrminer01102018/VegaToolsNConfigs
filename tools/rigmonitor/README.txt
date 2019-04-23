Set up passwordless ssh on root account.
If you don't know how to do it, please google it, since it is beyound my scope.
Copy all the files in rigmonitor to VegaToolsNConfigs directory in each rig.
Edit rigList.txt file to reflect your rig ip address(es).
Run "rigMon.sh rigList.txt".

You may tailor it for other miners.

Supported Miners:
1. xmrig-amd
Add/Edit the following to config.json file.
"log-file": "/var/log/hashrate.log",

2. xmr-stak
Add/Edit the following to config.txt file.
"output_file" : "/var/log/hashrate.log",

3. teamreadminer
Add the following to command line.
./teamredminer -a cnv8 -o stratum+tcp://pool.hashvault.pro:7777 -u YOUR_WALLET_ID -p your_password -d 0 --cn_config 16+14 2>&1 | tee /var/log/hashrate.log

4. cast-xmr
Add the following to run.sh or command line.
--log /var/log/hashrate.log

5. claymore duel miner for ethereum
Add/Edit the following to start.bash file.
-logfile /var/log/hashrate.log
 
6. nanominer for Cuckaroo29(C29)
Change the command line to:
./nanominer  2>&1 | tee /var/log/hashrate.log

7. GrinPro miner for Cuckaroo29(C29)
Add/Edit the following to run_GrinPro.sh file.
./GrinProMiner 2>&1 | tee /var/log/hashrate.log


 


Default log file: /var/log/hashrate.log

Note: If you use my default log file, no need to change the script(s).
