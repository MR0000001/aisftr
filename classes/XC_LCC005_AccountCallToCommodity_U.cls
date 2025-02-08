/**
 * @author Andrea Di Cicco 
 * @date Creation 22/10/2019
 * @description XC_LCC005_AccountCallToCommodity_U - extends class XC_LCC005_AccountCallToCommodity
 **/
public without sharing class XC_LCC005_AccountCallToCommodity_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_AccountCallToCommodity');
    private final static List<String> B2B_COUNTRY = new List<String>{'Chile', 'Colombia'};
    /**
     * @author Andrea Di Cicco
     * @description importAddressFromCommodity.
     * @param inputDataToSave map with all params input
     * @param addressValues addressValues to save
     * @param posValues posValues to save
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper importAddressFromCommodity(Map<String,Object> inputDataToSave, List<Map<String,Object>> addressValues, List<List<Map<String,Object>>> posValues){
        String recordId = (String)inputDataToSave.get('recordId');
        String sobjecttype = (String)inputDataToSave.get('sobjecttype');
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordId = '+recordId);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'sobjecttype = '+sobjecttype);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->-> CALL importAddressFraddressValuesomCommodity - addressValues = '+addressValues);
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        result.success = true;
        if(addressValues == null){
            return result;
        }
        
        if('Account'.equals(sobjecttype)){
            XC_UTIL_Address.AddressWrapper addressWrapper = XC_UTIL_CommodityAccount.populateAddressFromCommodityFields(recordId, addressValues, posValues);
            Account accInfo = [SELECT XC_DocumentCountry__c FROM Account WHERE Id = : recordId LIMIT 1];
            if(accInfo.XC_DocumentCountry__c != null && B2B_COUNTRY.contains(accInfo.XC_DocumentCountry__c) && posValues != null && !posValues.isEmpty()){
                List<XC_UTIL_Address.AddressWrapper> deplicatedAddressList = new List<XC_UTIL_Address.AddressWrapper>();
                for(List<Map<String,Object>> pos : posValues){
                    System.debug('pos >' + pos );
                    XC_UTIL_Address.AddressWrapper duplicatedAddress = new XC_UTIL_Address.AddressWrapper();
                    duplicatedAddress =(XC_UTIL_Address.AddressWrapper)JSON.deserialize(JSON.serialize(addressWrapper), XC_UTIL_Address.AddressWrapper.class); 
                    for(Map<String,Object> field : pos){ 
                        if('POS'.equals(field.get('fieldKey'))) {
                            duplicatedAddress.electricCUPS = (String)field.get('fieldValue');
                            //continue;
                        }
                    }
                    System.debug('deplicatedAddressList > ' + duplicatedAddress.electricCUPS);
                    deplicatedAddressList.add(duplicatedAddress);
                }
                List<XC_UTIL_Sobject.WrapperResult> wrapResultList = XC_UTIL_Address.insertListAddress(deplicatedAddressList);
                for(XC_UTIL_Sobject.WrapperResult wrapResult : wrapResultList ){
                    if(!wrapResult.success){
                        result.success = wrapResult.success;
                        result.resultMessage = wrapResult.errorMessage;
                        return result;
                    }
                }
                result.success = true;
                result.resultMessage =  Label.XC_CL_Address_Created ;
                return result;
            }else{
                XC_UTIL_Sobject.WrapperResult addrResult = XC_UTIL_Address.insertAddress(addressWrapper);
                XC_Address__c newaddress = new XC_Address__c();
                if(addrResult.recordId != null && addrResult.recordId!= ''){
                    newaddress.Id = addrResult.recordId;
                }
                newaddress.XC_AddressValidated__c = true;
                newaddress.XC_AddressValidatedCUPS__c = true;
                XC_UTIL_SObject.updateRecord(newaddress);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ DML addrResult = '+addrResult);
                result.success = addrResult.success;
                result.resultMessage = (addrResult.success) ? Label.XC_CL_Address_Created : addrResult.errorMessage;
                return result;
            }
        } if('Lead'.equals(sobjecttype)){

			Map<id,XC_Address__c> addrToCheck = new Map<id,XC_Address__c>([select id, XC_Lead__c from XC_Address__c where XC_Lead__c =: recordId]);
			if(!addrToCheck.values().isEmpty()){
				result.success = false;
            	result.resultMessage = Label.XC_CL_Address_Lead;
				return result;
			}

			XC_UTIL_Address.AddressWrapper addressWrapper = XC_UTIL_CommodityAccount.populateAddressFromCommodityFields(recordId, addressValues, posValues);
			XC_UTIL_Sobject.WrapperResult addrResult = XC_UTIL_Address.insertAddress(addressWrapper);
			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ DML addrResult = '+addrResult);
            result.success = addrResult.success;
            result.resultMessage = (addrResult.success) ? Label.XC_CL_Address_Created : addrResult.errorMessage;
			if(!result.success){
				return result;
			}
				
			Lead l = XC_UTIL_CommodityAccount.populateAddressFieldsOnLead(recordId, addressValues);
			l.XC_LeadAddress__c = addrResult.recordId;
			XC_UTIL_Sobject.WrapperResult leadRes = XC_UTIL_Sobject.updateRecord(l);
			result.success = leadRes.success;
			if(!result.success){
				result.resultMessage = leadRes.errorMessage;
			}
			
			return result;

		} else{
            result.success = false;
            result.resultMessage = Label.XC_CL_OperationNotAllowed;
            return result;
        }
    }

    /**
     * @author Andrea Di Cicco
     * @description importAddressFromCommodity.
     * @param inputDataToSave map with all params input
     * @param contactValues addressValues to save
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper importContactFromCommodity(Map<String,Object> inputDataToSave, List<Map<String,Object>> contactValues){
        String recordId = (String)inputDataToSave.get('recordId');
        String sobjecttype = (String)inputDataToSave.get('sobjecttype');
        String serverSystem = (String)inputDataToSave.get('serverSystem');
        Contact newContact = new Contact();
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        try{
        result.success = true;
        if(contactValues == null){
            return result;
        }

        newContact = inputDataMappingContact( contactValues, recordId);
        newContact.XC_ContactDocumentCountry__c = XC_UTIL_Country.serverSystemOnCountryMapping(serverSystem); //Anomalia 2400 [MC - 27/02/2020]
        XC_UTIL_Sobject.WrapperResult contactResult = XC_UTIL_Sobject.insertRecord(newContact);
        result.success = contactResult.success;
        result.resultMessage = (contactResult.success) ? Label.XC_CL_Contact_Created : contactResult.errorMessage;

        
        
        }catch(Exception ex){
            result.success = false;
            result.resultMessage = Label.XC_CL_OperationNotAllowed;
        }
        return result;
    }

    private static Contact inputDataMappingContact(List<Map<String,Object>> contactValues, String recordId){
        Map<String,String> contactMappingFields =  new Map<String, String>();
        contactMappingFields.put(Label.XC_CL_360LastName			,'LastName'							);
        contactMappingFields.put(Label.XC_CL_360FirstName				,'FirstName'						);
        contactMappingFields.put(Label.XC_CL_360PrimaryEmail					,'Email'							);
        contactMappingFields.put( Label.XC_CL_360MainPhonePrefix		,'XC_PhonePrefix__c'				);
        contactMappingFields.put(  Label.XC_CL_360MainPhone ,'XC_ContactPhone__c');
        contactMappingFields.put( Label.XC_CL_360PhonePrefix				,'XC_MobilePrefix__c'				);
        contactMappingFields.put( Label.XC_CL_360Phone					,'XC_ContactMobile__c'							);
        contactMappingFields.put(Label.XC_CL_360IdentityType			,'XC_ContactDocumentType__c'		);
        contactMappingFields.put(Label.XC_CL_360IdentityNumber		,'XC_ContactDocumentNumber__c'		);
        contactMappingFields.put(Label.XC_CL_360PreferenceLanguage		,'XC_Preferredlanguageofcontact__c');

        Contact newContact = new Contact();
        newContact.AccountId = recordId;
         Contact primaryContact = new Contact();
        if(Schema.sObjectType.Contact.isAccessible()){
            primaryContact = [SELECT XC_ContactDocumentCountry__c, XC_CountryLegalEntity__c, XC_MainLegalEntity__c, XC_GiveDataToNew__c, Account.XC_RecordTypeDeveloperName__c
                                FROM  Contact 
                                WHERE XC_PrimaryContact__c = true 
                                AND AccountId = : recordId 
                                LIMIT 1];
        }
        /*if(primaryContact.Account.XC_RecordTypeDeveloperName__c == 'XC_GLO_Account_Residential'){
            primaryContact.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Residential').getRecordTypeId();
        }else if(primaryContact.Account.XC_RecordTypeDeveloperName__c == 'XC_GLO_Account_Soho'){
            primaryContact.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Soho').getRecordTypeId();
        }else{
            primaryContact.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Condominium').getRecordTypeId();
        }*/

        newContact.XC_ContactDocumentCountry__c = primaryContact.XC_ContactDocumentCountry__c;
        newContact.XC_CountryLegalEntity__c = primaryContact.XC_CountryLegalEntity__c;
        newContact.XC_MainLegalEntity__c = primaryContact.XC_MainLegalEntity__c;
        newContact.XC_GiveDataToNew__c = primaryContact.XC_GiveDataToNew__c;
        for(Map<String,Object> field : contactValues){
            if(contactMappingFields.get(String.ValueOf(field.get('fieldLabel'))) != null){
                newContact.put(contactMappingFields.get(String.ValueOf(field.get('fieldLabel'))), String.valueOf(field.get('fieldValue')));
            }
        }
        checkPhoneValidation(newContact);
        checkPrefix(newContact);
        return newContact;
    }
    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description checkPhoneValidation
     * @param newContactFromCommodity the Contact
     */
    private static void checkPhoneValidation(Contact newContactFromCommodity){
        if(newContactFromCommodity != null && 
           newContactFromCommodity.XC_PhonePrefix__c == null && newContactFromCommodity.XC_ContactPhone__c == null &&
           newContactFromCommodity.XC_MobilePrefix__c != null && newContactFromCommodity.XC_ContactMobile__c != null){
               
            newContactFromCommodity.XC_PhonePrefix__c = newContactFromCommodity.XC_MobilePrefix__c;
            newContactFromCommodity.XC_ContactPhone__c = newContactFromCommodity.XC_ContactMobile__c;
            newContactFromCommodity.XC_MobilePrefix__c = null;
            newContactFromCommodity.XC_ContactMobile__c = null;
        }
    }

    /**
     * @author Andrea Di Cicco
     * @description if the phone is null also the prefix will be null
     * @param newContactFromCommodity the Contact
     */
    private static void checkPrefix(Contact newContactFromCommodity){
        if(newContactFromCommodity != null && newContactFromCommodity.XC_PhonePrefix__c != null && newContactFromCommodity.XC_ContactPhone__c == null){
            newContactFromCommodity.XC_PhonePrefix__c = null;
        }
        if(newContactFromCommodity != null && newContactFromCommodity.XC_MobilePrefix__c != null && newContactFromCommodity.XC_ContactMobile__c == null){
            newContactFromCommodity.XC_MobilePrefix__c = null;
        }
    }

    /**
     * @author Andrea Di Cicco
     * @date 28/10/2019
     * @description update account info
     * @param value the valued of the field
     * @param label the label of the field
     * @param accountId the Id of the Account
     * @return the result of the update
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper updateAccount(String value, String label, String accountId){
        Account account = new Account();
        if(Schema.sObjectType.Account.isAccessible()){
            account = [SELECT XC_FirstName__c, XC_LastName__c, XC_AccountPhonePrefix__c, XC_AccountPhone__c, XC_MainPhonePrefix__c, PrimaryEmail__c, XC_CertifiedEmail__c   FROM Account  WHERE id = :  accountId LIMIT 1 ];
        }
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        account.put(mappingAccountField( label), value);
        

        XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(account);
        result.success = updateResult.success;
        result.resultMessage = (updateResult.success) ? 'update Account' : updateResult.errorMessage;
        return result;

    }

    private static String mappingAccountField(String label){
        Map<String,String> mappingField = new Map<String, String>();
        mappingField.put( 'First Name','XC_FirstName__c' );
        mappingField.put( 'Last Name or Business Name','XC_LastName__c' );
        mappingField.put( 'Main Phone Prefix','XC_AccountPhonePrefix__c' );
        mappingField.put( 'Main Phone','XC_AccountPhone__c' );
        mappingField.put( 'PhonePrefix','XC_MainPhonePrefix__c' );
        mappingField.put( 'Phone','XC_AccountMainPhone__c' );
        mappingField.put( 'Primary Email','PrimaryEmail__c' );
        mappingField.put( 'Certified Email','XC_CertifiedEmail__c' );
        return mappingField.get(label);
    }

        /**
     * @author Andrea Di Cicco
     * @description update the Name and surname.
     * @param resultListString map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper  saveNameSurname(String resultListString, String recordId){
        List<XC_LCC005_AccountCallToCommodity.FieldWrapper> resultList = (List<XC_LCC005_AccountCallToCommodity.FieldWrapper>) System.JSON.deserialize(resultListString, List<XC_LCC005_AccountCallToCommodity.FieldWrapper>.class);
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        result.success = true;
        Account account = new Account();
        account.id = recordId;
        String name;
        String surname;
        Contact primaryContact = [Select id, FirstName, LastName, Account.RecordType.DeveloperName 
                                 from Contact 
                                 where AccountId = : recordId
                                 and XC_PrimaryContact__c = true
                                 LIMIT 1 ];
        List<NE__Billing_Profile__c> billingProfileList = new List<NE__Billing_Profile__c>();
        Map<Id, NE__Billing_Profile__c>    billingProfileMap = new Map<Id, NE__Billing_Profile__c>( [Select  NE__Account__c, id from NE__Billing_Profile__c where NE__Account__c =: recordId ]);
        billingProfileList = billingProfileMap.values();

        if(!billingProfileList.isEmpty()){
            result.success = false;
            result.resultMessage = Label.XC_CL_360NameAndSurnameError;
            return result;
        }


        result.success = true;

        for(XC_LCC005_AccountCallToCommodity.FieldWrapper field : resultList){ 
            if(field.fieldKey == 'FirstName'){
                name = field.fieldValue;
                

            }else if(field.fieldKey == 'LastName'){
                surname = field.fieldValue;
                
            }
        }

        XC_UTIL_Sobject.WrapperResult accountResult;
        if(!primaryContact.Account.RecordType.DeveloperName.contains('Residential')){
            account.name = name + ' ' +surname;
            accountResult = XC_UTIL_Sobject.updateRecord(account);
        }else{
            primaryContact.FirstName = name;
            primaryContact.LastName = surname;
            accountResult = XC_UTIL_Sobject.updateRecord(primaryContact);
        }
        result.success = accountResult.success;
        result.resultMessage = (accountResult.success) ? Label.XC_CL_360AccountUpdate : accountResult.errorMessage;
        return result;
    }

        /**
     * @author Andrea Di Cicco
     * @description update main phone.
     * @param resultListString map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper  savePrimaryPhone(String resultListString, String recordId){
        List<XC_LCC005_AccountCallToCommodity.FieldWrapper> resultList = (List<XC_LCC005_AccountCallToCommodity.FieldWrapper>) System.JSON.deserialize(resultListString, List<XC_LCC005_AccountCallToCommodity.FieldWrapper>.class);
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        result.success = true;
        Account account = new Account();
        account.id = recordId;
        String prefix;
        String phone;

        result.success = true;

        for(XC_LCC005_AccountCallToCommodity.FieldWrapper field : resultList){ 
            if(field.fieldKey == 'MainPhonePrefix'){
                account.XC_AccountPhonePrefix__c = field.fieldValue;
                

            }else if(field.fieldKey == 'MainPhone'){
                account.XC_AccountPhone__c = field.fieldValue;
                
            }
        }

        if(account.XC_MainPhonePrefix__c == null ){
            account.XC_AccountPhonePrefix__c = '+34';
        }
        XC_UTIL_Sobject.WrapperResult accountResult = XC_UTIL_Sobject.updateRecord(account);
        result.success = accountResult.success;
        result.resultMessage = (accountResult.success) ? Label.XC_CL_360AccountUpdate : accountResult.errorMessage;
        return result;
    }

           /**
     * @author Andrea Di Cicco
     * @description update main phone.
     * @param resultListString map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper  saveSecondaryPhone(String resultListString, String recordId){
        List<XC_LCC005_AccountCallToCommodity.FieldWrapper> resultList = (List<XC_LCC005_AccountCallToCommodity.FieldWrapper>) System.JSON.deserialize(resultListString, List<XC_LCC005_AccountCallToCommodity.FieldWrapper>.class);
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        result.success = true;
        Account account = new Account();
        account.id = recordId;
        String prefix;
        String phone;

        result.success = true;

        for(XC_LCC005_AccountCallToCommodity.FieldWrapper field : resultList){ 
            if(field.fieldKey == 'PhonePrefix'){
                account.XC_MainPhonePrefix__c = field.fieldValue;
            }else if(field.fieldKey == 'Phone'){
                account.XC_AccountMainPhone__c = field.fieldValue;
            }
        }

        if(account.XC_MainPhonePrefix__c == null ){
            account.XC_MainPhonePrefix__c = '+34';
        }

        XC_UTIL_Sobject.WrapperResult accountResult = XC_UTIL_Sobject.updateRecord(account);
        result.success = accountResult.success;
        result.resultMessage = (accountResult.success) ? Label.XC_CL_360AccountUpdate : accountResult.errorMessage;
        return result;
    }
}