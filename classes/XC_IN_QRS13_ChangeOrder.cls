/**
* @File Name          : XC_IN_QRS13_ChangeOrder.cls
* @Description        :
* @Author             : Federica Acerra f.acerra@accenture.com 
**/

public without sharing class XC_IN_QRS13_ChangeOrder {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }
    
    @InvocableMethod
    public static void executeChangeOrder(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteChangeOrder(inputs));
    }
    
    public class QueueableExecuteChangeOrder implements Queueable, Database.AllowsCallouts {
        
        private List<InputWrapper> inputs;
        
        public QueueableExecuteChangeOrder(List<InputWrapper> inputs){
            this.inputs = inputs;
        }
        
        public void execute(QueueableContext qc) {
            manageChangeOrder(inputs);
        }
        
    }

    /**
    * @description manages the creation of the change order for the change of price and plain
    * @author  Federica Acerra f.acerra@accenture.com 
    * @param inputs 
    **/
    public static void manageChangeOrder(List<InputWrapper> inputs){
        system.debug('manageChangeOrder start');
        
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
           
            //Retrieve Order JSON Body
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
            XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
            accountWrReq.Account = fullQRReqBody.Account;
            wrReq.Order = fullQRReqBody.Order;
            system.debug('accountWrReq.Account : '+accountWrReq.Account);
            system.debug('XC_LegalEntity__c : '+wrReq.Order.LegalEntity);
            system.debug('segment : '+accountWrReq.Account.Segment);
            system.debug('ClientSystem : '+currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            //prepare integration log  
            Map<String,Object> utilMap = new Map<String,Object>();
            utilMap.put('currentStep', currentStep);
            utilMap.put('OrderType',wrReq.Order.OrderType);
            utilMap.put('OrderSubType',wrReq.Order.OrderSubType);
            utilMap.put('intLog', intLog);
            utilMap.put('wrReq', wrReq);
            utilMap.put('wrResp', wrResp);
            utilMap.put('operation', 'ChangeOrder');
            utilMap.put('integrationLogName', 'AsyncChangeOrder');
            utilMap.put('savePoint', sp);
            utilMap.put('XC_LegalEntity__c', wrReq.Order.LegalEntity);
            utilMap.put('assetId', wrReq.Order.AssetID); 
            utilMap.put('XC_VASContractExtID__c', wrReq.Order.VASContractExtID); 
            utilMap.put('XC_VASContractNumber__c', wrReq.Order.VASContractNumber); 
            utilMap.put('stepId', currentStep.Id);
            utilMap.put('segment',  accountWrReq.Account.Segment);
            utilMap.put('accountId',  wrReq.Order.AccountID); 
            utilMap.put('currentStep', currentStep);
            utilMap.put('ClientSystem',currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            utilMap.put('TransactionID',currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
           
            populateIntegrationLogInfo(currentStep, intLog,  wrReq);
            
           if(String.isBlank(wrReq.Order.AssetID)){
                XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. Missing mandatory field: Order.AssetID');
                utilMap.put('ErrorMessage', 'ERROR. Missing mandatory field: Order.AssetID');
                XC_IN_QRS13_ChangeOrder_U.populateWrRes(utilMap);
                return;
            }
          
            // operations change order
           if(!manageOperationBeforeCO(utilMap) || !manageChangeOrderCreation(utilMap,wrResp)){
                return;
            }
            
            //manage response
            String respErrorCode = wrResp.Result.ErrorCode;
            messageResp = JSON.serialize(wrResp,true);
            if(respErrorCode != '0'){                
                manageKOResult(currentStep, wrResp.Result.Message , utilMap);
            }
            
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
    * @author Federica Acerra f.acerra@accenture.com  
    * @param utilMap
    **/
    public static Boolean manageOperationBeforeCO(Map<String,Object> utilMap){
        system.debug('manageOperationBeforeCO : utilMap '+utilMap);
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');

        //technical case creation
        Case changeOrderCase =  XC_IN_QRS13_ChangeOrder_U.manageCaseCreation(utilMap,new List<String>{'XC_ChangeOrderPrice'}); 
        XC_UTIL_Sobject.WrapperResult caseWrResult = XC_UTIL_Sobject.insertRecord(changeOrderCase);
        if(!caseWrResult.success){
            manageKOResult(currentStep, caseWrResult.errorMessage, utilMap);
            return false;
        }

        utilMap.put('changeOrderCase',changeOrderCase);  
        utilMap.put('changeOrderCaseId',changeOrderCase.id);      
        system.debug('manageOperationBeforeCO : changeOrderCase '+changeOrderCase);
        return true;
    }


    /**
    * @description method to manage the change order
    * @author  Federica Acerra f.acerra@accenture.com  
    * @param utilMap todo
    **/
    public static Boolean manageChangeOrderCreation(Map<String,Object> utilMap,XC_REST_Order_U.WrapperRes wrResp){
        
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest)utilMap.get('wrReq');
        system.debug('manageChangeOrderCreation : utilMap '+utilMap);
        system.debug('manageChangeOrderCreation : wrResp '+wrResp);
        system.debug('manageChangeOrderCreation : wrReq '+wrReq);
        //start change order creation
        XC_IN_QRS13_ChangeOrder_U.manageUpdate(wrReq, wrResp, utilMap);
        //step in KO if cannot create change order
        if(wrResp.Result.ErrorCode != '0'){
            manageKOResult(currentStep, wrResp.Result.Message, utilMap);
            return false;
        }

        return true;
    }

    /**
    * @description util method to manage the Ko result
    * @author Federica Acerra f.acerra@accenture.com  
    * @param currentStep
    * @param errorMessage
    * @param utilMap
    **/
    private static void manageKOResult(XC_QueuedRequestStep__c currentStep, String errorMessage, Map<String,Object> utilMap){

        XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + errorMessage);
        utilMap.put('ErrorMessage', errorMessage);
        XC_IN_QRS13_ChangeOrder_U.populateWrRes(utilMap);
    }
    

    /**
    * @description retieve all discount to be removed
    * @author Federica
    * @param currentStep 
    * @param intLog 
    * @param orderWr 
    **/
    private static void populateIntegrationLogInfo(XC_QueuedRequestStep__c currentStep, XC_UTIL_IntegrationLog intLog, XC_REST_Order_U.WrapperPOSTRequest wrReq){
        //adding headers
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('ClientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
        mapHeader.put('TransactionID', currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
        mapHeader.put('DateTimeMessage', DateTime.now().format('yyyyMMddHHmmssSSS'));
        mapHeader.put('Operation', 'ChangeOrder');
        mapHeader.put('Functionality', 'ChangeOrder');
        mapHeader.put('ServerSystem', 'XCustomerB2C');


        //TODO: manage first integration log insert here
        intLog.insertIntegReqInboundLog('AsyncChangeOrder', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
        intLog.setHeader(mapHeader); 
        intLog.setTransactionID(mapHeader.get('TransactionID'));
        
        // set additional integration log info 
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new  XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.accountID = wrReq.Order.accountID;
        intLog.setAdditionalInformations(logWrapper);

    }

    
}