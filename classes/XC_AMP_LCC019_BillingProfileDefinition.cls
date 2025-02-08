/**
* @author Monica Cutillo - mcutillo@deloitte.it + Eleni Tsiolaki - etsiolaki@deloitte.gr
* @date Creation 23/03/2021
* @description Controller of XC_AMP_LCP019_BillingProfileDefinition – used to manage Billing Profiles on Simplified Sales Portal
*/
public without sharing class XC_AMP_LCC019_BillingProfileDefinition {
    
    /**
     * @description Document Wrapper
     */
    public class XC_FieldSetInput {
        public String prefix;
        public String name;
        public String relatedObject;
        public String segment;
    }

    public class XC_CupsandContract_Wrapper {
        @AuraEnabled public List<String> cups ;
        @AuraEnabled public List<String> cupsLight ;
        @AuraEnabled public List<String> cupsGas ;
        @AuraEnabled public String contract = '';
        //@AuraEnabled public Boolean isB2B = false;
        @AuraEnabled public String commodityAccountId ='';
    }

    /**
     * @description init method
     * @param opportunityId
     * @return Stringified result data
     */
    @AuraEnabled
    public static String initPaymentPage(String opportunityId){
        Map<String,Object> resultData = new Map<String,Object>();

        Opportunity oppData = XC_AMP_LCC019_BillingProfileDefinition_D.retrieveDataFromOpportunity(opportunityId);

        //List<XC_UTIL_PaymentMethodFilter.MopWrapper> filteredMopWrappers = XC_UTIL_PaymentMethodFilter.getAvailableMopsForLe(oppData.XC_LegalEntity__c,oppData.XC_Segment__c);
		
        List<NE__OrderItem__c> orderItems = XC_AMP_LCC019_BillingProfileDefinition_D.retrieveOrderItemsFromOpportunity(oppData.XC_AMP_Order__c);

        Map<String,List<XC_UTIL_PaymentMethodFilter.MopWrapper>> filteredMopWrappersMap = XC_UTIL_PaymentMethodFilter.getAvailabeMopsForOrderItems(oppData.XC_LegalEntity__c,oppData.XC_Segment__c, orderItems);
		
        List<XC_UTIL_PaymentMethodFilter.MopWrapper> filteredMopWrappers = filteredMopWrappersMap.get(orderItems[0].Id);
        
        List<Map<String,String>> mopData= new List<Map<String,String>>();
        Map<String,String> mopRow;
    
        for(XC_UTIL_PaymentMethodFilter.MopWrapper mw : filteredMopWrappers){
            mopRow= new Map<String,String>();
            mopRow.put('key', mw.mopValue);
            mopRow.put('value', mw.mopValue);
            mopData.add(mopRow);
        }
        
        List<String> paymentMethodCatOpts = getPaymentMethodCategoryPickList();
        resultData.put('paymentMethodCatOpts',paymentMethodCatOpts);
        
        resultData.put('mopData',mopData);
        resultData.put('accountId',oppData.AccountId);
        resultData.put('contactId',oppData.XC_Contact__c);
        resultData.put('XC_DocumentCountry__c',oppData.Account.XC_DocumentCountry__c);
        resultData.put('IdentityType__c',oppData.Account.IdentityType__c);
        resultData.put('IdentityNumber__c',oppData.Account.IdentityNumber__c);
        resultData.put('addressId',oppData.XC_Address__c);
        resultData.put('legatEntity',oppData.XC_LegalEntity__c);
        resultData.put('segment',oppData.XC_Segment__c);
        resultData.put('recordTypeName', oppData.Account.XC_RecordTypeDeveloperName__c);

        String addressString = oppData.XC_Address__r.XC_Address__c + ', '+ oppData.XC_Address__r.XC_StreetNumber__c + ', '+ oppData.XC_Address__r.XC_City__c+ ', '+ 
                               oppData.XC_Address__r.XC_PostalCode__c + ', '+ oppData.XC_Address__r.XC_AddressCountry__c;
        Map<String,String> addressRow = new Map<String,String>();
        addressRow.put('key', oppData.XC_Address__c );
        addressRow.put('value', addressString);
        resultData.put('addressRow',addressRow);
        
        Map<String,String> contactRow = new Map<String,String>();
        contactRow.put('key', oppData.XC_Contact__c );
        contactRow.put('value', oppData.XC_Contact__r.Name);
        resultData.put('contactRow',contactRow);
        List<Map<String,String>> invoiceDeliveryPreferencesPick = getinvoiceDeliveryPreferencesPickList(XC_UTIL_User.getLegalEntityFromUser());
        resultData.put('invoiceDeliveryPreferencesPick',invoiceDeliveryPreferencesPick);
        List<Map<String,String>> doxeeLanguages = XC_UTIL_Account.getDoxeeLanguagesPicklist();
        resultData.put('doxeeLanguages',doxeeLanguages);
        resultData.put('sepaMandateValues',getSepaMandatePickList());
        
        String defaultMandateTypeVal;
        Schema.DescribeFieldResult dr = NE__Billing_Profile__c.XC_MandateType__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = dr.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals) {
            if (pv.isDefaultValue()) {
                defaultMandateTypeVal = pv.getLabel();
            }    
        }
        resultData.put('defaultMandateTypeVal',defaultMandateTypeVal);

        //Contact ExtraFields mngm
        /*XC_FieldSetInput fsInput = new XC_FieldSetInput();
        fsInput.prefix = 'XC_';
        fsInput.name = 'ZuoraContactExtraFields';
        fsInput.relatedObject = 'XC_BillingProfileLineItem__c';
        fsInput.segment = oppData.XC_Segment__c;
        List<XC_UTIL_FieldSet.FieldWrapper> contactExtraFields = retrieveFieldsFromFieldSet(fsInput);
        if(!contactExtraFields.isEmpty()){
            resultData.put('showContactExtraFields', true);
            resultData.put('contactExtraFields', contactExtraFields);
        }*/

        //Document ExtraFields mngm
        XC_FieldSetInput fsDocInput = new XC_FieldSetInput();
        fsDocInput.prefix = 'XC_AMP_';
        fsDocInput.name = 'Residential_AccDOC';
        fsDocInput.relatedObject = 'Account';
        fsDocInput.segment = oppData.XC_Segment__c;
        List<XC_UTIL_FieldSet.FieldWrapper> documentExtraFields = retrieveFieldsFromFieldSet(fsDocInput);
        if(!documentExtraFields.isEmpty()){
            resultData.put('showDocumentExtraFields', true);
            resultData.put('documentExtraFields', documentExtraFields);
            List<String> fieldNames = new List<String>();
            for(XC_UTIL_FieldSet.FieldWrapper f : documentExtraFields) {
                fieldNames.add(f.fieldName);
            }
            resultData.put('documentFieldNames', fieldNames);
        }

        Map<String, XC_CM_LegalEntity_Configuration__mdt> leMapping = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{oppData.XC_LegalEntity__c}, new Set<String>{oppData.XC_Segment__c});
        if(leMapping.get(oppData.XC_LegalEntity__c + oppData.XC_Segment__c) != null){
            resultData.put('getContractBy', leMapping.get(oppData.XC_LegalEntity__c + oppData.XC_Segment__c).XC_GetContractBy__c);
        }

        Map<String, List<XC_BillingProfileLineItem__c>> billingProfiles = XC_AMP_LCC019_BillingProfileDefinition_D.getAvailableBillingProfiles(oppData.AccountId, oppData.XC_Contact__c, oppData.XC_Address__c);
        for(String payment : billingProfiles.keySet()) {
            resultData.put(payment, billingProfiles.get(payment));
        }
        return JSON.serialize(resultData);
    }
    
    
    /**
     * @description retrieve dynamically available payment methods from Billing Profile Object. 
     * @param paymentMethod
     * @return dependent category value
     **/
    @AuraEnabled
    public static String getPaymentCategoryDependency(String paymentMethod){
        Map<String, List<String>> resMap = XC_UTIL_DependentPicklist.getDependentPicklist('NE__Billing_Profile__c', 'NE__Payment__c', 'XC_PaymentMethodCategory__c').pickListMap;
        return resMap.get(paymentMethod)[0];
    }

    /**
    * @author Francesco Imperioli - fimperioli@deloitte.it
    * @description return contracts for new commodity bill management for EndesaX
    * @createdDate 2020-03-03
    */
    @AuraEnabled
    public static List<Map<String,Object>> getCommodityContract(Map<String,Object> params){
        return XC_ZuoraBPCreationC_U.getCommodityContract(params);
    }

    /*
     * @description retrieveFieldsFromFieldSet
     * @param fsInput
     * @return List<XC_UTIL_FieldSet.FieldWrapper>, empty if the fieldset there isn't
     */
    private static List<XC_UTIL_FieldSet.FieldWrapper> retrieveFieldsFromFieldSet(XC_FieldSetInput fsInput) {
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUser();
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEStream = fsInput.segment;
        String fieldSetKey = fsInput.prefix + countryIso + '_' + userLEStream +'_' + fsInput.name; 

        List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey, fsInput.relatedObject); //'XC_BillingProfileLineItem__c'
        return fieldFromFieldSet;
    }
    
    /*
     * @description getinvoiceDeliveryPreferencesPickList
     * @param leagEntity
     * @return List<Map<String,String>> result data 
     */
    private static List<Map<String,String>> getinvoiceDeliveryPreferencesPickList(String leagEntity){
        List<Map<String,String>> result = new List<Map<String,String>>();
        List<Map<String,String>> resultB2C = new List<Map<String,String>>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_InvoiceDeliveryPref__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            Map<String,String> row = new Map<String,String>();
            row.put('key',ple.getValue());
            row.put('value', ple.getLabel());
            result.add(row);
        }
        for(Schema.PickListEntry ple : entryList){
            if(ple.getValue()!='Smart Invoice'){  
            Map<String,String> row = new Map<String,String>();
            row.put('key',ple.getValue()  );
            row.put('value', ple.getLabel());
            resultB2C.add(row);
            }
        }
        return resultB2C;
    }
    
    /**
     * @description Method to retrieve cups
     * @param addressId
     * @param documentNumber
     *@return XC_CupsandContract_Wrapper
    */
    @AuraEnabled
    public static XC_CupsandContract_Wrapper retrieveCups(String addressId , String documentNumber){
        XC_CupsandContract_Wrapper returnWrapper = new XC_CupsandContract_Wrapper();
        XC_Address__c addr = XC_AMP_LCC019_BillingProfileDefinition_D.retrieveAddresData(addressId);

        if(String.isNotBlank(addr.XC_ElectricCUPS__c) && String.isBlank(addr.XC_GasCUPS__c)){
            returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c};
            returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
            Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract('', addr.XC_ElectricCUPS__c,addr.XC_AddressCountry__c );
            if(callResult != null && !callResult.isEmpty() && callResult.get('Contract') != null && ((List<Object>)callResult.get('Contract'))[0] != null){
                Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
                Map<String,Object> contrData = (Map<String,Object>)contractValues;
                if(contrData != null && !contrData.isEmpty()){
                    returnWrapper.contract = String.valueOf(contrData.get('ContractNumber'));
                }
            }
        }
        else if(String.isNotBlank(addr.XC_GasCUPS__c) && String.isBlank(addr.XC_ElectricCUPS__c)){
            returnWrapper.cups = new List<String> {addr.XC_GasCUPS__c};
            returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
            Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract('', addr.XC_GasCUPS__c, addr.XC_AddressCountry__c);
            if(callResult != null && !callResult.isEmpty() && callResult.get('Contract') != null){
                Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
                Map<String,Object> contrData = (Map<String,Object>)contractValues;
                if(contrData != null && !contrData.isEmpty()){
                    returnWrapper.contract = String.valueOf(contrData.get('ContractNumber'));
                }
            }
        }
        else if(String.isNotBlank(addr.XC_ElectricCUPS__c) && String.isNotBlank(addr.XC_GasCUPS__c)){
            returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c,addr.XC_GasCUPS__c};
            returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
            returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
        }
        return returnWrapper;
    }
    
    /**
    * @description : returns picklist values for SepaMandate field on Billing profile Object
    * @return List<String> of picklistvalues
    **/
    private static List<String> getSepaMandatePickList(){
        List<String> result= new List<String>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_MandateType__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            result.add(ple.getLabel());
        }
        return result;
    }

    /**
    *@author:
    *@description : retrieve dynamically available payment methods from Billing Profile Object.
    *@createddate 2019-11-06
    **/
    @AuraEnabled
    public static List<String> getPaymentMethodCategoryPickList(){
        List<String> result= new List<String>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_PaymentMethodCategory__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            result.add(ple.getValue());
        }
        return result;
    }
    
}