/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation  23/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC003_NewAccount_U – UTIL XC_LCC003_NewAccount
*/

public without sharing class XC_LCC003_NewAccount_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC003_NewAccount');

    /**
     * @description Populate fields. 
     * @param newAccount the new account
     * @param fieldMap the field map
     */
    public static void populateFields(Account newAccount, Map<String,Object> fieldMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT populateFields');
        removeDirtyFields(newAccount,fieldMap);
        List<String> fieldList = XC_UTIL_Sobject.getListAllFields('Account');
        List<String> fieldListA = new List<String>();
        List<String> fieldListB = new List<String>();
        for(Integer i=0;i<fieldList.size();i++){
            if(i<(fieldList.size())/2){
                fieldListA.add(fieldList[i]);
            }else{
                fieldListB.add(fieldList[i]);
            }
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'fieldMap->' + fieldMap);
        for(String fieldName : fieldMap.keySet()){
            if(fieldListA.contains(fieldName)){
                populateDateFields(fieldName, fieldMap);
                if(fieldMap.get(fieldName) != null){
                    manageFields(newAccount, fieldMap, fieldName);
                }
            }else if(fieldListB.contains(fieldName)){
                populateDateFields(fieldName, fieldMap);
                if(fieldMap.get(fieldName) != null){
                    manageFields(newAccount, fieldMap, fieldName);
                }
            }
        }
    }

    /**
    * @description Remove Dirty fields.
    * @param newAccount the new account
    * @param fieldMap the field map
    */
    public static void removeDirtyFields(Account newAccount, Map<String,Object> fieldMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT removeDirtyFields');
        // fieldMap.remove('XC_FirstName__c');
        //fieldMap.remove('XC_LastName__c');
        fieldMap.remove('XC_StreetType__c');
        fieldMap.remove('XC_Province__c');
        fieldMap.remove('XC_Category__c');
        removePrefix(fieldMap);
        removeReleaseDate(fieldMap);


    }

    /**
* @description Remove Prefix
* @param fieldMap
*/
    private static void removePrefix(Map<String,Object> fieldMap) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT removePrefix');

        if(fieldMap.get('XC_AccountPhonePrefix__c')!= null && (fieldMap.get('XC_AccountPhone__c')==null || fieldMap.get('XC_AccountPhone__c')=='')){
            fieldMap.remove('XC_AccountPhonePrefix__c');
        }
        if(fieldMap.get('XC_MainPhonePrefix__c')!= null && (fieldMap.get('XC_AccountMainPhone__c')==null || fieldMap.get('XC_AccountMainPhone__c')=='')){
            fieldMap.remove('XC_MainPhonePrefix__c');
        }

        //fieldMap.remove('XC_MobilePrefix__c');

    }
