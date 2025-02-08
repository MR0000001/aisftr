/**
 * @File Name          : XC_IN049_ManageMixedVATBillingBatch.cls
 * @Description        : Change the zuora Billing Batch on current Item customer account
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 07-29-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/3/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_IN049_ManageMixedVATBillingBatch {

    private static final String accountResidentialRtID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }


    /**
    * @description Change The Zuora Customer Account Billing Batch 
    * And setup the old in a new custom field - ADOPTION ITALY
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/3/2020 
    * @param inputs 
    * @return void 
    **/
    @InvocableMethod
    public static void manageMixedVATZuoraBatch(List<InputWrapper> inputs){
        
        //getting the customer Accounts and bplis info
        Map<Id,Map<String,String>> stepCustomerBPLIMap = new Map<Id,Map<String,String>>();
        Set<String> stepsIds = new Set<String>();
        Set<XC_Provisioning_Step__c> stepsToCheck = new Set<XC_Provisioning_Step__c>();
        Map<String,String> bundleStepMap = new Map<String,String>();
        List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();

        for(InputWrapper iw : inputs){
            stepsIds.add(iw.stepid);
        }
        //check mixed VAT Items
        Map<Id,XC_Provisioning_Step__c> stepFieldsMap = new Map<Id,XC_Provisioning_Step__c>([SELECT Id,
        XC_Configuration_Item__c,
        XC_Configuration_Item__r.NE__Bundle_Configuration__c,
        XC_Configuration_Item__r.NE__CatalogItem__r.XC_Mixed_VAT__c,
        XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c,
        XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__r.RecordTypeId,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ZuoraId__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToContactId__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToContactId__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToAddress__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToAddress__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Batch__c
        FROM XC_Provisioning_Step__c WHERE Id IN :stepsIds]);

        for(XC_Provisioning_Step__c step : stepFieldsMap.values()){

            String accountRtId = step.XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__r.RecordTypeId;

            if(step.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Mixed_VAT__c==true &&
                accountRtId == accountResidentialRtID
            ){
                stepsToCheck.add(step);
            }else if(String.isNotBlank(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c) &&
            accountRtId == accountResidentialRtID){
                bundleStepMap.put(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c,step.Id);
            }
        }

        //check on bundles
        for(NE__OrderItem__c oi : [SELECT Id,NE__Bundle_Configuration__c FROM NE__OrderItem__c WHERE NE__Bundle_Configuration__c IN :bundleStepMap.keySet() AND NE__CatalogItem__r.XC_Mixed_VAT__c = true]){
            stepsToCheck.add(stepFieldsMap.get(bundleStepMap.get(oi.NE__Bundle_Configuration__c)));
        }


        if(stepsToCheck.isEmpty()){ // Fix NM-LR [10/05/2020]

            for(String stepId : stepsIds){
                XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = stepId, XC_Status__c = Label.XC_CL_Step_Skipped);
                stepsToUpdate.add(stepToUpdate);
            }

        }else {

            for(XC_Provisioning_Step__c step : stepsToCheck){

                Map<String,String> bpliFieldMap = new Map<String,String>();
                bpliFieldMap.put('billingProfileLineItemId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__c);
                bpliFieldMap.put('zuoraAccountId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ZuoraId__c);
                bpliFieldMap.put('billToId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToContactId__c);
                bpliFieldMap.put('soldToId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToContactId__c);
                bpliFieldMap.put('billAddrId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToAddress__c);
                bpliFieldMap.put('soldAddrId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToAddress__c);
                bpliFieldMap.put('oldBatch',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Batch__c);
                bpliFieldMap.put('stream',step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c);
                bpliFieldMap.put('batch','Batch50');
                //call Zuora
                if(Limits.getCallouts()<Limits.getLimitCallouts()){
                    if(step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Batch__c == 'Batch50'){
                        step.XC_Status__c = Label.XC_CL_Completed_Ok;
                        stepsToUpdate.add(step);
                    }else{
                        CallZuoraQueueable callZuora = new CallZuoraQueueable(step,bpliFieldMap,step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c);
                        System.enqueueJob(callZuora);
                    }
                }else{
                    step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    step.XC_ErrorMessage__c = 'Callout Limit';
                    stepsToUpdate.add(step);
                }
            }
        }

        if(!stepsToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        }


        // for(String stepId : stepsIds){
        //     XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id=stepId);
        //     if(stepCustomerBPLIMap.containsKey(stepId)){
        //         if(stepCustomerBPLIMap.get(stepId).containsKey('zuoraUpdateResult') && stepCustomerBPLIMap.get(stepId).get('zuoraUpdateResult').equalsIgnoreCase('true')){
        //             stepToUpdate.XC_Status__c = Label.XC_CL_Completed_Ok;
        //         }else{
        //             stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        //             stepToUpdate.XC_ErrorMessage__c = stepCustomerBPLIMap.get(stepId).containsKey('zuoraError') ? stepCustomerBPLIMap.get(stepId).get('zuoraError') : ''; 
        //         }
        //     }else{
        //         stepToUpdate.XC_Status__c = Label.XC_CL_Step_Skipped;
        //     }
        //     stepsToUpdate.add(stepToUpdate);
        // }

        // if(!stepsToUpdate.isEmpty()){
        //     XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        // }

        // if(!integrationLogs.isEmpty()){
        //     XC_UTIL_Sobject.insertListRecords(integrationLogs);
        // }

    }

    //call zuora  asynch
    public class CallZuoraQueueable implements Queueable,Database.AllowsCallouts{

            XC_Provisioning_Step__c step;
            Map<String,String> zuoraParams;
            String legalEntity;
    
            public CallZuoraQueueable (XC_Provisioning_Step__c step,Map<String,String> params,String legalEntity){
                this.step = step;
                this.zuoraParams = params;
                this.legalEntity = legalEntity;
            }
    
            public void execute(QueueableContext ctx){

                List<XC_Integration_Log__c> integrationLogs = new List<XC_Integration_Log__c>();
                ZuoraWebService.CreateZuoraAccountResponse zuoraResponse = callZuora(zuoraParams, legalEntity);

                System.Debug('ZUORA RESPONSE::: ' + zuoraResponse);
                if(zuoraResponse!=null){

                    String zuoraResp = zuoraResponse.success;
                    String errorMsg = '';
                    if(!zuoraResponse.success.equalsIgnoreCase('true')){
                        errorMsg = errorMsg + ' ERROR ON ZUORA ';
                        for(ZuoraWebService.Reason errorRes : zuoraResponse.reasons){
                            errorMsg += errorRes.message + ' ';
                        }
                    }
                    if(zuoraResponse.integrationLog!=null){
                        zuoraResponse.integrationLog.XC_Log_IntegrationName__c = 'MIXED VAT BILLING BATCH';
                        integrationLogs.add(zuoraResponse.integrationLog);
                    }

                    step.XC_Status__c = zuoraResp.equalsIgnoreCase('true') ? Label.XC_CL_Completed_Ok : Label.XC_CL_Step_CompletedKO;
                    step.XC_ErrorMessage__c = errorMsg;
                    XC_UTIL_Sobject.updateRecord(step);

                    if(!integrationLogs.isEmpty()){
                        XC_UTIL_Sobject.insertListRecords(integrationLogs);
                    }

                }


            }
    
    }


    /**
    * @description callout to zuora update account method
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/3/2020 
    * @param params 
    * @param legalEntity 
    * @return ZuoraWebService.CreateZuoraAccountResponse 
    **/
    private static ZuoraWebService.CreateZuoraAccountResponse callZuora(Map<String,String> params,String legalEntity){
        ZuoraWebService.CreateZuoraAccountResponse result;
        try{

            String entityName = XC_UTIL_Integration_U.getEntityName(legalEntity);
            ZuoraWebservice zws = new ZuoraWebservice(entityName);
            result = zws.updateZuoraAccount(params);
            return result;

        }catch(Exception e){

            result = new ZuoraWebService.CreateZuoraAccountResponse();
            System.Debug('EXCEPTION ON IN049 CALL TO ZUORA ' + e.getMessage() + ' TRACE:: ' + e.getStackTraceString());
            result.success = 'false';
            ZuoraWebService.Reason errorRes = new ZuoraWebService.Reason();
            errorRes.code = 'Error';
            errorRes.message = e.getMessage() + ' Stack Trace : ' + e.getStackTraceString();
            result.reasons = new List<ZuoraWebService.Reason>();

        }
        return result;
    }


}