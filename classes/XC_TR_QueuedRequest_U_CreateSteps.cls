/**
 * @File Name          : XC_TR_QueuedRequest_U_CreateSteps.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 11-03-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    27/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_QueuedRequest_U_CreateSteps {


    /**
    * @description get the template and create the steps associated to the queued request, after creation steps are started
    * @author Simone Trenta - strenta@deloitte.it
    * @param listNew 
    * @return void 
    **/
    public static void createQueuedRequestStepsFiltered ( List<XC_QueuedRequest__c> listNew){
        List<XC_QueuedRequest__c> qrToProcess = new List<XC_QueuedRequest__c>();

        for(XC_QueuedRequest__c q : listNew){
            //BEGIN [2021-10-18 :: TP :: Third Party Billing :: New ClientSystem for third parties]
            if( (q.XC_ClientSystem__c == 'ThirdPartyB2C' && q.XC_Status__c == 'Enqueued') || q.XC_Status__c == 'In Error' )
            {
                continue;
            }
            //END [2021-10-18 :: TP :: Third Party Billing :: New ClientSystem for third parties]
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(q.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            String type = fullQRReqBody.Order != null ? fullQRReqBody.Order.OrderType : '';

            if(q.XC_ClientSystem__c == 'CommoditySpainB2C' || (q.XC_ClientSystem__c == 'CommodityItalyB2C' && type == 'Energy Disconnect')){
                return;
            }
            
            qrToProcess.add(q);
        }

        createQueuedRequestSteps(qrToProcess);
    }


    /**
    * @description get the template and create the steps associated to the queued request, after creation steps are started
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param listNew 
    * @return void 
    **/
    public static void createQueuedRequestSteps ( List<XC_QueuedRequest__c> listNew){

        List<XC_CM_QueuedRequestTemplate__mdt> templates = [SELECT Id,DeveloperName,XC_TemplateName__c,XC_ClientSystems__c, XC_Type__c, XC_SubType__c,
        (SELECT XC_FlowAPIName__c,XC_Sequence__c,XC_StepLabel__c,XC_IsCallbackStep__c,XC_CallbackEndpoint__c FROM QueuedRequestTemplateSteps__r) 
        FROM XC_CM_QueuedRequestTemplate__mdt];
        List<XC_QueuedRequest__c> reqsToUpdate = new List<XC_QueuedRequest__c>();//[2021-12-30 :: TP :: Third Party Billing :: No template found management]
        Map<String,string> reqsToUpdateMap = new Map<String,String>();        
        if(!templates.isEmpty()){// && !templates[0].QueuedRequestTemplateSteps__r.isEmpty()){

            List<XC_QueuedRequestStep__c> stepsToInsert = new List<XC_QueuedRequestStep__c>();

            //Mapping templates with requests
            Map<String,List<XC_CM_QueuedRequestTemplate__mdt>> clientSystemTemplateMap = new Map<String,List<XC_CM_QueuedRequestTemplate__mdt>>();

            for(XC_CM_QueuedRequestTemplate__mdt template : templates){
                String [] splittedClients = template.XC_ClientSystems__c.split(';');
                for(String clientSystem : splittedClients){
                    if(!clientSystemTemplateMap.containsKey(clientSystem)){
                        clientSystemTemplateMap.put(clientSystem,new List<XC_CM_QueuedRequestTemplate__mdt>{template});
                    } else {
                        clientSystemTemplateMap.get(clientSystem).add(template);
                    }
                }
            }

            System.Debug('STEP CLIENT SYSTEM MAP:: ' + clientSystemTemplateMap);

            for(XC_QueuedRequest__c req : listNew){

                List<XC_CM_QueuedRequestTemplate__mdt> relatedTemplates = clientSystemTemplateMap.get(req.XC_ClientSystem__c);
                List<XC_CM_QueuedRequestTemplateStep__mdt> relatedTemplatesStep = new List<XC_CM_QueuedRequestTemplateStep__mdt>();

                XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(req.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
                String type = fullQRReqBody.Order != null ? fullQRReqBody.Order.OrderType : '';
                String subType = fullQRReqBody.Order != null ? fullQRReqBody.Order.OrderSubType : '';
                String templateName='';
                for(XC_CM_QueuedRequestTemplate__mdt temp : relatedTemplates){
                    if(String.isBlank(subType)&&temp.XC_Type__c == type){
                        relatedTemplatesStep = temp.QueuedRequestTemplateSteps__r;
                        templateName = temp.XC_TemplateName__c; 
                    } else if(temp.XC_Type__c == type && (temp.XC_SubType__c == subType||temp.XC_SubType__c == '*')){
                        relatedTemplatesStep = temp.QueuedRequestTemplateSteps__r;
                        templateName = temp.XC_TemplateName__c;
                    } else if(String.isBlank(subType)&&String.isBlank(type)&&String.isBlank(temp.XC_SubType__c)&&String.isBlank(temp.XC_Type__c)){
                        relatedTemplatesStep = temp.QueuedRequestTemplateSteps__r;
                        templateName = temp.XC_TemplateName__c;
                    }                                       
                    if(templateName != null && templateName!=''){
                        system.debug('Entro in templateName '+templateName);
                        reqsToUpdateMap.put(req.Id,templateName);
                    }                    
                }

                for(XC_CM_QueuedRequestTemplateStep__mdt templateStep : relatedTemplatesStep){
                    XC_QueuedRequestStep__c step = new XC_QueuedRequestStep__c();
                    step.XC_IsCallbackStep__c = templateStep.XC_IsCallbackStep__c;
                    step.XC_CallbackEndpoint__c = templateStep.XC_CallbackEndpoint__c;
                    step.XC_StepSequence__c = templateStep.XC_Sequence__c;
                    step.XC_FlowAPIName__c = templateStep.XC_FlowAPIName__c;
                    step.XC_QueuedRequest__c = req.Id;
                    step.XC_Status__c = Label.XC_CL_Provisioning_Step_NotStarted;
                    step.XC_StepLabel__c = templateStep.XC_StepLabel__c;
                    stepsToInsert.add(step);
                }

                //BEGIN [2021-12-30 :: TP :: Third Party Billing :: No template found management]
                if(req.XC_ClientSystem__c == 'ThirdPartyB2C' && ( relatedTemplatesStep == null || relatedTemplatesStep.isEmpty() ))
                {
                    req.XC_Status__c = 'In Error';
                    req.XC_ClientSystem__c = String.isNotBlank(fullQRReqBody.Account.PartnerClientSystem)?fullQRReqBody.Account.PartnerClientSystem:req.XC_ClientSystem__c;
                    req.XC_CallBackRequest__c = JSON.serialize(new Map<String, String>{
                        'type' => Label.XC_QR_CL_CallBackType,
                        'transactionId' => req.XC_TransactionId__c,
                        'source' => Label.XC_QR_CL_CallBackSource,
                        'integration_id' => req.XC_IntegrationId__c,
                        'result' => '1',
                        'result_message' => Label.XC_QR_CL_TemplateNotFound
                    });
                    reqsToUpdate.add(req);
                }
                //END [2021-12-30 :: TP :: Third Party Billing :: No template found management]
            }

            System.Debug('NO OF STEPS TO ENQUEUE:: ' + stepsToInsert.size());

            if(!stepsToInsert.isEmpty()){

                List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Sobject.insertListRecords(stepsToInsert);
                Boolean insertResult = false;
                for(XC_UTIL_Sobject.WrapperResult wr : results){
                    insertResult = wr.success;
                }
                //if all inserts are ok, start the steps and update the queued requests status
                if(insertResult){
                    startSteps(stepsToInsert);
                    updateRequestStatus(listNew,reqsToUpdateMap);
                }

            }
            //BEGIN [2021-12-30 :: TP :: Third Party Billing :: No template found management]
            if(!reqsToUpdate.isEmpty())
            {
                XC_UTIL_SObject.updateListRecords(reqsToUpdate);
            }
            //END [2021-12-30 :: TP :: Third Party Billing :: No template found management]
        }

    }

   
    /**
    * @description Start the first step available when the status become "in progress"
    * @author Simone Trenta - strenta@deloitte.it
    * @param mapNew 
    * @param mapOld 
    **/
    public static void startStepOnUpdate(Map<Id,XC_QueuedRequest__c> mapNew,Map<Id,XC_QueuedRequest__c> mapOld){
        Map<Id, XC_QueuedRequest__c> qrToProcess = new Map<id, XC_QueuedRequest__c>([
            SELECT Id, XC_Status__c, XC_ClientSystem__c, XC_RequestBody__c, XC_TransactionId__c, XC_IntegrationId__c, (SELECT Id FROM QueuedRequestSteps__r) 
            FROM XC_QueuedRequest__c
            WHERE Id IN: mapNew.keyset()]
        );//[2021-12-30 :: TP :: Third Party Billing :: No template found management]

        List<XC_QueuedRequest__c> qrList = new List<XC_QueuedRequest__c>();

        List<XC_QueuedRequest__c> temp = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'},mapOld,qrToProcess);
        for(XC_QueuedRequest__c qr : temp){

            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qr.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            String type = fullQRReqBody.Order != null ? fullQRReqBody.Order.OrderType : '';

            if( qr.XC_Status__c == 'In Progress' && (qr.XC_ClientSystem__c == 'CommoditySpainB2C'|| (qr.XC_ClientSystem__c == 'CommodityItalyB2C' && type == 'Energy Disconnect') || qr.XC_ClientSystem__c == 'ThirdPartyB2C' ) && qr.QueuedRequestSteps__r.isEmpty() ){//[2021-10-07 :: TP :: Third Party Billing :: New ClientSystem for third parties]
                qrList.add(qr);
            }
        }

        createQueuedRequestSteps(qrList);
    }


    /**
    * @description start queuedrequeststeps at rest upon creation , starts steps with sequence 1
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param stepsToStart 
    * @return void 
    **/
    private static void startSteps (List<XC_QueuedRequestStep__c> stepsToStart){
        //call util method to start steps
        XC_UTIL_QueuedRequestStep.startStep(stepsToStart);
    }


    /**
    * @description update the status of the requests
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param listNew 
    * @return void 
    **/
    private static void updateRequestStatus(List<XC_QueuedRequest__c> listNew, Map<String,String> reqsToUpdateMap){
        List<XC_QueuedRequest__c> reqsToUpdate = new List<XC_QueuedRequest__c>();
        for(XC_QueuedRequest__c req : listNew){            
            String temaplateName='';
            if(reqsToUpdateMap.containsKey(req.id)) {
                temaplateName = reqsToUpdateMap.get(req.id);
            }
            XC_QueuedRequest__c qr = new XC_QueuedRequest__c(Id = req.Id,XC_Status__c = 'In Progress', XC_TemplateName__c = temaplateName);
            reqsToUpdate.add(qr);
        }
        if(!reqsToUpdate.isEmpty()){
            XC_UTIL_SObject.updateListRecords(reqsToUpdate);
        }
    }

}