/**
* @File Name          : XC_IN_QRS01_CreateAccount.cls
* @Description        : 
* @Author             : Francesco Imperioli - fimperioli@deloitte.it
* @Group              : 
* @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
* @Last Modified On   : 07-13-2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    15/6/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_IN_QRS01_CreateAccount {
    
    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }
    
    public static final Set<String> MANAGED_ERROR_CODES = new Set<String>{'501','502','503'};
        
        
        /**
* @description invokes XC_REST_Account methods to manage account insert asynchronously - errors are managed via integration logs and queuedrequeststep fields
* @author Francesco Imperioli - fimperioli@deloitte.it | 15/6/2020 
* @param inputs 
* @return void 
**/
        @InvocableMethod
        public static void executeAccountCreation(List<InputWrapper> inputs){
            System.EnqueueJob(new QueueableExecuteAccountCreation(inputs));
        }
    
    
    public class QueueableExecuteAccountCreation implements Queueable, Database.AllowsCallouts{
        
        private List<InputWrapper> inputs;
        
        public QueueableExecuteAccountCreation(List<InputWrapper> inputs){
            this.inputs = inputs;
        }
        
        public void execute(QueueableContext qc) {
            manageAccountCreation(inputs);
        }
        
    }
    
    
    /**
* @description executes operations for account creation using XC_REST_Account methods
* @author Francesco Imperioli - fimperioli@deloitte.it | 1/7/2020 
* @param inputs 
* @return void 
**/
    public static void manageAccountCreation(List<InputWrapper> inputs){

        //Manage Rollback
        System.Savepoint beforeInsertSavepoint; 
        if(!Test.isRunningTest()){
            beforeInsertSavepoint = Database.setSavepoint();
        }
        
        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        
        //getting logging infos
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        String logError = '';
        String messageResp = '';
        
        try{
            
            //generate body request and response
            XC_REST_Account_W.WrapperRequest wrReq = generatePostAccountBody(currentStep);
            
            //adding headers
            Map<String,String> mapHeader = new Map<String,String>();
            mapHeader.put('ClientSystem',currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            mapHeader.put('TransactionID',currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
            mapHeader.put('Operation','INSERT');
            mapHeader.put('Functionality','ASYNCQR');
            mapHeader.put('DateTimeMessage',DateTime.now().format('yyyyMMddHHmmssSSS'));
            mapHeader.put('ServerSystem','XCustomerB2C');
            
            // BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
            List<XC_ThirdPartyConfiguration__c> tpbConfigs = [SELECT Name, XC_TPBCode__c FROM XC_ThirdPartyConfiguration__c WHERE XC_TPBCode__c = :mapHeader.get('ClientSystem') AND XC_OrgId__c = :UserInfo.getOrganizationId()];
            XC_ThirdPartyConfiguration__c tpbConf = (tpbConfigs != null && !tpbConfigs.isEmpty()) ? tpbConfigs.get(0) : null;
            if(tpbConf != null)
            {
                mapHeader.put('ClientSystem', 'ThirdPartyB2C');
            }
            // END - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
            
            //TODO: manage first integration log insert here
            intLog.insertIntegReqInboundLog('AsyncAccount', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod('POST');
            
            //adding validation on POST request
            XC_UTIL_Integration.WrapperResult validationResult = XC_REST_Account_V.validateRequestPOST(mapHeader, wrReq);
            
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
            
            //Try to inserting the account
            XC_REST_Account_U.manageInsert(wrReq, wrResp, mapHeader);
            
            //manage response
            String respErrorCode = wrResp.Result.ErrorCode;
            messageResp = JSON.serialize(wrResp,true);
            system.debug('test '+respErrorCode+' - '+messageResp);
            if(respErrorCode != '0'){                
                manageErrors(currentStep,wrResp,/*wrReq,*/ beforeInsertSavepoint);
            }else{
                currentStep.XC_ExecutionResponse__c = messageResp;
                currentStep.XC_Status__c = 'Completed OK';
                currentStep.XC_RelatedRecordsIds__c = wrResp.Account.AccountID;
                XC_UTIL_Sobject.updateRecord(currentStep);
            } 
            
        }catch(Exception e){

            if(!Test.isRunningTest()){
                Database.rollback(beforeInsertSavepoint);
            }

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
* @description manage duplication errors of the account creation phase
* @author Francesco Imperioli - fimperioli@deloitte.it | 15/6/2020 
* @param currentStep 
* @param wrResp 
* @param beforeInsertSavepoint 
* @return void 
**/
    @testVisible
    private static void manageErrors(XC_QueuedRequestStep__c currentStep ,XC_REST_Account_W.WrapperResponse wrResp, /*XC_REST_Account_W.WrapperRequest wrReq,*/ SavePoint beforeInsertSavepoint){
        
        if(!MANAGED_ERROR_CODES.contains(wrResp.Result.ErrorCode)){
            if(!Test.isRunningTest()){
                Database.rollback(beforeInsertSavepoint);
            }
            currentStep.XC_Status__c = 'Completed KO';
            currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
            currentStep.XC_ErrorMessage__c = wrResp.Result.Message;
            XC_UTIL_Sobject.updateRecord(currentStep); 
            XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            
            return;
        }
        
        /*manage eventual updates on the found account*/
        String foundAccountId = wrResp.Account.AccountID;
        currentStep.XC_RelatedRecordsIds__c = foundAccountId;
        currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
        currentStep.XC_Status__c = 'Completed OK';
        XC_UTIL_Sobject.updateRecord(currentStep); 
        
        
    }
    
    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 15/6/2020 
    * @param currentStep 
    * @return XC_REST_Account_W.WrapperRequest 
    **/
    private static XC_REST_Account_W.WrapperRequest generatePostAccountBody(XC_QueuedRequestStep__c currentStep){
        
        //manage special keywords inside the string
        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        requestStringValue = requestStringValue.replace('Currency', 'CurrencyName');
        requestStringValue = requestStringValue.replace('ShippingAddress', 'DeliveryAddress');
        
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        
        XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
        accountWrReq.Account = fullQRReqBody.Account;
        accountWrReq.Account.LastName = normalizeName(fullQRReqBody.Account.LastName, fullQRReqBody.Account.FirstName);
        accountWrReq.Account.FirstName = normalizeName(fullQRReqBody.Account.FirstName, fullQRReqBody.Account.FirstName);
        //[BEGIN ACERRA CR-NR2063 B2B 05.11.2021]
        if(checkB2BAccountType(currentStep)){
            accountWrReq.Account.AccountType = 'B2B';
        }
        //[END ACERRA CR-NR2063 B2B 05.11.2021]
        accountWrReq.Contact = fullQRReqBody.Contact;
        if(!accountWrReq.Contact.isEmpty()){
            accountWrReq.Contact[0].LastName = normalizeName(fullQRReqBody.Contact[0].LastName, fullQRReqBody.Contact[0].FirstName);
            accountWrReq.Contact[0].FirstName = normalizeName(fullQRReqBody.Contact[0].FirstName, fullQRReqBody.Contact[0].FirstName);   
            //[BEGIN ACERRA CR-NR2063 B2B 05.11.2021]
            accountWrReq.Contact[0].Type = ('B2B'.equalsIgnoreCase(accountWrReq.Account.AccountType)) ? 'B2B' : '' ;
            //[END ACERRA CR-NR2063 B2B 05.11.2021]
        }
        accountWrReq.Identity = fullQRReqBody.Identity;
        accountWrReq.BillingProfile = null;
        accountWrReq.Address = null;
        
        return accountWrReq;
        
    }
    
    
    private static String normalizeName(String fName, String lName){
        
        if(String.isNotBlank(fName)){
            fName = XC_UTIL_String.removeDiacritics(fName);
            fName = fName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
            fName = fName.normalizeSpace();
            if(fName.length() == 1){
                fName = fName + lName;
            }
        }
        
        return fName;
    }
    
    /**
    * @description 
    * @author Federica Acerra - f.acerra@accenture.it |CR-NR2063 B2B 05/11/2021 
    * @param currentStep 
    * @return Boolean
    **/
    
    @testVisible
    private static Boolean checkB2BAccountType(XC_QueuedRequestStep__c currentStep){
        system.debug('checkB2BAccountType : ');
        Boolean isB2B = false;
        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;
        List<NE__Catalog_Item__c> catalogItems;
        Set<String> ProdIDSet = new Set<String>();
        Set<String> CatalogNameSet = new Set<String> {'Enel X Catalog B2B2G - Italy'};
        if(null!=wrReq.Order && null!=wrReq.Order.OrderItem && !wrReq.Order.OrderItem.isEmpty()){
            for(XC_UTIL_Order.OrderItemWrapper orderItem : wrReq.Order.OrderItem){
                if(!String.isBlank(orderItem.ProdID)){
                    ProdIDSet.add(orderItem.ProdID);
                }
            }
        }
        if(!ProdIDSet.isEmpty() && ProdIDSet != null){
            String query =  'SELECT Id,  NE__UsageCode__c,Catalog_item_code__c , NE__Catalog_Id__c, NE__Catalog_Id__r.XC_LIC_Name__c, NE__ProductId__c ' +
                            'FROM NE__Catalog_Item__c WHERE NE__UsageCode__c IN: ProdIDSet AND NE__Catalog_Id__r.XC_LIC_Name__c =: CatalogNameSet';

            catalogItems = Database.query(String.escapeSingleQuotes(query));
        }
      
        if(null!=catalogItems && !catalogItems.isEmpty()){
            isB2B = true;
        }
        return isB2B;

    }

    
}