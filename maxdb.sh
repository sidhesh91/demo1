#!/bin/sh
#########################################################################################
#Scriptname: daily_backup.sh                                                            #
#version: 1.0                                                                           #
#Author: Sidhesh Kumar                                                                  #
#########################################################################################
CWD=$(pwd)
export DATE=$(date '+%d%m%Y%H%M%S')
echo "DATE is in dd-mm-yy format"
################################# PROPERTY SECTION #######################################
export LOG_DIR="$CWD/LOGS"
[ -d $LOG_DIR ] && echo "LOG Directory==> Exists" || mkdir -p $LOG_DIR
export BKP_LOG_FILE="$LOG_DIR/${DATE}_complete.log"
[ -f $BKP_LOG_FILE ] && echo "FILE ==> Exists" || touch $BKP_LOG_FILE
#configure backup medium
export BKP_MED=COM_DATA_TUE                                                  
export BKP_MED_FINAL=SDB_COM_TUE
#configure DB,username , password
export BKP_CMND="dbmcli -d  <SID> -u <user>,<password> -uUTL -c backup_start $BKP_MED"  
export BKP_CMND_DIR="/sapdb/SDB/db/bin"
export BKP_TARGET_DIR="/backup/localbackup/DATA"
export bkp=0
#configure your s3 bucket address
export S3_BUCKET_ADD="s3://bucket/address"                                     
################################## PROPERTY SECTION ENDS #################################
export red=`tput setaf 1`
export green=`tput setaf 2`
export nc=`tput sgr0`
export PL=10                                  
#function to delete old backup###########################################
        function DEL_prevbkp {
         [ -d $BKP_TARGET_DIR/$DATE ] && echo " ${green}OLD backup Directory exists,Deleting old backup...... ${nc}" || bkp=1
           if [ $bkp -eq 1 ]
             then
             CR_backup 1
           else
             echo "${red}Initiating old backup compression operation.....................${nc}"
             CR_backup 0
           fi
                }
#function to create new backup###########################################
        function CR_backup {
              if [ $1 -eq 1 ]
                 then
                  OLD_BKP=$(ls $BKP_TARGET_DIR)
                  echo "${green}Initiating  new backup...............${nc}"
                  echo "${green} Creating new backup directory...........................${green}"
                  mkdir -p $BKP_TARGET_DIR/$DATE
                  $BKP_CMND_DIR/$BKP_CMND > $BKP_LOG_FILE
                  echo " ${green} moving backup to new directory .........................${nc}"
                  mv $BKP_TARGET_DIR/$BKP_MED_FINAL $BKP_TARGET_DIR/$DATE
                  echo "${green} archiving and uploading  backup .........................................${nc}"
                       echo "${green} Uploading archive ==>$BKP_TARGET_DIR/$DATE to S3 ==>$S3_BUCKET_ADD ${nc}"
                       tar cvfz - $BKP_TARGET_DIR/$DATE| pigz -9 -p 32|aws s3 cp - $S3_BUCKET_ADD/${DATE}.tar.gz
                      if [ $? -eq 0 ]
                         then
                          echo " ${green} backup ===> ${DATE} successfuly  uploaded to $S3_BUCKET_ADD/${DATE} ${nc}"
                          FILE_CNT=$(ls $BKP_TARGET_DIR|wc -l)
                         if [ $FILE_CNT -gt 1 ]
                            then
                            echo "${red}Old backup found ====> ${OLD_BKP} ${nc}"
                            echo "${red} Deleting old backup====>${OLD_BKP}..................................${nc}"
                            cd ${BKP_TARGET_DIR}
                            find . -type d -not -name $DATE -print0|xargs -0 -I {} rm -rf {} 2>/dev/null
                            cd $CWD
                            echo "${green} Check log==> $BKP_LOG_FILE ${nc}"
                         else
                            echo "${green} Old backup not found ..............................${nc}"
                            echo "${green} Check log==> $BKP_LOG_FILE ${nc}"
                         fi
                       else
                        echo "${red}  ERROR: S3 upload failed, please check and retry ${nc}"
                     fi
              else
                echo "${green} Creating new backup...........${nc}"
                $BKP_CMND_DIR/$BKP_CMND > $BKP_LOG_FILE
                mv $BKP_TARGET_DIR/$BKP_MED_FINAL $BKP_TARGET_DIR/$DATE
              fi
       }
 
echo "${green} Checking available space before initiating backup operation.........${nc}"
UL=$(df -kh $BKP_TARGET_DIR | tail -1 | awk '{print $4}' | tr "G" " ")
echo "Available space ===> ${UL}G"
if [ $UL -gt $PL ]
   then
DEL_prevbkp
echo " ${red} Deleting old logs...........................${nc}"
cd $LOG_DIR
rm -f `ls -1t | tail -n +11`
cd $CWD
else
 echo " ${red} ERROR :There is no sufficient space avaialbe for backup , clear some space and rerun the script ${nc}"
exit 1
