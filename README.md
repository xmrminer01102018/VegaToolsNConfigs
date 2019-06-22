# VegaToolsNConfigs
AMD Vega GPU tools and configuration file(s) mostly for Monero(XMR) mining.
I will be expanding to other miners/coins/algos/gpus but the main focus will be for XMR and Vega+ GPUs.


# NOTE:

Confusing terms:

Depending on the miner, pool...etc the folloing will be used interchangeably.

Cryptonight r AKA cn/r AKA CNr AKA CNv4

Cryptonight rwz AKA cn/rwz AKA CNrwz AKA Cryptonight V8 ReverseWaltz

Crpytonight R and ReverseWaltz:

cast-xmr: development has stopped and CNr and CNrwz will not be supported.

xmrig-amd: Version 2.14.0-2.14.4 work on ALL VEGA GPUs under amdgpu-pro 18.30/18.40/18.50 with CNr(XMR) and CNrwz(GRAFT).

xmrig-amd: Version 2.14.0-2.14.4 work on Radeon VII under amdgpu-pro 19.10 with CNr(XMR) and CNrwz(GRAFT).

xmr-stak: Testing version 2.10.0/1/2/3/4/5.(Getting "AMD Invalid Result GPU ID 0" for pre-compiled binaries and native binaries)

teamredminer: Version 0.4.2-0.5.2 beta work on ALL VEGA GPUs under amdgpu-pro 18.30/18.40/18.50 with CNr(XMR) and CNrwz(GRAFT).

teamredminer: Version 0.4.2-0.5.2 beta work on Radeon VII under amdgpu-pro 19.10 with CNr(XMR) and 
CNrwz(GRAFT).

Cryptonight V8:

The xmrig-amd and xmr-stark cryptonight V8 miners will not work with amdgpu-pro 18.30/18.40/18.50 drivers alone so you have to use them in conjuction with 18.10.  However, they will work with ROCm 1.9.1+ with low hash rate.  All miners(cast-xmr/teamredminer/xmrig-amd/xmr-stak) have the very close hash rates on ALL VEGA GPUs under amdgpu-pro 18.10/18.30/18.40/18.50.  ROCm 1.9.1, 1.9.2, 2.0.0 and 2.1.0 are still stuck with lower hash rates.

Cryptonight V7:

VegaUbuntuGuide will work with most cryptonight V7 coins at Windows level hash rate(s).


# GUIDES

VegaUbuntuGuide - How to manually setup Vega mining in Ubuntu for CryptoNight V7.

VegaUbuntuGuide4CryptoNightV8 - How to manually setup Vega mining in Ubuntu for CryptoNight V8 with ROCm driver.

VegaUbuntuQuickGuideForCNrCNrwz - How to manually setup Vega mining in Ubuntu for CNr/CNrwz with AMD drivers for "Experts". 

VegaUbuntuGuideForCNrCNrwz - How to manually setup Vega mining in Ubuntu for CNr/CNrwz with AMD drivers.

VegaUbuntuQuickGuideForCNv2 - How to manually setup Vega mining in Ubuntu for CryptoNight V8 with AMD drivers for "Experts". 

VegaUbuntuGuideForCNv2- How to manually setup Vega mining in Ubuntu for CryptoNight V8 with AMD drivers.

VegaCentOSGuideForCNv2 - How to manually setup Vega mining in CentOs for CryptoNight V8 with AMD drivers.

VegaCentOSGuideForCNrCNrwz - How to manually setup Vega mining in CentOs for CNr and CNrwz with AMD drivers.

RadeonProDuo_R9390XQuickGuide - How to setup xmrig-amd miner for Radeon Pro Duo and R9 390X GPUs(CryptoNight V8).

RadeonProDuoCNrCNrwzQuickGuide - How to setup xmrig-amd miner for Radeon Pro Duo GPU(CNr and CNrwz).

RX470UbuntuGuideForCNv2 - How to setup RX470 bios, drivers and mining in Ubuntu to get 1kH/s for Monero(XMR) with CryptoNight V8 algo.

VegaUbuntuGuideWithAutoTools - How to setup Vega mining in Ubuntu with 90% automation.  Essentially the same as VegaUbuntuGuide but after a few manual downloads, run the scripts to setup.

OptimalRunningSequencesForVegas - Vega running sequences for maximum hash rate(CNv2/CNr/CNrwz).

OptimalRunningSequencesForRX470 - RX470 running sequences for maximum hash rate(CNv2/CNr/CNrwz).

OptimalRunningSequencesForRadeonVII - Radeon VII running sequences for maximum hash rate(CNr/CNrwz/C29/Ethash).

History - Addition(s) and changes by date.

TestedHarware - Limited hardware list working or not.

config folder - contains gpu and mem clock settings.

config/PPTDIR folder - contains
1. PPT binary files for Vega 56/64/FE and Radeon VII.
2. PPT hex table(s) in text format to generate binary PPT file(s).
3. SoftPPT-1.0.0.jar to convert hex table to binary PPT file.
4. SoftPPTProj.tgz(The maven java project to make SoftPPT-1.0.0.jar program).

tools folder - contains shell scripts for fan speed, overclocking, monitoring and setting PPT.

tools/rigmonitor folder - contains rig monitoring scripts using passwordless ssh method.
    Supported miners: xmrig-amd, xmr-stak, cast-xmr, teamredminer, and claymore duel miner(ETH).
    
GPU folder - contains different gpus and their hashrate, power usage, working linux version(s), miners, drivers...etc.


# Tips and Tricks
For CNv2 - If you have many rigs with the same type of Vega cards, follow the guide with one rig and tar up the xmrig-amd or xmr-stak and .openclcache directories.  On the other rig(s) just install amdgpu-pro 18.30/18.40/18.50 and copy the tar file from the first rig and untar them in ~/git directory and run the miners.  Dont' forget the ~/.openclcache if you are using xmr-stak.



# Tested coins:

    CryptoNightV8/V9(CNv2):

        Monero(XMR)
        
        GRAFT

    CryptoNight(CNr):

        Monero(XMR)
        
    CryptoNight(CNrwz):

        GRAFT
        
    Ethash:

        ETH
        
    Cuckaroo29(C29):

        Grin
        

# Contact(s)

xmrminer01102018@gmail.com

# Glossary
1. PPT - Soft Power Play Table
2. Ubuntu/CentOS - Linux OS
