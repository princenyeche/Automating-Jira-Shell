#!/bin/bash
################################################
# Script Name: Bulk Change Managed Users Email Address
# Author     : Prince Nyeche
# Platform   : Atlassian Organization
# Version    : 0.4
# endpoint set email
# PUT /users/{account_id}/manage/email
# Generate API Key from https://admin.atlassian.com/o/{organizationId}/admin-api
################################################
# uncomment set -x to debug
# set -x
# Set delimiter
IFS=","
OLDIFS=$IFS
path=$(pwd)
OLDIFS=$IFS
fname="USERS"
folder=$(mkdir -pv $fname)
read -p "Enter your Atlassian Managed Account API token: " token
SLEEP=2
content="Content-Type: application/json"
headers="Authorization: Bearer $token"
regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
rname="LOGS"
logger=$(mkdir -pv $rname)
log=report_$(date "+%Y-%m-%d-%H:%M:%S").csv
# dir file path to CSV file
read -p "Enter the user file Name: " userFile
DeleteLog() {
# Delete log file
files=$path/$fname/*.[a-z][a-z][a-z]
  for x in $files
  do
    rm -f $x
    echo "Deleting log \"$x\"..."
  done
  # we remove our credential and validators files
  rm -d $fname
  echo "removing  Directory \"$fname\""
sleep $SLEEP
}

updateEmail() {
file="$path/$userFile"
echo -e "\nChecking CSV File ... \n"
echo -e " Errors, User email, Full Name" | awk -F "," '{print $0}' > $rname/$log
if [[ -f $file ]]; then
  cat  $file | while read -r id displayName emailAddress active date  LastLogin
    do
      accountId=$id
      email=$emailAddress
      if [[ $emailAddress =~ $regex ]] && [[ ! -s $fname/${email}.txt ]]; then
      curl  -s -d '{"email": "'$emailAddress'" }' -X PUT -H "$content" -H "$headers" "https://api.atlassian.com/users/${accountId}/manage/email" > $fname/${email}.txt 2>&1
        # print stdout and stderr to email.txt file
        # print out the success
      echo -e "Changed $displayName to new $emailAddress complete...\n"
    else
      echo -e "Error unable to update user, $email , $displayName" >> $rname/$log
    fi
  done < $file
else
echo -e "****************************************************\n"
echo -e "NO $file EXIST, UPDATE FAILED \n"
echo -e "****************************************************\n"
fi
echo -e "REPORTING FILE LOCATED AT $path/$rname"
}

# Initialize the Script
updateEmail
DeleteLog
IFS=$OLDIFS
