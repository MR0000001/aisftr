/**
* The Class XC_REST_Case_V.
*
* @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation     : 26/04/2019
* @date Modification : dd/mm/yyyy
* @description       : Util class for handling Case REST
**/


public without sharing class XC_REST_Case_V {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_Case_V');

    /**
* Validate Request.
*
* @param mapHeader the map header
* @param caseWrapperRequest the case wrapper request
* @param method the http method
* @return the wrapper result
* @description method to validate the request
*/
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest, String method) {
        
        XC_UTIL_Integration.WrapperResult validateResult;
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }
        
        if(method == 'POST') {
            validateResult = validatePOSTRequest(caseWrapperRequest, mapHeader.get('ClientSystem'));
        } else if(method == 'PUT') {
            validateResult = validatePUTRequest(caseWrapperRequest);
        }
        
        return validateResult;
    }
    
    
    /**
* ValidatePOSTRequest.
*
* @param caseWrapperRequest the case wrapper request
* @return the wrapper result
* @description method to validate the POST request
*/
    public static XC_UTIL_Integration.WrapperResult validatePOSTRequest(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest, String clientSystem) {
        
        XC_UTIL_Integration.WrapperResult wrapper = new XC_UTIL_Integration.WrapperResult();
        
        if(caseWrapperRequest.CaseX == null) {
            wrapper.errorFlag = true;
            wrapper.errorMessage = Label.XC_CL_MandatoryField +' Case';
            return wrapper;
        }
        
        Map<String, String> requiredParametersMap = new Map<String, String>();
        //COMMODITY 
        if(clientSystem == Label.XC_CL_CommoditySpainB2C /*|| String.isNotBlank(String.isblank(caseWrapperRequest.CaseX.AccountDNI)*/) {
            
            //requiredParametersMap.put('AccountDNI', caseWrapperRequest.CaseX.AccountDNI);
            //requiredParametersMap.put('ContractNumber', caseWrapperRequest.CaseX.ContractNumber);
            requiredParametersMap.put('LegalEntity', caseWrapperRequest.CaseX.LegalEntity);
            requiredParametersMap.put('Channel', caseWrapperRequest.CaseX.Channel);
            requiredParametersMap.put('CaseReason', caseWrapperRequest.CaseX.CaseReason);
            requiredParametersMap.put('CaseSubCause', caseWrapperRequest.CaseX.CaseSubCause);
            /*if(caseWrapperRequest.CaseX.CaseReason String.isNotBlank(= 'XCMOT009' && caseWrapperRequest.CaseX.CaseSubCause String.isNotBlank(= 'ATCL018'){
                requiredParametersMap.put('CaseSubType', caseWrapperRequest.CaseX.CaseSubType);
            }*/
            
        //EVERYTHING ELSE
        }
        //[ BEGIN, neeraj.saini@accenture.com, 11/4/2022, CTI integration, added new Condition]
        else if(clientSystem == Label.CTIBrazilB2C){
            requiredParametersMap.put('LegalEntity', caseWrapperRequest.CaseX.LegalEntity);
            if(String.isNotBlank(caseWrapperRequest.CaseX.FileBase64)){
                requiredParametersMap.put('FileBase64Name', caseWrapperRequest.CaseX.FileBase64Name);
            }
            requiredParametersMap.put('CaseReason', caseWrapperRequest.CaseX.CaseReason);
            requiredParametersMap.put('CaseSubCause', caseWrapperRequest.CaseX.CaseSubCause);
            requiredParametersMap.put('Channel', caseWrapperRequest.CaseX.Channel);
            requiredParametersMap.put('Country', caseWrapperRequest.CaseX.Country);
            requiredParametersMap.put('ProtocolNumber', caseWrapperRequest.CaseX.ProtocolNumber);
            requiredParametersMap.put('OwnerID', caseWrapperRequest.CaseX.OwnerID);
            requiredParametersMap.put('RequestJourney', caseWrapperRequest.CaseX.RequestJourney);
        }
        //[ END, neeraj.saini@accenture.com, 11/4/2022, CTI integration, added new Condition]
        else {
            
            requiredParametersMap.put('LegalEntity', caseWrapperRequest.CaseX.LegalEntity);
            if(caseWrapperRequest.CaseX.SkipAccountContact==null||!caseWrapperRequest.CaseX.SkipAccountContact){
                requiredParametersMap.put('AccountID', caseWrapperRequest.CaseX.AccountID);
            }
            if(String.isNotBlank(caseWrapperRequest.CaseX.FileBase64)){
                requiredParametersMap.put('FileBase64Name', caseWrapperRequest.CaseX.FileBase64Name);
            }
            requiredParametersMap.put('CaseReason', caseWrapperRequest.CaseX.CaseReason);
            requiredParametersMap.put('CaseSubCause', caseWrapperRequest.CaseX.CaseSubCause);
            requiredParametersMap.put('Channel', caseWrapperRequest.CaseX.Channel);
            requiredParametersMap.put('Country', caseWrapperRequest.CaseX.Country);
            //requiredParametersMap.put('Priority', caseWrapperRequest.CaseX.Priority);
        }
        
        for(String field : requiredParametersMap.keySet()) {
            if(String.isBlank(requiredParametersMap.get(field))) { 
                wrapper.errorFlag = true;
                wrapper.errorMessage = Label.XC_CL_MandatoryField +' Case.' + field;
                return wrapper;
            }
        }
        return wrapper;
    }
    
    
    /**
* ValidatePUTRequest.
*
* @param caseWrapperRequest the case wrapper request
* @return the XC_UTIL_Integration.WrapperResult
* @description method to validate the PUT request
*/
    public static XC_UTIL_Integration.WrapperResult validatePUTRequest(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest) {
        
        XC_UTIL_Integration.WrapperResult wrapper = new XC_UTIL_Integration.WrapperResult();
        
        if(caseWrapperRequest.Casex == null) {
            wrapper.errorFlag = true;
            wrapper.errorMessage = Label.XC_CL_MandatoryField +' Case';
            return wrapper;
        }
        
        if(String.isBlank(caseWrapperRequest.CaseX.CaseId) &&
           String.isBlank(caseWrapperRequest.CaseX.CaseNumber)) {
               wrapper.errorFlag = true;
               wrapper.errorMessage = Label.XC_CL_MandatoryField +' Case.CaseID or Case.CaseNumber';
               return wrapper;
           }
        
        return wrapper;
    }
    
    
    /**
* Manage Get Case.
*
* @param params the request params map
* @param wrResp The wrapper response
* @description method to manage the get case
*/
    public static void manageGetCase(Map<String, String> params, XC_REST_Case_W.WrapperCaseResponseGET wrResp) {
        
        wrResp.CaseList = new List<XC_UTIL_Case.CaseRESTWrapper>();
        
        List<XC_UTIL_Case.CaseRESTWrapper> listCase = new List<XC_UTIL_Case.CaseRESTWrapper>();
        if (String.isNotBlank(params.get('AccountID')) || String.isNotBlank(params.get('PrimaryEmail')) || String.isNotBlank(params.get('IdentityNumberAccount'))){
            
            checkDate(params, wrResp);
            if(wrResp.Result.ErrorCode != '0') {
                return;
            }
            
            XC_REST_Case_W.WrapperAccount acc = XC_REST_Case_W.createAccountWrapper(params);
            listCase = XC_REST_Case_U.getCasesByAccount(acc);
            
        } else {
            listCase = manageGetCasePlus(params, wrResp);
            if(wrResp.Result.ErrorCode != '0') {
                return;
            }
        }
        
        if(!listCase.isEmpty()) {
            wrResp.Result.Message = 'Operation completed successfully'; /* Error in parsing the url */
            wrResp.Result.ErrorCode = '0';
            for(XC_UTIL_CASE.CaseRESTWrapper wr : listCase) {
                System.debug('@@@ add wr @@@');
                wrResp.CaseList.add(wr);
            }
        } else {
            wrResp.Result.Message = 'ERROR. Cases Not Found';
            wrResp.Result.ErrorCode = '400';
            wrResp.CaseList = new List<XC_UTIL_Case.CaseRESTWrapper>();
        }
    }
    
    
    /**
* Manage Get Case Plus.
*
* @param params the request params map
* @param wrResp The wrapper response
* @return the case wrapper list
* @description method to manage the get case
*/
    public static List<XC_UTIL_Case.CaseRESTWrapper> manageGetCasePlus(Map<String, String> params, XC_REST_Case_W.WrapperCaseResponseGET wrResp) {
        
        List<XC_UTIL_Case.CaseRESTWrapper> listCase = new List<XC_UTIL_Case.CaseRESTWrapper>();
        if(String.isNotBlank(params.get('ContactID')) || String.isNotBlank(params.get('Email')) || String.isNotBlank(params.get('IdentityNumberContact'))) {
            
            checkDate(params, wrResp);
            if(wrResp.Result.ErrorCode != '0') {
                return new List<XC_UTIL_Case.CaseRESTWrapper>();
            }
            
            XC_REST_Case_W.WrapperContact con = XC_REST_Case_W.createContactWrapper(params);
            listCase = XC_REST_Case_U.getCasesByContact(con);
            
        } else if(String.isNotBlank(params.get('CaseID')) || String.isNotBlank(params.get('CaseNumber'))) {
            
            System.debug('@@@ ' + params.get('CaseID'));
            System.debug('@@@ ' + params.get('CaseNumber'));
            XC_UTIL_Case.CaseRESTWrapper caseWrapper = XC_REST_Case_W.createCaseWrapper(params);
            listCase = XC_REST_Case_U.getCasesByID(caseWrapper);
            
        } else {
            wrResp.Result.Message = Label.XC_CL_NoKey;
            wrResp.Result.ErrorCode = '400';
            return new List<XC_UTIL_Case.CaseRESTWrapper>();
        }
        
        wrResp.Result.ErrorCode = '0';
        return listCase;
    }
    
    
    /**
* Check Date.
*
* @param params the request params map
* @param wrResp The wrapper response
* @description method to check date in GET Case
*/
    public static void checkDate(Map<String, String> params, XC_REST_Case_W.WrapperCaseResponseGET wrResp) {
        
        if(String.isBlank(params.get('StartDate')) || String.isBlank(params.get('EndDate'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField +' StartDate or EndDate';
            wrResp.Result.ErrorCode = '400';
            return;
        }
        
        if(!XC_UTIL_RESTInbound.checkDate(params.get('StartDate') + ' 00:00:00')) {
            wrResp.Result.Message = 'ERROR. StartDate '+ Label.XC_CL_DateFormat_Error;
            wrResp.Result.ErrorCode = '400';
            return;
        } else if(!XC_UTIL_RESTInbound.checkDate(params.get('EndDate') + ' 23:59:59')) {
            wrResp.Result.Message = 'ERROR. EndDate '+ Label.XC_CL_DateFormat_Error;
            wrResp.Result.ErrorCode = '400';
            return;
        }
        
        wrResp.Result.ErrorCode = '0';
    }
    
    
    /**
* CreateCaseToInsert.
*
* @param caseWrapperRequest the case wrapper request
* @param accountId the account Id
* @param contactId the contact Id
* @return the case
* @description method to create a Case to insert
*/
    public static Case createCaseToInsert(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest, String accountId, String contactId) {
    
        Case c = XC_UTIL_Case.createCaseFromWrapper(caseWrapperRequest.CaseX, accountId, contactId);
        c.XC_IsCloned__c = true;
        if(String.isNotBlank(caseWrapperRequest.CaseX.SubscriptionID)) {
            List<Asset> assetList = XC_REST_Asset_U_D.getAssetBySusbscription(caseWrapperRequest.CaseX.SubscriptionID, '');
            c.AssetId = (assetList.size() > 0) ? assetList[0].Id : null;
        }
        
        //if(caseWrapperRequest.CaseX.CaseReason=='XCMOT008' && caseWrapperRequest.CaseX.CaseSubCause=='ATCL073' && caseWrapperRequest.CaseX.CaseSubType=='XC106'){
            //c.XC_Description__c = caseWrapperRequest.CaseX.Description; Per ora utilizziamo il campo description standard. Scommentare in caso non vada bene
            c.XC_ContractID__c = caseWrapperRequest.CaseX.ContractNumber;
        //}
        if(String.isNotBlank(caseWrapperRequest.CaseX.ZuoraInvoiceID)) {
            Map<Id,Zuora__ZInvoice__c> mapZ = new Map<Id,Zuora__ZInvoice__c>([
                SELECT Id
                FROM Zuora__ZInvoice__c
                WHERE Zuora__External_Id__c =: caseWrapperRequest.CaseX.ZuoraInvoiceID
            ]);
            
            if( !mapZ.values().isEmpty()){
                c.XC_Invoice__C = mapZ.values()[0].Id;
            }
        }   
        manageLinkAsset(caseWrapperRequest, c);

        // set recordTypeId
        /*List<Case> caseList = new List<Case>();
        caseList.add(c);
        Map<String,String> reasonRecordTypeMap = XC_UTIL_Case.getCaseRecordType(caseList);
        if(reasonRecordTypeMap.isEmpty()){
            c.RecordTypeId = XC_UTIL_Case.getDefaultCaseRecordType(c.XC_LegalEntity__c);
        } else {
            c.RecordTypeId = reasonRecordTypeMap.get(c.Reason);
        }*/
            
        return c;
    }
    
    
    /**
* CreateCaseToUpdate.
*
* @param caseWrapperRequest the case wrapper request
* @param caseId the case Id
* @return the case
* @description method to create a Case to update
*/
    public static Case createCaseToUpdate(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest, Id caseId) {
        
        Case c = XC_UTIL_Case.createCaseFromWrapper(caseWrapperRequest.CaseX, caseWrapperRequest.CaseX.AccountID, caseWrapperRequest.CaseX.ContactID);
        c.Id = caseId;
        c.XC_IsCloned__c = true;
        if(String.isNotBlank(caseWrapperRequest.CaseX.SubscriptionID)) {
            List<Asset> assetList = XC_REST_Asset_U_D.getAssetBySusbscription(caseWrapperRequest.CaseX.SubscriptionID, '');
            c.AssetId = (assetList.size() > 0) ? assetList[0].Id : null;
        }

        if(String.isNotBlank(caseWrapperRequest.CaseX.ZuoraInvoiceID)) {
            Map<Id,Zuora__ZInvoice__c> mapZ = new Map<Id,Zuora__ZInvoice__c>([
                SELECT Id
                FROM Zuora__ZInvoice__c
                WHERE Zuora__External_Id__c =: caseWrapperRequest.CaseX.ZuoraInvoiceID
            ]);
            
            if(!mapZ.values().isEmpty()){
                c.XC_Invoice__C = mapZ.values()[0].Id;
            }
        }   

        manageLinkAsset(caseWrapperRequest, c);

        return c;
    }


    public static void manageLinkAsset(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest,Case c){

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ manageLinkAsset');

        if( !String.isBlank(caseWrapperRequest.casex.Description) && caseWrapperRequest.casex.Description.contains('Delete') && c.XC_EnergyVasContractNumberOfDays__c!= null && c.XC_EnergyContractedPower__c!= null && !String.isBlank(String.valueOf(c.AccountID))  ){
            List<String> descrField = new List<String>();
            descrField = (caseWrapperRequest.casex.Description).split(';');
            for( String field : descrField){
                if(field.contains('Address')){
                    List<String> addressField = new List<String>();
                    field = field.removeStart('Address:');
                    addressField = field.split('\\|',-1);
                    String code = descrField[0].removeStart('Delete,');

                    List<Asset> assetList = getAssetbyCase(c.AccountID,addressField,code);
                    if(!assetList.isEmpty() && assetList.size() == 1 ){
                        c.AssetId = assetList[0].Id;
                    }else{  
                        c.XC_AutomaticDeactivationError__c = 'Error to find the asset by field Description for code: '+ code + ' with Account: ' + c.AccountID + ' and fieldAddress: ' + addressField ;
                        System.debug('Error to find the asset by field Description');
                        System.debug('AssetList: ' + assetList);
                        c.addError('Error to find the asset by field Description ');
                    }
                    
                }
            }
        }
    }
    public static List<Asset> getAssetbyCase(String accountId, List<String> addressField, String code){

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ getAssetbyCase');
        List<Asset> assList = new List<Asset>();
        String query = 'SELECT Id FROM Asset';
        System.debug('Address Field: ' + addressField);
        System.debug('Size: '+ addressField.size() ); 

        if (String.isNotBlank(accountId) ){
            query += ' WHERE AccountId =: accountId';
        }

        if (String.isNotBlank(code) ){
            query += ' AND NE__CatalogItem__r.NE__UsageCode__c =: code';
        }

        if (String.isNotBlank( addressField[0])) {
            String country = addressField[0];
            query += ' AND XC_Address__r.XC_AddressCountry__c = :country';
        }

        if (String.isNotBlank(addressField[1]) ) {
            String province = addressField[1];
            query += ' AND XC_Address__r.XC_AddressProvince__c = :province';
        }

         if (String.isNotBlank(addressField[2]) ) {
            String city = addressField[2];
            query += ' AND XC_Address__r.XC_City__c = :city';
        }

        if (String.isNotBlank(addressField[3]) ) {
            String postalCode = addressField[3];
            query += ' AND XC_Address__r.XC_PostalCode__c = :postalCode';
        }

         if (String.isNotBlank(addressField[4]) ) {
            String streetType = addressField[4];
            query += ' AND XC_Address__r.XC_StreetTypeText__c = :streetType';
        }


         if (String.isNotBlank(addressField[5]) ) {
            String addr = addressField[5];
            query += ' AND XC_Address__r.XC_Address__c = :addr';
        }

         if (String.isNotBlank(addressField[6]) ) {
            String streetNumb = addressField[6];
            query += ' AND XC_Address__r.XC_StreetNumber__c = :streetNumb';
        }

         if (String.isNotBlank(addressField[7]) ) {
            String stair = addressField[7];
            query += ' AND XC_Address__r.XC_Stair__c = :stair';
        }

        if (String.isNotBlank(addressField[8]) ) {
            String floor = addressField[8];
            query += ' AND XC_Address__r.XC_Floor__c = :floor';
        }


        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Query Asset: '+query );
        System.debug('query:' + query);

        assList = (List<Asset>) Database.query(String.escapeSingleQuotes(query));
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'AssetList retrivata: ' + assList );

        return assList;

    }




}