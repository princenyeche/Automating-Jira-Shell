#!/bin/bash
# ------------------------------------------
# Script:  DELETE Users in Bulk Script
# Author : Prince Nyeche
# Platform: Atlassian Cloud Users
# Version: 1.2
# ------------------------------------------
# If you want to debug the Script run uncomment set -x below
# set -x
# A printable screen to show what the Script can do
printf "####################################################################### \n"
printf "                        DELETE USERS SCRIPT \n"
printf "                     Functions of this Script \n"
printf "                     ------------------------- \n"
printf "            1. VERIFY Credentials to Login \n"
printf "            2. VERIFY Users is valid before Deleting    \n"
printf "            3. DELETE Users from the Cloud Instance \n"
#printf "            4. DEATIVATE/ACTIVATE Users from the Cloud Instance  \n"
printf "                                                    \n"
printf "              To suspend the Script... [Press Ctrl + Z]      \n"
printf "####################################################################### \n"
# set delimiter
IFS=","
OLDIFS=$IFS
credentials="credential.csv"
fname="USERDELETED"
folder=$(mkdir -pv $fname)
path=$(pwd)
# we get our details and insert into a file
read -p "Enter your Atlassian Account Email Address: " email
read -p "Enter API token : " apitoken
printf $email','$apitoken | awk -F "," '{print $0}' > $fname/$credentials
### ---- Setup Config Start ----####
regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
url="atlassian.net"
# format : nexusfive not complete URL
read -p "Enter Atlassian Instance Name: " ins_name
# Declare file path, using current directory
read -p "Enter CSV User File Name: " userFileName
# Allow waiting time
SLEEP=2
# Deleting the files that were downloaded
# we don't want to leave a mess do we :D
DeleteLog() {
for files in $file2
do
  rm -f $files
  echo "removing  file \"$files\""
done
# we remove our credential file and validators
rm -f $fname/$credentials
echo "removing file... \"$credentials\""
rm -f $fname/${email}.txt
echo "removing file... \"${email}.txt\""
# then we remove the Directory
rm -d $fname
echo "removing  Directory \"$fname\""
sleep $SLEEP
clear
echo "*************************************************************"
echo "          DOWNLOADED FILES HAS BEEN REMOVED              "
echo "*************************************************************"
}
# user function, we only call this if and only if, the credentials are correct.
DeleteUser() {
# Somehow our file won't get read here. maybe because it's called into another read command
# and it's skipped if placed here, so we push it to a Global position.
file=$path/$userFileName
file2=$path/$fname/5*.txt
echo "Checking user file, Please wait..."
sleep $SLEEP # allow the processor to catch a breather (^_^)
# Check if the CSV file exist
if [[ -f $file ]]; then
# Read the CSV file and identify the columns, format like below
cat $file | while read -r id name emailAddress active date  LastLogin
# Start the loop here
do
    accountId=$id
    i=$emailAddress
    getUser=$(curl --silent -u "$email":"$apitoken" -X GET -H "Content-Type: application/json" "https://$ins_name.$url/rest/api/3/user?accountId=$accountId" > $fname/${accountId}.txt 2>&1)
    VERIFY_USER=$(grep '"active.*' $fname/${accountId}.txt | cut -d ',' -f9)
    No_User=$(grep "errorMessages" $fname/${accountId}.txt | cut -d ',' -f2)
# ----------------------------------------------
# Start the  Conditions to check
# 1. Validate email in CSV file ( we only check this)
# 2. Download a list of each user accountId
# 3. Validate if the user has been deleted before
# 4. Output if user has been deleted, exist or doesn't exist
# ----------------------------------------------
    if [[ "$i" =~ $regex ]] &&  [[ "$VERIFY_USER" == "\"active\":true" ]] ; then
# Start deleting the user in the instance
    echo "Deleting account...$accountId"
    curl -u "$email":"$apitoken" -X DELETE -H "Content-Type: application/json"  "https://$ins_name.$url/rest/api/3/user?accountId=$accountId"
    echo "User Deleted... $name : $emailAddress"
# -------------------------------------------
# check whether the user has been deleted before
# -------------------------------------------
elif [[ "$i" =~ $regex ]] && [[ "$VERIFY_USER" == "\"active\":false" ]] ; then
    echo "*********************************************"
    echo " This $emailAddress has been deleted before..."
    echo "*********************************************"
  elif [[ "$i" =~ $regex ]] && [[ "$No_User" == "\"errors\":{}}" ]] ; then
      echo "*********************************************"
      echo " This $emailAddress doesn't exist yet     ..."
      echo "*********************************************"
  else
# Output an error for wrong email Address
    echo "**************************************************"
    echo " $emailAddress doesn't seem valid...Check the CSV file..."
    echo "**************************************************"
      fi
    done < $file
sleep $SLEEP
echo "**************************"
echo "Script Process complete..."
echo "**************************"
else
# Output an error if the file entered doesn't exist
echo "*************************************************************"
echo "  No $userFileName file exist, cannot delete any user...Check and try again."
echo "*************************************************************"
  fi
  DeleteLog
}
### ---- Setup Config Start ----####
# we create  a Basic Auth function to verify our login credentials
BasicAuthJira() {
cat $fname/$credentials | while read -r email apitoken
do
  grabUser=$(curl --silent -u "$email":"$apitoken" -X GET -H "Content-Type: application/json" "https://$ins_name.$url/rest/api/3/myself"  1>> $fname/${email}.txt)
  loginOkay=$(grep '"active":*' $fname/${email}.txt | cut -d ',' -f9)
  loginErr=$(grep 'Unauthorized (401)' $fname/${email}.txt |cut -d "<" -f2)

 if [[ "$email" =~ $regex ]] && [[ "$loginOkay" == "\"active\":true" ]]; then
    echo "CREDENTIALS ACCEPTED, Login Successful..."
    #start reading the function
    DeleteUser
  elif [[ "$email" =~ $regex ]] && [[ "$loginErr" == "title>Unauthorized (401)
h1>Unauthorized (401)" ]]; then
    echo "INVALID CREDENTIALS, Authentication Failed..."
    echo "exiting Script..."
    DeleteLog
  else
    echo "Something else went wrong, check the Script..."
    echo "exiting Script..."
    DeleteLog
 fi
done < $fname/$credentials
sleep $SLEEP
}
# we  start our authentication with the details entered, we print out the Information
# to point out authentication done.
BasicAuthJira
# clear the Screen here before exiting.
IFS=$OLDIFS
exit $?
