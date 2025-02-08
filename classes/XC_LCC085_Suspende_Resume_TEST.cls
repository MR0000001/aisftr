/**
*@author Sara Miozza sara.miozza@nttdata.com 
*@date Creation 15/05/2019
*@description XC_LCC085_Suspende_Resume_TEST - Test class for XC_LCC085_Suspende_Resume
*/

@isTest
public class XC_LCC085_Suspende_Resume_TEST {

    @isTest
    static void getSwitchUtilTest(){
        Test.startTest();
        
        List<Asset> assList1 = XC_DF_Asset.createAssets(1);
        insert assList1;
        String recordId1 = assList1[0].Id;
        XC_UTIL_ResultWrapper resWrap1 =  XC_LCC085_Suspende_Resume.getSwitchUtil(recordId1);
        System.assert(!resWrap1.success);

       
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();       
        insert subscription;
        zqu__Quote__c zQuote = new zqu__Quote__c();
        zQuote.zqu__ZuoraSubscriptionID__c = subscription.Id;
        insert zQuote;   
        NE__Order__c config = new NE__Order__c();
        insert config; 
        NE__OrderItem__c ordItem = new NE__OrderItem__c();
        ordItem.XC_ZQuoteId__c =zQuote.Id;
        ordItem.NE__OrderId__c = config.Id;
        ordItem.NE__Qty__c = 1;
        insert ordItem;
        
        List<Asset> assList2 = XC_DF_Asset.createAssets(1);
        assList2[0].XC_Configuration_Item__c = ordItem.Id;
        assList2[0].Status = Label.XC_CL_Asset_StatusActive;
        insert assList2;
        String recordId2 = assList2[0].Id; 
        XC_UTIL_ResultWrapper resWrap2 =  XC_LCC085_Suspende_Resume.getSwitchUtil(recordId2);
        System.assert( resWrap2.success);

        List<Asset> assList3 = XC_DF_Asset.createAssets(1);
        assList3[0].XC_Configuration_Item__c = ordItem.Id;
        assList3[0].Status = Label.XC_CL_Asset_StatusSuspended;
        insert assList3;
        String recordId3 = assList3[0].Id; 
        XC_UTIL_ResultWrapper resWrap3 =  XC_LCC085_Suspende_Resume.getSwitchUtil(recordId3);
        System.assert( resWrap3.success);
		
        List<Asset> assList4 = XC_DF_Asset.createAssets(1);
        assList4[0].XC_Configuration_Item__c = ordItem.Id;
        assList4[0].Status = Label.XC_CL_Asset_StatusInactive;
        insert assList4;
        String recordId4 = assList4[0].Id; 
        XC_UTIL_ResultWrapper resWrap4 =  XC_LCC085_Suspende_Resume.getSwitchUtil(recordId4);
        System.assert(!resWrap4.success);
	
        Test.stopTest();

    }

}