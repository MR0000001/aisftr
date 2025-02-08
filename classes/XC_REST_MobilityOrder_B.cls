/**
 * The Class XC_REST_MobilityOrder_B.
 *
 * @author            : Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 30/08/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_MobilityOrder to managae new billing profile
 **/ 



public without sharing class XC_REST_MobilityOrder_B {

    
    /**
     * Create new billing profile for legal entity 
     *
     * @param params the Map
     * @param wrResp the wrapper response
     * @description method to create Billing Profile
    */
    public static XC_BillingProfileLineItem__c createBillingProfile(Map<String, Object> params, XC_REST_MobilityOrder_W.WrapperResponse wrResp){

        XC_BillingProfileLineItem__c billingProfLi = (XC_BillingProfileLineItem__c) params.get('billingProfLi');
        String legalEntity = (String) params.get('legalEntity');
        String deliveryAddressId = (String) params.get('deliveryAddressId');
        String transactionId = (String) params.get('TransactionID');

        Map<Id, Account> mapAcc = new Map<Id,Account>([
                        SELECT Id, XC_Segment__c, XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_isGuestUser__c, PrimaryEmail__c, XC_AccountType__c , XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c,
                        IdentityNumber__c, IdentityType__c, Country__c,  XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c, XC_RecordTypeDeveloperName__c, XC_Country__c,
                        (SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_Country__c  FROM Personal_Documents__r  ORDER BY CreatedDate desc),  
                        (SELECT Id, XC_InvoiceDeliveryPref__c, NE__Payment__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, NE__Expiration__c, NE__Expiration_Year__c, 
                        NE__Iban__c, XC_InvoicePreferredLanguage__c, XC_SepaMandateDate__c, XC_SepaMandate__c, XC_CommodityContractID__c, XC_Segment__c, XC_PayPalUsername__c
                        FROM NE__Billing_Profiles__r WHERE Id =: billingProfLi.XC_BillingProfile__c) 
                        FROM Account WHERE Id =: billingProfLi.XC_BillingProfile__r.NE__Account__c ]);

        Account bpAccount = mapAcc.values()[0];
        NE__Billing_Profile__c  billingProfile = bpAccount.NE__Billing_Profiles__r[0];

        String billAddrId = billingProfLi.XC_BillToAddress__c;
        String soldAddrId = deliveryAddressId;
        
        /*String contactSoldSerialized;
        String contactBillSerialized;

        if(soldAddrId == billAddrId){
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrWr = ZuoraBillingProfileCreationController.prepareContactForZuora(billingProfLi.XC_BillToContactId__c, soldAddrId, bpAccount.Country__c);
            contactSoldSerialized = JSON.Serialize(conAddrWr);
            contactBillSerialized = JSON.Serialize(conAddrWr);
        }else{ 
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrBillWr = ZuoraBillingProfileCreationController.prepareContactForZuora(billingProfLi.XC_BillToContactId__c, billAddrId, bpAccount.Country__c);
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrSoldWr = ZuoraBillingProfileCreationController.prepareContactForZuora(billingProfLi.XC_SoldToContactId__c, soldAddrId, bpAccount.Country__c);
            contactBillSerialized = JSON.Serialize(conAddrBillWr);
            contactSoldSerialized = JSON.Serialize(conAddrSoldWr);
        }


        Contact cBillTo = (Contact) JSON.deserialize(contactBillSerialized, Contact.class);
        Contact cSoldTo = (Contact) JSON.deserialize(contactSoldSerialized, Contact.class);*/


        

        XC_BillingProfileLineItem__c billingProfileLineItemToInsert = new XC_BillingProfileLineItem__c ( XC_BillingProfile__c = billingProfile.Id, 
                                                                            XC_BillToAddress__c = billAddrId, XC_SoldToAddress__c = soldAddrId, 
                                                                            XC_BillToContactId__c = billingProfLi.XC_BillToContactId__c, XC_SoldToContactId__c = billingProfLi.XC_SoldToContactId__c,
                                                                            XC_BillingProfileName__c = billingProfLi.XC_BillingProfileName__c, XC_Status__c = 'Draft',
                                                                            XC_LegalEntity__c = legalEntity, XC_ExternalKey__c = billingProfLi.XC_ExternalKey__c, 
                                                                            XC_PEC__c = billingProfLi.XC_PEC__c, XC_RecipientCode__c = billingProfLi.XC_RecipientCode__c,
                                                                            XC_InvoiceDeliveryPreference__c = (!String.isBlank(billingProfile.XC_InvoiceDeliveryPref__c) && billingProfile.XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : billingProfile.XC_InvoiceDeliveryPref__c, 
                                                                            XC_InvoicePreferredLanguage__c = billingProfile.XC_InvoicePreferredLanguage__c
                                                                            );
                   
        // set invoiceDeliveryPrefsPrint to true if the contact missing the email
        if(!String.isBlank(billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c) && (billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase(Label.XC_CL_BpliInvoiceDeliveryPref)
            || billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Email')) &&  String.isBlank(billingProfLi.XC_BillToContactId__r.Email)){
                billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c = 'Print';
        }

        XC_UTIL_Sobject.WrapperResult resultInsertBPLI = XC_UTIL_Sobject.insertRecord(billingProfileLineItemToInsert); 
        if(!resultInsertBPLI.success) {
            wrResp.Result.Message = 'INTERNAL ERROR: '+ resultInsertBPLI.errorMessage;
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.logError = 'INTERNAL ERROR: '+ resultInsertBPLI.errorMessage;
            return null; 
        }

        Map<String, Object> mapAccountDocument = new Map<String,Object>{'legalEntity' => legalEntity,'bpAccount' => bpAccount};
        manageDocument(mapAccountDocument);

        String docNif = (String) mapAccountDocument.get('docNif');
        String docNumber = (String) mapAccountDocument.get('docNumber');
        String expedition = (String) mapAccountDocument.get('expedition');
        String expiration = (String) mapAccountDocument.get('expiration');
        String docCountry = (String) mapAccountDocument.get('docCountry');
        String countryCode  = (String) mapAccountDocument.get('countryCode');


        Map<String,Object> paymentMethod = manageBpForZuora(billingProfile);

        mapAccountDocument.put('billingProfile', billingProfile);
        XC_REST_Account_B.wrapperOption wrOptions =  manageWrapperOption(mapAccountDocument);


        Map<String,Object>  zuoraPayment = new Map<String,Object>{'bpId' => billingProfileLineItemToInsert.Id,
                                                                    'fromBillingProfile' => false,
                                                                    'docNif' => (String.isBlank(docNif)) ? '': docNif,
                                                                    'docNumber' => (String.isBlank(docNumber)) ?  '': docNumber,
                                                                    'countryCode' => (String.isBlank(countryCode)) ?  '': countryCode,
                                                                    'expedition' => (String.isBlank(expedition)) ? '': expedition,
                                                                    'expiration' => (String.isBlank(expiration)) ? '': expiration,
                                                                    'personTypeCode' => (!String.isBlank(bpAccount.XC_RecordTypeDeveloperName__c) && bpAccount.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential')) ? 'F' : 'J',
                                                                    'sequenceSetId' => wrOptions.SimplifiedInvoiceReplace,  // GUEST Sequence Set
                                                                    'zuoraSequenceSetId' => wrOptions.zuoraSequenceSetId,   // DEFAULT Sequence Set
                                                                    'invoicePreferredLanguage' => billingProfile.XC_InvoicePreferredLanguage__c,
                                                                    'taxInfo' => 'No',
                                                                    'legalE' => legalEntity,
                                                                    'contractId' => !String.isBlank(billingProfile.XC_CommodityContractID__c) ? billingProfile.XC_CommodityContractID__c : ''
                                                                    };                

        wrOptions.zuoraSequenceSetId = null;
        Map<String,String>  zuoraMap = new Map<String,String>{'account' =>  JSON.Serialize(bpAccount, true),
                                                                /*'billingContact' => contactBillSerialized,
                                                                'soldContact' => contactSoldSerialized,*/
                                                                'legalEntity' => legalEntity,
                                                                'options' => (JSON.Serialize(wrOptions, true)).replace('Replace', '__c'),
                                                                'billingProfLineItemId' => billingProfileLineItemToInsert.Id,
                                                                'zuoraPayment' => JSON.serialize(zuoraPayment, true),
                                                                'mapPayment' => JSON.serialize(paymentMethod, true),
                                                                'billingProfId' => billingProfile.Id,
                                                                'bpli' => JSON.serialize(billingProfileLineItemToInsert, true),
                                                                'country' => bpAccount.Country__c,
                                                                'TransactionID' => transactionId
                                                                };    
        XC_REST_Account_B.callZuora(zuoraMap);

        return billingProfileLineItemToInsert; 

    }


    /**
    * Manage account document
    *
    * @param mapAccountDocument the map util 
    * @description method to manage account document
    */
    public static void manageDocument(Map<String,Object> mapAccountDocument){

        Account bpAccount = (Account)mapAccountDocument.get('bpAccount');
        String legalEntity = (String)mapAccountDocument.get('legalEntity');
        String stream = bpAccount.XC_Segment__c;

        String docNif;
        String docNumber;
        String expedition;
        String expiration;
        String docCountry;

        if(!bpAccount.Personal_Documents__r.isEmpty()){
            docNif      = bpAccount.Personal_Documents__r[0].XC_DocumentType__c;
            docNumber   =  bpAccount.Personal_Documents__r[0].XC_DocumentNumber__c;
            expedition  = String.valueOf(bpAccount.Personal_Documents__r[0].XC_ReleaseDate__c);
            expiration  = String.valueOf(bpAccount.Personal_Documents__r[0].XC_ExpirationDate__c);
            docCountry  = bpAccount.Personal_Documents__r[0].XC_Country__c;
        }else {
            docNif      = bpAccount.IdentityType__c;
            docNumber   =  bpAccount.IdentityNumber__c;
            expedition  = String.valueOf(bpAccount.XC_NIE_expedition_date__c);
            expiration  = String.valueOf(bpAccount.XC_NIE_expiration_date__c);
            docCountry  = bpAccount.XC_DocumentCountry__c;
        }

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalInfoMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_Country__c, XC_ValidDocuments__c, XC_SkipZuoraGuest__c, XC_ZuoraSequenceSetId__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: legalEntity AND XC_Stream__c =: stream AND XC_OrgId__c =: orgId]);
        XC_CM_LegalEntity_Configuration__mdt legalInfo = legalInfoMap.values()[0];
        List<String> validDocuments = new List<String>();
        if(String.isNotBlank(legalInfo.XC_ValidDocuments__c)) {
            validDocuments.addAll(legalInfo.XC_ValidDocuments__c.split(';'));
        }

        //if(String.isNotBlank(docNif) && (!docCountry.equalsIgnoreCase(legalInfo.XC_Country__c) || (docCountry.equalsIgnoreCase(legalInfo.XC_Country__c) && !validDocuments.contains(docNif)))) {
        if(String.isNotBlank(docNif) && !validDocuments.contains(docNif)) {
        	docNif = '';
            docNumber = '';
            expedition = '';
            expiration = '';
            docCountry = '';
        }

        
        mapAccountDocument.put('docNif', docNif);
        mapAccountDocument.put('docNumber', docNumber);
        mapAccountDocument.put('expedition', expedition);
        mapAccountDocument.put('expiration', expiration);
        mapAccountDocument.put('docCountry', docCountry);
        mapAccountDocument.put('validDocuments', validDocuments);
        mapAccountDocument.put('legalInfo', legalInfo);

        manageValidDocument(mapAccountDocument);
    }


    /**
    * Manage valid document
    *
    * @param mapAccountDocument the map util 
    * @description method to manage valid document
    */
    public static void manageValidDocument(Map<String,Object> mapAccountDocument){

        String countryCode; 
        String docNif = (String) mapAccountDocument.get('docNif');
        String docNumber = (String) mapAccountDocument.get('docNumber');
        String expedition = (String) mapAccountDocument.get('expedition');
        String expiration = (String) mapAccountDocument.get('expiration');
        String docCountry = (String) mapAccountDocument.get('docCountry');
        Account bpAccount = (Account)mapAccountDocument.get('bpAccount');
        List<String> validDocuments = (List<String>) mapAccountDocument.get('validDocuments');
        XC_CM_LegalEntity_Configuration__mdt legalInfo = (XC_CM_LegalEntity_Configuration__mdt) mapAccountDocument.get('legalInfo');


        if(String.isBlank(docNif) && String.isBlank(docNumber)){

            Map<Id, XC_PersonalDocument__c> documentsMap = new Map<Id, XC_PersonalDocument__c>([SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_Country__c FROM XC_PersonalDocument__c WHERE XC_Account__c =: bpAccount.Id /*AND XC_Country__c =: legalInfo.XC_Country__c*/ ORDER BY CreatedDate desc]);
            Boolean foundValidDocument = false;
            for(XC_PersonalDocument__c doc : documentsMap.values()) {
                if(validDocuments.contains(doc.XC_DocumentType__c) && (!foundValidDocument || (foundValidDocument && doc.XC_Country__c == legalInfo.XC_Country__c))) {
                    foundValidDocument = true;
                    docNif = doc.XC_DocumentType__c;
                    docNumber = doc.XC_DocumentNumber__c;
                    docCountry = doc.XC_Country__c;
                    expedition = (doc.XC_ReleaseDate__c != null) ? String.valueOf(bpAccount.Personal_Documents__r[0].XC_ReleaseDate__c) : '';
                    expiration = (doc.XC_ExpirationDate__c != null) ? String.valueOf(bpAccount.Personal_Documents__r[0].XC_ExpirationDate__c) : '';
                    if(doc.XC_Country__c == legalInfo.XC_Country__c) {
                        break;
                    }
                }
            }
        }

        if(!String.isBlank(docCountry)){
            countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: docCountry][0].XC_ISOCode__c;
        }

        mapAccountDocument.put('docNif', docNif);
        mapAccountDocument.put('docNumber', docNumber);
        mapAccountDocument.put('expedition', expedition);
        mapAccountDocument.put('expiration', expiration);
        mapAccountDocument.put('docCountry', docCountry);
        mapAccountDocument.put('countryCode', countryCode);
    }


    /**
     * Manage billing profile info to sent to zuora
     *
     * @param billingProfile the billing Profile
     * @return Map<String,Object> the map util
     * @description method to manage billing profile info
     */
    public static Map<String,Object> manageBpForZuora(NE__Billing_Profile__c  billingProfile){

        Map<String,Object> paymentMethod = new Map<String,Object>();

        Map<String,String> creditCardType = new Map<String, String> {   
            'MASTERCARD' => 'MasterCard', 
            'VISA' => 'Visa',
            'DISCOVER' => 'Discover',
            'AMEX' => 'AmericanExpress',
            'PAYPAL' => 'PayPal'
        };

        List<String> externalPaymentList = new List<String>{'External Financing', 'Cash', 'Bank Transfer', 'Commodity Bill', 'Barcode', 'Online'};

        if(externalPaymentList.contains(billingProfile.NE__Payment__c)) {
            paymentMethod.put('Type', billingProfile.NE__Payment__c);

        }else if(billingProfile.NE__Payment__c == 'Credit Card'){
            paymentMethod.put('Type', 'CreditCardReferenceTransaction');
            paymentMethod.put('TokenId', billingProfile.XC_Token__c);
            paymentMethod.put('CreditCardExpirationMonth', billingProfile.NE__Expiration__c);
            paymentMethod.put('CreditCardExpirationYear', billingProfile.NE__Expiration_Year__c);
            //paymentMethod.put('CreditCardHolderName', bpQ.CreditCardHolder);
            paymentMethod.put('SecondTokenId', billingProfile.XC_PayPalUsername__c);
            if(!String.isBlank(billingProfile.NE__Card_Number__c)){
                paymentMethod.put('CreditCardNumber', billingProfile.NE__Card_Number__c.substring(12)); 
            }
            if(billingProfile.NE__Card_Type__c != null) {
                paymentMethod.put('CreditCardType', creditCardType.get((billingProfile.NE__Card_Type__c).toUpperCase()));
            }    

        } else if(billingProfile.NE__Payment__c == 'Direct Debt') {
            paymentMethod.put('Type', 'BankTransfer');
            paymentMethod.put('BankTransferType', 'SEPA');
            paymentMethod.put('BankTransferAccountNumber', billingProfile.XC_Token__c);
            paymentMethod.put('IBAN', billingProfile.NE__Iban__c);
            //paymentMethod.put('BankTransferAccountNumber', billingProfile.NE__Iban__c);
            paymentMethod.put('TokenId', billingProfile.XC_Token__c);
            paymentMethod.put('MandateID', billingProfile.XC_SepaMandate__c);
            paymentMethod.put('MandateCreationDate', billingProfile.XC_SepaMandateDate__c);
        }

        System.debug('paymentMethod: '+ paymentMethod);
        return paymentMethod;   
    }


    /**
    * Manage wrapper option info to sent to zuora
    *
    * @param Account the account
    * @param BillingProfile the billing profile
    * @param docNif the document type
    * @return XC_REST_Account_B.WrapperOption
    * @description method to manage wrapper options
    */
    public static XC_REST_Account_B.WrapperOption manageWrapperOption(Map<String,Object> mapAccountDocument) {
        
        Account bpAccount = (Account) mapAccountDocument.get('bpAccount');
        NE__Billing_Profile__c billingProfile = (NE__Billing_Profile__c) mapAccountDocument.get('billingProfile');
        String docNif = (String) mapAccountDocument.get('docNif');
        String legalEntity = (String) mapAccountDocument.get('legalEntity'); 
        XC_CM_LegalEntity_Configuration__mdt legalInfo = (XC_CM_LegalEntity_Configuration__mdt) mapAccountDocument.get('legalInfo');

        XC_REST_Account_B.wrapperOption wrOptions = new XC_REST_Account_B.wrapperOption();

        Boolean invoiceEmail;
        Boolean invoicePrint;
        String payment;
        
   
        invoiceEmail = (billingProfile.XC_InvoiceDeliveryPref__c == 'Email' || (!String.isBlank(billingProfile.XC_InvoiceDeliveryPref__c) && billingProfile.XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart'))) ? true : false;
        invoicePrint = (billingProfile.XC_InvoiceDeliveryPref__c == 'Print') ? true : false;
        
        
        payment = (billingProfile.NE__Payment__c  == 'SEPA' || billingProfile.NE__Payment__c == 'Direct Debt') ? 'Net 7' : 'Due Upon Receipt';

       

        wrOptions.XC_isGuestReplace = (bpAccount.XC_isGuestUser__c == true) ? 'Yes' : 'No'; 
        wrOptions.XC_isGuestReplace = (legalInfo != null && legalInfo.XC_SkipZuoraGuest__c) ? 'No' : wrOptions.XC_isGuestReplace;
        if(wrOptions.XC_isGuestReplace == 'Yes') {
            wrOptions.SimplifiedInvoiceReplace = 'Yes';
        } else if (legalInfo != null && legalInfo.XC_SkipZuoraGuest__c) {
            wrOptions.SimplifiedInvoiceReplace = 'No';
        } else {
            wrOptions.SimplifiedInvoiceReplace = (String.isBlank(docNif)) ? 'Yes' : 'No';
        }

        wrOptions.invoiceDeliveryPrefsEmail = invoiceEmail;
        wrOptions.invoiceDeliveryPrefsPrint = invoicePrint;
        wrOptions.paymentTerm = (payment == 'Net 7' && !String.isBlank(legalEntity) && legalEntity == 'EnelXItalia') ? 'Net 10' : payment;
        wrOptions.billCycleDay = 0;
        wrOptions.XC_SplitPaymentReplace = (bpAccount.XC_SplitPayment__c) ? 'Yes' : 'No';
        //wrOptions.billCycleDay = 1;
        if(payment == 'Net 7' || payment == 'Net 10'){
            wrOptions.paymentGateway = 'SIA PH SDD';
        }

        wrOptions.zuoraSequenceSetId = (legalInfo != null && String.isNotBlank(legalInfo.XC_ZuoraSequenceSetId__c)) ? legalInfo.XC_ZuoraSequenceSetId__c : null;

        return wrOptions;
    }

}