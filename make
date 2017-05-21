#!/bin/bash
#Colorize text optput#
red=$(tput setaf 1)
grn=$(tput setaf 2)
cya=$(tput setaf 6)
txtbld=$(tput bold)
bldred=${txtbld}$(tput setaf 1)
bldgrn=${txtbld}$(tput setaf 2) 
bldblu=${txtbld}$(tput setaf 4) 
bldcya=${txtbld}$(tput setaf 6) 
txtrst=$(tput sgr0)
######################
#Export Varriables####
ARCH="arm"
PJ_NAME="len6580_we_m"
OUT_FOLDER="/home/$USER/out1"
CROSS_COMPILE="/home/$USER/arm-eabi-4.8/bin/arm-eabi-"
SOOURCE_PATH="/home/$USER/android_kernel3.18_alcatel_5022d/kernel-3.18"
THREADS="3"
IMG_NAME="tcl5022d_3_18"
PATH_CARLIV="/home/$USER/CarlivImageKitchen64"
######################
#Read data############
export curdate=`date "+_%Y:%M"`
read LAST_BUILD < <(cat $OUT_FOLDER/last_build.txt)
read ERR_COUNT < <(cat $OUT_FOLDER/error_count.txt)
read NUMBER < <(cat $OUT_FOLDER/build_num.txt)
read BUILD_DATE< <(date "+%Y/%m/%d/ %H:%M")
read SIZE_OUT < <(du -h $OUT_FOLDER | grep -o "[0-9]*[M,G,T,K]")
cd $SOOURCE_PATH
VER=$(grep -o "VERSION = [0-9]" Makefile | grep -o "[0-9]")
PATCH=$(grep -o "PATCHLEVEL = [0-9]*" Makefile | grep -o "[0-9]*")
SUB=$(grep -o "SUBLEVEL = [0-9]*" Makefile | grep -o "[0-9]*")
read CPU < <(grep -o "MT[0-9]*" arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep -o "[0-9]*")
cd
read SIZE_OUT < <(du -h $OUT_FOLDER | grep -o "[0-9]*[M,G,T,K]")
read CHECK_SIZE < <(echo $SIZE_OUT | grep  -o "[0-9]*")
if (("$CHECK_SIZE" >= "500")); then
echo -e "${txtbld}**********************************************************************************************${txtrst}"
echo -e "${txtbld}* Size of ${bldcya}$OUT_FOLDER${txtrst} ${bldred}reached maximum size${txtrst} ${bldgrn}500M${txtrst}${txtbld}, cleaning. ${txtrst}"
echo -e "${txtbld}**********************************************************************************************${txtrst}"
cd $OUT_FOLDER
rm -rf *.img
mv $PATH_CARLIV/output/"$IMG_NAME"_repacked.img $OUT_FOLDER/$"$IMG_NAME"_test$NUMBER.img
fi
#####################
#Start building main#
echo -e "${txtbld}**********************************************************************************************${txtrst}"
echo -e "${txtbld}* Start building${txtrst}${txtbld}${bldgrn} $VER.$PATCH.$SUB ${txtrst}${txtbld}kernel for${txtrst}${txtbld}${bldgrn} MT$CPU ${txtrst}${txtbld}, please wait and be patient!"
echo -e "${txtbld}**********************************************************************************************${txtrst}"
echo $BUILD_DATE > $OUT_FOLDER/last_build.txt
cd $SOOURCE_PATH > /dev/null 2>&1
export ARCH=$ARCH > /dev/null 2>&1
export CROSS_COMPILE=$CROSS_COMPILE > /dev/null 2>&1
BUILD_START=$(date +"%s")
make "$PJ_NAME"_defconfig O=out1 > /dev/null 2>&1
make -j$THREADS O=out1 &> $OUT_FOLDER/log.build
if [ $? -eq 0 ]; then
mv $PWD/out1/arch/$ARCH/boot/zImage-dtb $PATH_CARLIV/tcl5022d_3_18/$IMG_NAME.img-kernel
cd $PATH_CARLIV
./repack_img $IMG_NAME > /dev/null 2>&1
mv output/"$IMG_NAME"_repacked.img $OUT_FOLDER/"$IMG_NAME"_test$NUMBER.img
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
let "NEW = $NUMBER + 1"
echo $NEW > $OUT_FOLDER/build_num.txt
cd ..
#Output when build is successful
echo -e "${txtbld}**********************************************************************************************${txtrst}"
echo -e "${txtbld}* Firmware ${bldcya}$OUT_FOLDER/"$IMG_NAME"_test$NUMBER.img${txtrst} ${txtbld} compiled and packed${txtrst}"
echo -e "${txtbld}* Compilation end with ${bldgrn}$(($DIFF / 60)):$(($DIFF % 60)) (mm:ss)${txtrst}"
echo -e "${txtbld}* Total size output folder: ${bldcya}$OUT_FOLDER${txtrst} ${txtbld}is${txtrst} ${bldgrn}$SIZE_OUT ${txtrst}"
echo -e "${txtbld}* Last compilation maded in: ${txtrst}${bldgrn} $LAST_BUILD ${txtrst}"
echo -e "${txtbld}* Total error's count: ${txtrst}${bldred} #$ERR_COUNT ${txtrst}"
echo -e "${txtbld}* Total compilation's count: ${txtrst}${txtbld}${bldgrn} #$NUMBER ${txtrst}${txtbld}"
echo -e "${txtbld}* Platform: ${txtrst}${txtbld}${bldgrn} MT$CPU ${txtrst}${txtbld}"
echo -e "${txtbld}* Target kernel version is: ${txtrst}${txtbld}${bldgrn} $VER.$PATCH.$SUB ${txtrst}${txtbld}"
echo -e "${txtbld}**********************************************************************************************${txtrst}"
else
#Output when build is finish with error, read line and search file with error. Then open it
read FILENAME < <(cat $OUT_FOLDER/log.build | grep -o "[/,a-z,_, 0-9]*.[c,h]:[0-9]*:[0-9]*: error" | grep -o "[/,a-z,_, 0-9]*.[c,h]")
read LINE < <(cat $OUT_FOLDER/log.build | grep -o "[0-9,:]*: error" | grep -o "[0-9]*")
echo -e "${txtbld}${bldred}**********************************************************************************************${txtrst}"
echo -e "${txtbld}${bldred}*${txtrst}${txtbld} Warning! Compilation finished with ${bldred}ERROR! ${txtrst}"
echo -e "${txtbld}${bldred}*${txtrst}${txtbld} Error in file ${bldcya} $FILENAME ${txtrst}${bldred} on${bldgrn} $LINE ${bldred}line ${txtrst}"
echo -e "${txtbld}${bldred}**********************************************************************************************${txtrst}"
read ERR_COUNT < <(cat $OUT_FOLDER/error_count.txt)
let "ERR_COUNT_NUM = $ERR_COUNT + 1"
echo $ERR_COUNT_NUM > $OUT_FOLDER/error_count.txt
gedit +$LINE /home/$USER/5010$FILENAME
fi
###################
