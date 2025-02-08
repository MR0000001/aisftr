/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_Contact_U_CheckIndChildren_D_TEST – Test class for XC_TR_Contact_U_CheckIndChildren_D
    */ 
    @isTest
public with sharing class XC_TR_Contact_U_CheckIndChildren_D_TEST {
         // Test method for getMapIDToIndividual 
     static testMethod void getMapIDToIndividual(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            Individual i = new Individual(); 
            i.LastName= 'Rossi';
            insert i ;
            List<Contact> contact = XC_DF_Contact.createCondominiumContacts(1);
            contact[0].IndividualId = i.Id ;
            insert contact;
            System.assertEquals(1, contact.size());
            Test.stopTest(); 
     }

  

}