:: build opencv 3.4.x for windows by benjaminwan
@ECHO OFF
chcp 65001
cls
@SETLOCAL

echo 请选择生成库选项并回车: 1)Shared动态库，2)Static静态库:
echo Please Select Lib Type: 1)Shared Lib，2)Static Lib:
set BUILD_SHARED=ON
set /p flag=
if %flag% == "" (set BUILD_SHARED=ON)^
else if %flag% == 1 (set BUILD_SHARED=ON)^
else if %flag% == 2 (set BUILD_SHARED=OFF)^
else (echo "输入错误！Input Error!")

echo 请选择要生成的选项并回车: 0)ALL，1)Release，2)Debug:
echo Please Select Build Type: 0)ALL，1)Release，2)Debug:
set /p flag=
if %flag% == 0 (call :buildALL)^
else if %flag% == 1 (call :buildRelease)^
else if %flag% == 2 (call :buildDebug)^
else (echo "输入错误！Input Error!")
GOTO:EOF

:buildALL
call :buildRelease
call :buildDebug
GOTO:EOF

:buildRelease
mkdir build-win-Release
pushd build-win-Release
call :cmakeParams "Release"
nmake
nmake install
popd
GOTO:EOF

:buildDebug
mkdir build-win-Debug
pushd build-win-Debug
call :cmakeParams "Debug"
nmake
nmake install
popd
GOTO:EOF

:cmakeParams
cmake -G "NMake Makefiles" ^
  -DCMAKE_BUILD_TYPE="%~1" -DCMAKE_CONFIGURATION_TYPES="%~1" ^
  -DBUILD_DOCS=OFF ^
  -DBUILD_EXAMPLES=OFF ^
  -DBUILD_PERF_TESTS=OFF ^
  -DBUILD_PROTOBUF=OFF ^
  -DBUILD_SHARED_LIBS=%BUILD_SHARED% ^
  -DBUILD_TESTS=OFF ^
  -DBUILD_WITH_DEBUG_INFO=OFF ^
  -DBUILD_WITH_STATIC_CRT=OFF ^
  -DBUILD_IPP_IW=ON ^
  -DBUILD_ITT=ON ^
  -DBUILD_JASPER=ON ^
  -DBUILD_JPEG=ON ^
  -DBUILD_PNG=ON ^
  -DBUILD_TBB=ON ^
  -DBUILD_TIFF=ON ^
  -DBUILD_WEBP=ON ^
  -DBUILD_ZLIB=ON ^
  -DWITH_EIGEN=OFF ^
  -DWITH_FFMPEG=OFF ^
  -DBUILD_opencv_dnn=OFF ^
  -DBUILD_opencv_world=ON ^
  ..
GOTO:EOF