/**
* @description Remove ReleaseDate
* @param fieldMap
*/
    public static void removeReleaseDate( Map<String,Object> fieldMap) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT removeReleaseDate');
        if(fieldMap.get('IdentityType__c')=='NIF'){
            fieldMap.remove('XC_NIE_expedition_date__c');
        }
    }


    private static void manageFields(Account newAccount, Map<String,Object> fieldMap, String fieldName){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT manageFields');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CAMPO ='+ fieldName) ;
        //[ BEGIN, arjun.raoh@accenture.com, 05/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        List<String> currencyPercentageFields = new List<String>{'XC_Una_tantum_member_fee__c', 'XC_Annual_member_fee__c', 'XC_Fix_part_sharing_monthly__c', 'XC_MISE_incentive__c', 'XC_Arera_incentive__c', 'XC_Local_price_incentive__c'};
        //[ END, arjun.raoh@accenture.com, 05/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        if(XC_UTIL_Sobject.isFieldBoolean('Account', fieldName)){
            newAccount.put(fieldName, Boolean.valueOf(fieldMap.get(fieldName)));
        }
        //[ BEGIN, arjun.raoh@accenture.com, 24/11/2021, Enel X - NR2041 - Energy Communities, FT3-2021 ]
        else if(XC_UTIL_Sobject.isFieldDouble('Account', fieldName)){
            newAccount.put(fieldName, Double.valueOf(fieldMap.get(fieldName)));
        }
        //[ END, arjun.raoh@accenture.com, 24/11/2021, Enel X - NR2041 - Energy Communities, FT3-2021 ]
        //[ BEGIN, arjun.raoh@accenture.com, 05/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        else if(currencyPercentageFields.contains(fieldName)){
            newAccount.put(fieldName, Double.valueOf(fieldMap.get(fieldName)));
        }
        //[ END, arjun.raoh@accenture.com, 05/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        else{
            if(fieldMap.get(fieldName) instanceof Map<String,Object>){

                newAccount.put(fieldName, ((Map<String,Object>)(fieldMap.get(fieldName))).get('value'));
            } else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'CAMPO ='+fieldName+ ' valore ='+fieldMap.get(fieldName));
                newAccount.put(fieldName, fieldMap.get(fieldName));
            }
        }
    }

    /**
     * @description create Personal Document 
     * @param newAccount
     * @return XC_UTIL_Sobject.WrapperResult
     */
    public static XC_UTIL_Sobject.WrapperResult insertDocuments(Account newAccount){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT insertDocuments');
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.success = true;
        return wr;
    }

    /**
     * @description Populate Date fields. 
     * @param fieldName
     * @param fieldMap the field map
     */
    public static void populateDateFields(String fieldName, Map<String,Object> fieldMap) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT populateDateFields');
        if(XC_UTIL_Sobject.getFieldType('Account', fieldName) == Schema.DisplayType.Date){
            String dateField = '';
            if(fieldMap.get(fieldName) instanceof Map<String,Object>){
                Map<String,Object> dateMap = (Map<String,Object>)(fieldMap.get(fieldName));
                dateField = (String)dateMap.get('value');
            } else{
                dateField = (String)fieldMap.get(fieldName);
            }
            if(!String.isBlank(dateField)){
                Date d = XC_UTIL_Sobject.StringToDate(dateField);
                fieldMap.put(fieldName, d);
            }
        }
    }

    /**
     * @description create Address
     * @param newAccount
     * @param inputData
     * @param recordTypeId
     * @return XC_UTIL_Sobject.WrapperResult
     */
    //public static XC_UTIL_Sobject.WrapperResult insertAddress(Account newAccount, String addressFields, String recordTypeId){
    public static XC_UTIL_Sobject.WrapperResult insertAddress(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, String recordTypeId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT insertAddress');
        XC_UTIL_Sobject.WrapperResult addressResult = new XC_UTIL_Sobject.WrapperResult();
        addressResult.success = true;
        XC_UTIL_Address.AddressWrapper addressWrapper =  new XC_UTIL_Address.AddressWrapper();
        String addressFields = inputData.addressFields;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@insertAddress - addressFields@@@' + addressFields);

        if(addressFields==null || addressFields==''|| addressFields=='null'){
            return addressResult;
        }

        Map<String,Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressFields);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@addressMap@@@' + addressFields);
        if(XC_UTIL_Account.isPartner(recordTypeId)){
            addressWrapper.isPartner = true;
        }
        else{
            addressWrapper.isPartner = false;
        }
        addressWrapper.accountId = newAccount.Id;
        addressWrapper.addressValid = inputData.addressNoValidate;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'addressWrapper ='+addressWrapper);
        mapAddressFields(addressWrapper, addressMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'addressWrapper ='+addressWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Country of new Address ---> ' + addressWrapper.country);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Province of new Address ---> ' + addressWrapper.province);

        if(!String.isBlank(addressWrapper.country)){
            addressResult = XC_UTIL_Address.insertAddress(addressWrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@addressResult@@@' + addressResult);
        }
        return addressResult;
    }

    private static void mapAddressFields(XC_UTIL_Address.AddressWrapper addressWrapper, Map<String,Object> addressMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT mapAddressFields');
        addressWrapper.category = (String) addressMap.get('category');

        if( addressMap.get('streetTypeText')!=null && addressMap.get('streetTypeText')!=''){
            addressWrapper.streetTypeText = (String) addressMap.get('streetTypeText');
        }else{
            addressWrapper.streetType = (String) addressMap.get('streetType');
        }

        addressWrapper.address =(String) addressMap.get('address');
        addressWrapper.zipCode = (String) addressMap.get('postalCode');
        addressWrapper.province = (String) addressMap.get('province');
        addressWrapper.city = (String) addressMap.get('city');
        addressWrapper.streetNumber = (String) addressMap.get('streetNumber');
        addressWrapper.door = (String) addressMap.get('door');
        addressWrapper.floor = (String) addressMap.get('floor');
        addressWrapper.stair = (String) addressMap.get('stair');
        addressWrapper.country = (String) addressMap.get('country');

        //addressWrapper.electricCUPS = (String) addressMap.get('gas');
        //addressWrapper.gasCUPS = (String) addressMap.get('electric');

        addressWrapper.electricCUPS = (String) addressMap.get('electric');
        addressWrapper.gasCUPS = (String) addressMap.get('gas');

        addressWrapper.clarifType = (String) addressMap.get('clarifType');
        addressWrapper.clarifValue = (String) addressMap.get('clarifValue');
        
        addressWrapper.region = (String) addressMap.get('region');
        
        addressWrapper.municipality = (String) addressMap.get('municipality');

        if(addressMap.get('validate') != null){
            addressWrapper.addressValid = Boolean.valueOf(addressMap.get('validate'));
        } else {
            addressWrapper.addressValid = false;
        }

        if(addressMap.get('validatedCups') != null){
            addressWrapper.validatedCups = Boolean.valueOf(addressMap.get('validatedCups'));
        } else {
            addressWrapper.validatedCups = false;
        }

        system.debug('validation cups, addr: '+addressWrapper.addressValid+', '+addressWrapper.validatedCups);

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'addressWrapper ='+json.serialize(addressWrapper,true));
        mapAddressCheckboxes(addressWrapper, addressMap);
    }

    private static void mapAddressCheckboxes(XC_UTIL_Address.AddressWrapper addressWrapper, Map<String,Object> addressMap){
        addressWrapper.installationAddress = true;
        addressWrapper.billingAddress = true;
        addressWrapper.deliveryAddress = true;
        addressWrapper.pickupPoint = true;
        addressWrapper.warehouse = true;
        addressWrapper.pointOfSales = true;
    }

    /**
     * @description Creates the result wrapper.
     * @param errorMessage the error message
     * @param fieldName the field name
     * @param accId the acc id
     * @return the insert result wrapper
     */
    public static XC_LCC003_NewAccount_W.InsertResultWrapper createWrapperError(String errorMessage, String fieldName, String accId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT createWrapperError');
        XC_LCC003_NewAccount_W.InsertResultWrapper rw = new XC_LCC003_NewAccount_W.InsertResultWrapper(errorMessage, fieldName);
        rw.existingAccId = accId;
        return rw;
    }

    /**
     * @description create Root Territory
     * @param newAccount
     * @return XC_UTIL_Sobject.WrapperResult
     */
    /*public static XC_UTIL_Sobject.WrapperResult insertRootTerritory(Account newAccount){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT insertRootTerritory');
        XC_UTIL_Sobject.WrapperResult rootTerritoryResult = new XC_UTIL_Sobject.WrapperResult();
        if(!Schema.SObjectType.OperatingHours.isAccessible()){
            return rootTerritoryResult;
        }    
        Map<Id,OperatingHours> mapOpHours = new Map<Id,OperatingHours>( [SELECT Id, Name
                                        FROM OperatingHours
                                        WHERE Name =: Label.XC_CL_DefaultOperatingHours LIMIT 1]);   
        List<OperatingHours> opHours = mapOpHours.values();   
        ServiceTerritory rootToInsert = new ServiceTerritory(); 
        rootToInsert.Name = newAccount.Name;
        rootToInsert.XC_AccountId__c = newAccount.Id;
        rootToInsert.OperatingHoursId = opHours[0].Id;
        rootToInsert.isActive = true;
        rootTerritoryResult = XC_UTIL_Sobject.insertRecord(rootToInsert);  
        return rootTerritoryResult;
    }*/

    /**
     * @description update the Account in input
     * @param newAccount account to update
     * @return the dml result wrapper
     */
    public static XC_UTIL_Sobject.WrapperResult updateAccount(Account newAccount){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT updateAccount');
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.WrapperResult updWr = XC_UTIL_Sobject.updateRecord(newAccount);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# updWr UPDATE newAccount ---> ' + updWr);
        return updWr;
    }

    /**
     * @description populate XC_LCC003_NewAccount_W.InsertResultWrapper from WrapperResult
     * @param dmlResult the dml operation result
     * @param beforeInsertSavepoint point to rollback
     * @return the insert result wrapper
     */
    public static XC_LCC003_NewAccount_W.InsertResultWrapper doRollback(XC_UTIL_Sobject.WrapperResult dmlResult, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ACCOUNT creation Rollback@@@');
        Database.rollback(beforeInsertSavepoint);
        return new XC_LCC003_NewAccount_W.InsertResultWrapper(dmlResult.errorMessage, dmlResult.errorfieldName);
    }
}