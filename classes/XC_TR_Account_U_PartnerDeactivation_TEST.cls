/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  06/05/2019 
* @description XC_TR_Account_U_PartnerDeactivation_TEST – Test class for XC_TR_Account_U_PartnerDeactivation
*/

@isTest
private class XC_TR_Account_U_PartnerDeactivation_TEST {
    
    @isTest    
    static void inactivateAccount() {
        List<Account> accountsList = XC_DF_Account.insertPartnerAccounts(1);
        XC_DF_ServiceResource.createServiceResourcesFromAccount(accountsList);
        for(Account accnt :accountsList ){
            accnt.XC_Status__c = Label.XC_CL_Account_StatusInactive;
        }
        System.assertEquals(Label.XC_CL_Account_StatusInactive, accountsList[0].XC_Status__c);
        Test.startTest();
        update accountsList;
        Test.stopTest();
 	} 
    
    @isTest
    static  void activateAccount() {
        List<Account> accountsList = XC_DF_Account.insertPartnerAccounts(1, Label.XC_CL_Account_StatusInactive);
        List<User> userList = new List<User>();
        XC_DF_ServiceResource.createServiceResourcesFromAccount(accountsList, true);
        List<Account> accountsToUpdate = [SELECT Id, (SELECT Id FROM Users) FROM Account];
        List<ServiceResource> serviceResourceList = [SELECT Id FROM ServiceResource];
       	for(Account accnt :accountsToUpdate ){
            accnt.XC_Status__c = Label.XC_CL_Account_StatusActive;
            for(User us : accnt.Users){
                userList.add(us);
            }
        }
        System.assertEquals(Label.XC_CL_Account_StatusActive, accountsToUpdate[0].XC_Status__c);
        Test.startTest();
        update accountsToUpdate;
        Test.stopTest();
    }
    
    @isTest
    static void launchSecondEnqueuble() { 
        List<Account> accountsList = XC_DF_Account.insertPartnerAccounts(1);
        List<User> userList = new List<User>();
        XC_DF_ServiceResource.createServiceResourcesFromAccount(accountsList, true);
        List<Account> accountsToUpdate = [SELECT Id, (SELECT Id FROM Users) FROM Account];
        List<ServiceResource> serviceResourceList = [SELECT Id, RelatedRecord.isActive FROM ServiceResource];
       	for(Account accnt :accountsToUpdate ){
            for(User us : accnt.Users){
                userList.add(us);
            }
        }
        System.assertEquals(1, accountsToUpdate.size());
       	XC_TR_Account_U_PartnerDeactivation.ManageDMLWrapper manageDMLWrapper = new XC_TR_Account_U_PartnerDeactivation.ManageDMLWrapper();
        manageDMLWrapper.listUserToUpdate = userList;
        manageDMLWrapper.listServiceResourceToUpdate = serviceResourceList;
        manageDMLWrapper.listUserToUpdateLater = userList;
        manageDMLWrapper.listServiceResourceToUpdateLater = serviceResourceList;
        Test.startTest();
        System.enqueueJob(new XC_TR_Account_U_PartnerDeactivation.ManageDMLSecondQueue(manageDMLWrapper));
        Test.stopTest();
    }

}