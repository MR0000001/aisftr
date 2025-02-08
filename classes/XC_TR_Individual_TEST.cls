/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  22/05/2019 
* @description XC_TR_Individual_UpdateContact_TEST – Test class for XC_TR_Individual_UpdateContact
*/ 
    @isTest
public class XC_TR_Individual_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }
    
     static testMethod void onInsert(){
            Test.startTest();
                Individual i = new Individual();
                i.LastName='Rossi';
                i.XC_GDPRThirdPartiesRelated__c= false; 
                insert i ; 
                i.XC_GDPRThirdPartiesRelated__c= true; 
                update i ; 
                delete i;
            System.assertEquals(true, i.XC_GDPRThirdPartiesRelated__c);
            Test.stopTest();
     }

}