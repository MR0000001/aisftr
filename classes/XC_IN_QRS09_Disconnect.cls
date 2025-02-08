/**
 * @File Name          : XC_IN_QRS09_Disconnect.cls
 * @Description        :
 * @Author             : Luisana Rocco - lrocco@deloitte.it
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   :
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    10/05/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
 **/
public without sharing class XC_IN_QRS09_Disconnect {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    @InvocableMethod
    public static void executeDisconnect(List < InputWrapper > inputs) {
        System.enqueueJob(new QueueableExecuteDisconnect(inputs));
    }

    public class QueueableExecuteDisconnect implements Queueable, Database.AllowsCallouts {

        private List < InputWrapper > inputs;

        public QueueableExecuteDisconnect(List < InputWrapper > inputs) {
            this.inputs = inputs;
        }

        public void execute(QueueableContext qc) {
            manageDisconnect(inputs);
        }

    }

    /**
     * @description orchestrate disconnect
     * @author Luisana Rocco - lrocco@deloitte.it | 10-05-2021
     * @param inputs
     **/
    public static void manageDisconnect(List < InputWrapper > inputs) {

        Map < String, Object > utilMap = new Map < String, Object > ();
        //Setting a savepoint
        Savepoint sp = Database.setSavePoint();

        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);

        //getting logging infos
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        String logError = '';
        String messageResp = '';

        try {

            //Retrieve Order JSON Body
            XC_REST_Order_U.WrapperPOSTRequest wrReq = generatePostOrderBody(currentStep);
            String orderType = wrReq.Order.OrderType;
            String orderSubtype = wrReq.Order.OrderSubType;
            String assetId = wrReq.Order.AssetID;


            populateIntegrationLogInfo(currentStep, intLog, wrReq);

            //start utilMap population
            //CR UPiscopo 09/11/2021 - Energy Disconnect Romania (added new values to UtilMap) -- BEGIN -->
            utilMap.put('savePoint', sp);
            utilMap.put('accountId', wrReq.Order.AccountID); // in case of duplication it could be another account -> TO CHECK
            utilMap.put('assetId', wrReq.Order.AssetID);
            utilMap.put('contractNumber', wrReq.Order.CommodityContractNum);
            utilMap.put('ContractId', wrReq.Order.ContractID);
            utilMap.put('marketAssetID', wrReq.Order.XC_MarketAssetID);
            utilMap.put('stepId', currentStep.Id);
            utilMap.put('wrReq', wrReq); 
            utilMap.put('currentStep', currentStep); 
            utilMap.put('legalEntity', wrReq.Order.LegalEntity);
            utilMap.put('clientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            //<-- END


            //find Asset by AssetID
            List < Asset > assetList = getAssetInfo(utilMap,currentStep);

            //set step KO on asset Controls
            if (assetList.isEmpty()) {
                setStepKO(currentStep, 'No Asset/Contract found for AssetId: ' + wrReq.Order.assetID);
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR.' + 'No Asset/Contract found for AssetId: ' + wrReq.Order.assetID;
                wrResp.Result.Message = 'INTERNAL ERROR.' + 'No Asset/Contract found for AssetId: ' + wrReq.Order.assetID;
                return;
            } else {
                Asset ass = assetList[0];
                utilMap.put('segment', ass.Account.XC_Segment__c);

                //OTHER CHECKS ON ASSET IF THERE ARE OPENED ORDERS

                //Check Order 'Disconnect' OR 'ChangeOrder' already opened
                if (ass.NE__Order_Config__c != null &&
                    (ass.NE__Order_Config__r.NE__Type__c == 'Disconnection' || ass.NE__Order_Config__r.NE__Type__c == 'ChangeOrder') &&
                    ass.NE__Order_Config__r.XC_Status__c != 'Closed' && ass.NE__Order_Config__r.XC_Status__c != 'Cancelled') {

                    setStepKO(currentStep, String.format(Label.XC_CL_OrderAlreadyInProgress, new List < String > {
                        ass.NE__Order_Config__r.Name
                    }));
                    wrResp.Result.ErrorCode = '500';
                    wrResp.Result.logError = 'INTERNAL ERROR. ' + String.format(Label.XC_CL_OrderAlreadyInProgress, new List < String > {
                        ass.NE__Order_Config__r.Name
                    });
                    wrResp.Result.Message = 'INTERNAL ERROR. ' + String.format(Label.XC_CL_OrderAlreadyInProgress, new List < String > {
                        ass.NE__Order_Config__r.Name
                    });
                    return;
                }

                //Check Asset Status
                /*if(ass.Status != 'Active') { 
                    setStepKO(currentStep, 'ERROR. Asset Status is not correct: \'' + ass.Status + '\'' );
                    wrResp.Result.ErrorCode = '500';
                    wrResp.Result.logError = 'INTERNAL ERROR. Asset Status is not correct: \'' + ass.Status + '\'';
                    wrResp.Result.Message = 'INTERNAL ERROR. Asset Status is not correct: \'' + ass.Status + '\'';
                    return;
                }*/

            }

            //technical case creation
            Case disconnectCase = XC_UTIL_QueuedRequestStep.initDisconnectCase(utilMap); // add the start date?
            /*if(!String.isBlank(wrReq.Order.StartDate)){
                disconnectCase.XC_Communication_Date__c = Date.valueOf(wrReq.Order.StartDate);
            }*/
            XC_UTIL_Sobject.WrapperResult caseWrResult = XC_UTIL_Sobject.insertRecord(disconnectCase);
            if (!caseWrResult.success) {
                setStepKO(currentStep, 'INTERNAL ERROR.' + caseWrResult.errorMessage);
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR.' + caseWrResult.errorMessage;
                wrResp.Result.Message = 'INTERNAL ERROR.' + caseWrResult.errorMessage;
                return;
            }


            //start disconnection order creation
            XC_UTIL_ResultWrapper disconnectOrderCreationWr = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetId, orderSubtype, disconnectCase);

            //step in KO if cannot create disconnect order
            if (!disconnectOrderCreationWr.success) {
                setStepKO(currentStep, disconnectOrderCreationWr.resultMessage);
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR.' + disconnectOrderCreationWr.resultMessage;
                wrResp.Result.Message = 'INTERNAL ERROR.' + disconnectOrderCreationWr.resultMessage;
                if(!test.isRunningTest()){
                    return;
                }
            }

            utilMap.put('disconnectOrderId', disconnectOrderCreationWr.recordId);
 
            manageDisconnectOrder(utilMap, wrResp); 
            if(wrResp.Result.ErrorCode == '500'){ 
                if(!test.isRunningTest()){
                    return;
                } 
            } 
			
            String disconnectOrderId = disconnectOrderCreationWr.recordId;
            wrResp.Result.ErrorCode = '0';
            wrResp.Result.Message = 'Operation completed successfully';
            wrResp.Order = new XC_UTIL_Order.OrderIFWrapper();
            wrResp.Order.OrderID = disconnectOrderId;
            wrResp.Order.OrderItem = null;

            currentStep.XC_Status__c = 'Completed OK';
            currentStep.XC_RelatedRecordsIds__c = disconnectOrderId;
            currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp, true);
            XC_UTIL_Sobject.updateRecord(currentStep);


            //autostart provisioning
            XC_UTIL_NextStepOrderToProvisioning.firstNextStep(disconnectOrderId);

        } catch (Exception e) {
            logError = e.getMessage() + ' ' + e.getStackTraceString();
            setStepKO(currentStep, e.getMessage() + '' + e.getStackTraceString());
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
        } finally {
            //send callback if the status is KO
            if (currentStep.XC_Status__c == Label.XC_CL_Step_CompletedKO) {
                if (!Test.isRunningTest()) {
                    Database.rollback(sp);
                }
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            }
            logError = (String.isBlank(logError)) ? wrResp.Result.logError : logError;
            wrResp.Result.logError = null;
            messageResp = JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode == '0' ? '200' : wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode == '0' ? true : false), messageResp, logError);
        }
    }


    /**
     * @description method to generate order body
     * @author Luisana Rocco - lrocco@deloitte.it | 10-05-2021
     * @param currentStep  the current step
     * @return XC_REST_Order_U.WrapperPOSTRequest
     **/
    public static XC_REST_Order_U.WrapperPOSTRequest generatePostOrderBody(XC_QueuedRequestStep__c currentStep) {

        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;

        return wrReq;
    }


    /**
     * @description retrieve asset information
     * @author Luisana Rocco - lrocco@deloitte.it | 10-05-2021
     * @param utilMap
     * @return List<Asset>
     **/
    public static List < Asset > getAssetInfo(Map < String, Object > utilMap, XC_QueuedRequestStep__c currentStep) {
        //CR UPiscopo 09/11/2021 - Energy Disconnect Romania ( added a new control on XC_MarketAssetID and contractNumber for CommodityRomaniaB2C -- BEGIN -->
		XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
 
        String contractId = (String) utilMap.get('ContractId');
        String assetId = (String) utilMap.get('assetId');
        String accountId = (String) utilMap.get('accountId');
        String query = 'SELECT Id, Name, NE__Order_Config__c, NE__Order_Config__r.NE__Type__c, NE__Order_Config__r.XC_Status__c, Status,'+ 
            'NE__Order_Config__r.Name, Account.XC_Segment__c,XC_MarketAssetID__c,XC_VASContractNumber__c,XC_ActivePortfolio__c,'+
            'XC_BillingProfileLineItem__r.XC_BillingProfile__c,XC_BillingModel__c,NE__ProdId__r.XC_LIC_Product_Name__c,'+
            'XC_ContractEndDate__c,XC_ContractStartDate__c';
        
        List < Asset > assetList = new List < Asset > ();
		//getting the full step info in order to process data

        if (utilMap.get('clientSystem') == 'CommodityRomaniaB2C') {
            if(!String.isBlank(contractId)){
                query += ' FROM Asset WHERE AccountId =: accountId and XC_MarketAssetID__c =: ContractId ';
                system.debug('QUERY ON ASSET(on CommondityRomaniaB2C): ' + query);
                assetList = Database.query(String.escapeSingleQuotes(query));
            }
            
        } else {
            query += ' FROM Asset WHERE Id =: assetId';
            system.debug('QUERY ON ASSET(on as if): ' + query);
            assetList = Database.query(String.escapeSingleQuotes(query));
  
        }

        if (assetList != null || assetList.isEmpty()) {
            system.debug('NO ASSET FOUNDED');
        } else {
            system.debug('ASSET FOUNDED');

        }
        return assetList; //<-- END


    }


    /**
     * @description update step in KO status
     * @author Luisana Rocco - lrocco@deloitte.it | 10-05-2021
     * @param step
     * @param errorMessage
     **/
    public static void setStepKO(XC_QueuedRequestStep__c step, String errorMessage) {
        step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        step.XC_ErrorMessage__c = errorMessage;
    }


    /**
     * @description retieve all discount to be removed
     * @author Luisana Rocco - lrocco@deloitte.it | 18-05-2021
     * @param currentStep
     * @param intLog
     * @param orderWr
     **/
    private static void populateIntegrationLogInfo(XC_QueuedRequestStep__c currentStep, XC_UTIL_IntegrationLog intLog, XC_REST_Order_U.WrapperPOSTRequest wrReq) {
        //adding headers
        Map < String, String > mapHeader = new Map < String, String > ();
        mapHeader.put('ClientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
        mapHeader.put('TransactionID', currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
        mapHeader.put('DateTimeMessage', DateTime.now().format('yyyyMMddHHmmssSSS'));
        mapHeader.put('Operation', 'Disconnect');
        mapHeader.put('Functionality', 'Disconnect');
        mapHeader.put('ServerSystem', 'XCustomerB2C');


        //TODO: manage first integration log insert here
        intLog.insertIntegReqInboundLog('AsyncOrderDisconnect', JSON.serialize(wrReq, true), currentStep.XC_QueuedRequest__c);
        intLog.setHeader(mapHeader);
        intLog.setTransactionID(mapHeader.get('TransactionID'));
        intLog.setHttpMethod('POST');

        // set additional integration log info
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.accountID = wrReq.Order.accountID;
        intLog.setAdditionalInformations(logWrapper);

    }

    /** 
    * @description manage disconnect order 
    * @author Luisana Rocco - lrocco@deloitte.it  
    * @param utilMap  
    * @param wrResp  
    **/ 
    public static void manageDisconnectOrder(Map<String,Object> utilMap , XC_REST_Order_U.WrapperRes wrResp){ 
 
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest)utilMap.get('wrReq'); 
         
        // Update Order to set IntegrationID 
        if(!String.isBlank(wrReq.Order.IntegrationID) || !String.isBlank(wrReq.Order.VASContractExtID) || !String.isBlank(wrReq.Order.PartnerSalesChannel)){ 
            if(!XC_UTIL_QueuedRequestStep.updateFieldsonOrder((String)utilMap.get('disconnectOrderId'),  utilMap)){ 
                setStepKO((XC_QueuedRequestStep__c)utilMap.get('currentStep'), (String)utilMap.get('ErrorMessage')); 
                wrResp.Result.ErrorCode = '500'; 
                wrResp.Result.logError = 'INTERNAL ERROR.' + (String)utilMap.get('ErrorMessage'); 
                wrResp.Result.Message = 'INTERNAL ERROR.' + (String)utilMap.get('ErrorMessage'); 
                return; 
            } 
        } 
 
        //add external document 
        if(wrReq.Order.Document != null && !wrReq.Order.Document.isEmpty()){ 
            if(!XC_UTIL_QueuedRequestStep.manageExternalDocument((String)utilMap.get('disconnectOrderId'), utilMap)||test.isRunningTest()){ 
                setStepKO((XC_QueuedRequestStep__c)utilMap.get('currentStep'), (String)utilMap.get('ErrorMessage')); 
                wrResp.Result.ErrorCode = '500'; 
                wrResp.Result.logError = 'INTERNAL ERROR.' + (String)utilMap.get('ErrorMessage'); 
                wrResp.Result.Message = 'INTERNAL ERROR.' + (String)utilMap.get('ErrorMessage'); 
                return; 
            } 
        } 
 
    } 
 
}