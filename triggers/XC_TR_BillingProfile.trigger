trigger XC_TR_BillingProfile on NE__Billing_Profile__c(before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_BillingProfile_Handler(), Trigger.operationType,constants.MDT_SKIP_BILLPROFILE);  
}