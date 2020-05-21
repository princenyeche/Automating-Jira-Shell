# Automating Jira
Useful Scripts to Automate certain features of Atlassian Cloud

## Use cases

Using REST API to bulk change users on Atlassian Cloud.

* Create Users & Create Groups in Bulk ( Perform a Jira Cloud to Jira Cloud User Import)
* Delete Users in Bulk
* Bulk Change Managed Users Email Address
* Bulk Delete Jira Issues

## Usage
* Bulk Deleting Users in User Management
* Bulk Changed Claim domain email Address
* Bulk Create Users and Add them to Groups on JIRA Cloud
* Bulk delete Jira Issues including sub-task

## How to Use

1. Make use that you have user permission right on the file.

2. On your Terminal run `chmod u+x <filename>.sh`

3. Then to initiate the script run `./<filename>.sh`

4. you will require your **emailAddress** and **API-TOKEN** to authenticate your user. get one from https://id.atlassian.com

## Create a CSV file or Download the list from admin.atlassian.com

### Create User Import
There are two files that needs to be supplied. 
1. The User file
2. The Membership file

The `User` file should include the accountID, emailAddress in the below format.

>| id  | name  | email  | active  |date   | LastLogin |
>|---|---|---|---|---|---|
>| 5559343a3813hag  |User 1   | user1@example.com  | Yes  | 2 Nov 2019  |Never logged in|


You can remove the header of the csv file prior to beginning the script.

### Create Group Import
The `Group` CSV file should include the groupname, accountID, emailAddress in the below format.

* This script doesn't do much validation
* Ensure that the file is correct as below

>|groupname| id  | name  | email  | active  |date   | 
>|---|---|---|---|---|---|
>|Fit group| 5559343a3813hag  |User 1   | user1@example.com  | Yes  | 2 Nov 2019  |

Please remove the header of the csv file prior to beginning the script.

### Bulk Change Managed Users Email
The CSV file format should look like below after you've downloaded it. Depending on how many applications
you have on your Cloud Instance, you can remove the other columns and just leave 6 columns as shown
below.

>| id  | name  | email  | active  |date   | LastLogin |
>|---|---|---|---|---|---|
>| 5559343a3813hag  |User 1   | user1@example.com  | Yes  | 2 Nov 2019  |Never logged in|

* The email column should be the `new emailaddress` you want to change to
  e.g. from user1@example.com to user1@yourdomain.com
  so on the file you should place user1@yourdomain.com, because that's the email
  you want to change to.
  
* Please remove the header of the csv file prior to beginning the script.

### Bulk Delete Users
The CSV file format should look like below.

>| id  | name  | email  | active  |date   | LastLogin |
>|---|---|---|---|---|---|
>| 5559343a3813hag  |User 1   | user1@example.com  | Yes  | 2 Nov 2019  |Never logged in|

Please remove the header of the csv file prior to beginning the script.

### Bulk Delete Jira Issues
Ensure that the Project is visible to you; that means, you have **"BROWSE"** Project Permission and the **"DELETE"** Issues Permission of the Permission Scheme
