@RestResource(urlMapping='/v1/StartSignResponse')
global with sharing class XC_REST_DigitalSignature {

    @HttpPost
    global static Response startSignResponse(List<Map<String,String>> FileItem) {
        Response res = new Response();
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 
        RestRequest request = RestContext.request;
        Map<String,String> header = request.headers;  
        intLog.insertIntegReqInboundLog('StartSignResponse', JSON.serialize(FileItem));
        intLog.setHeader(header); 
        intLog.setTransactionID(header.get('TransactionID'));
        intLog.setHttpMethod(RestContext.request.httpMethod);

        try {
            String signer_id = FileItem[0].get('signer_id');
            String url_agent = FileItem[0].get('url_agent');
            String url_customer = FileItem[0].get('url_customer');
            String document_name = FileItem[0].get('document_name');
            String document_type = FileItem[0].get('document_type');
            String legal_entity = FileItem[0].get('legal_entity');
            String country = FileItem[0].get('country');
            String signatureType = FileItem[0].get('signature_type');
            String dossier_id = FileItem[0].get('dossier_id').split('_')[0];
            String objId = FileItem[0].get('dossier_id').split('_')[1];

            Boolean skipAgentRecognition =
                    signatureType == Label.XC_CL_ONESHOT_DEVISU_NONQUALIFICATA
                    || signatureType == Label.XC_CL_FEA_OTP_SI_DOC
                    || signatureType == Label.XC_CL_FEA_OTP_NO_DOC_NEW
                    || signatureType == Label.XC_CL_WEBID_ONESHOT;

            Boolean sendCustomerInteraction =
                    signatureType == Label.XC_CL_FEA_OTP_SI_DOC
                    || signatureType == Label.XC_CL_FEA_OTP_NO_DOC_NEW
                    || signatureType == Label.XC_CL_WEBID_ONESHOT;

            String step = skipAgentRecognition ? '2' : '1';

            String objectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(objId);
                XC_DocumentSignature__c doc = new XC_DocumentSignature__c(
                XC_SignerId__c = signer_id,
                XC_Order__c = objectType == 'NE__Order__c'? objId: null,
                XC_Contract__c = objectType == 'Contract' ? objId : null,
                XC_BillingProfile__c = objectType == 'NE__Billing_Profile__c' ? objId : null,
                XC_UrlAgent__c = url_agent,
                XC_UrlCustomer__c = url_customer,
                XC_DocumentName__c = document_name,
                XC_DocumentType__c = document_type,
                XC_LegalEntity__c = legal_entity,
                XC_Country__c = country,
                XC_DossierId__c = dossier_id,
                XC_Step__c = step,
                XC_Case__c = objectType == 'Case'? objId: null,
                XC_WorkOrderLineItem__c = objectType == 'WorkOrderLineItem'? objId: null,
                XC_Signature_Type__c = signatureType,
                XC_StatusDescription__c = step == '1' ? 'Inviato' : ''
            );
            upsert doc XC_DossierId__c;

            if(sendCustomerInteraction || Test.isRunningTest()){
                //send customer interaction
                NE__Order__c order = [SELECT ID,NE__OpportunityId__r.Contact__r.Email, NE__OpportunityId__r.Contact__r.Name, NE__OpportunityId__r.Contact__c
                                        FROM NE__Order__c
                                        WHERE ID =:objId];

                Map<String,Object> emailMap = new Map<String, Object>();
                emailMap.put('orderId', objId);
                emailMap.put('email', order.NE__OpportunityId__r.Contact__r.Email);
                emailMap.put('fullName', order.NE__OpportunityId__r.Contact__r.Name);
                emailMap.put('contactId', order.NE__OpportunityId__r.Contact__c);
                emailMap.put('legalEntity', order.NE__OpportunityId__r.Contact__r.XC_MainLegalEntity__c);
                emailMap.put('additionalInfo1', url_customer);
                emailMap.put('customerType', 'Order_Send_Contract_To_Sign_Email');
                XC_Customer_Interaction__c newCustomerInteraction = XC_UTIL_CustomerInteractionGeneration_U.populateCoreCustomerInteration(emailMap);
                XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.insertRecord(newCustomerInteraction);
                XC_UTIL_Debug.debug(true, 'newEmailForCustomerFromOrders newCustomerInteraction = ' + globalDMLResult);
            }

            emitPlatformEvent(objId);
            res.setResult('0', 'OK');
            intLog.insertIntegRespInboundLog('200', true, JSON.serialize(res), '');

        } catch(Exception e) {
            res.setResult('500', e.getMessage());
            intLog.insertIntegRespInboundLog('500', false, JSON.serialize(res), e.getMessage());

        }
        return res;
    }

    global class Response {
        @testVisible XC_UTIL_Integration.ResultSnakeCase Result = new XC_UTIL_Integration.ResultSnakeCase(); 

        public void setResult(String error_code, String message) {
            this.Result.error_code = error_code;
            this.Result.message = message;
        }
    }

    public static void emitPlatformEvent(String signerId) {
        EventBus.publish(new XC_DigitalSignature__e(XC_SignerId__c = signerId));
    }
}