/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   11-03-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_IN_QRS06_CreateOpportunity {

    public static final Set<String> MANAGED_ERROR_CODES = new Set<String>{'400','500'};


    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }


    @InvocableMethod
    public static void executeOpportunityCreation(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteOpportunityCreation(inputs));
    }

    public class QueueableExecuteOpportunityCreation implements Queueable{

        public List<InputWrapper> inputs;

        public QueueableExecuteOpportunityCreation(List<InputWrapper> inputs){
            this.inputs = inputs;
        }

        public void execute(QueueableContext qc) {
            manageOpportunityCreation(inputs);
        }

    }


    public static void manageOpportunityCreation(List<InputWrapper> inputs){

        System.Savepoint sp;
        if(!Test.isRunningTest()){
            sp = Database.setSavePoint();
        }

        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        Set<Integer> previousSequences = new Set<Integer> {Integer.valueOf(currentStep.XC_StepSequence__c)-1,  Integer.valueOf(currentStep.XC_StepSequence__c)-2};
        Map<Id,XC_QueuedRequestStep__c> previousSteps = XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(currentStep,  previousSequences);

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Opportunity_U.WrapperResponse wrResp = new XC_REST_Opportunity_U.WrapperResponse();
        String logError = '';
        String messageResp = '';

        try{
            XC_REST_Opportunity_U.WrapperRequest wrReq = generatePOSTOpportunityReq(currentStep,previousSteps);

            Map<String,String> mapHeader = new Map<String,String>();
            mapHeader.put('ClientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            mapHeader.put('TransactionID', currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
            mapHeader.put('DateTimeMessage', DateTime.now().format('yyyyMMddHHmmssSSS'));
            mapHeader.put('Operation', 'Create');
            mapHeader.put('Functionality', 'CreateOpportunity');
            mapHeader.put('ServerSystem', 'XCustomerB2C');


            intLog.insertIntegReqInboundLog('AsyncOpportunity', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod('POST');

            XC_UTIL_Integration.WrapperResult validationResult = XC_REST_Opportunity_U.validateCreateRequestOpportunity(mapHeader, wrReq, 'POST');

            if(validationResult.errorFlag){
                wrResp.Result.Message = validationResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                messageResp = JSON.serialize(wrResp,true);
                
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
                currentStep.XC_ErrorMessage__c = validationResult.errorMessage;
                XC_UTIL_Sobject.updateRecord(currentStep); 
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
                return;
            }
			
            // set additional integration log info 
			XC_UTIL_IntegrationLog.LogWrapper logWrapper = new  XC_UTIL_IntegrationLog.LogWrapper();
			logWrapper.accountID = 	wrReq.Opportunity.accountID;
            intLog.setAdditionalInformations(logWrapper);

            XC_REST_Opportunity_U.manageInsert(wrReq, wrResp, mapHeader);

            String respErrorCode = wrResp.Result.ErrorCode;
            messageResp = JSON.serialize(wrResp,true);
            if(respErrorCode != '0'){                
                manageErrors(currentStep,wrResp);
            }else{
                currentStep.XC_ExecutionResponse__c = messageResp;
                currentStep.XC_Status__c = 'Completed OK';
                currentStep.XC_RelatedRecordsIds__c = wrResp.Opportunity.OpportunityID;
            } 
            XC_UTIL_Sobject.updateRecord(currentStep);

        }catch(Exception e){
            XC_UTIL_ExceptionLog.insertExceptionLog(e);
        }finally{
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), messageResp, logError);
        }



    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-03-2020 
    * @param currentStep 
    * @param previousSteps 
    * @return XC_REST_Opportunity_U.WrapperRequest 
    **/
    public static XC_REST_Opportunity_U.WrapperRequest generatePOSTOpportunityReq(XC_QueuedRequestStep__c currentStep, Map<Id,XC_QueuedRequestStep__c> previousSteps){

        XC_REST_Opportunity_U.WrapperRequest result = new XC_REST_Opportunity_U.WrapperRequest();
        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        result.Opportunity = fullQRReqBody.Opportunity;

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAccount;
        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress;
        for(XC_QueuedRequestStep__c previousStep : previousSteps.values()){
            if(Integer.valueOf(previousStep.XC_StepSequence__c) == (Integer.valueOf(currentStep.XC_StepSequence__c) - 2)){
                responseWrPreviousStepAccount = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
            }else if(Integer.valueOf(previousStep.XC_StepSequence__c) == (Integer.valueOf(currentStep.XC_StepSequence__c) - 1)){
                responseWrPreviousStepAddress = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
            }
        }

        String accountId = responseWrPreviousStepAccount.Account.AccountID;
        List<Contact> relatedAccountContact = [SELECT Id FROM Contact WHERE AccountId= :accountId AND XC_PrimaryContact__c = TRUE LIMIT 1];

        result.Opportunity.AccountID = accountId;
        result.Opportunity.ContactID = relatedAccountContact[0].Id;
        result.Opportunity.AddressID = responseWrPreviousStepAddress.Address[0].AddressID;

        return result;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-03-2020 
    * @param currentStep 
    * @param wrResp 
    **/
    private static void manageErrors(XC_QueuedRequestStep__c currentStep, XC_REST_Opportunity_U.WrapperResponse wrResp){

        if(MANAGED_ERROR_CODES.contains(wrResp.Result.ErrorCode)){
            currentStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
            currentStep.XC_ErrorMessage__c = wrResp.Result.Message;

            return;
        }

    }

}