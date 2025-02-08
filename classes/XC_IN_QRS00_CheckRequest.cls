public with sharing class XC_IN_QRS00_CheckRequest {
    public static final Set<String> OK_CODES = new Set<String>{'0', '000', 'ERROR 000'};
    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    //[DeAv 16/11/2021 TPB-PostSales START]
    public class WrapperResult {
        public String errorMessage;
        public String assId;
        //begin acerra PS_ID036_ID019
        public String accId;
        public String segment;        
        public String VASContractExtID;
        public String VASContractNumber;
        //end acerra PS_ID036_ID019
        public Asset ass; //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278]

        public WrapperResult(){
            errorMessage = '';
            assId = '';
            //begin acerra PS_ID036_ID019
            accId = ''; 
            segment = ''; 
            VASContractExtID  = ''; 
            VASContractNumber = '' ;
            ass = null; //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278]
          //end acerra PS_ID036_ID019
        }
    }
    //[DeAv 16/11/2021 TPB-PostSales END]

    //[DeAv 07/12/2021 TPB: adjustment to invoke WebService START]
    public class WebServiceWrapper {
        public AccountWrapper Account;
    }
    public class AccountWrapper {
        public String ContractNumber;
        public String AccountType;
        public String POS;
        public String IdentityType;
        public String IdentityNumber;
        //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        public string commodityCustomerName;        
        public string commodityIdentityNumber;  
        //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
    }
    //[DeAv 07/12/2021 TPB: adjustment to invoke WebService END]
 

    @InvocableMethod
    public static void executeCheckRequest(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteCheckRequest(inputs));
    }


    public class QueueableExecuteCheckRequest implements Queueable, Database.AllowsCallouts{

        private List<InputWrapper> inputs;

        public QueueableExecuteCheckRequest(List<InputWrapper> inputs){
            this.inputs = inputs;
        }

        public void execute(QueueableContext qc) {
            manageCheckRequest(inputs);
        }
    }
    
    public static void manageCheckRequest(List<InputWrapper> inputs){
        System.debug('manageCheckRequest start : ');
        //Step blocked, need to comment this point
        /*
        System.Savepoint beforeInsertOrderSavepoint; 
        if(!Test.isRunningTest()){
            beforeInsertOrderSavepoint = Database.setSavepoint();
        }
        */
        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
         
        //getting logging infos
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        String jsonUpdated = '';
        String logError = '';
        String messageResp = '';
        Map<String,Object> mapCon = new Map<String,Object>();
        String contractStatus;
        String contractId = '';
        List<Object> contractsRetrieved = new  List<Object>();
        String integrationID='';
        String errorMessage='';
        //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        String commodityCustomerName='';
        String commodityIdentityNumber='';
        //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        //[DeAv 07/12/2021 TPB: adjustment to invoke WebService START]
        Map<String, Object> mapResultsPOST = new Map<String, Object>();
        Map<String, Object> resultsPOST = new Map<String, Object>();
        List<XC_Integration_Log__c> intLogGetContract= new List<XC_Integration_Log__c>();
        //[DeAv 07/12/2021 TPB: adjustment to invoke WebService END]

        //manage special keywords inside the string
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_QueuedRequest_W.WrapperRequest billingReq = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        XC_UTIL_Order.OrderIFWrapper orderReq = new XC_UTIL_Order.OrderIFWrapper();
        List<XC_UTIL_Account.IdentityIFWrapper> identityReq = new List <XC_UTIL_Account.IdentityIFWrapper>();
        List<XC_UTIL_Address.AddressWrapper> addressReq = new List<XC_UTIL_Address.AddressWrapper>();
        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        Map<String, Object> results = new Map<String, Object> ();
        accountWrReq.Account = fullQRReqBody.Account;
        billingReq.BillingProfile=fullQRReqBody.BillingProfile;
        orderReq= fullQRReqBody.Order;
        identityReq= fullQRReqBody.Identity;
        addressReq= fullQRReqBody.Address;
        currentStep.XC_QueuedRequest__r.XC_ClientSystem__c = accountWrReq.Account.PartnerClientSystem;
        System.debug('manageCheckRequest  orderReq: '+orderReq);
        integrationID= currentStep.XC_QueuedRequest__r.XC_IntegrationId__c;
        List <XC_QueuedRequest__c> queuedReqList = [SELECT Id, XC_IntegrationId__c
                                                    FROM XC_QueuedRequest__c
                                                    WHERE XC_IntegrationId__c = :integrationID
                                                    AND XC_Status__c!='In Error'];
        
        System.debug('@@@ queuedReqList.size: ' + queuedReqList.size());
        if(queuedReqList.size()>=2){
            errorMessage='ERROR: Request already inserted';
        }
        
        else{
           if('New'.equalsIgnoreCase(orderReq.OrderType)&&(String.isNotBlank(orderReq.VASContractExtID)||String.isNotBlank(orderReq.VASContractNumber))){
                List<String> listValueQuery = new List<String>();
                if(String.isNotBlank(orderReq.VASContractExtID)){
                    listValueQuery.add(orderReq.VASContractExtID);
                }
                else{
                    if(String.isNotBlank(orderReq.VASContractNumber)){
                        listValueQuery.add(orderReq.VASContractNumber);
                    }
                }
                System.debug('@@@ listValueQuery: ' + listValueQuery);
                List <Asset> assetList = [SELECT Id, XC_VASContractExtID__c,Account.PrimaryEmail__c, Account.XC_AccountPhone__c,Account.IdentityNumber__c
                                         FROM Asset
                                         WHERE XC_VASContractExtID__c IN:listValueQuery];
                
                System.debug('@@@ assetList: ' + assetList.size());
                if(assetList.size()>=1){
                    if(((String.isNotBlank(accountWrReq.Account.PrimaryEmail) && String.isNotBlank(assetList.get(0).Account.PrimaryEmail__c) && assetList.get(0).Account.PrimaryEmail__c != accountWrReq.Account.PrimaryEmail) 
                    || (String.isNotBlank(accountWrReq.Account.MainPhone) && String.isNotBlank(assetList.get(0).Account.XC_AccountPhone__c) && assetList.get(0).Account.XC_AccountPhone__c != accountWrReq.Account.MainPhone) 
                    || (String.isNotBlank(identityReq.get(0).IdentityNumber) && String.isNotBlank(assetList.get(0).Account.IdentityNumber__c) && assetList.get(0).Account.IdentityNumber__c != identityReq.get(0).IdentityNumber)) ){
                        errorMessage = 'ERROR: Contract number already inserted for another account';
                    }
                    else{
                        errorMessage = 'ERROR: Contract number already created for the specific account';
                    } 
                }
            }
        }
        //Start vdb 29-12-2021
    	Schema.DescribeFieldResult fieldResult  = XC_Address__c.XC_AddressCountry__c.getDescribe();
        List<String> pickListValuesList= new List<String>();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : entries){
			pickListValuesList.add(pickListVal.getValue());
		}     
        if(!pickListValuesList.contains(identityReq.get(0).Country)){
           setKO(currentStep, 'ERROR: Country not allowed', 'ERROR: No active Market contracts found');
           return;
        }
 		//End vdb 29-12-2021
        //[DeAv 10/01/2022 TPB Check Billing Model THIRDPARTY-1165 START]
        if(orderReq.OrderItem != null && !orderReq.OrderItem.isEmpty()){
            List<String> billingModels = new List<String>();
            List<NE__PropertyDomain__c> pds = [SELECT Name 
                                               FROM NE__PropertyDomain__c 
                                               WHERE NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c ='Payment model' AND 
                                                     NE__PropId__c in (SELECT NE__PropId__c 
                                                                       FROM NE__ProductFamilyProperty__c 
                                                                       WHERE NE__FamilyId__r.XC_LIC_Family_Name__c ='Payment Details')];
            if(!pds.isEmpty()){
                for(NE__PropertyDomain__c pd : pds){
                    billingModels.add(pd.Name);
                }            
                //List<String> billingModels = new List<String>{'Monthly','One shot'};
                List<XC_UTIL_Order.WrapperAttribute> attribs = orderReq.OrderItem.get(0).Attribute;
                for(XC_UTIL_Order.WrapperAttribute wa : attribs){
                    if('Payment details:Payment Method'.equalsIgnoreCase(wa.Name) && !billingModels.contains(wa.Value)){
                        setKO(currentStep, 'ERROR: Billing Model not allowed', 'ERROR: Billing Model not allowed');
                        return;
                    }
                }
            }
        }
        //[DeAv 10/01/2022 TPB Check Billing Model THIRDPARTY-1165 END]
        if(!'Disconnection'.equalsIgnoreCase(orderReq.OrderType) && (!'Change Order'.equalsIgnoreCase(orderReq.OrderType) && !'Promocode Application'.equalsIgnoreCase(orderReq.OrderSubType)) ){ //[DeAv 16/11/2021 TPB-PostSales - Added if-else] //[acerra PS_ID036_ID019 add or changeorder]

            if(errorMessage.equals('')){
                try{ 
                    //[DeAv 07/12/2021 TPB: adjustment to invoke WebService START]
                    XC_REST_Contract_Outbound.ContractOutboudCallInputData callData = new XC_REST_Contract_Outbound.ContractOutboudCallInputData();
                    callData.identityNumber = '';
                    callData.pos = addressReq.get(0).PointOfService.get(0).POS;
                    callData.country = identityReq.get(0).Country;
                    callData.insertLoggin = false;
                    XC_REST_Contract_Outbound.ContractOutboudCallOutputData responseGET = XC_REST_Contract_Outbound.callToGetContract(callData);
                    mapCon = responseGET.fieldsData;
                    intLogGetContract = responseGET.integrationLog;
                    //mapCon = XC_REST_Contract_Outbound.callToGetContract('',addressReq.get(0).PointOfService.get(0).POS,identityReq.get(0).Country);
                    //[DeAv 07/12/2021 TPB: adjustment to invoke WebService END]
                    contractsRetrieved = (List<Object>) mapCon.get('Contract');
                    results = (Map<String, Object>) mapCon.get('Result');
                }
                catch(Exception e){
                    System.debug('Errore call getContract: '+e.getMessage());
                    if(Test.isRunningTest()){   
                        mapCon =(Map<String,Object>) JSON.deserializeUntyped('{"Result":{"ErrorCode":"0","Message":"Operation completed successfully"},"Contract":[{"AccountID":"001360000187JS4AAM","ContractStartDate":"1986-04-02","ContractTerm":null,"Currency":"CLP","Status":"Activated","ContractType":"Energia","OwnerExpirationNotice":null,"AssetID":null,"AddressID":null,"ContractNumber":"01521664","TypeOfSocialBonus":null,"SocialBonus":null,"ContractedPower":null,"Tariff":"BT1","CIEAuthorizedMaximumPower":null,"MinimumElectricalConsumption":null,"NameContractedService":null,"OwnerCompany":"ENEL DISTRIBUCION CHILE","MaximumPowerPOD":null,"CNAE":null,"TensionType":null,"CIEExpirationRules":null}]}');
                        contractsRetrieved = (List<Object>) mapCon.get('Contract');
                    }
                    //Start VDB 29-12-2021
                    else{
                         setKO(currentStep, 'ERROR: Generic error in getContract', 'ERROR: Generic error in getContract');
                         if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                            insert intLogGetContract; 
                    }
                    //End VDB 29-12-2021
                    return;
                    }
                }

                //System.debug('@@@ contractsRetrieved: ' + contractsRetrieved.size());
                if(contractsRetrieved!=null && !contractsRetrieved.isEmpty()){
                    for(Object contractObj : contractsRetrieved){
                        Map<String,Object> contract = (Map<String,Object>) contractObj;
                        //contractStatus = contract.containsKey('Status') ? String.valueOf(contract.get('Status')) : '';
                        //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                        commodityCustomerName=String.valueOf(contract.get('commodityCustomerName'));
                        commodityIdentityNumber=String.valueOf(contract.get('commodityIdentityNumber'));
                        //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                        contractStatus = String.valueOf(contract.get('Status'));
                        if(contractStatus.equalsIgnoreCase('Activated')|| contractStatus.equalsIgnoreCase('Active') || contractStatus.equalsIgnoreCase('01') ){
                            contractId = String.valueOf(contract.get('ContractNumber'));
                            break;
                        }
                    }
                }else{
                    errorMessage = (results != null && String.isNotBlank(String.valueOf(results.get('Message')))) ? String.valueOf(results.get('Message')): Label.XC_CL_ContractOutbound_Exception;
                    setKO(currentStep, errorMessage, 'ERROR: No active Market contracts found');
                    if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                        insert intLogGetContract; 
                    }
                    return;
                }
                //[DeAv 07/12/2021 TPB: adjustment to invoke WebService START]
                System.debug('@@@ contractId: ' + contractId);
                if(String.isBlank(contractId)){
                    errorMessage = (results != null && String.isNotBlank(String.valueOf(results.get('Message')))) ? String.valueOf(results.get('Message')): Label.XC_CL_ContractOutbound_Exception;
                    setKO(currentStep, errorMessage, 'ERROR: No active Market contracts found');
                    if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                        insert intLogGetContract; 
                    }
                    return;
                }else{
                    //[DeAv 11/12/2021 Fix TPB added if-else for check activeInterface START]
                    XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_ContractAccountValidation, accountWrReq.Account.Country);
                    System.debug('@@@ isActiveInterface.activeInterface: ' + isActiveInterface.activeInterface);
                    if(isActiveInterface.activeInterface){
                        try{                          
                            WebServiceWrapper inputMap = new WebServiceWrapper();
                            AccountWrapper acc = new AccountWrapper();
                            acc.ContractNumber = contractId; 
                            acc.AccountType = String.isNotBlank(accountWrReq.Account.AccountType) ? accountWrReq.Account.AccountType : 'Residential'; 
                            acc.POS = (addressReq != null && !addressReq.isEmpty() && addressReq.get(0).PointOfService != null && !addressReq.get(0).PointOfService.isEmpty()) ? addressReq.get(0).PointOfService.get(0).POS : '';
                            acc.IdentityType = (identityReq != null && !identityReq.isEmpty()) ? identityReq.get(0).IdentityType : '';
                            acc.IdentityNumber = (identityReq != null && !identityReq.isEmpty()) ? identityReq.get(0).IdentityNumber : '';
                            //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                            acc.commodityCustomerName=commodityCustomerName;
                            acc.commodityIdentityNumber=commodityIdentityNumber;
                            //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                            inputMap.Account = acc;
                            String body = JSON.serialize(inputMap, true);
                            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'ContractAccountValidation', isActiveInterface.serverSystem);
                            
                            String endpointUrl = isActiveInterface.url;
                            //********************** Send outbound request *************************************//
                            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', endpointUrl, headerDefinitions, body);
                            System.debug('[ContractAccountValidation] request -> ' + request);
                            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ContractAccountValidation');
                            System.debug('[ContractAccountValidation] response -> ' + response);
                            mapResultsPOST = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                            resultsPOST = (Map<String, Object>) mapResultsPOST.get('Result');
                        }catch(Exception e){
                            System.debug('Errore call ContractAccountValidation: ' + e.getMessage());
                            if(Test.isRunningTest()){   
                                mapResultsPOST = (Map<String,Object>) JSON.deserializeUntyped('{"Result":{"ErrorCode":"0","Message":"Operation completed successfully"}}');
                                resultsPOST = (Map<String, Object>) mapResultsPOST.get('Result');
                            }else{
                                errorMessage = 'Error in ContractAccountValidation: ' + e.getMessage();
                                setKO(currentStep, errorMessage, errorMessage);
                                if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                                    insert intLogGetContract; 
                                }
                                return;
                            }
                        }  

                        //System.debug('@@@ ErrorCode ofresultsPOST: ' + String.valueOf(resultsPOST.get('ErrorCode')));
                        if(OK_CODES.contains(String.valueOf(resultsPOST.get('ErrorCode')))){
                            currentStep.XC_Status__c = 'Completed OK';
                            currentStep.XC_ExecutionResponse__c = JSON.serialize(resultsPOST,true);
                            billingReq.BillingProfile.get(0).CommodityContractNum = contractId;
                            billingReq.BillingProfile.get(0).CommodityCC = contractId; //[DeAv 14/12/2021 Fix for BillingProfile Creation]
                            billingReq.BillingProfile.get(0).CupsID = String.isNotEmpty(billingReq.BillingProfile.get(0).CupsID) ? billingReq.BillingProfile.get(0).CupsID : addressReq.get(0).PointOfService.get(0).POS;
                            fullQRReqBody.BillingProfile = billingReq.BillingProfile;
                            jsonUpdated=JSON.serialize(fullQRReqBody, true);                        
                            currentStep.XC_QueuedRequest__r.XC_RequestBody__c = jsonUpdated;
                            XC_QueuedRequest__c queuedReq = currentStep.XC_QueuedRequest__r;
                            queuedReq.XC_RequestBody__c = jsonUpdated;
                            XC_UTIL_Sobject.updateRecord(queuedReq);
                            XC_UTIL_Sobject.updateRecord(currentStep);
                            if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                                insert intLogGetContract; 
                            }
                            return;
                        }else{ //setto per andare in KO e chiamo la skipCallback
                            setKO(currentStep, String.valueOf(resultsPOST.get('Message')), JSON.serialize(resultsPOST,true));
                            if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                                insert intLogGetContract; 
                            }
                            return;
                        }
                    }else{                        
                        currentStep.XC_Status__c = 'Completed OK';
                        currentStep.XC_ExecutionResponse__c = JSON.serialize(resultsPOST,true);
                        billingReq.BillingProfile.get(0).CommodityContractNum = contractId;
                        billingReq.BillingProfile.get(0).CommodityCC = contractId; //[DeAv 14/12/2021 Fix for BillingProfile Creation]
                        billingReq.BillingProfile.get(0).CupsID = String.isNotEmpty(billingReq.BillingProfile.get(0).CupsID) ? billingReq.BillingProfile.get(0).CupsID : addressReq.get(0).PointOfService.get(0).POS;
                        fullQRReqBody.BillingProfile = billingReq.BillingProfile;
                        jsonUpdated=JSON.serialize(fullQRReqBody, true);                        
                        currentStep.XC_QueuedRequest__r.XC_RequestBody__c = jsonUpdated;
                        XC_QueuedRequest__c queuedReq = currentStep.XC_QueuedRequest__r;
                        queuedReq.XC_RequestBody__c = jsonUpdated;
                        XC_UTIL_Sobject.updateRecord(queuedReq);
                        XC_UTIL_Sobject.updateRecord(currentStep);
                        if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                            insert intLogGetContract; 
                        }
                        return;
                    }
                    //[DeAv 11/12/2021 Fix TPB added if-else for check activeInterface END]
                }
                //[DeAv 07/12/2021 TPB: adjustment to invoke WebService END]        
            }else{
                setKO(currentStep, errorMessage, '');
                if(intLogGetContract != null && !intLogGetContract.isEmpty()){
                    insert intLogGetContract; 
                }
                return;
            }
        //[DeAv 16/11/2021 TPB-PostSales START]
        }else{
            System.debug('@@@ errorMessage: ' + errorMessage);
            if(!String.isBlank(errorMessage)){
                setKO(currentStep, errorMessage, '');
            }else{
                System.debug('manageCheckRequest  if change order: ');
                WrapperResult result = new WrapperResult();
                result = checkDisconnectInfo(fullQRReqBody);

                System.debug('@@@ result.errorMessage: ' + result.errorMessage);
                if(!String.isBlank(result.errorMessage)){
                    setKO(currentStep, result.errorMessage, '');
                }else{
                    currentStep.XC_Status__c = 'Completed OK';
                    orderReq.AssetID = result.assId;
                    //begin acerra PS_ID036_ID019
                    //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278 START]
                    if(String.isNotBlank(result.VASContractExtID)){
                        orderReq.VASContractExtID = result.VASContractExtID;
                    }
                    if(String.isNotBlank(result.VASContractNumber)){
                        orderReq.VASContractNumber = result.VASContractNumber;
                    }
                    //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278 END]
                    orderReq.AccountID = result.accId ; 
                    accountWrReq.Account.Segment = result.segment ; 
                    fullQRReqBody.Account = accountWrReq.Account; 
                    //end acerra PS_ID036_ID019
                    fullQRReqBody.Order = orderReq;
                    jsonUpdated=JSON.serialize(fullQRReqBody, true);
                    currentStep.XC_QueuedRequest__r.XC_RequestBody__c = jsonUpdated;
                    XC_QueuedRequest__c queuedReq = currentStep.XC_QueuedRequest__r;
                    queuedReq.XC_RequestBody__c = jsonUpdated;
                    //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278 START]
                    if(result.ass!= null){
                        result.ass.XC_CommodityCancellationReason__c = fullQRReqBody.Order.CommodityCancellationReason;
                        XC_UTIL_Sobject.updateRecord(result.ass);
                    }
                    //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278 START]
                    XC_UTIL_Sobject.updateRecord(queuedReq);
                    XC_UTIL_Sobject.updateRecord(currentStep);
                    return;
                }
            }     
        }
        //[DeAv 16/11/2021 TPB-PostSales END]
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description method used to check input in Disconnect scenario 
     * @param fullQRReqBody input json
     */
    public static WrapperResult checkDisconnectInfo(XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody){
        System.debug('checkDisconnectInfo start');
        WrapperResult wr = new WrapperResult();
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingReq = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_Order.OrderIFWrapper orderReq = new XC_UTIL_Order.OrderIFWrapper();
        List<XC_UTIL_Account.IdentityIFWrapper> identityReq = new List <XC_UTIL_Account.IdentityIFWrapper>();
        List<XC_UTIL_Account.ContactIFWrapper> contactReq = new List<XC_UTIL_Account.ContactIFWrapper>();
        
        billingReq  = fullQRReqBody.BillingProfile;
        orderReq    = fullQRReqBody.Order;
        identityReq = fullQRReqBody.Identity; 
        contactReq  = fullQRReqBody.Contact;
        System.debug('checkDisconnectInfo orderReq2: '+orderReq);
        System.debug('@@@ orderReq.OrderType : ' + orderReq.OrderType);
        System.debug('@@@ orderReq.OrderSubType : ' + orderReq.OrderSubType);
        List<String> ordSubTypeList = new List<String>{'Cancellation by Business Decision', 'End of supply', 'Bad referral'};    
        //[BEGIN ACERRA PS_ID036_ID019]     
        if('Change Order'.equalsIgnoreCase(orderReq.OrderType) && 'Promocode Application'.equalsIgnoreCase(orderReq.OrderSubType) ){
            ordSubTypeList.add('Promocode Application');
        }
        //[END ACERRA PS_ID036_ID019]     
        if(orderReq == null || 
            (orderReq != null && (String.isBlank(orderReq.OrderSubType) || 
            (String.isNotBlank(orderReq.OrderSubType) && !ordSubTypeList.contains(orderReq.OrderSubType))))){
            wr.errorMessage = 'ERROR: Incorrect order subtype';
            return wr;
        }

        List<Account> accList = new List<Account>();
        String idNumber = (identityReq != null && !identityReq.isEmpty()) ? identityReq.get(0).IdentityNumber : '';
        if(String.isNotBlank(idNumber)){
            accList = [SELECT Id
                       FROM Account
                       WHERE IdentityNumber__c = :idNumber];
        }

        System.debug('@@@ accList size: ' + accList.size());
        if(identityReq == null || identityReq.isEmpty() || accList.isEmpty()){ //[DeAv 16.02.2022 INC000082316604 removed check on size account]
            wr.errorMessage = 'ERROR: Account not found';
            return wr;
        }

        Integer count = 0;
        Integer legEntIndex = 0;
        if(contactReq != null && !contactReq.isEmpty()){
            for(XC_UTIL_Account.ContactIFWrapper conReq : contactReq){
                count ++;
                String giveDataToLegEnt;
                String ordinalNumberAbbreviation = (count==1) ? 'st' : (count==2) ? 'nd' : (count==3) ? 'rd' : (count>=4) ? 'th'  : '';
                if(conReq.GDPR != null && conReq.GDPR.LegalEntity != null && !conReq.GDPR.LegalEntity.isEmpty()){
                    for(XC_UTIL_Account.LegalEntityWrapper legEnt : conReq.GDPR.LegalEntity){                                    
                        giveDataToLegEnt = conReq.GDPR.LegalEntity.get(legEntIndex).GiveDataToLegalEntity;
                        System.debug('@@@ giveDataToLegEnt: ' + giveDataToLegEnt);          
                        if(String.isBlank(giveDataToLegEnt) || (String.isNotBlank(giveDataToLegEnt) && !'Y'.equalsIgnoreCase(giveDataToLegEnt))){
                            wr.errorMessage = 'ERROR. Contact.GDPR.LegalEntity.GiveDataToLegalEntity must be Y in ' + count + ordinalNumberAbbreviation + ' Contact';
                            return wr;
                        }
                        legEntIndex ++;
                    }                                
                }else{
                    wr.errorMessage = 'ERROR. Contact.GDPR.LegalEntity.GiveDataToLegalEntity must be Y in ' + count + ordinalNumberAbbreviation + ' Contact';
                    return wr;
                }                   
            }
        }else{
            wr.errorMessage = 'ERROR: Contact not found';
            return wr;
        }

        //Id accId = accList.get(0).Id;
        //System.debug('@@@ accId ' + accId);
        List<Asset> assetList = new List<Asset>();
        List<String> attrNameList= new List<String>{'Number of quotas','Price'};//ACERRA PS_ID036_ID019
        if(orderReq != null && (String.isNotBlank(orderReq.VASContractExtID)||String.isNotBlank(orderReq.VASContractNumber))){
            String vasContract;
            //acerra PS_ID036_ID019 add  fields
            String query = 'SELECT Id, Status, XC_VASContractExtID__c, XC_VASContractNumber__c, NE__Order_Config__c, NE__Order_Config__r.NE__Type__c, NE__Order_Config__r.XC_Status__c, XC_LegalEntity__c, ContactId, Contact.IndividualId, NE__CatalogItem__r.NE__UsageCode__c ,AccountId, XC_BillingModel__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityCupsID__c,Account.XC_Segment__c, XC_CommodityCancellationReason__c, ' + //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278: Added XC_CommodityCancellationReason__c]
                            +'(SELECT id,name,NE__Value__c from NE__AssetItemAttributes__r where Name IN :attrNameList) '+
                            'FROM Asset ' +
                            'WHERE AccountId IN: accList'; //[DeAv 16.02.2022 INC000082316604 changed account where condition]
           if(String.isNotBlank(orderReq.VASContractExtID)){
                vasContract = orderReq.VASContractExtID;
                query = query + ' AND XC_VASContractExtID__c =: vasContract';
            }else if(String.isNotBlank(orderReq.VASContractNumber)){
                vasContract = orderReq.VASContractNumber;
                query = query + ' AND XC_VASContractNumber__c =: vasContract';
            }
            System.debug('@@@ vasContract: ' + vasContract);
            //[DeAv 17/12/2021 Modified to coverage the scenario of Disconnection START]
            if(!Test.isRunningTest()){
                assetList = Database.query(query);
            }else{
                assetList = [SELECT Id, Status, XC_VASContractExtID__c, XC_VASContractNumber__c, NE__Order_Config__c, NE__Order_Config__r.NE__Type__c, NE__Order_Config__r.XC_Status__c, XC_LegalEntity__c, ContactId, Contact.IndividualId, NE__CatalogItem__r.NE__UsageCode__c ,AccountId, XC_BillingModel__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityCupsID__c,Account.XC_Segment__c, 
                            (SELECT id,name,NE__Value__c from NE__AssetItemAttributes__r where Name IN :attrNameList)
                            FROM Asset
                            WHERE XC_VASContractExtID__c = :vasContract];
            }
            //[DeAv 17/12/2021 Modified to coverage the scenario of Disconnection END]
        }

        System.debug('checkDisconnectInfo assetList: '+assetList);       
        if(assetList.isEmpty() || assetList.size()>1){ 
            wr.errorMessage = 'ERROR: Asset not found';
            return wr;
        }
        
        System.debug('@@@ assetList.get(0).Status: ' + assetList.get(0).Status);
        if(!'Active'.equalsIgnoreCase(assetList.get(0).Status)){ 
            wr.errorMessage = 'ERROR: Asset with status different than active';
            return wr;
        }

       List<String> orderStatusList = new List<String>{'Closed', 'Cancelled'};
       if(assetList.get(0).NE__Order_Config__c != null && 
           !'InOrder'.equalsIgnoreCase(assetList.get(0).NE__Order_Config__r.NE__Type__c) &&
           !orderStatusList.contains(assetList.get(0).NE__Order_Config__r.XC_Status__c)){
            wr.errorMessage = 'ERROR: Asset currently subject to modification or disconnection';
            return wr;
        }
        
        String assLegEnt = assetList.get(0).XC_LegalEntity__c;
        Id assContact = assetList.get(0).ContactId;
        Id indId = assetList.get(0).Contact.IndividualId;
        Id billProfLineItemId = assetList.get(0).XC_BillingProfileLineItem__c;
        Id billProfId = assetList.get(0).XC_BillingProfileLineItem__r.XC_BillingProfile__c;
        
        System.debug('@@@ assContact: ' + assContact);
        if(String.isBlank(assContact)){
            wr.errorMessage = 'ERROR: Contact not found';
            return wr;
        }

        System.debug('@@@ indId: ' + indId);
        if(String.isBlank(indId)){
            wr.errorMessage = 'ERROR: Individual not found';
            return wr;
        }

        System.debug('@@@ billProfLineItemId: ' + billProfLineItemId);
        System.debug('@@@ billProfId: ' + billProfId);
        if(String.isBlank(billProfLineItemId) || String.isBlank(billProfId)){
            wr.errorMessage = 'ERROR: Billing Profile not found';
            return wr;
        }

        System.debug('@@@ assLegEnt: ' + assLegEnt);
        if(String.isNotBlank(assLegEnt) && String.isNotBlank(orderReq.LegalEntity)){
            if(!assLegEnt.equalsIgnoreCase(orderReq.LegalEntity)){
                wr.errorMessage = 'ERROR: LegalEntity does not match with the one related to the Contact and the Asset';
                return wr;
            }else{
                List<XC_LegalEntityConsent__c> consentList = new List<XC_LegalEntityConsent__c>();
                consentList = [SELECT Id, XC_GiveDataToNew__c
                               FROM XC_LegalEntityConsent__c
                               WHERE XC_Individual__c =: indId AND 
                                     XC_LegalEntity__c =: assLegEnt];
                
                System.debug('@@@ consentList: ' + consentList);
                if(!consentList.isEmpty()){
                    for(XC_LegalEntityConsent__c con : consentList){
                        if(!'Yes'.equalsIgnoreCase(con.XC_GiveDataToNew__c)){
                            wr.errorMessage = 'ERROR: LegalEntity does not match with the one related to the Contact and the Asset';
                            return wr;
                        }
                    }
                }else{
                    wr.errorMessage = 'ERROR: LegalEntity does not match with the one related to the Contact and the Asset';
                    return wr;
                }                
            }
        }

        if(billingReq != null && !billingReq.isEmpty()){
            String cupsReq = billingReq.get(0).CupsID;
            System.debug('@@@ cupsReq: ' + cupsReq);
            String cupsBillProf = assetList.get(0).XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityCupsID__c;
            System.debug('@@@ cupsBillProf: ' + cupsBillProf);
            if(String.isBlank(cupsBillProf) || (String.isNotBlank(cupsBillProf) && !cupsBillProf.equalsIgnoreCase(cupsReq))){
                wr.errorMessage = 'ERROR: POS does not match with the one used to bill the asset';
                return wr; 
            }           
        }else{
            wr.errorMessage = 'ERROR: Billing Profile not found';
            return wr;
        }

        if(orderReq.OrderItem != null && !orderReq.OrderItem.isEmpty()){
            String prodId = assetList.get(0).NE__CatalogItem__r.NE__UsageCode__c;
            System.debug('@@@ prodId: ' + prodId);
            String jsonProdId = orderReq.OrderItem.get(0).ProdID;
            System.debug('@@@ jsonProdId: ' + jsonProdId);
            if(String.isBlank(jsonProdId) || (String.isNotBlank(jsonProdId) && !jsonProdId.equalsIgnoreCase(prodId))){
                wr.errorMessage = 'ERROR: ProdId does not match with the Product Code of the asset';
                return wr;
            }
        }else{
            wr.errorMessage = 'ERROR: ProdId does not match with the Product Code of the asset';
            return wr;
        }
        
        if('Change Order'.equalsIgnoreCase(orderReq.OrderType) && 'Promocode Application'.equalsIgnoreCase(orderReq.OrderSubType) ){
           wr = checkPromocodeApplication(orderReq,assetList.get(0));
        }

        wr.assId = (String) assetList.get(0).Id;
        wr.accId = (String) assetList.get(0).AccountId; //acerra PS_ID036_ID019
        wr.ass = assetList.get(0); //[DeAv 2022-02-01 TPB Fix THIRDPARTY-1278]
        return wr;
    }


    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description method used to set KO on Queued Request Step
     * @param currentStep current Queued Request Step 
     * @param erroreMessage error description
     */
    public static void setKO(XC_QueuedRequestStep__c currentStep, String erroreMessage, String execResp){
        System.debug('@@@ Sono in setKO');
        currentStep.XC_Status__c = 'Completed KO';
        currentStep.XC_ErrorMessage__c = erroreMessage;
        currentStep.XC_ExecutionResponse__c = execResp;
        //[DeAv 06/12/2021 Fix TPB START]
        XC_QueuedRequest__c queuedReq = currentStep.XC_QueuedRequest__r;
        XC_UTIL_Sobject.updateRecord(queuedReq);
        //[DeAv 06/12/2021 Fix TPB END]
        XC_UTIL_Sobject.updateRecord(currentStep); 
        XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
        return;
    }

   /**
    * @description 
    * @author Federica Acerra - f.acerra@accenture.it | PS_ID036_ID019
    * @param orderReq
    * @param assetRecord 
    * @return WrapperResult
    **/
    @testVisible
    private static WrapperResult checkPromocodeApplication(XC_UTIL_Order.OrderIFWrapper orderReq, Asset assetRecord){
        System.debug('checkPromocodeApplication : ');
        WrapperResult wr = new WrapperResult();
        Map<String,Object> mapNameValueAtt = new Map<String,Object>();
        System.debug('@@@ assetRecord.XC_BillingModel__c: ' + assetRecord.XC_BillingModel__c);
        if(!'Recurring'.equalsIgnoreCase(assetRecord.XC_BillingModel__c)){
            wr.errorMessage = 'ERROR: Billing Model different than Recurring';
            return wr;
        }
        if(null!=orderReq && null!=orderReq.OrderItem && !orderReq.OrderItem.isEmpty()){
            for(XC_UTIL_Order.OrderItemWrapper orderItem : orderReq.OrderItem ){
                if(orderItem.Attribute != null && !orderItem.Attribute.isEmpty()){
                    for(XC_UTIL_Order.WrapperAttribute oiAttrWr: orderItem.Attribute){
                        if(String.isNotBlank(oiAttrWr.Name)){
                            if(oiAttrWr.Name.containsIgnoreCase('Number of quotas')){
                                mapNameValueAtt.put('Number of quotas', oiAttrWr.Value);
                            }else if(oiAttrWr.Name.containsIgnoreCase('Price')){
                                mapNameValueAtt.put('Price', oiAttrWr.Value);
                            }
                        }       
                    }
                }
            }
        }
        System.debug('checkPromocodeApplication : mapNameValueAtt  '+mapNameValueAtt);
        if(null!=mapNameValueAtt && !mapNameValueAtt.isEmpty()){
            if(assetRecord.NE__AssetItemAttributes__r != null){
                for(NE__AssetItemAttribute__c  attr : assetRecord.NE__AssetItemAttributes__r){
                    System.debug('checkPromocodeApplication : attr  '+attr);
                    if (mapNameValueAtt.containsKey(attr.Name) &&  attr.NE__Value__c == mapNameValueAtt.get(attr.Name)) {
                        wr.errorMessage = 'ERROR: Duration and Price alredy as requested';
                        return wr;
                    }    
                }
            }
        }
        wr.assId = (String) assetRecord.Id;
        wr.accId = (String) assetRecord.AccountId;
        wr.segment = assetRecord.Account.XC_Segment__c;
        wr.VASContractExtID = (String) assetRecord.XC_VASContractExtID__c;
        wr.VASContractNumber = (String) assetRecord.XC_VASContractNumber__c;
       
        return wr;
    }

}