@ECHO OFF
chcp 65001
cls
@SETLOCAL

echo 请注意：项目默认使用Release库，请您打开项目后选择Release(除非您自行编译Debug版的Onnxruntime和Opencv)

echo 请输入OpenMP选项并回车: 1)启用OpenMP, 2)禁用OpenMP:
echo Please Select OpenMP Option: 1)Enable OpenMP, 2)Disable OpenMP:
set BUILD_OPENMP=ON
set /p flag=
if %flag% == 1 (set BUILD_OPENMP=ON)^
else if %flag% == 2 (set BUILD_OPENMP=OFF)^
else (echo "输入错误！Input Error!")

echo 请选择要使用的OnnxRuntime和Opencv库选项并回车: 1)Static静态库，2)Shared动态库:
echo Please Select OnnxRuntime And Opencv Lib Type: 1)Static，2)Shared:
set BUILD_STATIC=ON
set /p flag=
if %flag% == 1 (set BUILD_STATIC=ON)^
else if %flag% == 2 (set BUILD_STATIC=OFF)^
else (echo "输入错误！Input Error!")

echo 请选择编译输出类型并回车: 1)编译可执行文件，2)编译动态库:
echo Please Select Build Type: 1)Executable，2)Dynamic Library:
set BUILD_LIB=OFF
set /p flag=
if %flag% == 1 (set BUILD_LIB=OFF)^
else if %flag% == 2 (set BUILD_LIB=ON)^
else (echo "输入错误！Input Error!")

echo 请注意：如果要编译为JNI Lib，则必须与本机安装的JDK(x86/x64)对应
echo 请输入选项并回车: 0)ALL, 1)vs2017-x86, 2)vs2017-x64, 3)vs2019-x86, 4)vs2019-x64:
echo Please Input VS Version: 0)ALL, 1)vs2017-x86, 2)vs2017-x64, 3)vs2019-x86, 4)vs2019-x64:
set /p flag=
if %flag% == 0 (call :buildALL)^
else if %flag% == 1 (call :gen2017-x86)^
else if %flag% == 2 (call :gen2017-x64)^
else if %flag% == 3 (call :gen2019-x86)^
else if %flag% == 4 (call :gen2019-x64)^
else (echo "输入错误！Input Error!")
GOTO:EOF

:buildALL
call :gen2017-x86
call :gen2017-x64
call :gen2019-x86
call :gen2019-x64
GOTO:EOF

:gen2017-x86
mkdir build-win-vs2017-x86
pushd build-win-vs2017-x86
call :cmakeParams "Visual Studio 15 2017" "Win32"
popd
GOTO:EOF

:gen2017-x64
mkdir build-win-vs2017-x64
pushd build-win-vs2017-x64
call :cmakeParams "Visual Studio 15 2017" "x64"
popd
GOTO:EOF

:gen2019-x86
mkdir build-win-vs2019-x86
pushd build-win-vs2019-x86
call :cmakeParams "Visual Studio 16 2019" "Win32"
popd
GOTO:EOF

:gen2019-x64
mkdir build-win-vs2019-x64
pushd build-win-vs2019-x64
call :cmakeParams "Visual Studio 16 2019" "x64"
popd
GOTO:EOF

:cmakeParams
echo cmake -G "%~1" -A "%~2" -DOCR_LITE_OPENMP=%BUILD_OPENMP% -DOCR_LITE_LIB=%BUILD_LIB% -DOCR_LITE_STATIC=%BUILD_STATIC% ..
cmake -G "%~1" -A "%~2" -DOCR_LITE_OPENMP=%BUILD_OPENMP% -DOCR_LITE_LIB=%BUILD_LIB% -DOCR_LITE_STATIC=%BUILD_STATIC% ..
GOTO:EOF

@ENDLOCAL
