/**
 * @File Name          : XC_IN_QRS10_UpdatePaymentMethod.cls
 * @Description        :
 * @Author             : Luisana Rocco - lrocco@deloitte.it
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-07-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/05/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
**/
public without sharing class XC_IN_QRS10_UpdatePaymentMethod {



    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }



    @InvocableMethod
    public static void executeUpdatePaymentMethod(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteUpdateMOP(inputs));
    }



    public class QueueableExecuteUpdateMOP implements Queueable, Database.AllowsCallouts{
        private List<InputWrapper> inputs;

        public QueueableExecuteUpdateMOP(List<InputWrapper> inputs){
            this.inputs = inputs;
        }

        public void execute(QueueableContext qc) {
            manageUpdateMOP(inputs);
        }
    }



    public static void manageUpdateMOP(List<InputWrapper> inputs) {
        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        XC_QueuedRequestStep__c previousStep = XC_UTIL_QueuedRequestStep.getPreviousStep(currentStep).previousStep;
        //getting logging infos
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        String logError = '';
        String messageResp = '';

        System.Savepoint beforeInsertSavepoint;
        if(!Test.isRunningTest()){
            beforeInsertSavepoint = Database.setSavepoint();
        }

        String parentQueuedReq = currentStep.XC_QueuedRequest__r.XC_ParentQueuedRequest__c;
        Map<Id, XC_QueuedRequestStep__c>  mapQRStepToUpdate = XC_IN_QRS10_UpdatePaymentMethod_U.getQRStepsToComplete(parentQueuedReq);

        try{

            //adding headers
            Map<String,String> mapHeader = new Map<String,String>();
            mapHeader.put('ClientSystem',currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            mapHeader.put('TransactionID',currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
            mapHeader.put('Operation','INSERT');
            mapHeader.put('Functionality','ASYNCQR');
            mapHeader.put('DateTimeMessage',DateTime.now().format('yyyyMMddHHmmssSSS'));
            mapHeader.put('ServerSystem','XCustomerB2C');

            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);

            intLog.insertIntegReqInboundLog('AsyncUpdateMOP', JSON.serialize(fullQRReqBody,true), currentStep.XC_QueuedRequest__c);
            intLog.setHeader(mapHeader);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod('POST');

            if(!XC_IN_QRS10_UpdatePaymentMethod_U.checkIban(fullQRReqBody.Order.IBAN)){

                Map<String,Object> utilMap = new Map<String,Object>();
                Case c = XC_IN_QRS10_UpdatePaymentMethod_U.createCase(/*fullQRReqBody.BillingProfile[0].BillingProfileID*/ fullQRReqBody.Order.BillingProfIdUpdateMop, utilMap);
                
                XC_UTIL_Sobject.WrapperResult wrRes = (XC_UTIL_Sobject.WrapperResult) utilMap.get('wrRes');
                if(!wrRes.success){
                    messageResp = wrRes.errorMessage;
                    currentStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    currentStep.XC_ErrorMessage__c = messageResp;
                }else{
                    messageResp = 'Customer mop is not valid, change mop will be performed manually, on Xcustomer has been opened case n.'+c.CaseNumber;
                    currentStep.XC_Status__c = 'Skipped';
                    currentStep.XC_ErrorMessage__c = messageResp;
                    currentStep.XC_ExecutionResponse__c = messageResp;
                }

                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, currentStep.XC_Status__c, messageResp);
                //XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, 'Skipped', messageResp);
                intLog.insertIntegRespInboundLog('400', false, messageResp, logError);
                return;
            }

    
            Map<String,Object> updateBPres = XC_IN_QRS10_UpdatePaymentMethod_U.updateBP(/*fullQRReqBody.BillingProfile[0].BillingProfileID*/ fullQRReqBody.Order.BillingProfIdUpdateMop, fullQRReqBody.Order.IBAN); //1st step - update bp to DD
            if(!(Boolean)updateBPres.get('success')) {   

                if(!Test.isRunningTest()){
                    beforeInsertSavepoint = Database.setSavepoint();
                }

                messageResp = 'Error on update Billing Profile';
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ErrorMessage__c = messageResp;
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, Label.XC_CL_Step_CompletedKO, messageResp);
                intLog.insertIntegRespInboundLog('400', false, messageResp, logError);
                return;
            }

            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('currentStep',currentStep);
            inputMap.put('iban',fullQRReqBody.Order.IBAN);
            inputMap.put('bpId',/*fullQRReqBody.BillingProfile[0].BillingProfileID*/ fullQRReqBody.Order.BillingProfIdUpdateMop);
            inputMap.put('fullQRReqBody',fullQRReqBody);
            inputMap.put('mapQRStepToUpdate',mapQRStepToUpdate);
            inputMap.put('updateBPres',updateBPres);
            inputMap.put('intLog',intLog);
            System.enqueueJob(new QueueableExecuteUpdateMOPCallout(inputMap));

        }catch(Exception e){
            logError = e.getMessage() + ' ' + e.getStackTraceString();
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ErrorMessage__c = logError;
            XC_UTIL_Sobject.updateRecord(currentStep);
            XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, currentStep.XC_Status__c, messageResp);
            XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(mapQRStepToUpdate.values());
            intLog.insertIntegRespInboundLog('500', false, messageResp, logError);
        }
    }


    public class QueueableExecuteUpdateMOPCallout implements Queueable, Database.AllowsCallouts{
        private Map<String,Object> inputMap;

        public QueueableExecuteUpdateMOPCallout(Map<String,Object> inputMap){
            this.inputMap = inputMap;
        }

        public void execute(QueueableContext qc) {
            manageUpdateMOPCallout(inputMap);
        }
    }


    private static void manageUpdateMOPCallout(Map<String,Object> inputMap){
        List<XC_Integration_Log__c> intLogList = new List<XC_Integration_Log__c>();
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c)inputMap.get('currentStep');
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest)inputMap.get('fullQRReqBody');
        Map<String,Object> updateBPres = (Map<String,Object>)inputMap.get('updateBPres');
        Map<Id,XC_QueuedRequestStep__c> mapQRStepToUpdate = (Map<Id,XC_QueuedRequestStep__c>)inputMap.get('mapQRStepToUpdate');
        XC_UTIL_IntegrationLog intLog = (XC_UTIL_IntegrationLog)inputMap.get('intLog');
        String iban = (String)inputMap.get('iban');
        String bpId = (String)inputMap.get('bpId');

        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_IN_QRS10_UpdatePaymentMethod_U.callSIA(fullQRReqBody.Account, updateBPres); //2st step - call sia
        XC_REST_PaymentMethodSIA_U.ResponseWrapper wrRes = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();

        try {
            wrRes = (XC_REST_PaymentMethodSIA_U.ResponseWrapper) JSON.deserialize(httpRWr.response.getBody(), XC_REST_PaymentMethodSIA_U.ResponseWrapper.class);
            if(String.isBlank(wrRes.debtorCode)){
                XC_LCC078_ChangePaymentMethod.rollbackBP((Map<String,Object>)updateBPres.get('oldBpInfos'));
                String messageResp = 'Error calling SIA';
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ErrorMessage__c = messageResp;
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, Label.XC_CL_Step_CompletedKO, messageResp);
                intLog.insertIntegRespInboundLog('400', false, messageResp, messageResp);
                return;
            }

        } catch(exception e){
            XC_LCC078_ChangePaymentMethod.rollbackBP((Map<String,Object>)updateBPres.get('oldBpInfos'));
            system.debug('Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString());
            String messageResp = 'Error calling SIA';
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ErrorMessage__c = messageResp;
            XC_UTIL_Sobject.updateRecord(currentStep);
            XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, Label.XC_CL_Step_CompletedKO, messageResp);
            intLog.insertIntegRespInboundLog('400', false, messageResp, messageResp);
            return;
        }

        intLogList.addAll(httpRWr.integrationLog);
        inputMap.put('intLogList',intLogList);

        Map<String,String> paymentMethod = new Map<String,String>();
        paymentMethod.put('Type', 'BankTransfer');
        paymentMethod.put('BankTransferType', 'SEPA');
        paymentMethod.put('BankTransferAccountNumber', wrRes.debtorCode); //debtorCode
        paymentMethod.put('TokenId', wrRes.debtorCode); //debtorCode
        paymentMethod.put('MandateID', (String)updateBPres.get('mandateID')); 
        paymentMethod.put('MandateCreationDate',(updateBPres.get('mandateDate')+'').split(' ')[0]); 
        paymentMethod.put('IBAN', iban); 
        paymentMethod.put('AuthGateway', 'SIA PH SDD'); 

        Map<Id, NE__Billing_Profile__c> bpMap = new  Map<Id, NE__Billing_Profile__c>([
            SELECT id, Name, XC_Segment__c,
                (SELECT Id, XC_ZuoraId__c,XC_LegalEntity__c,XC_BillToContactId__c,XC_BillToAddress__c,XC_SoldToContactId__c,XC_SoldToAddress__c, XC_Status__c
                FROM Billing_Profile_Line_Items__r WHERE (XC_Status__c = 'Active' AND XC_ZuoraId__c != '') OR XC_Status__c = 'Sent To Zuora' )
            FROM NE__Billing_Profile__c
            WHERE id=:bpId LIMIT 1
        ]);

        if(bpMap.values()[0].Billing_Profile_Line_Items__r.isEmpty()){
            XC_LCC078_ChangePaymentMethod.rollbackBP((Map<String,Object>)updateBPres.get('oldBpInfos'));
            String messageResp = 'No Bpli found';
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ErrorMessage__c = messageResp;
            XC_UTIL_Sobject.updateRecord(currentStep);
            XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, Label.XC_CL_Step_CompletedKO, messageResp);
            XC_UTIL_Sobject.insertListRecords((List<XC_Integration_Log__c>)inputMap.get('intLogList'));
            intLog.insertIntegRespInboundLog('400', false, messageResp, messageResp);
            return;
        }

        for(XC_BillingProfileLineItem__c bpli:bpMap.values()[0].Billing_Profile_Line_Items__r){
            if(bpli.XC_Status__c=='Sent To Zuora'){
                XC_LCC078_ChangePaymentMethod.rollbackBP((Map<String,Object>)updateBPres.get('oldBpInfos'));
                String messageResp = 'Bpli waiting for Zuora activation';
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ErrorMessage__c = messageResp;
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, Label.XC_CL_Step_CompletedKO, messageResp);
                XC_UTIL_Sobject.insertListRecords((List<XC_Integration_Log__c>)inputMap.get('intLogList'));
                intLog.insertIntegRespInboundLog('400', false, messageResp, messageResp);
                return;
            }
        }

        inputMap.put('paymentMethod',paymentMethod);
        inputMap.put('billingProf',bpMap.values()[0]);

        updatePaymentMethodZuoraAndLink(inputMap); //3st step - zuoraOperations for each bpli

    }




    private static void updatePaymentMethodZuoraAndLink(Map<String,Object> inputMap){
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c)inputMap.get('currentStep');
        Map<String,String> paymentMethod = (Map<String,String>)inputMap.get('paymentMethod');
        NE__Billing_Profile__c billingProf = (NE__Billing_Profile__c)inputMap.get('billingProf');
        List<XC_Integration_Log__c> logs = (List<XC_Integration_Log__c>)inputMap.get('intLogList');
        Map<Id,XC_QueuedRequestStep__c> mapQRStepToUpdate = (Map<Id,XC_QueuedRequestStep__c>)inputMap.get('mapQRStepToUpdate');
        XC_UTIL_IntegrationLog intLog = (XC_UTIL_IntegrationLog)inputMap.get('intLog');
        Boolean errorFlag = false;
        String messageResp = '';

        for(XC_BillingProfileLineItem__c bpli : billingProf.Billing_Profile_Line_Items__r ){

            if(String.isNotBlank(currentStep.XC_RelatedRecordsIds__c)&&currentStep.XC_RelatedRecordsIds__c.contains(bpli.id)){ //controllo related per escludere bpli gia mandati
                continue;
            }

            paymentMethod.put('AccountId', bpli.XC_ZuoraId__c);
            paymentMethod.put('AccountKey', bpli.XC_ZuoraId__c);
            String entityName = XC_Util_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, billingProf.XC_Segment__c);
            ZuoraWebservice zws = new ZuoraWebservice(entityName);
            ZuoraWebservice.CreatePaymentMethodResponse resp = new ZuoraWebservice.CreatePaymentMethodResponse();

            try {
                resp = zws.updatePaymentMethod(JSON.serialize(paymentMethod)); //3.1 updatePaymentMethod
            } catch(Exception e){
                resp.Success = 'false';
                system.debug('Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString());
            }

            resp.integrationLog.XC_BillingProfileLineItem__c = bpli.Id;
            resp.integrationLog.XC_Log_ClientSystem__c = 'XCustomer';
            resp.integrationLog.XC_Log_ServerSystem__c = 'Zuora';
            logs.add(resp.integrationLog);

            if(String.isNotBlank(resp.Success)  && !resp.Success.equalsIgnoreCase('true')){
                messageResp = 'Error on UpdatePaymentMethod for bpli: '+bpli.id;
                errorFlag = true;
                break;
            }

            Map<String,String> updateParams = new Map<String,String>();
            updateParams.put('zuoraAccountId',bpli.XC_ZuoraId__c);
            updateParams.put('billToId',bpli.XC_BillToContactId__c);
            updateParams.put('soldToId',bpli.XC_SoldToContactId__c);
            updateParams.put('billAddrId',bpli.XC_BillToAddress__c);
            updateParams.put('soldAddrId',bpli.XC_SoldToAddress__c);
            updateParams.put('isCommodityCustomer','No');
            updateParams.put('commodityFrequency','');
            updateParams.put('otherPaymentMethodType','');
            updateParams.put('commodityContractId','');

            if((String.isBlank(bpli.XC_BillToContactId__c)&&String.isBlank(bpli.XC_SoldToContactId__c))||(String.isBlank(bpli.XC_BillToAddress__c)&&String.isBlank(bpli.XC_SoldToAddress__c))){
                messageResp = 'Missing contact or address on bpli: '+bpli.id;
                errorFlag = true;
                break;
            }

            ZuoraWebService.CreateZuoraAccountResponse updateResp = new ZuoraWebService.CreateZuoraAccountResponse();

            try {
                updateResp = zws.updateZuoraAccount(updateParams); //3.2 updateZuoraAccount
            } catch(exception e){
                updateResp.Success = 'false';
                system.debug('Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString());
            }

            updateResp.integrationLog.XC_BillingProfileLineItem__c = bpli.Id;
            updateResp.integrationLog.XC_Log_ClientSystem__c = 'XCustomer';
            updateResp.integrationLog.XC_Log_ServerSystem__c = 'Zuora';
            logs.add(updateResp.integrationLog);

            if(String.isNotBlank(updateResp.Success) && !updateResp.Success.equalsIgnoreCase('true')){
                messageResp = 'Error on UpdateZuoraAccount for bpli: '+bpli.id;
                errorFlag = true;
                break;
            }

            ZuoraWebservice.LinkPaymentMethodToAccountResponse linkResMap = new ZuoraWebservice.LinkPaymentMethodToAccountResponse();

            try{
                linkResMap = zws.linkPaymentMethodToAccountWithGateWay(bpli.XC_ZuoraId__c, resp.Id, 'SIA PH SDD'); //3.3 linkPaymentMethodToAccount
            } catch(exception e){
                linkResMap.Success = 'false';
                system.debug('Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString());
            }

            linkResMap.integrationLog.XC_QueuedRequest__c = currentStep.XC_QueuedRequest__c;
            logs.add(linkResMap.integrationLog);

            if(linkResMap.Success == 'false'){
                messageResp = 'Error on linkPaymentMethodToAccount for bpli: '+bpli.id;
                errorFlag = true;
                break;
            }

            if(String.isBlank(currentStep.XC_RelatedRecordsIds__c)){
                currentStep.XC_RelatedRecordsIds__c = bpli.id;
            } else {
                currentStep.XC_RelatedRecordsIds__c += ','+bpli.id;
            }

        }

        if (errorFlag) {
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ErrorMessage__c = messageResp;
            intLog.insertIntegRespInboundLog('400', false, messageResp, messageResp);
        } else {
            currentStep.XC_Status__c = 'Completed OK';
            intLog.insertIntegRespInboundLog('200', true, messageResp, messageResp);
        }

        XC_UTIL_Sobject.updateRecord(currentStep);
        XC_IN_QRS10_UpdatePaymentMethod_U.updateStepsStatus(mapQRStepToUpdate, currentStep.XC_Status__c, messageResp);
        List<XC_UTIL_Sobject.WrapperResult> lw = XC_UTIL_Sobject.insertListRecords(logs);

        return;
    }



}