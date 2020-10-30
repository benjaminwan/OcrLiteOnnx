:: Set Param
@ECHO OFF
@SETLOCAL

:: build Win x64
mkdir build-win-jni
copy onnx\windows\onnxruntime.dll build-win-jni /Y
copy opencv\build\x64\vc14\bin\opencv_world3411.dll build-win-jni /Y
pushd build-win-jni
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DOCR_LITE_JNI=ON ..
nmake
popd

@ENDLOCAL
