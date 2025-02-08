/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Creation 27/05/2019
* @description Test Class for XC_UTIL_ExceptionLog
*/
@isTest
private class XC_UTIL_ExceptionLog_TEST {

    @testSetup
    private static void setup() {
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(3);
        insert orderItemList;
        List<NE__OrderItem__c> itemList = [SELECT Id, XC_ZQuoteID__c, NE__ProdId__c FROM NE__OrderItem__c LIMIT 1];  
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String orderItemId = itemList[0].Id;
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(orderItemId);
        insert ps;
    }

    static testMethod void ExceptionTest(){
        XC_Provisioning_Step__c ps = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
        Test.startTest();
        try{
            insert new Contact();
        }catch(Exception e){
            XC_UTIL_ExceptionLog.insertExceptionLog (e);
            XC_UTIL_ExceptionLog.insertExceptionLog (e, ps.Id);
        }
		/*Exception e ;    
        String error  = 'System.DmlException' + e.getMessage();
        XC_ExceptionLog__c exceptionLog = new XC_ExceptionLog__c();
        exceptionLog.XC_MessageException__c = e.getMessage();
        insert exceptionLog;
       
        XC_UTIL_ExceptionLog.insertExceptionLog (e);
        System.assert(e != null);*/
        Test.stopTest();
    }
}