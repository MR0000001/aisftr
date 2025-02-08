/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 03-23-2021
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   03-23-2021   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_SC044_UpdateInvoiceNumbersBatch_TEST {

    @TestSetup
    static void setup(){

        Zuora__ZInvoice__c zuoraZInvoice = new Zuora__ZInvoice__c();
        zuoraZInvoice.Zuora__Balance2__c = 3;
        zuoraZInvoice.Zuora__Status__c = 'Posted';
        insert zuoraZInvoice;

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                Zuora__PreviousSubscriptionId__c = '12345',
                                                                Zuora__External_Id__c = '56789',
                                                                Name = 'AS-0000');
        insert sub;
        
        Zuora__InvoiceItem__c invoiceItem = new Zuora__InvoiceItem__c(Zuora__Subscription__c = sub.Id,XC_SubscriptionNumber__c = 'AS-0000', Zuora__Invoice__c = zuoraZInvoice.Id);
        insert invoiceItem;

        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        assetList[0].XC_Product_Type__c = 'Bundle';
        assetList[0].XC_SubscriptionName__c = 'AS-0000';
        assetList[0].XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        assetList[0].XC_BillingModel__c = 'One Shot';
        assetList[0].XC_Segment__c = 'B2C';
        insert assetList;

        System.Debug(JSON.Serialize(assetList[0]));


    }

    @isTest
    static void onBatch(){
        Test.startTest();
            Id batchId = Database.executeBatch(new XC_SC044_UpdateInvoiceNumbersBatch());
        Test.stopTest();
    }


}