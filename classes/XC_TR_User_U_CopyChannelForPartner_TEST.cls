/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  23/05/2019 
    * @description XC_TR_User_U_CopyChannelForPartner_TEST – Test class for XC_TR_User_U_CopyChannelForPartner
    */ 
    @isTest
public with sharing class XC_TR_User_U_CopyChannelForPartner_TEST {
    // Test method for rebaltChannel 

         @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_ReceivingChannel__c= 'DPO';
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
    }

     static testMethod void rebaltChannel(){
            Test.startTest();
             List<Account> acc =[SELECT Id , Name
                                FROM Account ];
            List<Contact> cont= [SELECT Id, FirstName, LastName, Email
                                FROM Contact];
  
            System.debug('@@@-Account'+ acc); 
            List<User> u = XC_DF_User.createCommunityUsers(cont,true);
            
       
            
           

            System.assert(u!=null);
            Test.stopTest();
     }

}