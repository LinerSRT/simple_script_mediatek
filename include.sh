#!/bin/bash
export curdate=`date "+_%Y:%M"`
red=$(tput setaf 1)
grn=$(tput setaf 2)
cya=$(tput setaf 6)
txtbld=$(tput bold)
bldred=${txtbld}$(tput setaf 1)
bldgrn=${txtbld}$(tput setaf 2) 
bldblu=${txtbld}$(tput setaf 4) 
bldcya=${txtbld}$(tput setaf 6) 
txtrst=$(tput sgr0)

ARCH="arm"
PJ_NAME="pixi4_4_8g1g"
DATA_FOLDER="/home/$USER/data"
CROSS_COMPILE="/home/$USER/arm-eabi-4.8/bin/arm-eabi-"
SOOURCE_PATH="/home/$USER/5010"
THREADS="3"
IMG_NAME="tcl5022d_3_18"
PATH_CARLIV="/home/$USER/CarlivImageKitchen64"
OUT_FOLDER_IMG="/home/$USER/out"

source main_logic.sh
