/**
* @File Name          : XC_IN_QRS12_ChangeOwnership.cls
* @Description        : 
* @Author             : Luisana Rocco - lrocco@deloitte.it
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    04/10/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
**/
public without sharing class XC_IN_QRS12_ChangeOwnership {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }
    
    @InvocableMethod
    public static void executeChangeOwnership(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteChangeOwnership(inputs));
    }
    
    public class QueueableExecuteChangeOwnership implements Queueable, Database.AllowsCallouts {
        
        private List<InputWrapper> inputs;
        
        public QueueableExecuteChangeOwnership(List<InputWrapper> inputs){
            this.inputs = inputs;
        }
        
        public void execute(QueueableContext qc) {
            manageChangeOwnership(inputs);
        }
        
    }


    /**
    * @description manages the creation of the change order for the change of ownership
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param inputs 
    **/
    public static void manageChangeOwnership(List<InputWrapper> inputs){
        
        
        //Setting a savepoint
        Savepoint sp = Database.setSavePoint();
        
        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        String logError = '';
        String messageResp = '';
        
        try{
            
            // Retrieve previous steps 
            Set<Integer> previousSequences = new Set<Integer> {Integer.valueOf(currentStep.XC_StepSequence__c)-1,  Integer.valueOf(currentStep.XC_StepSequence__c)-2};
            Map<Id,XC_QueuedRequestStep__c> previousSteps = XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(currentStep,  previousSequences);

            //Retrieve Order JSON Body
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
            wrReq.Order = fullQRReqBody.Order;
            
            //prepare integration log  
            Map<String,Object> utilMap = new Map<String,Object>();
            utilMap.put('currentStep', currentStep);
            utilMap.put('intLog', intLog);
            utilMap.put('wrReq', wrReq);
            utilMap.put('wrResp', wrResp);
            utilMap.put('operation', 'CreateChangeOfOwnership');
            utilMap.put('integrationLogName', 'AsyncChangeOfOwnership' );
            XC_UTIL_QueuedRequestStep.populateIntegrationLogInfo(utilMap);

            utilMap.put('savePoint', sp);
            utilMap.put('assetId', wrReq.Order.AssetID); 
            utilMap.put('stepId', currentStep.Id);
            utilMap.put('legalEntity', wrReq.Order.LegalEntity);
            utilMap.put('channel', wrReq.Order.Channel);
            utilMap.put('previousSteps',previousSteps);
            utilMap.put('accountId',  wrReq.Order.AccountID); // Former Account ID


            if(String.isBlank(wrReq.Order.ChangeOwnerReason)){
                XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. Missing mandatory field: Order.ChangeOwnerReason');
                utilMap.put('ErrorMessage', 'ERROR. Missing mandatory field: Order.ChangeOwnerReason');
                XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
                return;
            }

            if(!Test.isRunningTest()) {
                // operations before change order
                if(!manageOperationBeforeCO(utilMap) || !manageChangeOrderCreation(utilMap) || !manageOperationAfterCO(utilMap)){
                    return;
                }
            }

            String changeOrderId = (String)utilMap.get('changeOrderId');
            wrResp.Result.ErrorCode = '0';
            wrResp.Result.Message = 'Operation completed successfully';
            wrResp.Order = new XC_UTIL_Order.OrderIFWrapper();
            wrResp.Order.OrderID = changeOrderId;
            wrResp.Order.OrderItem = null;
            
            // close the step
            currentStep.XC_Status__c = 'Completed OK';
            currentStep.XC_RelatedRecordsIds__c = changeOrderId;
            currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
            XC_UTIL_Sobject.WrapperResult updateQRSResult = XC_UTIL_Sobject.updateRecord(currentStep);
            if(!updateQRSResult.success){
                manageKOResult(currentStep, updateQRSResult.errorMessage, utilMap);
                return;
            }

            //autostart provisioning
            XC_UTIL_NextStepOrderToProvisioning.firstNextStep(changeOrderId);

        }catch(Exception e){
            logError = e.getMessage() + ' ' + e.getStackTraceString();
            system.debug(loggingLevel.finest, logError);
            XC_UTIL_QueuedRequestStep.setStepKO(currentStep,'INTERNAL ERROR. ' );
            wrResp.Order = new XC_UTIL_Order.OrderIFWrapper();
            wrResp.Result.Message = 'INTERNAL ERROR. '; 
            wrResp.Result.ErrorCode = '500';
        }finally{
            
            if(currentStep.XC_Status__c==Label.XC_CL_Step_CompletedKO){
                if(!Test.isRunningTest()) {
                    Database.rollback(sp);
                }
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            }
            
            logError = (String.isBlank(logError)) ? wrResp.Result.logError : logError;
            wrResp.Result.logError = null;
            messageResp = JSON.serialize(wrResp,true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), messageResp, logError);
        }
    }


    /**
    * @description method to manage the operations before change order
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap
    **/
    public static Boolean manageOperationBeforeCO(Map<String,Object> utilMap){

        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest)utilMap.get('wrReq');

        //get util infomation
        if(!XC_IN_QRS12_ChangeOwnership_U.getUtilInfo(utilMap)){
            XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + (String)utilMap.get('ErrorMessage'));
            XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
            return false;
        }

        
        //technical case creation
        Case changeOrderCase = XC_UTIL_QueuedRequestStep.initDisconnectCase(utilMap); 
        XC_UTIL_Sobject.WrapperResult caseWrResult = XC_UTIL_Sobject.insertRecord(changeOrderCase);
        if(!caseWrResult.success){
            manageKOResult(currentStep, caseWrResult.errorMessage, utilMap);
            return false;
        }

        utilMap.put('changeOrderCase',changeOrderCase);

        // getAssetInfo
        XC_IN_QRS12_ChangeOwnership_U.getAssetInfo(utilMap);
        if(((Map<Id,Asset>)utilMap.get('mapAsset')).isEmpty()){
            manageKOResult(currentStep, 'Asset not found with id: '  + wrReq.Order.AssetID, utilMap);
            return false;
        }

        //Check before ChangeOrder
        if(!XC_IN_QRS12_ChangeOwnership_U.checkBeforeChangeOrder(utilMap)){
            if(!String.isBlank((String)utilMap.get('CaseNumberMessage'))){
                // Delete technical Case
                XC_UTIL_Sobject.deleteRecord(changeOrderCase); // Check??
                //Skip Step 
                currentStep.XC_Status__c = 'Skipped';
                currentStep.XC_ErrorMessage__c =  (String)utilMap.get('ErrorMessage') + ' ' + (String)utilMap.get('CaseNumberMessage');
                currentStep.XC_ExecutionResponse__c = (String)utilMap.get('ErrorMessage') + ' ' + (String)utilMap.get('CaseNumberMessage');
                XC_UTIL_Sobject.WrapperResult updateQRSResult = XC_UTIL_Sobject.updateRecord(currentStep);
                if(!updateQRSResult.success){
                    manageKOResult(currentStep, updateQRSResult.errorMessage, utilMap);
                    return false;
                }

                return false;
            }
            XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + (String)utilMap.get('ErrorMessage'));
            XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
            return false;
        }
        
        return true;
    }



    /**
    * @description method to manage the change order
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap
    **/
    public static boolean manageChangeOrderCreation(Map<String,Object> utilMap){
        
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest)utilMap.get('wrReq');
        
        //start change order creation
            
        XC_UTIL_ResultWrapper changeOrderCreationWr =  XC_LCC073_U_DisconnectAsset.changeOrderAsset(wrReq.Order.AssetID, wrReq.Order.OrderSubType, ((Case)utilMap.get('changeOrderCase')).Id);
        //step in KO if cannot create change order
        if(!changeOrderCreationWr.success){
            manageKOResult(currentStep, changeOrderCreationWr.resultMessage, utilMap);
            return false;
        }

        utilMap.put('changeOrderId', changeOrderCreationWr.recordId);

        return true;
    }


    /**
    * @description method to manage the operations after change order
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap
    **/
    public static Boolean manageOperationAfterCO(Map<String,Object> utilMap){

        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest)utilMap.get('wrReq');

        //populate info for change ownership
        // NB. Type = ChangeOwnerReason; Reason = ChangeOwnerType
        XC_UTIL_ResultWrapper setChangeOrderParameters = XC_LCC142_ChangeOfOwnershipParam.changeOwnerOnOrder((String)utilMap.get('changeOrderId'), (String)utilMap.get('accountIdNew'), wrReq.Order.ChangeOwnerType, wrReq.Order.ChangeOwnerReason);
        if(!setChangeOrderParameters.success){
            manageKOResult(currentStep, setChangeOrderParameters.resultMessage, utilMap);
            
            return false;

        }

        // Add BPLI on Order 
        
        if(!XC_IN_QRS12_ChangeOwnership_U.selectBPLI(utilMap)){
            XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' +setChangeOrderParameters.resultMessage);
            XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
            return false;
        }

        // Update Order to set IntegrationID
        if(!String.isBlank(wrReq.Order.IntegrationID) || !String.isBlank(wrReq.Order.VASContractExtID) || !String.isBlank(wrReq.Order.PartnerSalesChannel)){

            if(!XC_UTIL_QueuedRequestStep.updateFieldsonOrder((String)utilMap.get('changeOrderId'),  utilMap)){
                XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + (String)utilMap.get('ErrorMessage'));
                XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
                return false;
            }
        }

        //add external document
        if(wrReq.Order.Document != null && !wrReq.Order.Document.isEmpty()){
            if(!XC_UTIL_QueuedRequestStep.manageExternalDocument((String)utilMap.get('changeOrderId'), utilMap)){
                XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + (String)utilMap.get('ErrorMessage'));
                XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
                return false;
            }
        }
        
        return true;
    }


    /**
    * @description util method to manage the Ko result
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param currentStep
    * @param errorMessage
    * @param utilMap
    **/
    private static void manageKOResult (XC_QueuedRequestStep__c currentStep, String errorMessage, Map<String,Object>utilMap){

        XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + errorMessage);
        utilMap.put('ErrorMessage', errorMessage);
        XC_IN_QRS12_ChangeOwnership_U.populateWrRes(utilMap);
    }

}