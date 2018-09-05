# SFDX  App

## Dev, Build and Test


## Resources


## Description of Files and Directories


## Issues

// Person accounts are really Account records with a specific record type. Having the special 
// recort type the fields from the Contact object is available on the Account as well. All 
// fields from Contact except FirstName, LastName and Name are prefixed with Person i.e. 
// Contact.MobilePhone becomes Account.PersonMobilePhone. Custom fields on Contact has a 
// __pc suffix instead of __c meaning that Contact.Shoesize__c becomes Account.Shoesize__pc

can Account.Name be set


sfdx force:org:create -f config/project-scratch-def.json -a personaccount.org -v bec.devhub
sfdx force:org:open -u personaccount.org

sfdx force:source:push -u personaccount.org
sfdx force:apex:execute -u personaccount.org -f ./business_account.apex
sfdx force:apex:execute -u personaccount.org -f ./person_account.apex
sfdx force:apex:execute -u personaccount.org -f ./person_account_and_badge.apex

sfdx force:apex:execute -u personaccount.org -f ./delete_accounts.apex
sfdx force:data:soql:query -u personaccount.org -q "select id, developername from RecordType where sobjecttype='Account' AND DeveloperName='PersonAccount'" --json | jq -r ".result.records[0].Id"
# update record type id in bulk file
sfdx force:data:bulk:upsert -s Account -f bulk/person_accounts.csv -i AccountSourceId__c -w 100 -u personaccount.org
sfdx force:data:bulk:upsert -s Badge__c -f bulk/person_badges.csv -w 100 -u personaccount.org -i Id


