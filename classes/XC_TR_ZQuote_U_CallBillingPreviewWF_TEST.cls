/**
* @author dpalamides
* @date 14/10/2020
* @description: classes.XC_UTIL_WOLICreateRMA_TEST
*/

@IsTest
public class XC_TR_ZQuote_U_CallBillingPreviewWF_TEST {
static testMethod void checkIfDenyCreations1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        zqu__Quote__c zqu = new zqu__Quote__c();
        insert zqu;
        List<NE__OrderItem__c> ci = XC_DF_OrderItem.createOrderItems(1);
        ci[0].XC_ZQuoteId__c = zqu.Id;
        insert ci;
    	
    	List<NE__Order__c> ordList = [select id from NE__Order__c];
		zqu.CRMConfiguration__c =  ordList[0].Id;
    	zqu.zqu__Status__c='Sent to Z-Billing';
        zqu.zqu__ZuoraSubscriptionID__c ='89213Test';
    	update zqu;
      	
    	XC_TR_ZQuote_U_CallBillingPreviewWF.callZuoraBillingPreview(new List<zqu__Quote__c>{zqu});
        
        Test.stopTest();
     }
}