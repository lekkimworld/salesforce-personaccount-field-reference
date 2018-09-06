RecordType personAccountRT = [SELECT Id 
    FROM RecordType 
    WHERE sobjecttype='Account' AND DeveloperName='PersonAccount' 
    LIMIT 1];

// create PersonAccount
final String personAccKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
Account acc1 = new Account(
    RecordTypeId=personAccountRT.Id,
    FirstName='Foo',
    LastName='Bar',
    AccountSourceId__c=personAccKey,
    ContactSourceId__pc=EncodingUtil.base64Encode(Crypto.generateAesKey(128)),
    Shoesize__pc=42.0
);
insert acc1;

// retrive account back without Name so we can update FirstName and/or LastName
Account personAcc = [SELECT 
        FirstName, LastName 
    FROM Account 
    WHERE AccountSourceId__c =: personAccKey
    LIMIT 1];
personAcc.FirstName = 'Foo';
personAcc.LastName = 'Baz';
upsert personAcc;
