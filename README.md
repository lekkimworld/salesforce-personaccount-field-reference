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