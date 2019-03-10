# VegaToolsNConfigs
AMD Vega GPU tools and configuration file(s) mostly for Monero(XMR) mining.
I will be expanding to other miners/coins/algos/gpus but the main focus will be for XMR and Vega+ GPUs.


# NOTE:

Confusing terms:

Depending on the miner, pool...etc the folloing will be used interchangeably.

Cryptonight r AKA cn/r AKA CNr

Cryptonight rwz AKA cn/rwz AKA CNrwz AKA Cryptonight V8 ReverseWaltz

For cn/wrz(GRAFT) and cn/r(XMR), use the CNv2 guides and skip amdgpu-pro 18.10 section for latest xmrig-amd and xmr-stak.  Will be updating the guides.

Crpytonight R and ReverseWaltz:

cast-xmr: development has stopped and CNr and CNrwz will not be supported.

xmrig-amd: Version 2.14.0 works on ALL VEGA GPUs under amdgpu-pro 18.30/18.40/18.50 with CNr(XMR).

xmrig-amd: Version 2.14.0 works on ALL VEGA GPUs under amdgpu-pro 18.30/18.40/18.50 with CNrwz(GRAFT).

xmr-stak: Testing version 2.10.0.

teamredminer: Version 0.4.0 beta works on ALL VEGA GPUs under amdgpu-pro 18.30/18.40/18.50 with CNr(XMR).

Cryptonight V8:

The xmrig-amd and xmr-stark cryptonight V8 miners will not work with amdgpu-pro 18.30/18.40/18.50 drivers alone so you have to use them in conjuction with 18.10.  However, they will work with ROCm 1.9.1+ with low hash rate.  All miners(cast-xmr/teamredminer/xmrig-amd/xmr-stak) have the very close hash rates on ALL VEGA GPUs under amdgpu-pro 18.10/18.30/18.40/18.50.  ROCm 1.9.1, 1.9.2, 2.0.0 and 2.1.0 are still stuck with lower hash rates.

Cryptonight V7:

VegaUbuntuGuide will work with most cryptonight V7 coins at Windows level hash rate(s).


# GUIDES

VegaUbuntuGuide - How to manually setup Vega mining in Ubuntu for CryptoNight V7.

VegaUbuntuGuide4CryptoNightV8 - How to manually setup Vega mining in Ubuntu for CryptoNight V8 with ROCm driver.

VegaUbuntuQuickGuideForCNv2 - How to manually setup Vega mining in Ubuntu for CryptoNight V8 with AMD drivers for "Experts". 

VegaUbuntuGuideForCNv2- How to manually setup Vega mining in Ubuntu for CryptoNight V8 with AMD drivers.

VegaCentOSGuideForCNv2 - How to manually setup Vega mining in CentOs for CryptoNight V8 with AMD drivers.


RadeonProDuo_R9390XQuickGuide - How to setup xmrig-amd miner for Radeon Pro Duo and R9 390X GPUs(CryptoNight V8).

RX470UbuntuGuideForCNv2 - How to setup RX470 bios, drivers and mining in Ubuntu to get 1kH/s for Monero(XMR) with CryptoNight V8 algo.

VegaUbuntuGuideWithAutoTools - How to setup Vega mining in Ubuntu with 90% automation.  Essentially the same as VegaUbuntuGuide but after a few manual downloads, run the scripts to setup.

OptimalRunningSequencesForVegas - Vega running sequences for maximum hash rate(pre-CNr).

OptimalRunningSequencesForRX470 - RX470 running sequences for maximum hash rate.

History - Addition(s) and changes by date.

TestedHarware - Limited hardware list working or not.

config folder - contains gpu and mem clock settings.

config/PPTDIR folder - contains
1. PPT binary files for Vega 56/64/FE.
2. PPT hex table in text format to generate binary PPT file.
3. SoftPPT-1.0.0.jar to convert hex table to binary PPT file.
4. SoftPPTProj.tgz(The maven java project to make SoftPPT-1.0.0.jar program).

tools folder - contains shell scripts for fan speed, overclocking, monitoring and setting PPT.

tools/rigmonitor folder - contains rig monitoring scripts using passwordless ssh method.
    Supported miners: xmrig-amd, xmr-stak, cast-xmr, teamredminer, and claymore duel miner(ETH).


# Tips and Tricks
For CNv2 - If you have many rigs with the same type of Vega cards, follow the guide with one rig and tar up the xmrig-amd or xmr-stak and .openclcache directories.  On the other rig(s) just install amdgpu-pro 18.30/18.40/18.50 and copy the tar file from the first rig and untar them in ~/git directory and run the miners.  Dont' forget the ~/.openclcache if you are using xmr-stak.


# VEGA
# Working Ubuntu Versions:

Ubuntu MATE 18.04.1

Ubuntu MATE 16.04.5

