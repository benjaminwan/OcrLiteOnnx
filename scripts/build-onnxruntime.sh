#!/bin/bash
# build onnxruntime 1.6 by benjaminwan
# CMakeFiles/onnxruntime.dir/link.txtlinklib*.a

function cmakeParams(){
./build.sh --parallel --config $1 --skip_tests --build_shared_lib \
--cmake_extra_defines CMAKE_INSTALL_PREFIX=./install
#--disable_contrib_ops --disable_ml_ops --disable_rtti
}

# Release
function buildRelease(){
cmakeParams "Release"
}

# Debug
function buildDebug(){
cmakeParams "Debug"
}

function buildALL(){
buildRelease
buildDebug
}

echo "请选择编译选项并回车: 1)Release，2)Debug"
echo "Please Select Build Type: 1)Release，2)Debug"
read -t 30 -p "" BUILD_TYPE
if [ $BUILD_TYPE == 0 ]; then
    buildALL
elif [ $BUILD_TYPE == 1 ]; then
    buildRelease
elif [ $BUILD_TYPE == 2 ]; then
    buildDebug
else
  echo -e "输入错误！Input Error!"
fi