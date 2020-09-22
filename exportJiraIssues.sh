#!/bin/bash
# User CREDENTIALS
email=email@address.com
apitoken=3yXXXXXXXXXXXXXX
# Enter Instance name without full URLs
read -p "Enter Instance Name (only): " instance
# The Amount of issues you want exported per CSV file e.g: 100
read -p "Enter Issue export in digits: " issue_1
# Where you want the Loop counter to stop counting  e.g. 400
read -p "Enter Loop Number in digits: " issue_2
# The Max range where you want the loop to jump to the issues rather to start the next export, it could be the same as the Initial number or lower. e.g.100
read -p "Enter Issue export Stop Cycle in digits: " issue_3
# The JQL URLs
# format: project%20%3D%20AT2%20ORDER%20BY%20Rank%20ASC
# you can copy this URL from the Issue navigator search by searching some issues and copy the URL
read -p "Enter JQL URL: " jql_url
# run a loop to cycle through the search, limit is 1K issues per CSV file by default.
for (( c=$issue_1; c<=$issue_2; c=c+$issue_3 ))
do
	echo "https://$instance.atlassian.net/sr/jira.issueviews:searchrequest-csv-all-fields/temp/SearchRequest.csv?jqlQuery=$jql_url&tempMax=1000&pager/start=${c}"
  curl -o "$c.csv" -u "$email":"$apitoken" -X GET -H "Content-Type: application/json" "https://$instance.atlassian.net/sr/jira.issueviews:searchrequest-csv-all-fields/temp/SearchRequest.csv?jqlQuery=$jql_url&tempMax=1000&pager/start=${c}"
done
echo "
*********************************************
        Export Complete
*********************************************
"
