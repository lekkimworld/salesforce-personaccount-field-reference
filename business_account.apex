// get the record type ID of the business account - note they may be named 
// different things in different orgs but since we created ours using 
// SalesforceDX we know what it's called
RecordType businessAccountRT = [SELECT Id 
    FROM RecordType 
    WHERE sobjecttype='Account' AND DeveloperName='Business_Account' 
    LIMIT 1];

// create business account (signaled using the business account record type id)
final String businessAccKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
Account businessAcc = new Account(
    // record type
    RecordTypeId=businessAccountRT.Id,

    // standard fields on Account
    Name='Her Majestry\'s Secret Service',
    Site='London',

    // custom fields on Account (suffixed with __c)
    TopSecret__c=true,
    Source_System_Id__c=businessAccKey
);
insert businessAcc;

// read account back
businessAcc = [SELECT 
        Name, Site,
        Source_System_Id__c, TopSecret__c
    FROM Account 
    WHERE Source_System_Id__c =: businessAccKey LIMIT 1];
System.debug(String.format(
    '{0} is situated in {1} (top secret: {2})', 
    new List<String>{businessAcc.Name, businessAcc.Site, businessAcc.TopSecret__c ? 'yes' : 'no'}
));

// update account
businessAcc.Site = 'London, England';           // standard field
businessAcc.TopSecret__c = true;                // custom field
upsert businessAcc;
