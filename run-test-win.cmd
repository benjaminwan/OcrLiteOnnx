chcp 65001
:: Set Param
@ECHO OFF
@SETLOCAL
echo "Setting the Number of Threads=%NUMBER_OF_PROCESSORS% Using an OpenMP Environment Variable"
set OMP_NUM_THREADS=%NUMBER_OF_PROCESSORS%

:: run Win x64
copy onnx\windows\onnxruntime.dll build-win /Y
copy opencv\build\x64\vc14\bin\opencv_world3411.dll build-win /Y
pushd build-win
OcrLiteOnnx.exe ../test_imgs/1.jpg ../models %NUMBER_OF_PROCESSORS% 50 0 0.6 0.3 3 1.0 1.0 1.6 1.6
popd
PAUSE
@ENDLOCAL
