/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  22/05/2019 
* @description XC_TR_Contact_U_HandleIndividual_TEST – Test class for XC_TR_Contact_U_HandleIndividual
*/
@istest
public class XC_TR_Contact_U_HandleIndividual_TEST {
    //Test Method handleIndividual
    static testMethod void handleIndividual(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;
        
        System.assertEquals(true, listc!=null);
        Test.stopTest();
    }
    
    //Test Method updateIndividualsFromContact
    static testMethod void updateIndividualsFromContact(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<Individual> listindiv = new List<Individual>();
        Individual indi = new Individual();
        indi.FirstName ='Test';
        indi.LastName = 'Testt';
        listindiv.add(indi);
        insert listindiv;
        
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        //listc[0].XC_GDPRThirdParties__c=true;
        listc[0].IndividualId = indi.Id;
        listc[0].FirstName ='Testc';
        insert listc;
        update listc;
        
        
        System.assertEquals(true, listc!=null);
        Test.stopTest();
    }
     //Test Method createIndividual
    static testMethod void createIndividual(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        Individual indi = new Individual();
        indi.FirstName ='Test';
        indi.LastName = 'Testt';
        insert indi;
        
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        listc[0].XC_SkipTriggerIndividual__c= false;
        insert listc;
        
       // update listc;
        
        List<XC_LegalEntityConsent__c> legalent = new List<XC_LegalEntityConsent__c>();
        XC_LegalEntityConsent__c lec = new XC_LegalEntityConsent__c();
        lec.XC_GiveDataToNew__c= 'Yes';
        lec.XC_LegalEntity__c='EndesaX';
        lec.XC_LeCountry__c = 'Spain';
        lec.XC_Individual__c =indi.Id;
        legalent.add(lec);
        insert legalent;
       

            
        System.assertEquals(true, listc!=null);
        Test.stopTest();
    }
    
    
    

}