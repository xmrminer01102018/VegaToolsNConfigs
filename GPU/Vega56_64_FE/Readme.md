# VEGA
# Working Ubuntu Versions:

Ubuntu MATE 18.04.1 (up to latest amdgpu-pro 18.X.  19.X not working)

Ubuntu MATE 18.04.2 (up to latest amdgpu-pro NOTE:Video driver is broken.  VNC and ssh sessions only)

Ubuntu MATE 16.04.5 (up to amdgpu-pro 18.30)

Ubuntu Desktop 16.04.6 (up to amdgpu-pro 18.30)

# Working CentOS Versions:

CentOS 7.5(1804) (amdgpu-pro 18.50)


# Working/Tested amdgpu-pro and ROCm versions:


For xmrig-amd 2.13.0+, amdgpu-pro 18.10 is no longer needed to compile and run the miner.

CNv1/CNv2:
----------

amdgpu-pro 18.10/18.30 (Ubuntu, CentOS)

amdgpu-pro 18.10/18.40 (Ubuntu, CentOS)

amdgpu-pro 18.10/18.50 (Ubuntu, CentOS)

ROCm 1.9.1 (Ubuntu)

ROCm 1.9.2 (Ubuntu)

ROCm 2.0.0 (Ubuntu)

ROCm 2.1.0 (Ubuntu)


CNr/CNrwz:
----------

amdgpu-pro 18.30 (Ubuntu)

amdgpu-pro 18.40 (Ubuntu)

amdgpu-pro 18.50 (Ubuntu, CentOS)

ROCm 2.0.0 (Ubuntu)

ROCm 2.1.0 (Ubuntu)



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

CNr power usage below for xmrig-amd 2.14.0+ and teamredminer 0.4.0+ beta.

V56 @ 120 +/- 10 W

V64 @ 140 +/- 10 W

VFE @ 150 +/- 10 W


CNv2 power usage below.  CNv1 power usages are 20 W lower.

V56 @ 120 +/- 10 W

V64 @ 135 +/- 10 W

VFE @ 155 +/- 10 W

For TeamRedMiner, VFE is about 10 W lower. 



cast-xmr (Ubuntu) (CNr+ - no longer supported)

TeamRedMiner (Ubuntu, CentOS) (CNr - V0.4.0+ beta)

    Vega 56(Hynix): 1800-1900 H/s
    Vega 56(Samsung): 1850-1950 H/s
    Vega 64: 1980-2100 H/s
    Vega FE: 2.1 kH/s

TeamRedMiner (Ubuntu, CentOS) (CNrwz - V0.4.2-0.4.4 beta)

    Vega 56(Hynix): 2450+ H/s
    Vega 56(Samsung): 2450+ H/s
    Vega 64: 2600+ H/s
    Vega FE: 2750+ kH/s


xmrig-amd (Ubuntu) (CNr - Use V2.13.0+ Tested version: 2.13.0, 2.14.0.  2.14.0 uses 10Watt less power than 2.13.0)

    Vega 56(Hynix): 1735 H/s
    Vega 56(Samsung): 1860 H/s
    Vega 64: 1950 H/s
    Vega FE: 2035 H/s


xmrig-amd (Ubuntu) (CNrwz - Use V2.13.0+ Tested version: 2.13.0, 2.14.0.  2.14.0 uses 10Watt less power than 2.13.0)

    Vega 56(Hynix): 2100 H/s
    Vega 56(Samsung): 2400 H/s
    Vega 64: 2600 H/s
    Vega FE: 2630 H/s


xmr-stak (Ubuntu) (CNr - V2.10.0-2.10.5 working with some invalid results for both pre-compiled binaries and native binaries.)

    Vega 56(Hynix): TBD H/s
    Vega 56(Samsung): TBD H/s
    Vega 64: TBD H/s
    Vega FE: 2000 H/s(miner) 1700 H/s(pool) 300 H/s(Fee+Invalid)

xmr-stak (Ubuntu) (CNrwz - V2.10.0-2.10.5 working with some invalid results for both pre-compiled binaries and native binaries.)

    Vega 56(Hynix): TBD H/s
    Vega 56(Samsung): 2200 H/s(miner) 1800 H/s(pool) 400 H/s(Fee+Invalid)
    Vega 64: TBD H/s
    Vega FE: TBD H/s

GrinPro (Ubuntu) (C29 V2.2)

    Vega 56(Hynix): TBD gps
    Vega 56(Samsung): TBD gps
    Vega 64: TBD gps
    Vega FE: 4.55 gps
    Vega FE(LC): 4.75 gps

