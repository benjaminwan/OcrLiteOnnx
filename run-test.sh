#!/usr/bin/env bash

#### Setting the Number of Threads Using an OpenMP* Environment Variable
set OMP_NUM_THREADS=4

##### run test on MacOS or Linux
pushd build
./OcrLiteOnnx ../test_imgs/1.jpg ../models 4 50 0 0.6 0.3 3 1.3 1.3 1.6 1.6
popd