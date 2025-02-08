@RestResource(urlMapping='/v1/CallbackAgentRecognition')
global with sharing class XC_REST_DigitalSignatureCallback {

    @HttpPost
    global static XC_REST_DigitalSignature.Response callbackPost(List<Map<String,String>> FileItem) {
        XC_REST_DigitalSignature.Response res = new XC_REST_DigitalSignature.Response();
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 
        RestRequest request = RestContext.request;
        Map<String,String> header = request.headers;  
        intLog.insertIntegReqInboundLog('CallbackAgentRecognition', JSON.serialize(FileItem));
        intLog.setHeader(header); 
        intLog.setTransactionID(header.get('TransactionID'));
        intLog.setHttpMethod(RestContext.request.httpMethod);

        //START - federico.manni@accenture.com - CR729
        try {
            Set<String> dossier_ids = new Set<String>();
            Set<XC_DocumentSignature__c> docs = new Set<XC_DocumentSignature__c>();
            String phase;
            String stepNotification;
            for(Map<String,String> item : FileItem){
                String dossier_id = item.get('dossier_id');
                dossier_ids.add(dossier_id);
                phase = item.get('signature_phase');
            }
            List<XC_DocumentSignature__c> listds=[ SELECT Id,XC_WorkOrderLineItem__r.WorkOrder.XC_AssignedResource__r.RelatedRecordId,XC_DocumentSignature__c.XC_DossierId__c, XC_Order__c, XC_WorkOrderLineItem__c, XC_WorkOrderLineItem__r.XC_RequestType__c, XC_WorkOrderLineItem__r.WorkOrderId, XC_WorkOrderLineItem__r.WorkOrder.AccountId, XC_WorkOrderLineItem__r.WorkOrder.Account.Name, XC_WorkOrderLineItem__r.WorkOrder.OwnerId, XC_WorkOrderLineItem__r.WorkOrder.XC_AssignedResource__c, XC_WorkOrderLineItem__r.XC_InternalID__c
                FROM XC_DocumentSignature__c
                WHERE XC_DossierId__c =: dossier_ids];

            Map<String, XC_DocumentSignature__c> mapD = new Map<String, XC_DocumentSignature__c>();
            for(XC_DocumentSignature__c  docsign:listds){
                mapD.put(docsign.XC_DossierId__c,docsign);
            }

            List<String> dossiersIdTemp = new List<String>();
            for(Map<String,String> item : FileItem){
                String company_id = item.get('company_id');
                String dossier_id = item.get('dossier_id');
                String signer_id = item.get('signer_id');
                String task_id = item.get('task_id');
                String task_name = item.get('task_name');
                String status = item.get('status');
                String creation_date = item.get('creation_date');
                String last_activity_date = item.get('last_activity_date');
                String notes = item.get('notes');
                //String signature_phase = item.get('signature_phase');
                String signer_name = item.get('signer_name');
                String signer_surname = item.get('signer_surname');
                //String document_type= item.get('document_type');

                Integer maxSize = 254;
                if(notes != null && notes.length() > 254){
                    notes = notes.substring(0, maxSize);
                }

                XC_DocumentSignature__c doc = new XC_DocumentSignature__c(
                Id = !mapD.values().isEmpty() ? mapD.get(dossier_id).Id : null,
                XC_DossierId__c = dossier_id,
                XC_CompanyId__c = company_id,
                XC_TaskId__c = task_id,
                XC_TaskName__c = task_name,
                XC_Status__c = status,
                XC_CreationDate__c = creation_date,
                XC_LastActivityDate__c = last_activity_date,
                XC_RefuseNotes__c = notes
                );
                
                Boolean addItemToUpdate = true;
                //DeAv 2022.08.02 Added if else condition on WOLI START 
                if(mapD.get(dossier_id).XC_WorkOrderLineItem__c!=null){
                    if(phase == '1' && 'STEP_CLOSED'.equalsIgnoreCase(status)){
                        doc.XC_Step__c = '2';
                        doc.XC_StatusDescription__c = 'Firma Procuratore';
                        stepNotification = '2';
                    }else if(phase == '2' && 'STEP_CLOSED'.equalsIgnoreCase(status)){
                        //addItemToUpdate = false;
                        doc.XC_StatusDescription__c = 'Firma Impresa';
                        stepNotification = '3';
                    }else if(phase == '1' && 'ENVELOPE_REJECTED'.equalsIgnoreCase(status)){
                        doc.XC_Step__c = '4';
                        doc.XC_StatusDescription__c = 'Rifiuto Procuratore';
                        stepNotification = '4';
                    }else if(phase == '2' && 'ENVELOPE_REJECTED'.equalsIgnoreCase(status)){
                        doc.XC_Step__c = '5';
                        doc.XC_StatusDescription__c = 'Rifiuto Impresa';
                        stepNotification = '5';
                    }else if('SIGN_PROCESS_ENDED'.equalsIgnoreCase(status)){
                        //doc.XC_Step__c = '3';
                    }
                }else{
                    doc.XC_Step__c = '2';
                }
                //DeAv 2022.08.02 Added if else condition on WOLI START 
                
                if(addItemToUpdate && !dossiersIdTemp.contains(doc.XC_DossierId__c)){
                    docs.add(doc);
                }
                dossiersIdTemp.add(dossier_id);
            }
             
            if(!docs.isEmpty()){
                List<XC_DocumentSignature__c> docToUpsert = new List<XC_DocumentSignature__c>();
                for(XC_DocumentSignature__c doc : docs){
                    docToUpsert.add(doc);
                }
                //upsert docs XC_DossierId__c;
                upsert docToUpsert XC_DossierId__c;
            }
            
            //sentNotification(mapD, stepNotification);
            
            /* *** OLD SERVICES ***
            String company_id  = FileItem[0].get('company_id');
            String dossier_id  = FileItem[0].get('dossier_id');
            String signer_id  = FileItem[0].get('signer_id');
            String task_id  = FileItem[0].get('task_id');
            String task_name  = FileItem[0].get('task_name');
            String status  = FileItem[0].get('status');
            String creation_date  = FileItem[0].get('creation_date');
            String last_activity_date  = FileItem[0].get('last_activity_date');

            Map<Id, XC_DocumentSignature__c> mapD = new Map<Id, XC_DocumentSignature__c>([
                SELECT Id, XC_Order__c
                FROM XC_DocumentSignature__c
                WHERE XC_DossierId__c =: dossier_id
            ]);

            XC_DocumentSignature__c doc = new XC_DocumentSignature__c(
                Id = !mapD.values().isEmpty() ? mapD.values()[0].Id : null,
                XC_DossierId__c = dossier_id,
                XC_CompanyId__c = company_id,
                XC_TaskId__c = task_id,
                XC_TaskName__c = task_name,
                XC_Status__c = status,

                XC_CreationDate__c = creation_date,
                XC_LastActivityDate__c = last_activity_date,
                XC_Step__c = '2'
            );
            upsert doc XC_DossierId__c;

            */

            //END - federico.manni@accenture.com - CR729

            XC_REST_DigitalSignature.emitPlatformEvent(mapD.values()[0].XC_Order__c);
            res.setResult('0', 'OK');
            intLog.insertIntegRespInboundLog('200', true, JSON.serialize(res), '');
            //DeAv 2022.08.02 Added if condition START
            if(mapD.values()[0].XC_WorkOrderLineItem__c != null){
                sentNotification(mapD, stepNotification);
            }
            //DeAv 2022.08.02 Added if condition END
            
            

        } catch(Exception e) {
            res.setResult('500', e.getMessage());
            intLog.insertIntegRespInboundLog('500', false, JSON.serialize(res), e.getMessage());
        }
        return res;
    }

    //START - federico.manni@accenture.com - CR729
    public static void sentNotification(Map<String, XC_DocumentSignature__c> mapD, String step){

        String requestType = null;
        String accountName = null;
        String signatureStatus = null;
        String targetId=null;
        Set<String> ownerIds = new Set<String>();
        String internalId = null;
        if(mapD.values()[0].XC_WorkOrderLineItem__c != null && mapD.values()[0].XC_WorkOrderLineItem__r.XC_RequestType__c != null){
            requestType = mapD.values()[0].XC_WorkOrderLineItem__r.XC_RequestType__c;
            ownerIds.add(mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder.XC_AssignedResource__r.RelatedRecordId);
        } else {
            requestType = 'Documento di ingaggio';
        }
        if(mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder != null && mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder.Account != null && mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder.Account.Name != null){
            accountName = mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder.Account.Name;
            if(mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder.OwnerId != null){
                ownerIds.add(mapD.values()[0].XC_WorkOrderLineItem__r.WorkOrder.OwnerId);
            }
        }
        if(step == '2') 
            signatureStatus = 'Firma Procuratore';
        if(step == '3')
            signatureStatus = 'Firma Impresa';
        if(step == '4')
            signatureStatus = 'Rifiuto Procuratore';
        if(step == '5')
            signatureStatus = 'Rifiuto Impresa';
        if(mapD.values()[0].XC_WorkOrderLineItem__r.XC_InternalID__c != null){
            internalId = mapD.values()[0].XC_WorkOrderLineItem__r.XC_InternalID__c;
        }
        targetId=mapD.values()[0].XC_WorkOrderLineItem__c;
        XC_TR_GenericNotification.notifyUsers(requestType,accountName,signatureStatus,ownerIds,internalId,targetId);
        updateWoli(mapD,step);
        
    }
    //END - federico.manni@accenture.com - CR729

    //START - federico.manni@accenture.com - CR729
    private static void updateWoli(Map<String, XC_DocumentSignature__c> mapD,String step){
        //TODO Aggiornamento del woli
        List<WorkOrderLineItem> updateWOLI=new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> listwoli=[Select id,XC_RequestType__c,XC_IsRequestInProgress__c,XC_WorkEndDateExtended__c,EndDate,XC_ResumeDate__c,XC_SuspensionStartDate__c,XC_RequestEndDateExtended__c from WorkOrderLineItem where id=:mapD.values()[0].XC_WorkOrderLineItem__c];
        System.debug('@@@@'+listwoli);
        for(WorkOrderLineItem woli:listwoli){  
            //woli.XC_IsRequestInProgress__c=null;
        	if(woli.XC_RequestType__c =='Sospensione' && (step =='4' || step =='5')){
            	woli.Status = 'Completed'; 
                woli.XC_SuspensionStartDate__c=null;
                woli.XC_SuspensionReason__c=null;
                woli.XC_EnelSoleSuspensionNotes__c=null;
                woli.XC_RequestDate__c=null;
        	} 
            if(woli.XC_RequestType__c == 'Ripresa' && step=='2'){
               woli.Status = 'Completed';
                if(woli.XC_WorkEndDateExtended__c!=null){
                    woli.XC_WorkEndDateExtended__c=woli.XC_WorkEndDateExtended__c+(woli.XC_SuspensionStartDate__c.daysBetween(woli.XC_ResumeDate__c));
                   }else{
                    Datetime newEndate=woli.EndDate+(woli.XC_SuspensionStartDate__c.daysBetween(woli.XC_ResumeDate__c));
                    woli.XC_WorkEndDateExtended__c=date.newinstance(newEndate.year(), newEndate.month(), newEndate.day());   
                }
            }
            if(woli.XC_RequestType__c =='Ripresa' && (step=='4' || step=='5')){
                woli.Status = 'Suspended';
                woli.XC_ResumeReason__c=null;
                woli.XC_ResumeDate__c=null;
                woli.XC_EnelSoleResumeNotes__c=null;
                woli.XC_RequestDate__c=null;
            }
            if(woli.XC_RequestType__c =='Proroga' && (step=='4' || step=='5')){
                woli.XC_ExtensionReason__c=null;
                woli.XC_EnelSoleExtensionNotes__c=null;
                woli.XC_RequestEndDateExtended__c=null;
                woli.XC_RequestDate__c=null;
            }
            if(woli.XC_RequestType__c =='Proroga' && (step=='2' || step=='3')){
                woli.XC_WorkEndDateExtended__c = woli.XC_RequestEndDateExtended__c;
            }
            updateWOLI.add(woli);
   		 }
        update updateWOLI;

        for(WorkOrderLineItem woli:updateWOLI){
            woli.XC_IsRequestInProgress__c=null;
        }
        update updateWOLI;
    }
   
    //END - federico.manni@accenture.com - CR729
}