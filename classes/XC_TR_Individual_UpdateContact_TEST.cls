/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_Individual_UpdateContact_TEST – Test class for XC_TR_Individual_UpdateContact
    */ 
    @isTest
public with sharing class XC_TR_Individual_UpdateContact_TEST {
         // Test method for updateContactsFromIndividual 
     static testMethod void updateContactsFromIndividual(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                Individual i = new Individual();
                i.LastName='Verdi';
                
                insert i ; 
                
                i.FirstName='Paolo';
                i.LastName='Rossi';
                i.XC_GiveDataToThirdParties__c= 'No'; 
                

                List<Contact> c = XC_DF_Contact.createResidentialContacts(1);
                c[0].FirstName= 'Mario';
                c[0].LastName= 'Bianchi';
        
                c[0].IndividualId = i.Id ;
                insert c; 

                i.XC_ChildContact__c = c[0].Id; 
                update i ; 
               
            System.assertEquals(1, c.size());
            Test.stopTest();
     }
   
}