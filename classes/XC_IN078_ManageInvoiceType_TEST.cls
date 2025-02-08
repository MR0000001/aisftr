/**
 * @author Salvatore Scarpato salvatore.scarpato@nttdata.com
 * @date Creation 15/06/2021
 * @description  – XC_IN078_ManageInvoiceType_TEST - Test class for XC_IN078_ManageInvoiceType
 */ 
@isTest
public class XC_IN078_ManageInvoiceType_TEST {
    @TestSetup
    static void setup(){        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
        for(NE__OrderItem__c oi : orderItemList){
            oi.XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        }
        insert orderItemList;
        NE__OrderItem__c ordIt = orderItemList[0];
        NE__OrderItem__c ordIt2 = orderItemList[1];
        List<NE__Product__c> lp = XC_DF_Product.createProducts(1);
        lp[0].Name = 'RFID';
        insert lp;
        ordit.NE__ProdId__c = lp[0].id;
		update ordit;
        List<Opportunity> oppNewList = XC_DF_Opportunity.createOpportunity(2, false);
        Opportunity opp1 = oppNewList[0];
        Opportunity opp2 = oppNewList[1];
        insert opp1;
        insert opp2;
        List<NE__Order__c> orderList = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        orderList[0].NE__OptyId__c = opp2.Id;
        orderList[0].XC_LegalEntity__c = 'EnelXItalia';
        orderList[0].XC_Segment__c = 'B2C';
        orderList[1].NE__OptyId__c = opp1.Id;
        orderList[1].XC_LegalEntity__c = 'EnelXItalia';
        orderList[1].XC_Segment__c = 'B2C';
        update orderList;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        XC_Provisioning_Step__c provisioningStep2 = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Step_Order__c = 1;
        provisioningStep2.XC_Configuration_Item__c = ordIt2.id;
        provisioningStep2.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep2.XC_Step_Order__c = 1;
        stepList.add(provisioningStep);
        stepList.add(provisioningStep2);
        insert stepList;
    }
    
    static testMethod void manageInvoiceTypeWithPrintTEST(){
        List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileList[0].NE__Payment__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        update billingProfileList[0];



        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        XC_BillingProfileLineItem__c bpli = bpliList[0];
        bpli.XC_InvoiceDeliveryPreference__c = 'Print';
        update bpli;
        List<Ne__OrderItem__c> oiList = [SELECT Id FROM Ne__OrderItem__c ];
        for(Ne__OrderItem__c oi :oiList ){
            oi.XC_BillingProfileLineItem__c = bpli.Id;
        }
        update oiList;
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN078_ManageInvoiceType.InputWrapper inw = new XC_IN078_ManageInvoiceType.InputWrapper();
        List<XC_IN078_ManageInvoiceType.InputWrapper> inputWrapperList = new List<XC_IN078_ManageInvoiceType.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN078_ManageInvoiceType.manageInvoiceType(inputWrapperList);
        test.stopTest();
        System.assertEquals(2, stepsList.size());
    }
    
  	static testMethod void manageInvoiceTypeWithoutPrintTEST(){
        /*List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        XC_BillingProfileLineItem__c bpli = bpliList[0];
        bpli.XC_InvoiceDeliveryPreference__c = 'Email';
        List<Ne__OrderItem__c> oiList = [SELECT Id FROM Ne__OrderItem__c ];
        for(Ne__OrderItem__c oi :oiList ){
            oi.XC_BillingProfileLineItem__c = bpli.Id;
        }
        update oiList;*/
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN078_ManageInvoiceType.InputWrapper inw = new XC_IN078_ManageInvoiceType.InputWrapper();
        List<XC_IN078_ManageInvoiceType.InputWrapper> inputWrapperList = new List<XC_IN078_ManageInvoiceType.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN078_ManageInvoiceType.manageInvoiceType(inputWrapperList);
        test.stopTest();
        System.assertEquals(2, stepsList.size());
    }
}