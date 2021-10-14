chcp 65001
:: Set Param
@ECHO OFF
@SETLOCAL
echo "Setting the Number of Threads=%NUMBER_OF_PROCESSORS% Using an OpenMP Environment Variable"
set OMP_NUM_THREADS=%NUMBER_OF_PROCESSORS%

:MainExec
echo "请输入测试选项并回车: 1)CPU-x64, 2)CPU-x86"
set /p flag=
if %flag% == 1 (call :PrepareCpuX64)^
else if %flag% == 2 (call :PrepareCpuX86)^
else (echo 输入错误！Input Error!)

echo "请输入循环次数:"
set /p LOOP_COUNT=

SET TARGET_IMG=images/1.jpg
if not exist %TARGET_IMG% (
echo "找不到待识别的目标图片：%TARGET_IMG%，请打开本文件并编辑TARGET_IMG"
PAUSE
exit
)

if exist %EXE_PATH%\install\bin (
SET EXE_PATH=%EXE_PATH%\install\bin
)

%EXE_PATH%\benchmark.exe --version
%EXE_PATH%\benchmark.exe --models models ^
--det dbnet.onnx ^
--cls angle_net.onnx ^
--rec crnn_lite_lstm.onnx ^
--keys keys.txt ^
--image %TARGET_IMG% ^
--numThread %NUMBER_OF_PROCESSORS% ^
--padding 50 ^
--maxSideLen 1024 ^
--boxScoreThresh 0.6 ^
--boxThresh 0.3 ^
--unClipRatio 2.0 ^
--doAngle 1 ^
--mostAngle 1 ^
--loopCount %LOOP_COUNT%

popd
echo.
GOTO:MainExec

:PrepareCpuX64
set EXE_PATH=win-BIN-x64
set GPU_INDEX=-1
GOTO:EOF

:PrepareCpuX86
set EXE_PATH=win-BIN-Win32
set GPU_INDEX=-1
GOTO:EOF

@ENDLOCAL
