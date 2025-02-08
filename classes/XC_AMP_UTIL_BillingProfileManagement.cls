/**
* @author Monica Cutillo - mcutillo@deloitte.it + Eleni Tsiolaki - etsiolaki@deloitte.gr
* @date Creation 13/04/2021
* @description UTIL Class for the XC_AMP_LCP019_BillingProfileDefinition Controller
*/
public with sharing class XC_AMP_UTIL_BillingProfileManagement {

    public class XC_ContactAddress_Wrapper {
        @AuraEnabled
        public Contact c ;
        @AuraEnabled
        public String addressId = '';
    }

    /**
     * @author Eleni Tsiolaki
     * @description Method to create a new one, or to use the selected Billing Profile
     *@param accountId - String
	 *@param mapValues - String
     *@return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createOrSelectBillingProfile(String accountId, String mapValues){
        Map<String,Object> values = (Map<String,Object>)JSON.deserializeUntyped(mapValues);
        String billingProfileLineItemId = (String)values.get('billingProfileLineItem');
        String opportunityId = (String)values.get('opportunityId');
        String paymentMethod = (String)values.get('payment');
        XC_UTIL_ResultWrapper result =  new XC_UTIL_ResultWrapper();
        
        if(String.isNotBlank(billingProfileLineItemId)) {
            System.debug('The billing Profile Line item is selected');
            result = associateBillingProfile(accountId, billingProfileLineItemId, opportunityId,  paymentMethod);
        } else {
            System.debug('No billing Profile Line item selected, creation of new Billing Profile');
            result = retrieveContactsForZuora(accountId, mapValues);
        }
        return result;
    }
    
    /**
     * @author Eleni Tsiolaki
     * @description Method to associate the Billing Profile Line item to the Order
     *@param accountId - String
	 *@param mapValues - String
     *@return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper associateBillingProfile(String accountId, String billingProfileLineItemId, String opportunityId, String paymentMethod){
        List<NE__OrderItem__c> orderItems = [SELECT Id, XC_PaymentMethod__c, XC_BillingProfileLineItem__c 
                    FROM NE__OrderItem__c WHERE NE__OrderId__r.NE__OptyId__c = :opportunityId AND NE__Account__c = :accountId AND NE__Root_Order_Item__c = null
                    AND NE__Bundle_Configuration__c = null ];
        for(NE__OrderItem__c orderItem : orderItems) {
            orderItem.XC_PaymentMethod__c = paymentMethod;
            orderItem.XC_BillingProfileLineItem__c = billingProfileLineItemId;
        }

        XC_UTIL_ResultWrapper result =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(orderItems);
        XC_UTIL_Sobject.WrapperResult globalRes = XC_UTIL_Sobject.getGlobalDMLResults(dmlRes);
        result.success = globalRes.success;
        if(!result.success){
            result.resultMessage = globalRes.errorMessage;
        }
        return result;
    }


    /**
     * @author
     * @description Method to update the Preferred Language on the Account
     *@param accountId - String
	 *@param mapValuesJSON - String
     *@return XC_UTIL_Sobject.WrapperResult
     */
    @AuraEnabled
    public static XC_UTIL_Sobject.WrapperResult updateSalesforceAccount(String accountId, String mapValuesJSON){
        Account acc = [SELECT Id FROM Account where Id =: accountId][0];
        Map<String, Object> mapValues = (Map<String, Object>)JSON.deserializeUntyped(mapValuesJSON);
        for(String key: mapValues.keySet() ){
            acc.put(key, mapValues.get(key));
        }
        return XC_UTIL_DML.updateRecords(new List<Account>{acc})[0];
    }

    /**
     * @author Eleni Tsiolaki
     * @description Method to retrieve Contacts For Zuora
     *@param accountId - String
	 *@param mapValues - String
     *@return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper retrieveContactsForZuora(String accountId, String mapValues){
        XC_ContactAddress_Wrapper wr1 = new XC_ContactAddress_Wrapper();
        XC_ContactAddress_Wrapper wr2 = new XC_ContactAddress_Wrapper();
        Map<String,Object> values = (Map<String,Object>)JSON.deserializeUntyped(mapValues);
        String legalEntity = (String)values.get('legalEntity');
        Account acc = prepareAccountForZuora(accountId);
        wr1 = prepareContactForZuora((String)values.get('contactId'),(String)values.get('billingAddress'), legalEntity);
        wr2 = prepareContactForZuora((String)values.get('contactId'),(String)values.get('soldAddress'), legalEntity);
        Contact billTo = wr1.c;
        Contact soldTo = wr2.c;
        String billAddress = wr1.addressId;
        String soldAddress = wr2.addressId;
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, acc.XC_Segment__c);
        
        Map<String, XC_CM_LegalEntity_Configuration__mdt> leMapping = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{legalEntity}, new Set<String>{acc.XC_Segment__c});
        String zuoraSequenceSetId;
        String vatGroupSequenceSetId;
        if(leMapping.get(legalEntity+acc.XC_Segment__c)!=null) {
            zuoraSequenceSetId = leMapping.get(legalEntity+acc.XC_Segment__c).XC_ZuoraSequenceSetId__c;
            // VAT GROUP TYPE SEQUENCE SET
            if(acc.XC_VatGroupType__c != null && acc.XC_VatGroupType__c.equalsIgnoreCase('Gruppo IVA Enel')) {
                vatGroupSequenceSetId = leMapping.get(legalEntity+acc.XC_Segment__c).XC_VatGroup_SequenceSet__c;
            }
        }

        // Update the Language on the Account
        String languagePreferred = (String)values.get('doxeeLanguage');
        if(String.isNotBlank(languagePreferred)){
            Map<String,Object> mapAccountValues = new Map<String,Object>(); 
            mapAccountValues.put('PreferredLanguage__c', languagePreferred);
            XC_UTIL_Sobject.WrapperResult accUpdRes = updateSalesforceAccount(accountId, JSON.serialize(mapAccountValues));
            if(!accUpdRes.success){
                XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper(accUpdRes.success);
                result.resultMessage = accUpdRes.errorMessage;
                return result;
            }
        }

        // Call the CreateBilingProfile method directly from here
        Map<String,Object> infoMap = new Map<String,Object>();

        infoMap.put('accountId',(String)values.get('accountId'));
        infoMap.put('accountRecordTypeName',acc.XC_RecordTypeDeveloperName__c);
        infoMap.put('splitPayment',acc.XC_SplitPayment__c);
        infoMap.put('paymentMethodType',(String)values.get('payment'));
        infoMap.put('paymentMethodCategoryVal',(String)values.get('paymentMethodCategoryVal'));
        infoMap.put('legal', (String)values.get('legalEntity'));

        infoMap.put('invoiceDel',(String)values.get('invoiceDeliveryPreferencesPick'));
        infoMap.put('account',acc);
        infoMap.put('billTo',billTo);
        infoMap.put('soldTo',soldTo);
        infoMap.put('billAddress', billAddress);
        infoMap.put('soldAddress', soldAddress);

        infoMap.put('accountNumber',(String)values.get('accountIban'));
        infoMap.put('bic',(String)values.get('bic'));
        infoMap.put('lang',(String)values.get('lang'));
        String mandateType = (String)values.get('mandateT');
        if (mandateType == 'One Time') {
            mandateType = 'ONE_SHOT';
        } else {
            mandateType = 'RECURRENT';
        }
        infoMap.put('sepaMandateType',mandateType);

        infoMap.put('docNif',(String)values.get('docdentityType'));
        infoMap.put('docNumber',(String)values.get('docIdentityNumber'));
        infoMap.put('docCountry',(String)values.get('docCountry'));

        infoMap.put('financialInstitute',(String)values.get('financialInstitute'));
        infoMap.put('otherFinancialInstitute',(String)values.get('otherFinancialInstitute'));

        infoMap.put('isB2BG','');
        infoMap.put('fromBillingProfile','false');
        infoMap.put('billingProfileId','');

        infoMap.put('cupsId',(String)values.get('cupsId'));
        infoMap.put('contractId',(String)values.get('contractId'));
        infoMap.put('commodityContractStatus',(String)values.get('commodityContractStatus'));
        infoMap.put('contractType',(String)values.get('contractType'));
        infoMap.put('contractBatch',(String)values.get('contractBatch'));
        infoMap.put('getContractBy',(String)values.get('getContractBy'));
        infoMap.put('commodityAccountId',(String)values.get('commodityAccountId'));
        infoMap.put('commodityBillingCycleFrequency',(String)values.get('commodityBillingCycleFrequency'));
        infoMap.put('VatGroupSequenceSetId',(String)values.get('VatGroupSequenceSetId'));
        infoMap.put('entityName',entityName);
        //Set the recipientCode by default to 0000000
        String recipientCode = '0000000';
        infoMap.put('recipientCode', recipientCode);
        
        String info = JSON.serialize(infoMap);
        return createBillingProfile(acc, billTo, soldTo, billAddress, soldAddress, info);
    }

    /**
     * @author
     * @description Method to prepare Account For Zuora
     * @param accountId
     * @return Account
     */
    private static Account prepareAccountForZuora(String accountId){
        Id accId = Id.valueOf(accountId);
        String sObjName = accId.getSObjectType().getDescribe().getName();
        If(sObjName == 'NE__Billing_Profile__c'){
            NE__Billing_Profile__c billingProf = [SELECT Id, NE__Account__c FROM NE__Billing_Profile__c WHERE Id =: accountId LIMIT 1];
            accountId = billingProf.NE__Account__c;
        }
        String fields = ZuoraWebserviceUtil.generateFieldsToQueryFromFieldSet('zqu__CustomAccountFields','Account');
        return (Account)Database.query('SELECT id, Name, XC_RecordTypeDeveloperName__c, XC_SplitPayment__c, XC_Segment__c, XC_SectorOfTheCompany__c, XC_Giro__c, XC_EnelXSupply__c , XC_TipoDeRegimen__c, XC_ObligacionesDelContribuyente__c, IdentityNumber__c, CurrencyIsoCode, XC_Country__c, XC_SohoType__c, XC_TradingPartner__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_IdentityNumber2__c, XC_DocumentType2__c, XC_BillingAgency__c '+fields+' FROM Account where Id=:accountId')[0];
    }

    /**
    * @author 
    * @description Method to prepare fake Contact For Zuora
    * @param contactId
    * @param addressId
    * @param legalEntity
    * @return XC_ContactAddress_Wrapper
     */
    public static XC_ContactAddress_Wrapper prepareContactForZuora(String contactId, String addressId, String legalEntity){
        XC_ContactAddress_Wrapper wr = new  XC_ContactAddress_Wrapper();

        if(!Schema.sObjectType.Contact.isAccessible()){
            return null;
        }
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Account.Name, XC_Preferredlanguageofcontact__c, Fax, MailingState, Email, Phone, MobilePhone, zqu__County__c FROM Contact WHERE Id =: contactId];
        List<XC_Address__c> address = [SELECT Id, XC_StreetTypeText__c, XC_StreetType__c, XC_FullAddress__c, XC_AddressProvince__c, XC_AddressCountry__c, XC_Stair__c, XC_Door__c, XC_Floor__c, XC_City__c, XC_Address__c, XC_DeliveryAddress__c, XC_BillingAddress__c, XC_PostalCode__c , XC_InstallationAddress__c, XC_StreetNumber__c, XC_AddressValidated__c FROM XC_Address__c WHERE Id =: addressId ];

        Contact contact = contacts[0];
        XC_Address__c a = address[0];
        Boolean hasNumber = a.XC_AddressCountry__c == 'Colombia' && String.isNotBlank(a.XC_Address__c) && String.isNotBlank(a.XC_StreetNumber__c) && a.XC_Address__c.contains(a.XC_StreetNumber__c);
        if(hasNumber){
            a.XC_Address__c = a.XC_Address__c.remove(' '+a.XC_StreetNumber__c);
        }
        
        Boolean concatenateFields;
        if(String.isNotBlank(legalEntity)) {
            concatenateFields = /*legalEntity == 'EndesaX' ||*/ legalEntity == 'EnelDistribucion' || legalEntity == 'EnelX' || legalEntity == 'Codensa';
        } else {
            concatenateFields = /*a.XC_AddressCountry__c == 'Spain' ||*/ a.XC_AddressCountry__c == 'Chile' || a.XC_AddressCountry__c == 'Colombia';
        }
        
        contact.MailingStreet = concatenateFields ? a.XC_Address__c+' '+a.XC_StreetNumber__c+' '+a.XC_PostalCode__c : a.XC_Address__c;
        contact.MailingStreet = (a.XC_AddressValidated__c && String.isNotBlank(a.XC_StreetTypeText__c) && !contact.MailingStreet.startsWithIgnoreCase(a.XC_StreetTypeText__c)) ? a.XC_StreetTypeText__c+' '+contact.MailingStreet : contact.MailingStreet;
        contact.MailingCity = a.XC_City__c;
        contact.MailingCountry = a.XC_AddressCountry__c;
        contact.MailingState = a.XC_AddressProvince__c;
        contact.MailingPostalCode = a.XC_PostalCode__c;
        contact.XC_Door__c = a.XC_Door__c;
        contact.XC_Floor__c = a.XC_Floor__c;
        contact.XC_Stair__c = a.XC_Stair__c;
        contact.XC_StreetNumber__c = a.XC_StreetNumber__c;

        if(String.isBlank(contact.FirstName)) {
            contact.FirstName = contact.Account.Name;
        }

        wr.c = contact;
        if(!address.isEmpty()){
            wr.addressId = address[0].Id;
        }
        return wr;
    }

    /**
     * @author
     * @description Method to Create Billing Profile And Bpli
     * @param billTo
     * @param soldTo
     * @param billAddress
     * @param soldAddress
     * @param info
     *@return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createBillingProfile(Account account, Contact billTo, Contact soldTo, String billAddress, String soldAddress, String info){
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(info);
        String legalEntity = String.valueOf(optionsMap.get('legal'));
        String subNumber = '';

        String lang = '';
        if(optionsMap.containsKey('lang')){
            lang = String.valueOf(optionsMap.get('lang'));
        }

        String accountNumber = '';
        if(optionsMap.containsKey('accountNumber')){
            accountNumber = String.valueOf(optionsMap.get('accountNumber'));
        }

        String bic = '';
        if(optionsMap.containsKey('bic')){
            bic = String.valueOf(optionsMap.get('bic'));
        }

        String contractId = '';
        if(optionsMap.containsKey('contractId')){
            contractId = String.valueOf(optionsMap.get('contractId'));
        }

        String contractType = '';
        if(optionsMap.containsKey('contractType')){
            String ctype= String.valueOf(optionsMap.get('contractType'));
            contractType = ctype == '01' ? 'ELECTRIC' : ctype == '02' ? 'GAS' : ctype == 'ELE' ? 'ELECTRIC' : 'GAS';
        }

        String cupsId = '';
        if(optionsMap.containsKey('cupsId')){
            cupsId = String.valueOf(optionsMap.get('cupsId'));
        }

        String interactionId = '';
        if(optionsMap.containsKey('interactionId')){
            interactionId = String.valueOf(optionsMap.get('interactionId'));
        }

        String siaToken ='';
        if(optionsMap.containsKey('siaPayment')){
            String siaTokenToParse = String.valueOf(optionsMap.get('siaPayment'));
            if(siaTokenToParse != 'createZuoraCustomer'){
                Map<String, Object> siaTokenMap = (Map<String, Object>)JSON.deserializeUntyped(siaTokenToParse);
                siaToken = String.valueOf(siaTokenMap.get('debtorCode'));
            }
        }

        String invoiceDel = '';
        if(optionsMap.containsKey('invoiceDel')){
            invoiceDel = String.valueOf(optionsMap.get('invoiceDel'));
        }
        String paymentTerm = '';
        if (optionsMap.containsKey('paymentTerm')) {
            paymentTerm = String.valueOf(optionsMap.get('paymentTerm'));
        }

        String docNum = '';
        String docType = '';
        String docCountry = '';
        if(optionsMap.containsKey('docNif')){
            docType = String.valueOf(optionsMap.get('docNif'));
        }

        if(optionsMap.containsKey('docNumber')){
            docNum = String.valueOf(optionsMap.get('docNumber'));
        }

        if(optionsMap.containsKey('docCountry')){
            docCountry = String.valueOf(optionsMap.get('docCountry'));
        }

        //External financing information
        String financialInstitute = '';
        String otherFinancialInstitute = '';
        if(optionsMap.containsKey('financialInstitute')){
            financialInstitute = String.valueOf(optionsMap.get('financialInstitute'));
        }

        if(optionsMap.containsKey('otherFinancialInstitute')){
            otherFinancialInstitute = String.valueOf(optionsMap.get('otherFinancialInstitute'));
        }

        String contractStatus = 'Active';
        if(optionsMap.containsKey('commodityContractStatus')){
            contractStatus = String.valueOf(optionsMap.get('commodityContractStatus'));
        }

        String totalName;
        String paymentMethod = String.valueOf(optionsMap.get('paymentMethodType'));
        String paymentMethodCategory = String.valueOf(optionsMap.get('paymentMethodCategoryVal'));
        // String bpliSearchKey = getTranslatedBPLIPaymentSearchKey(paymentMethod);
        String billingStatus = 'Sent To Zuora';
        String mandateType;

        if(paymentMethod=='Commodity Bill'){
            paymentMethod = 'Commodity Bill';
            totalName = billingName(paymentMethod, contractId);
            if(contractStatus!='Active'){
                billingStatus = 'Waiting External Activation';
            }

        } else if(paymentMethod=='Direct Debt'){
            paymentMethod = 'Direct Debt';
            totalName = billingName(paymentMethod, accountNumber);
            mandateType = String.valueOf(optionsMap.get('sepaMandateType'));

            //check autoactivation base on LE
            List<XC_CM_LegalEntity_Configuration__mdt> currentConfiguration = [SELECT XC_LegalEntity__c,XC_DisableSDDAutoActive__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c = :legalEntity AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];

            if(!currentConfiguration.isEmpty() && currentConfiguration[0].XC_DisableSDDAutoActive__c){
                billingStatus = 'Waiting External Activation';
            }

        } else if(paymentMethod=='Barcode'){
            paymentMethod = 'Barcode';
            totalName = paymentMethod;

        } else if(paymentMethod=='Bank Transfer'){
            paymentMethod = 'Bank Transfer';
            totalName = paymentMethod;

        } else if(paymentMethod=='Credit Card'){
            paymentMethod = 'Credit Card';
            totalName = paymentMethod;
            billingStatus = 'Draft';
        }else{
            totalName = paymentMethod;
        }

        //electronic invoice management IT - Adoption - F.I. 2020-03-04
        String PEC = optionsMap.containsKey('pec') ? String.valueOf(optionsMap.get('pec')) : '';
        String recipientCode = optionsMap.containsKey('recipientCode') ? String.valueOf(optionsMap.get('recipientCode')) : '';

        Boolean fromBillingProfile = false;
        if(optionsMap.containsKey('fromBillingProfile')){
            fromBillingProfile = Boolean.valueOf(optionsMap.get('fromBillingProfile'));
        }

        String billingProfileId;
        if(!fromBillingProfile){
            NE__Billing_Profile__c billingProfile = new NE__Billing_Profile__c(
                    Name = totalName, NE__Payment__c = paymentMethod, NE__Account__c = String.valueOf(optionsMap.get('accountId')),
                    NE__Iban__c = accountNumber, XC_CommodityContractID__c = contractId, XC_CommodityCupsID__c = cupsId,
                    XC_BIC__c = bic,XC_Status__c = billingStatus
            );

            if(String.isNotBlank(mandateType)){
                billingProfile.XC_MandateType__c = mandateType;
            }
            if(String.isNotBlank(invoiceDel)){
                billingProfile.XC_InvoiceDeliveryPref__c = invoiceDel;
            }

            if(paymentMethod == 'Direct Debt' || paymentMethod == 'External Financing'){
                billingProfile.XC_LegalEntity__c = legalEntity;
            }

            if(String.isNotBlank(contractType)){
                billingProfile.XC_CommodityContractType__c = contractType;
            }
            
            if(String.isNotBlank(paymentTerm)){
                billingProfile.XC_PaymentTerm__c = paymentTerm;
            }

            if(paymentMethod == 'External Financing'){
                if(String.isNotBlank(financialInstitute)){
                    billingProfile.XC_FinancialInstitute__c = financialInstitute;
                }
    
                if(String.isNotBlank(otherFinancialInstitute)){
                    billingProfile.XC_OtherFinancialInstitute__c = otherFinancialInstitute;
                }
            }
            
            XC_UTIL_Sobject.WrapperResult w = XC_UTIL_Sobject.insertRecord(billingProfile);
            if(!w.success){
                XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();
                wrNew.success = false;
                wrNew.resultMessage = Label.XC_CL_BillingProfile_ErrorInsert +w.errorMessage;
                return wrNew;
            }
            billingProfileId = billingProfile.Id;
        }

        Contact cBillTo = billTo;
        Contact cSoldTo = soldTo;
        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c(
                XC_BillingProfile__c = billingProfileId, XC_BillingProfileCopy__c = billingProfileId,
                XC_BillToAddress__c = billAddress, XC_SoldToAddress__c = soldAddress,
                XC_BillToContactId__c = cBillTo.Id, XC_SoldToContactId__c = cSoldTo.Id,
                XC_LegalEntity__c = legalEntity, XC_BillingProfileName__c = totalName,
                XC_DocumentType__c = docType,XC_DocumentNumber__c = docNum,XC_DocumentCountry__c = docCountry,
                XC_Status__c = billingStatus
        );

        if(String.isNotBlank(recipientCode)){
            billingProfileLineItem.XC_RecipientCode__c = recipientCode;
        }

        String sepaMandate = '';
        String sepaMandateDate = '';
        XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper(XC_UTIL_Sobject.insertRecord(billingProfileLineItem));
        if(billingProfileId!=null){
            NE__Billing_Profile__c bp = [
                    SELECT id, XC_SepaMandate__c, XC_SepaMandateDate__c
                    FROM NE__Billing_Profile__c
                    WHERE Id=: billingProfileId
            ];
            sepaMandate = bp.XC_SepaMandate__c;
            sepaMandateDate = String.valueOf(bp.XC_SepaMandateDate__c);
            wrNew.objectInfo = JSON.serialize(bp);
            optionsMap.put('sepaMandate', sepaMandate);
            optionsMap.put('sepaMandateDate', sepaMandateDate);
            wrNew.fieldName = billingProfileId; // invertiti il 06/08/2019
            wrNew.fieldName2 = cSoldTo.id;
            wrNew.fieldName3 = JSON.serialize(optionsMap);
        }
        return wrNew;
    }

    /**
    * @author 
    * @description Method to concatenate Name
    * @param paymentMethod
    * @param paymentString
    *@return String
    */
    public static String billingName (String paymentMethod, String paymentString){
        return paymentMethod+' - '+paymentString;
    }

    /**
    * @author
    * @description Method to call Sia and manage Operation after call
    * @param contactId
    * @param lang
    * @param paymentMethod
    * @param billingProfileId

    *@return XC_UTIL_ResultWrapper
   */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper manageOperationBeforeCallSia(String contactId, String lang, String paymentMethod, String billingProfileId){
        XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();

        Map<id,NE__Billing_Profile__c> bprofMap = new Map<id,NE__Billing_Profile__c>([
                SELECT Id, XC_Token__c, XC_MandateType__c, NE__Iban__c, XC_SepaMandate__c, XC_SepaMandateDate__c,
                (SELECT Id FROM Billing_Profile_Line_Items__r)
                FROM NE__Billing_Profile__c
                WHERE id=: billingProfileId
        ]);
        NE__Billing_Profile__c bprof = bprofMap.values()[0];

        XC_REST_PaymentMethodSIA.ResultWrapper restWr = new XC_REST_PaymentMethodSIA.ResultWrapper();
        if(paymentMethod=='Credit Card'){
            restWr = callSIAForCreditCard(contactId, bprof);

            if(restWr.paymentMethodSIA != '' && restWr.success){
                Map<String,Object> siaValues = (Map<String,Object>)JSON.deserializeUntyped(restWr.paymentMethodSIA);
                bprof.XC_Token__c = String.valueOf(siaValues.get('debtorCode'));
                wrNew.objectInfo = restWr.paymentMethodSIA;
                wrNew.success = true;

            } else {
                wrNew.resultMessage = restWr.errorMessage;
                wrNew.success = false;
            }

        }else if(paymentMethod=='Direct Debt'){
            XC_REST_PaymentMethodSIA_U.ResponseWrapper res = callSIAForSEPA(contactId, bprof);

            if(String.isNotBlank(res.debtorCode)){
                bprof.XC_Token__c = res.debtorCode;
                bprof.XC_CreateMandate__c = true;
                XC_UTIL_Sobject.updateRecord(bprof);
                wrNew.objectInfo = JSON.serialize(res, true);
                wrNew.success = true;

            } else {
                wrNew.objectInfo = JSON.serialize(res, true);
                wrNew.resultMessage = restWr.errorMessage;
                wrNew.success = true;

                //DELETE BP AND BPLI
                delete bprofMap.values()[0];
                delete bprofMap.values()[0].Billing_Profile_Line_Items__r;
            }
        }
        return wrNew;
    }

    /**
    * @author
    * @description Method to call sia web Service
    * @param contactId the contact or account id
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA.ResultWrapper
     */
    public static XC_REST_PaymentMethodSIA.ResultWrapper callSIAForCreditCard(String contactId, NE__Billing_Profile__c bp){
        XC_REST_PaymentMethodSIA.ResultWrapper resultWr = new XC_REST_PaymentMethodSIA.ResultWrapper();

        Contact c = getContactFields(contactId);
        if(c==null){
            resultWr.success = false;
            return resultWr;
        }

        if(String.isBlank(c.Email)){
            resultWr.success = false;
            resultWr.errorMessage = Label.XC_CL_Contact_NoEmail;
            return resultWr;
        }

        resultWr = XC_REST_PaymentMethodSIA.callForCreditCard(createReqWrapperCC(bp, c), c.Id, bp.Id);

        Map<String,Object> siaValues = new Map<String,Object>();
        //if(resultWr.paymentMethodSIA!=''){
        if(String.isNotBlank(resultWr.paymentMethodSIA)){
            siaValues = (Map<String,Object>)JSON.deserializeUntyped(resultWr.paymentMethodSIA);
        } else {
            return resultWr;
        }

        List<Map<String,Object>> customerInteractions = new List<Map<String,Object>>();
        customerInteractions.add(createValueMap(c, String.valueOf(siaValues.get('redirectUrl')), bp.Id));

        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(customerInteractions);
        resultWr.interactionRecordId = '';
        if(results!=null && results[0]!=null){
            resultWr.interactionRecordId = results[0].recordId;
        }

        return resultWr;
    }

    /**
    * @author
    * @description Method to call sia web Service
    * @param contactId
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA_U.ResponseWrapper
     */
    public static XC_REST_PaymentMethodSIA_U.ResponseWrapper callSIAForSEPA(String contactId, NE__Billing_Profile__c bp){
        XC_REST_PaymentMethodSIA_U.ResponseWrapper resultWr = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();

        Contact c = getContactFields(contactId);
        if(c==null){
            return resultWr;
        }

        requestWr = createReqWrapperSDD(bp, c);

        resultWr = XC_REST_PaymentMethodSIA.callForSEPA(requestWr);

        return resultWr;
    }


    /**
    * @author
    * @description Method to get all the needed contact fields
    * @param contactOrAccountId
    * @return Contact
    */
    private static Contact getContactFields(String contactOrAccountId){
        Contact c = new Contact();
        List<Contact> contactList = new List<Contact>();
        Schema.SObjectType sobjectType = ((Id)contactOrAccountId).getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        if(sobjectName=='Account'){
            Map<Id,Account> accMap = new Map<Id,Account>([
                    SELECT Id, (
                            SELECT Id, Email, Name, AccountId, XC_Preferredlanguageofcontact__c, XC_MainLegalEntity__c, Account.XC_LastName__c,
                                    Account.XC_FirstName__c,LastName,FirstName,Account.PrimaryEmail__c, Account.IdentityNumber__c, Account.XC_BirthDate__c, Account.Name
                            FROM Contacts
                            WHERE XC_PrimaryContact__c = true )
                    FROM Account
                    WHERE Id =: contactOrAccountId
                    LIMIT 1
            ]);
            if(!accMap.values().isEmpty()){
                contactList = accMap.values()[0].contacts;
            }

        } else if(sobjectName=='Contact'){
            Map<Id,Contact> contactMap = new Map<Id,Contact>([
                    SELECT Id, Email, Name, AccountId, XC_Preferredlanguageofcontact__c, XC_MainLegalEntity__c, Account.XC_LastName__c, Account.XC_FirstName__c,
                            Account.PrimaryEmail__c, Account.IdentityNumber__c,FirstName,LastName, Account.XC_BirthDate__c,Account.Name
                    FROM Contact
                    WHERE Id =: contactOrAccountId
                    LIMIT 1
            ]);
            contactList = contactMap.values();
        }

        if(contactList.isEmpty()){
            return null;
        }

        return contactList[0];
    }

    private static XC_REST_PaymentMethodSIA_U.requestWrapper createReqWrapperCC(NE__Billing_Profile__c billingProfile, Contact contact){
        XC_REST_PaymentMethodSIA_U.requestWrapper requestWr = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        requestWr.email = contact.Email;
        requestWr.typeX = billingProfile.XC_MandateType__c;

        if(String.isBlank(billingProfile.XC_MandateType__c)){
            requestWr.typeX = 'ONE_SHOT';
        }
        //adding address info to manage different payment gateways via payment hub
        List<XC_BillingProfileLineItem__c> currentBPLIs = [SELECT Id,
        XC_SoldToAddress__c,
        XC_SoldToAddress__r.XC_FullAddress__c,
        XC_SoldToAddress__r.XC_PostalCode__c,
        XC_SoldToAddress__r.XC_AddressProvince__c,
        XC_SoldToAddress__r.XC_StreetTypeText__c,
        XC_SoldToAddress__r.XC_City__c,
        XC_LegalEntity__c
        FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :billingProfile.Id ORDER BY CreatedDate DESC LIMIT 1];

        if(!currentBPLIs.isEmpty()){

            XC_BillingProfileLineItem__c currentBpli = currentBPLIs[0];
            String countryISOCode = XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c)!=null ? XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c).XC_ISOCode__c : '';

            //added address fields for CC also
            String addressString = String.isNotBlank(currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c) ? 
            currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_FullAddress__c :
            currentBpli.XC_SoldToAddress__r.XC_FullAddress__c;

            String localityString = currentBpli.XC_SoldToAddress__r.XC_PostalCode__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_City__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_AddressProvince__c;

            requestWr.address = addressString;
            requestWr.addressCity = localityString;
            requestWr.addressCountry = countryISOCode;
        }

        return requestWr;
    }

    /**
   * @author
   * @description Method to createValueMap for customet Interaction
   * @param c
   * @param docUrl
   * @return Map<String,Object>
    */
    @TestVisible
    private static Map<String,Object> createValueMap(Contact c, String docUrl, String billingProfileId){
        Map<String,Object> data = new Map<String,Object>();
        data.put('sent', false);
        data.put('billingProfileId', billingProfileId);
        data.put('skipComunication', false);
        data.put('email',  c.Email);
        data.put('fullName',c.Name);
        data.put('contactId',c.Id);
        data.put('legalEntity', c.XC_MainLegalEntity__c);
        data.put('customerType', 'SIA_Redirect_URL');
        data.put('docURL', docUrl);
        data.put('accountId', c.AccountId);
        data.put('preferredlanguage', c.XC_Preferredlanguageofcontact__c);
        return data;
    }

    private static XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA createReqWrapperSDD(NE__Billing_Profile__c bp, Contact c){
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();
        //String mandateId = bp.XC_SepaMandate__c;
        Map<Id,NE__Billing_Profile__c> bpRetrMap = new Map<Id,NE__Billing_Profile__c>([
                SELECT Id, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_MandateType__c,XC_LegalEntity__c,
                    (SELECT Id,
                    XC_SoldToAddress__c,
                    XC_SoldToAddress__r.XC_FullAddress__c,
                    XC_SoldToAddress__r.XC_PostalCode__c,
                    XC_SoldToAddress__r.XC_AddressProvince__c,
                    XC_SoldToAddress__r.XC_StreetTypeText__c,
                    XC_SoldToAddress__r.XC_City__c,
                    XC_LegalEntity__c
                    FROM Billing_Profile_Line_Items__r 
                    ORDER BY CreatedDate DESC LIMIT 1)
                FROM NE__Billing_Profile__c
                WHERE Id =: bp.id
        ]);

        NE__Billing_Profile__c bpRetr = bpRetrMap.values()[0];
        XC_BillingProfileLineItem__c currentBpli = bpRetr.Billing_Profile_Line_Items__r[0];
        String countryISOCode = XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c)!=null ? XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c).XC_ISOCode__c : '';

        String mandateId = bpRetr.XC_SepaMandate__c;
        requestWr.name = 
        String.isNotBlank(c.Account.XC_FirstName__c) ? XC_UTIL_String.removeDiacritics(c.Account.XC_FirstName__c) : 
        String.isNotBlank(c.FirstName) ? XC_UTIL_String.removeDiacritics(c.FirstName) : c.Account.Name;

        requestWr.surname =   String.isNotBlank(c.Account.XC_LastName__c) ? XC_UTIL_String.removeDiacritics(c.Account.XC_LastName__c) : XC_UTIL_String.removeDiacritics(c.LastName);
        requestWr.email = String.isNotBlank(c.Account.PrimaryEmail__c) ? c.Account.PrimaryEmail__c : String.isNotBlank(c.Email) ? c.Email : c.Account.IdentityNumber__c +'@sepa.com';
        requestWr.nationalIdentificationCode = c.Account.IdentityNumber__c;
        requestWr.iban = bp.NE__Iban__c;
        requestWr.mandateID = mandateId;
        requestWr.birthDate = String.valueOf(c.Account.XC_BirthDate__c);
        if(bpRetr.XC_MandateType__c=='One Time'){
            requestWr.type = 'ONE_SHOT';
        } else {
            requestWr.type = bpRetr.XC_MandateType__c;
        }
        requestWr.sdd = new XC_REST_PaymentMethodSIA_U.SDDWrapper();
        requestWr.sdd.iban = bp.NE__Iban__c;
        requestWr.sdd.mandateId = mandateId;
        requestWr.sdd.mandateDate = String.valueOf(bpRetr.XC_SepaMandateDate__c); // String.valueOf(bp.XC_SepaMandateDate__c); 

        //added address fields for SDD
        String addressString = String.isNotBlank(currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c) ? 
        currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_FullAddress__c :
        currentBpli.XC_SoldToAddress__r.XC_FullAddress__c;

        String localityString = currentBpli.XC_SoldToAddress__r.XC_PostalCode__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_City__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_AddressProvince__c;

        requestWr.address = addressString;
        requestWr.addressCity = localityString;
        requestWr.addressCountry = countryISOCode;
        requestWr.bp = bp.id;

        return requestWr;
    }


    /**
    * @author
    * @description New Method to create Zuora Customer Account
    * @param account
    * @param billingContact
    * @param soldContact
    * @param entityName
    * @param options
    * @param billingProfLineItemId
    * @param zuoraPayment
    *@return String
    */
    @AuraEnabled
    public static String createUnlinkedZuoraAccount(String account, String billingContact, String soldContact, String entityName, String options, String billingProfLineItemId, String zuoraPayment){
        Contact billTo = (Contact) JSON.deserialize(billingContact, Contact.class);
        Contact soldTo = (Contact) JSON.deserialize(soldContact, Contact.class);
        Account salesforceAccount = (Account) JSON.deserialize(account, Account.class);
        //Inizio GDB 10/01/2020
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(zuoraPayment);
        String dc = String.valueOf(m.get('docCountry'));
        if(!String.isblank(dc)){
            List<XC_CM_CountryISOCodeAssociation__mdt> countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: dc];
            m.put('countryCode' , countryCode[0].XC_ISOCode__c);
            zuoraPayment = JSON.serialize(m);
        }
        //Fine GDB 10/01/2020
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        String stream = salesforceAccount.XC_Segment__c;
        if(String.isBlank(stream)) {
            stream = [SELECT XC_Segment__c FROM Account WHERE Id =: salesforceAccount.Id].XC_Segment__c;
            salesforceAccount.XC_Segment__c = stream;
        }
        ZuoraWebservice.CreateZuoraAccountResponse resp = zws.createUnlinkedZuoraAccount(salesforceAccount, billTo, soldTo, options,billingProfLineItemId,zuoraPayment);
        if(resp.Success != null) {
            if(resp.Success.toLowerCase() != 'true') {
                rollbackForError(billingProfLineItemId, resp.reasons[0].code + ' - ' + resp.reasons[0].message);
            }
        }
        return JSON.serialize(resp);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails
     * @param billingProfLineItemId - String
     * @param message - String
     **/
    @TestVisible
    private static void rollbackForError(String billingProfLineItemId, String message) {
        XC_UTIL_DependentPicklist.PicklistWrapper pw = XC_UTIL_DependentPicklist.getDependentPicklist('NE__Billing_Profile__c', 'NE__Payment__c', 'XC_PaymentMethodCategory__c');
        List<String> listPaymentExternal = new List<String>();
        for(String key : pw.pickListMap.keySet()) {
            List<String> listPaymentMethod = pw.pickListMap.get(key);
            for(String mp : listPaymentMethod) {
                if(mp == Label.XC_CL_PaymentType_External) {
                    listPaymentExternal.add(key);
                }
            }
        }
        if(listPaymentExternal.isEmpty()) {
            return;
        }

        List<XC_BillingProfileLineItem__c> listBillingProfile = new List<XC_BillingProfileLineItem__c>([
            SELECT Id, XC_BillingProfile__c, XC_PaymentMethod__c 
            FROM XC_BillingProfileLineItem__c 
            WHERE Id = :billingProfLineItemId
        ]);
        if(listBillingProfile.isEmpty()) {
            return;
        }

        List<XC_BillingProfileLineItem__c> listBplToUpdate = new List<XC_BillingProfileLineItem__c>();
        List<XC_BillingProfileLineItem__c> listBplToDelete = new List<XC_BillingProfileLineItem__c>();
        List<NE__Billing_Profile__c> listBillingProfileToDelete = new List<NE__Billing_Profile__c>();
        for(XC_BillingProfileLineItem__c bp : listBillingProfile) {
            // For external method:
            if(listPaymentExternal.contains(bp.XC_PaymentMethod__c)) {
                listBplToDelete.add(new XC_BillingProfileLineItem__c(Id = bp.Id));
                listBillingProfileToDelete.add(new NE__Billing_Profile__c(Id = bp.XC_BillingProfile__c));
            }
            // For other method:
            else {
                listBplToUpdate.add(new XC_BillingProfileLineItem__c(
                    Id = bp.Id,
                    XC_Status__c = Label.XC_CL_ZuoraInvoiceDraft,
                    XC_ErrorLastCallout__c = message
                ));
            }
        }
        XC_UTIL_Sobject.updateListRecords(listBplToUpdate);
        XC_UTIL_Sobject.deleteListRecords(listBplToDelete);
        XC_UTIL_Sobject.deleteListRecords(listBillingProfileToDelete);
    }


    /**
     * @author
     * @description Method to adjust the Language
     * @param l - String
     * @return String
     **/
    private static String adjustLanguage(String l) { 
        if (l == 'CA') {
            return 'CAT';
        } else if (l == 'ESP') {
            return 'SPA';
        } else if (l == 'DE') {
            return 'DEU';
        } else {
            return l;
        }
    }

    /**
     * @author
     * @description Method to prepare all the information needed and call the CreateUnlinkedZuoraAccount method
     * @param optionsMap - Map<String, Object>
     * @param account - Account
     * @param billTo - Contact
     * @param soldTo - Contact
     * @param billingProfileLineItemId - String
     * @return String
     **/
    public static String prepareForCreateUnlinkedZuoraAccount(String optionsMapJSON, String account, String billTo, String soldTo, String billingProfileLineItemId) {
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(optionsMapJSON);
        String paymentMethod = String.valueOf(optionsMap.get('paymentMethodType'));
        String lang = optionsMap.containsKey('lang') ? String.valueOf(optionsMap.get('lang')) : '';
        
        String legalEntity = String.valueOf(optionsMap.get('legal'));

        String paymentT = 'Due Upon Receipt';
        if(paymentMethod == 'Direct Debt') {
            if(legalEntity == 'EnelXItalia'){
                paymentT = 'Net 15';
            }else{
                paymentT = 'Net 7';

            }
        }else if(paymentMethod == 'Bank Transfer'){
            if(legalEntity == 'EnelXItalia'){
                paymentT = 'Net 30';
            }
        }
        String correctLanguage = adjustLanguage(lang);
        String recordType = optionsMap.containsKey('accountRecordTypeName') ? String.valueOf(optionsMap.get('accountRecordTypeName')) : '';

        String personTypeCode = 'J';
        if (recordType == 'XC_GLO_Account_Residential') {
            personTypeCode = 'F';
        }

        Boolean fromBillingProfile = false;
        String invoiceDel = optionsMap.containsKey('invoiceDel') ? String.valueOf(optionsMap.get('invoiceDel')) : '';
        String docType = optionsMap.containsKey('docNif') ? String.valueOf(optionsMap.get('docNif')) : '';
        String docCountry = optionsMap.containsKey('docCountry') ? String.valueOf(optionsMap.get('docCountry')) : '';
        String docNum = optionsMap.containsKey('docNumber') ? String.valueOf(optionsMap.get('docNumber')) : '';
        String contractId = optionsMap.containsKey('contractId') ? String.valueOf(optionsMap.get('contractId')) : '';

        Map<String, Object> zuoraPaymentMap = new Map<String, Object>();
        zuoraPaymentMap.put('bpId',  String.valueOf(optionsMap.get('accountId')));
        zuoraPaymentMap.put('language',  correctLanguage);
        zuoraPaymentMap.put('fromBillingProfile',  fromBillingProfile);
        zuoraPaymentMap.put('personTypeCode',  personTypeCode);
        zuoraPaymentMap.put('legalE',  legalEntity);
        if(optionsMap.containsKey('VatGroupSequenceSetId')){
            zuoraPaymentMap.put('vatGroupSequenceSetId', String.valueOf(optionsMap.get('VatGroupSequenceSetId'))); 
        }
        zuoraPaymentMap.put('docCountry',  docCountry);
        zuoraPaymentMap.put('smartInvoice',  invoiceDel);
        zuoraPaymentMap.put('docNif',  docType);
        zuoraPaymentMap.put('docNumber',  docNum);
        zuoraPaymentMap.put('contractId',  contractId);

        Map<String, Object> options = new Map<String, Object>();
        options.put('invoiceDeliveryPrefsEmail', String.valueOf(optionsMap.get('invoiceDel')).equals('Email'));
        options.put('invoiceDeliveryPrefsPrint', String.valueOf(optionsMap.get('invoiceDel')).equals('Print'));
        options.put('paymentTerm', paymentT);
        //options.put('XC_SplitPayment__c ', String.valueOf(optionsMap.get('XC_SplitPayment__c')));

        if (paymentMethod == 'Direct Debt') {
                options.put('paymentGateway', 'SIA PH SDD');
                
        } else if(paymentMethod == 'Commodity Bill' && Boolean.valueOf(optionsMap.get('contractBatch')) &&  String.valueOf(optionsMap.get('getContractBy')) == 'IdentityDoc') { //
            
            options.put('batch', Boolean.valueOf(optionsMap.get('contractBatch')));
            options.put('XC_CommodityAccountId__c', String.valueOf(optionsMap.get('commodityAccountId')));

            if(Boolean.valueOf(optionsMap.get('commodityBillingCycleFrequency'))){
                options.put('XC_CommodityFrequency__c', String.valueOf(optionsMap.get('commodityBillingCycleFrequency')));
            }
        }

        String zuoraPaymentJSON = JSON.serialize(zuoraPaymentMap);
        String optionsJSON = JSON.serialize(options);
        //String billingContact = JSON.serialize(billTo);
        //String soldContact = JSON.serialize(soldTo);
        String entityName;
        if(optionsMap.containsKey('entityName')){
            entityName = String.valueOf(optionsMap.get('entityName'));
        }
        
        String paymentMethodCategory = String.valueOf(optionsMap.get('paymentMethodCategoryVal'));
        String sepaMandateDate= String.valueOf(optionsMap.get('sepaMandateDate'));
        String sepaMandate= String.valueOf(optionsMap.get('sepaMandate'));
        String responseCreateUnlinkedZuoraAccount;
        if(!Test.isRunningTest()){
            responseCreateUnlinkedZuoraAccount = createUnlinkedZuoraAccount(account, billTo, soldTo, entityName, optionsJSON, billingProfileLineItemId, zuoraPaymentJSON);
        }
        return responseCreateUnlinkedZuoraAccount;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails for create payment method
     * @param paymentMethod - String
     * @param entityName - String
     * @param billingProfLineItemId - String
     * @return String
     **/
    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName, String billingProfLineItemId){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.CreatePaymentMethodResponse resp = zws.createPaymentMethod(paymentMethod);
        if(resp.Success != null) {
            if(resp.Success.toLowerCase() != 'true') {
            	rollbackForError(billingProfLineItemId, resp.Errors[0].Code + ' - ' + resp.Errors[0].Message);
            }
        }
        return JSON.serialize(resp);
    }

    /**
    * @description save integration logs from component
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-10-2020 
    * @param integrationLogList 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean saveIntegrationLog(String integrationLogList){
        List<XC_Integration_Log__c> logs = (List<XC_Integration_Log__c>) JSON.Deserialize(integrationLogList,List<XC_Integration_Log__c>.class);
        Boolean operationResult = true;
        List<XC_UTIL_Sobject.WrapperResult> results =  XC_UTIL_Sobject.insertListRecords(logs);
        operationResult = XC_UTIL_Sobject.checkDMLResults(results);
        return operationResult;
    }
}