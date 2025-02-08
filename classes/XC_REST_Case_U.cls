/**
 * The Class XC_REST_Case_U.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 24/12/2018
 * @date Modification : 03/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Util class for handling Case REST
 * @date Modification : 20/04/2022 INC000084477669 by mario.a.giordano@accenture.com- Add this fields XC_InstallationCost__c, XC_PermittingCost__c, XC_Design__c
 **/
public without sharing class XC_REST_Case_U { 

    private static final String QUERY_FIELDS =   
        'SELECT Id, Type, Type_Notification__c, Reason, Channel_Type__c, Country__c, Origin, XC_Opportunity__c, Priority, CreatedDate, ClosedDate, Account.XC_UniqueId__c, '+
        'OwnerId,XC_ProtocolNumber__c,XC_RequestJourney__c, Status, XC_ProductCategoryOfInterest__c, AccountId, Description, XC_WorkOrder__c, XC_Order__c, AssetId, Asset.Name, SubCause__c, XC_Subtype__c, '+
        'XC_Address__c, XC_OrderItem__c, ContactPhone__c, NotificationEmail__c, XC_Contact_Preferred_Time__c, Subject, XC_ReclamationCounter__c, Responsible__c, '+
        'Account.RecordType.Name, Asset.NE__CatalogItem__r.NE__Engine_Code__c, Asset.NE__CatalogItem__r.XC_Brand__c, ContactId, CaseNumber, ParentId, XC_TechnicalAsset__c, '+
        'XC_Receiving_Channel__c, XC_SubStatus__c, XC_Channel_Attribute__c, ContactMobile, ContactEmail, XC_Resolution__c, CaseRemarks__c, XC_Result__c, XC_Invoice__c, XC_GeolocalizationCountry__c,' +
        'XC_Type_Intermediary__c, XC_ContactPhone__c, XC_ContactEmail__c,XC_eCityProductArea__c,  XC_InstallationCost__c, XC_PermittingCost__c, XC_Design__c, (SELECT Id, CommentBody, CreatedDate FROM CaseComments ORDER BY CreatedDate desc), '+
        '(SELECT Id, MilestoneType.Name, StartDate, TargetDate, CompletionDate, IsCompleted, IsViolated from CaseMilestones) '+
        'FROM Case WHERE ';   

    /**
     * GetCasesByAccount.
     *
     * @param accountWrapper the account wrapper
     * @return the cases by account
     * @description method to get cases by Account
     */
    public static List<XC_UTIL_Case.CaseRESTWrapper> getCasesByAccount(XC_REST_Case_W.WrapperAccount accountWrapper) {
        List<XC_UTIL_Case.CaseRESTWrapper> listCaseWrapper = new List<XC_UTIL_Case.CaseRESTWrapper>();
        
        List<Case> listCase = doQueryByAccount(accountWrapper); 

        /*
        if(String.isNotBlank(accountWrapper.IdentityNumber) && (listCase.isEmpty() || listCase[0].Account.RecordType.Name == 'Residential')) {
            Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT Id, (
                    SELECT Id, XC_DocumentNumber__c 
                    FROM Personal_Documents__r 
                    WHERE XC_DocumentNumber__c =: accountWrapper.IdentityNumber) 
                FROM Account 
                WHERE Id IN (
                    SELECT XC_Account__c 
                    FROM XC_PersonalDocument__c 
                    WHERE XC_DocumentNumber__c =: accountWrapper.IdentityNumber
                    )
                ]);
            List<Account> accList = accMap.values();

            DateTime startDate = DateTime.valueOf(accountWrapper.StartDateOfCase);
            DateTime endDate = DateTime.valueOf(accountWrapper.EndDateOfCase);
            Map<Id, Case> caseMap = new Map<Id, Case>([
                SELECT Id, Type, Type_Notification__c, Reason, Channel_Type__c, Country__c, Origin, XC_Opportunity__c, Priority, CreatedDate, ClosedDate, OwnerId, 
                Status, XC_ProductCategoryOfInterest__c, AccountId, Description, XC_WorkOrder__c, XC_Order__c, AssetId, Asset.Name, SubCause__c, XC_Subtype__c, ContactId, 
                CaseNumber, ParentId, XC_Address__c, XC_OrderItem__c, ContactPhone__c, NotificationEmail__c, XC_Contact_Preferred_Time__c, Subject, XC_ReclamationCounter__c, 
                Responsible__c, Account.RecordType.Name, Asset.NE__CatalogItem__r.NE__Engine_Code__c, Asset.NE__CatalogItem__r.XC_Brand__c, 
                (SELECT Id, CommentBody, CreatedDate FROM CaseComments ORDER BY CreatedDate desc) 
                FROM Case 
                WHERE AccountId =: accList[0].Id AND CreatedDate >=: startDate AND CreatedDate <=: endDate
            ]);
            listCase = caseMap.values();
        }
        */

        for(Case c : listCase) {
            XC_UTIL_Case.CaseRESTWrapper wrapper = XC_UTIL_Case.createWrapperFromCase(c, c.CaseComments);
            listCaseWrapper.add(wrapper);
        }

        return listCaseWrapper;
    }


    /**
     * Do Query By Account.
     *
     * @param accountWrapper the account wrapper
     * @return the cases by account
     * @description method to do query
     */
    public static List<Case> doQueryByAccount(XC_REST_Case_W.WrapperAccount accountWrapper) {

        String primaryEmail = accountWrapper.PrimaryEmail;
        String identityNumber = accountWrapper.IdentityNumber;
        String accountID = accountWrapper.AccountID;
        DateTime startDate = DateTime.valueOf(accountWrapper.StartDateOfCase);
        DateTime endDate = DateTime.valueOf(accountWrapper.EndDateOfCase); 
        String origin = accountWrapper.Origin;
        /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [start]*/
        //String query = QUERY_FIELDS;
        String query = XC_UTIL_TranslationWorkbench.toLabelizeQueryFields('Case',  XC_REST_Case.currentClientSystem, QUERY_FIELDS);
        /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [end]*/
        if (!String.isBlank(primaryEmail)) {
            query += 'Account.PrimaryEmail__c =: primaryEmail';

        } else if (!String.isBlank(identityNumber)) {
            query += 'Account.IdentityNumber__c =: identityNumber';

        } else if (!String.isBlank(accountID)) {
            query += 'AccountID =: accountID';

        }

        query += ' AND CreatedDate >=: startDate AND CreatedDate <=: endDate';

        if( !String.isBlank(origin)){
            query += ' AND Origin = :origin';
        }
        System.debug('QUERY -> ' + query.split('WHERE')[1]);
        return (List<Case>) Database.query(query);    
    }
    

    /**
     * GetCasesByContact.
     *
     * @param contactWrapper the contact wrapper
     * @return the cases by contact
     * @description method to get case by Contact
     */
    public static List<XC_UTIL_Case.CaseRESTWrapper> getCasesByContact(XC_REST_Case_W.WrapperContact contactWrapper) {

        List<XC_UTIL_Case.CaseRESTWrapper> listCaseWrapper = new List<XC_UTIL_Case.CaseRESTWrapper>();

        /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [start]*/
        //String query = QUERY_FIELDS;
        String query = XC_UTIL_TranslationWorkbench.toLabelizeQueryFields('Case',  XC_REST_Case.currentClientSystem, QUERY_FIELDS);
        /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [end]*/

        String email = contactWrapper.Email;
        String contactID = contactWrapper.ContactId; 

        String origin = contactWrapper.Origin;
        
        if (!String.isBlank(email)) {
            query += 'Contact.Email =: email';

        } else if (!String.isBlank(contactID)) {
            query += 'ContactId =: contactID';

        }
        if( !String.isBlank(origin)){
            query += ' AND Origin = :origin';
        }

        DateTime startDate = DateTime.valueOf(contactWrapper.StartDateOfCase);
        DateTime endDate = DateTime.valueOf(contactWrapper.EndDateOfCase);
        query += ' AND CreatedDate >=: startDate AND CreatedDate <=: endDate';

        if( !String.isBlank(origin) ){
            query += ' AND Origin = :origin';
        }
        System.debug('QUERY ' + query);
        List<Case> listCase = (List<Case>) Database.query(String.escapeSingleQuotes(query));
        for(Case c : listCase) {
            XC_UTIL_Case.CaseRESTWrapper wrapper = XC_UTIL_Case.createWrapperFromCase(c, c.CaseComments);
            listCaseWrapper.add(wrapper);
        }

        return listCaseWrapper;
    }


    /**
     * GetCasesByID.
     *
     * @param caseWrapper the case wrapper
     * @return the cases by ID
     * @description method to get Case
     */
    public static List<XC_UTIL_Case.CaseRESTWrapper> getCasesByID(XC_UTIL_Case.CaseRESTWrapper caseWrapper) {
        List<XC_UTIL_Case.CaseRESTWrapper> listCaseWrapper = new List<XC_UTIL_Case.CaseRESTWrapper>();

        /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [start]*/
        //String query = QUERY_FIELDS;
        String query = XC_UTIL_TranslationWorkbench.toLabelizeQueryFields('Case',  XC_REST_Case.currentClientSystem, QUERY_FIELDS);
        /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [end]*/

        String caseId = caseWrapper.CaseID;
        String caseNum = caseWrapper.CaseNumber;

        if(!String.isBlank(caseId)) {
            query += 'Id =: caseId';

        } else {
            query += 'CaseNumber =: caseNum';

        }

        List<Case> listCase = (List<Case>) Database.query(query);
        for(Case c : listCase) {
            XC_UTIL_Case.CaseRESTWrapper wrapper = XC_UTIL_Case.createWrapperFromCase(c, c.CaseComments);
            listCaseWrapper.add(wrapper);
        }

        return listCaseWrapper;
    }


    /**
     * InsertCaseByWrapper.
     *
     * @param caseWrapperRequest the case wrapper request
     * @param clientSystem the client System
     * @return the wrapper case response upsert
     * @description method to insert a Case
     */
    public static XC_REST_Case_W.WrapperCaseResponseUpsert insertCaseByWrapper(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest, String clientSystem) {

        XC_REST_Case_W.WrapperCaseResponseUpsert wrapperResponse = new XC_REST_Case_W.WrapperCaseResponseUpsert();

        String accountId;
        String contactId;

        
        Set<String> setFields = new Set<String>{'Id'};
        List<Account> listAcc = new List<Account>();
        case c = new case();

        if(caseWrapperRequest.CaseX.SkipAccountContact==null||!caseWrapperRequest.CaseX.SkipAccountContact){
            //ACCOUNT DNI START (GDB)
            if(String.isNotBlank(caseWrapperRequest.casex.AccountDNI)){
                List<String> docData = new List<String>();
                docData = (caseWrapperRequest.casex.AccountDNI).split('\\|');
                Map<Id, XC_PersonalDocument__c> docMap = new Map<Id, XC_PersonalDocument__c>([
                    SELECT XC_Account__c, XC_DocumentType__c 
                    FROM XC_PersonalDocument__c 
                    WHERE XC_DocumentNumber__c =: docData[1] AND XC_Account__c!= null
                    ]);
                if(!docMap.isEmpty()) {
                    for(XC_PersonalDocument__c pd : docMap.values()){
                        //if(pd.XC_DocumentType__c == docData[0]){
                            Account a = new Account();
                            a.id = pd.XC_Account__c;
                            listAcc.add(a);
                            continue;
                        //}
                    }
                } else{
                    Map<Id, Account> accMap = new Map<Id, Account>([
                        SELECT Id
                        FROM Account 
                        WHERE /*IdentityType__c =: docData[0] AND*/ IdentityNumber__c =: docData[1]
                        LIMIT 1
                        ]);
                    if(!accMap.isEmpty()) {
                        listAcc.add(accMap.values()[0]);
                    }
                }
            } else{ //ACCOUNT DNI END
                listAcc = (List<Account>) XC_UTIL_Query.selectFieldsList(setFields, caseWrapperRequest.casex.AccountID);
            }

            if(listAcc.isEmpty()) {
                wrapperResponse.Result.Message = Label.XC_CL_AccountNotFound;
                wrapperResponse.Result.ErrorCode = '400';
                return wrapperResponse;
            } else {
                accountId = listAcc.get(0).Id;
            }

            List<Contact> listCon;
            if(String.isBlank(caseWrapperRequest.casex.ContactID)){
                listCon = new Map<id,Contact>([select id from Contact where Accountid=:accountId and XC_PrimaryContact__c=true]).values();
            } else {
                listCon = (List<Contact>) XC_UTIL_Query.selectFieldsList(setFields, caseWrapperRequest.casex.ContactID);
            }

            if(listCon.isEmpty()) {
                wrapperResponse.Result.Message = Label.XC_CL_ContactNotFound;
                wrapperResponse.Result.ErrorCode = '400';
                return wrapperResponse;
            } else {
                contactId = listCon.get(0).Id;
            }

            c = XC_REST_Case_V.createCaseToInsert(caseWrapperRequest, accountId, contactId);
        } else {
            c = XC_REST_Case_V.createCaseToInsert(caseWrapperRequest, null, null);
        }

        assignmentRulesEvaluation(c);
        //c.Description = (clientSystem == Label.XC_CL_CommoditySpainB2C && c.Description != null) ? c.Description.split(';')[0] : c.Description;

        List<Case> cList = new List<Case>();
        if(!String.isBlank(c.XC_Invoice__C)&&(c.XC_Subtype__c=='XC029'||c.XC_Subtype__c=='XC027')){
            cList = createCasesForDunning(c);
        } else if(!String.isBlank(c.XC_Invoice__C)&&c.Reason == 'XCMOT007'&&c.SubCause__c == 'ATCL017'){
            resumeAssetForDunning(c);
            cList = createCasesForDunning(c);
        } else {
            cList.add(c);
        }
        
        List<XC_UTIL_Sobject.WrapperResult> wrappers = XC_UTIL_Sobject.insertListRecords(cList);
        for(XC_UTIL_Sobject.WrapperResult wrapper:wrappers){
            if(!wrapper.success) {
                wrapperResponse.Result.ErrorCode = '500';
                wrapperResponse.Result.Message = 'INTERNAL ERROR: ' + wrapper.errorMessage;
                return wrapperResponse;
            }
        }

        /*if(clientSystem == 'XRecharge') {
            Task t = new Task();
            t.WhatId = c.Id;
            t.WhoId = c.ContactId;
            t.Subject = 'Other';
            t.Type = 'Other';
            t.Description = 'Finalize Case';
            XC_UTIL_Sobject.WrapperResult wrapperTask = XC_UTIL_Sobject.insertRecord(t);
            if(!wrapperTask.success) {
                wrapperResponse.Result.ErrorCode = '500';
                wrapperResponse.Result.Message = 'INTERNAL ERROR: ' + wrapperTask.errorMessage;
                return wrapperResponse;
            }
        }*/
        
        if(cList.isEmpty()){
            wrapperResponse.Result.ErrorCode = '500';
            wrapperResponse.Result.Message = 'Error. Couldn\'t retrieve assets for this invoice' ;
            return wrapperResponse;
        }

        //create file
        if(String.isNotBlank(caseWrapperRequest.casex.filebase64)){
            XC_UTIL_SObject.WrapperResult r = insertFile(caseWrapperRequest,cList[0].id);
            if(!r.success){
                wrapperResponse.Result.ErrorCode = '500';
                wrapperResponse.Result.Message = 'INTERNAL ERROR: '+r.errorMessage;
                return wrapperResponse;
            }
            XC_REST_SendCaseFileToDoxee fileSendRequest = new XC_REST_SendCaseFileToDoxee(cList[0].id);
            System.enqueueJob(fileSendRequest); 
        }

        wrapperResponse.Result.ErrorCode = '0';
        wrapperResponse.Result.Message = Label.XC_CL_OperationCompleted;
        wrapperResponse.CaseItem = createWrapperFromCasePostPut(cList[0]);
        return wrapperResponse;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param caso Case to evaluate
     * @description set Assignment rule option if Case is from Market
     */
    private static void assignmentRulesEvaluation(Case caso){
         boolean fromZuora=false;
        if(caso.origin=='CAN002' &&
           caso.XC_Segment__c=='B2B' || caso.XC_Segment__c=='B2G' || caso.XC_Segment__c=='B2C'){
               fromZuora=true;
           }
        if(caso.Origin != 'CAN007' &&
           fromZuora==false
          ){
            return;
        }
        system.debug('fromZuora '+fromZuora);     
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
		dmlOpts.EmailHeader.TriggerUserEmail = true;
        caso.setOptions(dmlOpts);
    }
    

    /**
     * UpdateCaseByWrapper.
     *
     * @param caseWrapperRequest the case wrapper request
     * @return the wrapper case response upsert
     * @description method to update a Case
     */
    public static XC_REST_Case_W.WrapperCaseResponseUpsert updateCaseByWrapper(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest) {

        XC_REST_Case_W.WrapperCaseResponseUpsert wrapperResponse = new XC_REST_Case_W.WrapperCaseResponseUpsert();

        String caseId = caseWrapperRequest.CaseX.CaseID;
        String caseNumber = caseWrapperRequest.CaseX.CaseNumber;

        String query = 'SELECT Id, CaseNumber, SubCause__c, Reason, AccountID, ContactID FROM Case WHERE ';

        if (!String.isBlank(caseWrapperRequest.CaseX.CaseID)) { 
            query += 'Id =: caseId'; 

        } else if (!String.isBlank(caseWrapperRequest.CaseX.CaseNumber)) {
            query += ' AND CaseNumber =: caseNumber';

        } else if (!String.isBlank(caseWrapperRequest.CaseX.CaseNumber)) {
            query += 'CaseNumber =: caseNumber';

        }

        List<Case> listCase = (List<Case>) Database.query(String.escapeSingleQuotes(query));
        if(listCase.isEmpty()) {
            wrapperResponse.Result.ErrorCode = '400';
            wrapperResponse.Result.Message = Label.XC_CL_CTIContactCase_NOMatch;
            return wrapperResponse;
        }
        
        caseWrapperRequest.CaseX.AccountID = String.isNotBlank(caseWrapperRequest.CaseX.AccountID) ? caseWrapperRequest.caseX.AccountID : listCase.get(0).AccountId;
        Case c = XC_REST_Case_V.createCaseToUpdate(caseWrapperRequest, listCase.get(0).Id);
        XC_UTIL_Sobject.WrapperResult wrapper = XC_UTIL_Sobject.updateRecord(c);
        if(!wrapper.success) {
            wrapperResponse.Result.ErrorCode = '500';
            wrapperResponse.Result.Message = 'INTERNAL ERROR: ' + wrapper.errorMessage;
            return wrapperResponse;
        }   

        wrapperResponse.Result.ErrorCode = '0';
        wrapperResponse.Result.Message = 'Operation completed successfully';
        wrapperResponse.CaseItem = createWrapperFromCasePostPut(c);
        return wrapperResponse; 
    }


    /**
     * CreateWrapperFromCasePostPut.
     *
     * @param c the case
     * @return the XC_UTIL_Case.CaseRESTWrapper
     * @description method to populate the case wrapper response
     */
    public static XC_UTIL_Case.CaseRESTWrapper createWrapperFromCasePostPut(Case c) {

        XC_UTIL_Case.CaseRESTWrapper wrapper = new XC_UTIL_Case.CaseRESTWrapper();

        Set<String> setFields = new Set<String>{'Id', 'AccountID', 'ContactID', 'CaseNumber', 'SubCause__c', 'Reason'};
        Case cQ = (Case) XC_UTIL_Query.selectFields(setFields, c.ID);
        wrapper.CaseID = c.ID;
        wrapper.CaseNumber = cQ.CaseNumber;
        wrapper.CaseReason = cQ.Reason;
        wrapper.CaseSubCause = cQ.SubCause__c;
        wrapper.AccountID = cQ.AccountID;
        wrapper.ContactID = cQ.ContactID;
        //Missing UniqueID

        return wrapper;
    }



    private static List<Case> createCasesForDunning(Case c){
        List<Case> res = new List<Case>();

        Map<Id,Asset> mapAss = XC_UTIL_Asset.getAssetsFromInvoice(c.XC_Invoice__C);
        if(mapAss.values().isEmpty()){
            return res;
        }

        Map<Id,Asset> assListRes = new Map<Id,Asset>();
        for(Asset a:mapAss.values()){
            if(!String.isBlank(a.NE__Bundle_Configuration__c)){
                assListRes.put(a.NE__Bundle_Configuration__c,mapAss.get(a.NE__Bundle_Configuration__c));
            } else if(!String.isBlank(a.NE__Root_Order_Item__c)){
                assListRes.put(a.NE__Root_Order_Item__c,mapAss.get(a.NE__Root_Order_Item__c));
            } else {
                assListRes.put(a.Id,a);
            }
        }

        set<Case> setRes = new set<Case>();
        for(String s:assListRes.keySet()){
            //@Author: Luca Calicchio lcalicchio@deloitte.it
            //@Date: 30/07/2021
            //INC000048884707: Check if it is a case from zuora with reason XCMOT009 and subcause ATCL013
            //It this case it is not possible to create a case of type XC_AssetSuspension if it is a child with Billing product type.
            //The child case has the parentId of the parent case with the same XC_Invoice__r.Id 
            Id parentId;
            Map<String, XC_CM_Case_Type_Setting__mdt> caseMDT = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_AssetSuspension'});
            if(c.Reason == caseMDT.get('XC_AssetSuspension').XC_Case_Reason__c && c.SubCause__c == caseMDT.get('XC_AssetSuspension').XC_Sub_Cause__c){
                //retrieve asset
                List<Asset> asset = [SELECT  Id, XC_Product_Type__c FROM Asset WHERE Id =: s];
                if (!asset.isEmpty()){
                    if(asset[0].XC_Product_Type__c == 'Billing'){
                        continue;
                    }else{
                        List<Case> parentCase = [SELECT  Id, ParentId FROM Case WHERE XC_Invoice__r.Id =: c.XC_Invoice__c AND AccountId =: c.AccountId AND Asset.Id='' AND Reason =: caseMDT.get('XC_AssetSuspension').XC_Case_Reason__c AND SubCause__c=: caseMDT.get('XC_AssetSuspension').XC_Sub_Cause__c ];
                        if(!parentCase.isEmpty()){
                            parentId = parentCase[0].Id;
                        }
                    }
                }
            } 
            //END INC000048884707
            Case cn = new Case();
            cn.XC_LegalEntity__c = c.XC_LegalEntity__c; 
            cn.Reason = c.Reason; 
            cn.SubCause__c = c.SubCause__c;
            cn.XC_Subtype__c = c.XC_Subtype__c;
            cn.Origin = c.Origin;
            cn.XC_OriginChannel__c = c.XC_OriginChannel__c;
            cn.Country__c = c.Country__c;
            cn.Priority = c.Priority;
            cn.Status = c.Status;
            cn.AccountId = c.AccountId;
            cn.ContactId = c.ContactId;
            cn.XC_IsCloned__c = c.XC_IsCloned__c;
            cn.XC_Invoice__c = c.XC_Invoice__c;
            if (parentId!= null)
                cn.ParentId = parentId;
            //cn.RecordTypeId = c.RecordTypeId;
            cn.AssetId = s;

            if(c.Reason != 'XCMOT007'){
                if(mapAss.get(s).NE__Catalog__r.Name=='e-Home ES'){
                    cn.XC_Subtype__c = 'XC029';
                } else if(mapAss.get(s).NE__Catalog__r.Name=='e-Mobility ES'){ 
                    cn.XC_Subtype__c = 'XC027';
                } 
                if(mapAss.get(s).XC_Product_Type__c!='Service'){  
                    cn.Reason = 'XCMOT010';
                } else {
                    cn.Reason = 'XCMOT009';
                }
            }

            setRes.add(cn);
        }

        res.addAll(setRes);

        return res;
    }




    private static void resumeAssetForDunning(Case c){ 

        Map<Id,Asset> mapAss = XC_UTIL_Asset.getAssetsFromInvoice(c.XC_Invoice__C);
        if(mapAss.values().isEmpty()){
            return;
        }
        Map<Id,Asset> assListRes = new Map<Id,Asset>();
        List<Id> mapAssIds = XC_UTIL_Sobject.getIds(mapAss.values());
		Map<Id,Asset> childAssetMap = new Map<Id, Asset>([
            SELECT Id, Status
            FROM Asset
            WHERE NE__Root_Order_Item__c IN: mapAssIds]);
        if(!childAssetMap.values().isEmpty()){
            for(Asset a : childAssetMap.values()){
                a.Status = 'Active';
                if(!mapAss.values().contains(a)){
                    mapAss.put(a.id, a);
                }
            }
        }
        for(Asset a:mapAss.values()){
            a.Status = 'Active';
            assListRes.put(a.Id,a);
        }
        XC_UTIL_Sobject.updateListRecords(assListRes.values());
    }



    private static XC_UTIL_Sobject.WrapperResult insertFile(XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest, String caseId){

        try {
            ContentVersion conVer = new ContentVersion();
            conVer.PathOnClient = caseWrapperRequest.casex.filebase64name;
            conVer.VersionData = EncodingUtil.base64Decode(caseWrapperRequest.casex.filebase64); 
            conVer.XC_Category__c = 'SF_GENERIC_DOCUMENT';
            XC_UTIL_Sobject.insertRecord(conVer);
            
            if(!Schema.SObjectType.ContentVersion.isAccessible()) {
                XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
                res.success = false;
                res.errorMessage = 'No Access';
                return res;
            }
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDoc;     
            cdl.LinkedEntityId = caseId;      
                
            XC_UTIL_Sobject.WrapperResult res = XC_UTIL_Sobject.insertRecord(cdl);
            return res;

        } catch(Exception e){
            XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
            res.success = false;
            res.errorMessage = e+'';
            return res;
        }
    }


     /**
     *@description The Class XC_REST_SendSMSfromCustomerInteraction.
     *@Author Simone Trenta - strenta@deloitte.it
     */
    public without sharing class XC_REST_SendCaseFileToDoxee implements Queueable, Database.AllowsCallouts {

        /** The customer interaction. */
        public final String caseId;


        /**
        * Instantiates a new XC_REST_SendSMSfromCustomerInteraction.
        *
        * 
        * @description constructor of XC_REST_SendSMSfromCustomerInteraction
        * @param caseId the case id
        */
        public XC_REST_SendCaseFileToDoxee(String caseId) {
            this.caseId = caseId;
        }

        /**
        * Execute. 
        *
        * @param qc the QueueableContext
        * @description execute of XC_REST_SendSMSfromCustomerInteraction
        */
        public void execute(QueueableContext qc){

            Map<Id,Case> mp = new Map<Id,Case>([
                SELECT Id, ( SELECT Id, ContentDocument.LatestPublishedVersion.CreatedDate, Contentdocument.LatestPublishedVersion.XC_Category__c,
                Contentdocument.LatestPublishedVersion.PathOnClient, Contentdocument.LatestPublishedVersion.ContentSize,
                Contentdocument.LatestPublishedVersion.versiondata
                FROM AttachedContentDocuments ), XC_LegalEntity__c
                FROM Case
                WHERE id  =: this.caseId]
            );

            Map<Id,XC_CM_LegalEntity_Configuration__mdt> configurationLE = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
                SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                FROM  XC_CM_LegalEntity_Configuration__mdt 
                WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND  XC_LegalEntity__c  =: mp.values()[0].XC_LegalEntity__c]
            );

            AttachedContentDocument cdl = mp.values()[0].AttachedContentDocuments[0];

            XC_REST_DoxeeFileSend_U.RequestWrapper wrapperContentVersion = new XC_REST_DoxeeFileSend_U.RequestWrapper();
            wrapperContentVersion.File.fileSize = cdl.Contentdocument.LatestPublishedVersion.ContentSize;
            wrapperContentVersion.File.fileName = cdl.Contentdocument.LatestPublishedVersion.PathOnClient;
            wrapperContentVersion.File.fileCreationDate = cdl.Contentdocument.LatestPublishedVersion.createdDate+''; 
            wrapperContentVersion.File.ObjectID = this.caseId; 
            wrapperContentVersion.File.fileBase64= EncodingUtil.base64Encode(cdl.Contentdocument.LatestPublishedVersion.versiondata);
            wrapperContentVersion.File.ObjectType = 'CASE';
            wrapperContentVersion.File.company = configurationLE.values()[0].XC_DoxeeCompany__c; 
            wrapperContentVersion.File.country = configurationLE.values()[0].XC_DoxeeCountry__c;
            wrapperContentVersion.File.fileCategory = cdl.Contentdocument.LatestPublishedVersion.XC_Category__c;
            XC_REST_DoxeeFileSend_U.ResponseWrapper res = XC_REST_DoxeeFileSend.createFile(wrapperContentVersion);
        }
    }
}