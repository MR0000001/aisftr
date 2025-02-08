/**
* @author Marina Ciavarra - mciavarra@deloitte.it
* @date Creation 25/05/2021
* @description XC_SC056_ActivateBillingProfile – Activate BP and BPLI when there is a related active BA 
*/

public with sharing class XC_SC056_ActivateBillingProfile implements Schedulable, Database.Batchable<sObject>  {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC056_ActivateBillingProfile');
    /**
        * @author Marina Ciavarra - mciavarra@deloitte.it
        * @description start
        * @param bc - BatchableContext 
        * @return Database.getQueryLocator
       */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Zuora__CustomerAccount__c.isAccessible()){
            return null;
        }
        String query =  'SELECT Id, XC_BillingProfLineItem_LookUp__c, XC_BillingProfLineItem_LookUp__r.XC_Status__c,  XC_BillingProfLineItem_LookUp__r.XC_CustomerAccount__c,' +
                        ' XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__c,XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__r.XC_Status__c,'+
                        ' otherPaymentMethodType__c, Zuora__Default_Payment_Method__c, Zuora__DefaultPaymentMethod__c' +
                        ' FROM Zuora__CustomerAccount__c ' +
                        ' WHERE XC_AlreadyReprocessed__c =  false' +
                        ' AND XC_BillingProfLineItem_LookUp__r.XC_Status__c = \'Sent To Zuora\'' +
                        ' AND ( otherPaymentMethodType__c != null OR Zuora__Default_Payment_Method__c != null)';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query' + query);              
        return Database.getQueryLocator(query);
    }

    /**
    * @description execute method
    * @param sc - SchedulableContext
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC056_ActivateBillingProfile());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC056_ActivateBillingProfile in execution'); 
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
   */
    public void execute(Database.BatchableContext bc, List<Zuora__CustomerAccount__c> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        List<Zuora__CustomerAccount__c> toUpdateBA = new List<Zuora__CustomerAccount__c>();
        List<NE__Billing_Profile__c> toUpdateBP = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> toUpdateBPLI = new List<XC_BillingProfileLineItem__c>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 

        for(Zuora__CustomerAccount__c ca : scope){
            XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c (Id = ca.XC_BillingProfLineItem_LookUp__c);
            bpli.XC_Status__c = Label.XC_CL_BillingProfileActive;
            bpli.XC_CustomerAccount__c = ca.id;
            toUpdateBPLI.add(bpli);
            NE__Billing_Profile__c bp = new NE__Billing_Profile__c(Id = ca.XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__c);
            bp.XC_Status__c = Label.XC_CL_BillingProfileActive;
            toUpdateBP.add(bp);
            ca.XC_AlreadyReprocessed__c = true;
            toUpdateBA.add(ca);
        }
        
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(toUpdateBP);
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResultBPLI = XC_UTIL_Sobject.updateListRecords(toUpdateBPLI, false);
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResultBA = XC_UTIL_Sobject.updateListRecords(toUpdateBA);
        listWrapperResult.addAll(listWrapperResultBPLI);
        listWrapperResult.addAll(listWrapperResultBA);
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC056_ActivateBillingProfile';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Activate BP and BPLI batch';
                bel.XC_RecordId__c = wr.errorObjectId;
                                    errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC056_ActivateBillingProfile');
    }

}