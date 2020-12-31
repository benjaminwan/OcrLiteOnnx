#!/usr/bin/env bash
echo "========第一步：请准备好编译环境========"
echo "Linux编译工具链：sudo apt-get install build-essential cmake"
echo "Linux编译工具版本：1)g++>=5, 2)cmake>=3.1, 3)jdk8(可选)"
echo "macOS编译工具链：1)XCode, 2)brew install libomp"
echo "macOs编译工具版本：1)XCode>=12, 2)cmake>=3.1, 3)jdk8(可选)"
echo
echo "========第二步：下载opencv和onnxruntime========"
echo "可以选择从源码自行编译，scripts文件夹内有参考编译脚本。或者从以下地址下载编译好的。"
echo "https://gitee.com/benjaminwan/ocr-lite-onnx/releases/v1.0"
echo "OpenCv动态库：opencv-(版本号)-sharedLib.7z"
echo "OpenCv静态库：opencv-(版本号)-staticLib.7z"
echo "OnnxRuntime动态库：onnxruntime-(版本号)-sharedLib.7z"
echo "OnnxRuntime静态库：onnxruntime-(版本号)-staticLib.7z"
echo "可以选择只下载两者的动态库或两者的静态库(要么都是静态库要么都是动态库)，或者4种全部下载"
echo "把压缩包解压到项目根目录"
echo "OcrLiteOnnx"
echo "├── onnxruntime-shared"
echo "├── onnxruntime-static"
echo "├── opencv-shared"
echo "├── opencv-static"
echo
echo "========第三步：选择编译选项========"
echo "请选择编译选项并回车: 1)Release，2)Debug"
read -p "" BUILD_TYPE
if [ $BUILD_TYPE == 1 ]; then
    BUILD_TYPE=Release
elif [ $BUILD_TYPE == 2 ]; then
    BUILD_TYPE=Debug
else
  echo -e "输入错误！Input Error!"
fi

echo "请输入OpenMP选项并回车: 1)启用OpenMP(Angle阶段和Crnn阶段多线程并行执行), 2)禁用OpenMP(Angle阶段和Crnn阶段单线程执行)"
read -p "" OPENMP_TYPE
if [ $OPENMP_TYPE == 1 ]; then
    OPENMP_TYPE=ON
elif [ $OPENMP_TYPE == 2 ]; then
    OPENMP_TYPE=OFF
else
  echo -e "输入错误！Input Error!"
fi

echo "使用静态库时，编译出来的可执行文件较大，但部署起来比较方便。"
echo "使用动态库时，编译出来的可执行文件较小，但Linux部署时要配置LD_LIBRARY_PATH或复制到/usr/lib。"
echo "请选择要使用的OnnxRuntime和Opencv库选项并回车: 1)Static静态库，2)Shared动态库"
read -p "" BUILD_STATIC
if [ $BUILD_STATIC == 1 ]; then
    BUILD_STATIC=ON
elif [ $BUILD_STATIC == 2 ]; then
    BUILD_STATIC=OFF
else
  echo -e "输入错误！Input Error!"
fi

echo "请注意：如果选择2)编译为JNI动态库时，必须安装配置Oracle JDK"
echo "请选择编译输出类型并回车: 1)编译成可执行文件，2)编译成JNI动态库"
read -p "" OUTPUT_LIB
if [ $OUTPUT_LIB == 1 ]; then
    OUTPUT_LIB=OFF
elif [ $OUTPUT_LIB == 2 ]; then
    OUTPUT_LIB=ON
else
  echo -e "输入错误！Input Error!"
fi

if [ $OUTPUT_LIB == OFF ]; then
    mkdir -p build
    pushd build
else
    mkdir -p build-lib
    pushd build-lib
fi

sysOS=`uname -s`
NUM_THREADS=1
if [ $sysOS == "Darwin" ];then
    #echo "I'm MacOS"
    NUM_THREADS=$(sysctl -n hw.ncpu)
elif [ $sysOS == "Linux" ];then
    #echo "I'm Linux"
    NUM_THREADS=$(grep ^processor /proc/cpuinfo | wc -l)
else
    echo "Other OS: $sysOS"
fi

echo "cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DOCR_LITE_OPENMP=${OPENMP_TYPE} -DOCR_LITE_LIB=${OUTPUT_LIB} -DOCR_LITE_STATIC=${BUILD_STATIC} .."
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DOCR_LITE_OPENMP=$OPENMP_TYPE -DOCR_LITE_LIB=$OUTPUT_LIB -DOCR_LITE_STATIC=$BUILD_STATIC ..
make -j $NUM_THREADS
popd