/**
* @author Emanuela Cacace - ecacace@deloitte.it || Roberta Cossiga - rcossiga@deloitte.it 
* @date Creation 08/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceResource_U_WorkForEnd_TEST – Test for class XC_TR_ServiceResource_U_WorkingForEndesa 
*/

@isTest
public class XC_TR_ServiceResource_U_WorkForEnd_TEST {
    static testMethod void checkResourceWorkingForEndesa() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);  
        List<ServiceResource> servList =  XC_DF_ServiceResource.createServiceResourcesFromAccount(accList);
        servList[0].XC_WorkingForEndesa__c = false;   
        Test.startTest();
        servList[0].XC_WorkingForEndesa__c = true; 
        update servList;
        System.assertEquals(true, servList[0].XC_WorkingForEndesa__c);
        Test.stopTest();
    }
    
        static testMethod void checkResourceWorkingForEndesa2() { 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);  
        List<ServiceResource> servList =  XC_DF_ServiceResource.createServiceResourcesFromAccount(accList);
        servList[0].XC_WorkingForEndesa__c = false;   
         servList[0].IsActive = true;
        Test.startTest();
        update servList;
        System.assertEquals(false, servList[0].XC_WorkingForEndesa__c);
        Test.stopTest();
    }
}