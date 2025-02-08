/**
 * @File Name          : XC_IN_QRS05_CommodityCallback.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 11-04-2020
 * @Modification Log   : 
 * @TestClass          : 
 * Ver       Date            Author      		    Modification
 * 1.0    02/07/2020   Marco Ottaviano - mottaviano@deloitte.it     Initial Version
**/


public without sharing class XC_IN_QRS05_CommodityCallback {

    public static final Set<String> FILTERED_CLIENTSYSTEM = new Set<String>{
        'COMMODITYSPAINB2C'
    };

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }


     /**
    * @description send a request to commodity system in order to track the completed execution of the whole async flow
    * @author Marco Ottaviano mottaviano@deloitte.it
    * @param inputs 
    * @return void 
    **/
    @InvocableMethod
    public static void executeCommodityCallBack(List<InputWrapper> inputs) {
        System.enqueueJob(new QueueableExecuteCommodityCallBack(inputs));
    }


    public class QueueableExecuteCommodityCallBack implements Queueable,Database.AllowsCallouts{

        private List<InputWrapper> inputs;

        public QueueableExecuteCommodityCallBack(List<InputWrapper> inputs){
            this.inputs = inputs;
        }

        public void execute(QueueableContext context){
            InputWrapper iw = inputs[0];
            XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
            XC_QueuedRequestStep__c previousStep = XC_UTIL_QueuedRequestStep.getPreviousStep(currentStep).previousStep;

            //generating the request
            //if the full QR is already in error, get the last completed KO step to generate the request
            XC_REST_OrderChargerCallback.OrderCallbackRequest reqWr;
            XC_QueuedRequestStep__c step;
            if(currentStep.XC_QueuedRequest__r.XC_Status__c.equalsIgnoreCase('In Error')){
                //getting last completed KO step
                XC_UTIL_QueuedRequestStep.PreviousQRSWrapper lastFailedStep = XC_UTIL_QueuedRequestStep.getLastCompletedKOStep(currentStep.XC_QueuedRequest__c);
                step = lastFailedStep.previousStep;
            }else{
                step = previousStep;
            }

            reqWr = generateWrapperOrderCharge(step);
            //[DeAv 28/12/2021 TPB gestione result OK START]
            XC_QueuedRequest__c queuedReq = getQueuedRequestByStep(step);
            if(!queuedReq.XC_CallbackRequested__c && '0'.equalsIgnoreCase(reqWr.result)){
                reqWr.result_message = 'Operation completed successfully';
            }
            //[DeAv 28/12/2021 TPB gestione result OK END]
            //Store callback request 
            Integer callbackLen = Schema.SObjectType.XC_QueuedRequestStep__c.fields.XC_CallbackRequest__c.getLength();
            currentStep.XC_CallbackRequest__c = ((JSON.Serialize(reqWr)).length() > callbackLen) ? (JSON.Serialize(reqWr)).substring(0, callbackLen - 1) : (JSON.Serialize(reqWr, true));

            //Begin EA EnelX 27/09/2021 
            //XC_QueuedRequest__c queuedReq = getQueuedRequestByStep(step); [DeAv 28/12/2021 TPB gestione result OK]
            XC_REST_OrderChargerCallback.OrderCallbackResponse wcallBackResponse = new  XC_REST_OrderChargerCallback.OrderCallbackResponse();
            wcallBackResponse.success=true;
            System.debug('XC_IN_QRS05_CommodityCallback  field XC_CallbackRequested__c : '+queuedReq.XC_CallbackRequested__c);
            if(!queuedReq.XC_CallbackRequested__c){
                queuedReq.XC_CallbackRequest__c = currentStep.XC_CallbackRequest__c;
                //queuedReq.XC_Status__c= 'Completed';
                //currentStep.XC_Status__c = 'Completed OK';
                //XC_UTIL_Sobject.updateRecord(currentStep);
                System.debug('XC_IN_QRS05_CommodityCallback  field XC_CallbackRequest__c : '+queuedReq.XC_CallbackRequest__c);
                //[DeAv 06/12/2021 TPB Fix START]
                XC_UTIL_Sobject.updateRecord(queuedReq);
                //[DeAv 06/12/2021 TPB Fix END]
                manageResponse(wcallBackResponse,currentStep);
            }
            else{
                //XC_REST_OrderChargerCallback.OrderCallbackResponse wcallBackResponse=XC_REST_OrderChargerCallback.sendCallback(reqWr, step.XC_QueuedRequest__r.XC_ClientSystem__c,currentStep.XC_CallbackEndpoint__c);
                wcallBackResponse=XC_REST_OrderChargerCallback.sendCallback(reqWr, step.XC_QueuedRequest__r.XC_ClientSystem__c,currentStep.XC_CallbackEndpoint__c);
                System.debug('wcallBackResponse: ' + wcallBackResponse);
                manageResponse(wcallBackResponse,currentStep);
            }
            //End EA EnelX
        }

    }



    /**
    * @description generate request that will be sent to commodity system as a callback response
    * @author Francesco Imperioli - fimperioli@deloitte.it | 3/7/2020 
    * @param currentStep 
    * @param previousStep 
    * @return XC_REST_OrderChargerCallback.OrderCallbackRequest 
    **/
    private static XC_REST_OrderChargerCallback.OrderCallbackRequest generateWrapperOrderCharge(XC_QueuedRequestStep__c step) {

        Map<String,String> callbackInfos = getMapCallbackInfos(step);


        XC_REST_OrderChargerCallback.OrderCallbackRequest wReq = new XC_REST_OrderChargerCallback.OrderCallbackRequest();
        wReq.source = Label.XC_QR_CL_CallBackSource;
        wReq.type =Label.XC_QR_CL_CallBackType;
        wReq.transactionId = step.XC_QueuedRequest__r.XC_TransactionId__c;
                
        //if(!String.isBlank(step.XC_QueuedRequest__r.XC_clientSystem__c) && FILTERED_CLIENTSYSTEM.contains((step.XC_QueuedRequest__r.XC_clientSystem__c).toUppercase())){
            wReq.result_message = callbackInfos.containsKey('descr') ? callbackInfos.get('descr') : ((step.XC_StepLabel__c == Label.XC_CL_QRS_GetAsset && !String.isBlank(step.XC_ExecutionResponse__c) && step.XC_ExecutionResponse__c.containsIgnoreCase('case n.')) ? step.XC_ExecutionResponse__c  : ''); 
            wReq.result = callbackInfos.containsKey('code') ? callbackInfos.get('code') : '0';
        /*}else{
            wReq.esito = callbackInfos.get('result');
            wReq.descrizione =  callbackInfos.containsKey('descr') ? callbackInfos.get('descr') : ''; 
            wReq.codice = callbackInfos.containsKey('code') ? callbackInfos.get('code') : '0';
        }*/
        
        if(step.XC_QueuedRequest__r.XC_clientSystem__c == 'CommodityItalyB2B'){
            wreq.lead_id = step.XC_QueuedRequest__r.XC_IntegrationId__c;
            wreq.opportunity_id = callbackInfos.get('result').equalsIgnoreCase('OK')/*wreq.esito.equalsIgnoreCase('OK')*/ ? step.XC_RelatedRecordsIds__c : '';
        } else{
            wReq.integration_id = step.XC_QueuedRequest__r.XC_IntegrationId__c;
        }

        return wReq;
    }


    /**
    * @description manage the commodity sistem response to the callback sent
    * @author Marco Ottaviano mottaviano@deloitte.it
    * @param wcallBackResponse
    * @param currentStep
    * @return void 
    **/
    private static void manageResponse(XC_REST_OrderChargerCallback.OrderCallbackResponse wcallBackResponse,XC_QueuedRequestStep__c currentStep) {
        if(wcallBackResponse.success == null){
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ErrorMessage__c = 'Invalid Server Response';
        } else{
            if(wcallBackResponse.success) {
                currentStep.XC_Status__c = 'Completed OK';
            } else {
               currentStep.XC_Status__c = 'Completed KO';
               currentStep.XC_ErrorMessage__c = wcallBackResponse.errors;
            }
        }
        XC_UTIL_Sobject.updateRecord(currentStep);
    }


    /**
    * @description manages field mapping for commodity callback request
    * @author Francesco Imperioli - fimperioli@deloitte.it | 3/7/2020 
    * @param step 
    * @return Map<String, String> 
    **/
    private static Map<String,String> getMapCallbackInfos(XC_QueuedRequestStep__c step){
        Map<String,String> result = new Map<String,String>();

        result.put('result',step.XC_Status__c == 'Completed OK' ? 'OK' : 'KO');
        if(step.XC_Status__c!='Completed OK'){
            result.put('descr',step.XC_ErrorMessage__c);
            result.put('code','1'); //TODO: fix this and check error management issues
        }
        return result;
    }


    /**
    * @description manages field mapping for commodity callback request
    * @author Elio Adami - elio.adami@accenture.com | 28/09/2021 
    * @param XC_QueuedRequestStep__c step 
    * @return XC_QueuedRequest__c 
    **/
    public static XC_QueuedRequest__c getQueuedRequestByStep(XC_QueuedRequestStep__c step){

        List<XC_QueuedRequest__c> queueReq = [
            SELECT Id,OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, 
			LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, XC_RequestBody__c,
			XC_Status__c, XC_ClientSystem__c, XC_QueuedRequestSteps__c, XC_QueuedRequestCompletedSteps__c,
			XC_TransactionId__c, XC_QueuedRequestKOSteps__c, XC_IntegrationId__c, XC_ValidationStatus__c,
			XC_Reason__c, XC_IdempotencyToken__c, XC_ParentQueuedRequest__c, XC_SkipTheWait__c,
			XC_MasterOfUpdateMOP__c, XC_CallbackRequested__c, XC_BulkJobId__c
            FROM XC_QueuedRequest__c
			WHERE Id = :step.XC_QueuedRequest__c LIMIT 1];

        if(!queueReq.isEmpty()){
			return queueReq[0];
		}
		else{
			return null;
		} 
	}


}