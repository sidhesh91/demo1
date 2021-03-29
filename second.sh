#################################################################################
#usage: cateogorize spec files based on cloud vendor and day2 activities
#Author: sidhesh kumar
#version: 1.0
##################################create workspace###############################

export CYP_INT="cypress/integration"
echo "Arguments passed======>$*"
export cloud_vendor=$(echo $1|awk -F"," '{print $1}')
export cloud_provider=$cloud_vendor
export day2=$2
echo $1|awk -F","  '{for(i=2;i<=NF;++i)print $i}' > imagelist.txt
echo "cloud provider=====>$cloud_vendor"

#######################create list of specs#######################################
if [[ -f "spec_list.txt"  && -d "spec_temp" ]] ; then
    rm "spec_list.txt" 
    rm -r "spec_temp"
else 
      ls -1 ${CYP_INT}/*.spec.js|xargs -n 1 basename> spec_list.txt
      cat  spec_list.txt
fi
ls -larth spec_list.txt

for i in $(cat spec_list.txt)
do

echo "working on ======================================================>$i"
cloud=$(echo $i|awk -F"_cyp_" '{print $1}'|awk -F"_" '{print $NF}')
    if [[ $cloud == 'tu10101' ]]
       then
         cloud='otc'
         
    elif [[ $cloud == 'azt9797' ]]
       then 
       cloud='azure'

    elif [[ $cloud == 'tib0301' ]]
       then 
       cloud='aws'
    elif [[ $cloud == 'fci0401' ]]
       then 
       cloud='fci'

    elif [[ $cloud == 'gcp0501' ]]
       then 
       cloud='gcp'

    else 
       echo " no selection made" 
       exit 1    
     fi   
image_temp=$(echo $i|awk -F"_cyp_" '{print $2}'|cut -d"." -f1)

      for j in $(cat imagelist.txt)
       do

        if [[  $cloud == $cloud_provider  && $j == $image_temp ]]
           then
             mkdir ${CYP_INT}/spec_temp 
             rsync -a  ${CYP_INT}/${i}  ${CYP_INT}/spec_temp    
        fi
      done
done
ls -larth ${CYP_INT}/spec_temp/

#########################################cases for  parsing day2 operations#################################################
case "$day2" in

      power) 
              echo "day2 condition===========>power"
              export day2_arg="stopServer=true,startServer=true"
              chmod +x ./scripts/npmTest.sh 
              sh -x ./scripts/npmTest.sh $day2_arg 
              ;;

application)
              
              echo "day2 condition===========>application"
              export day2_arg="stopApplication=true,startApplication=true"
              chmod +x ./scripts/npmTest.sh 
              sh -x ./scripts/npmTest.sh $day2_arg 
              ;;



     backup)
            
              echo "day2 condition===========>backup"
              export day2_arg="enableDatabaseBackup=true,createDatabaseBackup=true,listDatabaseBackup=true"
              chmod +x ./scripts/npmTest.sh 
              sh -x ./scripts/npmTest.sh $day2_arg 
              ;;
 

   patching)
            
              echo "day2 condition===========>patching"
              export day2_arg="checkForOsPatches=true"
              chmod +x ./scripts/npmTest.sh 
              sh -x ./scripts/npmTest.sh $day2_arg 
              ;;


   password)

              echo "day2 condition===========>password"
              export day2_arg="getPassword=true,changePasswod=true"
              chmod +x ./scripts/npmTest.sh 
              sh -x ./scripts/npmTest.sh $day2_arg 
              ;;



   complete)
               
              echo "day2 condition===========>complete"
              export day2_arg="stopSID=true,startSID=true,enableDatabaseBackup=true,createDatabaseBackup=true,listDatabaseBackup=true,checkForOsPatches=true,getPassword=true,changePasswod=true,resize=true"
              chmod +x ./scripts/npmTest.sh 
              sh -x ./scripts/npmTest.sh $day2_arg 
              ;;

   scenario)
             
            for k in $(cat imagelist.txt)
               do 
                
                  if [[ ( $k == "syb" ) || ( $k == "bw_han" ) || ( $k == "syb_skel_single" ) || ( $k == "adobe_ds_1909" ) || ( $k == "ora_erp")  ]] 
                     then 
                     export day2_arg="stopApplication=true,stopServer=true,startServer=true,startApplication=true"
                     chmod +x ./scripts/npmTest.sh 
                     sh -x ./scripts/npmTest.sh $day2_arg    

                  fi 


                  if [[ ( $k == "syb" ) || ( $k == "bw_han" ) || ( $k == "ora_erp" ) ]] 
                     then 
                     export day2_arg="enableDatabaseBackup=true,createDatabaseBackup=true,listDatabaseBackup=true"
                     chmod +x ./scripts/npmTest.sh 
                     sh -x ./scripts/npmTest.sh $day2_arg    
                  fi

                  if [[ ( $k == "syb_skel_single" ) ]] 
                     then 
                     export day2_arg="checkForOsPatches=true,getPassword=true,changePasswod=true,resize=trure"
                     chmod +x ./scripts/npmTest.sh 
                     sh -x ./scripts/npmTest.sh $day2_arg    
                  fi

             
               done ;;

          *)
             echo "option out of context" 
            ;;        
esac        
