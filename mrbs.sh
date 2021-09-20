################################STARTS#############################################
curr_tmpstmp=$(date "+%s")
host=`hostname`

export red=`tput setaf 1`
export green=`tput setaf 2`
export nc=`tput sgr0`
cust_ban()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

cust_ban "Checking reservation on this system....."
sleep 3


# echo " ${green}Automation is checking reservation on this system.............${nc}"

for i in $(cat /usr/sap/gsatrain/extracts/sample.csv)
do
start_time=$(echo $i|awk -F "," '{print $2}')
end_time=$(echo $i|awk -F "," '{print $3}')
user_wiw=$(echo $i|awk -F "," '{print $9}' )
room_id=$(echo $i|awk -F "," '{print $6}' )
system_name=$(grep -w "$room_id" /usr/sap/gsatrain/properties/room.prop |cut -d "|" -f2)
  if (( ( $start_time < $curr_tmpstmp ) && ( $end_time > $curr_tmpstmp )  ))
   then

          if [ $host == $system_name ]
              then
                 if [ $USER == $user_wiw ]
                    then
                    cust_ban "*********WELCOME $USER *************"
                    #echo "${green} ====================welcome $USER==================================${nc}"
                    echo "${green} you have reservation on this system from $(date -d @$start_time) to $(date -d @$end_time) ${nc} "

                    exit 0
                 fi


                 if  [ $USER != $user_wiw ]
                    then
                        for j in $(cat /usr/sap/gsatrain/properties/suser.prop)
                        do
                           if [ $USER == $j ]
                            then
                            cust_ban "*WELCOME $USER{superuser}*"
                            exit 0
                           fi
                        done
                    else
                    cust_ban "***$USER NOT ALLOWED *************"

                   #echo " ${red}====================$USER is not ALLOWED==================================${nc}"
                 #  echo " above warning is for testing purpose you are allowed to work on this system"
                  sleep 5
                  # exit 0
                   pkill -9 -u $USER
                fi
          fi
           if [ $host != $system_name ]
             then
                for k in $(cat /usr/sap/gsatrain/properties/suser.prop)
                        do
                           if [ $USER == $k ]
                            then
                            cust_ban "*WELCOME $USER{superuser}*"
                            exit 0
                           fi
                        done

                cust_ban "***$USER NOT ALLOWED *************"
                echo " ${red}NO RESERVATION RECORDS FOUND FOR THIS USER ON THIS SYSTEM ${nc}"
                echo " ${red}**session closing in 10 seconds**********${nc}"
                 sleep 10
                 #echo " above warning is for testing purpose you are allowed to work on this system"
                pkill -9 -u $USER

           fi



# else
  #      #echo "${green}No reservation found  ====================welcome $USER==================================${nc}"
   #      cust_ban "*********WELCOME $USER *************"
      #  exit 0
  fi


if ((  $end_time < $curr_tmpstmp ))
then

for k in $(cat /usr/sap/gsatrain/properties/suser.prop)
                        do
                           if [ $USER == $k ]
                            then
                            cust_ban "*WELCOME $USER{superuser}*"
                            exit 0
                           fi
                        done

                cust_ban "***$USER NOT ALLOWED *************"
                echo " ${red}NO RESERVATION RECORDS FOUND FOR THIS USER ON THIS SYSTEM ${nc}"
                echo " ${red}**session closing in 10 seconds**********${nc}"
                sleep 10
                # echo " above warning is for testing purpose you are allowed to work on this system"
                 #exit 0
                pkill -9 -u $USER

fi

done
