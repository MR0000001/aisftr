/**
 * @File Name          : XC_UTIL_QueuedRequestStep.cls
 * @Description        :
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              :
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 02-09-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    27/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
 * 1.1    16/06/2020  Marco ottaviano -- Added getFirstQueuedRequestStep
**/
public without sharing class XC_UTIL_QueuedRequestStep {

    public static final String COMMODITY_CALLBACK_STEPLABEL = 'Commodity Callback';
    public static final String SKIP_TO_CALLBACK_STATUS = 'Skip To Callback';

    /*Wrapper for process builder that starts the flow*/
    public class QueuedRequestStepPBWrapper{
        @Invocablevariable
        public String currentStepId;
        @InvocableVariable
        public String futureStepsIds;
    }

    /*Previous Step Wrapper*/
    public class PreviousQRSWrapper{
        public XC_QueuedRequestStep__c previousStep;
        public Boolean success = false;
    }

    /**
    * @description start first sequenced steps launching platform events
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020
    * @param stepsToStart
    * @return void
    **/
    public static void startStep(List<XC_QueuedRequestStep__c> stepsToStart){

        List<XC_QueuedRequestStep__c> firstSteps = new List<XC_QueuedRequestStep__c>();
        for(XC_QueuedRequestStep__c step : stepsToStart){
            if(step.XC_Status__c == Label.XC_CL_Provisioning_Step_NotStarted && step.XC_StepSequence__c == 1){
                firstSteps.add(step);
            }
        }

        System.Debug('N OF FIRST STEPS::: ' + firstSteps.size());

        if(!firstSteps.isEmpty()){
            setStepInProgressAndEmitEvent(firstSteps);
        }

    }


    /**
    * @description change the step status and emit the platform event to start the step transaction
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020
    * @param stepsToStart
    * @return void
    **/
    public static void setStepInProgressAndEmitEvent(List<XC_QueuedRequestStep__c> stepsToStart){

        //change step status
        Set<String> stepIds = new Set<String>();
        for(XC_QueuedRequestStep__c step : stepsToStart){
            step.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
            step.XC_ProcessStartedDateTime__c = DateTime.now();
            stepIds.add(step.Id);
        }
        List<XC_UTIL_Sobject.WrapperResult> updateRes = XC_UTIL_Sobject.updateListRecords(stepsToStart);

        System.Debug('STEPS IDS TO BE EMITTED: ' + stepIds.size());

        //publishing platform event if update is successful
        Boolean updateResult = false;
        for(XC_UTIL_Sobject.WrapperResult wr : updateRes){
            updateResult = wr.success;
        }

        if(updateResult){
            emitEvent(stepIds);
        }

    }

    /**
    * @description populate platform event fields extracting the first of the steps that is going to be executed
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020
    * @param stepIds
    * @return void
    **/
    public static void emitEvent(Set<String> stepIds){
        if(!stepIds.isEmpty()){
            List<String> stepIdsList = new List<String>();
            stepIdsList.addAll(stepIds);
            String firstStepId = stepIdsList[0];
            stepIdsList.remove(0);
            String commaStepsIdsString = String.join(stepIdsList,';');

            //launching the first step and enqueue the others
            System.Debug('OTHER EVENTS ' + commaStepsIdsString);

            if(String.isNotBlank(firstStepId)){
                List<XC_QueuedRequestStepEnqueued__e> eventsToEmit = new List<XC_QueuedRequestStepEnqueued__e>();
                XC_QueuedRequestStepEnqueued__e event = new XC_QueuedRequestStepEnqueued__e(
                    XC_StepIdList__c = commaStepsIdsString,
                    XC_StepToExecute__c = firstStepId
                );
                eventsToEmit.add(event);
                Eventbus.publish(eventsToEmit);
            }
        }
    }


    /**
    * @description invoked by process builder to start flow associated to the step
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020
    * @param stepWrappers
    * @return void
    **/
    @InvocableMethod
    public static void executeStepsInvocable(List<QueuedRequestStepPBWrapper> stepWrappers){

        List<String> allStepIds = new List<String>();

        for(QueuedRequestStepPBWrapper pbw : stepWrappers){
            allStepIds.add(pbw.currentStepId);
            if(String.isNotBlank(pbw.futureStepsIds)){
                allStepIds.addAll(pbw.futureStepsIds.split(';'));
            }
        }

        if(!allStepIds.isEmpty()){
            List<XC_QueuedRequestStep__c> stepToExecuteList = XC_UTIL_Sobject.selectAllFields(allStepIds[0]);
            if(stepToExecuteList.size() == 1 && !Test.isRunningTest()){
                //Launch the flow
                Map<String,Object> inputVariables = new Map<String,Object>{
                    'step' => stepToExecuteList[0]
                };
                try{
                    Flow.Interview.createInterview(stepToExecuteList[0].XC_FlowApiName__c,inputVariables).start();
                }catch(Exception e){
                    System.Debug('Exception on enqueuing step flow ' + e.getMessage() + 'TRACE:: ' + e.getStackTraceString());
                }
            }

            allStepIds.remove(0);

            if(!allStepIds.isEmpty()){
                Set<String> idSet = new Set<String>();
                idSet.addAll(allStepIds);
                emitEvent(idSet);
            }

        }

        // for(QueuedRequestStepPBWrapper qrsw : stepWrappers){
        //     String stepToExecuteId = qrsw.currentStepId;
        //     String stepsToEnqueue = qrsw.futureStepsIds;
        //     //check first step
        //     if(String.isNotBlank(stepToExecuteId)){
        //         List<XC_QueuedRequestStep__c> stepToExecuteList = XC_UTIL_Sobject.selectAllFields(stepToExecuteId);
        //         if(stepToExecuteList.size() == 1 && !Test.isRunningTest()){
        //             //Launch the flow
        //             Map<String,Object> inputVariables = new Map<String,Object>{
        //                 'step' => stepToExecuteList[0]
        //             };
        //             try{
        //                 Flow.Interview.createInterview(stepToExecuteList[0].XC_FlowApiName__c,inputVariables).start();
        //             }catch(Exception e){
        //                 System.Debug('Exception on enqueuing step flow ' + e.getMessage() + 'TRACE:: ' + e.getStackTraceString());
        //             }
        //         }
        //     }
        //     //enqueue the others
        //     if(String.isNotBlank(stepsToEnqueue)){
        //         List<String> stepIds = stepsToEnqueue.split(';');
        //         Set<String> idSet = new Set<String>();
        //         idSet.addAll(stepIds);
        //         emitEvent(idSet);
        //     }
        // }

    }


    /**
    * @description returns details about the previous queuedrequest step in a wrapper object
    * @author Francesco Imperioli - fimperioli@deloitte.it | 15/6/2020
    * @param step
    * @return PreviousQRSWrapper
    **/
    public static PreviousQRSWrapper getPreviousStep(XC_QueuedRequestStep__c step){

        PreviousQRSWrapper ps = new PreviousQRSWrapper();

        if(step.XC_StepSequence__c==1 || step.XC_StepSequence__c==null){
            return ps;
        }

        Integer previousSeq = Integer.valueOf(step.XC_StepSequence__c) - 1;

        List<XC_QueuedRequestStep__c> previousStep = [SELECT
        Id,XC_FlowAPIName__c,XC_QueuedRequest__c,XC_Status__c,
        XC_StepLabel__c,XC_ExecutionResponse__c,XC_ErrorMessage__c,XC_StepSequence__c,
        XC_QueuedRequest__r.XC_RequestBody__c,XC_QueuedRequest__r.XC_ClientSystem__c,
        XC_QueuedRequest__r.XC_TransactionId__c,XC_QueuedRequest__r.XC_IntegrationId__c,
        XC_IsCallbackStep__c,XC_CallbackEndpoint__c,XC_RelatedRecordsIds__c, XC_QueuedRequest__r.XC_ParentQueuedRequest__c
        FROM XC_QueuedRequestStep__c
        WHERE XC_QueuedRequest__c = :step.XC_QueuedRequest__c AND XC_StepSequence__c = :previousSeq LIMIT 1];

        ps.success = !previousStep.isEmpty();
        ps.previousStep = !previousStep.isEmpty() ? previousStep[0] : null;

        return ps;

    }


    /**
    * @description returns details about the previous queuedrequest step in a wrapper object
    * @author Marco ottaviano - mottaviano | 16/06/2020
    * @param step
    * @return PreviousQRSWrapper
    **/
    public static PreviousQRSWrapper getFirstQueuedRequestStep(XC_QueuedRequestStep__c step){

        PreviousQRSWrapper ps = new PreviousQRSWrapper();

        if(step.XC_StepSequence__c==null){
            return ps;
        }

        Integer previousSeq = 1;

        List<XC_QueuedRequestStep__c> previousStep = [SELECT
        Id,XC_FlowAPIName__c,XC_QueuedRequest__c,XC_Status__c,
        XC_StepLabel__c,XC_ExecutionResponse__c,XC_ErrorMessage__c,XC_StepSequence__c,
        XC_QueuedRequest__r.XC_RequestBody__c,XC_QueuedRequest__r.XC_ClientSystem__c,
        XC_QueuedRequest__r.XC_TransactionId__c,XC_QueuedRequest__r.XC_IntegrationId__c,
        XC_IsCallbackStep__c,XC_CallbackEndpoint__c, XC_QueuedRequest__r.XC_ParentQueuedRequest__c
        FROM XC_QueuedRequestStep__c
        WHERE XC_QueuedRequest__c = :step.XC_QueuedRequest__c AND XC_StepSequence__c = :previousSeq LIMIT 1];

        ps.success = !previousStep.isEmpty();
        ps.previousStep = !previousStep.isEmpty() ? previousStep[0] : null;

        return ps;

    }


    /**
    * @description get all info of a single step by Id
    * @author Francesco Imperioli - fimperioli@deloitte.it | 15/6/2020
    * @param stepId
    * @return XC_QueuedRequestStep__c
    **/
    public static XC_QueuedRequestStep__c getFullStepInfo(String stepId){

        return [SELECT
        Id,XC_FlowAPIName__c,XC_QueuedRequest__c,XC_Status__c,
        XC_StepLabel__c,XC_ExecutionResponse__c,XC_ErrorMessage__c,XC_StepSequence__c,
        XC_QueuedRequest__r.XC_RequestBody__c,XC_QueuedRequest__r.XC_ClientSystem__c,
        XC_QueuedRequest__r.XC_TransactionId__c,XC_QueuedRequest__r.XC_Status__c,XC_QueuedRequest__r.XC_IntegrationId__c,XC_IsCallbackStep__c,XC_CallbackEndpoint__c,
        XC_QueuedRequest__r.XC_Reason__c, XC_QueuedRequest__r.XC_ValidationStatus__c, XC_QueuedRequest__r.XC_ParentQueuedRequest__c, XC_RelatedRecordsIds__c
        FROM XC_QueuedRequestStep__c
        WHERE Id = :stepId];

    }


    /**
    * @description returns details about the previous queuedrequest steps
    * @author Luisana Rocco - lrocco@deloitte.it | 23/6/2020
    * @param step
    * @return Map<Id,XC_QueuedRequestStep__c>
    **/
    public static Map<Id,XC_QueuedRequestStep__c> getQueuedRequestSteps(XC_QueuedRequestStep__c step, Set<Integer> previousSequences){

        Map<Id,XC_QueuedRequestStep__c> previousSteps = new Map<Id,XC_QueuedRequestStep__c>([SELECT
            Id,XC_FlowAPIName__c,XC_QueuedRequest__c,XC_Status__c,
            XC_StepLabel__c,XC_ExecutionResponse__c,XC_ErrorMessage__c,XC_StepSequence__c,
            XC_QueuedRequest__r.XC_RequestBody__c,XC_QueuedRequest__r.XC_ClientSystem__c,
            XC_QueuedRequest__r.XC_TransactionId__c,XC_QueuedRequest__r.XC_IntegrationId__c,
            XC_IsCallbackStep__c,XC_CallbackEndpoint__c, XC_QueuedRequest__r.XC_ParentQueuedRequest__c
            FROM XC_QueuedRequestStep__c
            WHERE  XC_QueuedRequest__c = :step.XC_QueuedRequest__c AND XC_StepSequence__c IN: previousSequences]);

        return previousSteps;

    }

    /**
    * @description returns the last failed step from the whole QR chain
    * @author Francesco Imperioli - fimperioli@deloitte.it | 3/7/2020
    * @param queuedRequestId
    * @return XC_QueuedRequestStep__c
    **/
    public static PreviousQRSWrapper getLastCompletedKOStep (String queuedRequestId){

        PreviousQRSWrapper ps = new PreviousQRSWrapper();

        List<XC_QueuedRequestStep__c> lastFailedStep = [SELECT
        Id,XC_FlowAPIName__c,XC_QueuedRequest__c,XC_Status__c,
        XC_StepLabel__c,XC_ExecutionResponse__c,XC_ErrorMessage__c,XC_StepSequence__c,
        XC_QueuedRequest__r.XC_RequestBody__c,XC_QueuedRequest__r.XC_ClientSystem__c,
        XC_QueuedRequest__r.XC_TransactionId__c,XC_QueuedRequest__r.XC_Status__c,XC_QueuedRequest__r.XC_IntegrationId__c,
        XC_IsCallbackStep__c,XC_CallbackEndpoint__c, XC_QueuedRequest__r.XC_ParentQueuedRequest__c
        FROM XC_QueuedRequestStep__c
        WHERE XC_QueuedRequest__c = :queuedRequestId AND XC_Status__c = 'Completed KO' ORDER BY XC_StepSequence__c DESC LIMIT 1];

        if(lastFailedStep.isEmpty()){
            ps.success = false;
            return ps;
        }

        ps.success = true;
        ps.previousStep = lastFailedStep[0];

        return  ps;

    }

    /**
    * @description set the status of the subsequent step as 'Skipped', only callback step will be always executed
    * @author Francesco Imperioli - fimperioli@deloitte.it | 3/7/2020
    * @param currentStep
    * @return List<XC_UTIL_Sobject.WrapperResult>
    **/
    public static Boolean skipNotCallbackSteps(XC_QueuedRequestStep__c currentStep){
        return skipNotCallbackSteps(new List<XC_QueuedRequestStep__c>{currentStep});
    }

    /**
    * @description set the status of the subsequent step as 'Skipped', only callback step will be always executed
    * @author Simone Trenta - strenta@deloitte.it
    * @param steps
    * @return List<XC_UTIL_Sobject.WrapperResult>
    **/
    public static Boolean skipNotCallbackSteps(List<XC_QueuedRequestStep__c> steps){

        set<String> qrIds = new set<String>();
        set<String> stepIds = new set<String>();
        Map<id,Decimal> stepSequence = new Map<Id,Decimal>();

        for(XC_QueuedRequestStep__c s:steps){
            qrIds.add(s.XC_QueuedRequest__c);
            stepIds.add(s.id);
            stepSequence.put(s.XC_QueuedRequest__c, s.XC_StepSequence__c);
        }

        List<XC_QueuedRequestStep__c> otherStepList = [
            SELECT Id, XC_Status__c, XC_StepLabel__c, XC_StepSequence__c , XC_QueuedRequest__c
            FROM XC_QueuedRequestStep__c
            WHERE
                XC_QueuedRequest__c IN: qrIds
                AND Id NOT IN: stepIds
                AND XC_StepLabel__c != :COMMODITY_CALLBACK_STEPLABEL
        ];

        List<XC_QueuedRequestStep__c> stepToUpdate = new List<XC_QueuedRequestStep__c>();

        for(XC_QueuedRequestStep__c qrs : otherStepList){
            if(stepSequence.get(qrs.XC_QueuedRequest__c)<qrs.XC_StepSequence__c){
                qrs.XC_Status__c = SKIP_TO_CALLBACK_STATUS;
                stepToUpdate.add(qrs);
            }
        }

        if(!stepToUpdate.isEmpty()){

            XC_UTIL_Sobject.updateListRecords(stepToUpdate);
            return true;

        }else{

            List<XC_QueuedRequestStep__c> callbackStep = [
                SELECT Id,Name,XC_FlowApiName__c,XC_StepSequence__c,XC_Status__c,XC_IsCallbackStep__c,XC_CallbackEndpoint__c
                FROM XC_QueuedRequestStep__c
                WHERE
                    XC_StepLabel__c = :COMMODITY_CALLBACK_STEPLABEL AND XC_QueuedRequest__c IN: qrIds
            ];

            if(!callbackStep.isEmpty()){
                XC_UTIL_QueuedRequestStep.setStepInProgressAndEmitEvent(callbackStep);
            }
            return true;
        }

    }



    /**
    * @description method to create a technical case
    * @author Luisana Rocco - lrocco@deloitte.it | 10-05-2021
    * @param utilMap
    * @return Case
    **/
    public static Case initDisconnectCase(Map<String,Object> utilMap){

        //[DeAv 26/11/2021 TPB-PostSales START]
        String clientSys = String.valueOf(utilMap.get('clientSystem'));
        List<XC_ThirdPartyConfiguration__c> tpbConfList = new List<XC_ThirdPartyConfiguration__c>([SELECT id
                                                                                                   FROM XC_ThirdPartyConfiguration__c 
                                                                                                   WHERE XC_TPBCode__c =: clientSys]);
        
        //initializing case triplet USE TECHNICAL CASE
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = new Map<String, XC_CM_Case_Type_Setting__mdt>();
        XC_CM_Case_Type_Setting__mdt caseMDT = new XC_CM_Case_Type_Setting__mdt();
        if(!tpbConfList.isEmpty()){
            mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_CL_CMD_TPBDisconnect'});
            caseMDT = mapCaseSetting.get('XC_CL_CMD_TPBDisconnect');
        }else{
            mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_UniqueAPIDisconnect});
            caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_UniqueAPIDisconnect);
        }
        //[DeAv 26/11/2021 TPB-PostSales END]
        
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        c.Subject = String.valueOf(utilMap.get('stepId'));
        c.AssetId = String.valueOf(utilMap.get('assetId'));
        c.AccountId = String.valueOf(utilMap.get('accountId'));
        c.XC_LegalEntity__c = String.valueOf(utilMap.get('legalEntity'));
        c.XC_Segment__c = String.valueOf(utilMap.get('segment'));
        return c;
    }

    /**
    * @description populate integration log
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap
    **/
    public static void populateIntegrationLogInfo(Map<String,Object> utilMap){

        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        XC_UTIL_IntegrationLog intLog = (XC_UTIL_IntegrationLog) utilMap.get('intLog');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        String operation = (String) utilMap.get('operation');
        String integrationLogName = (String) utilMap.get('integrationLogName');

        //adding headers
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('ClientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
        mapHeader.put('TransactionID', currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
        mapHeader.put('DateTimeMessage', DateTime.now().format('yyyyMMddHHmmssSSS'));
        mapHeader.put('Operation', operation);
        mapHeader.put('Functionality', operation);
        mapHeader.put('ServerSystem', 'XCustomerB2C');

        //TODO: manage first integration log insert here
        intLog.insertIntegReqInboundLog(integrationLogName, JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
        intLog.setHeader(mapHeader);
        intLog.setTransactionID(mapHeader.get('TransactionID'));
        intLog.setHttpMethod('POST');

    }

    /**
    * @description update step in KO status
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param step
    * @param errorMessage
    **/
    public static void setStepKO(XC_QueuedRequestStep__c step,String errorMessage){
        step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        step.XC_ErrorMessage__c = errorMessage;
    }


    /**
     * manageExternalDocument.
     *
     * @param confId the configuration id
     * @param utilMap the utilMap map
     * @description method to manage the external document from commodity.
    */
    public static boolean manageExternalDocument(String confId, Map<String, Object> utilMap){

        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        List<XC_ExternalDocument__c> externalDocumentToInsert = new List<XC_ExternalDocument__c>();

        for(XC_UTIL_Order.DocumentWrapper extDocs : wrReq.Order.Document){
            if(!String.isBlank(extDocs.ContractUrl)){
                XC_ExternalDocument__c externalDoc = new XC_ExternalDocument__c(XC_Configuration__c = confId, XC_ContractURL__c = extDocs.ContractUrl);
                externalDocumentToInsert.add(externalDoc);
            }
        }

        if(!externalDocumentToInsert.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> insertExtDocList = XC_UTIL_SObject.insertListRecords(externalDocumentToInsert);
            for(XC_UTIL_Sobject.WrapperResult insertExtDoc :insertExtDocList){
                if(!insertExtDoc.success){
                    utilMap.put('ErrorMessage', insertExtDoc.errorMessage);
                    return false;
                }
            }
        }

        return true;
    }


    /**
     * update field on order.
     *
     * @param confId the configuration id
     * @param utilMap the utilMap map
     * @description method to update fields on order.
    */
    public static boolean updateFieldsonOrder(String confId, Map<String, Object> utilMap){

        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        Map<String, Object> mapOrderWrapper = new Map<String,Object>{   'Id' => confId,
                                                                        'XC_CommodityExternalId__c' => wrReq.Order.IntegrationID,
                                                                        'XC_VASContractExtID__c' =>  wrReq.Order.VASContractExtID,
                                                                        'XC_VASContractNumber__c' => wrReq.Order.VASContractNumber,
                                                                        'XC_PartnerContractDelivered__c' => wrReq.Order.PartnerContractDelivered,
                                                                        'XC_PartnerSalesChannel__c' => wrReq.Order.PartnerSalesChannel,
                                                                        'NE__Channel__c' => wrReq.Order.Channel,
                                                                        'XC_Channel__c' => wrReq.Order.Channel
                                                                    };

        NE__Order__c ordToUpdate = new NE__Order__c();
        for(String key : mapOrderWrapper.keySet()){
            if(mapOrderWrapper.get(key) != null){
                ordToUpdate.put(key, mapOrderWrapper.get(key));
            }
        }

        XC_UTIL_Sobject.WrapperResult updateOrderResult = XC_UTIL_Sobject.updateRecord(ordToUpdate);
        if(!updateOrderResult.success){
            utilMap.put('ErrorMessage', updateOrderResult.errorMessage);
            return false;
        }

        return true;
    }
}