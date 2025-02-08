/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation  23/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC002_NewLead_U – UTIL XC_LCC002_NewLead
*/
public without sharing class XC_LCC002_NewLead_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC002_NewLead');

    /** 
    * @description Checks for commercial visit. 
    * @param productCategory the product category
    * @return the boolean
    */
    public static Boolean hasCommercialVisit(String productCategory){
        List<XC_ProductCategoryOfInterest__c> listProdCat = XC_LCC002_NewLead_D.retrieveProductCategoriesFromNames(new List<String>{productCategory});
        if(!listProdCat.isEmpty()){
            return listProdCat[0].XC_CommercialVisit__c;
        }
        return false;
    }

    /** 
    * @description Insert legal entity consents
    * @param individualId
    * @param consentsLE
    * @param leadToUpdate
    * @return XC_UTIL_Sobject.WrapperResult
    */
    public static XC_UTIL_Sobject.WrapperResult insertLegalEntityConsents(Id individualId, String consentsLE, Lead leadToUpdate){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NewLead > insertLegalEntityConsents -> IndividualId = '+ individualId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLE = '+ consentsLE);
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = new List<XC_UTIL_Sobject.WrapperResult>();
        
        List<XC_LegalEntityConsent__c> existingConsents = [SELECT id,XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c =: individualId];
        Map<String,XC_LegalEntityConsent__c> leExistingConsent = new Map<String,XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c lec : existingConsents){
            leExistingConsent.put(lec.XC_LegalEntity__c,lec);
        }


        if(consentsLE!=null && !consentsLE.equals('null')){
            List<XC_LegalEntityConsent__c> consentsToInsert = new List<XC_LegalEntityConsent__c>();
            List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(consentsLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLEList = '+ consentsLEList);
            for(Object obj : consentsLEList){
                Map<String,Object> item = (Map<String,Object>)obj;
                String legalEntity = (String)item.get('XC_LegalEntity__c');
                if(legalEntity==null || legalEntity=='' || leExistingConsent.containsKey(legalEntity)){
                    continue;
                }
                XC_LegalEntityConsent__c newConsent = new XC_LegalEntityConsent__c();
                newConsent.XC_Individual__c = individualId;
                newConsent.XC_LegalEntity__c = legalEntity;
                newConsent.XC_LeCountry__c = String.valueOf(item.get('XC_LeCountry__c')); //'Spain'
                newConsent.XC_GiveDataToNew__c =  String.valueOf(item.get('XC_GiveDataTo__c'));
                newConsent.XC_UpdateAboutProducts__c =  String.valueOf(item.get('XC_KeepMeUpdateOnProducts__c'));
                newConsent.XC_ConsentToDataProcessing__c =  String.valueOf(item.get('XC_GiveConsentToDataProcessing__c'));
                newConsent.XC_CompanyConsentVersion__c =  String.valueOf(item.get('XC_CompanyConsentVersion__c'));
                newConsent.XC_MarketingConsentVersion__c =  String.valueOf(item.get('XC_MarketingConsentVersion__c'));
                newConsent.XC_ProfilingConsentVersion__c =  String.valueOf(item.get('XC_ProfilingConsentVersion__c'));
                /*newConsent.XC_GiveDataTo__c =  Boolean.valueOf(item.get('XC_GiveDataTo__c'));
                newConsent.XC_KeepMeUpdateOnProducts__c =  Boolean.valueOf(item.get('XC_KeepMeUpdateOnProducts__c'));
                newConsent.XC_GiveConsentToDataProcessing__c =  Boolean.valueOf(item.get('XC_GiveConsentToDataProcessing__c'));*/
                consentsToInsert.add(newConsent);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsToInsert1 = '+ consentsToInsert);
            dmlResult = XC_UTIL_DML.insertRecords(consentsToInsert);

            if(leadToUpdate != null && !consentsToInsert.isEmpty()){
                leadToUpdate.XC_MainLegalEntity__c = consentsToInsert[0].XC_LegalEntity__c;
                leadToUpdate.XC_SkipTriggerIndividual__c = true;
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ LE dmlResult List = '+ dmlResult);
        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ insertLegalEntityConsents - result = '+ result);

        return result;
    }

    /**
    * @description Populate List of Legal Entities
    * @param newLead - Lead 
    * @param consentsLE - String
    */
    public static void populateListOfLegalEntities(Lead newLead, String consentsLE){
        Set<String> setLE = new Set<String>();
        if(consentsLE!=null && !consentsLE.equals('null')){
            List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(consentsLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLEList = '+ consentsLEList);
            for(Object obj : consentsLEList){
                //Map<String,Object> item = (Map<String,Object>)obj;
                String legalEntity = (String) obj;//item.get('XC_LegalEntity__c');
                if(legalEntity==null || legalEntity==''){
                    continue;
                } else {
                    setLE.add(legalEntity);
                }
            }
        }
        List<String> listLE = new List<String>();
        listLE.addAll(setLE);
        //listLE.add(consentsLE);
        newLead.XC_ListOfLegalEntity__c = String.join(listLE, '|');
        newLead.XC_MainLegalEntity__c = listLE.get(0);
        newLead.XC_SkipTriggerIndividual__c = true;
    }

    /**
    * @description Populate name fields 
    * @param recordTypeId - String 
    * @param newLead - the new lead
    * @param fieldMap - the field map
    */
    public static void populateName(String recordTypeId, Lead newLead, Map<String,Object> fieldMap){
        if(XC_UTIL_Lead.isCondominium(recordTypeId)){
            newLead.FirstName = (String)fieldMap.get('FirstName');
            newLead.LastName = (String)fieldMap.get('LastName');
            newLead.Company = (String)fieldMap.get('XC_CondominiumName__c');
        }else if(XC_UTIL_Lead.isSoho(recordTypeId)|| XC_UTIL_Lead.isGlobalB2B(recordTypeId)|| XC_UTIL_Lead.isGlobalB2G(recordTypeId)){
            newLead.Company = (String)fieldMap.get('Company');
            newLead.FirstName = (String)fieldMap.get('FirstName');
            newLead.LastName = (String)fieldMap.get('LastName');
        }
    }

    /** 
* @description Populate Date fields. 
* @param fieldName
* @param fieldMap the field map
*/
    public static void populateDateFields(String fieldName, Map<String,Object> fieldMap) {
        if(XC_UTIL_Sobject.getFieldType('Lead', fieldName) == Schema.DisplayType.Date && fieldMap.containsKey(fieldName)){
            String dateField = String.valueOf(fieldMap.get(fieldName));
            if(!String.isBlank(dateField)){
                Date d = XC_UTIL_Sobject.stringToDate(dateField);
                fieldMap.put(fieldName, d);
            }
        }
    }

    /**
    * @description create Personal Document 
    * @param newLead
    * @return XC_UTIL_Sobject.WrapperResult
    */
    /*public static XC_UTIL_Sobject.WrapperResult insertDocuments(Lead newLead){
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.success = true;
        XC_PersonalDocument__c personalD = new XC_PersonalDocument__c();
        personalD.XC_Lead__c = newLead.Id;
        if(newLead.XC_NIE_expedition_date__c!=null){
            personalD.XC_ReleaseDate__c = newLead.XC_NIE_expedition_date__c;
        }
        if(newLead.XC_NIE_expiration_date__c!=null){
            personalD.XC_ExpirationDate__c = newLead.XC_NIE_expiration_date__c;
        }
        if(newLead.XC_DocumentCountry__c!=null){
            personalD.XC_Country__c = newLead.XC_DocumentCountry__c;
        }
        if(newLead.XC_DocumentType__c!=null && newLead.XC_DocumentNumber__c!=null ){
            personalD.XC_DocumentType__c = newLead.XC_DocumentType__c;
            personalD.XC_DocumentNumber__c = newLead.XC_DocumentNumber__c;
            personalD.XC_MainDocument__c = true;
            wr = XC_UTIL_Sobject.insertRecord(personalD);
        } 
        return wr;
    }  */

    /**
    * @description create Address
    * @param newLead
    * @return XC_UTIL_Sobject.WrapperResult
    */
    public static XC_UTIL_Sobject.WrapperResult insertAddress(Lead newLead){
        XC_UTIL_Address.AddressWrapper addresWR = XC_UTIL_Address.createWrapperFromLead(newLead);
        return XC_UTIL_Address.insertAddress(addresWR);
    }

    /**
     * @description Associate social persona with lead. 
     * @param leadId the lead id
     * @param socialPersonaId the social persona id
     *@return
     */
    public static XC_UTIL_Sobject.WrapperResult associateSocialPersonaWithLead(String leadId, String socialPersonaId){
        XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
        result.success = true;
        if(leadId != null && socialPersonaId != null){
            SocialPersona sp = new SocialPersona(Id=socialPersonaId);
            sp.XC_LeadId__c = leadId;
            result = XC_UTIL_Sobject.updateRecord(sp);
        }
        return result;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Populate Adress
    * @param newLead 
    * @param addressFields 
    * @return the lead
    */
    public static Lead populateAddress(Lead newLead, String addressFields) {

        if(addressFields==null || addressFields.equals('null')){
            return newLead;
        }

        Map<String,Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressFields);
        newLead.XC_Country__c = (String) addressMap.get('country');

        if( addressMap.get('streetTypeText')!=null && addressMap.get('streetTypeText')!=''){
            newLead.XC_StreetTypeText__c = (String) addressMap.get('streetTypeText');

        } else {
            newLead.XC_StreetType__c = (String) addressMap.get('streetType');

        }

        newLead.XC_Address__c = (String) addressMap.get('address');
        newLead.XC_StreetNumber__c =  (String) addressMap.get('streetNumber');
        newLead.XC_Door__c = (String) addressMap.get('door');
        newLead.XC_Floor__c = (String) addressMap.get('floor');
        newLead.XC_Stair__c = (String) addressMap.get('stair');
        newLead.XC_ZipCode__c = (String) addressMap.get('postalCode');
        newLead.XC_City__c   = (String) addressMap.get('city');
        newLead.XC_Province__c   = (String) addressMap.get('province');
        newLead.XC_Category__c   = (String) addressMap.get('category');
        newLead.XC_Municipality__c   = (String) addressMap.get('municipality');
        newLead.XC_InstallationAddress__c = true;
        newLead.XC_DeliveryAddress__c = true;
        newLead.XC_BillingAddress__c = true;
        newLead.XC_AddressLeadNotValidated__c = !Boolean.valueOf(addressMap.get('validate'));

        newLead.XC_GasCUPS__c   = (String) addressMap.get('gas');
        newLead.XC_ElectricCUPS__c   = (String) addressMap.get('electric');

        newLead.XC_ClarificatorType__c = (String) addressMap.get('clarifType');
        newLead.XC_ClarificatorValue__c = (String) addressMap.get('clarifValue');

        newLead.XC_Region__c = (String) addressMap.get('region');

        if(addressMap.get('validatedCups')!=null){
            newLead.XC_AddressValidatedCUPS__c = Boolean.valueOf(addressMap.get('validatedCups'));
        } else {
            newLead.XC_AddressValidatedCUPS__c = false;
        }

        return newLead;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Remove Prefix
    * @param fieldMap
    */
    public static void removePrefix( Map<String,Object> fieldMap) {
        if((fieldMap.get('XC_PhonePrefix__c') != null || fieldMap.get('XC_PhonePrefix__c') !='') && (fieldMap.get('XC_LeadPhone__c')==null  || fieldMap.get('XC_LeadPhone__c')=='')){
            fieldMap.remove('XC_PhonePrefix__c');
        }
        if((fieldMap.get('XC_MobilePrefix__c') != null || fieldMap.get('XC_MobilePrefix__c') !='' ) && (fieldMap.get('XC_LeadMobile__c')==null || fieldMap.get('XC_LeadMobile__c')=='')){
            fieldMap.remove('XC_MobilePrefix__c');
        }

        //fieldMap.remove('XC_MobilePrefix__c');

    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Remove ReleaseDate
    * @param fieldMap
    */
    public static void removeReleaseDate( Map<String,Object> fieldMap) {
        if(fieldMap.get('XC_DocumentType__c')=='NIF'){
            fieldMap.remove('XC_NIE_expedition_date__c');
        }
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Remove Adress
    * @param fieldMap
    */
    public static void removeAddress( Map<String,Object> fieldMap) {
        fieldMap.remove('XC_StreetType__c');
        fieldMap.remove('XC_Province__c');
        fieldMap.remove('XC_Category__c');
        fieldMap.remove('XC_StreetNumber__c');
        fieldMap.remove('XC_City__c');
        fieldMap.remove('XC_AddressProvince__c');
        fieldMap.remove('XC_Address__c');
        fieldMap.remove('XC_PostalCode__c');
        fieldMap.remove('XC_AddressCountry__c');
        fieldMap.remove('XC_Door__c');
        fieldMap.remove('XC_Stair__c');
        fieldMap.remove('XC_Floor__c');
        fieldMap.remove('XC_Municipality__c');
        fieldMap.remove('XC_InstallationAddress__c');
        fieldMap.remove('XC_BillingAddress__c');
        fieldMap.remove('XC_DeliveryAddress__c');

    }

    /**
    * @description Populate Case Lookup from Social Persona
    * @param newLead - Lead
    * @param mapLead - Map<String,Object>
*/
    public static void populateCaseLookup(Lead newLead, Map<String,Object> mapLead){
        String socialPersonaId = (String) mapLead.get('socialPersonaId');
        if(!String.isBlank(socialPersonaId)){
            List<SocialPersona> listSocialPersona = new List<SocialPersona>([SELECT ParentId FROM SocialPersona WHERE Id = :socialPersonaId]);
            if(!listSocialPersona.isEmpty()) {
                List<SocialPost> listSocialPost = new List<SocialPost>([SELECT ParentId FROM SocialPost WHERE Id = :listSocialPersona[0].ParentId]);
                if(!listSocialPost.isEmpty()) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Case id from SocialPost -> '+ listSocialPost[0].ParentId);
                    newLead.XC_Case__c = listSocialPost[0].ParentId;
                }
            }
        }
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Populate Social Persona
    * @param newLead 
    * @param mapLead
    */

    public static void populateSocialPersona(Lead newLead, Map<String,Object> mapLead){
        String socialPersonaId = (String) mapLead.get('socialPersonaId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ socialPersonaId -> '+ socialPersonaId);
        if(!String.isBlank(socialPersonaId)){
            newLead.XC_SocialPersonaId__c = socialPersonaId;
        }
    }

    /**
     * @description Create Legal Entity Consents
     * @param individualId the individual Id 
     * @param consentsLE legal entity consentsù
     * @return dml results
     */
    public static XC_UTIL_Sobject.WrapperResult insertLegalEntityConsents(Id individualId, String consentsLE){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NewLead > insertLegalEntityConsents -> IndividualId = '+ individualId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLE = '+ consentsLE);
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = new List<XC_UTIL_Sobject.WrapperResult>();
        List<XC_LegalEntityConsent__c> existingConsents = [SELECT id,XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c =: individualId];
        Map<String,XC_LegalEntityConsent__c> leExistingConsent = new Map<String,XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c lec : existingConsents){
            leExistingConsent.put(lec.XC_LegalEntity__c,lec);
        }
        
        if(consentsLE!=null && !consentsLE.equals('null')){
            List<XC_LegalEntityConsent__c> consentsToInsert = new List<XC_LegalEntityConsent__c>();
            List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(consentsLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLEList = '+ consentsLEList);
            for(Object obj : consentsLEList){
                Map<String,Object> item = (Map<String,Object>)obj;
                String legalEntity = (String)item.get('XC_LegalEntity__c');
                if(legalEntity==null || legalEntity=='' || leExistingConsent.containsKey(legalEntity)){
                    continue;
                }
                XC_LegalEntityConsent__c newConsent = new XC_LegalEntityConsent__c();
                newConsent.XC_Individual__c = individualId;
                newConsent.XC_LegalEntity__c = legalEntity;
                newConsent.XC_LeCountry__c = String.valueOf(item.get('XC_LeCountry__c')); //XC_UTIL_User.getCountryFromUser(UserInfo.getUserId());
                newConsent.XC_GiveDataToNew__c =  String.valueOf(item.get('XC_GiveDataTo__c'));
                newConsent.XC_UpdateAboutProducts__c =  String.valueOf(item.get('XC_KeepMeUpdateOnProducts__c'));
                newConsent.XC_ConsentToDataProcessing__c =  String.valueOf(item.get('XC_GiveConsentToDataProcessing__c'));
                newConsent.XC_CompanyConsentVersion__c =  String.valueOf(item.get('XC_CompanyConsentVersion__c'));
                newConsent.XC_MarketingConsentVersion__c =  String.valueOf(item.get('XC_MarketingConsentVersion__c'));
                newConsent.XC_ProfilingConsentVersion__c =  String.valueOf(item.get('XC_ProfilingConsentVersion__c'));
                /*newConsent.XC_GiveDataTo__c =  Boolean.valueOf(item.get('XC_GiveDataTo__c'));
                newConsent.XC_KeepMeUpdateOnProducts__c =  Boolean.valueOf(item.get('XC_KeepMeUpdateOnProducts__c'));
                newConsent.XC_GiveConsentToDataProcessing__c =  Boolean.valueOf(item.get('XC_GiveConsentToDataProcessing__c'));*/
                consentsToInsert.add(newConsent);
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsToInsert2 = '+ consentsToInsert);
            dmlResult = XC_UTIL_DML.insertRecords(consentsToInsert);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ LE dmlResult List = '+ dmlResult);
        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ insertLegalEntityConsents - result = '+ result);
        return result;
    }
}