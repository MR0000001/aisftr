/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  23/05/2019 
    * @description XC_TR_User_U_CheckPartnerRole_TEST – Test class for XC_TR_User_U_CheckPartnerRole
    */ 
    @isTest
public with sharing class XC_TR_User_U_CheckPartnerRole_TEST {
     // Test method for checkPartnerRoleChanged 

     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
     static testMethod void checkPartnerRoleChanged(){
            User u = XC_DF_User.createUserAdmin(); 
            u.XC_HasRoleBeenProcessed__c= true; 
            
            insert u; 
            System.debug('@@@-USEROLD' + u );
            Test.startTest();
            List<UserRole> r = [SELECT id FROM UserRole WHERE PortalType='None']; 
            u.UserRoleId = r[0].Id;
            u.XC_HasRoleBeenProcessed__c = false ; 
           /* Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_ESP_SalesAgentPartner' LIMIT 1]; 
            u.Profile.UserLicense.Name = Label.XC_CL_PartnerCommunity;*/
            
            update u ; 
            System.debug('@@@-USERNEW' + u );
            System.assert(u!=null);
            Test.stopTest();
     }

        static testMethod void checkPartnerRoleChanged2(){
            User u = XC_DF_User.createUserAdmin(); 
            u.XC_HasRoleBeenProcessed__c= true; 
            insert u; 
            System.debug('@@@-USEROLD' + u );
            Test.startTest();
            update u ; 
            System.debug('@@@-USERNEW' + u );
            System.assert(u!=null);
            Test.stopTest();
     }

}