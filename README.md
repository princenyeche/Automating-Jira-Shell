# AutomatingJIRA
Useful Scripts to Automate certain features of Atlassian Cloud

## Use cases

Using REST API to bulk change users on Atlassian Cloud.

* Create Users & Create Groups in Bulk
* Delete Users in Bulk
* Bulk Change Managed Users Email Address

## Usage
* Bulk Deleting Users in User Management
* Bulk Changed Claim domain email Address
* Bulk Create Users and Add them to Groups on JIRA Cloud

## How to Use

1. Make use that you have user permission right on the file.

2. On your Terminal run `chmod u+x <filename>.sh`

3. Then to initiate the script run `./<filename>.sh`

4. Do not forget to rename Instance name and insert **emailAddress** and **API-TOKEN** on the file prior to running it.

### Create a CSV file or Download the list from admin.atlassian.com
The file should include the accountID, emailAddress in the below format.

>| id  | name  | email  | active  |date   | LastLogin |
>|---|---|---|---|---|---|
>| 5559343a3813hag  |User 1   | user1@example.com  | Yes  | 2 Nov 2019  |Never logged in|


You can remove the header of the csv file prior to beginning the script.

### Create User Import & Group Import
The file should include the groupname, accountID, emailAddress in the below format.

* This script doesn't do much validation
* Ensure that the file is correct as below

>|groupname| id  | name  | email  | active  |date   | LastLogin |
>|---|---|---|---|---|---|---|
>|Fit group| 5559343a3813hag  |User 1   | user1@example.com  | Yes  | 2 Nov 2019  |Never logged in|

Please remove the header of the csv file prior to beginning the script.

