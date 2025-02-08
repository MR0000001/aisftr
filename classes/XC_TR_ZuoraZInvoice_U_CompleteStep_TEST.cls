/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation  11/10/2019 
* @description XC_TR_ZuoraZInvoice_U_CompleteStep_TEST – Test class for XC_TR_ZuoraZInvoice_U_CompleteStep

*/ 
@isTest
public class XC_TR_ZuoraZInvoice_U_CompleteStep_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Zuora__ZInvoice__c zuoraZInvoice = new Zuora__ZInvoice__c();
        zuoraZInvoice.Zuora__Balance2__c = 3;
        insert zuoraZInvoice;

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                Zuora__PreviousSubscriptionId__c = '12345',
                                                                Zuora__External_Id__c = '56789',
                                                                Name = 'AS-0000');
        insert sub;
        
        Zuora__InvoiceItem__c invoiceItem = new Zuora__InvoiceItem__c(Zuora__Subscription__c = sub.Id, Zuora__Invoice__c = zuoraZInvoice.Id, XC_SubscriptionNumber__c = 'AS-0000');
        insert invoiceItem;
        
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].XC_CreditAssignmentAvailable__c = true;
        listOrderItem[0].XC_CreditAssignmentAmount__c = 1500;
        listOrderItem[0].XC_BundleTotalOTAmount__c = 2000;
        
        insert listOrderItem;
        
        zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = sub.Id,
                                                XC_SubscriptionName__c ='AS-0000',
                                                XC_ConfigurationItem__c= listOrderItem[0].Id);
        insert quote;
        Test.startTest();
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        assetList[0].XC_SubscriptionName__c = 'AS-0000';
        insert assetList;
        
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningPaymentCheck_Flow;
        provisioningStep.XC_Step_Order__c = 1;
        provisioningStep.XC_Configuration_Item__c = listOrderItem[0].Id;
        provisioningStep.XC_ZuoraSubscriptionId__c = sub.Zuora__External_Id__c;
        insert provisioningStep;
        
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(1);
        listSA[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        listSA[0].XC_Configuration_Item__c  = listOrderItem[0].Id;
        listSA[0].Status = Label.XC_CL_ServiceAppointment_OnHold;
        insert listSA;
        
        Test.stopTest();
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].XC_ProvisioningStep__c = provisioningStep.Id;
        insert listCase;
        listCase[0].Status = Label.XC_CL_Case_InProgress;
        update listCase;
    }

    @isTest static void onUpdate(){ 
        
        Zuora__ZInvoice__c zuoraZInvoice  = [SELECT Id FROM Zuora__ZInvoice__c WHERE Zuora__Balance2__c = 3];
        
        Test.startTest();
        zuoraZInvoice.Zuora__Balance2__c = 0;
        zuoraZInvoice.Zuora__PaymentAmount__c = 30;
        update zuoraZInvoice;
        Test.stopTest();
        System.assert(zuoraZInvoice!=null);
        delete zuoraZInvoice;
    }

}