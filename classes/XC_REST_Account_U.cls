/**
 *
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       07/12/2018
 * @date Modification :   17/04/2019
 * @description :         XC_REST_Account_U – Util for Rest Resourse to Create/Update Account
 * 
 */


public without sharing class XC_REST_Account_U {


        /**
         * **************************************************************************************************************************************************************************************************.
         * @param wrReq - XC_REST_Account_W.WrapperRequest
         * @param wrResp - XC_REST_Account_W.WrapperResponse
         * @description Method to manage the insert of Account and its related objects
         * ***************************************************************************************************************************************************************************************************
         */
        public static void manageInsert(XC_REST_Account_W.WrapperRequest wrReq, XC_REST_Account_W.WrapperResponse wrResp, Map<String, String> mapHeader){

                Map<String, String> mapInfos = new Map<String, String>();
                Account accountToInsert; 
                Boolean whereCondition = false;
                String email;

                String recordTypeID = XC_REST_Account_ZZZ.retrieveRecordTypeID(wrReq, 'POST'); 

                String query = 'SELECT Id, MainPhone__c, PrimaryEmail__c, IdentityNumber__c, RecordType.DeveloperName, XC_isGuestUser__c, (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r) FROM Account WHERE ';
                if (!String.isBlank(wrReq.Account.PrimaryEmail)) {
                        email = wrReq.Account.PrimaryEmail;
                        /*  Mod CV.Task New005A_I
                        * @ Add RecordTypeId =: recordTypeID to check recordType in duplication
                        Start --> */
                        query += '((PrimaryEmail__c =: email AND RecordTypeId =: recordTypeID)';
                        //query += '(PrimaryEmail__c =: email';
                        //End <-- */
                        whereCondition = true;
                }

                //mod 14/06/2019
                Boolean guest = (wrReq.Account.RegisteredOnRechargeApp == false && ((wrReq.Account.PrimaryEmail != null && wrReq.Account.PrimaryEmail.endsWith('@enel.app.com')) ||(wrReq.Account.Channel != null && wrReq.Account.Channel.equalsIgnoreCase('Web'))))  ? true : false;
                if(!guest){
                        String identityNumber;
                        String documentType; 
                        List<String> idList = new List<String>();
                        Set<String> docTypeSet = new Set<String>();
                        if (wrReq.Identity != null && !wrReq.Identity.isEmpty() && whereCondition){
                                if(wrReq.Account.AccountType == 'Residential'){
                                        for(XC_UTIL_Account.IdentityIFWrapper identity : wrReq.Identity){
                                                if(String.isNotBlank(identity.IdentityNumber)){
                                                        idList.add(identity.IdentityNumber);
                                                        docTypeSet.add(identity.IdentityType);
                                                }
                                        }
                                        if(!idList.isEmpty()){
                                                Map<Id, XC_PersonalDocument__c> mapIdDocs = new Map<Id, XC_PersonalDocument__c>([SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c in: idList AND XC_Account__c!= null  AND XC_Account__r.XC_isGuestUser__c = false AND XC_DocumentTypeFormula__c IN: docTypeSet AND  XC_Account__r.RecordTypeId  =: recordTypeID]);
                                                List<XC_PersonalDocument__c> docs = mapIdDocs.values(); 
                                                List<String> docIds = new List<String>();
                                                for(XC_PersonalDocument__c d : docs){
                                                        docIds.add(d.XC_Account__c);
                                                }
                                                query += ' OR Id IN: docIds'; 
                                        }
        
                                }else{
                                        if(String.isNotBlank(wrReq.Identity[0].IdentityNumber)){
                                                identityNumber = wrReq.Identity[0].IdentityNumber;
                                                documentType = wrReq.Identity[0].IdentityType;
                                                query += ' OR (IdentityNumber__c =: identityNumber AND IdentityType__c =: documentType AND RecordTypeId =: recordTypeID)';
                                        }  
                                }
                        } else  if (wrReq.Identity != null && !wrReq.Identity.isEmpty() && !whereCondition){
                                if(wrReq.Account.AccountType == 'Residential'){
                                        for(XC_UTIL_Account.IdentityIFWrapper identity : wrReq.Identity){
                                                if(String.isNotBlank(identity.IdentityNumber)){
                                                        idList.add(identity.IdentityNumber);
                                                        docTypeSet.add(identity.IdentityType);
                                                }
                                        }
                                        if(!idList.isEmpty()){
                                                query += ' (Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c in: idList AND XC_Account__c!= null AND XC_Account__r.XC_isGuestUser__c = false AND XC_DocumentTypeFormula__c  IN: docTypeSet AND XC_Account__r.RecordTypeId  =: recordTypeID)';
                                        }
                                }else{
                                        if(String.isNotBlank(wrReq.Identity[0].IdentityNumber)){
                                                identityNumber = wrReq.Identity[0].IdentityNumber;
                                                documentType = wrReq.Identity[0].IdentityType;
                                                query += ' ((IdentityNumber__c =: identityNumber AND IdentityType__c =: documentType AND  RecordTypeId  =: recordTypeID)';
                                                whereCondition = true;
                                        }
                                }
                        }
                }
                query += (!guest) ? ') AND XC_isGuestUser__c = false ' : ') AND XC_isGuestUser__c = true';
               
                /*String phone;
                if (!String.isBlank(wrReq.Account.MainPhone) && whereCondition && !query.contains('Id IN (SELECT')){
                        phone = wrReq.Account.MainPhone;
                        query += ' OR XC_AccountMainPhone__c =: phone ';
                }else if (!String.isBlank(wrReq.Account.MainPhone) && !whereCondition && !query.contains('Id IN (SELECT')){
                        phone = wrReq.Account.MainPhone;
                        query += 'XC_AccountMainPhone__c =: phone';
                }*/
                
                system.debug('test query: '+query);         

                //Add @author : Riccardo Cossu for PMD check
                query = String.escapeSingleQuotes(query);
                system.debug('QUERY'+ query);
                List<Account> listAcc = (List<Account>) Database.query(query);

                Map<String,Object> utilMapAccount = new Map<String,Object>{ 'wrReq' => wrReq,
                                                                            'wrResp' => wrResp, 
                                                                            'clientSystem' => mapHeader.get('ClientSystem')
                                                                          };
                if(listAcc.isEmpty()) {
                        /*accountToInsert = new Account();
                        XC_REST_Account_ZZZ.createAccountFromWrapper(wrReq, 'POST', accountToInsert);
                        XC_UTIL_Sobject.WrapperResult insertAccRes = XC_UTIL_Sobject.insertRecord(accountToInsert); 
                        if(!insertAccRes.success) {
                                wrResp.Result.Message = 'INTERNAL ERROR: In Account Section, '+accountToInsert.XC_FirstName__c+' '+accountToInsert.XC_LastName__c+' '+ insertAccRes.errorMessage;
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.logError = 'INTERNAL ERROR: In Account Section, ' + insertAccRes.errorMessage;
                                return;
                        } else {
                                wrResp.Result.Message = 'Operation completed successfully';
                                wrResp.Result.ErrorCode = '0'; 
                                wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                                wrResp.Account.AccountID = accountToInsert.Id;
                                wrResp.Account.FirstName = accountToInsert.XC_FirstName__c;
                                wrResp.Account.LastName = accountToInsert.XC_LastName__c;
                        }*/
                        accountToInsert = new Account();
						accountToInsert.recordTypeId = recordTypeID;
                        insertAccount(accountToInsert, utilMapAccount);
                        if(wrResp.Result.ErrorCode != '0'){
                                return;
                        }
                } else {

                        manageDuplicationErrorAccount(listAcc, wrReq, wrResp, Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';').contains(mapHeader.get('ClientSystem')));             

                        List<String> errorCodeList = new List<String> {'501','502','503'};
                        if(errorCodeList.contains(wrResp.Result.ErrorCode)){
                                List<String> listOfClientSystemSkip = new List<String>();
                                listOfClientSystemSkip = Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';');
                                if(listOfClientSystemSkip.contains(mapHeader.get('ClientSystem'))){
                                        if(wrResp.Result.ErrorCode == '502'){
                                                accountToInsert = new Account();
                                                accountToInsert.recordTypeId = recordTypeID;
                                                accountToInsert.XC_SecondaryEmail__c = wrReq.Account.PrimaryEmail;
                                                wrReq.Account.PrimaryEmail = '';
                                                insertAccount(accountToInsert, utilMapAccount);
                                                if(wrResp.Result.ErrorCode != '0'){
                                                        return;
                                                }
                                                mapInfos.put('BlankEmailForCommodity', 'Yes');

                                        }else if(wrResp.Result.ErrorCode == '503') {

                                                system.debug('test1: '+wrResp.Account.AccountId+' '+wrReq.Account.PrimaryEmail);

                                                Account acc = new Account();
                                                acc.id = wrResp.Account.AccountId;
                                                acc.XC_SecondaryEmail__c = wrReq.Account.PrimaryEmail;
        
                                                update acc;
                                    
                                                return;

                                        } else {
                                                return;
                                        } 
                                        /*else if(wrResp.Result.ErrorCode == '501' || wrResp.Result.ErrorCode == '503') { //tolto per nuovo servizio unico - ST
                                                if(mapHeader.get('ClientSystem') == Label.XC_CL_CommoditySpainB2C){
                                                        wrResp.Result.Message = 'Operation completed successfully';
                                                        wrResp.Result.ErrorCode = '0';
                                                        wrResp.Account = null;
                                                }
                                                return;
                                        }*/
                                        
                                }else {
                                        return;
                                }
                                
                        }
                }
                String stream = accountToInsert.XC_Segment__c;
                
                // populate identity section for Small Business and Condominium Account
                if(wrReq.Account.AccountType == 'Small Business' || wrReq.Account.AccountType == 'Condominium'){

                        wrResp.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                        XC_UTIL_Account.IdentityIFWrapper identityWr = new XC_UTIL_Account.IdentityIFWrapper();
                        identityWr.IdentityID = accountToInsert.Id;
                        identityWr.Country = accountToInsert.XC_DocumentCountry__c;
                        identityWr.IdentityType = accountToInsert.IdentityType__c;
                        identityWr.IdentityNumber = accountToInsert.IdentityNumber__c;
                        wrResp.Identity.add(identityWr);
                }

                String defaultVal; 
                List <Schema.PicklistEntry> pickVals = Account.CurrencyIsoCode.getDescribe().getPicklistValues();        
                for (Schema.PicklistEntry pv: pickVals) {
                        if (pv.isDefaultValue()) {
                                defaultVal = pv.getValue();
                        }    
                }
                accountToInsert.CurrencyIsoCode = defaultVal;

                // convert dateTime to Date (String)
                if(wrReq.Identity != null && !wrReq.Identity.isEmpty()){
                        for(XC_UTIL_Account.IdentityIFWrapper identityWr : wrReq.Identity){
                                identityWr.ReleaseDate = (identityWr.ReleaseDate != null) ? identityWr.ReleaseDate.split('T')[0] : null;
                                identityWr.ExpiryDate = (identityWr.ExpiryDate != null) ? identityWr.ExpiryDate.split('T')[0] : null;
                        }
                }
                /*Map<Id,Account> accInserted;
                if(accountToInsert.Country__c == null){
                        accInserted = new Map<Id,Account> ([SELECT Country__c  FROM Account WHERE id =: accountToInsert.Id]);
                }*/
                Account accInserted = (Account) Account.sObjectType.newSObject(/*recordTypeId*/ accountToInsert.RecordTypeId, /*loadDefaultValues*/ true);
                Map<Id, XC_CM_CountryLegalEntityAssociation__mdt> legalAssociationMap = new Map<Id, XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id, XC_GuestAddress__c,XC_Preferredlanguageofcontact__c FROM XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_LegalEntity__c =: wrReq.Contact[0].GDPR.LegalEntity[0].LegalEntity AND XC_Category__c =: stream]);

                String account = JSON.Serialize(accountToInsert, true);
                mapInfos.put('accountId', accountToInsert.id);
                mapInfos.put('account', account);
                mapInfos.put('method', 'POST');
                mapInfos.put('accountType', accountToInsert.XC_RecordTypePick__c);
                mapInfos.put('stream', stream);
                mapInfos.put('country', (accountToInsert.Country__c != null) ? accountToInsert.Country__c : accInserted.Country__c);
                mapInfos.put('identityWrapper', (wrReq.Identity != null && !wrReq.Identity.isEmpty()) ? JSON.serialize(wrReq.Identity[0], true) : null);
                mapInfos.put('isGuest', (!guest) ? 'No' : 'Yes');
                mapInfos.put('clientSystem', mapHeader.get('ClientSystem'));
                mapInfos.put('TransactionID', mapHeader.get('TransactionID'));
                mapInfos.put('wrReq', JSON.Serialize(wrReq, true));
                mapInfos.put('Preferredlanguageofcontact', legalAssociationMap.isEmpty() ? null : legalAssociationMap.values()[0].XC_Preferredlanguageofcontact__c);
                /*if(!String.isBlank(wrReq.Account.PrimaryEmail)){
                        mapInfos.put('isGuest', (wrReq.Account.RegisteredOnRechargeApp == false && wrReq.Account.PrimaryEmail.endsWith('@enel.app.com'))? 'Yes' : 'No');
                }else{
                        mapInfos.put('isGuest', 'No');
                }*/


                // Contact, Individual and LegalEntity
                Map<String, Object> mapUtilConDoc = new Map<String, Object>();
                maputilConDoc.put('clientSystem', mapHeader.get('ClientSystem'));
                maputilConDoc.put('wrReq', wrReq);
                maputilConDoc.put('isGuest', mapInfos.get('isGuest'));
                List<XC_UTIL_Sobject.WrapperResult> contactWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(wrReq.Contact != null && !wrReq.Contact.isEmpty()){
                        wrResp.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
                        contactWrLIST = XC_REST_Account_U.insertUpdateContact(wrReq, mapInfos, wrResp, null, mapUtilConDoc);
                        if(contactWrLIST.isEmpty()){
                                return;
                        }
                }

                // Personal Document
                List<XC_UTIL_Sobject.WrapperResult> identityWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(wrReq.Account.AccountType == 'Residential'){
                        if(wrReq.Identity != null && !wrReq.Identity.isEmpty()){
                                wrResp.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                                Map<String, Object> mapUtilIdentity = new Map<String, Object>{  'identityList' => wrReq.Identity,
                                                                                                'accountID' => accountToInsert.id,
                                                                                                'accountType' => 'Residential',
                                                                                                'wrResp' => wrResp,
                                                                                                'docList' => null,
                                                                                                'contactID' => ((Contact) mapUtilConDoc.get('primaryContact')!= null) ? ((Contact) mapUtilConDoc.get('primaryContact')).Id : null
                                                                                                };
                                identityWrLIST = XC_REST_Account_U.insertUpdateIdentity(mapUtilIdentity, 'POST');
                                if(identityWrLIST.isEmpty()){
                                        return;
                                }
                        }
                }

                // contact personal document
                if((List<String>)maputilConDoc.get('idNumberList') != null && !((List<String>)mapUtilConDoc.get('idNumberList')).isEmpty()){
                        mapUtilConDoc.put('accountType', wrReq.Account.AccountType);
                        insertUpdateContactPersonalDocument(mapUtilConDoc);
                        if(wrResp.Result.ErrorCode == '500'){
                                return;
                        }
                }
            
                Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c> mapPosAddr = new Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c>();
                List<XC_UTIL_Sobject.WrapperResult> addressWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
            
                // populate address for guest user
                if(wrReq.Account.RegisteredOnRechargeApp==false && wrReq.Account.PrimaryEmail != null && wrReq.Account.PrimaryEmail.endsWith('@enel.app.com') && (wrReq.Address == null  || wrReq.Address.isEmpty())){
                        XC_UTIL_Address.AddressWrapper address = new XC_UTIL_Address.AddressWrapper();
                        wrReq.Address = new List<XC_UTIL_Address.AddressWrapper>();
                        if(legalAssociationMap.isEmpty() || String.isBlank(legalAssociationMap.values()[0].XC_GuestAddress__c)) {
                                address.StreetType = 'Street';
                                address.Address = 'Calle de la Ribera del Loira';
                                address.StreetNumber = '60';
                                address.ZipCode = '28042';
                                address.City = 'Madrid';
                                address.Country = 'Spain';
                        } else {
                                List<String> addressFields = legalAssociationMap.values()[0].XC_GuestAddress__c.split(';');
                                address.StreetType = addressFields[0];
                                address.Address = addressFields[1];
                                address.StreetNumber = addressFields[2];
                                address.ZipCode = addressFields[3];
                                address.City = addressFields[4];
                                address.Province = addressFields[5];
                                address.Country = addressFields[6];
                        }
                        address.InstallationAddress = true;
                        address.DeliveryAddress = true;
                        address.BillingAddress = true;
                        wrReq.Address.add(address);
                        wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                        addressWrLIST = XC_REST_Account_U.insertUpdateAddress(mapInfos, wrReq, wrResp, null, mapPosAddr);
                        if(addressWrLIST.isEmpty()){
                                return;
                        }
                } else{
                    // Address 
                    if(wrReq.Address != null && !wrReq.Address.isEmpty()) {
                            wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                            addressWrLIST = XC_REST_Account_U.insertUpdateAddress(mapInfos, wrReq, wrResp, null, mapPosAddr);
                            if(addressWrLIST.isEmpty()){
                                return;
                            }
                    } else if (wrReq.BillingProfile != null && !wrReq.BillingProfile.isEmpty()) {
                            wrResp.Result.Message = Label.XC_CL_Address_BillingProfile;
                            wrResp.Result.ErrorCode = '400';
                            wrResp.Result.logError = Label.XC_CL_Address_BillingProfile;
                            return;
                    }
                }    
                

                // PointOfService
                List<XC_UTIL_Sobject.WrapperResult> posWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(!mapPosAddr.isEmpty()) {
                        wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                        Map<String, Object> mapUtil = new Map<String, Object>{  'wrReq' => wrReq,
                                                                            'wrResp' => wrResp,
                                                                            'posList' => null,
                                                                            'mapPosAddr' => mapPosAddr
                                                                            };
                        posWrLIST = XC_REST_Account_U.insertUpdatePos(mapUtil);
                        if(posWrLIST.isEmpty()){
                                return;
                        }
                } 
                
                // Billing Profile
                List<XC_UTIL_Sobject.WrapperResult> billingProfileWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(wrReq.BillingProfile != null) {
                        wrResp.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
                        billingProfileWrLIST = XC_REST_Account_B.insertUpdateBillingProfile(wrReq.BillingProfile, mapInfos, wrResp, false);
                        if(billingProfileWrLIST.isEmpty()){
                                return;
                        }
                }

                // Create Response
                XC_REST_Account_U.createResponse(accountToInsert.id, contactWrLIST, addressWrLIST, billingProfileWrLIST, identityWrLIST, posWrLIST, wrResp, mapHeader.get('ClientSystem'));

        }

        /**
         * *******************************************************************************************************************************************************
         * @param accountToInsert - Account
         * @param utilMapAccount - Map<String,Object>
         * @description Method to insert the account
         * *******************************************************************************************************************************************************
        */
        public static void insertAccount(Account accountToInsert, Map<String,Object> utilMapAccount){
        
                XC_REST_Account_W.WrapperRequest wrReq = (XC_REST_Account_W.WrapperRequest) utilMapAccount.get('wrReq');
                XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) utilMapAccount.get('wrResp');
                utilMapAccount.put('method', 'POST');

                //accountToInsert = new Account();
                XC_REST_Account_ZZZ.createAccountFromWrapper(utilMapAccount, accountToInsert);
                XC_UTIL_Sobject.WrapperResult insertAccRes = XC_UTIL_Sobject.insertRecord(accountToInsert); 
                if(!insertAccRes.success) {
                        wrResp.Result.Message = 'INTERNAL ERROR: In Account Section, '+accountToInsert.XC_FirstName__c+' '+accountToInsert.XC_LastName__c+' '+ insertAccRes.errorMessage;
                        wrResp.Result.ErrorCode = '500';
                        wrResp.Result.logError = 'INTERNAL ERROR: In Account Section, ' + insertAccRes.errorMessage;
                        return;
                } else {
                        wrResp.Result.Message = 'Operation completed successfully';
                        wrResp.Result.ErrorCode = '0'; 
                        wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                        wrResp.Account.AccountID = accountToInsert.Id;
                        wrResp.Account.FirstName = accountToInsert.XC_FirstName__c;
                        wrResp.Account.LastName = accountToInsert.XC_LastName__c;
                }
        }

        

        /**
         * *******************************************************************************************************************************************************
         * @param listAcc - List<Account>
         * @param wrReq - XC_REST_Account_W.WrapperRequest
         * @param wrResp - XC_REST_Account_W.WrapperResponse
         * @description Method to manage the account duplication error
         * *******************************************************************************************************************************************************
        */
        public static void manageDuplicationErrorAccount(List<Account> listAcc, XC_REST_Account_W.WrapperRequest wrReq, XC_REST_Account_W.WrapperResponse wrResp, Boolean fromCommodity){

                //Boolean sameEmail = false;
                //String docAccId = '';
                //String emailAccId = '';

                Map<String,Object> mapUtil = new Map<String,Object>();
                mapUtil.put('identityWrList', wrReq.Identity);

                Map<integer,Map<String,Object>> prioMap = new Map<integer,Map<String,Object>>();

                for(Account accDuplicated : listAcc){

                        Boolean sameEmail = false;
                        String emailAccId = '';

                        system.debug('asd1: '+wrReq.Account.PrimaryEmail+' - '+accDuplicated.PrimaryEmail__c);
                        if(!String.isBlank(wrReq.Account.PrimaryEmail) && accDuplicated.PrimaryEmail__c == wrReq.Account.PrimaryEmail){
                                sameEmail = true;
                                emailAccId = accDuplicated.Id;
                        }

                        mapUtil.put('accDuplicated', accDuplicated);
                        checkDuplicatedDocument(mapUtil);

                        mapUtil.put('sameEmail', sameEmail);
                        mapUtil.put('emailAccId', emailAccId);


                        if(sameEmail && (Boolean)mapUtil.get('sameDocument')){ //501 priorità massima
                                prioMap.put(1,new Map<String,Object>(mapUtil));
                                break;
                        
                        } else if(!sameEmail && (Boolean)mapUtil.get('sameDocument')){//503
                                prioMap.put(2,new Map<String,Object>(mapUtil));                                                                            
                        
                        } else if(sameEmail && !(Boolean)mapUtil.get('sameDocument')){//502 priorità minima
                                prioMap.put(3,new Map<String,Object>(mapUtil));
                        } 

                }

                if(prioMap.containsKey(1)){ 
                        mapUtil = prioMap.get(1);

                } else if(prioMap.containsKey(2) && fromCommodity){ 
                        mapUtil = prioMap.get(2);
                        system.debug('test 503'+maputil);

                } else if(prioMap.containsKey(3) && fromCommodity){
                        mapUtil = prioMap.get(3);
                } 
                
                //mapUtil.put('sameEmail', sameEmail);
                //mapUtil.put('emailAccId', emailAccId);

                manageDuplicationErrorMessage(mapUtil, wrResp);
                
                return;

        }


        /**
         * *********************************************************************
         * @param mapUtil - Map<String,Object>
         * @description Method to manage the document duplication error
         * *********************************************************************
        */
        public static void checkDuplicatedDocument(Map<String,Object> mapUtil){

                String docAccId = '';
                Boolean sameDocument = false;
                List<XC_UTIL_Account.IdentityIFWrapper> identityWrList = (List<XC_UTIL_Account.IdentityIFWrapper>) mapUtil.get('identityWrList');
                Account accDuplicated = (Account) mapUtil.get('accDuplicated');

                if(identityWrList != null && !identityWrList.isEmpty()){
                        for(XC_UTIL_Account.IdentityIFWrapper identityWr: identityWrList){
                                if(!accDuplicated.Personal_Documents__r.isEmpty()){
                                        for(XC_PersonalDocument__c personalDoc : accDuplicated.Personal_Documents__r){
                                                if(personalDoc.XC_DocumentNumber__c == identityWr.IdentityNumber && !accDuplicated.XC_isGuestUser__c){
                                                        sameDocument = true;
                                                        docAccId = accDuplicated.Id;
                                                }
                                        }       
                                } else if(identityWr.IdentityNumber == accDuplicated.IdentityNumber__c && !accDuplicated.XC_isGuestUser__c){
                                        sameDocument = true;
                                        docAccId = accDuplicated.Id;
                                }
                        }
                }

                mapUtil.put('sameDocument', sameDocument);
                mapUtil.put('docAccId', docAccId);
        }


        /**
         * ********************************************************************************************************************
         * @param mapUtil - Map<String,Object>
         * @param wrResp - XC_REST_Account_W.WrapperResponse
         * @description Method to manage the account duplication error message
         * ********************************************************************************************************************
        */
        public static void manageDuplicationErrorMessage(Map<String,Object> mapUtil, XC_REST_Account_W.WrapperResponse wrResp){

                Boolean sameEmail = (Boolean)mapUtil.get('sameEmail');
                Boolean sameDocument = (Boolean)mapUtil.get('sameDocument');
                String docAccId = (String)mapUtil.get('docAccId');
                String emailAccId = (String)mapUtil.get('emailAccId');

                system.debug('sameEmail: '+sameEmail+' - '+sameDocument); 

                if(sameEmail && sameDocument){
                        wrResp.Result.Message = Label.XC_CL_AccountDuplicDocEmail;
                        wrResp.Result.ErrorCode = '501';
                        wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                        wrResp.Account.AccountID = emailAccId;
                        wrResp.Result.logError = Label.XC_CL_AccountDuplicDocEmail + ' ' + emailAccId;
                        return;
                }else if(sameEmail && !sameDocument){
                        wrResp.Result.Message = Label.XC_CL_AccountDuplicEmail;
                        wrResp.Result.ErrorCode = '502';
                        wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                        wrResp.Account.AccountID = emailAccId;
                        wrResp.Result.logError = Label.XC_CL_AccountDuplicEmail + ' ' + emailAccId;
                        return;
                }else if(!sameEmail && sameDocument){
                        wrResp.Result.Message = Label.XC_CL_AccountDuplicDoc;
                        wrResp.Result.ErrorCode = '503';
                        wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                        wrResp.Account.AccountID = docAccId;
                        wrResp.Result.logError =  Label.XC_CL_AccountDuplicDoc + ' ' + docAccId;
                        return;
                }

        }


        
        /**
         * **************************************************************************************************************************************************************************************************.
         * @param wrReq - XC_REST_Account_W.WrapperRequest
         * @param wrResp - XC_REST_Account_W.WrapperResponse
         * @param mapHeader - Map<String, String>
         * @description Method to manage the update of Account and its related objects
         * ***************************************************************************************************************************************************************************************************
        */
        public static void manageUpdate(XC_REST_Account_W.WrapperRequest wrReq, XC_REST_Account_W.WrapperResponse wrResp, Map<String, String> mapHeader){

                Map<String, String> mapInfos = new Map<String, String>();

                List<Account> accList;
                if(String.isNotBlank(wrReq.Account.AccountID)) {
                        Map<Id, Account> mapAcc = new Map<Id,Account>([SELECT Id, RecordTypeId, XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_Country__c, XC_Segment__c, XC_RecordTypeDeveloperName__c, XC_BirthDate__c, XC_isGuestUser__c, PrimaryEmail__c, XC_AccountType__c , XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, IdentityNumber__c, IdentityType__c, CurrencyIsoCode, Country__c,  XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c, (SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c FROM Personal_Documents__r),  (SELECT Id, XC_Segment__c, XC_MainLegalEntity__c, IndividualId, XC_PrimaryContact__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c, Email FROM Contacts), (SELECT Id,  XC_BillingAddress__c, XC_DeliveryAddress__c  FROM Addresses__r ORDER BY LastModifiedDate DESC), (SELECT Id FROM Points_of_Service__r), (SELECT Id FROM NE__Billing_Profiles__r) FROM Account WHERE Id =: wrReq.Account.AccountID]);
                        accList = mapAcc.values();
                } else if(String.isNotBlank(wrReq.Account.PrimaryEmail) && String.isBlank(wrReq.Account.IdentityNumber)) {
                        Map<Id, Account> mapAcc = new Map<Id,Account>([SELECT Id, RecordTypeId, XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_Country__c, XC_Segment__c, XC_RecordTypeDeveloperName__c, XC_BirthDate__c,  XC_isGuestUser__c, PrimaryEmail__c, XC_AccountType__c, XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, IdentityNumber__c, IdentityType__c,  CurrencyIsoCode, Country__c,  XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c,  (SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c FROM Personal_Documents__r),  (SELECT Id, XC_Segment__c, XC_MainLegalEntity__c, IndividualId, XC_PrimaryContact__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c, Email  FROM Contacts), (SELECT Id,  XC_BillingAddress__c, XC_DeliveryAddress__c  FROM Addresses__r ORDER BY LastModifiedDate DESC), (SELECT Id FROM Points_of_Service__r), (SELECT Id FROM NE__Billing_Profiles__r) FROM Account WHERE PrimaryEmail__c =: wrReq.Account.PrimaryEmail]);
                        accList = mapAcc.values();
                } else if(String.isBlank(wrReq.Account.PrimaryEmail) && String.isNotBlank(wrReq.Account.IdentityNumber)) {
                        Map<Id, Account> mapAcc  = new Map<Id, Account>();

                        // Residential
                        mapAcc = new Map<Id,Account>([SELECT Id, RecordTypeId, XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_Country__c, XC_Segment__c, XC_RecordTypeDeveloperName__c, XC_BirthDate__c, XC_AccountType__c, XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, IdentityNumber__c, IdentityType__c, CurrencyIsoCode, Country__c, XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c,  (SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c FROM Personal_Documents__r),  (SELECT Id, XC_Segment__c, XC_MainLegalEntity__c, IndividualId, XC_PrimaryContact__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c, Email  FROM Contacts), (SELECT Id,  XC_BillingAddress__c, XC_DeliveryAddress__c  FROM Addresses__r ORDER BY LastModifiedDate DESC), (SELECT Id FROM Points_of_Service__r), (SELECT Id FROM NE__Billing_Profiles__r) FROM Account WHERE Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c =: wrReq.Account.IdentityNumber)]);
                        accList = mapAcc.values(); 

                        // !Residential
                        if(accList.isEmpty() || accList[0].RecordType.Name == 'Residential'){
                                mapAcc = new Map<Id,Account>([SELECT Id,RecordTypeId,  XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_Country__c, XC_Segment__c, XC_RecordTypeDeveloperName__c, XC_BirthDate__c, XC_AccountType__c, XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, IdentityNumber__c, IdentityType__c, CurrencyIsoCode, Country__c, XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c, (SELECT Id, XC_Segment__c, XC_MainLegalEntity__c, IndividualId, XC_PrimaryContact__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c,Email  FROM Contacts), (SELECT Id,  XC_BillingAddress__c, XC_DeliveryAddress__c  FROM Addresses__r ORDER BY LastModifiedDate DESC), (SELECT Id FROM Points_of_Service__r), (SELECT Id FROM NE__Billing_Profiles__r) FROM Account WHERE IdentityNumber__c =: wrReq.Account.IdentityNumber]);
                                accList = mapAcc.values();
                        }

                        accList = mapAcc.values();
                } 
                
                if(accList.size() == 0) {
                        wrResp.Result.Message = Label.XC_CL_AccountNotFound;
                        wrResp.Result.ErrorCode = '404';
                        return;
                }

                String stream = accList[0].XC_Segment__c;
                System.debug('@@@ NM stream1: ' + stream);
                
                
                // Validate identity for Small Business and Condominium Account
                if(!mapHeader.get('ClientSystem').equalsIgnoreCase('XInstaller') && (accList[0].XC_RecordTypePick__c == 'Soho' || accList[0].XC_RecordTypePick__c == 'Condominium') && (wrReq.Identity != null && !wrReq.Identity.isEmpty() && (wrReq.Identity.size()>1 || wrReq.Identity[0].IdentityID == null))) {
                        wrResp.Result.Message = Label.XC_CL_MandatoryField+' Identity.IdentityID';
                        wrResp.Result.ErrorCode = '400';
                        wrResp.Result.LogError = Label.XC_CL_MandatoryField+' Identity.IdentityID';
                        return;
                } else{
                        if(wrReq.Identity != null && wrReq.Identity.size() >0){
                                XC_UTIL_Integration.WrapperResult validateResult = XC_REST_Account_VV.validateRequestIdentity(wrReq.Identity, mapHeader.get('ClientSystem'));
                                if(validateResult.errorFlag) {
                                        wrResp.Result.ErrorCode = '400';
                                        wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                                        wrResp.Result.LogError = 'ERROR. ' + validateResult.errorMessage;
                                        return;
                                }
                        }
                        
                }   
                Map<String, Object> mapAccount = (Map<String, Object>) JSON.DeserializeUntyped(JSON.Serialize(wrReq.Account, true));
                if(mapAccount.size() > 1 || (accList[0].XC_RecordTypePick__c == 'Soho' || accList[0].XC_RecordTypePick__c == 'Condominium') || (wrReq.Identity != null && !wrReq.Identity.isEmpty())) {

                        // update account
                        List<Account> listAcc; 

                        if((wrReq.Identity == null  || (wrReq.Identity != null && !wrReq.Identity.isEmpty() && String.isBlank(wrReq.Identity[0].IdentityNumber))) && String.isBlank(wrReq.Account.PrimaryEmail) /*&& String.isBlank(wrReq.Account.MainPhone)*/) {
                                listAcc = new List<Account>();
                        } else {

                                // Duplication Check
                                Boolean whereCondition = false;
                                String email;


                                String recordTypeId = accList[0].recordTypeId; 
                                String query = 'SELECT Id, MainPhone__c, PrimaryEmail__c, IdentityNumber__c, RecordType.DeveloperName, XC_FirstName__c, XC_LastName__c, Name, XC_isGuestUser__c, (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r) FROM Account ';
                                if(!String.isBlank(wrReq.Account.PrimaryEmail)) {
                                        email =  wrReq.Account.PrimaryEmail;
                                /*  Mod CV.Task New005A_I
                                * @ Add RecordTypeId =: recordTypeID to check even the recordType in duplication
                                Start --> */
                                query += 'WHERE ((PrimaryEmail__c =: email AND RecordTypeId =: recordTypeID)';
                                //query += '(PrimaryEmail__c =: email';
                                //End <-- */
                                        whereCondition = true;
                                }

                                if(!accList[0].XC_isGuestUser__c){
                                        //mod 14/06/2019 
                                        String identityNumber;
                                        String documentType; 
                                        List<String> idList = new List<String>();
                                        Set<String> docTypeSet = new Set<String>();
                                        if (wrReq.Identity != null && !wrReq.Identity.isEmpty() && whereCondition) {
                                                if(accList[0].XC_RecordTypePick__c == 'Residential' || (wrReq.Account.AccountType != null && wrReq.Account.AccountType == 'Residential')){
                                                        for(XC_UTIL_Account.IdentityIFWrapper identity : wrReq.Identity){
                                                                if(String.isNotBlank(identity.IdentityNumber)){
                                                                        idList.add(identity.IdentityNumber);
                                                                        docTypeSet.add(identity.IdentityType);
                                                                }
                                                        }
                                                        if(!idList.isEmpty()){
                                                                Map<Id,XC_PersonalDocument__c> mapDocs = new Map<Id,XC_PersonalDocument__c>([SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c in: idList AND XC_Account__c!= null AND XC_Account__r.XC_isGuestUser__c = false AND XC_DocumentTypeFormula__c IN: docTypeSet AND XC_Account__r.RecordTypeId =: recordTypeID]); 
                                                                List<XC_PersonalDocument__c> docs = mapDocs.values();
                                                                List<String> docIds = new List<String>();   
                                                                for(XC_PersonalDocument__c d : docs){ 
                                                                        docIds.add(d.XC_Account__c);
                                                                }
                                                                query += ' OR Id IN: docIds';      
                                                        }
                                                }else{
                                                        if(String.isNotBlank(wrReq.Identity[0].IdentityNumber)){
                                                                identityNumber = wrReq.Identity[0].IdentityNumber; 
                                                                documentType = wrReq.Identity[0].IdentityType; 
                                                                query += ' OR (IdentityNumber__c =: identityNumber AND IdentityType__c =: documentType AND RecordTypeId  =: recordTypeID)';   
                                                        }
                                                }

                                        } else if (wrReq.Identity != null && !wrReq.Identity.isEmpty() && !whereCondition){
                                                if(accList[0].XC_RecordTypePick__c != 'Residential' || (wrReq.Account.AccountType != null && wrReq.Account.AccountType != 'Residential')){          
                                                        if(String.isNotBlank(wrReq.Identity[0].IdentityNumber)){
                                                                identityNumber = wrReq.Identity[0].IdentityNumber;
                                                                documentType = wrReq.Identity[0].IdentityType; 
                                                                query += ' WHERE ((IdentityNumber__c =: identityNumber AND IdentityType__c =: documentType AND  RecordTypeId =: recordTypeID) '; //
                                                                whereCondition = true;  
                                                        }                    
                                                } else {
                                                        for(XC_UTIL_Account.IdentityIFWrapper identity : wrReq.Identity){
                                                                if(String.isNotBlank(identity.IdentityNumber)){
                                                                        idList.add(identity.IdentityNumber);
                                                                        docTypeSet.add(identity.IdentityType);
                                                                }
                                                        }
                                                        if(!idList.isEmpty()){
                                                                query += ' WHERE (Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c in: idList AND XC_Account__c!= null AND XC_Account__r.XC_isGuestUser__c = false  AND XC_DocumentTypeFormula__c IN: docTypeSet AND XC_Account__r.RecordTypeId =: recordTypeID)';
                                                                whereCondition = true;
                                                        } //WHERE
                                                }
                                        }
                                        if(whereCondition) {
                                                query += ') AND XC_isGuestUser__c = false ';
                                        } else {
                                                query += ' WHERE XC_isGuestUser__c = false';
                                        }
                                } 
                                else if(whereCondition) {
                                        query += ') AND XC_isGuestUser__c = true';
                                }
                               
                                System.debug('@@@@@' + wrReq.Account);
                                /*String phone;
                                if (!String.isBlank(wrReq.Account.MainPhone) && whereCondition && !query.contains('Id IN (SELECT')) {
                                        phone = wrReq.Account.MainPhone;
                                        query += ' OR XC_AccountMainPhone__c =: phone ';
                                } else if (!String.isBlank(wrReq.Account.MainPhone) && !whereCondition && !query.contains('Id IN (SELECT')) {
                                        phone = wrReq.Account.MainPhone;
                                        query += 'WHERE XC_AccountMainPhone__c =: phone';
                                }*/

                                system.debug('query: '+query);    
                                
                                //Add @author : Riccardo Cossu for PMD check
                                if(!query.endsWith('Account ')){
                                     String accId = accList[0].Id;
                                     query += ' AND Id != :accId';
                                     query = String.escapeSingleQuotes(query);
                                     listAcc = (List<Account>) Database.query(query);
                                }else{
                                    listAcc = new List<Account>();
                                }
                               
                        }


                        /*

                        //mod 14/06/2019
                        if(!accList[0].XC_isGuestUser__c){
                                if (wrReq.Identity != null && !wrReq.Identity.isEmpty() && !listAcc.isEmpty() && !listAcc.get(0).Personal_Documents__r.isEmpty()) {
                                        if(accList[0].XC_RecordTypePick__c == 'Residential' || wrReq.Account.AccountType == 'Residential'){
                                                for(XC_UTIL_Account.IdentityIFWrapper identity : wrReq.Identity){
                                                        Boolean foundDoc = false;
                                                        for(XC_PersonalDocument__c doc : listAcc.get(0).Personal_Documents__r){
                                                                if(String.isNotBlank(identity.IdentityID) && doc.id==identity.IdentityID){
                                                                        foundDoc = true; 
                                                                }
                                                        }
                                                        if(!foundDoc && accList[0].id != listAcc.get(0).id){
                                                                wrResp.Result.Message = 'INTERNAL ERROR: The Account already exists';
                                                                wrResp.Result.ErrorCode = '501';
                                                                wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                                                                wrResp.Account.AccountID = listAcc.get(0).Id;
                                                                wrResp.Result.logError = 'INTERNAL ERROR: The Account already exist with the ID ' + listAcc.get(0).Id;
                                                                return;
                                                        }
                                                }
                                        }
                                }
                        }
                        */
                        
                


                        if(listAcc.isEmpty() || listAcc.get(0).Id == accList[0].id) {
                                Map<String,Object> utilMapAccount = new Map<String,Object>{ 'wrReq' => wrReq, 
                                                                                             'clientSystem' => mapHeader.get('ClientSystem'),
                                                                                             'method' => 'PUT'
                                                                                           };
                                
                                XC_REST_Account_ZZZ.createAccountFromWrapper(utilMapAccount, accList.get(0));
                                XC_UTIL_Sobject.WrapperResult wrResAcc = XC_UTIL_Sobject.updateRecord(accList.get(0));
                        
                                if(!wrResAcc.success) {
                                        wrResp.Result.Message = 'INTERNAL ERROR';
                                        wrResp.Result.Message = 'INTERNAL ERROR: ' + wrResAcc.errorMessage;
                                        wrResp.Result.ErrorCode = '500';
                                        wrResp.Result.LogError = 'INTERNAL ERROR: ' + wrResAcc.errorMessage;
                                        return;
                                } else {
                                        wrResp.Result.Message = 'Operation completed successfully';
                                        wrResp.Result.ErrorCode = '0';
                                }
                        } else {

                                manageDuplicationErrorAccount(listAcc, wrReq, wrResp, Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';').contains(mapHeader.get('ClientSystem')));   

                                /*
                                wrResp.Result.Message = 'INTERNAL ERROR: The Account already exists';
                                wrResp.Result.ErrorCode = '501';
                                wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                                wrResp.Account.AccountID = listAcc.get(0).Id;
                                wrResp.Result.logError = 'INTERNAL ERROR: The Account already exist with the ID ' + listAcc.get(0).Id;
								*/
                                return;
                        } 
                }

                wrReq.Account.AccountID = accList[0].Id;

                wrResp.Account = new XC_UTIL_Account.AccountIFWrapper();
                wrResp.Account.AccountID = accList[0].Id;
                wrResp.Account.FirstName = accList[0].XC_FirstName__c;
                wrResp.Account.LastName = accList[0].XC_LastName__c;
            
                mapInfos.put('accountId', accList[0].Id);
                mapInfos.put('account',  JSON.Serialize(accList[0], true));
                mapInfos.put('accountType', (String.isNotBlank(accList[0].XC_RecordTypePick__c)) ? accList[0].XC_RecordTypePick__c : ((accList[0].XC_RecordTypeDeveloperName__c.containsIgnoreCase('B2B') || accList[0].XC_RecordTypeDeveloperName__c.containsIgnoreCase('B2G')) ? 'Soho' : accList[0].XC_RecordTypeDeveloperName__c));
                mapInfos.put('country',  accList[0].Country__c);
                mapInfos.put('clientSystem', mapHeader.get('ClientSystem'));
                mapInfos.put('TransactionID', mapHeader.get('TransactionID'));
                mapInfos.put('method', 'PUT');
                mapInfos.put('stream', stream);
                mapInfos.put('wrReq', JSON.Serialize(wrReq, true));

                mapInfos.put('isGuest', (accList[0].XC_isGuestUser__c) ? 'Yes' : 'No');

                /*if(!String.isBlank(accList[0].PrimaryEmail__c)){
                        mapInfos.put('isGuest', (accList[0].PrimaryEmail__c.endsWith('@enel.app.com') && accList[0].XC_isGuestUser__c == true) ? 'Yes' : 'No');
                }else{
                        mapInfos.put('isGuest', 'No');
                }*/

                // populate identity section for Small Business and Condominium Account
                if((accList[0].XC_RecordTypePick__c == 'Soho' || accList[0].XC_RecordTypePick__c == 'Condominium') && (wrReq.Identity != null && !wrReq.Identity.isEmpty())){
                        
                        for(XC_UTIL_Account.IdentityIFWrapper idWr : wrReq.Identity) {
                                if(String.isNotBlank(idWr.IdentityID) && idWr.IdentityID == accList[0].Id) {
                                        wrResp.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                                        XC_UTIL_Account.IdentityIFWrapper identityWr = new XC_UTIL_Account.IdentityIFWrapper();
                                        identityWr.IdentityID = accList[0].Id;
                                        identityWr.Country = accList[0].XC_DocumentCountry__c;
                                        identityWr.IdentityType = accList[0].IdentityType__c;
                                        identityWr.IdentityNumber = accList[0].IdentityNumber__c;
                                        wrResp.Identity.add(identityWr);
                                        break;
                                }
                        }
                }

                // convert dateTime to Date 
                if(wrReq.Identity != null && !wrReq.Identity.isEmpty()){
                        for(XC_UTIL_Account.IdentityIFWrapper identityWr : wrReq.Identity){
                                identityWr.ReleaseDate = (identityWr.ReleaseDate != null) ? identityWr.ReleaseDate.split('T')[0] : null;
                                identityWr.ExpiryDate = (identityWr.ExpiryDate != null) ? identityWr.ExpiryDate.split('T')[0] : null;
                        }
                }

                // Contact, Individual and LegalEntity
                Map<String, Object> maputilConDoc = new Map<String, Object>();
                maputilConDoc.put('clientSystem', mapHeader.get('ClientSystem'));
                maputilConDoc.put('wrReq',wrReq);
                maputilConDoc.put('isGuest', mapInfos.get('isGuest'));
                List<XC_UTIL_Sobject.WrapperResult> contactWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(wrReq.Contact != null && !wrReq.Contact.isEmpty()) {
                        wrResp.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
                        contactWrLIST = XC_REST_Account_U.insertUpdateContact(wrReq, mapInfos, wrResp, accList.get(0).Contacts, maputilConDoc);
                        if(contactWrLIST.isEmpty()){
                                return;
                        }
                } else {
                        //D-3800 mario.a.giordano@accenture.com - 07032022 - add if list acc is not empty
                        if(!accList.isEmpty() && null !=  accList.get(0) && !accList.get(0).Contacts.isEmpty() && null != accList.get(0).Contacts[0] ){
                                mapInfos.put('contactId', accList.get(0).Contacts[0].Id);
                                mapInfos.put('contactInfo', JSON.Serialize(accList.get(0).Contacts[0]));
                                mapInfos.put('legalEntity', accList.get(0).Contacts[0].XC_MainLegalEntity__c);
                                for(Contact c : accList.get(0).Contacts) {
                                        if(c.XC_PrimaryContact__c) {
                                                mapInfos.put('contactId', c.Id);
                                                mapInfos.put('legalEntity', c.XC_MainLegalEntity__c);
                                                mapInfos.put('contactInfo', JSON.Serialize(c));
                                                break;
                                        }
                                }
                        }        
                }

                // Personal Document
                List<XC_UTIL_Sobject.WrapperResult> identityWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                //if(wrReq.Account.AccountType == 'Residential' || accList[0].XC_RecordTypePick__c == 'Residential'){
                        if(wrReq.Identity != null && !wrReq.Identity.isEmpty()){
                                String contactID;
                                if(((Contact) maputilConDoc.get('primaryContact'))!= null){
                                        contactID = ((Contact)maputilConDoc.get('primaryContact')).Id;
                                }else{
                                        for(Contact con : accList.get(0).Contacts){
                                                if(con.XC_PrimaryContact__c){
                                                     contactID = con.Id;
                                                     break;
                                                }
                                        }
                                }
                                if(wrResp.Identity == null) {
                                        wrResp.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                                }
                                Map<String, Object> mapUtilIdentity = new Map<String, Object>{  'identityList' => wrReq.Identity,
                                                                                                'accountID' => wrReq.Account.AccountID,
                                                                                                'accountType' => (String.isNotBlank(wrReq.Account.AccountType)) ? wrReq.Account.AccountType : accList[0].XC_RecordTypePick__c,
                                                                                                'wrResp' => wrResp,
                                                                                                'docList' => accList.get(0).Personal_Documents__r,
                                                                                                'contactID' => contactID
                                                                                                };
                                identityWrLIST = XC_REST_Account_U.insertUpdateIdentity(mapUtilIdentity, 'PUT');
                                /*if(identityWrLIST.isEmpty()){
                                        return;
                                }*/
                        }
                //}
                
                
                // contact personal document
                if((List<String>)maputilConDoc.get('idNumberList') != null && !((List<String>)maputilConDoc.get('idNumberList')).isEmpty()){
                        maputilConDoc.put('accountType', (String.isNotBlank(wrReq.Account.AccountType)) ? wrReq.Account.AccountType : accList[0].XC_RecordTypePick__c);
                        insertUpdateContactPersonalDocument(maputilConDoc);
                        if(wrResp.Result.ErrorCode == '500'){
                                return;
                        }
                }


                // populate map infos
                Map<Id, Account> mapAccUpdated = new Map<Id,Account>([SELECT Id, XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_Country__c, XC_Segment__c, XC_RecordTypeDeveloperName__c, XC_BirthDate__c, XC_SohoType__c, XC_TradingPartner__c, XC_Preference_Language__c, PrimaryEmail__c, XC_isGuestUser__c, XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, IdentityNumber__c, IdentityType__c, CurrencyIsoCode, Country__c, XC_AccountType__c, XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c,   (SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_Country__c FROM Personal_Documents__r ORDER BY CreatedDate desc) FROM Account WHERE Id =: wrReq.Account.AccountID]);
                List<Account> accListUpdate = mapAccUpdated.values();
                String account = JSON.Serialize(accListUpdate[0], true);
                mapInfos.put('account',  account);
                mapInfos.put('personalDocument', (accListUpdate[0].Personal_Documents__r != null && !accListUpdate[0].Personal_Documents__r.isEmpty()) ? JSON.Serialize(accListUpdate[0].Personal_Documents__r[0], true) : null);
               
                if(wrReq.Identity != null && !wrReq.Identity.isEmpty()){
                        for(XC_UTIL_Account.IdentityIFWrapper docWr : wrReq.Identity) {
                                if(String.isBlank(docWr.IdentityID)){
                                        mapInfos.put('identityWrapper', JSON.Serialize(docWr, true));
                                        break;
                                }
                        }
                }
        
            
                // Address
                List<XC_UTIL_Sobject.WrapperResult> addressWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c> mapPosAddr = new Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c>();
                if(wrReq.Address != null) {
                        wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                        addressWrLIST = XC_REST_Account_U.insertUpdateAddress(mapInfos, wrReq, wrResp, accList.get(0).Addresses__r, mapPosAddr);
                        if(addressWrLIST.isEmpty()){
                        return;
                        }
                }else {
                        if(accList.get(0).Addresses__r != null){
                                for(XC_Address__c addr: accList.get(0).Addresses__r){
                                        if(addr.XC_BillingAddress__c && String.isBlank(mapInfos.get('billId'))){
                                                mapInfos.put('billId', addr.Id);
                                                //mapInfos.put('soldId', addr.Id);
                                        }
                                        if(addr.XC_DeliveryAddress__c && String.isBlank(mapInfos.get('soldId'))){
                                                mapInfos.put('soldId', addr.Id);
                                        }
                                }
                        }
                }
                

                // PointOfService
                List<XC_UTIL_Sobject.WrapperResult> posWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(!mapPosAddr.isEmpty()) {
                        wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                        Map<String, Object> mapUtil = new Map<String, Object>{  'wrReq' => wrReq,
                                                                                'wrResp' => wrResp,
                                                                                'posList' => accList.get(0).Points_of_Service__r,
                                                                                'mapPosAddr' => mapPosAddr
                                                                                };
                        posWrLIST = XC_REST_Account_U.insertUpdatePos(mapUtil);
                        if(posWrLIST.isEmpty()){
                                return; 
                        }
                } 
                

                // Billing Profile
                List<XC_UTIL_Sobject.WrapperResult> billingProfileWrLIST = new List<XC_UTIL_Sobject.WrapperResult>();
                if(wrReq.BillingProfile != null) {
                        wrResp.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
                        billingProfileWrLIST = XC_REST_Account_B.insertUpdateBillingProfile(wrReq.BillingProfile, mapInfos, wrResp, true);
                        if(billingProfileWrLIST.isEmpty()){
                                return;
                        }
                }

                // Create Response 
                XC_REST_Account_U.createResponse(wrReq.Account.AccountID,contactWrLIST, addressWrLIST, billingProfileWrLIST, identityWrLIST, posWrLIST, wrResp, mapHeader.get('ClientSystem'));

                 if(wrResp.Result.Message.contains('Document alredy exist')&&mapHeader.get('ClientSystem')=='E-Commerce'){
                        wrResp.Result.ErrorCode = '501';
                }
        }


        /**
         * **************************************************************************************************************************************************************************************************.
         * @param mapUtilIdentity - Map<String, Object>
         * @return the list
         * @description Method to insert or update Identity
         * ***************************************************************************************************************************************************************************************************
         */
        public static List<XC_UTIL_Sobject.WrapperResult> insertUpdateIdentity(Map<String, Object> mapUtilIdentity, String method){
                
                List<XC_UTIL_Account.IdentityIFWrapper> identityList = (List<XC_UTIL_Account.IdentityIFWrapper>) mapUtilIdentity.get('identityList');
                String contactID = (String) mapUtilIdentity.get('contactID');
                String accountID = (String) mapUtilIdentity.get('accountID');
                String accountType = (String) mapUtilIdentity.get('accountType');
                XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) mapUtilIdentity.get('wrResp');
                List<XC_PersonalDocument__c> docList = (List<XC_PersonalDocument__c>) mapUtilIdentity.get('docList');

                List<Id> docdIdList = new List<Id>();
                if(docList != null && !docList.isEmpty()){
                       docdIdList =  XC_UTIL_SObject.getIds(docList);
                }
               
                List<XC_PersonalDocument__c> docToUpsertList = new List<XC_PersonalDocument__c>();
                for(XC_UTIL_Account.IdentityIFWrapper docWr : identityList) {
                        /*if(String.isNotBlank(docWr.IdentityID) && !docdIdList.contains(docWr.IdentityID)) {
                                wrResp.Result.Message = 'ERROR. Identity with id ' + docWr.IdentityID + ' does not exist for the Account ' + accountID;
                                wrResp.Result.ErrorCode = '400';
                                return new List<XC_UTIL_Sobject.WrapperResult>();
                        }*/

                        if(String.isBlank(docWr.IdentityID) || (String.isNotBlank(docWr.IdentityID) && docWr.IdentityID != accountID)) {
                                accountID = (accountType == 'Residential') ? accountID : '';
                                XC_PersonalDocument__c docToProcess = XC_REST_Account_ZZZ.createIdentityFromWrapper(docWr, accountID, contactID);
                                docToUpsertList.add(docToProcess);
                        }
                }

                if(method == 'POST' && accountType == 'Residential'){
                        docToUpsertList[0].XC_MainDocument__c = true;

                } else if(method == 'PUT' && accountType == 'Residential' && docList.isEmpty()){
                        docToUpsertList[0].XC_MainDocument__c = true;
               
                }
                
                docList = docToUpsertList;
                List<XC_UTIL_Sobject.WrapperResult> docListUpsertRes = XC_UTIL_Sobject.upsertListRecords(docToUpsertList);
                return docListUpsertRes;
        }


        /**
         * **************************************************************************************************************************************************************************************************.
         * @param wrReq - XC_REST_Account_W.WrapperRequest
         * @param infoParameters -  Map<String, String>
         * @param wrResp the wr resp
         * @param contactList the contact list
         * @return the list
         * @description Method to insert or update Contacts
         * ***************************************************************************************************************************************************************************************************
         */
        public static List<XC_UTIL_Sobject.WrapperResult> insertUpdateContact(XC_REST_Account_W.WrapperRequest wrReq, Map<String, String> infoParameters, XC_REST_Account_W.WrapperResponse wrResp, List<Contact> contactList,  Map<String, Object> mapUtilConDoc) {
                List<Id> contactIdList = new List<Id>();
                Map<XC_UTIL_Account.ContactIFWrapper, Contact> mapConWrCon = new Map<XC_UTIL_Account.ContactIFWrapper, Contact>();
                List<String> idNumberList = new List<String>();
                Set<String> docTypeSet = new Set<String>();
                Map<XC_UTIL_Account.ContactIFWrapper, Contact> gdprContactMap = new Map<XC_UTIL_Account.ContactIFWrapper, Contact>();
                // Map<List<XC_UTIL_Account.LegalEntityWrapper>, Contact> gdprContactMap = new Map<List<XC_UTIL_Account.LegalEntityWrapper>, Contact>();
                Map<Id,String> conLegal = new Map<Id,String>();
        
                if(contactList != null && !contactList.isEmpty()){
                        contactIdList = XC_UTIL_SObject.getIds(contactList);    
                        for(Contact c : contactList){
                                conLegal.put(c.Id, c.XC_MainLegalEntity__c);
                        }
                }
        
                String contactType;
                if(String.isBlank(wrReq.Account.AccountType)){ 
                        contactType = infoParameters.get('accountType');
                } else { 
                        contactType = wrReq.Account.AccountType;
                }
                
                // For CommodityB2C
                checkEmailDuplicatedForCommodity (wrReq, infoParameters);
        
                // Upsert input Contact:
                System.debug('@@@ List Contact Ids -> ' + contactIdList);
                List<Contact> contactToUpsertList = new List<Contact>();
                List<String> listDocKey = new List<String>();
                for(XC_UTIL_Account.ContactIFWrapper conWr : wrReq.Contact) {
                        System.debug('@@@ For Contact Id -> ' + conWr.ContactID);
                        // If Contact id is not null:
                        if(String.isNotBlank(conWr.ContactID) && !contactIdList.contains(conWr.ContactID)) {
                                wrResp.Result.Message = 'ERROR. Contact with id ' + conWr.ContactID + ' does not exist for the Account ' + infoParameters.get('accountId');
                                wrResp.Result.ErrorCode = '400';
                                return new List<XC_UTIL_Sobject.WrapperResult>();
                        }
                        // else...
                        
                        // populates document information at the contact level if it is missing. Useful for duplication logics. Only in POST in case of Residential for a primary contact.
                        populateContactDocumentInfo(wrReq, infoParameters, conWr);

                        Contact contactToProcess = XC_REST_Account_ZZZZ.createContactFromWrapper(conWr, infoParameters, contactType, conLegal);                   
                        contactToProcess.XC_isGuestContact__c = infoParameters.get('isGuest');
                        List<String> listOfClientSystemSkip = new List<String>();
                        listOfClientSystemSkip = Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';');
                        contactToProcess.XC_SecondaryEmail__c = (listOfClientSystemSkip.contains(infoParameters.get('clientSystem')) && !String.isBlank(infoParameters.get('SecondaryEmailContact'))) ? infoParameters.get('SecondaryEmailContact') : contactToProcess.XC_SecondaryEmail__c; // commodity uses only POST API. We have only one contact. (the primary contact)
                //Mod CV.Task New005A_I Add XC_RecordTypeName__c to future match on RecordType Name Start --->
                contactToProcess.XC_RecordTypeName__c = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosById().get(contactToProcess.RecordTypeId).getName();
                //Mod CV.Task New005A_I Add XC_RecordTypeName__c to future match on RecordType Name End <---

                        contactToUpsertList.add(contactToProcess);
                        listDocKey.add(conWr.IdentityType + '_' + conWr.IdentityNumber);
                }
        
                // Upsert contacts:
                System.debug('@@@ List Contact to Upsert -> ' + contactToUpsertList);
                List<XC_UTIL_Sobject.WrapperResult> conListUpsertRes = new List<XC_UTIL_Sobject.WrapperResult>();
                if(!contactToUpsertList.isEmpty()){
                        XC_UTIL_AccountDuplication.UpertedContactWrapper upsertResWrapper = XC_UTIL_AccountDuplication.upsertContacts(contactToUpsertList, listDocKey);
                        conListUpsertRes = upsertResWrapper.listResult;
                        contactToUpsertList = upsertResWrapper.listContact;
                }

                // Manage Personal Documents:
                if(wrReq.Identity != null) {
                        for(XC_UTIL_Account.IdentityIFWrapper idWr : wrReq.Identity) {
                                Boolean found = false;
                                String identityId = '';
                                for(Contact cntTemp : contactToUpsertList) {
                                        if(!found) {
                                                for(XC_PersonalDocument__c pd : cntTemp.Personal_Documents__r) {
                                                        if(pd.XC_Country__c == idWr.Country && pd.XC_DocumentNumber__c == idWr.IdentityNumber && pd.XC_DocumentType__c == idWr.IdentityType) {
                                                                found = true;
                                                                identityId = pd.Id;
                                                                break;
                                                        }
                                                }
                                        } else {
                                                break;
                                        }
                                }
                                if(found && String.isNotBlank(identityId)) {
                                        idWr.IdentityID = identityId;
                                }
                        }
                }
        
                // Populate maps:
                Contact conB = new Contact();
                Boolean checkContact = false;

                for(XC_UTIL_Account.ContactIFWrapper conWr : wrReq.Contact) {
                        Contact contactToProcess = new Contact();
                        Contact contactToCheck = XC_REST_Account_ZZZZ.createContactFromWrapper(conWr, infoParameters, contactType, conLegal);
                    	contactToCheck.XC_ContactDocumentType__c = conWr.IdentityType;
                    	contactToCheck.XC_ContactDocumentNumber__c = conWr.IdentityNumber;
                        Boolean found = false;	
                        Integer i=0;

                        for(Contact cnt : contactToUpsertList) {
                            	if(listDocKey[i] != null && String.isNotBlank(listDocKey[i]) && listDocKey[i].split('_').size() == 2) {
                            		cnt.XC_ContactDocumentType__c = listDocKey[i].split('_')[0];
                            		cnt.XC_ContactDocumentNumber__c = listDocKey[i].split('_')[1];
                                } 

                                if(XC_UTIL_AccountDuplication.checkContactMatching(contactToCheck, cnt, listDocKey[i].split('_'))) {
                                        found = true;
                                        contactToProcess = cnt;
                                        
                                        break;
                                }
                                i++;
                                
                        }

                        if(!found) {
                                //break;
                                contactToProcess = contactToCheck;
                        }

                        if(conWr.GDPR != null && conWr.GDPR.LegalEntity != null && !conWr.GDPR.LegalEntity.isEmpty()){
                                gdprContactMap.put(conWr, contactToProcess);
                                // gdprContactMap.put(conWr.GDPR.LegalEntity, contactToProcess);
                        }
                        if(conWr.PrimaryContact != null && conWr.PrimaryContact == true){
                                mapUtilConDoc.put('primaryContact', contactToProcess);
                                conB = contactToProcess;
                        }
                        if(String.isBlank(conWr.ContactID) && !checkContact) {
                                conB = contactToProcess;
                                checkContact = true;
                        }
                        if(!String.isBlank(conWr.IdentityNumber)){
                                mapConWrCon.put(conWr, contactToProcess);
                                idNumberList.add(conWr.IdentityNumber);
                                if(!String.isBlank(conWr.IdentityType)){
                                        docTypeSet.add(conWr.IdentityType);
                                }
                        }
                        
                        //contactToUpsertList.add(contactToProcess);
                }  
        
                // Set result and check duplicate
                List<Id> contactIdResult = new List<Id>();
                Boolean contactDuplicated = false;
                for(XC_UTIL_Sobject.WrapperResult wrResult : conListUpsertRes) {
                        if(!wrResult.success) {
                                if((wrResult.errorMessage== Label.XC_CL_ContactDuplicationError || wrResult.errorMessage == Label.XC_CL_GuestContactDuplicationError) && infoParameters.get('clientSystem') == 'XRecharge'){
                                        contactDuplicated = true;
                                        break;
                                }
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.Message = 'INTERNAL ERROR: In Contact Section, ' + wrResult.errorMessage;
                                wrResp.Result.logError = 'INTERNAL ERROR: In Contact Section, ' + wrResult.errorMessage;
                                wrResp.Contact = null;
                                return new List<XC_UTIL_Sobject.WrapperResult>();
                        }else{
                                contactIdResult.add(wrResult.recordId); 
                        }
                } 
        
                if(contactDuplicated){
                        manageContactDuplicationError(wrReq, wrResp, infoParameters.get('isGuest'));
                        if(wrResp.Result.ErrorCode == '500'){
                                return new List<XC_UTIL_Sobject.WrapperResult>();
                        }
                }
        
                if(gdprContactMap.size()>0){
                        Map<String,Object> utilMap = new Map<String,Object>{'gdprContactMap' => gdprContactMap, 
                                                                             'account' => infoParameters.get('account'),
                                                                             'clientSystem' => infoParameters.get('clientSystem')
                        };

                        XC_REST_Account_U.setIndividual(gdprContactMap, contactIdResult);
                        XC_REST_Account_U.createLegalEntity(wrReq, utilMap, wrResp);
                        if(wrResp.Result.ErrorCode == '500'){
                                return new List<XC_UTIL_Sobject.WrapperResult>();
                        }
                }
        
                String legalEntity;
                if(conB.Id != null){
                        infoParameters.put('contactId', conB.Id);
                        infoParameters.put('contactInfo', JSON.Serialize(conB));
                        if(String.isNotBlank(conB.XC_MainLegalEntity__c)) {
                                legalEntity =  conB.XC_MainLegalEntity__c;
                        } else {
                                for(Contact c : contactList) {
                                        if(c.Id == conB.Id) {
                                                legalEntity = c.XC_MainLegalEntity__c;
                                        }
                                }
                        }
                }else{
                        infoParameters.put('contactId', contactList[0].Id);
                        infoParameters.put('contactInfo', JSON.Serialize(contactList[0]));
                        legalEntity = contactList[0].XC_MainLegalEntity__c;
                        for(Contact c : contactList) {
                                if(c.XC_PrimaryContact__c) {
                                        infoParameters.put('contactId', c.Id);
                                        infoParameters.put('contactInfo', JSON.Serialize(c));
                                        legalEntity = c.XC_MainLegalEntity__c;
                                        break;
                                }
                        }
                }
                infoParameters.put('legalEntity', legalEntity);
                system.debug('Contact legalEntity '+  legalEntity);
                
                //insertUpdatePersonalDocument infos
                mapUtilConDoc.put('mapConWrCon', mapConWrCon);
                mapUtilConDoc.put('infoParameters', infoParameters);
                mapUtilConDoc.put('idNumberList', idNumberList);
                mapUtilConDoc.put('docTypeSet', docTypeSet);
                mapUtilConDoc.put('contactList', contactList);
                mapUtilConDoc.put('wrResp', wrResp);
        
                return conListUpsertRes;
        }     

        
        /**
         * ****************************************************************************************
         * @param wrReq - the wrapper request
         * @param infoParameters - the util map
         * @param conWr - the contact wrapper
         * @description Method to check if document missing on contact section level for primary contact
         * **********************************************************************************************
        */   
        private static void populateContactDocumentInfo(XC_REST_Account_W.WrapperRequest wrReq, Map<String, String> infoParameters, XC_UTIL_Account.ContactIFWrapper conWr){
                
                if(infoParameters.get('method') == 'POST' &&  wrReq.Account.AccountType == 'Residential' && conWr.PrimaryContact == true 
                        && String.isBlank(conWr.IdentityType) && String.isBlank(conWr.IdentityNumber) && wrReq.Identity != null && !wrReq.Identity.isEmpty()){

                        conWr.IdentityType = wrReq.Identity[0].IdentityType;
                        conWr.IdentityNumber = wrReq.Identity[0].IdentityNumber;
                }
        }


        /**
         * ************************************************************************************
         * @param wrReq - the wrapper request
         * @param infoParameters - the util map
         * @description Method to check duplicated email for Commodity
         * ************************************************************************************
        */      
        public static void checkEmailDuplicatedForCommodity (XC_REST_Account_W.WrapperRequest wrReq, Map<String, String> infoParameters){
                List<String> listOfClientSystemSkip = new List<String>();
                listOfClientSystemSkip = Label.XC_CL_AllClientSystemForSkipAccAndContDupl.split(';');
                //manage duplication email for Commodity 
                if(infoParameters.get('method') == 'POST' && listOfClientSystemSkip.contains(infoParameters.get('clientSystem'))){
                        Set<String> emailSet = new Set<String>();
                        Integer i = 0;
                        while (i < wrReq.Contact.size()){

                                if(wrReq.Contact[i].PrimaryContact != null && wrReq.Contact[i].PrimaryContact){
                                        if(!String.isBlank(wrReq.Contact[i].Email)){
                                                emailSet.add(wrReq.Contact[i].Email);
                                        }
                                        i++;
                                }else{
                                        wrReq.Contact.remove(i);
                                }
                        }       

                        if(!emailSet.isEmpty() && infoParameters.get('BlankEmailForCommodity') != null){
                                infoParameters.put('SecondaryEmailContact', wrReq.Contact[0].Email);
                                wrReq.Contact[0].Email = '';
                        }
                }
        }

        
        
        /**
         * ************************************************************************************
         * @param wrReq - the wrapper request
         * @param wrResp - the wrapper response
         * @description Method method check duplicated contact
         * ************************************************************************************
        */
        public static void manageContactDuplicationError(XC_REST_Account_W.WrapperRequest wrReq, XC_REST_Account_W.WrapperResponse wrResp, String isGuest){


                List<String> emailList = new List<String>();
                List<String> docList = new List<String>();
                
                for(XC_UTIL_Account.ContactIFWrapper wrCon : wrReq.Contact){
                        if(!String.isBlank(wrCon.Email)){
                                emailList.add(wrCon.Email);
                        }
                        if(!String.isBlank(wrCon.IdentityNumber)){
                                docList.add(wrCon.IdentityNumber);
                        }
                }

                if(!emailList.isEmpty() || !docList.isEmpty()){
                        Map<Id,Contact> mapCon = new Map<Id,Contact>([SELECT Id, Email, XC_ContactDocumentNumber__c, XC_isGuestContact__c  FROM Contact 
                                                                      WHERE Email IN: emailList OR XC_ContactDocumentNumber__c IN: docList]);
                        if(!mapCon.isEmpty()){
                                for(String conId : mapCon.keySet()){
                                        for(XC_UTIL_Account.ContactIFWrapper wrCon : wrReq.Contact){
                                                if((mapCon.get(conId).Email==wrCon.Email || mapCon.get(conId).XC_ContactDocumentNumber__c == wrCon.IdentityNumber) && mapCon.get(conId).XC_isGuestContact__c == 'No' && isGuest == 'No'){
                                                        wrResp.Result.ErrorCode = '500';
                                                        wrResp.Result.Message = 'INTERNAL ERROR: In Contact Section, ' + Label.XC_CL_ContactDuplicationError;
                                                        wrResp.Result.logError = 'INTERNAL ERROR: In Contact Section, '+ Label.XC_CL_ContactDuplicationError;

                                                        wrResp.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
                                                        wrResp.Contact.add(new XC_UTIL_Account.ContactIFWrapper());
                                                        wrResp.Contact[0].ContactID = conId;
                                                        wrResp.Contact[0].ShippingContact = null;
                                                        wrResp.Contact[0].BillingContact = null;
                                                        return;    
                                                }else if(mapCon.get(conId).XC_isGuestContact__c  == 'Yes' && mapCon.get(conId).Email == wrCon.Email && isGuest == 'Yes'){
                                                        wrResp.Result.ErrorCode = '500';
                                                        wrResp.Result.Message = 'INTERNAL ERROR: In Contact Section, ' + Label.XC_CL_GuestContactDuplicationError;
                                                        wrResp.Result.logError = 'INTERNAL ERROR: In Contact Section, ' + Label.XC_CL_GuestContactDuplicationError;

                                                        wrResp.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
                                                        wrResp.Contact.add(new XC_UTIL_Account.ContactIFWrapper());
                                                        wrResp.Contact[0].ContactID = conId;
                                                        wrResp.Contact[0].ShippingContact = null;
                                                        wrResp.Contact[0].BillingContact = null;
                                                        return;    
                                                }
                                        }
                                }
                        }

                }

        }

        

        /**
         * ************************************************************************************
         * @param mapConWrCon - Map<XC_UTIL_Account.ContactIFWrapper, Contact> 
         * @description Method method to inser/update personal document for contact
         * ************************************************************************************
        */
        public static void insertUpdateContactPersonalDocument(Map<String, Object> mapUtil){
                
                Map<XC_UTIL_Account.ContactIFWrapper, Contact> mapConWrCon = (Map<XC_UTIL_Account.ContactIFWrapper, Contact>) mapUtil.get('mapConWrCon');
                Map<String, String> mapInfos = (Map<String, String>) mapUtil.get('infoParameters');
                List<String> idNumberList = (List<String>) mapUtil.get('idNumberList');
                Set<String> docTypeSet = (Set<String>) mapUtil.get('docTypeSet');
                List<Contact> conList = (List<Contact>) mapUtil.get('contactList');
                String accountType = (String) mapUtil.get('accountType');
                XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) mapUtil.get('wrResp');
                
                if(mapInfos.get('clientSystem') == 'XRecharge' && mapConWrCon.values()[0].RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Soho').getRecordTypeId()) {
                        // No Personal Document on Contacts for Soho and eMobility
                        wrResp.Result.ErrorCode = '0';
                        mapUtil.put('wrResp', wrResp);
                        return;
                }

                Map<Id, XC_PersonalDocument__c> mapidNumberDoc = new Map<Id, XC_PersonalDocument__c>([SELECT  Id, XC_DocumentNumber__c, XC_MainDocument__c, XC_Contact__c, XC_Country__c, XC_Contact__r.Account.XC_isGuestUser__c  FROM XC_PersonalDocument__c 
                                                                                                     WHERE XC_DocumentNumber__c IN: idNumberList AND XC_DocumentTypeFormula__c IN: docTypeSet AND XC_Contact__c != null AND XC_Contact__r.RecordTypeId =: mapConWrCon.values()[0].RecordTypeId
                                                                                                     ]);

                Map<Id, Contact> mapIdCon = (conList != null) ? populateMapContact(conList) : new Map<Id, Contact>();
                Map<Id, Boolean> mapidConPdMain = new Map<Id, Boolean>();
                Map<Id, Contact> mapidConPd = new Map<Id, Contact>();
                
                /*if(!mapIdCon.isEmpty()){
                        mapidConPd = new Map<Id, Contact>([SELECT id, (SELECT Id, XC_DocumentNumber__c, XC_MainDocument__c, XC_Contact__c FROM Personal_Documents__r WHERE XC_MainDocument__c = true)
                                                          FROM Contact WHERE Id IN:mapIdCon.keySet()]);
                }*/
              
                // FIX to manage CF update 23/04/2020
                if(!mapIdCon.isEmpty()){
                        mapidConPd = new Map<Id, Contact>([SELECT id, (SELECT Id, XC_DocumentType__c, XC_DocumentNumber__c, XC_MainDocument__c, XC_Contact__c FROM Personal_Documents__r)
                                                           FROM Contact WHERE Id IN:mapIdCon.keySet()]);
                        
                        for(Contact c : mapidConPd.values()){
                                mapidConPdMain.put(c.id, false);
                                for(XC_PersonalDocument__c pd : c.Personal_Documents__r){
                                        if(pd.XC_MainDocument__c){
                                                mapidConPdMain.put(c.id, true);
                                                break;
                                        }
                                }
                        }
                }


                List<XC_PersonalDocument__c> docListToUpsert = new List<XC_PersonalDocument__c>();

                for(XC_UTIL_Account.ContactIFWrapper conWr :mapConWrCon.keySet()){

                        // insert/update identity related to contact
                        mapInfos.put('contactIdPd', mapConWrCon.get(conWr).Id);
                        if((!String.isBlank(conWr.ContactID) && conWr.PrimaryContact == null && mapIdCon.get(mapConWrCon.get(conWr).id).XC_PrimaryContact__c) || (!String.isBlank(conWr.ContactID) && conWr.PrimaryContact != null && conWr.PrimaryContact)){
                                mapInfos.put('isPrimary', 'true');
                                mapInfos.put('isMain', !mapidConPdMain.get(conWr.ContactID) /*(mapidConPd.get(conWr.ContactID).Personal_Documents__r.isEmpty())*/ ? 'true': 'false');
                        }                        
                        
                        mapInfos.put('accountType', accountType);
                        XC_PersonalDocument__c doc = populateIdentityForContact(conWr, null, mapInfos);
                        
                        //16/12/2019
                        if(String.isBlank(conWr.ContactID) || (!String.isBlank(conWr.ContactID) && !mapidConPdMain.get(conWr.ContactID) /*mapidConPd.get(conWr.ContactID).Personal_Documents__r.isEmpty())*/)){
                                doc.XC_MainDocument__c = true;
                        }

                        for(XC_PersonalDocument__c pd : mapidNumberDoc.values()){
                                if(pd.XC_DocumentNumber__c == doc.XC_DocumentNumber__c){
                                        if(pd.XC_Contact__c == doc.XC_Contact__c){
                                                doc.Id = pd.Id;
                                                doc.XC_Country__c = pd.XC_Country__c;
                                                //doc.XC_MainDocument__c = pd.XC_MainDocument__c;
                                        }else if(doc.XC_Contact__c != pd.XC_Contact__c && doc.XC_MainDocument__c && pd.XC_MainDocument__c && mapInfos.get('isGuest') == 'No' && !pd.XC_Contact__r.Account.XC_isGuestUser__c){
                                                // duplicated identity
                                                wrResp.Result.Message = 'ERROR. Document with IdentityNumber ' + conWr.IdentityNumber + ' already exists with this ContactId: ' + pd.XC_Contact__c;
                                                wrResp.Result.ErrorCode = '500';
                                                return;
                                        }
                                }
                        }

                        // FIX to manage CF update 23/04/2020
                        if(!String.isBlank(conWr.ContactID) && !String.isBlank(conWr.IdentityType) && conWr.IdentityType ==  'CF'){
                                for(XC_PersonalDocument__c pd : mapidConPd.get(conWr.ContactID).Personal_Documents__r){
                                        if(pd.XC_DocumentType__c == 'CF'){
                                                doc.XC_MainDocument__c = pd.XC_MainDocument__c;
                                                doc.XC_DocumentNumber__c = conWr.IdentityNumber;
                                                doc.Id = pd.Id;
                                        }
                                }
                        }
                
                        docListToUpsert.add(doc);
                }
                
                // upsert identity
                List<XC_UTIL_Sobject.WrapperResult> docListUpsertRes = new List<XC_UTIL_Sobject.WrapperResult>();
                if(!docListToUpsert.isEmpty()){
                    docListUpsertRes = XC_UTIL_Sobject.upsertListRecords(docListToUpsert);
                }
                
                for(XC_UTIL_Sobject.WrapperResult wrResult : docListUpsertRes) {
                        if(!wrResult.success) {
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.Message = 'INTERNAL ERROR: In Contact Section, ' + wrResult.errorMessage;
                                wrResp.Result.logError = 'INTERNAL ERROR: In Contact Section, ' + wrResult.errorMessage;
                                return;
                        }
                } 

                updateContactDocInfo(docListToUpsert, mapUtil);
                if(wrResp.Result.ErrorCode == '500'){
                        return;
                }
               
        }


        
        /**
         * ****************************************************************************************************************
         * @param docListToUpsert - List<XC_PersonalDocument__c>
         * @description method to update document info on contact with main personal document
         * ****************************************************************************************************************
        */
        public static void updateContactDocInfo(List<XC_PersonalDocument__c> docListToUpsert, Map<String, Object> mapUtil){
                 
                XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) mapUtil.get('wrResp');
                XC_REST_Account_W.WrapperRequest  wrReq = (XC_REST_Account_W.WrapperRequest) mapUtil.get('wrReq');
               
                List<Contact> conList = new List<Contact>();
                for(XC_PersonalDocument__c personDoc : docListToUpsert){
                        if(personDoc.XC_MainDocument__c){
                                Contact con = new Contact();
                                con.id = personDoc.XC_Contact__c;
                                con.XC_ContactDocumentType__c = personDoc.XC_DocumentType__c;
                                con.XC_ContactDocumentNumber__c = personDoc.XC_DocumentNumber__c;
                                con.XC_ContactDocumentCountry__c = personDoc.XC_Country__c;
                                con.XC_ContactDocExpirationDate__c = personDoc.XC_ExpirationDate__c;
                                con.XC_ContactDocReleaseDate__c = personDoc.XC_ReleaseDate__c;
                                conList.add(con);
                        }
                }

                List<XC_UTIL_Sobject.WrapperResult> conToUpdateResult = new List<XC_UTIL_Sobject.WrapperResult>();
                if(!conList.isEmpty()){
                        conToUpdateResult =  XC_UTIL_Sobject.updateListRecords(conList);
                }

                Boolean contactDuplicated = false; 
                for(XC_UTIL_Sobject.WrapperResult wrResult : conToUpdateResult) {

                        if(!wrResult.success) {
                                if((wrResult.errorMessage == Label.XC_CL_ContactDuplicationError || wrResult.errorMessage == Label.XC_CL_GuestContactDuplicationError) && mapUtil.get('clientSystem') == 'XRecharge'){
                                        contactDuplicated = true;
                                        break;
                                }
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.Message = 'INTERNAL ERROR: In Contact Section, ' + wrResult.errorMessage;
                                wrResp.Result.logError = 'INTERNAL ERROR: In Contact Section, ' + wrResult.errorMessage;
                                wrResp.Contact = null;
                                return;
                        }
                } 

                if(contactDuplicated){
                        manageContactDuplicationError(wrReq, wrResp, (String)mapUtil.get('isGuest'));
                        if(wrResp.Result.ErrorCode == '500'){
                                return;
                        }
                }

        }


        /**
         * ************************************************************************************
         * @param conWr - XC_UTIL_Account.ContactIFWrapper
         * @param identityId - String
         * @param Map<String,String> - MapInfos
         * @return XC_PersonalDocument__c
         * @description Method method to create personal document from wrapper
         * ************************************************************************************
        */
        public static XC_PersonalDocument__c populateIdentityForContact(XC_UTIL_Account.ContactIFWrapper conWr, String identityId, Map<String,String> mapInfos){
                

                XC_PersonalDocument__c  identityFromWrapper = new XC_PersonalDocument__c();
                String accountId;
                Boolean mainDoc;
                if((conWr.PrimaryContact != null && conWr.PrimaryContact) || mapInfos.get('isPrimary') == 'true'){ 
                        accountId = mapInfos.get('accountId');
                        if(String.isBlank(conWr.ContactID)){ 
                                identityFromWrapper.XC_MainDocument__c = true;
                        }else{
                                identityFromWrapper.XC_MainDocument__c = Boolean.ValueOf(mapInfos.get('isMain'));
                        }
                }
                
                String country = mapInfos.get('country');
                String accountType = mapInfos.get('accountType');
                Map<String, Object> identityParameters = new Map<String, Object>{'Id' => identityId,
                                                                        'XC_Country__c' => country,
                                                                        'XC_DocumentType__c' => conWr.IdentityType,
                                                                        'XC_DocumentNumber__c' => conWr.IdentityNumber,
                                                                        'XC_ReleaseDate__c' => (conWr.ReleaseDate != null) ? Date.valueOf(conWr.ReleaseDate) : null,
                                                                        'XC_ExpirationDate__c' => (conWr.ExpiryDate != null) ? Date.valueOf(conWr.ExpiryDate) : null,
                                                                        //'XC_Account__c' => accountId,
                                                                        'XC_Account__c' => (accountType == 'Residential') ? accountId : '',
                                                                        'XC_Contact__c' => mapInfos.get('contactIdPd')
                                                                        };

                for(String field : identityParameters.keySet()) {
                        if(identityParameters.get(field) != null) {
                                identityFromWrapper.put(field, identityParameters.get(field));
                        }
                }
                return identityFromWrapper;
        }

        
        /**
         * ************************************************************************************
         * @param conList the con list
         * @return Map<Id, Contact>
         * @description Method to populate the map with ContactId as key and Contact as Value
         * ************************************************************************************
        */
        public static Map<Id, Contact> populateMapContact(List<Contact> conList){

                Map<Id, Contact> mapIdCon = new Map<Id, Contact>();
                for(Contact con : conList){
                        mapIdCon.put(con.Id, con); 
                }
                return mapIdCon;
        } 


        /**
         * **************************************************************************************************************************************************************************************************.
         * @param wrReq the wrapper Request
         * @param mapGdprContact 
         * @description Method to 
         * ***************************************************************************************************************************************************************************************************
         */
        public static void setIndividual (Map<XC_UTIL_Account.ContactIFWrapper, Contact> mapGdprContact,  List<Id> contactIdList){

                Map<Id,Contact> mapContact;
                if(!contactIdList.isEmpty()){
                        mapContact = new Map<Id,Contact>([SELECT IndividualId FROM Contact WHERE id IN: contactIdList]);
                }
               
                system.debug(LoggingLevel.FINEST, 'CONTACT GDPR' + mapGdprContact);
                for(Contact con : mapGdprContact.values()){
                        system.debug(LoggingLevel.FINEST, 'CONTACT GDPR1' + con);
                      con.IndividualId = mapContact.get(con.Id).individualId;
                }

        }


        
        /**
         * **************************************************************************************************************************************************************************************************.
         *
         * @param wrReq the wrapper Request
         * @param mapGdprContact 
         * @description Method to insert or update LegalEntity
         * ***************************************************************************************************************************************************************************************************
         */
        public static void createLegalEntity (XC_REST_Account_W.WrapperRequest wrReq, Map<String,Object> utilMap,  XC_REST_Account_W.WrapperResponse wrResp){
                
                
                Map<XC_UTIL_Account.ContactIFWrapper, Contact> mapGdprContact = (Map<XC_UTIL_Account.ContactIFWrapper, Contact>) utilMap.get('gdprContactMap');
                // Map<List<XC_UTIL_Account.LegalEntityWrapper>, Contact> mapGdprContact = (Map<List<XC_UTIL_Account.LegalEntityWrapper>, Contact>) utilMap.get('gdprContactMap');
                Account acc = (Account)JSON.deserialize((String)utilMap.get('account'), Account.class);

                Map<Id,XC_ConsentDescription__c> descr = new Map<Id,XC_ConsentDescription__c>([
                        SELECT id, XC_LegalEntity__c, XC_ParentDescription__c FROM XC_ConsentDescription__c WHERE XC_ParentDescription__c =: '' AND XC_ConsentStatus__c =: 'Active' ORDER BY CreatedDate DESC
                ]);
                 
                List<String> invidualIdList = new List<String>();
                List<XC_LegalEntityConsent__c > legalEntityToUpsert = new List<XC_LegalEntityConsent__c>();
                Map<Id, Individual> individualsToUpdate = new Map<Id, Individual>();
                for(XC_UTIL_Account.ContactIFWrapper conWr : wrReq.Contact){ 
                        // String individualId = mapGdprContact.get(conWr.gdpr.legalEntity).IndividualId;
                        String individualId = mapGdprContact.get(conWr).IndividualId;
                        invidualIdList.add(individualId);
                        if(String.isNotBlank(conWr.GDPR.GiveDataToThirdParties)) {
                                Individual ind = new Individual();
                                ind.Id = individualId;
                                ind.XC_GiveDataToThirdParties__c = XC_UTIL_Integration_U.convertFromStringToPicklist(conWr.GDPR.GiveDataToThirdParties);
                                individualsToUpdate.put(ind.Id, ind);
                        }
                        for(XC_UTIL_Account.LegalEntityWrapper wrLegalEn: conWr.GDPR.LegalEntity){
                                String country = XC_UTIL_Integration_U.getCountryFromLegalEntity(wrLegalEn.LegalEntity);
                                XC_LegalEntityConsent__c lec = XC_REST_Account_ZZZZ.createLegalEntityFromWrapper(wrLegalEn, individualId, country);
                                if(!descr.values().isEmpty()){
                                        for(Integer i = 0; i<descr.values().size(); i++){
                                                if(descr.values()[i].XC_LegalEntity__c==lec.XC_LegalEntity__c){
                                                        lec.XC_ConsentDescription__c = descr.values()[i].id;
                                                        break;
                                                }
                                        }     
                                }
                                legalEntityToUpsert.add(lec);
                        }
                }
                   
                checkDuplicateLegalEntity(invidualIdList, legalEntityToUpsert);

                // check if has the majority age 
                if(acc.XC_Birthdate__c != null){

                        if(utilMap.get('clientSystem') == Label.XC_CL_CommoditySpainB2C){
                                XC_TR_LegalEntityConsent_U_CheckFields.checkAlreadyDone = true;
                        }else {
                                Boolean majority = XC_TR_LegalEntityConsent_U_CheckFields.checkAge(legalEntityToUpsert, acc);
                                if(!majority){
                                        wrResp.Result.ErrorCode = '500';
                                        wrResp.Result.Message = 'INTERNAL ERROR: In Legal Entity Section, '  + Label.XC_CL_ErrorAdultAge;
                                        wrResp.Result.logError = 'INTERNAL ERROR: In Legal Entity Section,' + Label.XC_CL_ErrorAdultAge;
                                        return;
                                } else {
                                        XC_TR_LegalEntityConsent_U_CheckFields.checkAlreadyDone = true;    
                                }
                        }
                       
                }
                    
                List<XC_UTIL_Sobject.WrapperResult> legalListUpsertRes = new List<XC_UTIL_SObject.WrapperResult>();
                if(!legalEntityToUpsert.isEmpty()){
                        legalListUpsertRes = XC_UTIL_Sobject.upsertListRecords(legalEntityToUpsert);
                }
                for(XC_UTIL_Sobject.WrapperResult wrResult : legalListUpsertRes) {
                        if(!wrResult.success) {
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.Message = 'INTERNAL ERROR: In Legal Entity Section, ' + wrResult.errorMessage;
                                wrResp.Result.logError = 'INTERNAL ERROR: In Legal Entity Section, ' + wrResult.errorMessage;
                        }
                }

                List<XC_UTIL_Sobject.WrapperResult> indListUpsertRes = new List<XC_UTIL_SObject.WrapperResult>();
                if(!individualsToUpdate.isEmpty()){
                        indListUpsertRes = XC_UTIL_Sobject.upsertListRecords(individualsToUpdate.values());
                }
                for(XC_UTIL_Sobject.WrapperResult wrResult : indListUpsertRes) {
                        if(!wrResult.success) {
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.Message = 'INTERNAL ERROR: In Legal Entity Section, ' + wrResult.errorMessage;
                                wrResp.Result.logError = 'INTERNAL ERROR: In Legal Entity Section, ' + wrResult.errorMessage;
                        }
                }
                
        }


        /**
         * **************************************************************************************************************************************************************************************************.
         * @param invidualIdList the Individual List
         * @param legalEntityToUpdate The legalEntity List 
         * @description Method to check if there is a duplicate LegalEntity
         * ***************************************************************************************************************************************************************************************************
         */
        public static void checkDuplicateLegalEntity(List<String> invidualIdList, List<XC_LegalEntityConsent__c> legalEntityToUpdate){

                if(invidualIdList.size()>0){
                        Map<Id, XC_LegalEntityConsent__c> legalEnMap = new Map<Id, XC_LegalEntityConsent__c>([SELECT XC_Individual__c, XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c IN : invidualIdList]);
                        Map<Id,Map<String, XC_LegalEntityConsent__c>> indLegEnMap = new Map<Id,Map<String, XC_LegalEntityConsent__c>>();
                        Map<String, XC_LegalEntityConsent__c> entityMap; 

                        for(XC_LegalEntityConsent__c legEn : legalEnMap.values()) {
                                if(indLegEnMap.containsKey(legEn.XC_Individual__c)){
                                        indLegEnMap.get(legEn.XC_Individual__c).put(legEn.XC_LegalEntity__c, legEn);
                                }else{
                                        entityMap = new Map<String, XC_LegalEntityConsent__c>();
                                        entityMap.put(legEn.XC_LegalEntity__c, legEn);
                                        indLegEnMap.put(legEn.XC_Individual__c, entityMap);
                                }
                        }
        
                        for(XC_LegalEntityConsent__c legEn : legalEntityToUpdate){
                                if(indLegEnMap.containsKey(legEn.XC_Individual__c) && indLegEnMap.get(legEn.XC_Individual__c).containsKey(legEn.XC_LegalEntity__c)){
                                        legEn.Id = indLegEnMap.get(legEn.XC_Individual__c).get(legEn.XC_LegalEntity__c).id;
                                }
                        }
                }

        }



        /**
         * **********************************************************************************************************************************************************************************************************.
         * @param accountID the account ID
         * @param wrReq the wr req
         * @param wrResp the wr resp
         * @param addressList the address list
         * @return the list
         * @description Method to insert or update Address
         * **********************************************************************************************************************************************************************************************************
         */
        public static List<XC_UTIL_Sobject.WrapperResult> insertUpdateAddress(Map<String,String> infoParameters, XC_REST_Account_W.WrapperRequest wrReq, XC_REST_Account_W.WrapperResponse wrResp, List<XC_Address__c> addressList, Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c> mapPosAddr){

                
                List<XC_Address__c> addressListToUpsert = new List<XC_Address__c>();
                
                //List<Id> addressIdList = new List<Id>();
                Map<Id, XC_Address__c> addressMap = new Map<Id, XC_Address__c>();
                if(addressList != null && !addressList.isEmpty()) {
                       //addressIdList =  XC_UTIL_SObject.getIds(addressList);
                        for(XC_Address__c addr : addressList) {
                               addressMap.put(addr.Id, addr);
                        }
                }
                system.debug('@@@ Address ID List '+  addressMap.keySet());

                XC_Address__c soldAddr = new XC_Address__c();
                XC_Address__c billAddr = new XC_Address__c();
                Boolean checkSold = false;
                Boolean checkBill = false;
                

                String clientSystem = infoParameters.get('clientSystem');
                
                for(XC_UTIL_Address.AddressWrapper wr : wrReq.Address) {

                        if(String.isBlank(wr.AddressID)){
                                wr.DeliveryAddress = (wr.DeliveryAddress != null) ? wr.DeliveryAddress : true;
                                wr.BillingAddress = (wr.BillingAddress != null) ? wr.BillingAddress : true;
                                wr.InstallationAddress = (wr.InstallationAddress != null) ? wr.InstallationAddress : true;
                        }

                        if(!String.isBlank(wr.AddressID) && /*!addressIdList.contains(wr.AddressID)*/ !addressMap.containsKey(wr.AddressID)) {
                            wrResp.Result.Message = 'INTERNAL ERROR: Address with id ' + wr.AddressID + ' does not exist for the Account ' + infoParameters.get('accountId');
                            wrResp.Result.ErrorCode = '500';
                            wrResp.Result.logError = 'INTERNAL ERROR: Address with id ' + wr.AddressID + ' does not exist for the Account ' + infoParameters.get('accountId');
                            return new List<XC_UTIL_Sobject.WrapperResult>();
                        }

                        //For Commodity
                wr.AddressValidated = true;
                        if(infoParameters.get('method') == 'POST' && clientSystem == Label.XC_CL_CommoditySpainB2C && wr.AddressValidated != true){
                                continue; 
                        }

                        XC_Address__c addressToUpsert = XC_REST_Account_ZZZZ.createAddressFromWrapper(infoParameters, wr);
                        if(wr.PointOfService  != null && !wr.PointOfService.isEmpty()){
                                mapPosAddr.put(wr.PointOfService, addressToUpsert);
                        }
                        if(/*String.isBlank(wr.AddressID) &&*/ !checkSold && ((wr.DeliveryAddress != null && wr.DeliveryAddress) || (String.isNotBlank(wr.AddressID) && addressMap.get(wr.AddressID).XC_DeliveryAddress__c))) {
                                soldAddr = addressToUpsert;
                                checkSold = true;
                        }
                        if(/*String.isBlank(wr.AddressID) &&*/ !checkBill && ((wr.BillingAddress != null && wr.BillingAddress) || (String.isNotBlank(wr.AddressID) && addressMap.get(wr.AddressID).XC_BillingAddress__c))) {
                                billAddr = addressToUpsert;
                                checkBill = true;
                        }
                        addressListToUpsert.add(addressToUpsert);
                
                }
        

                List<XC_UTIL_Sobject.WrapperResult> resultUpsert= new List<XC_UTIL_Sobject.WrapperResult>();
                if(!addressListToUpsert.isEmpty()) {
                        resultUpsert = XC_UTIL_Sobject.upsertListRecords(addressListToUpsert);
                }

                Boolean addressDuplicated = false;

                for(XC_UTIL_Sobject.WrapperResult wrResult : resultUpsert) {

                        //fix 05/09/2019 *********
                        if(!wrResult.success && infoParameters.get('clientSystem') == 'XRecharge' &&
                                (wrResult.errorMessage=='Address already exist' || wrResult.errorMessage.containsIgnoreCase('There is already an Address'))) {
                                        addressDuplicated = true;
                                
                        } else if(!wrResult.success) {
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.Message = 'INTERNAL ERROR: In Address Section, ' + wrResult.errorMessage;
                                wrResp.Result.logError = 'INTERNAL ERROR: In Address Section, ' + wrResult.errorMessage;
                                return new List<XC_UTIL_Sobject.WrapperResult>();
                        }

                }

                //fix 05/09/2019 *********
                if(addressDuplicated){

                        List<String> countryList = new List<String>();
                        List<String> cityList = new List<String>();
                        List<String> provinceList = new List<String>();
                        List<String> numberList = new List<String>();
                        for(XC_UTIL_Address.AddressWrapper wrAdd : wrReq.Address){
                                countryList.add(wrAdd.Country);
                                cityList.add(wrAdd.City);
                                provinceList.add(wrAdd.Province);
                                numberList.add(wrAdd.StreetNumber);
                        }

                        Map<Id,XC_Address__c> mapApp = new Map<Id,XC_Address__c>([
                                SELECT id, XC_AddressCountry__c, XC_City__c, XC_AddressProvince__c, XC_StreetNumber__c FROM XC_Address__c 
                                WHERE 
                                        XC_Account__c =: wrReq.Account.AccountID AND
                                        XC_AddressCountry__c in: countryList AND 
                                        XC_City__c in: cityList AND 
                                        XC_AddressProvince__c in: provinceList AND 
                                        XC_StreetNumber__c in: numberList 
                                        ]);

                        for(String addId : mapApp.keySet()){
                                for(XC_UTIL_Address.AddressWrapper wrAdd : wrReq.Address){
                                        if(     mapApp.get(addId).XC_AddressCountry__c==wrAdd.Country &&
                                                mapApp.get(addId).XC_City__c==wrAdd.City &&
                                                mapApp.get(addId).XC_AddressProvince__c==wrAdd.Province &&
                                                mapApp.get(addId).XC_StreetNumber__c==wrAdd.StreetNumber){
                                                        
                                                wrResp.Result.ErrorCode = '500';
                                                wrResp.Result.Message = 'INTERNAL ERROR: In Address Section, Address already exist';
                                                wrResp.Result.logError = 'INTERNAL ERROR: In Address Section, Address already exist';    
                                                wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                                                wrResp.Address.add(new XC_UTIL_Address.AddressWrapper('REST'));
                                                wrResp.Address[0].AddressID = addId;
                                                return new List<XC_UTIL_Sobject.WrapperResult>();     

                                        }
                                }
                        }
   
                }
                
                String billingAddrId;
                if(addressList != null){
                        for(XC_Address__c addr: addressList){
                                if(addr.XC_BillingAddress__c){
                                        billingAddrId= addr.Id;
                                        break;
                                }
                        }
                }
                 
                if(billAddr.Id != null){
                        infoParameters.put('billId', billAddr.Id);
                }else{
                        infoParameters.put('billId', billingAddrId);
                }
                if(soldAddr.Id != null){
                        infoParameters.put('soldId', soldAddr.Id);
                }else{
                        infoParameters.put('soldId', billingAddrId);
                }

            return resultUpsert;
        }

       

        /**
         * **********************************************************************************************************************************************************************************************************.
         * @param mapUtil - Map<String, Object>
         * @return the list
         * @description Method to insert or update PointOfService
         * **********************************************************************************************************************************************************************************************************
         */
        public static List<XC_UTIL_Sobject.WrapperResult> insertUpdatePos (Map<String, Object> mapUtil){

                XC_REST_Account_W.WrapperRequest wrReq = (XC_REST_Account_W.WrapperRequest) mapUtil.get('wrReq');
                XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse)  mapUtil.get('wrResp');
                List<XC_PointOfService__c> posList = (List<XC_PointOfService__c>) mapUtil.get('posList');
                Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c> mapPosAddr = (Map<List<XC_UTIL_Address.PoSWrapper>, XC_Address__c>) mapUtil.get('mapPosAddr');

                List<XC_PointOfService__c> posListToUpsert = new List<XC_PointOfService__c>();

                List<Id> posIdList = new List<Id>();
                if( posList!= null && !posList.isEmpty()){
                       posIdList =  XC_UTIL_SObject.getIds(posList);
                }

                for(XC_UTIL_Address.AddressWrapper address : wrReq.Address){ 
                        //String addrId = mapPosAddr.get(address.PointOfService).id;
                        String addrId = (mapPosAddr.get(address.PointOfService) != null) ? mapPosAddr.get(address.PointOfService).id : null; // --
                        if(!String.isBlank(addrId)){ //--
                                for(XC_UTIL_Address.PoSWrapper wrPos: address.PointOfService){
                                        if(address.PointOfService != null && !address.PointOfService.isEmpty() && String.isNotBlank(wrPos.POSID) && !posIdList.contains(wrPos.POSID)){
                                                wrResp.Result.Message = 'ERROR. PointOfService with id ' + wrPos.POSID + ' does not exist';
                                                wrResp.Result.ErrorCode = '400';
                                                wrResp.Result.logError = 'ERROR. PointOfService with id ' + wrPos.POSID + ' does not exist';
                                                return new List<XC_UTIL_Sobject.WrapperResult>();
                                        }
                                        XC_PointOfService__c posToUpsert = XC_REST_Account_ZZZZ.createPosFromWrapper(addrId, wrPos);
                                        posToUpsert.XC_Account__c =  mapPosAddr.get(address.PointOfService).XC_Account__c;
                                        posListToUpsert.add(posToUpsert);
                                }
                        }
                }
                
                
                List<XC_UTIL_Sobject.WrapperResult> resultUpsert = new List<XC_UTIL_Sobject.WrapperResult>();
                if(!posListToUpsert.isEmpty()) {
                        resultUpsert = XC_UTIL_Sobject.upsertListRecords(posListToUpsert);
                }

                for(XC_UTIL_Sobject.WrapperResult wrResult : resultUpsert) {
                        if(!wrResult.success) {
                        wrResp.Result.ErrorCode = '500';
                        wrResp.Result.Message = 'INTERNAL ERROR: In Address/Pos Section, ' + wrResult.errorMessage;
                        wrResp.Result.logError = 'INTERNAL ERROR: In Address/Pos Section, ' + wrResult.errorMessage;
                        return new List<XC_UTIL_Sobject.WrapperResult>();
                        }
                }
                
                return resultUpsert;
        }




    /**
    * **************************************************************************************************************************************************************************************************.
    * @param mapUtil - Map<String,Object>
    * @return Account List
    * @description Method to get Account List from request params
    * ***************************************************************************************************************************************************************************************************
    */
    public static List<Account> getAccountList(Map<String,Object> mapUtil){

        List<Account> listAcc = new List<Account> ();
        String uniqueID = ((Map<String, String>)mapUtil.get('params')).get('UniqueID');
        String accountId = ((Map<String, String>)mapUtil.get('params')).get('AccountID');
        String email = ((Map<String, String>)mapUtil.get('params')).get('PrimaryEmail');
        String identityNumber = ((Map<String, String>)mapUtil.get('params')).get('IdentityNumber');
        String identityType = ((Map<String, String>)mapUtil.get('params')).get('IdentityType');
        String companyCode = ((Map<String, String>)mapUtil.get('params')).get('CompanyCode');

        Map<Id, List<NE__Order__c>>  mapAccIdOrder = (Map<Id, List<NE__Order__c>>) mapUtil.get('mapAccIdOrder');
        Map<Id, String> mapAccIdCS = (Map<Id, String>) mapUtil.get('mapAccIdCS');
		
        //Fix to exclude the Assets and the Addresses created by Migration Technical Asset User
    	String excludeUserId;
    	XC_CS_UtilityGlobalValues__c cs = XC_CS_UtilityGlobalValues__c.getInstance('XC_MigrationTechnicalAssetID');
        if(cs != null){
            excludeUserId = cs.Value__c; 
        }

        if(String.isNotBlank(companyCode)) {
            
            List<NE__Product__c> prodList = new List<NE__Product__c>(
                [SELECT Id, 
                (SELECT Id, NE__ProdId__c, NE__Order_Config__c, NE__Order_Config__r.XC_Company_Code__c, NE__Order_Config__r.XC_Cost_Center__c, NE__Order_Config__r.NE__AccountId__c FROM NE__Asset_Prod__r WHERE XC_CompanyCode__c =: companyCode AND NE__Order_Config__r.NE__Type__c = 'InOrder' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff),
                (SELECT Id, NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__ProductFamily__r WHERE NE__FamilyId__r.XC_LIC_Family_Name__c = :Label.XC_CL_Family_JNManager)
                FROM NE__Product__c
                WHERE Id IN 
                (SELECT NE__ProdId__c FROM Asset WHERE XC_CompanyCode__c =: companyCode AND NE__Order_Config__r.NE__Type__c = 'InOrder' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff AND CreatedById !=: excludeUserId)]);
            
            Map<Id, NE__Order__c> ordList = new Map<Id, NE__Order__c>();
            Set<Id> accIdList = new Set<Id>();
            for(NE__Product__c pr : prodList) {
                if(pr.NE__ProductFamily__r.isEmpty()) {
                    for(Asset a : pr.NE__Asset_Prod__r) {
                        NE__Order__c ord = new NE__Order__c();
                        ord.Id = a.NE__Order_Config__c;
                        ord.XC_Cost_Center__c = a.NE__Order_Config__r.XC_Cost_Center__c;
                        ord.XC_Company_Code__c = a.NE__Order_Config__r.XC_Company_Code__c;
                        ord.NE__AccountId__c = a.NE__Order_Config__r.NE__AccountId__c;
                        ordList.put(ord.id, ord);
                        accIdList.add(a.NE__Order_Config__r.NE__AccountId__c);
                    }
                }
            }
            
            mapAccIdOrder.putAll(XC_REST_Account_U.createMapAccIdOrder(ordList.values()));
            Map<Id, Account> mapIdAcc = new Map<Id, Account>(
                [SELECT Id, XC_UniqueId__c, XC_AccountType__c, XC_AccountNationality__c, ParentId, XC_CertifiedEmail__c,  XC_Status__c,  XC_RecordTypePick__c, XC_RecordTypeDeveloperName__c, Name, XC_LastName__c, XC_FirstName__c, XC_MainPhonePrefix__c, XC_AccountMainPhone__c, PrimaryEmail__c, XC_AccountPhonePrefix__c, XC_AccountPhone__c, Country__c, XC_Birthdate__c, XC_Preference_Language__c, XC_Notes__c, XC_PreferredPartner__c, XC_Blacklist_result__c, XC_Score__c, XC_DataLakeScore__c, IdentityType__c, IdentityNumber__c, XC_NIE_expiration_date__c,  XC_NIE_expedition_date__c, XC_DocumentCountry__c, XC_SplitPayment__c, XC_SohoType__c, XC_isGuestUser__c, RecordType.DeveloperName, XC_GIRO__c, /*20220402 NicoloFodera NR1954  Add XC_GIRO__c field in read Account*/
                (SELECT Id, XC_Country__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_ExpirationDate__c, XC_Issued_By__c, XC_Issued_On__c, XC_Issue_Place__c, XC_Issue_Province__c, XC_Issue_Country__c, XC_Contact__c FROM Personal_Documents__r), 
                (SELECT Id, LastName, FirstName, Salutation, IndividualId, XC_PrimaryContact__c, Email, XC_MobilePrefix__c, XC_ContactMobile__c, MobilePhone, XC_ContactPhone__c, XC_PhonePrefix__c, Phone, Birthdate, XC_Preferredlanguageofcontact__c,  XC_HourToBeRecontacted__c, XC_Nationality__c, XC_External_ID__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c, XC_ContactDocumentNumber__c, XC_Birth_Place__c, XC_Birth_Country__c, XC_Birth_Province__c, XC_Citizenship__c, XC_Sex__c, XC_ContactDocumentCountry__c FROM Contacts),
                (SELECT Id, Name, XC_Category__c,XC_StreetTypeText__c, XC_Address__c, XC_PostalCode__c, XC_AddressProvince__c, XC_City__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_Stair__c, XC_InstallationAddress__c, XC_BillingAddress__c, XC_DeliveryAddress__c, XC_Municipality__c,  XC_AddressCountry__c, XC_Note__c, XC_AddressValidated__c, XC_ClarificatorType__c, XC_ClarificatorValue__c, XC_Region__c FROM Addresses__r WHERE CreatedById !=: excludeUserId), 
                (SELECT Id, Name, XC_Type__c, XC_Address__c  FROM Points_of_Service__r), (SELECT Id, NE__Card_Number__c , Name, NE__Billing_Media__c, NE__Payment__c, CurrencyIsoCode, NE__Description__c, B2WZC__Zuora_MethodPaymentId__c, NE__Account__c, XC_InvoicePreferredLanguage__c, XC_InvoiceDeliveryPref__c , XC_Province__c, XC_City__c, XC_ZipCode__c, NE__Mail_To__c, XC_User_Number__c, NE__Card_Type__c, XC_Token__c , NE__Expiration__c, NE__Expiration_Year__c, NE__Iban__c, XC_CommodityCupsID__c, XC_CommodityContractID__c, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_MandateType__c, XC_BIC__c, XC_Status__c, XC_PayPalUsername__c, XC_SAPBusinessPartner__c, XC_StatusReason__c, XC_StatusReasonDetails__c, XC_LastEventDate__c, XC_CommodityUsage__c, XC_ConsumptionNumber__c, XC_OPDocumentNumber__c, XC_OPDocumentType__c FROM NE__Billing_Profiles__r),
                (SELECT Id,XC_BillingProfile__c, XC_ExternalKey__c, XC_RecipientCode__c, XC_PEC__c, XC_BillToAddressText__c, XC_SoldToAddressText__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_LegalEntity__c FROM XC_BillingProfileLineItems__r), XC_Community_Typology__c, XC_Community_Code__c, XC_GSE_Code__c, XC_Community_Members_Number__c, XC_Community_GSE_Approval_Date__c, XC_Energy_Community_Foundation_date__c, XC_Member_Typology__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c, XC_Refund_Method__c, XC_CustomerNumber_EnelEnergia__c, XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Annual_membership_fee_due_date__c, XC_Fix_part_sharing_monthly__c, XC_Energy_Community__c  
                FROM Account 
                WHERE Id IN :accIdList]); //Added Fields, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche
            listAcc = mapIdAcc.values();

        } else if(String.isNotBlank(identityNumber)) {
            
            Map<Id, Account> mapIdAcc = new Map<Id, Account>();
            
            // Residential
            mapIdAcc = new Map<Id, Account>(
                [SELECT Id, XC_UniqueId__c, XC_AccountType__c, XC_AccountNationality__c, ParentId, XC_CertifiedEmail__c,XC_Status__c, XC_RecordTypePick__c, XC_RecordTypeDeveloperName__c, Name, XC_LastName__c, XC_FirstName__c, XC_MainPhonePrefix__c, XC_AccountMainPhone__c, PrimaryEmail__c, XC_AccountPhonePrefix__c, XC_AccountPhone__c, Country__c, XC_Birthdate__c, XC_Preference_Language__c, XC_Notes__c, XC_PreferredPartner__c, XC_Blacklist_result__c, XC_Score__c, XC_DataLakeScore__c, IdentityType__c, IdentityNumber__c, XC_NIE_expiration_date__c,  XC_NIE_expedition_date__c, XC_DocumentCountry__c, XC_SplitPayment__c, XC_SohoType__c, XC_isGuestUser__c, RecordType.DeveloperName, XC_GIRO__c, /*20220402 NicoloFodera NR1954  Add XC_GIRO__c field in read Account*/
                (SELECT Id, XC_Country__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_ExpirationDate__c, XC_Issued_By__c, XC_Issued_On__c, XC_Issue_Place__c, XC_Issue_Province__c, XC_Issue_Country__c, XC_Contact__c FROM Personal_Documents__r WHERE XC_DocumentNumber__c =: IdentityNumber), 
                (SELECT Id, LastName, FirstName, Salutation, IndividualId, XC_PrimaryContact__c, Email, XC_MobilePrefix__c, XC_ContactMobile__c, MobilePhone, XC_ContactPhone__c, XC_PhonePrefix__c, Phone, Birthdate, XC_Preferredlanguageofcontact__c, XC_HourToBeRecontacted__c, XC_Nationality__c, XC_External_ID__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c, XC_ContactDocumentNumber__c, XC_Birth_Place__c, XC_Birth_Country__c, XC_Birth_Province__c, XC_Citizenship__c, XC_Sex__c, XC_ContactDocumentCountry__c FROM Contacts),
                (SELECT Id, Name, XC_Category__c, XC_Address__c, XC_PostalCode__c, XC_AddressProvince__c, XC_City__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_Stair__c, XC_InstallationAddress__c, XC_BillingAddress__c, XC_DeliveryAddress__c, XC_Municipality__c,  XC_AddressCountry__c,XC_StreetTypeText__c , XC_Note__c, XC_AddressValidated__c, XC_ClarificatorType__c, XC_ClarificatorValue__c, XC_Region__c FROM Addresses__r WHERE CreatedById !=: excludeUserId), 
                (SELECT Id, Name, XC_Type__c, XC_Address__c  FROM Points_of_Service__r), 
                (SELECT Id, NE__Card_Number__c,  Name, NE__Billing_Media__c, NE__Payment__c, CurrencyIsoCode, NE__Description__c, B2WZC__Zuora_MethodPaymentId__c, NE__Account__c, XC_InvoicePreferredLanguage__c, XC_InvoiceDeliveryPref__c , XC_Province__c, XC_City__c, XC_ZipCode__c, NE__Mail_To__c, XC_User_Number__c, NE__Card_Type__c, XC_Token__c , NE__Expiration__c, NE__Expiration_Year__c, NE__Iban__c, XC_CommodityCupsID__c, XC_CommodityContractID__c, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_MandateType__c, XC_BIC__c, XC_Status__c, XC_PayPalUsername__c, XC_SAPBusinessPartner__c, XC_StatusReason__c, XC_StatusReasonDetails__c, XC_LastEventDate__c, XC_CommodityUsage__c, XC_ConsumptionNumber__c, XC_OPDocumentNumber__c, XC_OPDocumentType__c FROM NE__Billing_Profiles__r),
                (SELECT Id,XC_BillingProfile__c, XC_ExternalKey__c, XC_RecipientCode__c, XC_PEC__c, XC_BillToAddressText__c, XC_SoldToAddressText__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_LegalEntity__c FROM XC_BillingProfileLineItems__r), XC_Community_Typology__c, XC_Community_Code__c, XC_GSE_Code__c, XC_Community_Members_Number__c, XC_Community_GSE_Approval_Date__c, XC_Energy_Community_Foundation_date__c, XC_Member_Typology__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c, XC_Refund_Method__c, XC_CustomerNumber_EnelEnergia__c, XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Annual_membership_fee_due_date__c, XC_Fix_part_sharing_monthly__c, XC_Energy_Community__c   
                FROM Account 
                WHERE Id IN 
                (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c =: IdentityNumber)]); //Added Fields, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche
            listAcc = mapIdAcc.values();
            
            // !Residential
            if(listAcc.isEmpty()){
                mapIdAcc = new Map<Id, Account>(
                    [SELECT Id, XC_UniqueId__c, XC_AccountType__c, XC_AccountNationality__c, ParentId, XC_CertifiedEmail__c, XC_Status__c, XC_RecordTypePick__c, XC_RecordTypeDeveloperName__c, Name, XC_LastName__c, XC_FirstName__c, XC_MainPhonePrefix__c, XC_AccountMainPhone__c, PrimaryEmail__c, XC_AccountPhonePrefix__c, XC_AccountPhone__c, Country__c, XC_Birthdate__c, XC_Preference_Language__c, XC_Notes__c, XC_PreferredPartner__c, XC_Blacklist_result__c, XC_Score__c, XC_DataLakeScore__c, IdentityType__c, IdentityNumber__c, XC_NIE_expiration_date__c,  XC_NIE_expedition_date__c, XC_DocumentCountry__c, XC_SplitPayment__c, XC_SohoType__c, XC_isGuestUser__c, RecordType.DeveloperName, XC_GIRO__c, /*20220402 NicoloFodera NR1954  Add XC_GIRO__c field in read Account*/
                    (SELECT Id, LastName, FirstName, Salutation, IndividualId, XC_PrimaryContact__c, Email, XC_MobilePrefix__c, XC_ContactMobile__c, MobilePhone, XC_ContactPhone__c, XC_PhonePrefix__c, Phone, Birthdate, XC_Preferredlanguageofcontact__c,  XC_HourToBeRecontacted__c, XC_Nationality__c, XC_External_ID__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c, XC_DoNotDisturb__c, XC_Birth_Place__c, XC_Birth_Country__c, XC_Birth_Province__c,  XC_Citizenship__c, XC_Sex__c, XC_ContactDocumentCountry__c FROM Contacts), 
                    (SELECT Id, Name, XC_Category__c, XC_Address__c, XC_PostalCode__c, XC_AddressProvince__c, XC_City__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_Stair__c, XC_InstallationAddress__c, XC_BillingAddress__c, XC_DeliveryAddress__c, XC_Municipality__c,  XC_AddressCountry__c,XC_StreetTypeText__c , XC_Note__c, XC_AddressValidated__c, XC_ClarificatorType__c, XC_ClarificatorValue__c, XC_Region__c FROM Addresses__r WHERE CreatedById !=: excludeUserId), 
                    (SELECT Id, Name, XC_Type__c, XC_Address__c  FROM Points_of_Service__r),
                    (SELECT Id, NE__Card_Number__c, Name, NE__Billing_Media__c, NE__Payment__c, CurrencyIsoCode, NE__Description__c, B2WZC__Zuora_MethodPaymentId__c, NE__Account__c, XC_InvoicePreferredLanguage__c, XC_InvoiceDeliveryPref__c , XC_Province__c, XC_City__c, XC_ZipCode__c, NE__Mail_To__c, XC_User_Number__c, NE__Card_Type__c, XC_Token__c , NE__Expiration__c, NE__Expiration_Year__c, NE__Iban__c, XC_CommodityCupsID__c, XC_CommodityContractID__c, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_MandateType__c, XC_BIC__c, XC_Status__c, XC_PayPalUsername__c, XC_SAPBusinessPartner__c, XC_StatusReason__c, XC_StatusReasonDetails__c, XC_LastEventDate__c, XC_CommodityUsage__c, XC_ConsumptionNumber__c, XC_OPDocumentNumber__c, XC_OPDocumentType__c FROM NE__Billing_Profiles__r),
                    (SELECT Id, XC_BillingProfile__c, XC_ExternalKey__c, XC_RecipientCode__c, XC_PEC__c, XC_BillToAddressText__c, XC_SoldToAddressText__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_LegalEntity__c FROM XC_BillingProfileLineItems__r), XC_Community_Typology__c, XC_Community_Code__c, XC_GSE_Code__c, XC_Community_Members_Number__c, XC_Community_GSE_Approval_Date__c, XC_Energy_Community_Foundation_date__c, XC_Member_Typology__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c, XC_Refund_Method__c, XC_CustomerNumber_EnelEnergia__c, XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Annual_membership_fee_due_date__c, XC_Fix_part_sharing_monthly__c,XC_Energy_Community__c
                    FROM Account
                    WHERE IdentityNumber__c =: identityNumber]); //Added Fields, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche
                listAcc = mapIdAcc.values();
            }
            
            
            if(String.isNotBlank(identityType)&&String.isNotBlank(identityNumber)&&!listAcc.isEmpty()){
                List<Account> listTemp = new List<Account>();
                for(Account a : listAcc){
                    boolean docFound = false;
                    for(XC_PersonalDocument__c d : a.Personal_Documents__r){
                        if(d.XC_DocumentType__c == identityType){
                            docFound = true;
                            break;
                        }
                    }
                    
                    if(a.IdentityType__c == identityType || docFound){
                        listTemp.add(a);
                    }
                }
                listAcc = listTemp;
            }
            
            
        } else if(String.isNotBlank(accountId) || String.isNotBlank(email) || String.isNotBlank(uniqueID)){
            
            listAcc = createDynamicQuery(accountId, email, uniqueID, excludeUserId);
        }
        
        return listAcc;
    }
    
    
    /**
    * **************************************************************************************************************************************************************************************************.
    * @param accountId - String
    * @param email - String
    * @return Account List
    * @description Method to create a dynamic query to retrieve Account List
    * ***************************************************************************************************************************************************************************************************
    */
    public static List<Account> createDynamicQuery(String accountId, String email, String uniqueID, String excludeUserId){

        Boolean whereCondition = false;
        String query = 'SELECT Id, XC_UniqueId__c, XC_AccountType__c, XC_AccountNationality__c, XC_RecordTypePick__c, XC_RecordTypeDeveloperName__c, Name, XC_CertifiedEmail__c, ParentId, XC_Status__c, XC_LastName__c, XC_FirstName__c, XC_MainPhonePrefix__c, XC_AccountMainPhone__c, PrimaryEmail__c, XC_AccountPhonePrefix__c, XC_AccountPhone__c, Country__c, XC_Birthdate__c, XC_Preference_Language__c, XC_Notes__c, XC_PreferredPartner__c, XC_Blacklist_result__c, XC_Score__c, XC_DataLakeScore__c, IdentityType__c, IdentityNumber__c, XC_NIE_expiration_date__c,  XC_NIE_expedition_date__c, XC_DocumentCountry__c, XC_SplitPayment__c, XC_SohoType__c, XC_isGuestUser__c, RecordType.DeveloperName, XC_GIRO__c, (SELECT Id, XC_Country__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_ExpirationDate__c, XC_Issued_By__c, XC_Issued_On__c, XC_Issue_Place__c, XC_Issue_Province__c, XC_Issue_Country__c, XC_Contact__c  FROM Personal_Documents__r), (SELECT Id, LastName, FirstName, Salutation, IndividualId,  XC_PrimaryContact__c, Email, XC_MobilePrefix__c, XC_ContactMobile__c, MobilePhone, XC_ContactPhone__c, XC_PhonePrefix__c, Phone, Birthdate, XC_Preferredlanguageofcontact__c,  XC_HourToBeRecontacted__c, XC_Nationality__c, XC_External_ID__c, XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c,XC_DoNotDisturb__c, XC_ContactDocumentNumber__c, XC_Birth_Place__c, XC_Birth_Country__c, XC_Birth_Province__c, XC_Citizenship__c, XC_Sex__c, XC_ContactDocumentCountry__c FROM Contacts), (SELECT Id, Name, XC_Category__c, XC_Address__c, XC_PostalCode__c, XC_AddressProvince__c, XC_City__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_Stair__c, XC_InstallationAddress__c, XC_BillingAddress__c, XC_DeliveryAddress__c, XC_Municipality__c,  XC_AddressCountry__c,XC_StreetTypeText__c, XC_Note__c, XC_AddressValidated__c, XC_ClarificatorType__c, XC_ClarificatorValue__c, XC_Region__c FROM Addresses__r WHERE CreatedById !=: excludeUserId), (SELECT Id, Name, XC_Type__c, XC_Address__c  FROM Points_of_Service__r), (SELECT Id, Name, NE__Billing_Media__c, NE__Payment__c, CurrencyIsoCode, NE__Description__c, B2WZC__Zuora_MethodPaymentId__c, NE__Account__c, XC_InvoicePreferredLanguage__c, XC_InvoiceDeliveryPref__c , XC_Province__c, XC_City__c, XC_ZipCode__c, NE__Mail_To__c, XC_User_Number__c, NE__Card_Type__c, XC_Token__c , NE__Expiration__c, NE__Expiration_Year__c, NE__Iban__c, XC_CommodityCupsID__c, XC_CommodityContractID__c, NE__Card_Number__c, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_MandateType__c, XC_BIC__c, XC_Status__c, XC_PayPalUsername__c, XC_SAPBusinessPartner__c, XC_StatusReason__c, XC_StatusReasonDetails__c, XC_LastEventDate__c, XC_CommodityUsage__c, XC_ConsumptionNumber__c, XC_OPDocumentNumber__c, XC_OPDocumentType__c  FROM NE__Billing_Profiles__r), (SELECT Id, XC_BillingProfile__c, XC_ExternalKey__c, XC_RecipientCode__c, XC_PEC__c, XC_BillToAddressText__c, XC_SoldToAddressText__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_LegalEntity__c FROM XC_BillingProfileLineItems__r), XC_Community_Typology__c, XC_Community_Code__c, XC_GSE_Code__c, XC_Community_Members_Number__c, XC_Community_GSE_Approval_Date__c, XC_Energy_Community_Foundation_date__c, XC_Member_Typology__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c, XC_Refund_Method__c, XC_CustomerNumber_EnelEnergia__c, XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Annual_membership_fee_due_date__c, XC_Fix_part_sharing_monthly__c, XC_Energy_Community__c  FROM Account WHERE '; /*20220402 NicoloFodera NR1954  Add XC_GIRO__c field in read Account*/
		//Added Fields, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche
        if(String.isNotBlank(accountId)) {
                query += 'Id =: accountId';
                whereCondition = true;
        }
        if (String.isNotBlank(email) && whereCondition) {
                query += ' AND PrimaryEmail__c =: email';
        } else if (String.isNotBlank(email) && !whereCondition) {
                query += 'PrimaryEmail__c =: email';
                whereCondition = true;
        }

        if (String.isNotBlank(uniqueID) && whereCondition) {
                query += ' AND XC_UniqueId__c =: uniqueID';
        } else if (String.isNotBlank(uniqueID) && !whereCondition) {
                query += 'XC_UniqueId__c =: uniqueID';
        }
        //Add @author : Riccardo Cossu for PMD check
        query = String.escapeSingleQuotes(query);
        
        return((List<Account>) Database.query(query));
    }



        /**
         * **************************************************************************************.
         * @param oppList the opp list
         * @return the map
         * @description Method to  create a map with AccountId as key and Order as value
         * **************************************************************************************
         */
        public static Map<Id, List<NE__Order__c>> createMapAccIdOrder (List<NE__Order__c> ordList){

                Map<Id, List<NE__Order__c>> mapAccIdOrder = new Map<Id, List<NE__Order__c>>();
                for(NE__Order__c ord: ordList){
                        if(mapAccIdOrder.containsKey(ord.NE__AccountId__c)){
                                mapAccIdOrder.get(ord.NE__AccountId__c).add(ord);
                        }else{
                                List<NE__Order__c> orderList = new List<NE__Order__c>();
                                orderList.add(ord);
                                mapAccIdOrder.put(ord.NE__AccountId__c, orderList);
                        }
                }

                return mapAccIdOrder;
        }


    /**
    * *******************************************************************************************
    * @param accList the account list
    * @return the map
    * @description Method to  create a map with Individual as key and LegalEntityConsents as value
    * *********************************************************************************************
    */
    public static Map<Id,Map<Individual, List<XC_LegalEntityConsent__c>>> createMapIndividualLegal(List<Account> accList){
        
        /*GDB - 22/03/2022 - INC000083394390 
		This method has been reworked to support the GET Account on Accounts with a number of Contacts greater than 200. 
		There is a query in a for loop made on batchs of 150 Individual Ids in order to overcome the limits of the platform.
		This development affects only a very limited number of accounts. in 99.9% of cases only one query will be made.*/
        
        System.debug('XC_REST_Account_U.createMapIndividualLegal START');
        List<Individual> individualList = new List<Individual>();
        List<Contact> conList = new List<Contact>();
        
        if(!accList.isEmpty()){
            for(Account acc : accList){     
                for(Contact cont : acc.Contacts){
                    conList.add(cont);
                }
            }
        }
        
		if(!conList.isEmpty()){
            
            System.debug('XC_REST_Account_U.createMapIndividualLegal - Contact Size: ' + conList.size() + ' - Contact List: ' + conList);
            Integer i = 0;	//Contact iterator
            Decimal k = 150;	//Max number of Individuals for each query            
            for(Integer j = 1; j <= (conList.size()/k).round(System.RoundingMode.CEILING).intValue(); j++){	//Iteration on every batch for a maximum of 150 Contacts
                
                System.debug('XC_REST_Account_U.createMapIndividualLegal - j iterator: ' + j);
                List<Id> individualIdListTemp = new List<Id>();
                for(i = i ; i < (j*k-1) ; i++){
                	individualIdListTemp.add(conList[i].individualId);
                    if(i == (conList.size()-1)){
                        break;
                    }
                }
                
                Map<Id,Individual> mapIndividualTemp = new Map<Id,Individual>([	//A query every 150 Individual Ids
                    SELECT Id, XC_GiveDataToThirdParties__c,   
                    (SELECT 
                     XC_UpdateAboutProducts__c, 
                     XC_LegalEntity__c, 
                     XC_GiveDataToNew__c, 
                     XC_ConsentToDataProcessing__c, 
                     XC_MarketingConsent__c, 
                     XC_ProfilingConsent__c, 
                     XC_LeCountry__c, 
                     XC_CompanyConsentVersion__c, 
                     //ConsentCompanyDate,
                     XC_MarketingConsentVersion__c, 
                     XC_CollectionDateMarketing__c, 
                     XC_ProfilingConsentVersion__c, 
                     //PreferredContactMethod,
                     XC_CollectionDateProfiling__c,
                     XC_NotCustomerConsent__c,
                     XC_ThirdProductsMarketingConsent__c,
                     XC_NotCustomerConsentVersion__c,
                     XC_CollectionDateNotCustomer__c,
                     XC_ThirdProductsMarketingConsentVersion__c,
                     XC_CollectionDateThirdProductsMarketing__c                                                                             
                     FROM Legal_Entity_Consents__r) 
                    FROM Individual WHERE Id IN: individualIdListTemp]);
                
                System.debug('XC_REST_Account_U.createMapIndividualLegal - mapIndividualTemp: ' + mapIndividualTemp);
                individualList.addall(mapIndividualTemp.values());	//Put all the records in a single list
            }
        }
        
        Map<Id,Map<Individual, List<XC_LegalEntityConsent__c>>> mapIndividualLegal = new  Map<Id,Map<Individual, List<XC_LegalEntityConsent__c>>>();
              
        for(Individual ind: individualList){
            Map<Individual, List<XC_LegalEntityConsent__c>> indLegalMap = new Map<Individual, List<XC_LegalEntityConsent__c>>();
            indLegalMap.put(ind, ind.Legal_Entity_Consents__r);
            mapIndividualLegal.put(ind.Id, indLegalMap);
        }
        
        System.debug('XC_REST_Account_U.createMapIndividualLegal END');
        return mapIndividualLegal;
    }
    

    /**
    * **********************************************************************************************************.
    * @param mapUtilResponse - Map<String, Object>
    * @description Method to create a WrapperResponse to send the response of the GET REST callout
    * **********************************************************************************************************
    */
    public static void createResponseGET(Map<String, Object> mapUtilResponse){
        
        /*GDB - 22/03/2022 - INC000083394390 
		This method has been reworked to support the GET Account on Accounts with a number of Contacts greater than 200.*/
        
        System.debug('XC_REST_Account_U.createResponseGET START');
        List<Account> accList = (List<Account>) mapUtilResponse.get('listAcc');
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) mapUtilResponse.get('wrResp');
        Map<Id, List<NE__Order__c>> mapAccIdOrder = (Map<Id, List<NE__Order__c>>) mapUtilResponse.get('mapAccIdOrder');
        Map<Id,Map<Individual, List<XC_LegalEntityConsent__c>>> mapIndLegal = (Map<Id,Map<Individual, List<XC_LegalEntityConsent__c>>>) mapUtilResponse.get('mapIndLegal');
        Map<Id,String> mapAccIdCS = (Map<Id,String>) mapUtilResponse.get('mapAccIdCS');
        String clientSystem = (String)mapUtilResponse.get('clientSystem');
        Map<Id, XC_PersonalDocument__c> mapidConPd = new Map<Id, XC_PersonalDocument__c>();
        wrResp.Account = new List<XC_UTIL_Account.AccountIFWrapper>();
        
        List<Id> allAccountIds = new List<Id>();
        for(Account acc : accList) {
            allAccountIds.add(acc.Id);
        }
        
        System.debug('XC_REST_Account_U.createResponseGET clientSystem: ' + clientSystem);
        if(clientSystem == 'XInstaller'){
            
            Map<Id, Contact> mapidCon = new Map<Id, Contact>([
                SELECT Id, 
                (SELECT Id, 
                 XC_DocumentType__c, 
                 XC_DocumentNumber__c 
                 FROM Personal_Documents__r)
                FROM Contact 
                WHERE AccountId IN: allAccountIds]);
            
            System.debug('XC_REST_Account_U.createResponseGET mapidCon: ' + mapidCon);
            for(Contact con : mapidCon.values()){
                for(XC_PersonalDocument__c pd : con.Personal_Documents__r){
                    if(pd.XC_DocumentType__c == 'CF'){
                        mapidConPd.put(con.Id, pd);
                        break;
                    }
                }
            }          
        }
        
        Map<Id, XC_Customer_Interaction__c> mapCI =  new Map<Id, XC_Customer_Interaction__c>([
            SELECT Id, 
            XC_ContactId__c, 
            XC_ContactId__r.AccountId, 
            XC_Channel__c, 
            CreatedDate  
            FROM XC_Customer_Interaction__c 
            WHERE XC_ContactId__r.AccountId IN: allAccountIds]); 
        
        List<XC_Customer_Interaction__c> customerInteractionList = mapCI.values();
        System.debug('XC_REST_Account_U.createResponseGET customerInteractionList: ' + customerInteractionList);
        
        Map<Id, List<XC_Customer_Interaction__c>> mapAccIdCustInterList = new Map<Id, List<XC_Customer_Interaction__c>>();
        for(XC_Customer_Interaction__c cInter : customerInteractionList) {
            
            if(mapAccIdCustInterList.containsKey(cInter.XC_ContactId__r.AccountId)) {
                mapAccIdCustInterList.get(cInter.XC_ContactId__r.AccountId).add(cInter);
                
            } else{
                List<XC_Customer_Interaction__c> cInterList = new List<XC_Customer_Interaction__c>();
                cInterList.add(cInter);
                mapAccIdCustInterList.put(cInter.XC_ContactId__r.AccountId, cInterList);
            }
        }
        
        if(mapAccIdOrder != null && !mapAccIdOrder.isEmpty()){            
            System.debug('XC_REST_Account_U.createResponseGET mapAccIdOrder not Empty');
            XC_UTIL_Account.AccountIFWrapper accWR;
            Map<Id, Account> mapUtil = createMapAccIdAcc(accList);
            for(String accId : mapAccIdOrder.keySet()){
                
                Integer j = 0;
                for(Integer i=0; i < mapAccIdOrder.get(accId).size(); i++){ 
                    
                    accWR = new XC_UTIL_Account.AccountIFWrapper();
                    Account acc = mapUtil.get(accId);
                    Map<String, Object> mapUtilAccRes = new Map<String, Object>{    
                        'acc' => acc,
                        'accWR' => accWR,
                        'mapIndLegal' => mapIndLegal,
                        'mapAccIdOrder' => mapAccIdOrder,
                        'mapAccIdCS' => mapAccIdCS,
                        'clientSystem' => clientSystem,
                        'i' => j
                        };

                    manageObjectsCreateResponseGET(mapUtilAccRes, mapAccIdCustInterList, mapidConPd);
                    wrResp.Account.add((XC_UTIL_Account.AccountIFWrapper)mapUtilAccRes.get('accWR'));
                    j++;
                }
            } 
            
        } else{
            System.debug('XC_REST_Account_U.createResponseGET mapAccIdOrder Empty');
            for(Account acc : accList) {
                XC_UTIL_Account.AccountIFWrapper accWR = new XC_UTIL_Account.AccountIFWrapper();
                Map<String, Object> mapUtilAccRes = new Map<String, Object>{  
                    'acc' => acc,
                    'accWR' => accWR,
                    'mapIndLegal' => mapIndLegal,
                    'mapAccIdOrder' => mapAccIdOrder,
                    'mapAccIdCS' => mapAccIdCS,
                    'clientSystem' => clientSystem
                    };
                            
                manageObjectsCreateResponseGET(mapUtilAccRes, mapAccIdCustInterList, mapidConPd);
                wrResp.Account.add((XC_UTIL_Account.AccountIFWrapper)mapUtilAccRes.get('accWR'));
            }           
        }
        System.debug('XC_REST_Account_U.createResponseGET END');
    }
    
    /**
    * ********************************************************************************
    * @param Map<String, Object> mapUtilAccRes, Map<Id, List<XC_Customer_Interaction__c>> mapAccIdCustInterList, Map<Id, XC_PersonalDocument__c> mapidConPd
    * @description Method used to manage the creation of the different wrapper of the response
    * ********************************************************************************
    */
    public static void manageObjectsCreateResponseGET (Map<String, Object> mapUtilAccRes, Map<Id, List<XC_Customer_Interaction__c>> mapAccIdCustInterList, Map<Id, XC_PersonalDocument__c> mapidConPd){
        
        System.debug('XC_REST_Account_U.manageObjectsCreateResponseGET START');
        
        //Manage Account
        createAccountResponseGET(mapUtilAccRes);
        
 		List<XC_PersonalDocument__c> documentList = new list <	XC_PersonalDocument__c>();        
        List<Contact> contactList = new list <Contact>();
        List<XC_Address__c> addressList = new List<XC_Address__c>();
        List<NE__Billing_Profile__c> bpList = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>();
        List<XC_PointOfService__c> posList = new List<XC_PointOfService__c>();
        List<XC_Customer_Interaction__c> custIntList = new List<XC_Customer_Interaction__c>();
        
        Account acc = (Account)mapUtilAccRes.get('acc');
        for(XC_PersonalDocument__c ps : acc.Personal_Documents__r){documentList.add(ps);}
        for(Contact c : acc.Contacts){contactList.add(c);}
        for(XC_Address__c a : acc.Addresses__r){addressList.add(a);}
        for(NE__Billing_Profile__c bp : acc.NE__Billing_Profiles__r){bpList.add(bp);}
        for(XC_BillingProfileLineItem__c bpli : acc.XC_BillingProfileLineItems__r){bpliList.add(bpli);}
        for(XC_PointOfService__c pos : acc.Points_of_Service__r){posList.add(pos);}
        if(mapAccIdCustInterList.get(acc.Id) != null){
            for(XC_Customer_Interaction__c ci : mapAccIdCustInterList.get(acc.Id)){
                custIntList.add(ci);
            }
        }
        
        //Manage Personal Document
        createIdentityResponseGET(documentList, (XC_UTIL_Account.AccountIFWrapper) mapUtilAccRes.get('accWR'), (String) mapUtilAccRes.get('clientSystem'));
        
        //Manage Contact
        if (contactList.size() > 0){
            mapUtilAccRes.put('conList', contactList);
            mapUtilAccRes.put('mapidConPd', mapidConPd);                  
            createContactResponseGET( mapUtilAccRes);
        }
        
        //Manage Customer Interaction
        if (custIntList.size() > 0) {
            createInteractionResponseGET(custIntList, (XC_UTIL_Account.AccountIFWrapper) mapUtilAccRes.get('accWR'));
        }
        
        //Manage Address
        if (addressList.size() > 0) {
            createAddressResponseGET(addressList, posList, (XC_UTIL_Account.AccountIFWrapper) mapUtilAccRes.get('accWR'), (String) mapUtilAccRes.get('clientSystem'));
        }
        
        //Manage Billing Profile and Billing Profile Line Item
        if (bpList.size() > 0) {
            createBillingProfileResponseGET(bpList, (XC_UTIL_Account.AccountIFWrapper) mapUtilAccRes.get('accWR'), bpliList, (String) mapUtilAccRes.get('clientSystem'));
        }
        System.debug('XC_REST_Account_U.manageObjectsCreateResponseGET END');
    }
        
        
    /**
    * ********************************************************************************
    * @param accList - List<Account>
    * @description Method to create a Map with AccountID as Key and Account as value
    * ********************************************************************************
    */
    public static Map<Id, Account> createMapAccIdAcc (List<Account> accList){
    
            Map<Id, Account> mapAccIdAcc = new  Map<Id, Account>();
            for(Account acc: accList){
                    mapAccIdAcc.put(acc.Id, acc);
            }
    
            return mapAccIdAcc;
    }


        /**
         * *******************************************************************************************************************************************.
         * @param mapUtilAccRes - Map<String, Object>
         * @description Method to populate the Account Wrapper of the WrapperResponse for the GET REST Callout
         * ********************************************************************************************************************************************
         */
        public static void createAccountResponseGET(Map<String, Object> mapUtilAccRes){
                

                Account acc = (Account) mapUtilAccRes.get('acc');
                XC_UTIL_Account.AccountIFWrapper accWR = (XC_UTIL_Account.AccountIFWrapper) mapUtilAccRes.get('accWR');
                Map<Id, List<NE__Order__c>> mapAccIdOrder = (Map<Id, List<NE__Order__c>>) mapUtilAccRes.get('mapAccIdOrder');
                Map<Id,String> mapAccIdCS = (Map<Id,String>) mapUtilAccRes.get('mapAccIdCS');
                Integer i = (Integer) mapUtilAccRes.get('i');
                system.debug('I'+ i);

                accWr.UniqueID = acc.XC_UniqueId__c;
                accWR.AccountID = acc.Id;
                accWR.AccountType = acc.XC_AccountType__c;
                accWR.LastName = acc.XC_LastName__c ;
                accWR.FirstName = acc.XC_FirstName__c;
                accWR.MainPhonePrefix = acc.XC_AccountPhonePrefix__c;
                accWR.MainPhone = acc.XC_AccountPhone__c;
                accWR.PrimaryEmail = acc.PrimaryEmail__c;
                accWR.PhonePrefix = acc.XC_MainPhonePrefix__c; 
                accWR.Phone = acc.XC_AccountMainPhone__c;
                accWR.Country = acc.Country__c;
                accWR.BirthDate = acc.XC_Birthdate__c;
                accWR.PreferenceLanguage = acc.XC_Preference_Language__c;
                accWR.Notes = acc.XC_Notes__c;
                accWR.Status = acc.XC_Status__c;
                accWR.CertifiedEmail = acc.XC_CertifiedEmail__c;
                accWR.Nationality = acc.XC_AccountNationality__c;
                //Destination Code
                // RegisteredOnRechargeApp
                //Segmentation
                accWR.PartnerID = acc.XC_PreferredPartner__c;
                //accWR.CommodityScoring = acc.XC_Score__c;
                accWR.DataLakeScoring = acc.XC_DataLakeScore__c;
                accWR.BlackList = acc.XC_Blacklist_result__c;     
                //accWR.ParentAccountID   = acc.ParentId;
                accWR.SplitPayment = acc.XC_SplitPayment__c;
                accWR.SohoType = acc.XC_SohoType__c;
                accWR.IsGuest = acc.XC_isGuestUser__c; 
                accWR.RecordTypeName = acc.RecordType.DeveloperName;
                accWR.GIRO = acc.XC_GIRO__c; /*20220402 NicoloFodera NR1954  Add XC_GIRO__c field in read Account*/
				//[ BEGIN, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche]
                accWR.Energy_Community = acc.XC_Energy_Community__c;
                accWR.Community_Tipology= acc.XC_Community_Typology__c;
                accWR.Community_Code=acc.XC_Community_Code__c;
                accWR.GSE_Code=acc.XC_GSE_Code__c;
                accWR.Community_Members_Number=acc.XC_Community_Members_Number__c;
                accWR.Community_GSE_Approval_Date=acc.XC_Community_GSE_Approval_Date__c;
                accWR.Energy_Community_Foundation_date= acc.XC_Energy_Community_Foundation_date__c;
                accWR.ChildAccount = new List<XC_UTIL_Account.AccountChildIFWrapper>();
				List<Account> accountchildlist = new List<Account>();
				accountchildlist = [select id, XC_Member_Typology__c,XC_Fix_part_sharing_monthly__c,XC_Annual_membership_fee_due_date__c,XC_Annual_member_fee__c,XC_Una_tantum_member_fee__c,XC_CustomerNumber_EnelEnergia__c, ParentId,XC_MISE_incentive__c, XC_Arera_incentive__c,XC_Local_price_incentive__c, XC_Refund_Method__c  from account where parentId =:   accWR.AccountID];
                if(!accountchildlist.isEmpty()){
                    for (Account childacc : accountchildlist){
                        XC_UTIL_Account.AccountChildIFWrapper accChildWr = new XC_UTIL_Account.AccountChildIFWrapper();
                        accChildWr.AccountID = childacc.id;
                        accChildWr.MemberTypology = childacc.XC_Member_Typology__c;
                        accChildWr.ParentId = childacc.ParentId;
                        accChildWr.MISE_incentive = childacc.XC_MISE_incentive__c ;
                        accChildWr.Arera_incentive = childacc.XC_Arera_incentive__c ;
                        accChildWr.Local_price_incentive = childacc.XC_Local_price_incentive__c ;
                        accChildWr.Refund_Method = childacc.XC_Refund_Method__c;
                        accChildWr.CustomerNumberEnelEnergia = childacc.XC_CustomerNumber_EnelEnergia__c;
                        accChildWr.Una_tantum_member_fee = childacc.XC_Una_tantum_member_fee__c;
                        accChildWr.Annual_member_fee = childacc.XC_Annual_member_fee__c;
                        accChildWr.Annual_membership_fee_due_date = String.valueOf(childacc.XC_Annual_membership_fee_due_date__c);
                        accChildWr.Fix_part_sharing_monthly = childacc.XC_Fix_part_sharing_monthly__c;
                        accWR.ChildAccount.add(accChildWr);
                    }
                }
                //[ END, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche]
                
                if(mapAccIdOrder != null && !mapAccIdOrder.isEmpty() && i != null){
                        accWR.MobilityOrderID = mapAccIdOrder.get(acc.Id).get(i).Id;                
                        accWR.CostCenter = mapAccIdOrder.get(acc.Id).get(i).XC_Cost_Center__c;
                }

                if(acc.XC_RecordTypePick__c == 'Soho' || acc.XC_RecordTypePick__c == 'Condominium'){
                        accWR.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                        XC_UTIL_Account.IdentityIFWrapper idWr = new XC_UTIL_Account.IdentityIFWrapper();
                        idWr.IdentityID = acc.Id;
                        idWr.Country = acc.XC_DocumentCountry__c;
                        idWr.IdentityType = acc.IdentityType__c;
                        idWr.IdentityNumber = acc.IdentityNumber__c;
                        idWr.ReleaseDate = (acc.XC_NIE_expedition_date__c != null) ? String.valueOf(acc.XC_NIE_expedition_date__c) + 'T00:00:00' : null;
                        idWr.ExpiryDate = (acc.XC_NIE_expiration_date__c != null) ? String.valueOf(acc.XC_NIE_expiration_date__c) + 'T00:00:00' : null;
                        accWR.Identity.add(idWr);
                }
        }

        
        /**
         * *************************************************************************************************************.
         * @param identityList the identity list
         * @param accWR the acc WR
         * @description Method to populate the Identity Wrapper List of the WrapperResponse for the GET REST Callout
         * *************************************************************************************************************
        */
        public static void createIdentityResponseGET(List<XC_PersonalDocument__c> identityList, XC_UTIL_Account.AccountIFWrapper accWR, String clientSystem) {
                if(accWR.Identity == null) {
                        accWR.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                }
                if(identityList == null) {
                        identityList = new List<XC_PersonalDocument__c>();
                }

                if(accWr.AccountType != 'Residential' && clientSystem.equalsIgnoreCase('XInstaller')) {
                        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, XC_Country__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_ExpirationDate__c, XC_Issued_By__c, XC_Issued_On__c, XC_Issue_Place__c, XC_Issue_Province__c, XC_Issue_Country__c FROM Personal_Documents__r)
                                                                                FROM Contact
                                                                                WHERE AccountId =: accWR.AccountID AND XC_PrimaryContact__c = true]);
                        identityList.addAll(contactMap.values()[0].Personal_Documents__r);
                }

                XC_UTIL_Account.IdentityIFWrapper idWr;
                for (XC_PersonalDocument__c identity : identityList){
                        idWr = new XC_UTIL_Account.IdentityIFWrapper();
                        idWr.IdentityID = identity.Id;
                        idWr.Country = identity.XC_Country__c;
                        idWr.IdentityType = identity.XC_DocumentType__c;
                        idWr.IdentityNumber = identity.XC_DocumentNumber__c;
                        idWr.ReleaseDate = (identity.XC_ReleaseDate__c != null) ? String.valueOf(identity.XC_ReleaseDate__c) + 'T00:00:00' : null;
                        idWr.ExpiryDate = (identity.XC_ExpirationDate__c != null) ? String.valueOf(identity.XC_ExpirationDate__c) + 'T00:00:00' : null;
                        idWr.IssuedBy = identity.XC_Issued_By__c;
                        idWr.IssuedOn = (identity.XC_Issued_On__c != null) ? String.valueOf(identity.XC_Issued_On__c) + 'T00:00:00' : null;
                        idWr.IssuePlace = identity.XC_Issue_Place__c;
                        idWr.IssueProvince = identity.XC_Issue_Province__c;
                        idWr.IssueCountry = identity.XC_Issue_Country__c;
                        
                        accWR.Identity.add(idWr);
                }
        }


        /**
         * *********************************************************************************************************.
         * @param conList the con list
         * @param accWR the acc WR
         * @description Method to populate the Contact Wrapper List of the WrapperResponse for the GET REST Callout
         * **********************************************************************************************************
         */
        public static void createContactResponseGET(Map<String,Object> mapUtilAccRes) {
                
                XC_UTIL_Account.AccountIFWrapper accWR = (XC_UTIL_Account.AccountIFWrapper) mapUtilAccRes.get('accWR');
                List<Contact>  conList = (List<Contact>) mapUtilAccRes.get('conList');
                Map<Id, Map<Individual, List<XC_LegalEntityConsent__c>>> mapIndLegal = (Map<Id, Map<Individual, List<XC_LegalEntityConsent__c>>>) mapUtilAccRes.get('mapIndLegal');
                String clientSystem = (String) mapUtilAccRes.get('clientSystem');
                 Map<Id, XC_PersonalDocument__c>  mapidConPd = ( Map<Id, XC_PersonalDocument__c>) mapUtilAccRes.get('mapidConPd');

                accWR.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
                XC_UTIL_Account.ContactIFWrapper conWr; 
                
                for (Contact con :conList){
                        conWr = new XC_UTIL_Account.ContactIFWrapper();
                        conWr.ContactID = con.Id;
                        conWr.LastName = con.LastName;
                        conWr.FirstName = con.FirstName;
                        conWr.Salutation = con.Salutation;
                        conWr.PrimaryContact = con.XC_PrimaryContact__c;
                        conWr.Email = con.Email;
                        conWr.MainPhonePrefix = con.XC_PhonePrefix__c;
                        conWr.MainPhone = con.XC_ContactPhone__c;
                        conWr.PhonePrefix = con.XC_MobilePrefix__c;
                        conWr.Phone = con.XC_ContactMobile__c;
                        conWr.BirthDate = con.BirthDate;
                        conWr.PreferenceLanguage = con.XC_Preferredlanguageofcontact__c;
                        conWr.ContactPreferredTime = con.XC_HourToBeRecontacted__c;
                        conWr.Nationality = con.XC_Nationality__c;
                        conWr.ExternalLoginId = con.XC_External_ID__c;
                        conWr.GDPR = new XC_UTIL_Account.gdprWrapper();
                        if(mapIndLegal.containsKey(con.IndividualId)){
                                conWr.GDPR.LegalEntity = new List<XC_UTIL_Account.LegalEntityWrapper>();
                                for(Individual ind : (mapIndLegal.get(con.IndividualId)).keySet()){
                                        conWr.GDPR.GiveDataToThirdParties = XC_UTIL_Integration_U.convertFromPicklistToString(ind.XC_GiveDataToThirdParties__c);
                                        conWr.GDPR.VersionConsentThirdParty = XC_UTIL_Integration_U.convertFromPicklistToString(con.XC_ThirdPartiesConsentVersion__c);
                                        //conWr.GDPR.ConsentThirdPartyDate = XC_UTIL_Integration_U.convertFromPicklistToString(con.ConsentThirdPartyDate);
                                        conWr.GDPR.RobinsonCustomer = con.XC_RobinsonCustomer__c ? 'Y' : 'N'; 
                                        conWr.GDPR.DoNotDisturb = con.XC_DoNotDisturb__c ? 'Y' : 'N';
                                }
                                /*if(String.isBlank(conWr.GDPR.GiveDataToThirdParties)) {
                                        conWr.GDPR.GiveDataToThirdParties = 'N';
                                }*/
                                List<XC_LegalEntityConsent__c> legalList = (mapIndLegal.get(con.IndividualId)).values()[0];
                                for(XC_LegalEntityConsent__c legalEntity : legalList){
                                        XC_UTIL_Account.LegalEntityWrapper legalWr = new XC_UTIL_Account.LegalEntityWrapper();
                                        legalWr.LegalEntity = legalEntity.XC_LegalEntity__c;
                                        legalWr.GiveDataToLegalEntity = XC_UTIL_Integration_U.convertFromPicklistToString(legalEntity.XC_GiveDataToNew__c);
                                        legalWr.GiveDataForMarketing = XC_UTIL_Integration_U.convertFromPicklistToString(legalEntity.XC_MarketingConsent__c);
                                        legalWr.GiveDataForProfiling = XC_UTIL_Integration_U.convertFromPicklistToString(legalEntity.XC_ProfilingConsent__c);            

                                        legalWr.Country = legalEntity.XC_LeCountry__c;
                                        legalWr.VersionConsentCompany = legalEntity.XC_CompanyConsentVersion__c;
                                        //legalWr.ConsentCompanyDate = 
                                        legalWr.VersionConsentMarketing = legalEntity.XC_MarketingConsentVersion__c;
                                        legalWr.ConsentMarketingDate = legalEntity.XC_CollectionDateMarketing__c;
                                        legalWr.VersionConsentForProfiling = legalEntity.XC_ProfilingConsentVersion__c;
                                        legalWr.ConsentProfilingDate = legalEntity.XC_CollectionDateProfiling__c; 
                                        //legalWr.PreferredContactMethod = 
                                         
                                         //API 2.22
                                         legalWr.GiveDataForNotCustomer = XC_UTIL_Integration_U.convertFromPicklistToString(legalEntity.XC_NotCustomerConsent__c);
                                         legalWr.GiveDataForThirdProductMarketing = XC_UTIL_Integration_U.convertFromPicklistToString(legalEntity.XC_ThirdProductsMarketingConsent__c);
                                         legalWr.VersionConsentNotCustomer = legalEntity.XC_NotCustomerConsentVersion__c;
                                         legalWr.ConsentNotCustomerDate = legalEntity.XC_CollectionDateNotCustomer__c;
                                         legalWr.VersionConsentThirdProductMarketing = legalEntity.XC_ThirdProductsMarketingConsentVersion__c;
                                         legalWr.ConsentThirdProductMarketingDate = legalEntity.XC_CollectionDateThirdProductsMarketing__c;

                                        conWr.GDPR.LegalEntity.add(legalWr);
                                }
                        } 
                        conWr.ShippingContact = null;
                        conWr.BillingContact = null;

                        conWr.ContactDocumentNumber = (mapidConPd.containsKey(con.Id)) ? mapidConPd.get(con.Id).XC_DocumentNumber__c : null;
                        conWr.BirthPlace = con.XC_Birth_Place__c;
                        conWr.BirthCountry = con.XC_Birth_Country__c;
                        conWr.BirthProvince = con.XC_Birth_Province__c;
                        conWr.Citizenship = con.XC_Citizenship__c;
                        conWr.Sex = con.XC_Sex__c;
                        conWr.Country = con.XC_ContactDocumentCountry__c;

                        
                        accWR.Contact.add(conWr);
                }
        }


        /**
         * *************************************************************************************************************.
         * @param customerInteractionList the customer interaction list
         * @param accWR the acc WR
         * @description Method to populate the Interaction Wrapper List of the WrapperResponse for the GET REST Callout
         * **************************************************************************************************************
         */
        public static void createInteractionResponseGET(List<XC_Customer_Interaction__c> customerInteractionList, XC_UTIL_Account.AccountIFWrapper accWR) {
                
                /*accWR.Interaction = new List<XC_UTIL_Account.InteractionWrapper>();

                for(XC_Customer_Interaction__c customInter : customerInteractionList){
                        XC_UTIL_Account.InteractionWrapper interWr = new XC_UTIL_Account.InteractionWrapper();
                        interWr.ContactID = customInter.XC_ContactId__c;
                        interWr.Channel = customInter.XC_Channel__c;
                        interWr.CallDate = Date.valueOf(customInter.CreatedDate);// check created date
                        accWR.Interaction.add(interWr); 
                }*/
        }


        /**
         * *********************************************************************************************************.
         * @param addressList the address list
         * @param accWR the acc WR
         * @description Method to populate the Address Wrapper List of the WrapperResponse for the GET REST Callout
         * **********************************************************************************************************
         */
        public static void createAddressResponseGET(List<XC_Address__c> addressList, List<XC_PointOfService__c> posList, XC_UTIL_Account.AccountIFWrapper accWR, String clientSystem){
               accWR.Address = new List<XC_UTIL_Address.AddressWrapper>();

               for (XC_Address__c addr : addressList){
                        XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
                        addressWr.AddressID = addr.Id;
                        addressWr.StreetType = addr.XC_StreetTypeText__c;
                        addressWr.Address = addr.XC_Address__c;
                        addressWr.StreetNumber = addr.XC_StreetNumber__c;
                        addressWr.ZipCode = addr.XC_PostalCode__c;
                        addressWr.City = addr.XC_City__c;
                        addressWr.Country = addr.XC_AddressCountry__c;
                        addressWr.Category = addr.XC_Category__c;
                        addressWr.Stair = addr.XC_Stair__c;
                        addressWR.Floor = addr.XC_Floor__c;
                        addressWr.Door = addr.XC_Door__c;
                        addressWr.Province = addr.XC_AddressProvince__c;
                        addressWr.DeliveryAddress = addr.XC_DeliveryAddress__c;
                        addressWr.InstallationAddress = addr.XC_InstallationAddress__c;
                        addressWr.BillingAddress = addr.XC_BillingAddress__c;
                        //addressWr.Note = addr.XC_Note__c;
                        addressWr.Municipality = addr.XC_Municipality__c;
                        addressWr.ClarifierType = addr.XC_ClarificatorType__c;
                        addressWr.ClarifierValue = addr.XC_ClarificatorValue__c;
                        addressWr.isPartner = null;
                        addressWr.PickupPoint = null;
                        addressWr.Warehouse = null;
                        addressWr.PointOfSales = null;
                        addressWr.AddressValidated = addr.XC_AddressValidated__c;
                        addressWr.Region = addr.XC_Region__c;
                        
                        if(!posList.isEmpty()){
                                addressWr.PointOfService = new List<XC_UTIL_Address.PoSWrapper>();
                                for(XC_PointOfService__c  pos: posList) {
                                        if(pos.XC_Address__c == addr.Id){
                                                XC_UTIL_Address.PosWrapper posWR = new XC_UTIL_Address.PosWrapper();
                                                posWR.POSID =  pos.id;
                                                posWR.POS = pos.Name;
                                                posWR.POSType = pos.XC_Type__c ;
                                                addressWr.PointOfService.add(posWR); 
                                        }
                        
                                }
                        }
                        accWR.Address.add(addressWr);
               }
        }


        /**
         * *****************************************************************************************************************.
         * @param billingProfileList the billing profile list
         * @param accWR the acc WR
         * @description Method to populate the Billing Profile Wrapper List of the WrapperResponse for the GET REST Callout
         * ******************************************************************************************************************
         */
