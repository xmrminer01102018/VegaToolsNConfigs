# VegaToolsNConfigs
AMD Vega GPU tools and configuration file(s) for Monero(XMR) mining.

VegaUbuntuGuide - How to manually setup Vega mining in Ubuntu.

Working Ubuntu Versions:

Ubuntu MATE 18.04.1

Ubuntu MATE 16.04.5


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

Binary file checksums:
1.   b959ad1ffd296a8c5c75d1eb9e11e467  V56PPT
2.   4c9fc25157f392e9c94ab1536847b7c0  V64PPT
3.   e30d9cd42cfe2190e263cd7f04aaef6f  SoftPPT-1.0.0.jar

LIMITATIONS

Four Vega GPUs per motherboard for XMR mining.  Risers and extenders working with some motherboards.

The limitations have been upgraded to 6 GPUs with risers.

The limitations have been upgraded to 8 GPUs with Colorful's motherboard without risers.


Contact(s)

xmrminer01102018@gmail.com

Glossary
1. PPT - Soft Power Play Table
2. Ubuntu - Linux OS
