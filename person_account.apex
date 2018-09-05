// get the record type ID of the person account - note they may be named 
// different things in different orgs but since we created ours using 
// SalesforceDX we know what it's called
RecordType personAccountRT = [SELECT Id 
    FROM RecordType 
    WHERE sobjecttype='Account' AND DeveloperName='PersonAccount' 
    LIMIT 1];

// create Account but mark as PersonAccount by setting the record type id
final String personAccKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
final String contactSrcId = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
Account personAcc = new Account(
    // record type
    RecordTypeId=personAccountRT.Id, 

    // fields from Contact - notice custom field is suffixed with __pc
    FirstName='James', 
    LastName='Bond',
    PersonMobilePhone='914-007-1234',
    PersonDepartment='Her Majestry\'s Secret Service',
    Shoesize__pc=43.0,
    ContactSourceId__pc=contactSrcId,

    // fields from Account - notice custom field is suffixed with __c
    AccountSourceId__c=personAccKey,
    Site='London',
    TopSecret__c=true
);
insert personAcc;

// read back the account
personAcc = [SELECT 
        Name, 
        FirstName, LastName, PersonMobilePhone, PersonDepartment, 
        Shoesize__pc, ContactSourceId__pc, 
        AccountSourceId__c, TopSecret__c, Site 
    FROM Account 
    WHERE AccountSourceId__c =: personAccKey
    LIMIT 1];
System.debug(String.format(
    'My name is {0}, {1} of {2}. Call me on {3} or visit me in {4}... Am I licensed to kill? {5}!', 
    new List<String>{
        personAcc.LastName, 
        personAcc.Name, 
        personAcc.PersonDepartment, 
        personAcc.PersonMobilePhone, 
        personAcc.Site,
        personAcc.TopSecret__c ? 'Yes' : 'No'}
));
