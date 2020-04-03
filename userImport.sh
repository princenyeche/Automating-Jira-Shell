#!/bin/bash
# ------------------------------------------
# Import Users & Groups  in Bulk Script
# Author : Prince Nyeche
# Platform: Atlassian Cloud Users
# Version: 0.8
# ------------------------------------------
# If you want to debug Script uncomment set -x
# set -x
printf "####################################################################### \n"
printf "                   CLOUD USERS & GROUPS IMPORT SCRIPT \n"
printf "                     Functions of this Script \n"
printf "                     ------------------------- \n"
printf "            1. VERIFY Credentials to Login \n"
printf "            2. VERIFY Users is valid before creating  \n"
printf "            3. Creates Groups from CSV file \n"
printf "            4. Adds Users into Groups from CSV file  \n"
printf "                                                    \n"
printf "              To suspend the Script... [Press Ctrl + Z]      \n"
printf "####################################################################### \n"
#########################################
# Change Log 14 Dec 2019
# 1. Added a means to validate login
# 2. rewrote the script into functions
# 3. Add more UI features
#
#########################################
# Set delimiter
IFS=","
OLDIFS=$IFS
#### ---- Configuration ---####
credentials="credential.csv"
fname="CLOUDIMPORT"
folder=$(mkdir -pv $fname)
path=$(pwd)
CONN_END=4 #terminated connection
# we get our details and insert into a file
read -p "Enter your Atlassian Account Email Address: " email
read -p "Enter API token : " apitoken
printf $email','$apitoken | awk -F "," '{print $0}' > $fname/$credentials
SLEEP=2
content="Content-Type: application/json"
regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
userlog="userlog.txt"
grouplog="grouplog.txt"
groupfile="groupfile.csv"
inst="atlassian.net"
#### ---- End Configuration ---####
# format : nexusfive
read -p "Enter Issue Instance Name: " ins_name
# declare file path to users file
read -p "Enter Users File Name: " userFileName
# declare file path to group file
read -p "Enter Groups File Name: " memFileName
url="https://$ins_name.atlassian.net/rest/api/3/user"
DeleteLog() {
# Delete log file
files=$path/$fname/[ug]*.[a-z][a-z][a-z]
for x in $files
do
  rm -f $x
  echo "Deleting log \"$x\"..."
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
}
# We define a function to Create Groups
CreateGroup() {
# Start creating a Group, mention something on screen
echo "Starting Group Import..."
if [[ -f $file2 ]]; then
  cat $file2 | while read -r groupname id name emailAddress active created
    do
      echo "Creating Groups..." '\n'
      if [[ -n $groupname ]]; then
      curl  --silent -u "$email":"$apitoken" -d '{"name": "'$groupname'" }' -X POST -H "$content" "https://$ins_name.$inst/rest/api/3/group" 2>> $fname/$grouplog
# print stdout to screen and stderr to grouplog
# print out the success
      printf 'Group Created... Group Name: "'$groupname'"\n'
    fi
  done < $file2
else
echo "****************************************************"
echo "No $file2 file exist, No Group creation"
echo "****************************************************"
fi
# End Group creation
addUserToGroup
DeleteLog
}
# We define a function to Add created users to Groups
addUserToGroup() {
# ----------------------------------------------
# Start the  Conditions to check
# 1. Start checking the accountId and add the groups
# ----------------------------------------------
if [[ -f $file2 ]]; then
# Accounted for space characters, will need to write a function
cat $file2 | sed -e 's/ /+/g'| awk -F "," '{print $1","$2}'  > $fname/$groupfile
# if want to manipulate other special characters
# I think POSIX will work though
# e.g. sed -e 's/[:punct:]/+/g' => Future test
 cat $path/$fname/$groupfile| while read -r groupname id
  do
    accountId=$id
    echo "Checking Groups..." '\n'
    curl -u "$email":"$apitoken" -d '{"accountId": "'$accountId'"}' -X POST -H "$content" "https://$ins_name.$inst/rest/api/3/group/user?groupname=${groupname}"
# display the values of the file
 printf 'Matching accountId to Group... Groups: "'$groupname'"\n'
done < $fname/$groupfile
else
echo "****************************************************************"
echo "No $file2 file exist, cannot create groups to user...Try Again."
echo "****************************************************************"
fi
echo "*********************************************"
echo "        User & Group Addition Complete "
echo "*********************************************"
}
# We define a function to Create Users
CreateUser() {
# file variables and path to file
file="$path/$userFileName"
file2="$path/$memFileName"
# Show something to the user to read while waiting
echo "Checking user file, Please wait..."
sleep $SLEEP
### ---- Start  the Conditions ----###
# ----------------------------------------------
# Start the  Conditions to check
# 1. Validate email in CSV file ( we only check this)
# 2. Download a list of each user accountId
# 3. Validate if the user has been created before
# 4. Output if data has been created, create user
# ----------------------------------------------
if [[ -f $file ]]; then
# Start the loop
cat $file | while read -r id displayName emailAddress active date  LastLogin
do
      if [[ $emailAddress =~ $regex ]]; then
      # Start Creating the user in the instance
      echo "$url"
      curl --silent -u "$email":"$apitoken" -d '{"emailAddress": "'$emailAddress'", "displayName": '$displayName' }' -X POST -H "$content"  "$url" >> $fname/$userlog 2>&1
       # display the values of the user created
       printf 'Creating User... emailAddress: "'$emailAddress'", displayName: '$displayName'\n'
       else
       echo "**************************************************"
       echo "$emailAddress doesn't seem valid...Check the CSV file..."
       echo "**************************************************"

      fi
done < $file
# Close reading file, print results
echo "*********************************************"
echo "        User Creation Complete"
echo "*********************************************"
else
# if file not present display  message
echo "****************************************************"
echo "No $file file exist, cannot create user...Try Again."
echo "****************************************************"
fi
# End Bulk User Creation
CreateGroup
}
# Our Basic Authentication to login
BasicAuthJira() {
cat $fname/$credentials | while read -r email apitoken
do
  grabUser=$(curl --silent -u "$email":"$apitoken" -X GET -H "Content-Type: application/json" "https://$ins_name.$inst/rest/api/3/myself"  1>> $fname/${email}.txt)
  loginOkay=$(grep '"active":*' $fname/${email}.txt | cut -d ',' -f9)
  loginErr=$(grep 'Unauthorized (401)' $fname/${email}.txt |cut -d "<" -f2)

 if [[ "$email" =~ $regex ]] && [[ "$loginOkay" == "\"active\":true" ]]; then
    echo "CREDENTIALS ACCEPTED, Login Successful..."
    #start reading the function
    CreateUser
  elif [[ "$email" =~ $regex ]] && [[ "$loginErr" == "title>Unauthorized (401)
h1>Unauthorized (401)" ]]; then
    echo "INVALID CREDENTIALS, Authentication Failed..."
    DeleteLog
    exit $CONN_END
  else
    echo "Something else went wrong, check the Script..."
    DeleteLog
    exit $CONN_END
 fi
done < $fname/$credentials
}
# We Initialize our Script below
BasicAuthJira
IFS=$OLDIFS
exit $?
