:: build opencv 3.4.11 for windows static (.lib) by benjaminwan

@ECHO OFF
mkdir build-win-vs2017-x86
pushd build-win-vs2017-x86
call :cmakeParams "Visual Studio 15 2017" "Win32"
popd

mkdir build-win-vs2017-x64
pushd build-win-vs2017-x64
call :cmakeParams "Visual Studio 15 2017" "x64"
popd

mkdir build-win-vs2019-x86
pushd build-win-vs2019-x86
call :cmakeParams "Visual Studio 16 2019" "Win32"
popd

mkdir build-win-vs2019-x64
pushd build-win-vs2019-x64
call :cmakeParams "Visual Studio 16 2019" "x64"
popd

GOTO:EOF

:cmakeParams
cmake -G "%~1" -A "%~2" ^
  -DBUILD_CUDA_STUBS=OFF ^
  -DBUILD_DOCS=OFF ^
  -DBUILD_EXAMPLES=OFF ^
  -DBUILD_IPP_IW=OFF ^
  -DBUILD_ITT=OFF ^
  -DBUILD_JASPER=OFF ^
  -DBUILD_JAVA=OFF ^
  -DBUILD_JPEG=OFF ^
  -DBUILD_LIST=OFF ^
  -DBUILD_OPENEXR=OFF ^
  -DBUILD_PACKAGE=OFF ^
  -DBUILD_PERF_TESTS=OFF ^
  -DBUILD_PNG=OFF ^
  -DBUILD_PROTOBUF=OFF ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DBUILD_TBB=OFF ^
  -DBUILD_TESTS=OFF ^
  -DBUILD_TIFF=OFF ^
  -DBUILD_USE_SYMLINKS=OFF ^
  -DBUILD_WEBP=OFF ^
  -DBUILD_WITH_DEBUG_INFO=OFF ^
  -DBUILD_WITH_STATIC_CRT=OFF ^
  -DBUILD_WITH_DYNAMIC_IPP=OFF ^
  -DBUILD_ZLIB=OFF ^
  -DBUILD_opencv_apps=OFF ^
  -DBUILD_opencv_calib3d=OFF ^
  -DBUILD_opencv_core=ON ^
  -DBUILD_opencv_dnn=OFF ^
  -DBUILD_opencv_features2d=OFF ^
  -DBUILD_opencv_flann=OFF ^
  -DBUILD_opencv_highgui=ON ^
  -DBUILD_opencv_imgcodecs=ON ^
  -DBUILD_opencv_imgproc=ON ^
  -DBUILD_opencv_java_bindings_generator=OFF ^
  -DBUILD_opencv_js=OFF ^
  -DBUILD_opencv_ml=OFF ^
  -DBUILD_opencv_objdetect=OFF ^
  -DBUILD_opencv_photo=OFF ^
  -DBUILD_opencv_python2=OFF ^
  -DBUILD_opencv_python_bindings_generator=OFF ^
  -DBUILD_opencv_python_tests=OFF ^
  -DBUILD_opencv_shape=OFF ^
  -DBUILD_opencv_stitching=OFF ^
  -DBUILD_opencv_superres=OFF ^
  -DBUILD_opencv_ts=OFF ^
  -DBUILD_opencv_video=OFF ^
  -DBUILD_opencv_videoio=OFF ^
  -DBUILD_opencv_videostab=OFF ^
  -DBUILD_opencv_world=ON ^
  -DWITH_1394=OFF ^
  -DWITH_ARITH_DEC=OFF ^
  -DWITH_ARITH_ENC=OFF ^
  -DWITH_AVFOUNDATION=OFF ^
  -DWITH_EIGEN=OFF ^
  -DWITH_FFMPEG=OFF ^
  -DWITH_GSTREAMER=OFF ^
  -DWITH_IMGCODEC_HDR=OFF ^
  -DWITH_IMGCODEC_PXM=OFF ^
  -DWITH_IMGCODEC_SUNRASTER=OFF ^
  -DWITH_IPP=OFF ^
  -DWITH_ITT=OFF ^
  -DWITH_JASPER=OFF ^
  -DWITH_JPEG=OFF ^
  -DWITH_LAPACK=OFF ^
  -DWITH_OPENEXR=OFF ^
  -DWITH_PNG=OFF ^
  -DWITH_PROTOBUF=OFF ^
  -DWITH_PTHREADS_PF=OFF ^
  -DWITH_QUIRC=OFF ^
  -DWITH_TIFF=OFF ^
  -DWITH_VTK=OFF ^
  -DWITH_WEBP=OFF ^
  ..
GOTO:EOF