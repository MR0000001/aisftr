/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  23/05/2019 
    * @description XC_TR_User_U_AssignPartnerRole_TEST – Test class for XC_TR_User_U_AssignPartnerRole
    */ 
    @isTest
public with sharing class XC_TR_User_U_AssignPartnerRole_TEST {
     // Test method for assignRoleFromContactType 
     static testMethod void assignRoleFromContactType(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            insert u; 

            System.assert(u!=null);
            Test.stopTest();
     }


}