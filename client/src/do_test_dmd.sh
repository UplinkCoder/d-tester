#!/usr/bin/env bash

#set -x

# args:
#    1) directory for build
#    2) os
#    3) runmode (master, pull)

PARALLELISM=1

if [ -f configs/`hostname` ]; then
    . configs/`hostname`
fi

echo -e "\ttesting dmd"

makecmd=make
MODEL=32
EXTRA_ARGS="-j$PARALLELISM"
case "$2" in
    Darwin_32|Darwin_64_32)
        ;;
    Darwin_32_64|Darwin_64_64)
        MODEL=64
        ;;
    FreeBSD_32)
        makecmd=gmake
        ;;
    FreeBSD_64)
        makecmd=gmake
        MODEL=64
        ;;
    Linux_32|Linux_64_32)
        ;;
    Linux_32_64|Linux_64_64)
        MODEL=64
        ;;
    stub)
        exit 0
        ;;
    Win_32)
        makecmd=/usr/bin/make
        EXE=.exe
        ;;
    Win_64)
        makecmd=/usr/bin/make
        MODEL=64
        EXE=.exe
        ;;
    *)
        echo "unknown os: $2"
        exit 1
esac

if [ "$3" == "pull" ]; then
    ARGS="-O -inline -release"
fi

cd $1/dmd/test

# parallelism rules are either too weak or make is broken and occasionally the directory isn't properly created first
$makecmd MODEL=$MODEL RESULTS_DIR=generated generated/d_do_test$EXE >> ../../dmd-unittest.log 2>&1
if [ ! -z "$ARGS" ]; then
    $makecmd MODEL=$MODEL $EXTRA_ARGS RESULTS_DIR=generated ARGS="$ARGS" >> ../../dmd-unittest.log 2>&1
else
    $makecmd MODEL=$MODEL $EXTRA_ARGS RESULTS_DIR=generated >> ../../dmd-unittest.log 2>&1
fi

if [ $? -ne 0 ]; then
    echo -e "\tdmd tests had failures"
    exit 1
fi

