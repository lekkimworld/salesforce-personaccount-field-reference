// get the record type ID of the person account - note they may be named 
// different things in different orgs but since we created ours using 
// SalesforceDX we know what it's called
RecordType personAccountRT = [SELECT Id 
    FROM RecordType 
    WHERE sobjecttype='Account' AND DeveloperName='PersonAccount' 
    LIMIT 1];

// create Account but mark as PersonAccount by setting the record type id
final String personAccKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
Account personAcc = new Account(
    // record type
    RecordTypeId=personAccountRT.Id, 

    // fields from Contact - notice custom field is suffixed with __pc
    FirstName='James', 
    LastName='Bond',
    PersonMobilePhone='914-007-1234',
    PersonDepartment='Her Majestry\'s Secret Service',
    Shoesize__pc=43.0,

    // fields from Account - notice custom field is suffixed with __c
    AccountSourceId__c=personAccKey,
    Site='London',
    TopSecret__c=true
);
insert personAcc;

// create badges for James Bond
Badge__c badge = new Badge__c(
    Slug__c='tux101',
    Badge_Description__c='Learn all there is to know about wearing a tux in public.'
);

// we set the parent account by using the Salesforce object Id of the Account
badge.Account__c = personAcc.Id;
insert badge;
