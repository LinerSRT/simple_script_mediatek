#!/bin/bash

source include.sh
read_data
dysp_start_build
echo $BUILD_DATE > $DATA_FOLDER/last_build.txt
cd $SOOURCE_PATH > /dev/null 2>&1
export ARCH=$ARCH > /dev/null 2>&1
export CROSS_COMPILE=$CROSS_COMPILE > /dev/null 2>&1
BUILD_START=$(date +"%s")
make "$PJ_NAME"_defconfig O=out1 > /dev/null 2>&1
make -j$THREADS O=out1 &> $DATA_FOLDER/log.build
if [ $? -eq 0 ]; then
mv $PWD/out1/arch/$ARCH/boot/zImage-dtb $PATH_CARLIV/tcl5022d_3_18/$IMG_NAME.img-kernel
cd $PATH_CARLIV
./repack_img $IMG_NAME > /dev/null 2>&1
cp output/"$IMG_NAME"_repacked.img $OUT_FOLDER_IMG/"$IMG_NAME"_test$NUMBER.img
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
let "NEW = $NUMBER + 1"
echo $NEW > $DATA_FOLDER/build_num.txt
cd ..
dysp_fisnish
else
read_log
dysp_error
read ERR_COUNT < <(cat $DATA_FOLDER/error_count.txt)
let "ERR_COUNT_NUM = $ERR_COUNT + 1"
echo $ERR_COUNT_NUM > $DATA_FOLDER/error_count.txt
gedit +$LINE $SOOURCE_PATH$FILENAME
fi
