#!/bin/bash

#ssh connection 
#Please run this script in the private key location !
#ssh -i private_key.pem rke@jump-att-pet1-oso.petgrp1.attbase.amdocs.com
# Colors 
red='\033[0;31m';
green='\033[0;32m';
NC='\033[0m';

echo "####### date and Pod name is ########"


# loop inside deployment 

kubectl get deploy -n dop | grep -i 'dop-backend-oso \|nimbus-integration-service \|sky-integration-service \|som-tmf622-service' | awk '{print $1}' | while read deploy ; do 

# Select the Pods names which conatins a word "pod" 
kubectl get pod -n dop | grep -i "$deploy" | awk '{print $1}' | while read pod_name;do

 log=$(kubectl logs -n dop $pod_name  | grep -i "error" | tail -1)

#then extract pods logs and looping them , then using egrep to match the date pattern 
#for EX if date format in log file is 22/Nov/2022:19:09:16 
#use pattern [0-9]{2}/[A-Za-z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}


 kubectl logs -n dop $pod_name  | grep -i "error" | tail -1 | egrep -o "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" | \

    while read -r line; do
    # Reading date and time into separate variables
     yyyy=${line:0:4};
     mm=${line:5:2};
     dd=${line:8:2};
     time=${line:11:8};
    # displaying pod_name ,datetime and log error in desired format
     log_date=$(date -d  "${yyyy}-${mm}-${dd} ${time}" +'%Y %m %d %H:%M:%S') 

     echo -e "$green POD_NAME: $NC $pod_name,$green DATE: $NC $log_date  ,$red ERROR_LOG $NC : $log"  
    # echo "$log_date"
     done  
   done 
 done | sort  -k7 | tail -1 # | awk ' {print $NF }'
echo "###########################################"
