/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  08/12/2020 
* @description XC_UTIL_Flow_U_TEST – Test class for XC_UTIL_Flow_U
*/ 
@isTest
public class XC_UTIL_Flow_U_TEST {
    @TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfList[0];
        List<XC_BillingProfileLineItem__c> bpli = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1];
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c ordItem : orderItems){
            ordItem.XC_BillingProfileLineItem__c = bpli[0].Id;
            ordItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
            ordItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
    }
    
    static testMethod void startConga() {
        XC_UTIL_Flow_U.InputWrapper wrapper = new XC_UTIL_Flow_U.InputWrapper();
        NE__OrderItem__c orderItem = [SELECT Id, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        String forConga = 'launchConga#-#' + orderItem.Id;
        wrapper.operationRecordToExecuteId = forConga;            
        wrapper.operationRecordsToEnqueueId = forConga;
        XC_UTIL_Flow_U.executeFlowAndEnqueueSteps(new List<XC_UTIL_Flow_U.InputWrapper>{wrapper});
    }
    
    static testMethod void startProvisioning() {
        XC_UTIL_Flow_U.InputWrapper wrapper = new XC_UTIL_Flow_U.InputWrapper();
        NE__OrderItem__c orderItem = [SELECT Id, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        NE__Order__c orderToUpdate = new NE__Order__c(Id = orderItem.NE__OrderId__c, XC_Segment__c = 'B2C', XC_LegalEntity__c = 'EndesaX');
        XC_UTIL_Sobject.updateRecord(orderToUpdate);
        String forConga = 'launchProvisioning#-#' + orderItem.NE__OrderId__c;
        wrapper.operationRecordToExecuteId = forConga;            
        wrapper.operationRecordsToEnqueueId = forConga;
        XC_UTIL_Flow_U.executeFlowAndEnqueueSteps(new List<XC_UTIL_Flow_U.InputWrapper>{wrapper});
    }
}