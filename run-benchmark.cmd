chcp 65001
:: Set Param
@ECHO OFF
@SETLOCAL
echo "Setting the Number of Threads=%NUMBER_OF_PROCESSORS% Using an OpenMP Environment Variable"
set OMP_NUM_THREADS=%NUMBER_OF_PROCESSORS%

:: run Win x64
:: echo "请把对应的onnxruntime.dll和opencv_world3411.dll复制到build目录"
:: copy onnx\windows\onnxruntime.dll build-win /Y
:: copy opencv\build\x64\vc14\bin\opencv_world3411.dll build-win /Y
pushd build
benchmark.exe --models ../models --image ../../test_imgs/1.jpg ^
                --numThread $NUM_THREADS --loopCount 10
popd
PAUSE
@ENDLOCAL