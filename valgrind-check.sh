#!/bin/bash
## script for 内存泄露检查
# ========== macOS ==========
# https://github.com/LouisBrunner/valgrind-macos
# brew tap LouisBrunner/valgrind
# brew install --HEAD LouisBrunner/valgrind/valgrind
# ========== linux ==========
# https://www.valgrind.org/
# apt install valgrind

NUM_THREADS=2

set OMP_NUM_THREADS=$NUM_THREADS

##### run test on MacOS or Linux
pushd build
valgrind --leak-check=full --show-leak-kinds=all --log-file=valgrind-report.txt \
./OcrLiteOnnx --models ../models --image ../../test_imgs/1.jpg \
--numThread $NUM_THREADS --padding 50 --imgResize 0 \
--boxScoreThresh 0.6 --boxThresh 0.3 --minArea 3 \
--unClipRatio 2.0 --doAngle 1 --mostAngle 1
popd
