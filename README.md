# VegaToolsNConfigs
AMD Vega GPU tools and configuration file(s) for Monero(XMR) mining.


# NOTE:
This guide will work with most cryptonight V7 coins at Windows level hash rate(s).  Most cryptonight V8 miners will not work with 18.30 driver.  Please use cast-xmr for the time being.  The hash rate is around 1250 H/s for XMR.  If you want to use xmrig-amd or xmr-stak, use ROCm 1.9.1+.  UPDATE: The cast-xmr with Vega 56/64/FE will get you 1600/1870/1960 H/s on --intensity=10/10/9(default is 7).  All miners(cast-xmr/teamredminer/xmrig-amd/xmr-stak) have the very close hash rates on ALL VEGA GPUs under amdgpu-pro 18.10/18.30/18.40.  ROCm 1.9.1 is still stuck with lower hash rates.

VegaUbuntuGuide - How to manually setup Vega mining in Ubuntu for CryptoNight V7.

VegaUbuntuGuide4CryptoNightV8 - How to manually setup Vega mining in Ubuntu for CryptoNight V8 with ROCm driver.

VegaUbuntuQuickGuideForCNv2 - How to manually setup Vega mining in Ubuntu for CryptoNight V8 with AMD drivers for "Experts". 

VegaUbuntuGuideForCNv2- How to manually setup Vega mining in Ubuntu for CryptoNight V8 with AMD drivers.

VegaCentOSGuideForCNv2 - How to manually setup Vega mining in CentOs for CryptoNight V8 with AMD drivers.


# Tips and Tricks
If you have many rigs with the same type of Vega cards, follow the guide with one rig and tar up the xmrig-amd or xmr-stak and .openclcache directories.  On the other rig(s) just install amdgpu-pro 18.30 or 18.40 and copy the tar file from the first rig and untar them in ~/git directory and run the miners.  Dont' forget the ~/.openclcache if you are using xmr-stak.


# Working Ubuntu Versions:

Ubuntu MATE 18.04.1

Ubuntu MATE 16.04.5

# Working CentOS Versions:

CentOS 7.5(1804)


# Working amdgpu-pro and ROCm versions:

amdgpu-pro 18.10/18.30

amdgpu-pro 18.10/18.40

ROCm 1.9.1


RadeonProDuo_R9390XQuickGuide - How to setup xmrig-amd miner for Radeon Pro Duo and R9 390X GPUs.

VegaUbuntuGuideWithAutoTools - How to setup Vega mining in Ubuntu with 90% automation.  Essentially the same as VegaUbuntuGuide but after a few manual downloads, run the scripts to setup.

OptimalRunningSequencesForVegas - Running sequences for maximum hash rate.

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

# Binary file checksums:
1.   b959ad1ffd296a8c5c75d1eb9e11e467  V56PPT
2.   d6bcb2130d4050cf26e93584be742cef  LGMV56PPT
3.   4c9fc25157f392e9c94ab1536847b7c0  V64PPT
4.   ed13313360a2a4306e11a62afd111ace  V64V8PPT
5.   e30d9cd42cfe2190e263cd7f04aaef6f  SoftPPT-1.0.0.jar

# LIMITATIONS

Four Vega GPUs per motherboard for XMR mining.  Risers and extenders working with some motherboards.

The limitations have been upgraded to 6 GPUs with risers.

The limitations have been upgraded to 8 GPUs with Colorful's motherboard without risers.

# Hash rates and power usage from lm-sensors(Not from wall)

CNv2 power usage below.  CNv1 power usages are 20 W lower.

V56 @ 120 +/- 10 W

V64 @ 135 +/- 10 W

VFE @ 155 +/- 10 W

For TeamRedMiner, VFE is about 10 W lower. 


cast-xmr (Ubuntu)

    Vega 56(Hynix): 1630 H/s
    Vega 56(Samsung): 1730 H/s
    Vega 64: 1870 H/s
    Vega FE: 1960 H/s


TeamRedMiner (Ubuntu, CentOS)

    Vega 56(Hynix): 1900 H/s
    Vega 56(Samsung): 1950 H/s
    Vega 64: 2020 H/s
    Vega FE: 2100 H/s


xmrig-amd (Ubuntu)

    Vega 56(Hynix): 1735 H/s
    Vega 56(Samsung): 1860 H/s
    Vega 64: 1950 H/s
    Vega FE: 2035 H/s


xmr-stak (Ubuntu)

    Vega 56(Hynix): 1720 H/s
    Vega 56(Samsung): 1850 H/s
    Vega 64: 1940 H/s
    Vega FE: 2040 H/s


# Tested coins:

    CryptoNightV7(CNv1):

        Monero(XMR)(Updated to CNv2)

        GRAFT (Updated to CNv2)

    CryptoNightV8/V9(CNv2):

        Monero(XMR)
        
        GRAFT


# Contact(s)

xmrminer01102018@gmail.com

# Glossary
1. PPT - Soft Power Play Table
2. Ubuntu - Linux OS
