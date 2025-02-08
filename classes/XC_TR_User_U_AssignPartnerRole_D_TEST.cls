/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  23/05/2019 
    * @description XC_TR_User_U_AssignPartnerRole_D_TEST – Test class for XC_TR_User_U_AssignPartnerRole_D
    */ 
    @isTest
public with sharing class XC_TR_User_U_AssignPartnerRole_D_TEST {
     // Test method for getUsers 
     static testMethod void getUsers(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            insert u; 

            System.assert(u!=null);
            Test.stopTest();
     }
}