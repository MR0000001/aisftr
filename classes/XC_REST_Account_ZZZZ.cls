/**
 * The Class XC_REST_Account_ZZZZ.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 23/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 */


public without sharing class XC_REST_Account_ZZZZ {

    
    /**
     * CheckLanguageForAccount.
     *
     * @param preferenceLanguage the preference Language
     * @return the language
     * @description Method to check the preference Language
     */
    public static String checkLanguageForAccount(String preferenceLanguage) {

        String language;
        if(preferenceLanguage != null ) {
            List<Schema.PicklistEntry> picklist = Schema.Account.XC_Preference_Language__c.getDescribe().getPicklistValues();
            Set<String> picklistValues = new Set<String>();
            for(Schema.PicklistEntry pe : picklist) {
                if(pe.isActive()) {
                    picklistValues.add(pe.getValue());
                }
            }
            language = (picklistValues.contains(preferenceLanguage)) ? preferenceLanguage : 'English';
        }

        return language;
    }


    /**
     * CreateContactFromWrapper.
     *
     * @param contact the contact wrapper
     * @param accountId the account id
     * @param recordType the recordType
     * @return the contact
     * @description Method to populate Contact fields from WrapperRequest
     */
    public static Contact createContactFromWrapper(XC_UTIL_Account.ContactIFWrapper contact, Map<String, String> infoParameters, String recordType, Map<Id,String> conLegal) {

        Contact contactFromWrapper = new Contact();
        String accountId = infoParameters.get('accountId');
        String method = infoParameters.get('method');
        String country = infoParameters.get('country');
        String stream = infoParameters.get('stream');
        System.debug('@@@ NM stream2: ' + stream);

        XC_REST_Account_W.WrapperRequest wrReq = (XC_REST_Account_W.WrapperRequest) JSON.deserialize(infoParameters.get('wrReq'), XC_REST_Account_W.WrapperRequest.class);
        contact.PreferenceLanguage = (!String.isBlank(contact.PreferenceLanguage)) ? contact.PreferenceLanguage : (!String.isBlank(wrReq.account.PreferenceLanguage)) ? wrreq.account.PreferenceLanguage : infoParameters.get('Preferredlanguageofcontact'); // fix 02/07/2020
        String language = XC_REST_Account_ZZZZ.checkLanguageForContact(contact.PreferenceLanguage);

        String mainPhonePrefix = (String.isNotBlank(contact.MainPhonePrefix)) ? contact.MainPhonePrefix : contact.MobilePhonePrefix;
        String mainPhone = (String.isNotBlank(contact.MainPhone)) ? contact.MainPhone : contact.MobilePhone;

        Map<String, Object> mapContactWrapper = new Map<String,Object>{'Id' => contact.ContactID,
                                                                        'AccountId' =>  accountId,
                                                                        'LastName' => contact.LastName,
                                                                        'FirstName' => contact.FirstName,
                                                                        'Salutation' => contact.Salutation,
                                                                        'Email' => contact.Email,
                                                                        'XC_MobilePrefix__c' => contact.PhonePrefix,
                                                                        'XC_ContactMobile__c' => contact.Phone,
                                                                        'XC_PhonePrefix__c' => mainPhonePrefix, 
                                                                        'XC_ContactPhone__c' => mainPhone,
                                                                        'XC_PrimaryContact__c' => contact.PrimaryContact,
                                                                        'Birthdate' => contact.BirthDate,
                                                                        'XC_Preferredlanguageofcontact__c' => language,
                                                                        'XC_HourToBeRecontacted__c' => contact.ContactPreferredTime,
                                                                        'XC_Nationality__c' => contact.Nationality,
                                                                        'XC_External_ID__c' => contact.ExternalLoginId,
                                                                        'XC_SkipTriggerIndividual__c' => true,
                                                                        'XC_Birth_Place__c' => contact.BirthPlace,
                                                                        'XC_Birth_Country__c' => contact.BirthCountry,
                                                                        'XC_Birth_Province__c' => contact.BirthProvince,
                                                                        'XC_Citizenship__c' => contact.Citizenship,
                                                                        'XC_Sex__c' => contact.Sex,
                                                                        'Country__c' =>  contact.Country,
                                                                        'XC_Segment__c' => stream};
        
        if(recordType != null){
            //contactFromWrapper.RecordTypeID =  (recordType == 'Small Business') ? Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Soho').getRecordTypeId() : Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
            String typeName = (stream != 'B2C') ? stream : ((recordType == 'Small Business') ? 'Soho' : recordType);
            typeName = '%' + typeName + '%';
            Map<Id,RecordType> rec = new Map<Id,RecordType>([SELECT Id, SobjectType, Name FROM RecordType WHERE DeveloperName like :typeName AND SobjectType = 'Contact']);
            contactFromWrapper.RecordTypeID = rec.values()[0].Id;
            System.debug('@@@ Con RT: ' + rec.values()[0].Name);
        }

        for(String key : mapContactWrapper.keySet()){
            if(mapContactWrapper.get(key) != null){
                contactFromWrapper.put(key, mapContactWrapper.get(key));
            }
        }

        manageContactGDPR(contactFromWrapper, contact, conLegal);
        
        return contactFromWrapper;  
    }

    
    /**
     * CheckLanguageForContact.
     *
     * @param preferenceLanguage the preference Language
     * @return the language
     * @description Method to check the preference Language
    */
    public static String checkLanguageForContact(String preferenceLanguage) {

        String language;
        if(preferenceLanguage != null ) {
            List<Schema.PicklistEntry> picklist = Schema.Contact.XC_Preferredlanguageofcontact__c.getDescribe().getPicklistValues();
            Set<String> picklistValues = new Set<String>();
            for(Schema.PicklistEntry pe : picklist) {
                if(pe.isActive()) {
                    picklistValues.add(pe.getValue());
                }
            }
            language = (picklistValues.contains(preferenceLanguage)) ? preferenceLanguage : 'English';
        }

        return language;
    }


    /**
    * @param contactFromWrapper - Contact
    * @param contact - XC_UTIL_Account.ContactIFWrapper 
    * @description Method to populate Contact GDPR
    */
    public static void manageContactGDPR(Contact contactFromWrapper, XC_UTIL_Account.ContactIFWrapper contact, Map<Id,String> conLegal){

        if(contact.GDPR != null){
                        
            contactFromWrapper.XC_ThirdPartiesConsentVersion__c = contact.gdpr.VersionConsentThirdParty;
            //contactFromWrapper.ConsentThirdPartyDate = contact.gdpr.ConsentThirdPartyDate;
            contactFromWrapper.XC_RobinsonCustomer__c = XC_UTIL_Integration.convertFromStringToBoolean(contact.gdpr.RobinsonCustomer); 
            contactFromWrapper.XC_DoNotDisturb__c = XC_UTIL_Integration.convertFromStringToBoolean(contact.gdpr.DoNotDisturb); 

            // fix 27/08/2019 tbd **** 

            if (String.isBlank(contact.ContactID)) {
                if(contact.gdpr.GiveDataToThirdParties != null){ 
                    contactFromWrapper.XC_GiveDataToThirdParties__c = XC_UTIL_Integration_U.convertFromStringToPicklist(contact.gdpr.GiveDataToThirdParties);
                }
                if(contact.GDPR.LegalEntity != null){
                    contactFromWrapper.XC_GiveDataToNew__c = XC_UTIL_Integration_U.convertFromStringToPicklist(contact.GDPR.LegalEntity[0].GiveDataToLegalEntity);
                    contactFromWrapper.XC_MainLegalEntity__c = contact.GDPR.LegalEntity[0].LegalEntity;
                    contactFromWrapper.XC_CountryLegalEntity__c = XC_UTIL_Integration_U.getCountryFromLegalEntity(contact.GDPR.LegalEntity[0].LegalEntity);
                }


            } else {
                String legal = conLegal.get(contact.ContactID);

                for(XC_UTIL_Account.LegalEntityWrapper wrLegal : contact.GDPR.LegalEntity){
                    if(legal == wrLegal.LegalEntity){
                        
                        if(contact.gdpr.GiveDataToThirdParties != null){ 
                            contactFromWrapper.XC_GiveDataToThirdParties__c = XC_UTIL_Integration_U.convertFromStringToPicklist(contact.gdpr.GiveDataToThirdParties);
                        }
                        if(contact.GDPR.LegalEntity != null){
                            contactFromWrapper.XC_GiveDataToNew__c = XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegal.GiveDataToLegalEntity);
                            contactFromWrapper.XC_CountryLegalEntity__c = XC_UTIL_Integration_U.getCountryFromLegalEntity(wrLegal.LegalEntity);
                        }

                    }
                }

                

            }
            
        }
    }
    

    /**
     * CreateAddressFromWrapper.
     *
     * @param accountID the account ID
     * @param wr the Address wrapper
     * @return the Address
     * @description Method to create Address from wrapper
     */
    public static XC_Address__c createAddressFromWrapper(Map<String,String> infoParameters, XC_UTIL_Address.AddressWrapper wr) {
        
        String accountID = infoParameters.get('accountId');
        String accountType = infoParameters.get('accountType');
        XC_Address__c address = new XC_Address__c();
        Boolean isPartner = (accountType == 'Partner') ? true : false;
        String recordTypeId;
        if(wr.AddressID == null){
            recordTypeId = XC_UTIL_Address.getAddressRecordTypeByCountry(wr.Country.toUpperCase(), isPartner); 
        }
       
        Map<Id, XC_CM_AddressTranscoder__mdt> listAddressToTranscod = new Map<Id, XC_CM_AddressTranscoder__mdt>([SELECT Id, XC_AddressProvince__c, XC_AddressProvinceTranscoded__c, XC_Country__c, XC_AddressCountryTranscoded__c FROM XC_CM_AddressTranscoder__mdt WHERE XC_Country__c =: wr.Country]); 
        for(XC_CM_AddressTranscoder__mdt addrTransdecoder : listAddressToTranscod.values()) {
            if(addrTransdecoder.XC_AddressProvince__c == wr.Province && String.isNotBlank(addrTransdecoder.XC_AddressProvinceTranscoded__c)) {
                wr.Province = addrTransdecoder.XC_AddressProvinceTranscoded__c;
            }
            if(addrTransdecoder.XC_Country__c == wr.Country && String.isNotBlank(addrTransdecoder.XC_AddressCountryTranscoded__c)) {
                wr.Country = addrTransdecoder.XC_AddressCountryTranscoded__c;
            }
        }
        
        Map<String, Object> mapAddressWrapper = new Map<String,Object>{
            'XC_Category__c' => wr.Category,
            'XC_StreetTypeText__c' => wr.StreetType,
            'XC_Address__c' => wr.Address,
            'XC_StreetNumber__c' => wr.StreetNumber,
            'XC_PostalCode__c' => wr.ZipCode,
            'XC_City__c' => wr.City,
            'XC_Stair__c' => wr.Stair,
            'XC_AddressCountry__c' => wr.Country,
            'XC_Floor__c' => wr.Floor,
            'XC_Door__c' => wr.Door,
            'XC_AddressProvince__c' => wr.Province,
            'XC_Stair__c' => wr.Stair,
            'XC_DeliveryAddress__c' => wr.DeliveryAddress,
            'XC_BillingAddress__c' => wr.BillingAddress,
            'XC_InstallationAddress__c' => wr.InstallationAddress,
            'Id' => wr.AddressID,
            'XC_Account__c' => accountID,
            'RecordTypeId' => recordTypeId,
            'XC_Note__c' => wr.Note,
            'XC_Municipality__c' => wr.Municipality,
            'XC_ClarificatorType__c' => wr.ClarifierType, 
            'XC_ClarificatorValue__c' => wr.ClarifierValue,
            'XC_Region__c' => wr.Region,
            'XC_SkipDuplication__c' => wr.SkipDuplication
        };

        for(String key : mapAddressWrapper.keySet()){
            if(mapAddressWrapper.get(key) != null){
                address.put(key, mapAddressWrapper.get(key));
            }
        }

        if(mapAddressWrapper.get('XC_SkipDuplication__c') != null){
            if(mapAddressWrapper.get('XC_SkipDuplication__c') == true){
                address.put('XC_isGuest__c', 'true');
            } else if(mapAddressWrapper.get('XC_SkipDuplication__c') == false){
                address.put('XC_isGuest__c', 'false');
            }
        }

        //GDB POS FIX B2B
        System.debug('## PointOfService wrapper list: '+wr.PointOfService);
        System.debug('## clientSystem: '+infoParameters.get('clientSystem'));
        if(infoParameters.get('clientSystem')=='CommodityItalyB2B'||infoParameters.get('clientSystem')=='MKChile'||infoParameters.get('clientSystem')=='MKColombia' || ('B2B'.equalsIgnoreCase(infoParameters.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infoParameters.get('clientSystem'))) || infoParameters.get('clientSystem')=='ThirdPartyB2C' ){//[2021-12-27 :: TP :: Third Party Billing :: Logic for ThirdParty]  //DCR 25112021 - CR-NR2063
        //Il primo POS lo setto sul primo address
            if(wr.PointOfService != null && !wr.PointOfService.isEmpty()){
                if(wr.PointOfService[0].POSType == 'Light'){
                    address.put('XC_ElectricCUPS__c', wr.PointOfService[0].POS);
                
                } else if(wr.PointOfService[0].POSType == 'Gas'){
                    address.put('XC_GasCUPS__c', wr.PointOfService[0].POS);
                }
            }

            if(infoParameters.get('clientSystem')=='MKChile'||infoParameters.get('clientSystem')=='MKColombia'){
                return address;
            }

            //Per i POS successivi al primo creo nuovi address clonati
            List<XC_Address__c> posAdd = new List<XC_Address__c>();
            if(wr.PointOfService !=null){
                for (Integer i=1; i<wr.PointOfService.size(); i++) {
                    
                    XC_Address__c addressClone = new XC_Address__c();
                    for(String key : mapAddressWrapper.keySet()){
                        if(mapAddressWrapper.get(key) != null){
                            addressClone.put(key, mapAddressWrapper.get(key));
                        }
                    }

                    System.debug('## POS: '+wr.PointOfService[i].POS);
                    if(wr.PointOfService[i].POSType == 'Light'){
                        addressClone.put('XC_ElectricCUPS__c', wr.PointOfService[i].POS);
                    
                    } else if(wr.PointOfService[i].POSType == 'Gas'){
                        addressClone.put('XC_GasCUPS__c', wr.PointOfService[i].POS);
                    }
                    posAdd.add(addressClone);
                }
            }
            if(!posAdd.isEmpty()) {
                XC_UTIL_Sobject.insertListRecords(posAdd);
            }
        }


        return address;
    }


    /**
    * CreatePosFromWrapper.
    *
    * @param addressID the address ID
    * @param wrPos the PointOfService Wrapper  
    * @return the pointOfService
    * @description Method to create PointOfService from wrapper
    */
    public static XC_PointOfService__c createPosFromWrapper(String addressID, XC_UTIL_Address.PoSWrapper wrPos) {
        
        Map<String, Object> posParameters = new Map<String, Object>{
            'Id' => wrPos.POSID,
            'XC_Type__c' => wrPos.POSType,
            'Name' => wrPos.POS
        };
                
        if(String.isBlank(wrPos.POSID)){
            posParameters.put('XC_Address__c', addressID);
            posParameters.put('Id', null);
        }

        XC_PointOfService__c pos = new XC_PointOfService__c();
        for(String field : posParameters.keySet()) {
            if(posParameters.get(field) != null) {
                pos.put(field, posParameters.get(field));
            }
        }

        return pos;
    }


    /**
     * CreateLegalEntityFromWrapper.
     *
     * @param wrLegalEn the Legal Entity Wrapper
     * @param individualId the individual Id 
     * @return the LegalEntity
     * @description Method to populate legalEntity fields from WrapperRequest
     */        
    public static XC_LegalEntityConsent__c createLegalEntityFromWrapper(XC_UTIL_Account.LegalEntityWrapper wrLegalEn, String individualId, String country) {

        Map<String, Object> legalEntityParameters = new Map<String, Object>{
            'XC_LegalEntity__c' => wrLegalEn.LegalEntity,
            'XC_GiveDataToNew__c' => XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegalEn.GiveDataToLegalEntity),
            'XC_MarketingConsent__c' => XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegalEn.GiveDataForMarketing),
            'XC_ProfilingConsent__c' => XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegalEn.GiveDataForProfiling),
            'XC_ConsentToDataProcessing__c' => XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegalEn.GiveDataForProfiling),
            'XC_IndividualId__c' => individualId,
            'XC_Individual__c' => individualId,
            'XC_LeCountry__c' => wrLegalEn.Country == null ? country : wrLegalEn.Country,
            'XC_CompanyConsentVersion__c' => wrLegalEn.VersionConsentCompany,
            //'' => ConsentCompanyDate,
            'XC_MarketingConsentVersion__c' => wrLegalEn.VersionConsentMarketing,
            'XC_CollectionDateMarketing__c' => wrLegalEn.ConsentMarketingDate,
            'XC_LECollectedMarketingConsents__c' => wrLegalEn.LegalEntity,
            'XC_ProfilingConsentVersion__c' => wrLegalEn.VersionConsentForProfiling,
            'XC_CollectionDateProfiling__c' => wrLegalEn.ConsentProfilingDate,
             'XC_LECollectedProfilingConsents__c' => wrLegalEn.LegalEntity,
             //'' => PreferredContactMethod
             //API 2.22
             'XC_NotCustomerConsent__c' => XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegalEn.GiveDataForNotCustomer),
             'XC_ThirdProductsMarketingConsent__c' => XC_UTIL_Integration_U.convertFromStringToPicklist(wrLegalEn.GiveDataForThirdProductMarketing),
             'XC_NotCustomerConsentVersion__c' => wrLegalEn.VersionConsentNotCustomer,
             'XC_CollectionDateNotCustomer__c' => wrLegalEn.ConsentNotCustomerDate,
             'XC_ThirdProductsMarketingConsentVersion__c' => wrLegalEn.VersionConsentThirdProductMarketing,
             'XC_CollectionDateThirdProductsMarketing__c' => wrLegalEn.ConsentThirdProductMarketingDate
        };
        
        XC_LegalEntityConsent__c legalEntityFromWrapper = new XC_LegalEntityConsent__c ();
        for(String field : legalEntityParameters.keySet()) {
            if(legalEntityParameters.get(field) != null) {
                legalEntityFromWrapper.put(field, legalEntityParameters.get(field));
            }
        }
                        
        return legalEntityFromWrapper;  
    }

}