# Working CentOS Versions:

CentOS 7.5(1804)


# Working amdgpu-pro and ROCm versions:


For xmrig-amd 2.13.0+, amdgpu-pro 18.10 is no longer needed to compile and run the miner.

amdgpu-pro 18.10/18.30

amdgpu-pro 18.10/18.40

amdgpu-pro 18.10/18.50

ROCm 1.9.1

ROCm 1.9.2

ROCm 2.0.0

ROCm 2.1.0

# Binary file checksums:
1.   b959ad1ffd296a8c5c75d1eb9e11e467  V56PPT
2.   d6bcb2130d4050cf26e93584be742cef  LGMV56PPT
3.   4c9fc25157f392e9c94ab1536847b7c0  V64PPT
4.   ed13313360a2a4306e11a62afd111ace  V64V8PPT
5.   e30d9cd42cfe2190e263cd7f04aaef6f  SoftPPT-1.0.0.jar

# LIMITATIONS

Four Vega GPUs per motherboard for XMR mining.  Risers and extenders working with some motherboards.

The limitations have been upgraded to 6 GPUs with risers.

The limitations have been upgraded to 8 GPUs with Colorful's and Biostar TB250-BTC D+ motherboards without risers.

# Hash rates and power usage from lm-sensors(Not from wall)

CNv2 power usage below.  CNv1 power usages are 20 W lower.

V56 @ 120 +/- 10 W

V64 @ 135 +/- 10 W

VFE @ 155 +/- 10 W

For TeamRedMiner, VFE is about 10 W lower. 

CNr power usage below.

V56 @ 120 +/- 10 W (xmrig-amd 2.14.0)

V64 @ 140 +/- 10 W (xmrig-amd 2.14.0)

VFE @ 150 +/- 10 W (xmrig-amd 2.14.0)




cast-xmr (Ubuntu) (CNr+ - no longer supported)

TeamRedMiner (Ubuntu, CentOS) (CNr - 0.4.0 beta - Test in progress)

    Vega 56(Hynix): 1800-1900 H/s
    Vega 56(Samsung): 1850-1950 H/s
    Vega 64: 1980-2100 H/s
    Vega FE: 2.1 kH/s


xmrig-amd (Ubuntu) (CNr - Use 2.13.0+ Tested version: 2.13.0, 2.14.0.  2.14.0 uses 10Watt less power than 2.13.0)

    Vega 56(Hynix): 1735 H/s
    Vega 56(Samsung): 1860 H/s
    Vega 64: 1950 H/s
    Vega FE: 2035 H/s


xmrig-amd (Ubuntu) (CNrwz - Use 2.13.0+ Tested version: 2.13.0, 2.14.0.  2.14.0 uses 10Watt less power than 2.13.0)

    Vega 56(Hynix): 2100 H/s
    Vega 56(Samsung): 2400 H/s
    Vega 64: 2600 H/s
    Vega FE: 2630 H/s


xmr-stak (Ubuntu) (CNr and CNrwz - 2.10.0 working with some invalid results for both pre-compiled binaries and native binaries.)

    Vega 56(Hynix): TBD H/s
    Vega 56(Samsung): TBD H/s
    Vega 64: TBD H/s
    Vega FE: TBD H/s


# RX470
# Working Ubuntu Versions:

Ubuntu MATE 18.04.1

# Working amdgpu-pro versions:

amdgpu-pro 18.30

amdgpu-pro 18.40

amdgpu-pro 18.50

# Hash rates and power usage from lm-sensors(Not from wall)

RX470 @ 60 +/- 5 W

cast-xmr (Ubuntu) (CNr+ - no longer supported)

TeamRedMiner (Ubuntu) (CNr - 0.4.0 beta)

CNv2: For the same setup 18.40 got additional 10+ H/s

    RX470(Hynix): 1008/1020/1003 H/s (driver 18.30/18.40/18.50)
    RX470(Micron): 1008/1020/1003 H/s (driver 18.30/18.40/18.50)

CNr:

    RX470(Hynix): 1008 H/s
    RX470(Micron): 1008 H/s


xmrig-amd (Ubuntu) (CNr - Version: 2.14.0)

    RX470(Hynix): 930 H/s
    RX470(Micron): 930 H/s

xmrig-amd (Ubuntu) (CNrwz Version: 2.14.0)

    RX470(Hynix): 1225 H/s
    RX470(Micron): 1225 H/s



# Tested coins:

    CryptoNightV8/V9(CNv2):

        Monero(XMR)
        
        GRAFT

    CryptoNight(CNr):

        Monero(XMR)
        
    CryptoNight(CNrwz):

        GRAFT
        

# Contact(s)

xmrminer01102018@gmail.com

# Glossary
1. PPT - Soft Power Play Table
2. Ubuntu/CentOS - Linux OS
