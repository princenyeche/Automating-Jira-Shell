#!/bin/bash
#######################################
## Script : Delete Multiple Issues
## Platform: JIRA Cloud
## Author : Prince Nyeche
## Version : 1.1
#######################################
# to see what happens uncomment set -x
# set -x
read -p "Enter your Atlassian Email Address: " email
read -p "Enter your Atlassian API Token: " apitoken
# declare Instance format : nexusfive
read -p "Enter Instance Name (e.g. nexusfive): " ins_name
# declare where the delete issue start
read -p "Enter Issue Start Key (numbers only): " iss_1
# declare where the delete  issue end
read -p "Enter Issue End Key (numbers only): " iss_2
# The Issue Project Key format: ABC
read -p "Enter Project Key (e.g. ABC): " iss_key
#########configurations###########
content="Content-Type: application/json"
path=$(pwd)
fname="DELETEISSUES"
folder=$(mkdir -pv "$path/$fname")
#########configurations###########
for (( c=$iss_1; c<=$iss_2; c++ ))
do
	# make a request to download the JSON payload of the file
	# we will use the info on that file to create a condition
	# to let us know if the file exist or not
	body=$(curl --silent -u "$email":"$apitoken" -X GET -H "$content" "https://$ins_name.atlassian.net/rest/api/3/issue/${iss_key}-${c}" > $fname/${iss_key}-${c}.txt 2>&1)
  sleep 1
	Is_Issue=$(grep '"key.*' $fname/${iss_key}-${c}.txt | cut -d ',' -f10)
	Not_Issue=$(grep 'errorMessages' $fname/${iss_key}-${c}.txt | cut -d ',' -f2)
	# start a condition to check the files are correct
	# if they exist or not, you know what to do
	if [[ -f "$path/$fname/${iss_key}-${c}.txt"  &&  "$Not_Issue" == "\"errors\":{}}" ]]; then
		echo "No content in this Issue skipping...${iss_key}-${c}"
	elif [[ -f "$path/$fname/${iss_key}-${c}.txt" && "$Is_Issue" == "\"key\":\"${iss_key}-${c}\"" ]]; then
	echo "Deleting Issues...${iss_key}-${c}"
	curl -u "$email":"$apitoken" -X DELETE -H "$content" "https://$ins_name.atlassian.net/rest/api/3/issue/${iss_key}-${c}?deleteSubtasks=true"
else
  echo "Something went wrong somewhere, we're checking it out...";
fi
done
printf 'removing files and deleting %s'"$fname"' Directory \n'
# remove the files first,
rm -f $path/$fname/$iss_key*
# allow waiting if many files
sleep 5
# then delete the directory
rm -d $path/$fname
sleep 1
echo
echo "*********************************************"
echo "        DELETE Process Complete              "
echo "*********************************************"
