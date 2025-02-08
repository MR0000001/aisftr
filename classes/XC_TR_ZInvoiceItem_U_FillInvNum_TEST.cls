/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-25-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-25-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_TR_ZInvoiceItem_U_FillInvNum_TEST {

    @TestSetup
    static void setup(){

        //creating asset,confitem,provisioning step
        List<NE__OrderItem__c> ois = XC_DF_OrderItem.createOrderItems(2);
        insert ois[0];
        ois[1].XC_Product_Type__c = 'Equipment';
        ois[1].NE__Bundle_Configuration__c = ois[0].Id;
        insert ois[1];

        List<Asset> assets = XC_DF_Asset.createAssets(1);
        assets[0].XC_Configuration_Item__c = ois[1].Id;
        assets[0].XC_SubscriptionName__c = 'AS000TST';
        assets[0].XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot;
        assets[0].XC_Product_Type__c = 'Equipment';
        insert assets;

        XC_Provisioning_Step__c waitInvStep = XC_DF_ProvisioningStep.createProvisioningStep(ois[1].Id);
        waitInvStep.XC_StepLabel__c = 'Wait Invoice';
        insert waitInvStep;



        
    }

    @isTest
    static void testInvoiceUpdate(){

        Asset relatedAsset = [SELECT Id,XC_SubscriptionName__c FROM Asset LIMIT 1];

        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c(Zuora__Status__c = 'Draft');
        insert invoice;

        Zuora__InvoiceItem__c invItem = new Zuora__InvoiceItem__c(
            Zuora__Invoice__c = invoice.Id,
            XC_SubscriptionNumber__c = relatedAsset.XC_SubscriptionName__c
        );
        insert invItem;

        Test.startTest();
            invoice.Zuora__Status__c = 'Posted';
            update invoice;
        Test.stopTest();
    }

}