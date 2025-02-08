/**
 * @File Name          : XC_IN050_ManageMixedVATWF.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 07-29-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/3/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_IN050_ManageMixedVATWF {

    private static final String accountResidentialRtID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    /**
    * @description select steps that include a mixed vat confitem and call zuoraworkflow to manage the billing flow
    * @author Francesco Imperioli - fimperioli@deloitte.it | 30/3/2020 
    * @param inputs 
    * @return void 
    **/
    @InvocableMethod
    public static void manageMixedVATZuoraWF(List<InputWrapper> inputs){

        Set<String> stepsIds = new Set<String>();
        Set<String> zQuoteIds = new Set<String>();
        
        for(InputWrapper iw : inputs){
            stepsIds.add(iw.stepid);
        }

        //getting steps infos and fields
        Map<Id,XC_Provisioning_Step__c> stepFieldsMap = new Map<Id,XC_Provisioning_Step__c>([SELECT Id,
        XC_Configuration_Item__c,
        XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c,
        XC_Configuration_Item__r.NE__Bundle_Configuration__c,
        XC_Configuration_Item__r.NE__CatalogItem__r.XC_Mixed_VAT__c,
        XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__r.RecordTypeId,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ZuoraId__c,
        XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c,
        XC_Configuration_Item__r.XC_ZQuoteId__c
        FROM XC_Provisioning_Step__c WHERE Id IN :stepsIds]);

        Map<Id,Boolean> stepWithMixedVAT = checkMixedVAT(stepFieldsMap);

        //getting ZquotesInfo
        for(XC_Provisioning_Step__c step : stepFieldsMap.values()){
            if(stepWithMixedVAT.containsKey(step.Id) && stepWithMixedVAT.get(step.Id)==true){
                zQuoteIds.add(step.XC_Configuration_Item__r.XC_ZQuoteId__c);
            }
        }

        Map<Id,zqu__Quote__c> mapZuoraQuote = new Map<Id,zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionID__c
        FROM zqu__Quote__c
        WHERE Id IN: zQuoteIds]);



        List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();

        for(XC_Provisioning_Step__c step : stepFieldsMap.values()){
            if(stepWithMixedVAT.containsKey(step.Id) && stepWithMixedVAT.get(step.Id)==true){
                //TODO: call to zuora WF
                if(Limits.getCallouts() < Limits.getLimitCallouts()){

                    try{

                        //check subscription id and manage errors
                        if(String.isBlank(step.XC_Configuration_Item__r.XC_ZQuoteId__c)){

                            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                            step.XC_ErrorMessage__c = 'Missing ZQuoteId on OI : ' + step.XC_Configuration_Item__c;
                            stepsToUpdate.add(step);
                            continue;

                        }

                        //building params to call Zuora
                        Map<String,Object> params = new Map<String,Object>();
                        params.put('subscriptionId',mapZuoraQuote.get(step.XC_Configuration_Item__r.XC_ZQuoteId__c).zqu__ZuoraSubscriptionID__c);
                        params.put('zuoraAccountId',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ZuoraId__c);
                        params.put('legalEntity',step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c);
                        params.put('stream',step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c);

                        // Map<String,Object> zuoraResult = callZuoraWF(params);
                        // Boolean success = Boolean.valueOf(zuoraResult.get('success'));
                        // step.XC_Status__c = success ==true ? Label.XC_CL_Completed_Ok : Label.XC_CL_Step_CompletedKO;
                        // step.XC_ErrorMessage__c = success == true  ? '' : String.valueOf(zuoraResult.get('errorMsg'));
                        CallZuoraWFQueueable callZuora = new CallZuoraWFQueueable(step,params);
                        System.enqueueJob(callZuora);

                    }catch(Exception e){
                        step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                        step.XC_ErrorMessage__c = e.getMessage() + ' TRACE : ' + e.getStackTraceString();
                        stepsToUpdate.add(step);
                    }

                }else{
                    step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    stepsToUpdate.add(step);
                }
            }else{
                step.XC_Status__c = Label.XC_CL_Step_Skipped;
                stepsToUpdate.add(step);
            }
        }

        if(!stepsToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        }

    }


    /**
    * @description get mixed vat items from a map of provisioning steps already queried
    * @author Francesco Imperioli - fimperioli@deloitte.it | 30/3/2020 
    * @param stepFieldsMap 
    * @return Map<Id, Boolean> 
    **/
    private static Map<Id,Boolean> checkMixedVAT (Map<Id,XC_Provisioning_Step__c> stepFieldsMap){
        Map<Id,Boolean> result = new Map<Id,Boolean>();
        Map<String,String> bundleStepMap = new Map<String,String>();

        for(XC_Provisioning_Step__c step : stepFieldsMap.values()){

            String accountRtId = step.XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__r.RecordTypeId;


            if(step.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Mixed_VAT__c == true
            && accountRtId == accountResidentialRtID
            ){
                result.put(step.Id,true);
            }else if(String.isNotBlank(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c) && accountRtId == accountResidentialRtID){
                bundleStepMap.put(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c,step.Id);
            }else{
                result.put(step.Id,false);
            }
        }

        if(!bundleStepMap.isEmpty()){
            List<NE__OrderItem__c> bundleItems = [SELECT Id,NE__Bundle_Configuration__c FROM NE__OrderItem__c WHERE 
            NE__Bundle_Configuration__c IN :bundleStepMap.keySet() AND NE__CatalogItem__r.XC_Mixed_VAT__c = true];
            for(NE__OrderItem__c oi : bundleItems){
                result.put(bundleStepMap.get(oi.NE__Bundle_Configuration__c),true);
            }
        }

        return result;
    }

    /**
    * @description get the mixed vat items from a set of provisioning step ids
    * @author Francesco Imperioli - fimperioli@deloitte.it | 30/3/2020 
    * @param stepIds 
    * @return Map<Id, Boolean> 
    **/
    public static Map<Id,Boolean> checkMixedVAT(Set<String> stepIds){

        Map<Id,XC_Provisioning_Step__c> stepFieldsMap = new Map<Id,XC_Provisioning_Step__c>([SELECT Id,
        XC_Configuration_Item__c,
        XC_Configuration_Item__r.NE__Bundle_Configuration__c,
        XC_Configuration_Item__r.NE__CatalogItem__r.XC_Mixed_VAT__c,
        XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__r.RecordTypeId
        FROM XC_Provisioning_Step__c WHERE Id IN :stepIds]);

        Map<Id,Boolean> result = new Map<Id,Boolean>();
        Map<String,String> bundleStepMap = new Map<String,String>();

        for(XC_Provisioning_Step__c step : stepFieldsMap.values()){

            String accountRtId = step.XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__r.RecordTypeId;

            if(step.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Mixed_VAT__c == true && accountRtId == accountResidentialRtID){
                result.put(step.Id,true);
            }else if(String.isNotBlank(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c) && accountRtId == accountResidentialRtID){
                bundleStepMap.put(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c,step.Id);
            }else{
                result.put(step.Id,false);
            }
        }

        if(!bundleStepMap.isEmpty()){
            List<NE__OrderItem__c> bundleItems = [SELECT Id,NE__Bundle_Configuration__c FROM NE__OrderItem__c WHERE 
            NE__Bundle_Configuration__c IN :bundleStepMap.keySet() AND NE__CatalogItem__r.XC_Mixed_VAT__c = true];
            for(NE__OrderItem__c oi : bundleItems){
                result.put(bundleStepMap.get(oi.NE__Bundle_Configuration__c),true);
            }
        }

        return result;

    }

    //call zuora wf asynch
    public class CallZuoraWFQueueable implements Queueable,Database.AllowsCallouts{

            XC_Provisioning_Step__c step;
            Map<String,Object> zuoraParams;
    
            public callZuoraWFQueueable (XC_Provisioning_Step__c step,Map<String,Object> params){
                this.step = step;
                this.zuoraParams = params;
            }
    
            public void execute(QueueableContext ctx){
                //building params to call Zuora
                Map<String,Object> zuoraResult = callZuoraWF(zuoraParams);
                Boolean success = Boolean.valueOf(zuoraResult.get('success'));
                step.XC_Status__c = success ==true ? Label.XC_CL_Completed_Ok : Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = success == true  ? '' : String.valueOf(zuoraResult.get('errorMsg'));
                XC_UTIL_Sobject.updateRecord(step);
            }
    
    }
    

    /**
    * @description call zuora workflow to manage mixed vat products billing strategy
    * @author Francesco Imperioli - fimperioli@deloitte.it | 30/3/2020 
    * @param step 
    * @return Boolean 
    **/
    private static Map<String,Object> callZuoraWF(Map<String,Object> params){
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('success',true);

        XC_REST_MixedVATWF.WrapperRequest req = new XC_REST_MixedVATWF.WrapperRequest();
        req.accountId = String.valueOf(params.get('zuoraAccountId'));
        req.subscriptionId = String.valueOf(params.get('subscriptionId'));
        req.legalEntity = String.valueOf(params.get('legalEntity'));
        req.stream = String.valueOf(params.get('stream'));


        XC_REST_MixedVATWF.WrapperResponse resp =  XC_REST_MixedVATWF.callMixedVATWF(req);
        if(resp.errors!=null && !resp.errors.isEmpty()){
            result.put('success',false);
            String errorMsgs = '';
            for(XC_REST_MixedVATWF.WrapperErrors err : resp.errors){
                errorMsgs += ' Zuora Workflow Error : ' + err.title + ' ' + err.code + ' ' + err.status;
            }
            result.put('errorMsg',errorMsgs);
        }

        System.Debug('RESPONSE RECEIVIED::: ' + resp);

        if(resp.responseLog!=null){
            XC_UTIL_Sobject.insertRecord(resp.responseLog);
        }

        return result;
    }


}