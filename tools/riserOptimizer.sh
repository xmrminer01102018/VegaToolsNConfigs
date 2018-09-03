#!/bin/bash
./setSMClockVoltages.sh 0,1,2,3,4,5 MSIV56H.data_P7P3OC8_7 skip
./setGPUOC.sh 0,1,2,3,4,5 8 7
./setPPT.sh 0 V56PPT
./setPPT.sh 1 V56PPT
./setPPT.sh 2 V56PPT
./setPPT.sh 3 V56PPT
./setPPT.sh 4 V56PPT
./setPPT.sh 5 V56PPT
./setAMDGPUFanSpeed.sh -g 0,1,2,3,4,5 -s 82
