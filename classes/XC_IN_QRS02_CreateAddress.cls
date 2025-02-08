/**
* @File Name          : XC_IN_QRS02_CreateAddress.cls
* @Description        :
* @Author             : Francesco Imperioli - fimperioli@deloitte.it
* @Group              :
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 08-03-2021
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    15/6/2020   Simone Trenta - strenta@deloitte.it    Initial Version
**/
public with sharing class XC_IN_QRS02_CreateAddress {
    
    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }
    
    /**
    * @description invokes XC_REST_Account methods to manage account insert asynchronously - errors are managed via integration logs and queuedrequeststep fields
    * @author Simone Trenta - strenta@deloitte.it
    * @param inputs
    **/
    @InvocableMethod
    public static void executeAccountCreation(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteAddressCreation(inputs));
    }
    
    
    public class QueueableExecuteAddressCreation implements Queueable, Database.AllowsCallouts{
        
        private List<InputWrapper> inputs;
        
        public QueueableExecuteAddressCreation(List<InputWrapper> inputs){
            this.inputs = inputs;
        }
        
        public void execute(QueueableContext qc) {
            manageAddressCreation(inputs);
        }
    }
    
    public static void manageAddressCreation(List<InputWrapper> inputs) {
        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        XC_QueuedRequestStep__c previousStep = XC_UTIL_QueuedRequestStep.getPreviousStep(currentStep).previousStep;
        
        
        //getting logging infos
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        String logError = '';
        String messageResp = '';
        
        try{
            
            //generate body request and response
            XC_REST_Account_W.WrapperRequest wrReq = generateInsertAddresstBody(currentStep, previousStep);
            
            //adding headers
            Map<String,String> mapHeader = new Map<String,String>();
            mapHeader.put('ClientSystem',currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            mapHeader.put('TransactionID',currentStep.XC_QueuedRequest__r.XC_TransactionId__c);

            // BEGIN - [2021-12-27 :: TP :: Third Party Billing :: Get partner codes]
            List<XC_ThirdPartyConfiguration__c> tpbConfigs = [SELECT Name, XC_TPBCode__c FROM XC_ThirdPartyConfiguration__c WHERE XC_TPBCode__c = :mapHeader.get('ClientSystem') AND XC_OrgId__c = :UserInfo.getOrganizationId()];
            XC_ThirdPartyConfiguration__c tpbConf = (tpbConfigs != null && !tpbConfigs.isEmpty()) ? tpbConfigs.get(0) : null;
            if(tpbConf != null)
            {
                mapHeader.put('ClientSystem', 'ThirdPartyB2C');
            }
            // END - [2021-12-27 :: TP :: Third Party Billing :: Get partner codes]
            
            //TODO: manage first integration log insert here
            intLog.insertIntegReqInboundLog('AsyncAddress', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
            intLog.setHeader(mapHeader);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod('PUT');
            
            XC_REST_Account_U.manageUpdate(wrReq, wrResp, mapHeader);
            messageResp = JSON.serialize(wrResp,true);
            manageResponse(currentStep, wrReq, wrResp);
            
        }catch(Exception e){
            logError = e.getMessage() + ' ' + e.getStackTraceString();
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ErrorMessage__c = logError;
            XC_UTIL_Sobject.updateRecord(currentStep);
            XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            
        }finally{
            //inserting logs
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), messageResp, logError);
        }
    }
    
    /**
    * @description
    * @author Simone Trenta - strenta@deloitte.it
    * @param currentStep
    * @param previousStep
    * @return XC_REST_Account_W.WrapperRequest
    **/
    private static XC_REST_Account_W.WrapperRequest generateInsertAddresstBody(XC_QueuedRequestStep__c currentStep, XC_QueuedRequestStep__c previousStep){
        
        //manage special keywords inside the string
        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        String accountCreatedMessage = previousStep.XC_ExecutionResponse__c;
        
        requestStringValue = requestStringValue.replaceAll('ShippingAddress', 'DeliveryAddress');
        
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_UTIL_QueuedRequest_W.WrapperRequest accountInfo = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(accountCreatedMessage, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        
        XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
        accountWrReq.Address = fullQRReqBody.Address;
        accountWrReq.Account.AccountID = accountInfo.Account.AccountID;
        accountWrReq.Contact = null;
        accountWrReq.Identity = null;
        accountWrReq.BillingProfile = null;
        
        //Mod CV Errore 23/07/2021 Start ---->
        
        List<String> listOfClientSystemSkip = new List<String>();
        listOfClientSystemSkip = Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';');
        if(listOfClientSystemSkip.contains(currentStep.XC_QueuedRequest__r.XC_ClientSystem__c)){
            
            //Add logic to put prefered address in the first position of List
            // if(accountWrReq.Address.size() > 1){
            // 	for (Integer i = 0; i < accountWrReq.Address.size();i++ ){
            // 		if(accountWrReq.Address.get(i).BillingAddress){
            // 			accountWrReq.Address.add(0, accountWrReq.Address.remove(i));
            // 			break;
            // 		}
            // 	}
            // }
            
            for (XC_UTIL_Address.AddressWrapper addrTmpList : accountWrReq.Address) {
                addrTmpList.BillingAddress = true;
                addrTmpList.DeliveryAddress = true;
                addrTmpList.InstallationAddress = true;
                // break;
            }
            
        }
        //Mod CV Errore 23/07/2021 End <----
        if(currentStep.XC_QueuedRequest__r.XC_ClientSystem__c=='CommoditySpainB2C' && !accountWrReq.Address.isEmpty() && String.isBlank(accountWrReq.Address[0].Country)){
            accountWrReq.Address[0].Country = 'Spain';
        }
        
        return accountWrReq;
    }
    
    private static void manageResponse(XC_QueuedRequestStep__c currentStep, XC_REST_Account_W.WrapperRequest wrReq, XC_REST_Account_W.WrapperResponse wrResp){
        String respErrorCode = wrResp.Result.ErrorCode;
        String messageResp = JSON.serialize(wrResp,true);
        if(respErrorCode != '0'){
            Set<String> addressKeys = new Set<String>(); //
            Set<String> addressKeysOne = new Set<String>(); //
            if(wrResp.Result.Message.contains('Address already exist') || wrResp.Result.Message.contains('There is already an Address with the same data. Try reporting a different POD.')){
                
                // String keyDupl1 =
                // wrReq.Account.AccountID + ' ' +
                // wrReq.Address[0].Country + ' ' +
                // wrReq.Address[0].City + ' ' +
                // wrReq.Address[0].Province + ' ' +
                // wrReq.Address[0].StreetNumber;
                
                // String keyDupl2 =
                // wrReq.Address[0].Address + ' ' +
                // wrReq.Address[0].StreetType + ' ' +
                // wrReq.Address[0].Municipality + ' ' +
                // wrReq.Address[0].ZipCode;
                
                // Map<Id,XC_Address__c> addMap = new Map<Id,XC_Address__c>([
                //     SELECT id FROM XC_Address__c WHERE XC_KeyForDuplication__c =: keyDupl1 AND XC_KeyForDuplicationOne__c =: keyDupl2 ORDER BY CreatedDate DESC]);
                
                // wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                // XC_UTIL_Address.AddressWrapper add = new XC_UTIL_Address.AddressWrapper();
                // add.AddressID = addMap.values()[0].Id;
                // wrResp.Address.add(add);
                
                for(XC_UTIL_Address.AddressWrapper aw : wrReq.Address){
                    
                    String keyForDup = wrReq.Account.AccountID + ' ' +aw.Country + ' ' + aw.City + ' ' +aw.Province + ' ' + aw.StreetNumber;
                    String keyForDup2 = aw.Address + ' ' + aw.StreetType + ' ' +  aw.Municipality + ' ' +aw.ZipCode;
                    addressKeys.add(keyForDup);
                    addressKeysOne.add(keyForDup2);
                }
                
                Map<Id,XC_Address__c> addMap = new Map<Id,XC_Address__c>([SELECT id
                                                                          FROM XC_Address__c
                                                                          WHERE XC_KeyForDuplication__c IN :addressKeys
                                                                          AND XC_KeyForDuplicationOne__c IN :addressKeysOne
                                                                          ORDER BY CreatedDate DESC
                                                                          LIMIT 4]); //Mod CV Errore Step Billing Profile 03/08/2021 Rising query Limit from 2 to 4
                
                
                
                if(wrResp.Address == null){
                    wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                }
                
                for(XC_Address__c duplicateAddr : addMap.values()){
                    
                    XC_UTIL_Address.AddressWrapper add = new XC_UTIL_Address.AddressWrapper();
                    add.AddressID = duplicateAddr.Id;
                    wrResp.Address.add(add);
                }
                
                
                
                currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
                currentStep.XC_Status__c = 'Completed OK';
                //saving the recordIds on Step
                List<String> addrIds = new List<String>();
                for(XC_UTIL_Address.AddressWrapper addrWr : wrResp.Address){
                    addrIds.add(addrWr.AddressID);
                }
                currentStep.XC_RelatedRecordsIds__c = String.join(addrIds,';');
                
                
                XC_UTIL_Sobject.updateRecord(currentStep);
                
                
            } else {
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
                currentStep.XC_ErrorMessage__c = wrResp.Result.Message;
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            }
        }else{
            currentStep.XC_ExecutionResponse__c = messageResp;
            currentStep.XC_Status__c = 'Completed OK';
            
            List<String> addrIds = new List<String>();
            for(XC_UTIL_Address.AddressWrapper addrWr : wrResp.Address){
                addrIds.add(addrWr.AddressID);
            }
            currentStep.XC_RelatedRecordsIds__c = String.join(addrIds,';');
            
            XC_UTIL_Sobject.updateRecord(currentStep);
        }
    }
    
}