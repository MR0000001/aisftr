/**
 * @File Name          : XC_IN_QRS03_CreateBillingProfile.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 07-17-2020
 * @Modification Log   : 
 * @TestClass          : 
 * Ver       Date            Author                 Modification
 * 1.0    16/06/2020   Marco Ottaviano - mottaviano@deloitte.it     Initial Version
**/


public without sharing class XC_IN_QRS03_CreateBillingProfile {


    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    public static final Set<String> MANAGED_ERROR_CODES = new Set<String>{'501'};


    /**
    * @description 
    * @author Marco Ottaviano mottaviano@deloitte.it
    * @param inputs 
    * @return void 
    **/
    @InvocableMethod
    public static void executeBillingProfileCreation(List<InputWrapper> inputs) {
        System.debug('START CALL QUEUEABLE BILLING PROFILE');
        System.enqueueJob(new queuableExcecuteBillingProfileCreation(inputs));
    
    }


    public class queuableExcecuteBillingProfileCreation implements Queueable, Database.AllowsCallouts {

        private List<InputWrapper> inputs;
        public queuableExcecuteBillingProfileCreation(List<InputWrapper> inputs) {
            this.inputs=inputs;
        }


        public void execute(QueueableContext qc) {

        
            //getting the full step info in order to process data
            InputWrapper iw = inputs[0];
            XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
            XC_UTIL_QueuedRequestStep.PreviousQRSWrapper previousStepWr = XC_UTIL_QueuedRequestStep.getPreviousStep(currentStep);
            
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
            XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
            String logError = '';
            String messageResp ='';

            try{

                XC_REST_Account_W.WrapperRequest wrReq=generatePutAccountBody(currentStep,previousStepWr.previousStep);
                //adding headers
                Map<String,String> mapHeader = new Map<String,String>();
                mapHeader.put('ClientSystem',currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
                mapHeader.put('TransactionID',currentStep.XC_QueuedRequest__r.XC_TransactionId__c);

                intLog.insertIntegReqInboundLog('AsyncBillingProfile', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
                intLog.setHeader(mapHeader); 
                intLog.setTransactionID(mapHeader.get('TransactionID'));
                intLog.setHttpMethod('PUT');

                for(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr : wrReq.BillingProfile){
                    if(mapHeader.get('ClientSystem')=='CommoditySpainB2C' && !String.isBlank(bpwr.iban)){
                        bpwr.iban = bpwr.iban.toUpperCase();
                    }
                }

                String contr = wrReq.BillingProfile[0].CommodityContractNum;
                if(mapHeader.get('ClientSystem')=='CommodityItalyB2C'){
                    contr = wrReq.BillingProfile[0].CommodityCC;
                    if(String.isBlank(contr)){
                        contr = wrReq.BillingProfile[0].CupsID;
                    }
                }

                
                List<String> listOfClientSystemSkip = new List<String>();
                listOfClientSystemSkip = Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';');

                // For the list of client to skip, all address flags are set to true in QRS02. For these clients, the BP uses the first address (which will be chosen also for the order in QRS04).
                String addrReq1 = wrReq.Address[0].AddressID;
                String addrReq2 = (wrReq.Address.size() > 1 && !listOfClientSystemSkip.contains(currentStep.XC_QueuedRequest__r.XC_ClientSystem__c)) ? wrReq.Address[1].AddressID : '';

                Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c, (SELECT Id, XC_Preferredlanguageofcontact__c FROM Contacts WHERE XC_PrimaryContact__c = true),
                (SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToAddress__c, XC_SoldToAddress__c, XC_TPBCode__c,XC_LegalEntity__c  FROM XC_BillingProfileLineItems__r WHERE XC_BillingProfile__r.XC_CommodityContractID__c =: contr ),
                (SELECT Id, XC_AddressProvince__c, XC_BillingAddress__c, XC_PricinRegion__c, XC_DeliveryAddress__c, XC_InstallationAddress__c  FROM Addresses__r WHERE Id =: addrReq1 OR Id =: addrReq2) 
                FROM Account WHERE Id =: wrReq.Account.AccountID LIMIT 1]);//[2021-09-30 :: TP :: Third Party Billing :: Added new field XC_TPBCode__c]

                //search addresses
                XC_address__c deliveryAddress;
                XC_address__c billingAddress;
                XC_address__c installationAddress;
                for(XC_address__c addr: accountMap.values()[0].Addresses__r){
                    if(addr.XC_DeliveryAddress__c){
                        deliveryAddress = addr;
                    }
                    if(addr.XC_BillingAddress__c){
                        billingAddress = addr;
                    }
                    if(addr.XC_InstallationAddress__c){
                        installationAddress = addr;
                    }
                }

                String legalEntity = wrReq.BillingProfile[0].LegalEntity; //[AO011249 - 21/03/2021 - check on legal entity - mariateresa.mollica@accenture.com]
                Boolean duplicateFound = false;
                // BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
                List<XC_ThirdPartyConfiguration__c> tpbConfigs = [SELECT Name, XC_TPBCode__c, XC_ZuoraSequenceSetId__c FROM XC_ThirdPartyConfiguration__c WHERE XC_TPBCode__c = :mapHeader.get('ClientSystem') AND XC_OrgId__c = :UserInfo.getOrganizationId()];
                XC_ThirdPartyConfiguration__c tpbConf = (tpbConfigs != null && !tpbConfigs.isEmpty()) ? tpbConfigs.get(0) : null;
                // END - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
                for(XC_BillingProfileLineItem__c bpli : accountMap.values()[0].XC_BillingProfileLineItems__r){
                    duplicateFound = (bpli.XC_BillToAddress__c == billingAddress.id && bpli.XC_SoldToAddress__c == deliveryAddress.Id 
                        && ((tpbConf==null && String.isBlank(bpli.XC_TPBCode__c)) || (tpbConf != null && bpli.XC_TPBCode__c == tpbConf.XC_TPBCode__c)) //[2021-09-30 :: TP :: Third Party Billing :: Added new field XC_TPBCode__c]
                        && (legalEntity!=null && legalEntity.equalsIgnoreCase(bpli.XC_LegalEntity__c))); //[AO011249 - 21/03/2021 - check on legal entity - mariateresa.mollica@accenture.com]
                    if(duplicateFound){
                        XC_REST_Account_U.manageUpdate(wrReq, wrResp, mapHeader);
                        break;
                    }
                }

                if(!duplicateFound){
                    if(!accountMap.values()[0].XC_BillingProfileLineItems__r.isEmpty()){
                        wrReq.BillingProfile[0].BillingAddressID = billingAddress.Id;
                        wrReq.BillingProfile[0].SoldAddressID = deliveryAddress.Id;
                        wrReq.BillingProfile[0].BillingProfileID = accountMap.values()[0].XC_BillingProfileLineItems__r[0].XC_BillingProfile__c;
                    }
                    
                    XC_REST_Account_U.manageUpdate(wrReq, wrResp, mapHeader);
                }


                //manage response
                String respErrorCode = wrResp.Result.ErrorCode;
                messageResp = JSON.serialize(wrResp,true);


                if(respErrorCode != '0'){                
                    manageErrors(currentStep,wrResp,wrReq);
                }else{
                    currentStep.XC_ExecutionResponse__c = messageResp;
                    currentStep.XC_Status__c = 'Completed OK';
                    
                    //setting the IDs on field
                    List<String> bpIds = new List<String>();
                    for(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr : wrResp.BillingProfile){
                        bpIds.add(bpwr.BillingProfileID);
                    }
                    currentStep.XC_RelatedRecordsIds__c = String.join(bpIds,';');
                    
                    XC_UTIL_Sobject.updateRecord(currentStep);
                } 


            } catch(Exception e) {
                logError = e.getMessage() + ' ' + e.getStackTraceString();
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ErrorMessage__c = logError;
                XC_UTIL_Sobject.updateRecord(currentStep); 
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            } finally {
                intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), messageResp, logError);
            }
        }
        
    }



    /**
    * @description manage errors of the billing profile creation phase
    * @author Marco Ottaviano- mottaviano@deloitte.it | 16/6/2020 
    * @param currentStep 
    * @param wrResp 
    * @return void 
    **/
    @TestVisible
    private static void manageErrors(XC_QueuedRequestStep__c currentStep,XC_REST_Account_W.WrapperResponse wrResp, XC_REST_Account_W.WrapperRequest wrReq){

        if(!MANAGED_ERROR_CODES.contains(wrResp.Result.ErrorCode)){
            if(wrResp.Result.ErrorCode == '500' && wrResp.Result.Message.contains('Already exist a Billing profile with this Commodity Contract')) {
				
                List<String> CommodityContractNumList = new List<String>();
                List<String> CommodityCCNums = new List<String>();
                List<String> externalId = new List<String>();
                for(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpifWr: wrReq.BillingProfile) {
                    CommodityContractNumList.add(bpifWr.CommodityContractNum);
                    if (bpifWr.CommodityCC != null){
                    	CommodityCCNums.add(bpifWr.CommodityCC);
                    }
                        // externalId.add(bpifWr.Ex)
                }
                
                String accountId = wrResp.Account.AccountID;
                Map<Id, NE__Billing_Profile__c> billMap = new Map<Id, NE__Billing_Profile__c>([SELECT Id FROM NE__Billing_Profile__c WHERE NE__Account__r.Id =: accountId AND (XC_CommodityContractID__c IN : CommodityContractNumList OR XC_CommodityContractID__c IN : CommodityCCNums)]);
                
                wrResp.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
                XC_UTIL_BillingProfile.BillingProfileIFWrapper add = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
                add.BillingProfileID = billMap.values()[0].Id;
                wrResp.BillingProfile.add(add);

            } else {
                currentStep.XC_Status__c = 'Completed KO';
                currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
                currentStep.XC_ErrorMessage__c = wrResp.Result.Message;
                XC_UTIL_Sobject.updateRecord(currentStep); 
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);

                return;
            }
        }

        currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
        currentStep.XC_Status__c = 'Completed OK';
        XC_UTIL_Sobject.updateRecord(currentStep); 

    }





      /**
    * @description method to generate put account body
    * @author Marco Ottaviano mottaviano@deloitte.it | 16/6/2020 
    * @param currentStep 
    * @return XC_REST_MobilityOrder_W.WrapperRequest
    **/
    private static XC_REST_Account_W.WrapperRequest generatePutAccountBody(XC_QueuedRequestStep__c currentStep,XC_QueuedRequestStep__c previousStep){

        //manage special keywords inside the string
        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        requestStringValue = requestStringValue.replace('Currency', 'CurrencyName');
        requestStringValue = requestStringValue.replace('ShippingAddress', 'DeliveryAddress');

        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        
        String responseFrompreviousStep = previousStep.XC_ExecutionResponse__c;
        XC_REST_Account_W.WrapperResponse responseWrPreviousStep= (XC_REST_Account_W.WrapperResponse) JSON.deserialize(responseFrompreviousStep, XC_REST_Account_W.WrapperResponse.class);


        XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
        accountWrReq.Account.AccountID = responseWrPreviousStep.Account.AccountID;
        accountWrReq.Contact = null;
        accountWrReq.Identity = null;
        accountWrReq.BillingProfile = fullQRReqBody.BillingProfile;
        accountWrReq.Address = responseWrPreviousStep.Address;

        return accountWrReq;

    }


  

    

}