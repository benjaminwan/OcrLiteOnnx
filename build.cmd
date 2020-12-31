@ECHO OFF
chcp 65001
cls
@SETLOCAL
echo "========第一步：请准备好编译环境========"
echo "编译环境：VS2017或VS2019，安装时，至少选中'使用C++的桌面开发'"
echo "开始菜单打开'x64 Native Tools Command Prompt for VS 2019'或'适用于 VS2017 的 x64 本机工具'，并转到OcrLiteOnnx根目录"
echo "运行'build.cmd'"
echo.

echo "========第二步：准备opencv和onnxruntime========"
echo "可以选择从源码自行编译，scripts文件夹内有参考编译脚本。或者从以下地址下载编译好的。"
echo "https://gitee.com/benjaminwan/ocr-lite-onnx/releases/v1.0"
echo "OpenCv动态库：opencv-(版本号)-sharedLib.7z"
echo "OpenCv静态库：opencv-(版本号)-staticLib.7z"
echo "OnnxRuntime动态库：onnxruntime-(版本号)-sharedLib.7z"
echo "OnnxRuntime静态库：onnxruntime-(版本号)-staticLib.7z"
echo "可以选择只下载两者的动态库或两者的静态库(要么都是静态库要么都是动态库)，或者4种全部下载"
echo "把压缩包解压到项目根目录"
echo OcrLiteOnnx
echo ├── onnxruntime-shared
echo ├── onnxruntime-static
echo ├── opencv-shared
echo ├── opencv-static
echo.

echo "========第三步：选择编译选项========"
echo "请注意：项目默认使用Release库，除非您自行编译Debug版的Onnxruntime和Opencv，否则请不要选择Debug编译"
echo "请输入编译选项并回车: 1)Release, 2)Debug:""
set BUILD_TYPE=Release
set /p flag=
if %flag% == 1 (set BUILD_TYPE=Release)^
else if %flag% == 2 (set BUILD_TYPE=Debug)^
else (echo 输入错误！Input Error!)
echo.

echo "请输入OpenMP选项并回车: 1)启用OpenMP(Angle阶段和Crnn阶段多线程并行执行), 2)禁用OpenMP(Angle阶段和Crnn阶段单线程执行)"
set BUILD_OPENMP=ON
set /p flag=
if %flag% == 1 (set BUILD_OPENMP=ON)^
else if %flag% == 2 (set BUILD_OPENMP=OFF)^
else (echo 输入错误！Input Error!)
echo.

echo "使用静态库时，编译出来的可执行文件较大，但部署起来比较方便。"
echo "使用动态库时，编译出来的可执行文件较小，但部署的时候记得把dll复制到可执行文件目录"
echo "请选择要使用的OnnxRuntime和Opencv库选项并回车: 1)Static静态库，2)Shared动态库"
set BUILD_STATIC=ON
set /p flag=
if %flag% == 1 (set BUILD_STATIC=ON)^
else if %flag% == 2 (set BUILD_STATIC=OFF)^
else (echo "输入错误！Input Error!")
echo.

echo "请注意：如果选择2)编译为JNI动态库时，必须安装配置Oracle JDK"
echo "请选择编译输出类型并回车: 1)编译成可执行文件，2)编译成JNI动态库"
set BUILD_LIB=OFF
set /p flag=
if %flag% == 1 (set BUILD_LIB=OFF)^
else if %flag% == 2 (set BUILD_LIB=ON)^
else (echo 输入错误！Input Error!)
echo.
if %BUILD_LIB% == OFF (call :makeExe)^
else (call :makeLib)
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DOCR_LITE_OPENMP=%BUILD_OPENMP% -DOCR_LITE_LIB=%BUILD_LIB% -DOCR_LITE_STATIC=%BUILD_STATIC% ..
nmake
popd
GOTO:EOF

:makeExe
mkdir build
pushd build
GOTO:EOF

:makeLib
mkdir build-lib
pushd build-lib
GOTO:EOF

@ENDLOCAL
