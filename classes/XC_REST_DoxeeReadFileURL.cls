/**
 * The Class XC_REST_DoxeeReadFileURL.
 *
 * @author            : 
 * @date Creation     : dd/mm/yyyy
 * @date Modification : 09/05/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Rest Resourse of Doxee
 */

    
@RestResource(urlMapping = '/v1/FileUrl/*')
global without sharing class XC_REST_DoxeeReadFileURL {

        
    /**
     * Do post.
     *
     * @description method to send a request for read a document With Doxee
     */
    @HttpPost
    global static void doPost() {
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = '';

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_DoxeeReadFileURL_W.WrapperResponse wrResp = new XC_REST_DoxeeReadFileURL_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();

        try {
            mapHeader = request.headers;
            msgRequest =  request.requestbody.tostring();
            intLog.insertIntegReqInboundLog('DoxeeReadFileURL', msgRequest);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = (XC_REST_DoxeeReadFileURL_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_DoxeeReadFileURL_W.WrapperRequest.class);

            //VALIDATE REQUEST FILEITEM DOXEE
            XC_UTIL_Integration.Result validateResult = XC_REST_DoxeeReadFileURL_U.validateRequest(mapHeader, wrReq);

            if(validateResult.ErrorCode == '400'){
                wrResp.Result.Message = 'ERROR. ' + validateResult.message;
                wrResp.Result.ErrorCode = validateResult.ErrorCode;
				logError = 'ERROR. ' + validateResult.message;
            } else {
                
                Map<String, Case> mapDocIdCase = createDocCaseInvoice(wrReq.FileItem);       // new
                wrResp = XC_REST_DoxeeReadFileURL_U.createDocCustomerInteraction(wrReq.FileItem, mapDocIdCase);   // new   
                //wrResp = XC_REST_DoxeeReadFileURL_U.createDocCustomerInteraction(wrReq.FileItem); //(wrReq.FileItem, mapDocIdCase);
                XC_REST_DoxeeReadFileURL_U.createLeadDocument(wrReq.FileItem);
                XC_REST_DoxeeReadFileURL_U.createDocumentURL(wrReq.FileItem);
            }

        } catch(Exception e ){

            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            wrResp.Result.Message = 'INTERNAL ERROR'+logError;
            wrResp.Result.ErrorCode = '500';
            system.debug('El error es: ' + logError);
        
        } finally {

            if(wrResp.Result.ErrorCode != '0'){
                Database.rollback(beforeInsertSavepoint);
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.LogError;
                }
            }

            wrResp.Result.logError = null; 
            msgResponse =  JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);

            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }else{
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;
        }
    }


    /**
     * **********************************************************************************************************************.
     *
     * @author      : Antonio Paez apaez@ayesa.com - Alejandro Martin amartinc@ayesa.com
     * @param fileList the file list
     * @return Map (fileId, Case)
     * @Date        : 31/07/2019
     * @description : Method to create Cases when category is Invoice
     * ***********************************************************************************************************************
     */
    private static Map<String, Case> createDocCaseInvoice(List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileList) {
        Map<String, Case> mapResult = new Map<String, Case>();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> invoiceFileList = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        List<Case> caseList = new List<Case>();
        String typeCase = Label.XC_CL_InvoiceCreateCase;
        Map<Id,XC_CM_Case_Type_Setting__mdt> mdtMap = new Map<Id,XC_CM_Case_Type_Setting__mdt>([
            SELECT id, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Status__c, XC_Priority__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c, XC_Resolution__c, XC_Result__c, XC_Origin__c   
            FROM XC_CM_Case_Type_Setting__mdt 
            WHERE DeveloperName = :typeCase
        ]);
        XC_CM_Case_Type_Setting__mdt mdtType = new XC_CM_Case_Type_Setting__mdt();
        if(mdtMap.values().isEmpty()){
            system.debug('Not data found for metadata XC_CM_Case_Type_Setting__mdt for data' + Label.XC_CL_InvoiceCreateCase);
            return mapResult;
        } else {
            mdtType = mdtMap.values()[0];
        }
        List<String> accountIdList = new List<String>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile fileOne: fileList){
            system.debug('The Category is ' + fileOne.Category);
            system.debug('The ObjectType is ' + fileOne.ObjectType);
            if(fileOne.Category == 'SF_INVOICE' && fileOne.ObjectType =='ACCOUNT'){
                accountIdList.add(fileOne.ObjectID);
                system.debug('Inside for fileList');
                invoiceFileList.add(fileOne);
            } 
        }
        Map<String, Contact> mapAccContact = primaryContact(accountIdList);
              

        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile fileOne: invoiceFileList){
            Case caseObj = XC_UTIL_Case.initCaseFromCaseSettings(mdtType);
            //caseObj.Origin = 'CAN001';
            caseObj.AccountId=fileOne.ObjectID;
            caseObj.ContactId = mapAccContact.get(fileOne.ObjectID).id;
            caseObj.XC_LegalEntity__c = mapAccContact.get(fileOne.ObjectID).XC_MainLegalEntity__c;
            //caseObj.CaseRemarks__c =  mdtType.XC_CaseRemarks__c;
            caseObj.CaseRemarks__c = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(mdtType, mapAccContact.get(fileOne.ObjectID).XC_MainLegalEntity__c);
            caseObj.XC_Resolution__c = mdtType.XC_Resolution__c;
            caseObj.XC_Result__c = mdtType.XC_Result__c;
            caseList.add(caseobj);
            
            mapResult.put(fileOne.DocumentID, caseObj);
        }
  
        XC_UTIL_Sobject.insertListRecords(caseList);

        return mapResult;
    }
    
    /**
     * **********************************************************************************************************************.
     *
     * @author      : Antonio Paez apaez@ayesa.com - Alejandro Martin amartinc@ayesa.com
     * @param accountIdList
     * @return Map (AccountId, Contact)
     * @Date        : 31/07/2019
     * @description : Method to find the primary contact
     * ***********************************************************************************************************************
     */
    private static Map<String, Contact> primaryContact(List<String> accountIdList) {
        Map<String, Contact> mapAccountContact = new Map<String, Contact>();
        Map<Id,Contact> conMap = new Map<Id,Contact>([
            SELECT id, name,AccountId, Account.name, XC_PrimaryContact__c, XC_ContactPhone__c, XC_MainLegalEntity__c 
            FROM Contact WHERE AccountId in :accountIdList and XC_PrimaryContact__c =true]);
        List<Contact> contactList = conMap.values();
        for(Contact cont : contactList){
            mapAccountContact.put(cont.AccountId, cont);
        }
		return mapAccountContact;
    }

}