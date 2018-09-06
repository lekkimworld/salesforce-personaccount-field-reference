# Salesforce PersonAccounts #
Person Accounts in Salesforce keeps confusing developers not at home on the platform due to their 
special behaviour. The purpose of this repo is to hold some examples on how to work with Person Accounts 
in an org using Apex and the Bulk API to try and illustrate a few points.

For production orgs PersonAccounts are enabled by opening a Case with Support as it's an irreversible process. If 
using [SalesforceDX](https://developer.salesforce.com/platform/dx) like in the examples below PersonAccounts may be 
enabled declaratively.

## What ARE PersonAccounts ##
First of knowing WHAT a Person Account is is important. In Salesforce we normally talk about Accounts and Contacts 
with the Account being the company entity (i.e. Salesforce.com Inc.) and the Contact being the people that we 
track for that company (i.e. Marc Benioff, Parker Harris etc.). It means that we have to have an Account and a 
Contact to track a person in Salesforce. But what if that doesn't make any sense like when tracking individuals 
for B2C commerce or similar? Meet the PersonAccount. 

**Please Note:** There is no such object as PersonAccount in Salesforce. There are only Account and Contact but in the 
following I'll use PersonAccount to reference this special case for Account.

PersonAccount is a special kind of Account that is both an Account AND a Contact giving you the possibility 
to treat an individual using an Account. The secret to understanding PersonAccount is knowing that using a 
special [record type](https://help.salesforce.com/articleView?id=customize_recordtype.htm&type=5) and specifying it 
when you create the Account, Salesforce will automatically create both an Account AND a Contact record and automatically 
link them and thus create the PersonAccount. Salesforce automatically makes the fields that are normally available (including custom fields) on the Contact available on Account. Only thing you need to do is follow a few simple rules that are listed below.

**Please Note:** When using PersonAccounts you should always access the Account and never the associated Contact.

## Finding the Record Type to use ##
I find that the easiest way to see the record types are to query for them using SOQL. The below query lists the 
record types for the Account object. Notice how one (the aptly named "Person Account") has the IsPersonType flag set 
to `true`. That indicates that it's a PersonAccount record type and it's that ID you supply when creating an Account to 
make it a PersonAccount.
```
sfdx force:data:soql:query -u myorg -q "select id, name, developername, ispersontype from RecordType where sobjecttype='Account'"
ID                  NAME             DEVELOPERNAME          ISPERSONTYPE
──────────────────  ────────────────  ─────────────────────  ────────────
0120E0000006cQ3QAI  Business Account BusinessAccount
0120E0000007fVaQAI  Person Account   PersonAccount           true
Total number of records retrieved: 2.
```

## Referencing Fields ##
Because there is both an Account and a Contact for a PersonAccount there are some special rules to follow when 
referencing fields. This goes for any access whether that be using Apex, REST API and the Bulk API. The rules are 
pretty easy and are as follows:

1. Always reference the Account object
2. When creating a PersonAccount create an Account specifying the record type ID of the PersonAccount record type configured in Salesforce. Doing this makes the Account a PersonAccount.
3. Fields from Account are available on Account (as probably expected):
    1. **Standard fields from Account** Referenced using their API name as usual (i.e. Site, Website, NumberOfEmployees)
    2. **Custom fields from Account** Referenced using their API name as usual (i.e. Revenue__c, MyIntegrationId__c)
4. Fields from Contact are available directly on Account:
    1. **Standard fields from Contact** The API name of the field is prefixed with "Person" (i.e. Contact.Department becomes Account.PersonDepartment, Contact.MobilePhone becomes Account.PersonMobilePhone) _**UNLESS**_ we are talking FirstName and LastName as they keep their names (i.e. Contact.FirstName becomes Account.FirstName, Contact.LastName becomes Account.LastName)
    2. **Custom fields from Contact** The field API name suffix is changed from __c to __pc (i.e. Contact.Shoesize__c becomes Account.Shoesize__pc)

## Examples ##
Below are some examples to illustrate the above. The examples may be executed using [SalesforceDX](https://developer.salesforce.com/platform/dx) and as such I assume familiarity with SalesforceDX in 
order to follow the examples. If you wish to learn more about SalesforceDX I suggest checking out 
the SalesforceDX trails on [Trailhead](https://trailhead.salesforce.com).

### Common Steps ###
```bash
# create scratch org aliased as "personaccount.org" using my DevHub (here aliased as "devhub") and 
# push the source to the scratch org
sfdx force:org:create -f config/project-scratch-def.json -a personaccount.org -v devhub
sfdx force:source:push -u personaccount.org
```

### Apex Examples ###
```bash
# work with regular accounts i.e. business accounts using Apex
sfdx force:apex:execute -u personaccount.org -f ./business_account.apex

# work with PersonAccounts using Apex
sfdx force:apex:execute -u personaccount.org -f ./person_account.apex

# example creating a record for a custom object referencing a PersonAccount
sfdx force:apex:execute -u personaccount.org -f ./person_account_and_badge.apex
```

### Bulk API Examples ###
```bash
# get record type id and update record type id in account bulk file
sfdx force:data:soql:query -u personaccount.org -q "select id, developername from RecordType where sobjecttype='Account' AND DeveloperName='PersonAccount'" --json | jq -r ".result.records[0].Id"

# delete accounts in the org
sfdx force:apex:execute -u personaccount.org -f ./delete_accounts.apex

## use Bulk API to insert PersonAccounts and custom object records
sfdx force:data:bulk:upsert -s Account -f bulk/person_accounts.csv -i AccountSourceId__c -w 100 -u personaccount.org
sfdx force:data:bulk:upsert -s Badge__c -f bulk/person_badges.csv -w 100 -u personaccount.org -i Id
```

## PersonAccount Caveats ##
The Name field is special in Salesforce and is available on all objects. For PersonAccounts the Name field 
is automatically updated to what you would expect i.e. the FirstName and LastName combined together. There is 
a caveat when you need to update the name for a PersonAccount. When referencing PersonAccount records you 
cannot update the Name field. Instead you update the FirstName and/or LastName fields. 

If done in Apex you cannot update the FirstName and/or LastName on a record where you retrieved the Name field. The code in `update_personaccount_name_error.apex` will fail with the following error as it retrieved the Name field and attempted to 
update the FirstName and/or LastName.

```bash
$ sfdx force:apex:execute -u personaccount.org -f update_personaccount_name_error.apex
Compiled successfully.
ERROR:  Execution failed.

 ▸    ERROR: System.DmlException: Upsert failed. First exception on row 0 with id 0013E00000tAeAmQAK; first error: INVALID_FIELD_FOR_INSERT_UPDATE, Unable to create/update fields: Name. Please check the security settings of this field and verify that it is read/write for your profile or
 ▸    permission set.: [Name]
 ▸    ERROR: AnonymousBlock: line 26, column 1
```
