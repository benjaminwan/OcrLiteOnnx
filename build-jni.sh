#!/usr/bin/env bash

##### build jni for MacOS or Linux
mkdir -p build-jni
pushd build-jni
cmake -DCMAKE_BUILD_TYPE=Release -DOCR_LITE_JNI=ON ..
make
popd
