/**
 * The Class XC_REST_Account_ZZZ.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 23/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account - Populate Object from wrapper
 */


public without sharing class XC_REST_Account_ZZZ {

    
    /**
    * CreateIdentityFromWrapper.
    *
    * @param identity the identity  
    * @param accountID the account ID
    * @return the perdonal document
    * @description method to create personal document from wrapper
    */
    public static XC_PersonalDocument__c createIdentityFromWrapper(XC_UTIL_Account.IdentityIFWrapper identity, String accountID,  String contactID) {
        
        Map<String, Object> identityParameters = new Map<String, Object>{'Id' => identity.IdentityID,
                                                                        'XC_Country__c' => identity.Country,
                                                                        'XC_DocumentType__c' => identity.IdentityType,
                                                                        'XC_DocumentNumber__c' => identity.IdentityNumber,
                                                                        'XC_ReleaseDate__c' => (identity.ReleaseDate != null) ? Date.valueOf(identity.ReleaseDate) : null,
                                                                        'XC_ExpirationDate__c' => (identity.ExpiryDate != null) ? Date.valueOf(identity.ExpiryDate) : null,
                                                                        'XC_Account__c' => accountID,
                                                                        'XC_Contact__c' => contactID,
                                                                        'XC_Issued_By__c' => identity.IssuedBy,
                                                                        'XC_Issued_On__c' => (identity.IssuedOn != null) ? Date.valueOf(identity.IssuedOn) : null,
                                                                        'XC_Issue_Place__c' => identity.IssuePlace,
                                                                        'XC_Issue_Province__c' => identity.IssueProvince,
                                                                        'XC_Issue_Country__c' => identity.IssueCountry};

        XC_PersonalDocument__c identityFromWrapper = new XC_PersonalDocument__c();
        for(String field : identityParameters.keySet()) {
            if(identityParameters.get(field) != null) {
                identityFromWrapper.put(field, identityParameters.get(field));
            }
        }
        
        return identityFromWrapper;
    }


    /**
     * CreateAccountFromWrapper.
     *
     * @param utilMapAccount the util map 
     * @param existingAcc the existing acc
     * @return the account
     * @description Method to populate Account fields from WrapperRequest
     */
    public static void createAccountFromWrapper(Map<String,Object> utilMapAccount, Account accountFromWrapper){

        XC_REST_Account_W.WrapperRequest wr = (XC_REST_Account_W.WrapperRequest) utilMapAccount.get('wrReq');
        String method = (String) utilMapAccount.get('method');
        String clientSystem = (String) utilMapAccount.get('clientSystem');

        Map<String, Object> mapAccountIdentity = new Map<String,Object>{'wr' => wr,'accountFromWrapper' => accountFromWrapper};
        manageAccountIdentity(mapAccountIdentity, method);      

        String identityType = (String) mapAccountIdentity.get('identityType');
        String identityNumber = (String) mapAccountIdentity.get('identityNumber');
        String identityCountry = (String) mapAccountIdentity.get('Country'); //[ACERRA CR-NR2063 B2B 17.11.2021]
        Date releaseDate = (Date) mapAccountIdentity.get('releaseDate');
        Date expiryDate = (Date) mapAccountIdentity.get('expiryDate');
        String documentCountry = (String) mapAccountIdentity.get('documentCountry');
        //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        String commodityCustomerName = (String) mapAccountIdentity.get('commodityCustomerName');
        String commodityIdentityNumber = (String) mapAccountIdentity.get('commodityIdentityNumber');
        //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
 
        String language = XC_REST_Account_ZZZZ.checkLanguageForAccount(wr.Account.PreferenceLanguage);

        Boolean isGuestUser;
        Boolean forEmobility;
        Boolean splitPayment; 
        if(/*String.isBlank(wr.Account.AccountID)*/ method == 'POST') {
            splitPayment = (wr.Account.SplitPayment != null) ? wr.Account.SplitPayment : false;
            if(wr.Account.RegisteredOnRechargeApp != null){
                isGuestUser = (wr.Account.RegisteredOnRechargeApp == false && ((wr.Account.PrimaryEmail != null && wr.Account.PrimaryEmail.endsWith('@enel.app.com')) || (wr.Account.Channel != null && wr.Account.Channel.equalsIgnoreCase('Web')))) ? true : false;
                if(wr.Account.Channel == null || (wr.Account.Channel != null && !wr.Account.Channel.equalsIgnoreCase('Web'))) { 
                    forEmobility = true;
                }else{
                    forEmobility = false;
                }
            }
            
        }
        
        /*if(wr.Account.RegisteredOnRechargeApp != null && !String.isBlank(wr.Account.PrimaryEmail)){
            isGuestUser = (wr.Account.RegisteredOnRechargeApp == false && (wr.Account.PrimaryEmail.endsWith('@enel.app.com')) ? true: false;
        }*/
        // forEmobility = (wr.Account.RegisteredOnRechargeApp != null && wr.Account.Channel == null) ? true : false;

        Map<String, Object> mapAccountWrapper = new Map<String,Object>{'Id' => wr.Account.AccountID,
                                                                        'XC_AccountType__c' => wr.Account.AccountType,
                                                                        'XC_UniqueId__c' =>  wr.Account.UniqueID,
                                                                        //[BEGIN ACERRA CR-NR2063 B2B 01.12.2021]
                                                                        //'XC_LastName__c' => wr.Account.LastName,
                                                                        'XC_LastName__c' =>(('CommodityItalyB2C'.equalsIgnoreCase(clientSystem) && method == 'POST' && 'B2B'.equalsIgnoreCase(wr.Account.AccountType) && String.isNotBlank(wr.Account.LastName)) ? wr.Account.LastName.left(40) : wr.Account.LastName) ,
                                                                        //[END ACERRA CR-NR2063 B2B 01.12.2021]
                                                                        'XC_FirstName__c' => wr.Account.FirstName,
                                                                        'XC_MainPhonePrefix__c' => wr.Account.PhonePrefix,
                                                                        'XC_AccountMainPhone__c' => wr.Account.Phone,
                                                                        'PrimaryEmail__c' => wr.Account.PrimaryEmail,
                                                                        'XC_AccountPhonePrefix__c' => wr.Account.MainPhonePrefix,
                                                                        'XC_AccountPhone__c' => wr.Account.MainPhone, 
                                                                        'IdentityType__c' => identityType,
                                                                        'IdentityNumber__c' => identityNumber,
                                                                        'XC_NIE_expedition_date__c' => releaseDate,
                                                                        'XC_NIE_expiration_date__c' => expiryDate,
                                                                        'XC_DocumentCountry__c' => documentCountry,
                                                                        'XC_Status__c' => wr.Account.Status,
                                                                        //[BEGIN ACERRA CR-NR2063 B2B 08.11.2021]
                                                                        //'Country__c' =>  wr.Account.Country,
                                                                        //'XC_Country__c' =>  wr.Account.Country,
                                                                        'Country__c' => (('CommodityItalyB2C'.equalsIgnoreCase(clientSystem) && method == 'POST' && 'B2B'.equalsIgnoreCase(wr.Account.AccountType)) ? identityCountry :wr.Account.Country),
                                                                        'XC_Country__c' => (('CommodityItalyB2C'.equalsIgnoreCase(clientSystem) && method == 'POST' && 'B2B'.equalsIgnoreCase(wr.Account.AccountType)) ? identityCountry :wr.Account.Country),
                                                                        //[END ACERRA CR-NR2063 B2B 08.11.2021]
                                                                        'XC_BirthDate__c' => wr.Account.BirthDate,
                                                                        'XC_Preference_Language__c' => language,
                                                                        'XC_Notes__c' =>  wr.Account.Notes,
                                                                        'XC_PreferredPartner__c' => wr.Account.PartnerID,
                                                                        'XC_Blacklist_result__c' => wr.Account.BlackList,
                                                                        'BusinessName__c' => wr.Account.BusinessName,
                                                                        'XC_AccountNationality__c' => wr.Account.Nationality,
                                                                        //'XC_Score__c' => wr.Account.CommodityScoring,
                                                                        'XC_DataLakeScore__c' => wr.Account.DataLakeScoring,
                                                                        'XC_CertifiedEmail__c' =>  wr.Account.CertifiedEmail,
                                                                        'XC_isGuestUser__c' => isGuestUser,
                                                                        'XC_CreatedForEmobility__c' => forEmobility,
                                                                        'XC_ConfirmationByCustomer__c' => true,
                                                                        'XC_ReceivingChannel__c' => (String.isNotBlank(wr.Account.Channel)) ? wr.Account.Channel : ((clientSystem == Label.XC_CL_CommoditySpainB2C && method == 'POST') ? 'Commodity Partner' : null),
                                                                        'XC_SplitPayment__c' => splitPayment,
                                                                        'XC_Segment__c' => (String.isNotBlank(wr.Account.Stream)) ? wr.Account.Stream : (String.isNotBlank(wr.Account.AccountType) && (wr.Account.AccountType == 'B2B' || wr.Account.AccountType == 'B2G')) ? wr.Account.AccountType : ((method == 'POST') ? 'B2C' : null), //03-02-2022 Commodity Spain use AccountType to specify segment
                                                                        'XC_GIRO__c' => wr.Account.GIRO,
                                                                        //[BEGIN ACERRA CR-NR2063 B2B 08.11.2021]
                                                                        // 'Company__c' => (clientSystem == Label.XC_CL_CommoditySpainB2C && method == 'POST' && wr.Account.AccountType == 'Small Business') ? wr.Account.LastName : null,
                                                                        'Company__c' => ((clientSystem == Label.XC_CL_CommoditySpainB2C && method == 'POST' && wr.Account.AccountType == 'Small Business') || ('CommodityItalyB2C'.equalsIgnoreCase(clientSystem) && method == 'POST' && 'B2B'.equalsIgnoreCase(wr.Account.AccountType) )) ? wr.Account.LastName : null,
                                                                        //[END ACERRA CR-NR2063 B2B 08.11.2021]
                                                                        'XC_SectorOfTheCompany__c' => wr.Account.Sector,
                                                                        'XC_SectorOfTheCompanySecondLevel__c' => wr.Account.Subsector,
                                                                        'XC_SegmentOfCountry__c' => wr.Account.SegmentOfCountry,
                                                                        'XC_Theatre__c' => wr.Account.Theatre,
                                                                         //[BEGIN ACERRA CR-NR2063 B2B 08.11.2021]
                                                                         'XC_AccountTaxType__c' => wr.Account.AccountTaxType,
                                                                         'XC_VatGroupType__c' => wr.Account.VatGroupType,
                                                                         'XC_Zone__c' => wr.Account.Zone
                                                                         //[END ACERRA CR-NR2063 B2B 08.11.2021]
                                                                        };
        
        if(wr.Account.AccountType != null){
            
            String soType = (wr.Account.AccountType == 'Small Business') ? wr.Account.SohoType :null;
            mapAccountWrapper.put('XC_SohoType__c', soType);
           
            if(method == 'POST') {
                /*String typeName = '%' + mapAccountWrapper.get('XC_Segment__c') + '%';
                if(typeName.contains('B2C')) {
                    typeName = (wr.Account.AccountType == 'Small Business') ? 'Soho' : wr.Account.AccountType;
                    typeName = '%' + typeName + '%';
                }
                
                Map<Id,RecordType> rec = new Map<Id,RecordType>([SELECT Id, SobjectType, Name FROM RecordType WHERE DeveloperName like :typeName AND SobjectType = 'Account' LIMIT 1]);
                accountFromWrapper.RecordTypeID = rec.values()[0].Id;
                System.debug('@@@ Acc RT: ' + rec.values()[0].Name);*/
                if(String.isBlank(accountFromWrapper.RecordTypeID)){
                    accountFromWrapper.RecordTypeID = retrieveRecordTypeID(wr, method);
                }
                
                //[BEGIN ACERRA CR-NR2063 B2B 12.11.2021]
                if('CommodityItalyB2C'.equalsIgnoreCase(clientSystem) && 'B2B'.equalsIgnoreCase(wr.Account.AccountType)){
                    mapAccountWrapper.put('XC_SohoType__c',  wr.Account.AccountType);
                    mapAccountWrapper.put('XC_CompanyFiscalCode__c',  identityNumber); // NOT WORKS for Gruppo IVA Enel and Gruppo IVA Societario. In this cases they must be different. 
                    //mapAccountWrapper.put('XC_TradingPartner__c',  'G0CL10'); // XC_TradingPartner__c mandatory for Gruppo IVA Enel
                }
                //[END ACERRA CR-NR2063 B2B 12.11.2021]
                
            }
            //[ BEGIN, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping and conditions for new tag]
            system.debug('vat: ' +wr.Account.VatGroupNumber);
            system.debug('identity: ' +wr.Account.IdentityNumber);
            if(wr.Account.VatGroupNumber != null && wr.Account.IdentityNumber != null){
                mapAccountWrapper.put('XC_CompanyFiscalCode__c', wr.Account.VatGroupNumber);
                mapAccountWrapper.put('IdentityNumber__c',  wr.Account.IdentityNumber);
            } else if(wr.Account.VatGroupNumber == null && wr.Account.IdentityNumber != null){
                mapAccountWrapper.put('IdentityNumber__c',  wr.Account.IdentityNumber);
                mapAccountWrapper.put('XC_CompanyFiscalCode__c',wr.Account.IdentityNumber);
            }
           //[ END, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping and conditions for new tag]
            //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
           if('B2C'.equalsIgnoreCase(wr.Account.AccountType) && 'Brazil'.equalsIgnoreCase(documentCountry))
           {
            mapAccountWrapper.put('XC_CommodityCustomerName__c', commodityCustomerName);
            mapAccountWrapper.put('XC_CommodityIdentityNumber__c',commodityIdentityNumber);
           }
            //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        
        }
        
        for(String key : mapAccountWrapper.keySet()){
            if(mapAccountWrapper.get(key) != null){
                accountFromWrapper.put(key, mapAccountWrapper.get(key));
            }
        }
        
        //manageAccountName(wr, method, accountFromWrapper);
        String name = checkAccountName(wr, method, accountFromWrapper);
            if(!String.isBlank(name)&&
        !((wr.Account.AccountType=='Residential'||accountFromWrapper.XC_RecordTypeDeveloperName__c=='XC_GLO_Account_Residential')&&method=='PUT')){ 
         system.debug('**************lkj: '+name+' '+wr.Account.AccountType+' '+method+' ');
            accountFromWrapper.Name = name;
        }     
    }


    /**
    * @param mapAccountIdentity - Map<String, Object>
    * @description Method to populate Identity Account fields from WrapperRequest
    */
    public static void manageAccountIdentity(Map<String, Object> mapAccountIdentity, String method){

        XC_REST_Account_W.WrapperRequest wr = (XC_REST_Account_W.WrapperRequest) mapAccountIdentity.get('wr');
        Account accountFromWrapper = (Account) mapAccountIdentity.get('accountFromWrapper'); 

        if(wr.Identity != null && wr.Identity.size()>0) {

            if(method == 'POST') {
                setIdentityData(mapAccountIdentity, wr.Identity[0]);

            } else if(method == 'PUT' && ((wr.Account.AccountType == 'Small Business' || wr.Account.AccountType == 'Condominium' )||(accountFromWrapper.XC_AccountType__c == 'Small Business' || accountFromWrapper.XC_AccountType__c == 'Condominium'))) {

                for(XC_UTIL_Account.IdentityIFWrapper idWr : wr.Identity) {
                    if(String.isNotBlank(idWr.IdentityID) && idWr.IdentityID == accountFromWrapper.Id) {
                        setIdentityData(mapAccountIdentity, idWr);
                    }
                }
            }
        }

        /*if((method == 'POST' || (method == 'PUT' && ((wr.Account.AccountType == 'Small Business' || wr.Account.AccountType == 'Condominium' )||(accountFromWrapper.XC_AccountType__c == 'Small Business' || accountFromWrapper.XC_AccountType__c == 'Condominium')))) && (wr.Identity != null && wr.Identity.size()>0)){
            mapAccountIdentity.put('identityType',  wr.Identity[0].IdentityType);
            mapAccountIdentity.put('identityNumber', wr.Identity[0].IdentityNumber);
            if(wr.Identity[0].ReleaseDate != null){
                mapAccountIdentity.put('releaseDate', Date.valueOf(wr.Identity[0].ReleaseDate));
            }
            if(wr.Identity[0].ExpiryDate!= null){
                mapAccountIdentity.put('expiryDate', Date.valueOf(wr.Identity[0].ExpiryDate));
            }
            mapAccountIdentity.put('documentCountry', wr.Identity[0].Country);
        }*/
    }


    /**
    * @param mapAccountIdentity - Map<String, Object>
    * @param idWr - XC_UTIL_Account.IdentityIFWrapper
    * @description setIdentityData
    */
    public static void setIdentityData(Map<String, Object> mapAccountIdentity, XC_UTIL_Account.IdentityIFWrapper idWr){

        mapAccountIdentity.put('identityType',  idWr.IdentityType);
        mapAccountIdentity.put('identityNumber', idWr.IdentityNumber);
        if(idWr.ReleaseDate != null){
            mapAccountIdentity.put('releaseDate', Date.valueOf(idWr.ReleaseDate));
        }
        if(idWr.ExpiryDate!= null){
            mapAccountIdentity.put('expiryDate', Date.valueOf(idWr.ExpiryDate));
        }

        mapAccountIdentity.put('Country',  idWr.Country); //[ACERRA CR-NR2063 B2B 17.11.2021]
        mapAccountIdentity.put('documentCountry', idWr.Country);
    }


   /**
    * CheckAccountName.
    *
    * @param wr the Account Wrapper
    * @param method the method
    * @param existingAcc the existing acc
    * @description method to populate Account Name from WrapperRequest
    */        
    /*public static void manageAccountName(XC_REST_Account_W.WrapperRequest wr, String method, Account existingAcc){
        String name = checkAccountName(wr, method, existingAcc);
        if(!String.isBlank(name)){
            existingAcc.Name = name;
        }
    }


    /**
    * CheckAccountName.
    *
    * @param wr the Account Wrapper
    * @param method the method
    * @param existingAcc the existing acc
    * @return Account Name
    * @description method to populate Account Name from WrapperRequest Util
    */        
    public static String checkAccountName(XC_REST_Account_W.WrapperRequest wr, String method, Account existingAcc) {

        String name; 

        if(method == 'POST') {
            if(wr.Account.FirstName != null && wr.Account.LastName != null) {
                name = wr.Account.LastName + ' ' + wr.Account.FirstName;
            } else {
                name = wr.Account.LastName;
            } 
        } 

        if(method == 'PUT' && (wr.Account.FirstName != null || wr.Account.LastName != null)) {
            if(wr.Account.FirstName != null && wr.Account.LastName != null) {
                name = wr.Account.LastName + ' ' + wr.Account.FirstName;
            } else if (wr.Account.LastName != null) {
                if (existingAcc.XC_FirstName__c != null) {
                    name = wr.Account.LastName + ' ' + existingAcc.XC_FirstName__c;
                } else {
                    name = wr.Account.LastName;
                }
            } else {
                if (existingAcc.XC_LastName__c != null) {
                    name = existingAcc.XC_LastName__c + ' ' + wr.Account.FirstName;
                } 
            }
        }

        return name;
    }
    

    /**
    * retrieveRecordTypeID.
    *
    * @param wr the Account Wrapper
    * @param method the method
    * @return record type di
    * @description method to retrieve the record type id 
    */        
    public static string retrieveRecordTypeID(XC_REST_Account_W.WrapperRequest wr, String method){
        //[BEGIN ACERRA CR B2B 05.11.2021]
        //String segment = (String.isNotBlank(wr.Account.Stream)) ? wr.Account.Stream : ((method == 'POST') ? 'B2C' : null);
        String segment = (String.isNotBlank(wr.Account.Stream)) ? wr.Account.Stream :(method == 'POST' && 'B2B'.equalsIgnoreCase(wr.Account.AccountType) ? 'B2B' :  ((method == 'POST') ? 'B2C' : null));
        //[END ACERRA CR B2B 05.11.2021]
        String typeName = '%' + segment + '%';
        if(typeName.contains('B2C')) {
            typeName = (wr.Account.AccountType == 'Small Business') ? 'Soho' : wr.Account.AccountType;
            typeName = '%' + typeName + '%';
        }
       
        Map<Id,RecordType> rec = new Map<Id,RecordType>([SELECT Id, SobjectType, Name FROM RecordType WHERE DeveloperName like :typeName AND SobjectType = 'Account' LIMIT 1]);
        System.debug('@@@ Acc RT: ' + rec.values()[0].Name);
        return rec.values()[0].Id;
    }
}