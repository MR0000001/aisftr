/**
 * The Class XC_REST_Opportunity_U.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 10/12/2018
 * @date Modification : 29/04/2019
 * @description       : Util for Rest Resourse to Create Opportunity
 */


public class XC_REST_Opportunity_U {

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The Opportunity. */
        public XC_UTIL_Opportunity.OpportunityIFWrapper Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();
    }


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
        
        /** The Opportunity. */
        public XC_UTIL_Opportunity.OpportunityIFWrapper Opportunity;
    }

    
    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperGETResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
        
        /** The Opportunity. */
        public List<XC_UTIL_Opportunity.OpportunityIFWrapper> Opportunity;
    }


    /**
     * Validate request.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @param method the method
     * @return the wrapper result
     * @description validate request
     */
    public static XC_UTIL_Integration.WrapperResult validateCreateRequestOpportunity(Map<String, String> mapHeader, WrapperRequest wrReq, String method){
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Opportunity', 'create');
        if(validateResult.errorFlag){
            return validateResult; 
        } 

        XC_UTIL_Opportunity.OpportunityIFWrapper opp = wrReq.Opportunity;
        if(opp == null) {
            validateResult.errorMessage = 'ERROR. Missing mandatory field: Opportunity';
            validateResult.errorFlag = true;
            return validateResult;
        }

        Map<String, String> requiredParameters = new Map<String, String>{
            'LegalEntity' => opp.LegalEntity,
            'AccountID' => opp.AccountID,
            'ContactID' => opp.ContactID,
            'ProductCategoryOfInterest' => opp.ProductCategoryOfInterest,
            'Status' => opp.Status,
            'AddressID' => opp.AddressID
            };

        System.debug('Client System: ' + mapHeader.get('ClientSystem'));
        //Servizio Unico AccountOpportunity
        if(mapHeader.get('ClientSystem') == 'CommodityItalyB2B'){
            requiredParameters.put('LeadID', opp.LeadID);
            requiredParameters.put('OpportunityType', opp.OpportunityType);
            //Set flow mandatory fields
            wrReq.Opportunity.OpportunityName = (wrReq.Opportunity.OpportunityName!=null) ? wrReq.Opportunity.OpportunityName : 'B2B/G';
            wrReq.Opportunity.CloseDate = (wrReq.Opportunity.CloseDate!=null) ? wrReq.Opportunity.CloseDate : Date.today().addDays(30);
        }
        //Other Client Systems
        else{
            requiredParameters.put('OpportunityName', opp.OpportunityName);
            
            if(opp.CloseDate == null){
                validateResult.errorMessage = 'ERROR. Missing mandatory field: Opportunity.CloseDate';
                validateResult.errorFlag = true;
                return validateResult;
            }
        }

        for(String key : requiredParameters.keySet()) {
            if(String.isBlank(requiredParameters.get(key))) {
                validateResult.errorMessage = 'ERROR. Missing mandatory field: Opportunity.' + key;
                validateResult.errorFlag = true;
                return validateResult;
            }
        }

        doChecksOnAccount(new Map<String, String>{'AccountID' => opp.AccountID, 'ContactID' => opp.ContactID, 'AddressID' => opp.AddressID}, validateResult);
        if(validateResult.errorFlag) {
            return validateResult;
        }
        
        //BlacklistCheck GDB 26/03/2020
        if(!String.isblank(opp.LegalEntity) && !String.isblank(opp.ProductCategoryOfInterest) && !String.isblank(opp.AddressID)){
            checkOpportunityBlacklist(validateResult, opp);
        }

        return validateResult;
    }

    /**
     * DoChecksOnAccount.
     *
     * @param params the params map
     * @param validateResult the wrapper result of validation
     * @description do Checks On Account
     */
    public static void doChecksOnAccount(Map<String, String> params, XC_UTIL_Integration.WrapperResult validateResult){
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, (SELECT Id FROM Personal_Documents__r), (SELECT Id FROM Contacts WHERE Id =: params.get('ContactID')), (SELECT Id FROM Addresses__r WHERE Id =: params.get('AddressID')) FROM Account WHERE Id =: params.get('AccountID')]);

        if(accountMap.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_AccountNotFound;
            validateResult.errorFlag = true;
            return;
        }

        if(accountMap.values()[0].Contacts.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_ContactNotFound;
            validateResult.errorFlag = true;
            return;
        }

        if(accountMap.values()[0].Addresses__r.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_AddressNotFound;
            validateResult.errorFlag = true;
            return;
        }

        if(String.isBlank(accountMap.values()[0].IdentityNumber__c) && accountMap.values()[0].Personal_Documents__r.isEmpty()){
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Account_MissingDocument;
            validateResult.errorFlag = true;
            return;
        }
    }


    /**
     * Create Oopportunity From Wrapper.
     *
     * @param wr the wrapper request
     * @return the opportunity
     * @description create opportunity from wrapper
     */
    public static Opportunity createOpportunityFromWrapper(WrapperRequest wr) {
        Opportunity opportunityFromWrapper = new Opportunity();
        System.debug('@@@opp' + wr.Opportunity);		
        
        if(!String.isBlank(wr.Opportunity.OpportunityType)){
            Map<Id,XC_CM_AccOpportunity_RT_Config__mdt> rec = new Map<Id,XC_CM_AccOpportunity_RT_Config__mdt>([SELECT XC_Developer_Name__c
            FROM XC_CM_AccOpportunity_RT_Config__mdt 
            WHERE XC_OpportunityType__c =: wr.Opportunity.OpportunityType LIMIT 1]);

            if(!rec.isEmpty()){
                Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(rec.values()[0].XC_Developer_Name__c).getRecordTypeId();
                opportunityFromWrapper.RecordTypeId = recordTypeId;
            }
        }
        
        opportunityFromWrapper.Name =  wr.Opportunity.OpportunityName;
        // Missing field UniqueID
        opportunityFromWrapper.XC_LegalEntity__c = wr.Opportunity.LegalEntity;
        opportunityFromWrapper.AccountId = wr.Opportunity.AccountID;
        opportunityFromWrapper.XC_Contact__c = wr.Opportunity.ContactID;
        opportunityFromWrapper.XC_ProductCategoryOfInterest__c = wr.Opportunity.ProductCategoryOfInterest;
        opportunityFromWrapper.CloseDate = wr.Opportunity.CloseDate;
        opportunityFromWrapper.StageName = wr.Opportunity.Status;
        opportunityFromWrapper.XC_LossReason__c = wr.Opportunity.LossReason;
        opportunityFromWrapper.XC_LossReasonDescription__c = wr.Opportunity.LossReasonDescription;
        opportunityFromWrapper.Probability = wr.Opportunity.Probability;
        opportunityFromWrapper.XC_PrincingRegion__c = wr.Opportunity.PrincingRegion;
        opportunityFromWrapper.XC_ReceivingChannel__c = wr.Opportunity.ReceivingChannel;
        opportunityFromWrapper.XC_Source__c = wr.Opportunity.Sources;
        opportunityFromWrapper.XC_Address__c = wr.Opportunity.AddressID;
        opportunityFromWrapper.XC_WorkOrder__c = wr.Opportunity.WorkOrderID;

        if(wr.Opportunity.PrimaryCampaignSource == ''){
            opportunityFromWrapper.CampaignId = null;
        } else {
            opportunityFromWrapper.CampaignId = wr.Opportunity.PrimaryCampaignSource;
        }
        opportunityFromWrapper.XC_Score__c = wr.Opportunity.Scoring;
        if(wr.Opportunity.ExecuteAssignment != null){
            opportunityFromWrapper.XC_RunAssignmentsRules__c = wr.Opportunity.ExecuteAssignment;
        }
        opportunityFromWrapper.Description = wr.Opportunity.Description;

        opportunityFromWrapper.XC_CampaignPlatform__c = wr.Opportunity.CampaignPlatform; 
        opportunityFromWrapper.XC_CampaignProduct__c = wr.Opportunity.CampaignProduct;
        opportunityFromWrapper.XC_CampaignCode__c = wr.Opportunity.CampaignCode;
        opportunityFromWrapper.XC_ConventionCode__c = wr.Opportunity.ConventionCode; 
        opportunityFromWrapper.XC_Ecid__c = wr.Opportunity.ECID;
        //Servizio unico
        opportunityFromWrapper.XC_LeadID_EnelEnergia__c = wr.Opportunity.LeadID;
        opportunityFromWrapper.XC_LeadSourceCampaign__c = wr.Opportunity.LeadSourceCampaign;
        opportunityFromWrapper.XC_LeadChannelCategory__c = wr.Opportunity.LeadChannelCategory;
        opportunityFromWrapper.XC_SalesChannel__c = wr.Opportunity.SalesChannel;

        return opportunityFromWrapper;
    }   

    /**
     * Validate request.
     *
     * @param mapHeader the map header
     * @param params the request
     * @return the wrapper result
     * @description validate request
     */
    public static XC_UTIL_Integration.WrapperResult validateReadRequestOpportunity(Map<String, String> mapHeader, Map<String, String> params){
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Opportunity', 'read');
        if(validateResult.errorFlag){
            return validateResult; 
        } 

        List<String> oneOfTheseFields = new List<String>{  
            'AccountID',
            'ContactID',
            'OrderID',
            'WorkOrderID',
            'OpportunityID',
            'CaseID'
        };

        boolean ck = false;
        for(String field : oneOfTheseFields) {
            if(!string.isBlank(params.get(field))) {
                ck = true;
                break; 
            }
        }

        if(!ck){
            validateResult.errorMessage = 'ERROR. Missing one of these fields: AccountID, WorkOrderID, ContactID, OpportunityID, OrderID, CaseID';
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }


    /**
     * Validate request.
     *
     * @param request the request
     * @return the wrapper result
     * @description getOppResult
     */
    public static List<XC_UTIL_Opportunity.OpportunityIFWrapper> getOppResult(Map<String, String> request){
        List<XC_UTIL_Opportunity.OpportunityIFWrapper> result = new List<XC_UTIL_Opportunity.OpportunityIFWrapper>();

        String accId = request.get('AccountID');
        String woId = request.get('WorkOrderID');
        String conId = request.get('ContactID');
        String oppId = request.get('OpportunityID');
        String caseId = request.get('CaseID');
        String ordId = request.get('OrderID');

        String condition = '';
        if(!string.isBlank(request.get('AccountID'))){
            condition = 'AccountId =: accId';

        } else if(!string.isBlank(request.get('WorkOrderID'))){
            condition = 'XC_WorkOrder__c =: woId';

        } else if(!string.isBlank(request.get('ContactID'))){
            condition = 'XC_Contact__c =: conId';

        } else if(!string.isBlank(request.get('OpportunityID'))){
            condition = 'Id =: oppId';

        } else if(!string.isBlank(caseId)){
            condition = 'XC_CaseId__c =: caseId';

        } else if(!string.isBlank(ordId)){
            condition = 'id IN (SELECT NE__OptyId__c FROM NE__Order__c WHERE id =: ordId )';
        }

        String queryString = 
            'SELECT Id, AccountId, XC_Contact__c, XC_CaseId__c, XC_WorkOrder__c, XC_LegalEntity__c, Name, XC_ProductCategoryOfInterest__c, CloseDate, StageName, '+
            'XC_Source__c, CampaignId, XC_Score__c, XC_RunAssignmentsRules__c, Description, XC_Address__c, XC_ReceivingChannel__c, '+
            '(SELECT Id FROM NE__Orders__r WHERE id =: ordId ) FROM Opportunity WHERE '+condition;
        List<Opportunity> resOpp = Database.query(String.escapeSingleQuotes(queryString));

        if(resOpp.isEmpty()){
            return result;
        }

        for(Opportunity opp : resOpp){
            XC_UTIL_Opportunity.OpportunityIFWrapper wrOrd = new XC_UTIL_Opportunity.OpportunityIFWrapper();
            wrOrd.OpportunityID = opp.Id; 
            wrOrd.LegalEntity = opp.XC_LegalEntity__c;
            wrOrd.OpportunityName = opp.Name;
            //wrOrd.UniqueID = opp.
            wrOrd.AccountID = opp.AccountId;
            wrOrd.ContactID = opp.XC_Contact__c;
            wrOrd.ProductCategoryOfInterest = opp.XC_ProductCategoryOfInterest__c;
            wrOrd.CloseDate  = opp.CloseDate;
            wrOrd.Status = opp.StageName;
            wrOrd.ReceivingChannel = opp.XC_ReceivingChannel__c;
            wrOrd.Sources = opp.XC_Source__c;
            wrOrd.PrimaryCampaignSource = opp.CampaignId;
            wrOrd.Scoring = opp.XC_Score__c;
            wrOrd.ExecuteAssignment = opp.XC_RunAssignmentsRules__c;
            wrOrd.Description = opp.Description;
            wrOrd.AddressID = opp.XC_Address__c;
            wrOrd.WorkOrderID = opp.XC_WorkOrder__c;
            //wrOrd.ProductType = opp.
            result.add(wrOrd);
        }
    
        return result;
    }

    
    /**
     * checkOpportunityBlacklist.
     * @author            : Giuseppe Di Bonito - gdibonito@deloitte.it
     * @date Creation     : 26/03/2020
     * @param validateResult the result of validation 
     * @param opp the opportunity wrapper
     * @description validate zipcode
     */
    public static void checkOpportunityBlacklist(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Opportunity.OpportunityIFWrapper opp) {
            
        List<XC_UTIL_ZipCodeBlacklist.InputWrapper> blist = new List<XC_UTIL_ZipCodeBlacklist.InputWrapper>();
        XC_UTIL_ZipCodeBlacklist.InputWrapper b = new XC_UTIL_ZipCodeBlacklist.InputWrapper();
        String addId = opp.AddressID;
        Map<Id, XC_Address__c> add = new Map<Id, XC_Address__c>([SELECT Id, XC_PostalCode__c, XC_Account__r.XC_Segment__c FROM XC_Address__c WHERE id =: addId]);
        if(add.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_AddressNotFound;
            validateResult.errorCode = '400';
            validateResult.errorFlag = true;
            return;
        }
        b.productCategoryOfInterest = opp.ProductCategoryOfInterest;
        b.zipCode = add.get(addId).XC_PostalCode__c;
        blist.add(b);
        Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean> breturn = new Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean>();
        breturn = XC_UTIL_ZipCodeBlacklist.checkZipBlacklist(blist, opp.LegalEntity, add.get(addId).XC_Account__r.XC_Segment__c);

        if(breturn.get(b)) {
            validateResult.errorMessage = 'Product category of Interest selected is in blacklist for the zipcode provided';
            validateResult.errorCode = '492';
            validateResult.errorFlag = true;
            return;
        }
    }


    /**
    * @description create the opportunity record
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-03-2020 
    * @param req 
    * @param resp 
    * @param mapHeader 
    **/
    public static void manageInsert(WrapperRequest req, WrapperResponse resp, Map<String, String> mapHeader){
              
        List<Opportunity> opportunityToInsert = new List<Opportunity> {XC_REST_Opportunity_U.createOpportunityFromWrapper(req)};
        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.insertRecord(opportunityToInsert.get(0));
        if(result.success == false) {
            resp.Result.Message = 'INTERNAL ERROR. ' + result.errorMessage;
            resp.Result.ErrorCode = '500';
            // logError = result.errorMessage;
            return;
        } else {
            resp.Result.Message = 'Operation completed successfully';
            resp.Result.ErrorCode = '0'; 
            resp.Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();
            resp.Opportunity.OpportunityID = result.recordId;
            resp.Opportunity.ExecuteAssignment = null;                      
        }
    }

}