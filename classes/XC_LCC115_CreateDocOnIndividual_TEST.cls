@isTest
public without sharing class XC_LCC115_CreateDocOnIndividual_TEST {
    
    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c();  
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
        individual e = new individual();
        e.lastname = 'test';
        insert e;
        
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c();
        ct.country__c = 'SPAIN';
        ct.APXTConga4__Name__c = 'IndividualTemplate';
        insert ct;
        
        lead l = new lead();
        l.lastname = 'asd';
        l.email = 'test@test.it';
        l.company = 'test';
        l.IndividualId = e.id;
        insert l;
        
        update e;

        //creazione contact
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(1);
        insert contacts;

        // individual e2 = new individual();
        // e2.lastname = 'test2';
        // insert e2;

        // contacts[0].IndividualId = e2.Id;
        // update contacts[0];



    }
    
    static testMethod void populateCongaField_test(){
        
       Id indId = [SELECT Id,IndividualId FROM Lead WHERE IndividualId!=null LIMIT 1][0].IndividualId;
        

        Test.startTest();
        String res = XC_LCC115_CreateDocumentOnIndividual.populateCongaField(indId);
        system.assert(res!=null);
        Test.stopTest();

    }

    static testMethod void populateCongaField_test2(){
        
        Id indId = [SELECT Id,IndividualId FROM Contact WHERE IndividualId!=null LIMIT 1][0].IndividualId;
        

        Test.startTest();
        
        String res = XC_LCC115_CreateDocumentOnIndividual.populateCongaField(indId);
        system.assert(res!=null);
        Test.stopTest();

    }

    static testMethod void startWorkflowOnIndividual(){

        Id indId = [SELECT Id,IndividualId FROM Contact WHERE IndividualId!=null LIMIT 1][0].IndividualId;

        Test.startTest();
        XC_LCC115_CreateDocumentOnIndividual.startWorkflowOnIndividual(indId);
        Test.stopTest();


    }

}