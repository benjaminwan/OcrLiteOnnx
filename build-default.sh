#!/usr/bin/env bash

sysOS=$(uname -s)
NUM_THREADS=1
if [ $sysOS == "Darwin" ]; then
  #echo "I'm MacOS"
  NUM_THREADS=$(sysctl -n hw.nCPU)
elif [ $sysOS == "Linux" ]; then
  #echo "I'm Linux"
  NUM_THREADS=$(grep ^processor /proc/cpuinfo | wc -l)
else
  echo "Other OS: $sysOS"
fi

mkdir -p ${sysOS}-BIN
pushd ${sysOS}-BIN
cmake -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=Release -DOCR_OUTPUT="BIN" ..
cmake --build . --config Release -j $NUM_THREADS
cmake --build . --config Release --target install
popd


mkdir -p ${sysOS}-JNI
pushd ${sysOS}-JNI
cmake -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=Release -DOCR_OUTPUT="JNI" ..
cmake --build . --config Release -j $NUM_THREADS
cmake --build . --config Release --target install
popd


mkdir -p ${sysOS}-CLIB
pushd ${sysOS}-CLIB
cmake -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=Release -DOCR_OUTPUT="CLIB" ..
cmake --build . --config Release -j $NUM_THREADS
cmake --build . --config Release --target install
popd