public static void createBillingProfileResponseGET(List<NE__Billing_Profile__c> billingProfileList, XC_UTIL_Account.AccountIFWrapper accWR, List<XC_BillingProfileLineItem__c> bpliList, String clientSystem){

        accWR.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();

                Map<String,List<XC_BillingProfileLineItem__c>> mapBpIdBpli = new Map<String,List<XC_BillingProfileLineItem__c>>();
                for(XC_BillingProfileLineItem__c bpli : bpliList){
                        if(!mapBpIdBpli.containsKey(bpli.XC_BillingProfile__c)){
                                List<XC_BillingProfileLineItem__c> bpliToAddList = new List<XC_BillingProfileLineItem__c>();
                                bpliToAddList.add(bpli);
                                mapBpIdBpli.put(bpli.XC_BillingProfile__c, bpliToAddList);
                        }else{
                                mapBpIdBpli.get(bpli.XC_BillingProfile__c).add(bpli);
                        }
                        
                }

                for(NE__Billing_Profile__c billingProfile : billingProfileList){
                         if(billingProfile.XC_Status__c != 'Active' && billingProfile.XC_Status__c != 'Waiting External Activation' && billingProfile.XC_Status__c != 'Sent To Zuora'){
                                continue;
                        }
                        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileWr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
                        billingProfileWr.BillingProfileID = billingProfile.Id;
                        billingProfileWr.BillingProfileName = billingProfile.Name;
                        billingProfileWr.PaymentMethod = (billingProfile.Name.containsIgnoreCase('SEPA')) ? 'SEPA' : billingProfile.NE__Payment__c; //(billingProfile.NE__Payment__c == 'Direct Debt') ? 'SEPA' : billingProfile.NE__Payment__c; 20/09/2019
                        billingProfileWr.InvoicePreferredLanguage = billingProfile.XC_InvoicePreferredLanguage__c;
                        billingProfileWr.InvoiceDeliveryPref = billingProfile.XC_InvoiceDeliveryPref__c;
                        billingProfileWr.IBAN = billingProfile.NE__Iban__c;
                        billingProfileWr.Token = billingProfile.XC_Token__c;
                        billingProfileWr.CreditCardType = billingProfile.NE__Card_Type__c;
                        billingProfileWr.ExpirationMonth = billingProfile.NE__Expiration__c;
                        billingProfileWr.ExpirationYear = billingProfile.NE__Expiration_Year__c;
                        billingProfileWr.CreditCardLastFourNumber = (billingProfile.NE__Card_Number__c != null) ? (billingProfile.NE__Card_Number__c).substring(12) : null;
                        billingProfileWr.UserNumber = billingProfile.XC_User_Number__c;
                        billingProfileWr.Email = billingProfile.NE__Mail_To__c; 
                        // Missing PhoneNumber
                        billingProfileWr.PostalCode = billingProfile.XC_ZipCode__c;
                        billingProfileWr.City = billingProfile.XC_City__c;
                        billingProfileWr.State = billingProfile.XC_Province__c;
                        // Missing Country
                        billingprofileWr.CupsID = billingProfile.XC_CommodityCupsID__c;
                        billingprofileWr.CommodityContractNum = billingProfile.XC_CommodityContractID__c;
                        billingProfileWr.SEPAMandateID = BillingProfile.XC_SepaMandate__c;
                        billingProfileWr.SEPAMandateDate = String.valueOf(BillingProfile.XC_SepaMandateDate__c);
                        billingProfileWr.SEPAMandateType = BillingProfile.XC_MandateType__c;
                        billingProfileWr.SEPABIC = BillingProfile.XC_BIC__c;
                        billingProfileWr.CreditCardExternalKey = mapBpIdBpli.get(billingProfile.Id)[0].XC_ExternalKey__c; // one bp - n bpli 
                        billingProfileWr.CertifiedEmail = mapBpIdBpli.get(billingProfile.Id)[0].XC_PEC__c;
                        billingProfileWr.RecipientCode = mapBpIdBpli.get(billingProfile.Id)[0].XC_RecipientCode__c;
                        billingProfileWr.PayPalUsername = billingProfile.XC_PayPalUsername__c;
                        
                        billingProfileWr.SAPBusinessPartner = billingProfile.XC_SAPBusinessPartner__c;
                        billingProfileWr.Status = billingProfile.XC_Status__c;
                        billingProfileWr.Reason = billingProfile.XC_StatusReason__c;
                        billingProfileWr.ReasonDetails = billingProfile.XC_StatusReasonDetails__c;
                        billingProfileWr.EventDate = billingProfile.XC_LastEventDate__c;
                        billingProfileWr.CommodityUsage = billingProfile.XC_CommodityUsage__c;
                        billingProfileWr.ConsumptionNumber = billingProfile.XC_ConsumptionNumber__c;
                        //billingProfileWr.ProductID = billingProfile.
                        //billingProfileWr.OrderID = billingProfile.
                        billingProfileWr.OPDocumentNumber = billingProfile.XC_OPDocumentNumber__c;
                        billingProfileWr.OPDocumentType = billingProfile.XC_OPDocumentType__c;

                        /*
                        billingProfileWr.LegalEntity = XC_LegalEntity__c;
                        billingProfileWr.BillingAddressID = XC_BillingAddress__c;
                        billingProfileWr.CreditCardHolder = ;
                        billingProfileWr.CreditCardExternalKey = ;
                        billingProfileWr.BillingAddressIndex = ;
                        billingProfileWr.SoldAddressIndex = ;
                        billingProfileWr.ActiveEmobAPPflag = ;
                        */

                List<XC_UTIL_BillingProfile.BillingProfileLineItemIFWrapper> bplisWr = new List<XC_UTIL_BillingProfile.BillingProfileLineItemIFWrapper>();
                for(XC_BillingProfileLineItem__c bpli : mapBpIdBpli.get(billingProfile.Id)) {
                    XC_UTIL_BillingProfile.BillingProfileLineItemIFWrapper bpliWr = new XC_UTIL_BillingProfile.BillingProfileLineItemIFWrapper();
                    bpliWr.BillToAddressText = bpli.XC_BillToAddressText__c;
                    bpliWr.SoldToAddressText = bpli.XC_SoldToAddressText__c;
                    bpliWr.SoldToAddress = bpli.XC_SoldToAddress__c;
                    bpliWr.BillToAddress = bpli.XC_BillToAddress__c;
                    bpliWr.LegalEntity = bpli.XC_LegalEntity__c;
                    bplisWr.add(bpliWr);
                }
                if(clientSystem != null && clientSystem.equals('XInstaller')){
                    billingProfileWr.BillingProfileLineItem = bplisWr;
                } 
                accWR.BillingProfile.add(billingProfileWr);
        }

}


        /**
         * *********************************************************************************************************************************************************************************************************************************************************.
         * @param accountId the account id
         * @param contactWrLIST the contact wr LIST
         * @param addressWrLIST the address wr LIST
         * @param billingProfileWrLIST the billing profile wr LIST
         * @param wrResp the wr resp
         * @param beforeAccSavepoint the before acc savepoint
         * @description Method to create a WrapperResponse to send the response of the POST and PUT REST callout
         * **********************************************************************************************************************************************************************************************************************************************************
         */
        public static void createResponse(String accountId, List<XC_UTIL_Sobject.WrapperResult> contactWrLIST, List<XC_UTIL_Sobject.WrapperResult> addressWrLIST, List<XC_UTIL_Sobject.WrapperResult> billingProfileWrLIST,List<XC_UTIL_Sobject.WrapperResult> identityWrLIST,  List<XC_UTIL_Sobject.WrapperResult> posWrLIST, XC_REST_Account_W.WrapperResponse wrResp, String clientSystem) {
                
                Map<Id,Account> mapAcc = new Map<Id,Account> ([SELECT Id, Name, XC_LastName__c, XC_FirstName__c, 
                        (SELECT Id, LastName, FirstName, Email FROM Contacts),
                        (SELECT Id, ContactId, Contact.LastName, Contact.FirstName, Contact.Email from AccountContactRelations),
                        (SELECT Id, XC_Note__c,XC_StreetTypeText__c, XC_Address__c, XC_PostalCode__c,  XC_City__c, XC_StreetNumber__c,  XC_AddressCountry__c, XC_StreetType__c, XC_AddressValidated__c FROM Addresses__r), 
                        (SELECT Id, XC_Address__c, Name FROM Points_of_Service__r), 
                        (SELECT Id, NE__Payment__c, Name  FROM NE__Billing_Profiles__r),
                        (SELECT Id, XC_Country__c, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r) 
                        FROM Account WHERE Id =: accountId]);
                List<Account> accList = mapAcc.values();

                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
                if(contactWrLIST.size() > 0) {
                        //populateContactResponse(accList[0].Contacts, contactWrLIST, wrResp);
                        List<Contact> conList = accList[0].Contacts;
                        for (AccountContactRelation acr : accList[0].AccountContactRelations) {
                                Contact c = new Contact(Id = acr.ContactId, LastName = acr.Contact.LastName, FirstName = acr.Contact.FirstName, Email = acr.Contact.Email);
                                conList.add(c);
                        }
                        populateContactResponse(conList, contactWrLIST, wrResp);
                }
                if(addressWrLIST.size() > 0) {
                        populateAddressResponse(accList[0].Addresses__r, addressWrLIST, posWrLIST, accList[0].Points_of_Service__r, wrResp, clientSystem);
                }
                if(billingProfileWrLIST.size() > 0) {
                        populateBillingProfileResponse(accList[0].NE__Billing_Profiles__r, billingProfileWrLIST, wrResp);
                }    
                if(identityWrLIST.size() > 0) {
                        populateIdentityResponse(accList[0].Personal_Documents__r, identityWrLIST, wrResp);
                }   
        }


        /**
         * *******************************************************************************************************************************************.
         * @param conList the con list
         * @param contactWrLIST the contact wr LIST
         * @param wrResp the wr resp
         * @param beforeAccSavepoint the before acc savepoint
         * @description Method to populate the Contact Wrapper List of the WrapperResponse for the PUT and POST REST Callout
         * ********************************************************************************************************************************************
         */
        public static void populateContactResponse (List<Contact> conList, List<XC_UTIL_Sobject.WrapperResult> contactWrLIST, XC_REST_Account_W.WrapperResponse wrResp){
                System.debug(LoggingLevel.FINEST, 'conList: ' + conList);
                XC_UTIL_Account.ContactIFWrapper contactWr;

                Map<Id, Contact> mapIdContact = new Map<Id, Contact>();
                for (Contact con : conList){
                        mapIdContact.put(con.id, con);
                }
                System.debug(LoggingLevel.FINEST, 'mapIdContact: ' + mapIdContact);
                for(XC_UTIL_Sobject.WrapperResult wr : contactWrLIST){ 
                        contactWr = new XC_UTIL_Account.ContactIFWrapper();
                        if(wr.success) {
                                contactWr.ContactID = wr.recordId;
                                contactWr.LastName = mapIdContact.get(wr.recordId).LastName;
                                contactWr.FirstName = mapIdContact.get(wr.recordId).FirstName;   
                                contactWr.Email = mapIdContact.get(wr.recordId).Email;
                                contactWr.PrimaryContact = null;
                                contactWr.ShippingContact = null;
                                contactWr.BillingContact = null;
                        } else {   
                                wrResp.Result.Message = 'INTERNAL ERROR: In Contact Section ' + wr.errorMessage;
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.logError = 'INTERNAL ERROR: In Contact Section ' + wr.errorMessage;
                                return;
                        }
                        wrResp.Contact.add(contactWr);
                } 
        }


        /**
         * *******************************************************************************************************************************************************************.
         * @param addrList the addr list
         * @param addrListRes the addr list res
         * @param wrResp the wr resp
         * @param beforeAccSavepoint the before acc savepoint
         * @description Method to populate the Address Wrapper List of the WrapperResponse for the PUT and POST REST Callout
         * ********************************************************************************************************************************************************************
         */
        public static void populateAddressResponse(List<XC_Address__c> addrList, List<XC_UTIL_SObject.WrapperResult> addrListRes,  List<XC_UTIL_Sobject.WrapperResult> posListRes, List<XC_PointOfService__c> posList, XC_REST_Account_W.WrapperResponse wrResp, String clientSystem) {

                Map<Id, XC_Address__c> mapIdAddr = populateMapAddress(addrList);
               
                Map<Id, XC_PointOfService__c> mapIdPos = populateMapPos(posList);
                
                /*
                Map<Id, XC_PointOfService__c> mapIdPos = new Map<Id, XC_PointOfService__c>();
                if (posList.size()>0) {
                        for(XC_PointOfService__c  pos : posList){
                                mapIdPos.put(pos.Id, pos); 
                        }
                }*/
        
                wrResp.Address = new List<XC_UTIL_Address.AddressWrapper>();
                for (XC_UTIL_SObject.WrapperResult addr : addrListRes) {
                        XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
                        if(addr.success) {
                                addressWr.AddressID = mapIdAddr.get(addr.recordId).Id;
                                addressWr.StreetType =  mapIdAddr.get(addr.recordId).XC_StreetTypeText__c;  // (translatedMap != null) ? translatedMap.get(mapIdAddr.get(addr.recordId).XC_StreetType__c) : mapIdAddr.get(addr.recordId).XC_StreetType__c;
                                addressWr.Address = mapIdAddr.get(addr.recordId).XC_Address__c;
                                addressWr.StreetNumber = mapIdAddr.get(addr.recordId).XC_StreetNumber__c;
                                addressWr.ZipCode = mapIdAddr.get(addr.recordId).XC_PostalCode__c;
                                addressWr.City = mapIdAddr.get(addr.recordId).XC_City__c;
                                addressWr.Country = mapIdAddr.get(addr.recordId).XC_AddressCountry__c;
                                //addressWr.Region = mapIdAddr.get(addr.recordId).XC_Region__c;
                                //addressWr.Note = mapIdAddr.get(addr.recordId).XC_Note__c;
                                addressWr.InstallationAddress = null; 
                                addressWr.DeliveryAddress = null;
                                addressWr.BillingAddress = null;
                                addressWr.isPartner = null;
                                addressWr.PickupPoint = null;
                                addressWr.Warehouse = null;
                                addressWr.PointOfSales = null;
                        }
                        if(posList != null && !posList.isEmpty()){
                                addressWr.PointOfService = new List<XC_UTIL_Address.PoSWrapper>();
                                for(XC_UTIL_Sobject.WrapperResult result : posListRes) {
                                        if(result.success){
                                                /*if(mapIdPos.get(result.recordId).XC_Address__c == addressWr.AddressID){
                                                        XC_UTIL_Address.PosWrapper posWR = new XC_UTIL_Address.PosWrapper();
                                                        posWR.POSID = mapIdPos.get(result.recordId).id;
                                                        //posWR.POS = mapIdPos.get(result.recordId).POs;
                                                        addressWr.PointOfService.add(posWR); 
                                                        POST
                                                }*/
                                                if(mapIdPos.get(result.recordId).XC_Address__c == addressWr.AddressID){
                                                        XC_UTIL_Address.PosWrapper posWR = new XC_UTIL_Address.PosWrapper();
                                                        posWR.POSID = mapIdPos.get(result.recordId).id;
                                                        posWR.POS = mapIdPos.get(result.recordId).Name;
                                                        addressWr.PointOfService.add(posWR); 
                                                }
                                        
                                        }
                                }
                        }
                        wrResp.Address.add(addressWr); 
                }
        }

        
        /**
         * *******************************************************************************************************************************************************************.
         * @param addrList the addr list
         * @return Map<Id, XC_Address__c>
         * @description Method to populate the map with Id as key and XC_PointOfService__c as Value
         * ********************************************************************************************************************************************************************
        */
        public static Map<Id, XC_Address__c> populateMapAddress(List<XC_Address__c> addrList){

                Map<Id, XC_Address__c> mapIdAddr = new Map<Id, XC_Address__c>();
                for(XC_Address__c addr : addrList){
                        mapIdAddr.put(addr.Id, addr); 
                }
                return mapIdAddr;
        } 


        /**
         * *******************************************************************************************************************************************************************.
         * @param addrList the addr list
         * @return Map<Id, XC_PointOfService__c>
         * @description Method to populate the map with Id as key and XC_Address__c as Value
         * ********************************************************************************************************************************************************************
        */
        public static Map<Id, XC_PointOfService__c> populateMapPos(List<XC_PointOfService__c> posList){

                Map<Id, XC_PointOfService__c> mapIdPos = new Map<Id, XC_PointOfService__c>();
                
                if (posList != null && posList.size()>0) {
                        for(XC_PointOfService__c  pos : posList){
                                mapIdPos.put(pos.Id, pos); 
                        }
                }

                return mapIdPos;
        } 


        /**
         * **************************************************************************************************************************************************.
         * @param billProfileList the bill profile list
         * @param billingProfileWrList the billing profile wr list
         * @param wrResp the wr resp
         * @param beforeAccSavepoint the before acc savepoint
         * @description Method to populate the Billing Profile Wrapper List of the WrapperResponse for the PUT and POST REST Callout
         * ***************************************************************************************************************************************************
         */
        public static void populateBillingProfileResponse(List<NE__Billing_Profile__c> billProfileList, List<XC_UTIL_Sobject.WrapperResult> billingProfileWrList, XC_REST_Account_W.WrapperResponse wrResp){
                
                Map<Id, NE__Billing_Profile__c> billingProfileMap = new Map<Id, NE__Billing_Profile__c>();
                for(NE__Billing_Profile__c billProfile : billProfileList){
                        billingProfileMap.put(billProfile.Id, billProfile); 
                }
                wrResp.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
                if(billingProfileWrList.size() > 0){
                       
                        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileWr;

                        for(XC_UTIL_Sobject.WrapperResult wr : billingProfileWrList){
                                billingProfileWr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
                                if(wr.success) {
                                        billingProfileWr.BillingProfileID = wr.recordId;
                                        billingProfileWr.PaymentMethod = (billingProfileMap.get(wr.recordId).Name.containsIgnoreCase('SEPA')) ? 'SEPA' : billingProfileMap.get(wr.recordId).NE__Payment__c;
                                        //billingProfileWr.PaymentMethod = (billingProfileMap.get(wr.recordId).NE__Payment__c == 'Direct Debt') ? 'SEPA' : billingProfileMap.get(wr.recordId).NE__Payment__c ;
                                } else {
                                        wrResp.Result.Message = 'INTERNAL ERROR: In BillingProfile Section ' + wr.errorMessage;
                                        wrResp.Result.ErrorCode = '500';
                                        wrResp.Result.logError = 'INTERNAL ERROR: In BillingProfile Section ' + wr.errorMessage;
                                        return;
                                }
                                wrResp.BillingProfile.add(billingprofileWr);
                        }      
                }
                  
        }


        /**
         * *******************************************************************************************************************************************.
         * @param conList the con list
         * @param contactWrLIST the contact wr LIST
         * @param wrResp the wr resp
         * @param beforeAccSavepoint the before acc savepoint
         * @description Method to populate the Contact Wrapper List of the WrapperResponse for the PUT and POST REST Callout
         * ********************************************************************************************************************************************
         */
        public static void populateIdentityResponse (List<XC_PersonalDocument__c> docList, List<XC_UTIL_Sobject.WrapperResult> docWrLIST, XC_REST_Account_W.WrapperResponse wrResp){

                XC_UTIL_Account.IdentityIFWrapper identityWr; 

                Map<Id, XC_PersonalDocument__c> mapIdIdentity = new Map<Id, XC_PersonalDocument__c>();
                for (XC_PersonalDocument__c doc : docList){
                        mapIdIdentity.put(doc.id, doc);
                }

                /*for(XC_UTIL_Sobject.WrapperResult wr : docWrLIST){ 
                        identityWr = new XC_UTIL_Account.IdentityIFWrapper();
                        if(wr.success) {
                                identityWr.IdentityID = wr.recordId;
                                identityWr.Country = mapIdIdentity.get(wr.recordId).XC_Country__c;
                                identityWr.IdentityType = mapIdIdentity.get(wr.recordId).XC_DocumentType__c;
                                identityWr.IdentityNumber = mapIdIdentity.get(wr.recordId).XC_DocumentNumber__c;
                        } else {   
                                wrResp.Result.Message = 'INTERNAL ERROR: In Identity Section, ' + wr.errorMessage;
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.logError = 'INTERNAL ERROR' + wr.errorMessage;
                                return;
                        }
                        wrResp.Identity.add(identityWr);
                }*/

                List<XC_UTIL_Sobject.WrapperResult> otherDocumentResultWr = new List<XC_UTIL_Sobject.WrapperResult>();
                Set<String> otherDocumentIds = new Set<String>();
                for(XC_UTIL_Sobject.WrapperResult wr : docWrLIST){

                        if(!wr.success) {
                                wrResp.Result.Message = 'INTERNAL ERROR: In Identity Section, ' + wr.errorMessage;
                                wrResp.Result.ErrorCode = '500';
                                wrResp.Result.logError = 'INTERNAL ERROR' + wr.errorMessage;
                                return;
                        } else {
                                if(mapIdIdentity.containskey(wr.recordId)) {
                                        identityWr = new XC_UTIL_Account.IdentityIFWrapper();
                                        identityWr.IdentityID = wr.recordId;
                                        identityWr.Country = mapIdIdentity.get(wr.recordId).XC_Country__c;
                                        identityWr.IdentityType = mapIdIdentity.get(wr.recordId).XC_DocumentType__c;
                                        identityWr.IdentityNumber = mapIdIdentity.get(wr.recordId).XC_DocumentNumber__c;
                                        wrResp.Identity.add(identityWr);
                                } else {
                                        otherDocumentResultWr.add(wr);
                                        otherDocumentIds.add(wr.recordId);
                                }
                        }
                }

                if(!otherDocumentIds.isEmpty()) {
                        Map<Id, XC_PersonalDocument__c> otherDocumentMap = new Map<Id, XC_PersonalDocument__c>([SELECT Id, XC_Country__c, XC_DocumentType__c, XC_DocumentNumber__c
                                                                                                                FROM XC_PersonalDocument__c
                                                                                                                WHERE Id IN :otherDocumentIds]);
                        for(XC_UTIL_Sobject.WrapperResult wr : otherDocumentResultWr) {
                                identityWr = new XC_UTIL_Account.IdentityIFWrapper();
                                if(wr.success) {
                                        identityWr.IdentityID = wr.recordId;
                                        identityWr.Country = otherDocumentMap.get(wr.recordId).XC_Country__c;
                                        identityWr.IdentityType = otherDocumentMap.get(wr.recordId).XC_DocumentType__c;
                                        identityWr.IdentityNumber = otherDocumentMap.get(wr.recordId).XC_DocumentNumber__c;
                                } else {   
                                        wrResp.Result.Message = 'INTERNAL ERROR: In Identity Section, ' + wr.errorMessage;
                                        wrResp.Result.ErrorCode = '500';
                                        wrResp.Result.logError = 'INTERNAL ERROR' + wr.errorMessage;
                                        return;
                                }
                                wrResp.Identity.add(identityWr);
                        }
                }
        }
}