#!/bin/bash
dysp_size_warn(){
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
echo -e "${txtbld}* Size of ${bldcya}$OUT_FOLDER_IMG${txtrst} ${bldred}reached maximum size${txtrst} ${bldgrn}500M${txtrst}${txtbld}, cleaning. ${txtrst}"
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
}

dysp_start_build(){
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
echo -e "${txtbld}* Start building${txtrst}${txtbld}${bldgrn} $VER.$PATCH.$SUB ${txtrst}${txtbld}kernel for${txtrst}${txtbld}${bldgrn} MT$CPU ${txtrst}${txtbld}, please wait and be patient!"
echo -e "${txtbld}* LCM used: ${txtrst}${bldgrn}$LCM ${txtbld} ${txtrst}"
echo -e "${txtbld}* Screen size: ${txtrst}${bldgrn}$LCM_H${txtrst}${txtbld} x ${txtrst}${bldgrn}$LCM_W${txtrst} ${txtbld} ${txtrst}"
echo -e "${txtbld}* Touchscreen used: ${txtrst}${bldgrn}$TOUCH ${txtbld} ${txtrst}"
echo -e "${txtbld}* Imgsensors used: ${txtrst}${bldgrn}$SENSORS ${txtbld} ${txtrst}"
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
}

dysp_fisnish(){
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
echo -e "${txtbld}* Firmware ${bldcya}$OUT_FOLDER_IMG/"$IMG_NAME"_test$NUMBER.img${txtrst} ${txtbld} compiled and packed${txtrst}"
echo -e "${txtbld}* Compilation end with ${bldgrn}$(($DIFF / 60)):$(($DIFF % 60)) (mm:ss)${txtrst}"
echo -e "${txtbld}* Total size output folder: ${bldcya}$OUT_FOLDER_IMG${txtrst} ${txtbld}is${txtrst} ${bldgrn}$SIZE_OUT ${txtrst}"
echo -e "${txtbld}* Last compilation maded in: ${txtrst}${bldgrn} $LAST_BUILD ${txtrst}"
echo -e "${txtbld}* Total error's count: ${txtrst}${bldred} #$ERR_COUNT ${txtrst}"
echo -e "${txtbld}* Total compilation's count: ${txtrst}${txtbld}${bldgrn} #$NUMBER ${txtrst}${txtbld}"
echo -e "${txtbld}* Platform: ${txtrst}${txtbld}${bldgrn} MT$CPU ${txtrst}${txtbld}"
echo -e "${txtbld}* Target kernel version is: ${txtrst}${txtbld}${bldgrn} $VER.$PATCH.$SUB ${txtrst}${txtbld}"
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
}

dysp_error(){
echo -e "${txtbld}${bldred}*********************************************************************************************************************${txtrst}"
echo -e "${txtbld}${bldred}*${txtrst}${txtbld} Warning! Compilation finished with ${bldred}ERROR! ${txtrst}"
echo -e "${txtbld}${bldred}*${txtrst}${txtbld} Error in file ${bldcya} $FILENAME ${txtrst}${bldred} on${bldgrn} $LINE ${bldred}line ${txtrst}"
echo -e "${txtbld}${bldred}*********************************************************************************************************************${txtrst}"
}

dysp_unpack_img(){
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
echo -e "${txtbld}* Your image ${bldcya}$IMG_NAME${txtrst}${txtbld} is unpacking to working directory! ${txtrst}"
echo -e "${txtbld}******************************************************************************************************************************${txtrst}"
}

read_data(){
read LAST_BUILD < <(cat $DATA_FOLDER/last_build.txt)
read ERR_COUNT < <(cat $DATA_FOLDER/error_count.txt)
read NUMBER < <(cat $DATA_FOLDER/build_num.txt)
read BUILD_DATE< <(date "+%Y/%m/%d/ %H:%M")
read SIZE_OUT < <(du -h $OUT_FOLDER_IMG | grep -o "[0-9]*[M,G,T,K]")
cd $SOOURCE_PATH
VER=$(grep -o "VERSION = [0-9]" Makefile | grep -o "[0-9]")
PATCH=$(grep -o "PATCHLEVEL = [0-9]*" Makefile | grep -o "[0-9]*")
SUB=$(grep -o "SUBLEVEL = [0-9]*" Makefile | grep -o "[0-9]*")
read CPU < <(grep -o "MT[0-9]*" arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep -o "[0-9]*")
read LCM < <(cat arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep CUSTOM_KERNEL_LCM | grep -o "\"[a-z,0-9,_ ]*\"" | grep -o "[a-Z,0-9, ,_]*")
read LCM_H < <(cat arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep CONFIG_LCM_HEIGHT=\"[0-9]*\" | grep -o "[0-9]*")
read LCM_W < <(cat arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep CONFIG_LCM_WIDTH=\"[0-9]*\" | grep -o "[0-9]*")
read TOUCH < <(cat arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep "CONFIG_TOUCHSCREEN_MTK_[A-Z,0-9]*=y"| grep -o "_[A-Z,0-9]*=y" | grep -o "[A-Z]*")
read SENSORS < <(cat arch/$ARCH/configs/"$PJ_NAME"_defconfig | grep "CONFIG_CUSTOM_KERNEL_IMGSENSOR" | grep "\"[a-z,_,\ ,0-9]*" | grep -o "\"[a-z,\ ,_,0-9]*" | grep -o "[a-z,\ ,_,0-9]*")

cd
read SIZE_OUT < <(du -h $OUT_FOLDER_IMG | grep -o "[0-9]*[M,G,T,K]" )
read CHECK_SIZE < <(echo $SIZE_OUT | grep  -o "[0-9]*")
if (("$CHECK_SIZE" >= "500")); then
dysp_size_warn #Display warning massage
cd $OUT_FOLDER_IMG
rm -rf *.img
cp $PATH_CARLIV/output/"$IMG_NAME"_repacked.img $OUT_FOLDER_IMG/$"$IMG_NAME"_test$NUMBER.img
fi
}

read_log(){
read FILENAME < <(cat $DATA_FOLDER/log.build | grep -o "[/,a-z,_, 0-9]*.[c,h]:[0-9]*:[0-9]*: error" | grep -o "[/,a-z,_, 0-9]*.[c,h]")
read LINE < <(cat $DATA_FOLDER/log.build | grep -o "[0-9,:]*: error" | grep -o "[0-9]*")
}

unpack_img(){
cd $PATH_CARLIV
cp .scripts/unpack_img $PATH_CARLIV
./unpack_img [a-z,_,0-9]*.img $IMG_NAME
cd
}
