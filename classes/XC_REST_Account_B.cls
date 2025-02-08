/**
 *
 * @author : Francesco Imperioli - fimperioli@deloitte.it
 * @date Creation :       25/07/2019
 * @date Modification :   
 * @description :         XC_REST_Account_U – Util for Rest Resourse to Create/Update Account Billing Profile
 * 
 */

public without sharing class XC_REST_Account_B {

    
    /* @description the wrapperInfo */
    public class wrapperInfo{

        public String accountId;
        public String paymentMethodType;
        public String cardNumber;
        public String month;
        public String year;
        public String accountNumber;
        public String contractId;
        public String cupsId;
        public String legal;
        public Boolean fromBillingProfile;
        public String billingProfileId;
        public String creditCardExternalKey; 
        public String siaPayment;
        public String invoiceDeliveryPref;
        public String invoicePreferredLanguage;
        public String email;
        public String postalCode;
        public String city;
        public String iban;
        public String state;
        public String creditCardType;
        public String SEPAMandateId;
        public String SEPAMandateDate;
        public String SEPABIC;
        public String SEPAMandateType;
        public String certifiedEmail;
        public String recipientCode;
        public String clientSystem;
        public String payPalUsername;
        public String commodityBillingCycleFrequency;

        public String SAPBusinessPartner;
        public String Status;
        public String Reason;
        public String ReasonDetails;
        public Date EventDate;
        public String CommodityUsage;
        public String ConsumptionNumber;
        //public String ProductID;
        //public String OrderID;
        public String OPDocumentNumber;
        public String OPDocumentType;
        public Boolean SkipDuplication;
        public Boolean CurrentActiveEmobApp;
    }


    /**
    * @description WrapperOption 
    */
    public class WrapperOption{
        public Boolean invoiceDeliveryPrefsEmail;
        public Boolean invoiceDeliveryPrefsPrint;
        public String paymentTerm; 
        public Integer billCycleDay;
        public String SimplifiedInvoiceReplace;
        public String XC_isGuestReplace;
        public String paymentGateway;
        public String XC_SplitPaymentReplace;
        public String XC_CommodityFrequencyReplace; 
        public String XC_CommodityAccountIdReplace;
        public String vatGroupSequenceSetId;
        public String zuoraSequenceSetId;
        public String batch;
    }

    
    /*
    * @param mapInfos - Map<String,Object>
    * @return thw wrapperInfo
    * @description Method to populate WrapperInfo
    */
    public static wrapperInfo populateWrapperInfo(XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfile, Map<String,Object> mapInfos){

        Contact cont = (mapInfos.get('contactInfo')!= null) ?  (Contact) (JSON.Deserialize ((String)mapInfos.get('contactInfo'), Contact.class)) : null;
        wrapperInfo wr = new wrapperInfo();

        wr.accountId = (String)mapInfos.get('accountId');
        wr.paymentMethodType = billingProfile.PaymentMethod;
        wr.cardNumber = (billingProfile.CreditCardLastFourNumber != null) ?'000000000000'+billingProfile.CreditCardLastFourNumber : null; 
        wr.month = billingProfile.ExpirationMonth;
        wr.year = billingProfile.ExpirationYear;
        wr.accountNumber = billingProfile.IBAN;
        wr.contractId = (String.valueOf(mapInfos.get('clientSystem')).equalsIgnoreCase('CommodityItalyB2C') && String.isNotBlank(billingProfile.CommodityCC)) ? billingProfile.CommodityCC : billingProfile.CommodityContractNum;
        wr.cupsId = (String.isBlank(billingProfile.CupsID)) ? billingProfile.CommodityCupsID : billingProfile.CupsID;
        /*if(billingProfile.BillingProfileID == null){
            wr.legal = (billingProfile.legalEntity != null) ? billingProfile.legalEntity : (String) mapInfos.get('legalEntity');
        }else if(billingProfile.BillingProfileID != null && billingProfile.legalEntity != null){
            wr.legal = billingProfile.legalEntity;
        }*/
        wr.legal = (billingProfile.legalEntity != null) ? billingProfile.legalEntity : (String) mapInfos.get('legalEntity');
        wr.fromBillingProfile = false;
        wr.creditCardExternalKey = billingProfile.creditCardExternalKey;
        wr.recipientCode = billingProfile.RecipientCode;
        wr.certifiedEmail = billingProfile.CertifiedEmail;
        wr.siaPayment = (billingProfile.Token != null) ? '{"debtorCode":"' + billingProfile.Token + '"}' : null;
        wr.invoiceDeliveryPref = (String.isBlank(billingProfile.BillingProfileID) && cont != null && (billingProfile.InvoiceDeliveryPref.containsIgnoreCase('Smart') ||
                                  billingProfile.InvoiceDeliveryPref.equalsIgnoreCase('Email')) && String.isBlank(cont.Email)) 
                                ? 'Print': billingProfile.InvoiceDeliveryPref;  // set invoiceDeliveryPrefsPrint to true if the contact missing the email
      
        if(billingProfile.InvoicePreferredLanguage != null) {
            wr.invoicePreferredLanguage = getPreferredLanguage(billingProfile.InvoicePreferredLanguage);
        }

        wr.email = billingProfile.Email;
        wr.postalCode = billingProfile.postalCode;
        wr.state = billingProfile.state;
        wr.city = billingProfile.city;
        wr.creditCardType = billingProfile.CreditCardType;
        wr.SEPAMandateId = billingProfile.SEPAMandateId;
        wr.SEPAMandateDate = billingProfile.SEPAMandateDate;    
        wr.SEPABIC = billingProfile.SEPABIC;
        wr.SEPAMandateType = billingProfile.SEPAMandateType; 
        wr.clientSystem = (String) mapInfos.get('clientSystem');
        wr.payPalUsername = billingProfile.PayPalUsername;
        wr.commodityBillingCycleFrequency = (String.isBlank(billingProfile.BillingProfileID)) ? billingProfile.CommodityBillingCycleFrequency : '';
        wr.SAPBusinessPartner = billingProfile.SAPBusinessPartner;
        wr.Status = billingProfile.Status;
        if(String.isBlank(wr.SAPBusinessPartner)) wr.SAPBusinessPartner = billingProfile.CommodityBP; /*20220331 NicoloFodera correctly ingest CommodityBP*/
        wr.Reason = billingProfile.Reason;
        wr.ReasonDetails = billingProfile.ReasonDetails;
        wr.EventDate = billingProfile.EventDate;
        wr.CommodityUsage = billingProfile.CommodityUsage;
        wr.ConsumptionNumber = billingProfile.ConsumptionNumber;
        //wr.ProductID = billingProfile.ProductID;
        //wr.OrderID = billingProfile.OrderID;
        wr.OPDocumentNumber = billingProfile.OPDocumentNumber;
        wr.OPDocumentType = billingProfile.OPDocumentType;
        wr.SkipDuplication = billingProfile.SkipDuplication;
        wr.CurrentActiveEmobApp = billingProfile.CurrentActiveEmobApp;


        return wr;
    }


    /*
    * @param prefereddLanguage - String
    * @return the preferred language
    * @description Method to get preferred language
    */
    public static String getPreferredLanguage(String prefereddLanguage){
        
        List<Schema.PicklistEntry> picklist = Schema.NE__Billing_Profile__c.XC_InvoicePreferredLanguage__c.getDescribe().getPicklistValues();
        Set<String> picklistValues = new Set<String>();
        for(Schema.PicklistEntry pe : picklist) {
            if(pe.isActive()) {
                picklistValues.add(pe.getValue());
            }
        }
        String language = (picklistValues.contains(prefereddLanguage)) ? prefereddLanguage : 'English';
        
        return language;
    }


    
    /**
    * @param mapInfos - Map<String,String>
    * @param wrResp - XC_REST_Account_W.WrapperResponse
    * @return the preferred language
    * @description Method to get preferred language
    */
    public static void checkAddressToAssociate(Map<String,String> mapInfos, XC_REST_Account_W.WrapperResponse wrResp){
        
        if(String.isBlank(mapInfos.get('billId'))){
            wrResp.Result.Message = 'INTERNAL ERROR: Missing BillingAddress to associate with the billing profile';
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.logError = 'INTERNAL ERROR: Missing BillingAddress to associate with the billing profile';
            return;
        }
        if(String.isBlank(mapInfos.get('soldId'))){
            wrResp.Result.Message = 'INTERNAL ERROR: Missing SoldAddress to associate with the billing profile';
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.logError = 'INTERNAL ERROR: Missing SoldAddress to associate with the billing profile';
            return;
        }
    }


    /**
    * @param billingProfileList - List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>
    * @param mapInfos - Map<String,String>
    * @param wrResp - XC_REST_Account_W.WrapperResponse
    * @return Map<Id, NE__Billing_Profile__c>
    * @description Method to check billing profile
    */
    public static Map<Id, NE__Billing_Profile__c> checkBillingProfile(List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList, Map<String,String> mapInfos, XC_REST_Account_W.WrapperResponse wrResp){

        Map<Id, utilWrapper> bilingProfWrMap = new Map<Id, utilWrapper>();
        Integer i = 0;
        for(XC_UTIL_BillingProfile.BillingProfileIFWrapper billProfWr : billingProfileList) {
            if(!String.isBlank(billProfWr.BillingProfileID)){
                utilWrapper wr = new utilWrapper();
                wr.i = i;
                wr.billProfileWr = billProfWr;
                bilingProfWrMap.put(billProfWr.BillingProfileID, wr);
            }
            i++;
        }

        // Check if billing profile exists and if it has one billing profile line item 
        Map<Id, NE__Billing_Profile__c> mapBp = new  Map<Id, NE__Billing_Profile__c>();
        if(!bilingProfWrMap.isEmpty()){
            mapBp =  new Map<Id, NE__Billing_Profile__c>([SELECT Name, NE__Iban__c,  XC_Province__c, XC_City__c, XC_ZipCode__c, NE__Mail_To__c, XC_InvoicePreferredLanguage__c, NE__Account__c, 
                                                            XC_Status__c, XC_CommodityContractID__c, XC_CommodityCupsID__c,  XC_InvoiceDeliveryPref__c, NE__Card_Number__c, NE__Payment__c, 
                                                            XC_Token__c, NE__Card_Type__c, NE__Expiration__c, NE__Expiration_Year__c, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_PayPalUsername__c,
                                                            XC_CommodityBillingCycleFrequency__c, XC_SAPBusinessPartner__c, XC_StatusReason__c, XC_StatusReasonDetails__c, XC_LastEventDate__c,
                                                            XC_CommodityUsage__c, XC_ConsumptionNumber__c, XC_OPDocumentNumber__c, XC_OPDocumentType__c, XC_SkipDuplication__c, XC_CurrentActiveEmobApp__c,
                                                            (SELECT Id, XC_BillToContactId__c, XC_LegalEntity__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_SoldToContactId__c, XC_BillingProfile__c, XC_Status__c, XC_BillToContactId__r.Email, XC_TPBCode__c FROM Billing_Profile_Line_Items__r)
                                                        FROM NE__Billing_Profile__c WHERE Id IN: bilingProfWrMap.keySet() AND NE__Account__c =: mapInfos.get('accountId') ]);//[2021-09-30 :: TP :: Third Party Billing :: Added new field XC_TPBCode__c]
            for(String bpId : bilingProfWrMap.keySet()){
                if(!mapBp.KeySet().contains(bpId)){
                    wrResp.Result.Message = 'INTERNAL ERROR: BillingProfile with id '+ bpId + ' does not exist for the Account ' + mapInfos.get('accountId');
                    wrResp.Result.ErrorCode = '500';
                    wrResp.Result.logError = 'INTERNAL ERROR: BillingProfile with id '+ bpId +' does not exist for the Account ' + mapInfos.get('accountId');
                    return new  Map<Id, NE__Billing_Profile__c>();
                }
                
                NE__Billing_Profile__c bp = mapBp.get(bpId);
                XC_UTIL_BillingProfile.BillingProfileIFWrapper billProfWr = bilingProfWrMap.get(bpId).billProfileWr;
                Integer index = bilingProfWrMap.get(bpId).i;
                if(billProfWr.Status == 'Active') {
                    if(String.isNotBlank(bp.XC_CommodityCupsID__c) && String.isNotBlank(billProfWr.CommodityCupsID) && bp.XC_CommodityCupsID__c != billProfWr.CommodityCupsID) {
                        billingProfileList.get(index).Status = 'Refused';
                        billingProfileList.get(index).Reason = 'Cancellation';
                        billingProfileList.get(index).ReasonDetails = 'Different CommodityCupsID';
                    } else if(String.isNotBlank(bp.XC_OPDocumentType__c) && String.isNotBlank(billProfWr.OPDocumentType) && bp.XC_OPDocumentType__c != billProfWr.OPDocumentType) {
                        billingProfileList.get(index).Status = 'Refused';
                        billingProfileList.get(index).Reason = 'Cancellation';
                        billingProfileList.get(index).ReasonDetails = 'Different OPDocumentType';
                    } else if(String.isNotBlank(bp.XC_OPDocumentNumber__c) && String.isNotBlank(billProfWr.OPDocumentNumber) && bp.XC_OPDocumentNumber__c != billProfWr.OPDocumentNumber) {
                        billingProfileList.get(index).Status = 'Refused';
                        billingProfileList.get(index).Reason = 'Cancellation';
                        billingProfileList.get(index).ReasonDetails = 'Different OPDocumentNumber';
                    }
                }
            }

            for(NE__Billing_Profile__c bp : mapBp.values()){
                if(bp.Billing_Profile_Line_Items__r.isEmpty()){
                    wrResp.Result.Message = 'INTERNAL ERROR: No Billing Profile Line Item found for BillingProfile with id '+ bp.id;
                    wrResp.Result.ErrorCode = '500';
                    wrResp.Result.logError = 'INTERNAL ERROR: No Billing Profile Line Item found for BillingProfile with id '+ bp.id;
                    return new  Map<Id, NE__Billing_Profile__c>();
                }
            }
        }
        
        return mapBp;
    }


    /**
    * @param mapUtilBp - Map<String,Object>
    * @param wrResp - XC_REST_Account_W.WrapperResponse
    * @return List<XC_BillingProfileLineItem__c>
    * @description Method to manage billing profile line item
    */    
    public static List<XC_BillingProfileLineItem__c> manageBpli(Map<String,Object> mapUtilBp, XC_REST_Account_W.WrapperResponse wrResp){

        Map<String,String> mapInfos = (Map<String,String>) mapUtilBp.get('mapInfos');                                                        
        Map<Id, NE__Billing_Profile__c> mapBp = (Map<Id, NE__Billing_Profile__c>) mapUtilBp.get('mapBp');
        Map<Id, Map<String,String>>  billingProfMapLe = (Map<Id, Map<String,String>>) mapUtilBp.get('billingProfMapLe');
        List<NE__Billing_Profile__c> billProfListToInsert = (List<NE__Billing_Profile__c>) mapUtilBp.get('billProfListToInsert');
        Map<NE__Billing_Profile__c, XC_UTIL_BillingProfile.BillingProfileIFWrapper> reverseBpMap = (Map<NE__Billing_Profile__c, XC_UTIL_BillingProfile.BillingProfileIFWrapper>) mapUtilBp.get('reverseBpMap');
        
        Map<Id,XC_BillingProfileLineItem__c> mapBpli = new Map<Id,XC_BillingProfileLineItem__c>([SELECT Id, (SELECT id FROM Configuration_Items__r) 
                                                                                                 FROM XC_BillingProfileLineItem__c 
                                                                                                 WHERE XC_BillingProfile__c IN: mapBp.keySet()]);


        String soldAddrId = mapInfos.get('soldId');
        String billAddrId = mapInfos.get('billId');

        List<XC_BillingProfileLineItem__c> billProfLineItemListToInsert = new List<XC_BillingProfileLineItem__c>();
        List<XC_BillingProfileLineItem__c> billProfLineItemListToProcess = new List<XC_BillingProfileLineItem__c>();
        List<XC_BillingProfileLineItem__c> billProfLineItemToUpdate = new List<XC_BillingProfileLineItem__c>();

        Account acc = (Account)JSON.deserialize(mapInfos.get('account'), Account.class);
        XC_UTIL_Account.IdentityIFWrapper identityWr = (mapInfos.get('identityWrapper') != null)? (XC_UTIL_Account.IdentityIFWrapper) JSON.Deserialize(mapInfos.get('identityWrapper'), XC_UTIL_Account.IdentityIFWrapper.class) : null;
        String docType = (identityWr != null) ?  identityWr.IdentityType : acc.IdentityType__c;
        String docNumber = (identityWr != null) ? identityWr.IdentityNumber : acc.IdentityNumber__c;
        String docCountry = (identityWr != null) ? identityWr.Country : acc.XC_DocumentCountry__c;

        Contact cont = mapInfos.get('contactInfo')!= null ? (Contact) JSON.deserialize(mapInfos.get('contactInfo'), Contact.class) : null;
        
        // BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
        XC_ThirdPartyConfiguration__c tpConfig = (XC_ThirdPartyConfiguration__c ) mapUtilBp.get('tpbConfiguration');
        // END - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
        
        for(NE__Billing_Profile__c bp : billProfListToInsert) {
            System.debug('BP Status: ' + bp.XC_Status__c);
            XC_BillingProfileLineItem__c billingProfileLineItem; 
            // create billing profile line item 
            if(mapBp.containsKey(bp.Id)){ // check duplicate bpli(PUT bp)
                XC_BillingProfileLineItem__c bpliToDuplicate = mapBp.get(bp.Id).Billing_Profile_Line_Items__r[0];
                Boolean newBpli = false;
                Boolean updateBpli = false;
                Boolean sameBpli = false;  
                soldAddrId = (!String.isBlank(billingProfMapLe.get(bp.Id).get('soldAddressId'))) ? billingProfMapLe.get(bp.Id).get('soldAddressId'): soldAddrId;
                billAddrId = (!String.isBlank(billingProfMapLe.get(bp.Id).get('billingAddressId'))) ? billingProfMapLe.get(bp.Id).get('billingAddressId'): billAddrId;
                String status = billingProfMapLe.get(bp.Id).get('status');
                
                if(bp.XC_Status__c == 'Refused') {

                    for(XC_BillingProfileLineItem__c bpli : mapBp.get(bp.Id).Billing_Profile_Line_Items__r) {
                        bpli.XC_Status__c = bp.XC_Status__c;
                    }
                    billProfLineItemToUpdate.addAll(mapBp.get(bp.Id).Billing_Profile_Line_Items__r);

                } else if(mapInfos.get('clientSystem') != 'SIAPaymentHub'){

                    XC_BillingProfileLineItem__c bpliToUpdate = new XC_BillingProfileLineItem__c();
                    XC_BillingProfileLineItem__c bpliToProcess = new XC_BillingProfileLineItem__c();

                    for(XC_BillingProfileLineItem__c bpli : mapBp.get(bp.Id).Billing_Profile_Line_Items__r) {
                        Boolean tpbCondition = ((tpConfig==null && String.isBlank(bpli.XC_TPBCode__c)) || (tpConfig!=null && tpConfig.XC_TPBCode__c == bpli.XC_TPBCode__c));//[2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
                        if((bpli.XC_BillToAddress__c != billAddrId ||  bpli.XC_SoldToAddress__c != soldAddrId)  // update bpli addresses
                            && billingProfMapLe.get(bp.Id).get('legalEntity') == bpli.XC_LegalEntity__c
                            && mapBpli.get(bpli.Id).Configuration_Items__r.size() == 0
                            && tpbCondition) {//[2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
                                bpli.XC_BillToAddress__c = billAddrId;
                                bpli.XC_BillingAddressCopy__c= billAddrId;
                                bpli.XC_SoldToAddress__c = soldAddrId;
                                bpli.XC_SoldToAddressCopy__c = soldAddrId;

                                if(bpli.XC_Status__c != 'Sent To Zuora' && bpli.XC_Status__c != 'Active' && bpli.XC_Status__c != 'Refused'){
                                    bpli.XC_InvoiceDeliveryPreference__c = (!String.isBlank(billingProfMapLe.get(bp.Id).get('invoiceDeliveryPreference'))) ? ((billingProfMapLe.get(bp.Id).get('invoiceDeliveryPreference').containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : billingProfMapLe.get(bp.Id).get('invoiceDeliveryPreference')) : ((!String.isBlank(mapBp.get(bp.Id).XC_InvoiceDeliveryPref__c) && mapBp.get(bp.Id).XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : mapBp.get(bp.Id).XC_InvoiceDeliveryPref__c);              
                                    bpli.XC_InvoicePreferredLanguage__c = (!String.isBlank(billingProfMapLe.get(bp.Id).get('invoicePreferredLanguage'))) ? billingProfMapLe.get(bp.Id).get('invoicePreferredLanguage'):  mapBp.get(bp.Id).XC_InvoicePreferredLanguage__c;               
                                    
                                    // set invoiceDeliveryPrefsPrint to true if the contact missing the email
                                    if(!String.isBlank(bpli.XC_InvoiceDeliveryPreference__c) && (bpli.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase(Label.XC_CL_BpliInvoiceDeliveryPref)
                                        || bpli.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Email')) && String.isBlank(bpli.XC_BillToContactId__r.Email)){
                                        bpli.XC_InvoiceDeliveryPreference__c = 'Print';
                                    }
                                }

                                bpliToUpdate = bpli;
                                updateBpli = true;
                        } else if((bpli.XC_BillToAddress__c == billAddrId &&  bpli.XC_SoldToAddress__c == soldAddrId)  // same bpli -> it's not necessary to update it
                                    && billingProfMapLe.get(bp.Id).get('legalEntity') == bpli.XC_LegalEntity__c && tpbCondition ) {//[2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
                                        sameBpli = true;
                                        bpliToProcess = bpli;
                        } else if(status == 'Active') {
                            billProfLineItemListToProcess.add(bpli);
                        }
                    }

                    if(sameBpli){
                        billProfLineItemListToProcess.add(bpliToProcess);
                    }else if(updateBpli){
                        billProfLineItemToUpdate.add(bpliToUpdate); 
                    } else if(status != 'Active'){
                        newBpli = true;
                    }

                } else {
                    billProfLineItemListToProcess.addAll(mapBp.get(bp.Id).Billing_Profile_Line_Items__r);
                }

                if(newBpli){ // create bp (PUT bp)
                    billingProfileLineItem = new XC_BillingProfileLineItem__c( XC_BillingProfile__c = bp.Id, 
                                                                            XC_BillToAddress__c = billAddrId, 
                                                                            XC_SoldToAddress__c = soldAddrId, 
                                                                            XC_BillToContactId__c = bpliToDuplicate.XC_BillToContactId__c,
                                                                            XC_SoldToContactId__c = bpliToDuplicate.XC_SoldToContactId__c,
                                                                            XC_BillingProfileName__c = bp.Name, XC_Status__c = 'Draft');
                    billingProfileLineItem.XC_LegalEntity__c = billingProfMapLe.get(bp.Id).get('legalEntity');
                    billingProfileLineItem.XC_ExternalKey__c = billingProfMapLe.get(bp.Id).get('CreditCardExternalKey');
                    billingProfileLineItem.XC_PEC__c = billingProfMapLe.get(bp.Id).get('CertifiedEmail');
                    billingProfileLineItem.XC_RecipientCode__c = billingProfMapLe.get(bp.Id).get('RecipientCode');
                    //[BEGIN ACERRA CR-NR2063 B2B 16.11.2021]
                    billingProfileLineItem.XC_RecipientCodeB2B__c = (String.isNotBlank(billingProfMapLe.get(bp.Id).get('RecipientCode')) && 'B2B'.equalsIgnoreCase(acc.XC_Segment__c)) ? billingProfMapLe.get(bp.Id).get('RecipientCode') : null;
                    //[END ACERRA CR-NR2063 B2B 16.11.2021]
                    billingProfileLineItem.XC_Country__c = (String.isNotBlank(billingProfMapLe.get(bp.Id).get('Country'))) ? billingProfMapLe.get(bp.Id).get('Country') : null;
                    billingProfileLineItem.XC_DocumentType__c = docType;
                    billingProfileLineItem.XC_DocumentNumber__c = docNumber;
                    billingProfileLineItem.XC_DocumentCountry__c = docCountry;
                    billingProfileLineItem.XC_InvoiceDeliveryPreference__c = (!String.isBlank(billingProfMapLe.get(bp.Id).get('invoiceDeliveryPreference'))) ? ((billingProfMapLe.get(bp.Id).get('invoiceDeliveryPreference').containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : billingProfMapLe.get(bp.Id).get('invoiceDeliveryPreference')) : ((!String.isBlank(mapBp.get(bp.Id).XC_InvoiceDeliveryPref__c) && mapBp.get(bp.Id).XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : mapBp.get(bp.Id).XC_InvoiceDeliveryPref__c);    
                    billingProfileLineItem.XC_InvoicePreferredLanguage__c = (!String.isBlank(billingProfMapLe.get(bp.Id).get('invoicePreferredLanguage'))) ? billingProfMapLe.get(bp.Id).get('invoicePreferredLanguage') : mapBp.get(bp.Id).XC_InvoicePreferredLanguage__c;            
                    // set invoiceDeliveryPrefsPrint to true if the contact missing the email
                    if(!String.isBlank(billingProfileLineItem.XC_InvoiceDeliveryPreference__c) && (billingProfileLineItem.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase(Label.XC_CL_BpliInvoiceDeliveryPref)
                        || billingProfileLineItem.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Email')) &&  String.isBlank(bpliToDuplicate.XC_BillToContactId__r.Email)){
                        billingProfileLineItem.XC_InvoiceDeliveryPreference__c = 'Print';
                    } 
                    //BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
                    if(tpConfig!=null)
                    {
                        billingProfileLineItem.XC_TPBCode__c = tpConfig.XC_TPBCode__c;
                    }
                    //END - [2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
                }  
            }else{ // create bp (POST bp)
                billingProfileLineItem = new XC_BillingProfileLineItem__c(  XC_BillingProfile__c = bp.Id, 
                                                                            XC_BillToAddress__c = billAddrId,  
                                                                            XC_SoldToAddress__c = soldAddrId, 
                                                                            XC_BillToContactId__c = mapInfos.get('contactId'), 
                                                                            XC_SoldToContactId__c = mapInfos.get('contactId'),
                                                                            XC_BillingProfileName__c = bp.Name, XC_Status__c = 'Draft');
                if(reverseBpMap.containsKey(bp)){
                    billingProfileLineItem.XC_LegalEntity__c = reverseBpMap.get(bp).LegalEntity;
                    billingProfileLineItem.XC_ExternalKey__c = reverseBpMap.get(bp).CreditCardExternalKey;
                    billingProfileLineItem.XC_PEC__c = reverseBpMap.get(bp).CertifiedEmail;
                    billingProfileLineItem.XC_RecipientCode__c = reverseBpMap.get(bp).RecipientCode;
                    //[BEGIN ACERRA CR-NR2063 B2B 10.11.2021]
                    billingProfileLineItem.XC_RecipientCodeB2B__c = (String.isNotBlank(reverseBpMap.get(bp).RecipientCode) && 'B2B'.equalsIgnoreCase(acc.XC_Segment__c)) ? reverseBpMap.get(bp).RecipientCode : null;
                    //[END ACERRA CR-NR2063 B2B 10.11.2021]
                    billingProfileLineItem.XC_Country__c = (String.isNotBlank(reverseBpMap.get(bp).Country)) ? reverseBpMap.get(bp).Country : null;
                    billingProfileLineItem.XC_InvoiceDeliveryPreference__c = (!String.isBlank(reverseBpMap.get(bp).InvoiceDeliveryPref)) ? ((reverseBpMap.get(bp).InvoiceDeliveryPref.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref :  reverseBpMap.get(bp).InvoiceDeliveryPref): null;
                    billingProfileLineItem.XC_InvoicePreferredLanguage__c = (!String.isBlank(reverseBpMap.get(bp).InvoicePreferredLanguage)) ? reverseBpMap.get(bp).InvoicePreferredLanguage : null;

                    // set invoiceDeliveryPrefsPrint to true if the contact missing the email
                    if(!String.isBlank(billingProfileLineItem.XC_InvoiceDeliveryPreference__c) && (billingProfileLineItem.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase(Label.XC_CL_BpliInvoiceDeliveryPref)
                        || billingProfileLineItem.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Email')) &&  (Cont != null && String.isBlank(cont.Email))){
                            billingProfileLineItem.XC_InvoiceDeliveryPreference__c = 'Print';
                    }
                }
                billingProfileLineItem.XC_DocumentType__c = docType;
                billingProfileLineItem.XC_DocumentNumber__c = docNumber;
                billingProfileLineItem.XC_DocumentCountry__c = docCountry;
                //BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
                if(tpConfig != null)
                {
                    billingProfileLineItem.XC_TPBCode__c = tpConfig.XC_TPBCode__c;
                }
                //END - [2021-09-30 :: TP :: Third Party Billing :: Added new logic on XC_TPBCode__c]
            }
            if(billingProfileLineItem != null){
                billProfLineItemListToInsert.add(billingProfileLineItem);
            }
        }


        // upsert billing profile line item
        List<XC_UTIL_Sobject.WrapperResult> resultUpsertBPLI = XC_UTIL_Sobject.insertListRecords(billProfLineItemListToInsert); 
        resultUpsertBPLI.addAll(XC_UTIL_Sobject.updateListRecords(billProfLineItemToUpdate));
        for(XC_UTIL_Sobject.WrapperResult wr : resultUpsertBPLI) {
            if(!wr.success) {
                wrResp.Result.Message = 'INTERNAL ERROR: '+ wr.errorMessage;
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR: '+ wr.errorMessage;
                return new List<XC_BillingProfileLineItem__c>();
            }
        }

        billProfLineItemListToInsert.addAll(billProfLineItemListToProcess);
        billProfLineItemListToInsert.addAll(billProfLineItemToUpdate);

        return billProfLineItemListToInsert;

    }
  

    /**
    * @param billingProfileList - List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>
    * @param mapInfos - Map<String,String>
    * @param wrResp - XC_REST_Account_W.WrapperResponse 
    * @param methodPUT the method PUT
    * @return the list
    * @description Method to insert or update Billing Profile
    */
    public static List<XC_UTIL_Sobject.WrapperResult> insertUpdateBillingProfile(List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList, Map<String,String> mapInfos, XC_REST_Account_W.WrapperResponse wrResp, Boolean methodPUT){

        List<XC_UTIL_Sobject.WrapperResult> wrResult = new List<XC_UTIL_Sobject.WrapperResult>();

        checkAddressToAssociate(mapInfos, wrResp);
        if(wrResp.Result.ErrorCode == '500'){
            return new List<XC_UTIL_Sobject.WrapperResult>();
        }

        String country = mapInfos.get('country');

        /*String batch = '';

        if(!billingProfileList.isEmpty()&&!String.isBlank(billingProfileList[0].CommodityBillingCycleFrequency)){
            batch = XC_ZuoraBPCreationC_U.manageCommodityContractBillingFrequency(new Map<String,Object>{
                'CommodityBillingCycleFrequency' => billingProfileList[0].CommodityBillingCycleFrequency
            });
        }*/

        List<NE__Billing_Profile__c> billProfListToInsert = new List<NE__Billing_Profile__c>();
        Map<NE__Billing_Profile__c, XC_UTIL_BillingProfile.BillingProfileIFWrapper> reverseBpMap = new Map<NE__Billing_Profile__c, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c> bpMap = new Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c>();
        Map<Id, Map<String,String>> billingProfMapLe = new  Map<Id, Map<String,String>>();
        Map<String,Object> maputilBp = new Map<String,Object>{
                                                                'billProfListToInsert' => billProfListToInsert,
                                                                'billingProfMapLe' => billingProfMapLe,
                                                                'reverseBpMap' => reverseBpMap,
                                                                'billingProfileList' => billingProfileList,
                                                                'mapInfos' => mapInfos,
                                                                'bpMap' => bpMap
                                                                //'batch' => batch
                                                                };

        // BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]
        List<XC_ThirdPartyConfiguration__c> tpbConfigs = [SELECT Name, XC_TPBCode__c, XC_ZuoraSequenceSetId__c FROM XC_ThirdPartyConfiguration__c WHERE XC_TPBCode__c = :mapInfos.get('clientSystem') AND XC_OrgId__c = :UserInfo.getOrganizationId()];
        XC_ThirdPartyConfiguration__c tpbConf = (tpbConfigs != null && !tpbConfigs.isEmpty()) ? tpbConfigs.get(0) : null;
        maputilBp.put('tpbConfiguration', tpbConf);
        // END - [2021-09-30 :: TP :: Third Party Billing :: Get partner codes]

        //check billing profile
        Map<Id, NE__Billing_Profile__c> mapBp = checkBillingProfile(billingProfileList, mapInfos, wrResp);
        if(wrResp.Result.ErrorCode == '500'){
            return new List<XC_UTIL_Sobject.WrapperResult>();
        }

        maputilBp.put('mapBp', mapBp);

        // manage billing profile
        manageBillingProfile(mapUtilBp, wrResp);
        if(wrResp.Result.ErrorCode == '500'){
            return new List<XC_UTIL_Sobject.WrapperResult>();
        }


        //start payment method sia flow 
        for(XC_UTIL_BillingProfile.BillingProfileIFWrapper bw : billingProfileList){
            String accId = mapInfos.get('accountId');
            // if(bw.PaymentMethod=='SEPA' || bw.PaymentMethod == 'Direct Debt'){
            //     system.debug('sending sepa');
            //     ZuoraBillingProfileCreationController.callSIAForSEPAAsynchronous(accId, (NE__Billing_Profile__c)maputilBp.get('bp4sia'));
            // } else 
            
            if(bw.PaymentMethod=='Credit Card'){
                if(bw.Action == 'ToSendToPH'){ 
                    system.debug('sending cc');
                    ZuoraBillingProfileCreationController.callSIAForCreditCardAsynchronous(accId, (NE__Billing_Profile__c)maputilBp.get('bp4sia'));
                }
            }
        }

        bpMap = (Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c>) mapUtilBp.get('bpMap');
        List<XC_UTIL_Sobject.WrapperResult> resultInsert = (List<XC_UTIL_Sobject.WrapperResult>) mapUtilBp.get('resultInsert');

       
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> mapBPwr = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        for(XC_UTIL_BillingProfile.BillingProfileIFWrapper wr :bpMap.keySet()){
            reverseBpMap.put(bpMap.get(wr), wr);
            mapBPwr.put(bpMap.get(wr).id, wr);    
        }

        
        // manage bpli
        List<XC_BillingProfileLineItem__c> billProfLineItemListToInsert = manageBpli(maputilBp, wrResp);
        if(wrResp.Result.ErrorCode == '500'){
            return new List<XC_UTIL_Sobject.WrapperResult>();
        }

        //BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Recover zuoraSequenceSetId for Partners]
        String tpbZuoraSequenceSetId = '';
        String tpbCode = '';
        if(tpbConf != null)
        {
            tpbZuoraSequenceSetId = tpbConf.XC_ZuoraSequenceSetId__c;
            tpbCode = tpbConf.XC_TPBCode__c;
        }
        //END - [2021-09-30 :: TP :: Third Party Billing :: Recover zuoraSequenceSetId for Partners]

        Account acc = (Account)JSON.deserialize(mapInfos.get('account'), Account.class);

        XC_UTIL_Account.IdentityIFWrapper identityWr = (mapInfos.get('identityWrapper') != null)? (XC_UTIL_Account.IdentityIFWrapper) JSON.Deserialize(mapInfos.get('identityWrapper'), XC_UTIL_Account.IdentityIFWrapper.class) : null;
        XC_PersonalDocument__c  personalDoc = (mapInfos.get('personalDocument') != null)? (XC_PersonalDocument__c)JSON.deserialize(mapInfos.get('personalDocument'), XC_PersonalDocument__c.class) : null;
        mapUtilBp.put('splitPayment', acc.XC_SplitPayment__c);
        mapUtilBp.put('vatGroupType', acc.XC_VatGroupType__c);

        Map<String, Object> mapAccountDocument = new Map<String,Object>{'billProfLineItemListToInsert' => billProfLineItemListToInsert,
                                                                        'identityWr' => identityWr,
                                                                        'acc' => acc,
                                                                        'methodPUT' => methodPUT,
                                                                        'personalDoc' => personalDoc
                                                                        };
        // manage document to send to Zuora 
        if(!billProfLineItemListToInsert.isEmpty()){
            manageDocument(mapAccountDocument);
        }
       
        String docNif = (String) mapAccountDocument.get('docNif');
        String docNumber = (String) mapAccountDocument.get('docNumber');
        String expedition = (String) mapAccountDocument.get('expedition');
        String expiration = (String) mapAccountDocument.get('expiration');
        String docCountry = (String) mapAccountDocument.get('docCountry');
        String countryCode  = (String) mapAccountDocument.get('countryCode');
        mapUtilBp.put('legalInfo', mapAccountDocument.get('legalInfo'));

        Map<String,String> creditCardType = new Map<String, String> {   'MASTERCARD' => 'MasterCard', 
                                                                        'VISA' => 'Visa',
                                                                        'DISCOVER' => 'Discover',
                                                                        'AMEX' => 'AmericanExpress',
                                                                        'PAYPAL' => 'PayPal'
                                                                        };
        
        Set<Id> bpliIds = XC_UTIL_Sobject.getSetIds(billProfLineItemListToInsert);
        Map<Id,XC_BillingProfileLineItem__c> parentBPObjectInfos = new Map<Id,XC_BillingProfileLineItem__c>([SELECT XC_BillingProfile__r.NE__Payment__c, XC_BillingProfile__r.XC_CurrentActiveEmobApp__c, XC_BillingProfile__r.NE__Account__c, XC_BillToContactId__r.Email  FROM XC_BillingProfileLineItem__c  WHERE ID IN :bpliIds]);
        List<XC_BillingProfileLineItem__c> bpliListForCurrentActiveEmobApp = new List<XC_BillingProfileLineItem__c>();

        for(XC_BillingProfileLineItem__c billingProfInserted : billProfLineItemListToInsert){ 
                
            mapUtilBp.put('mapBPwr', mapBPwr);
            mapUtilBp.put('creditCardType', creditCardType);
            mapUtilBp.put('billingProfInserted', billingProfInserted);
            mapUtilBp.put('LegalEntity', billingProfInserted.XC_LegalEntity__c);
           

            prepareBPinfoForZuora(mapUtilBp);

            Map<String,Object> paymentMethod = (Map<String,Object>) mapUtilBp.get('paymentMethod');
            Boolean invoiceEmail = (Boolean) mapUtilBp.get('invoiceEmail');
            Boolean invoicePrint = (Boolean) mapUtilBp.get('invoicePrint');
            String payment = (String) mapUtilBp.get('payment');
            XC_UTIL_BillingProfile.BillingProfileIFWrapper billProfWr = (XC_UTIL_BillingProfile.BillingProfileIFWrapper) mapUtilBp.get('billProfWr');
            Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, String> mapBfwrIsExtWaiting = (Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, String>) mapUtilBp.get('mapBfwrIsExtWaiting');
            
            // populate wrapper options
            mapUtilBp.put('docNif', docNif);
            
    
            wrapperOption wrOptions = manageWrapperOption(mapUtilBp);
			

            String sohoType = '';
            String tradingPartner = '';
            String accountType = '';
            if((!String.isBlank(acc.XC_AccountType__c) && acc.XC_AccountType__c == 'Residential') || (!String.isBlank(acc.XC_RecordTypeDeveloperName__c) && acc.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential'))) {
                accountType = 'Residential';
            }

            if(accountType != 'Residential'){
                sohoType = (String.isBlank(acc.XC_SohoType__c)) ? 'Soho' : acc.XC_SohoType__c;
            }
            

            Map<String,Object>  zuoraPayment = new Map<String,Object>{'bpId' => billingProfInserted.Id,
                                                                        'fromBillingProfile' => false,
                                                                        'docNif' => (String.isBlank(docNif)) ? '': docNif,
                                                                        'docNumber' => (String.isBlank(docNumber)) ?  '': docNumber,
                                                                        'countryCode' => (String.isBlank(countryCode)) ?  '': countryCode,
                                                                        'expedition' => (String.isBlank(expedition)) ? '': expedition,
                                                                        'expiration' => (String.isBlank(expiration)) ? '': expiration,
                                                                        'personTypeCode' => (accountType == 'Residential') ? 'F' : 'J',
                                                                        'sequenceSetId' => wrOptions.SimplifiedInvoiceReplace,
                                                                        'vatGroupSequenceSetId' => wrOptions.vatGroupSequenceSetId,
                                                                        'zuoraSequenceSetId' => String.isNotBlank(tpbZuoraSequenceSetId)?tpbZuoraSequenceSetId:wrOptions.zuoraSequenceSetId,//[2021-09-30 :: TP :: Third Party Billing :: Recover zuoraSequenceSetId for Partners]
                                                                        'sohoType' => sohoType,
                                                                        'taxInfo' => 'No',
                                                                        'contractId' => !String.isBlank((String)mapUtilBp.get('contractId')) ? (String)mapUtilBp.get('contractId') : '',
                                                                        'tpbCode' => String.isNotBlank(tpbCode)?tpbCode:'' //[2021-09-30 :: TP :: Third Party Billing :: set tpbcode for Partners]
                                                                        };  
            
            /****fix 30/08/2019 */
            String invoiceLanguage = (String) mapUtilBp.get('invoiceLanguage');
            if(billProfWr!=null){
                zuoraPayment.put('invoicePreferredLanguage',billProfWr.InvoicePreferredLanguage);
            } else if (String.isNotBlank(invoiceLanguage)) {
                zuoraPayment.put('invoicePreferredLanguage', invoiceLanguage);
            }

            zuoraPayment.put('legalE', billingProfInserted.XC_LegalEntity__c);            
            String isWaitingExtAct = (billProfWr!=null && mapBfwrIsExtWaiting.get(billProfWr) != null) ? mapBfwrIsExtWaiting.get(billProfWr) : 'N';
            
            wrOptions.vatGroupSequenceSetId = null;
            wrOptions.zuoraSequenceSetId = null;
            Map<String,String>  zuoraMap = new Map<String,String>{  'account' => mapInfos.get('account'),
                                                                    'legalEntity' => billingProfInserted.XC_LegalEntity__c,
                                                                    'options' => (JSON.Serialize(wrOptions, true)).replace('Replace', '__c'),
                                                                    'billingProfLineItemId' => billingProfInserted.Id,
                                                                    'zuoraPayment' => JSON.serialize(zuoraPayment, true),
                                                                    'mapPayment' => JSON.serialize(paymentMethod, true),
                                                                    'billingProfId' => billingProfInserted.XC_BillingProfile__c,
                                                                    'bpli' => JSON.serialize(billingProfInserted, true),
                                                                    'country' => country,
                                                                    'TransactionID' => mapInfos.get('TransactionID'),
                                                                    'isWaitingExtAct' => isWaitingExtAct
                                                                    };    

            
            system.debug('Info to Zuora: option'+ zuoraMap.get('options'));
            system.debug('Info to Zuora: mapPayment'+ zuoraMap.get('mapPayment'));  
            system.debug('Info to Zuora: zuoraPayment'+ zuoraMap.get('zuoraPayment'));  

            Boolean mandatoryOk = true;
            
            system.debug('PaymentMethod: '+ paymentMethod);
            system.debug('BPLI Status: '+ billingProfInserted.XC_Status__c);  
            if(billingProfInserted.XC_Status__c != 'Sent To Zuora' && billingProfInserted.XC_Status__c != 'Active' && billingProfInserted.XC_Status__c != 'Refused'){
                if(parentBPObjectInfos.containsKey(billingProfInserted.Id) && (parentBPObjectInfos.get(billingProfInserted.Id).XC_BillingProfile__r.NE__Payment__c == 'Direct Debt' 
                || parentBPObjectInfos.get(billingProfInserted.Id).XC_BillingProfile__r.NE__Payment__c == 'SEPA')){
                    // new management for SEPA, all logic is asynchronous, both token and zuora creation.
                    System.Debug('ENTERED SEPA CREATION');
                    ZuoraBillingProfileCreationController.callSIAForSEPAAsynchronous(mapInfos.get('accountId'), (NE__Billing_Profile__c)maputilBp.get('bp4sia'),zuoraMap);
                }else if((paymentMethod.get('Type') == 'CreditCardReferenceTransaction' && checkMandatoryCCValues(paymentMethod))
                        || (paymentMethod.get('Type') == 'Commodity Bill' && !String.isBlank((String)zuoraPayment.get('contractId')))
                        || (paymentMethod.get('Type') != 'CreditCardReferenceTransaction' && paymentMethod.get('Type') != 'Commodity Bill' 
                            && ((parentBPObjectInfos.containsKey(billingProfInserted.Id) && parentBPObjectInfos.get(billingProfInserted.Id).XC_BillingProfile__r.NE__Payment__c != 'Direct Debt')
                            ||( parentBPObjectInfos.containsKey(billingProfInserted.Id) && parentBPObjectInfos.get(billingProfInserted.Id).XC_BillingProfile__r.NE__Payment__c != 'SEPA')))){
                            callZuora(zuoraMap);
                            system.debug('CallZuora');
                }
            }
            
            if(parentBPObjectInfos.containsKey(billingProfInserted.Id) && parentBPObjectInfos.get(billingProfInserted.Id).XC_BillingProfile__r.XC_CurrentActiveEmobApp__c) {
                billingProfInserted.XC_Account__c = parentBPObjectInfos.get(billingProfInserted.Id).XC_BillingProfile__r.NE__Account__c;
                bpliListForCurrentActiveEmobApp.add(billingProfInserted);
            }
        }

        if(!bpliListForCurrentActiveEmobApp.isEmpty()) {
            setCurrentActiveEmobAppToFalse(JSON.serialize(bpliListForCurrentActiveEmobApp));
        }

        return resultInsert;
    }


    /*
    * @param bpliListForCurrentActiveEmobAppSTRING
    * @description method to manage billing profile CurrentActiveEmobApp field
    */
    @future
    public static void setCurrentActiveEmobAppToFalse(String bpliListForCurrentActiveEmobAppSTRING) {
        List<XC_BillingProfileLineItem__c> bpliListForCurrentActiveEmobApp = (List<XC_BillingProfileLineItem__c>) JSON.deserialize(bpliListForCurrentActiveEmobAppSTRING, List<XC_BillingProfileLineItem__c>.class);

        Set<String> bpliIds = new Set<String>();
        Set<String> legalEntitySet = new Set<String>();
        Map<String, Set<String>> accountLegalEntityMap = new Map<String, Set<String>>();
        for(XC_BillingProfileLineItem__c bpli : bpliListForCurrentActiveEmobApp) {
            bpliIds.add(bpli.Id);
            legalEntitySet.add(bpli.XC_LegalEntity__c);
            if(accountLegalEntityMap.containsKey(bpli.XC_Account__c)) {
                accountLegalEntityMap.get(bpli.XC_Account__c).add(bpli.XC_LegalEntity__c);
            } else {
                accountLegalEntityMap.put(bpli.XC_Account__c, new Set<String>{bpli.XC_LegalEntity__c});
            }
        }

        Map<Id, XC_BillingProfileLineItem__c> bpliMap = new Map<Id,XC_BillingProfileLineItem__c>([SELECT XC_BillingProfile__c, XC_Account__c, XC_LegalEntity__c
                                                                                                    FROM XC_BillingProfileLineItem__c
                                                                                                    WHERE ID NOT IN: bpliIds AND XC_Account__c IN :accountLegalEntityMap.keySet()
                                                                                                        AND XC_BillingProfile__r.XC_CurrentActiveEmobApp__c = true
                                                                                                        AND XC_LegalEntity__c IN :legalEntitySet]);
        Map<Id, NE__Billing_Profile__c> bpMap = new Map<Id, NE__Billing_Profile__c>();
        for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            if(accountLegalEntityMap.containsKey(bpli.XC_Account__c) && accountLegalEntityMap.get(bpli.XC_Account__c).contains(bpli.XC_LegalEntity__c)) {
                NE__Billing_Profile__c bp = new NE__Billing_Profile__c();
                bp.Id = bpli.XC_BillingProfile__c;
                bp.XC_CurrentActiveEmobApp__c = false;
                bpMap.put(bp.Id, bp);
            }
        }
        
        if(!bpMap.isEmpty()) {
            XC_UTIL_SObject.updateListRecords(bpMap.values());
        }
    }


    /*
    * @param Map<String,Object>  - mapUtilBp 
    * @paramXC_REST_Account_W.WrapperResponse - wrResp 
    * @description method to manage billing profile
    */
    public static void manageBillingProfile(Map<String,Object> mapUtilBp, XC_REST_Account_W.WrapperResponse wrResp){


        Map<String,Object> mapInfos = (Map<String,Object>) mapUtilBp.get('mapInfos');
        Map<Id, NE__Billing_Profile__c> mapBp = (Map<Id, NE__Billing_Profile__c>) mapUtilBp.get('mapBp');
        Map<Id, Map<String,String>> billingProfMapLe = (Map<Id, Map<String,String>>) mapUtilBp.get('billingProfMapLe');
        List<NE__Billing_Profile__c> billProfListToInsert = (List<NE__Billing_Profile__c>) mapUtilBp.get('billProfListToInsert');
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList = (List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>) mapUtilBp.get('billingProfileList');
        Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c> bpMap = (Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c>) mapUtilBp.get('bpMap');
       
        List<NE__Billing_Profile__c> billProfListToUpdate = new List<NE__Billing_Profile__c>();

        List<NE__Billing_Profile__c> billProfListToSia = new List<NE__Billing_Profile__c>();

        Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, String> mapBfwrIsExtWaiting = new Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, String> ();

        // populate billing profile to insert 
        NE__Billing_Profile__c bpSia = new NE__Billing_Profile__c();
        for(XC_UTIL_BillingProfile.BillingProfileIFWrapper billProfWr : billingProfileList) {
            mapBfwrIsExtWaiting.put(billProfWr, 'N');
            if(String.isBlank(billProfWr.BillingProfileID)){
                WrapperInfo wi = populateWrapperInfo(billProfWr, mapInfos);
                String legalEntity =wi.legal;

                
                // for market italia - commodity bill
                if((legalEntity.equalsIgnoreCase(Label.XC_CL_LegalEntity_Italy)
                        ||legalEntity.equalsIgnoreCase(Label.XC_CL_LegalEntity_EnelXMobilityItalia)
                        ||legalEntity.equalsIgnoreCase(Label.XC_CL_LegalEntity_EnelXMobilityHolding))
                    && billProfWr.paymentMethod == Label.XC_CL_Commodity_Bill 
                    && (String.isBlank(billProfWr.CommodityCC) && String.isBlank(billProfWr.CommodityContractNum))){

                    billProfWr.CommodityContractNum = String.isBlank(billProfWr.CupsID) ? billProfWr.CommodityCupsID : billProfWr.CupsID;
                    billProfWr.CommodityCC = billProfWr.CommodityContractNum;
                    wi.contractId = billProfWr.CommodityContractNum;
                    mapBfwrIsExtWaiting.put(billProfWr, 'Y');

                //Italy SDD Management
                }else if(legalEntity.equalsIgnoreCase(Label.XC_CL_LegalEntity_Italy) && billProfWr.paymentMethod==Label.XC_CL_DirectDebt){
                    mapBfwrIsExtWaiting.put(billProfWr, 'Y');
                }

                String info = JSON.Serialize(wi, true); 

                NE__Billing_Profile__c bp = new NE__Billing_Profile__c();
                createBillingProfile(info, bp);
                system.debug( 'Legal Entity '+ legalEntity);
                billProfWr.legalEntity = legalEntity;
                bpMap.put(billProfWr, bp); // bpMap for new BP
                billProfListToInsert.add(bp);
                bpSia = bp;
               
                
            } else {
                // billing profile to update
                String info = JSON.Serialize(populateWrapperInfo(billProfWr, mapInfos), true);
                String legalEntity =(String)((Map<String,Object>) JSON.deserializeUntyped(info)).get('legal');
                Map<String, String> mapUtil = new Map<String, String>();
                mapUtil.put('CreditCardExternalKey', billProfWr.CreditCardExternalKey);
                mapUtil.put('legalEntity', legalEntity);
                mapUtil.put('soldAddressId', billProfWr.SoldAddressID);
                mapUtil.put('billingAddressId', billProfWr.BillingAddressID);
                mapUtil.put('CertifiedEmail', billProfWr.CertifiedEmail);
                mapUtil.put('RecipientCode', billProfWr.RecipientCode);
                mapUtil.put('Country', billProfWr.Country);
                mapUtil.put('status', billProfWr.Status);
                mapUtil.put('invoiceDeliveryPreference', billProfWr.InvoiceDeliveryPref);
                mapUtil.put('invoicePreferredLanguage',billProfWr.InvoicePreferredLanguage);
                billingProfMapLe.put(billProfWr.BillingProfileID, mapUtil);
                system.debug('INFO'+ info);
                createBillingProfile(info, mapBp.get(billProfWr.BillingProfileID));
                billProfListToUpdate.add(mapBp.get(billProfWr.BillingProfileID));
              	bpSia = mapBp.get(billProfWr.BillingProfileID); // mapBP for update BP
            }

            if(billProfWr.Action == 'ToSendToPH' || billProfWr.PaymentMethod == 'SEPA' ||  billProfWr.PaymentMethod == 'Direct Debt'){
                billProfListToSia.add(bpSia);
            }
        }
        mapUtilBp.put('mapBfwrIsExtWaiting', mapBfwrIsExtWaiting);
       

        // upsert billing profile 
        billProfListToInsert.addall(billProfListToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> resultInsert = XC_UTIL_Sobject.UpsertListRecords(billProfListToInsert); 
        for(XC_UTIL_Sobject.WrapperResult wr : resultInsert) {
            if(!wr.success) {
                wrResp.Result.Message = 'INTERNAL ERROR: '+ wr.errorMessage;
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR: '+ wr.errorMessage;
                return;
            }
        }

        //bp to send to sia 
        if(!billProfListToSia.isEmpty()){
           	/*XC_UTIL_Sobject.WrapperResult bp4sia = XC_UTIL_Sobject.UpsertRecord(billProfListToSia[0]); 
            if(!bp4sia.success) {
                wrResp.Result.Message = 'INTERNAL ERROR: '+ bp4sia.errorMessage;
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR: '+ bp4sia.errorMessage;
                return;
        	} */
            mapUtilBp.put('bp4sia', billProfListToSia[0]);
        }

        mapUtilBp.put('billProfListToInsert', billProfListToInsert);
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        mapUtilBp.put('resultInsert', resultInsert);
        mapUtilBp.put('bpMap', bpMap);
        
    }


    /*
    * @param Map<String,Object>  - mapUtilBp 
    * @description method to prepare billing profile info to send to Zuora
    */
    public static void prepareBPinfoForZuora(Map<String,Object> mapUtilBp){
                                                       
        Map<Id, NE__Billing_Profile__c> mapBp = (Map<Id, NE__Billing_Profile__c>) mapUtilBp.get('mapBp');
        Map<String,String> creditCardType = ( Map<String,String>) mapUtilBp.get('creditCardType');
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> mapBPwr = (Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>) mapUtilBp.get('mapBPwr');
        XC_BillingProfileLineItem__c billingProfInserted = (XC_BillingProfileLineItem__c) mapUtilBp.get('billingProfInserted');
        
        Map<String,Object> paymentMethod = new Map<String,Object>();
        Boolean invoiceEmail;
        Boolean invoicePrint;
        String invoiceLanguage;
        String payment;
        String contractId;
        String batch;
        String commodityBillingCycleFrequency;
        String commodityBP;
        Map<String,String> mapInfo = (Map<String,String>) mapUtilBp.get('mapInfos');

        List<String> externalPaymentList = new List<String>{'External Financing', 'Cash', 'Bank Transfer', 'Commodity Bill', 'Barcode', 'Online'};

        // insert bp (get info from wrapper)
        payment = 'Due Upon Receipt'; 
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billProfWr;
        if(!mapBp.containsKey(billingProfInserted.XC_BillingProfile__c)){
            billProfWr = mapBPwr.get(billingProfInserted.XC_BillingProfile__c);
            invoiceEmail = (billProfWr.InvoiceDeliveryPref == 'Email' || (!String.isblank(billProfWr.InvoiceDeliveryPref) && billProfWr.InvoiceDeliveryPref.containsIgnoreCase('Smart'))) ? true : false;
            invoicePrint = (billProfWr.InvoiceDeliveryPref == 'Print') ? true : false;
            invoiceLanguage = billProfWr.InvoicePreferredLanguage;
            //payment = (billProfWr.PaymentMethod  == 'SEPA' || billProfWr.PaymentMethod == 'Direct Debt') ? 'Net 7' : 'Due Upon Receipt';
            payment = (billProfWr.PaymentMethod  == 'SEPA' || billProfWr.PaymentMethod == 'Direct Debt') ? ((billProfWr.LegalEntity == Label.XC_CL_LegalEntity_Italy) ? 'Net 15' : 'Net 7') :  ((billProfWr.PaymentMethod == Label.XC_CL_BankTransfer && billProfWr.LegalEntity == Label.XC_CL_LegalEntity_Italy) ? 'Net 30' : 'Due Upon Receipt');
            if(billProfWr.LegalEntity == 'EnelXRomania'){
                if(billProfWr.PaymentMethod == 'Commodity Bill'){
                    payment = 'Net 60';
                } else if(billProfWr.PaymentMethod == 'Direct Debt') {
                    payment = 'Net 15';
                } else if(billProfWr.PaymentMethod == 'Bank Transfer') {
                    payment = 'Net 5';
                } else if(billProfWr.PaymentMethod == 'External Financing') {
                    payment = 'Net 5';
                } else {
                    payment = 'Due Upon Receipt';
                }
            }
			contractId = mapInfo.get('clientSystem').equalsIgnoreCase('CommodityItalyB2C') ? billProfWr.CommodityCC :  billProfWr.CommodityContractNum;
            commodityBP = ((Label.XC_CL_LegalEntity_Italy.equalsIgnoreCase(billProfWr.LegalEntity) ||
                            Label.XC_CL_LegalEntity_EnelXMobilityHolding.equalsIgnoreCase(billProfWr.LegalEntity) ||
                            Label.XC_CL_LegalEntity_EnelXMobilityItalia.equalsIgnoreCase(billProfWr.LegalEntity)) &&
                            billProfWr.PaymentMethod == Label.XC_CL_Payment_CommodityBill && !String.isBlank(billProfWr.CommodityBP)) ? billProfWr.CommodityBP : ((String.isNotBlank(billProfWr.SAPBusinessPartner)) ? billProfWr.SAPBusinessPartner : '');
            commodityBillingCycleFrequency = (billProfWr.PaymentMethod == Label.XC_CL_Payment_CommodityBill) ? billProfWr.CommodityBillingCycleFrequency : '';
            batch = (billProfWr.PaymentMethod == Label.XC_CL_Payment_CommodityBill && !String.isBlank(billProfWr.CommodityBillingCycleFrequency)) ? XC_ZuoraBPCreationC_U.manageCommodityContractBillingFrequency(new Map<String,Object>{'CommodityBillingCycleFrequency' => billProfWr.CommodityBillingCycleFrequency}) : '';
            if(externalPaymentList.contains(billProfWr.PaymentMethod)) {
                paymentMethod.put('Type', billProfWr.PaymentMethod);

            } else if(billProfWr.PaymentMethod == 'Credit Card') {
                paymentMethod.put('Type', 'CreditCardReferenceTransaction');
                paymentMethod.put('TokenId', billProfWr.Token);
                paymentMethod.put('CreditCardNumber', billProfWr.CreditCardLastFourNumber);
                paymentMethod.put('CreditCardHolderName', billProfWr.CreditCardHolder);
                paymentMethod.put('CreditCardExpirationMonth', billProfWr.ExpirationMonth);
                paymentMethod.put('CreditCardExpirationYear', billProfWr.ExpirationYear);
                paymentMethod.put('SecondTokenId', billProfWr.PayPalUsername);
                if(billProfWr.CreditCardType != null) {
                    paymentMethod.put('CreditCardType', creditCardType.get((billProfWr.CreditCardType).toUpperCase()));
                }
                    
            } else if(billProfWr.PaymentMethod == 'SEPA' || billProfWr.PaymentMethod == 'Direct Debt') {
                paymentMethod.put('Type', 'BankTransfer');
                paymentMethod.put('BankTransferType', 'SEPA');
                //paymentMethod.put('BankTransferAccountNumber', billProfWr.IBAN); 
                paymentMethod.put('TokenId', billProfWr.Token);
                paymentMethod.put('IBAN', billProfWr.IBAN); 
                paymentMethod.put('BankTransferAccountNumber', billProfWr.Token);
                paymentMethod.put('MandateID', billProfWr.SEPAMandateId);
                paymentMethod.put('MandateCreationDate', billProfWr.SEPAMandateDate);
            }
                
        // update bp (get info from query)
        }else {
            String legalEntity = (String) mapUtilBp.get('LegalEntity');
            billProfWr = mapBPwr.get(billingProfInserted.XC_BillingProfile__c);
            NE__Billing_Profile__c bpQ = mapBp.get(billingProfInserted.XC_BillingProfile__c);
            invoiceEmail = (bpQ.XC_InvoiceDeliveryPref__c == 'Email' || (!String.isBlank(bpQ.XC_InvoiceDeliveryPref__c) && bpQ.XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart'))) ? true : false;
            invoicePrint =  (bpQ.XC_InvoiceDeliveryPref__c == 'Print') ? true : false;
            invoiceLanguage = bpQ.XC_InvoicePreferredLanguage__c;
            //payment = (bpQ.NE__Payment__c  == 'Direct Debt') ? 'Net 7' : 'Due Upon Receipt';
            payment = (bpQ.NE__Payment__c == 'Direct Debt') ? ((!String.isBlank(legalEntity) && legalEntity == Label.XC_CL_LegalEntity_Italy) ? 'Net 15' : 'Net 7') :  ((bpQ.NE__Payment__c == Label.XC_CL_BankTransfer && !String.isBlank(legalEntity) && legalEntity == Label.XC_CL_LegalEntity_Italy) ? 'Net 30' : 'Due Upon Receipt');
            if(legalEntity == 'EnelXRomania'){
                if(bpQ.NE__Payment__c == 'Commodity Bill'){
                    payment = 'Net 60';
                } else if(bpQ.NE__Payment__c == 'Direct Debt') {
                    payment = 'Net 15';
                } else if(bpQ.NE__Payment__c == 'Bank Transfer') {
                    payment = 'Net 5';
                } else if(bpQ.NE__Payment__c == 'External Financing') {
                    payment = 'Net 5';
                } else {
                    payment = 'Due Upon Receipt';
                }
            }
            contractId = bpQ.XC_CommodityContractID__c; 
            commodityBillingCycleFrequency = (bpQ.NE__Payment__c == Label.XC_CL_Payment_CommodityBill) ? bpQ.XC_CommodityBillingCycleFrequency__c : '';
            commodityBP = (bpQ.NE__Payment__c == Label.XC_CL_Payment_CommodityBill) ? bpQ.XC_SAPBusinessPartner__c : '';
            batch = (bpQ.NE__Payment__c == Label.XC_CL_Payment_CommodityBill && !String.isBlank(bpQ.XC_CommodityBillingCycleFrequency__c)) ? XC_ZuoraBPCreationC_U.manageCommodityContractBillingFrequency(new Map<String,Object>{'CommodityBillingCycleFrequency' => bpq.XC_CommodityBillingCycleFrequency__c}) : '';

            if(externalPaymentList.contains(bpQ.NE__Payment__c)) {
               paymentMethod.put('Type', bpQ.NE__Payment__c);

            } else if(bpQ.NE__Payment__c == 'Credit Card') {
                paymentMethod.put('Type', 'CreditCardReferenceTransaction');
                paymentMethod.put('TokenId', bpQ.XC_Token__c);
                paymentMethod.put('CreditCardExpirationMonth', bpQ.NE__Expiration__c);
                paymentMethod.put('CreditCardExpirationYear', bpQ.NE__Expiration_Year__c);
                //paymentMethod.put('CreditCardHolderName', bpQ.CreditCardHolder);
                paymentMethod.put('SecondTokenId', bpQ.XC_PayPalUsername__c);
                if(!String.isBlank(bpQ.NE__Card_Number__c)){
                    paymentMethod.put('CreditCardNumber', bpQ.NE__Card_Number__c.substring(12)); 
                }
                if(bpQ.NE__Card_Type__c != null) {
                    paymentMethod.put('CreditCardType', creditCardType.get((bpQ.NE__Card_Type__c).toUpperCase()));
                }

            } else if(bpQ.NE__Payment__c == 'Direct Debt') {
                paymentMethod.put('Type', 'BankTransfer');
                paymentMethod.put('BankTransferType', 'SEPA');
                paymentMethod.put('BankTransferAccountNumber', bpQ.XC_Token__c);
                paymentMethod.put('IBAN', bpQ.NE__Iban__c);
                //paymentMethod.put('BankTransferAccountNumber', bpQ.NE__Iban__c);
                paymentMethod.put('TokenId', bpQ.XC_Token__c);
                paymentMethod.put('MandateID', bpQ.XC_SepaMandate__c);
                paymentMethod.put('MandateCreationDate', bpQ.XC_SepaMandateDate__c);
            }
        }

        mapUtilBp.put('paymentMethod', paymentMethod);
        mapUtilBp.put('invoiceEmail', invoiceEmail);
        mapUtilBp.put('invoicePrint', invoicePrint);
        mapUtilBp.put('invoiceLanguage', invoiceLanguage);
        mapUtilBp.put('billProfWr', billProfWr);
        mapUtilBp.put('payment', payment);
        mapUtilBp.put('contractId', contractId);
        mapUtilBp.put('batch', batch);
        mapUtilBp.put('commodityBillingCycleFrequency', commodityBillingCycleFrequency);
        mapUtilBp.put('commodityBP', commodityBP);
    }
    

    /*
    * @param Map<String,Object> - mapAccountDocument 
    * @description method to manage docuemnt to send to zuora
    */
    public static void manageDocument(Map<String,Object> mapAccountDocument){

        List<XC_BillingProfileLineItem__c> billProfLineItemListToInsert  = (List<XC_BillingProfileLineItem__c>)mapAccountDocument.get('billProfLineItemListToInsert');
        XC_UTIL_Account.IdentityIFWrapper identityWr = (XC_UTIL_Account.IdentityIFWrapper) mapAccountDocument.get('identityWr');
        Account acc = (Account)mapAccountDocument.get('acc');

        String docNif;
        
        String docNumber;
        String expedition;
        String expiration;
        String docCountry;
        
        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalInfoMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_Country__c, XC_ValidDocuments__c, XC_SkipZuoraGuest__c, XC_VatGroup_SequenceSet__c, XC_ZuoraSequenceSetId__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: billProfLineItemListToInsert[0].XC_LegalEntity__c AND XC_Stream__c =: acc.XC_Segment__c AND XC_OrgId__c =: orgId]);
        XC_CM_LegalEntity_Configuration__mdt legalInfo = legalInfoMap.values()[0];
        List<String> validDocuments = new List<String>();
        if(String.isNotBlank(legalInfo.XC_ValidDocuments__c)) {
            validDocuments.addAll(legalInfo.XC_ValidDocuments__c.split(';'));  
        }

        // Document info from wrapper
        docNif = (identityWr != null) ?  identityWr.IdentityType : acc.IdentityType__c;
        docNumber = (identityWr != null) ? identityWr.IdentityNumber : (!String.isBlank(acc.XC_CommodityIdentityNumber__c)? acc.XC_CommodityIdentityNumber__c:acc.IdentityNumber__c);// gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        expedition = (identityWr != null) ? identityWr.ReleaseDate : String.valueOf(acc.XC_NIE_expedition_date__c);
        expiration = (identityWr != null) ? identityWr.ExpiryDate : String.valueOf(acc.XC_NIE_expiration_date__c);
        docCountry = (identityWr != null) ? identityWr.Country : acc.XC_DocumentCountry__c;

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


    /*
    * @param mapAccountDocument the map util 
    * @description method to manage valid document 
    */
    public static void manageValidDocument(Map<String,Object> mapAccountDocument){

        String countryCode; 
        Boolean methodPUT = (Boolean) mapAccountDocument.get('methodPUT');
        String docNif = (String) mapAccountDocument.get('docNif');
        String docNumber = (String) mapAccountDocument.get('docNumber');
        String expedition = (String) mapAccountDocument.get('expedition');
        String expiration = (String) mapAccountDocument.get('expiration');
        String docCountry = (String) mapAccountDocument.get('docCountry');
        Account acc = (Account) mapAccountDocument.get('acc');
        XC_PersonalDocument__c  personalDoc = (XC_PersonalDocument__c) mapAccountDocument.get('personalDoc');
        List<String> validDocuments = (List<String>) mapAccountDocument.get('validDocuments');
        XC_CM_LegalEntity_Configuration__mdt legalInfo = (XC_CM_LegalEntity_Configuration__mdt) mapAccountDocument.get('legalInfo');


        // Document info from Query
        if(methodPUT && (String.isBlank(docNif) && String.isBlank(docNumber))){

            Map<Id, XC_PersonalDocument__c> documentsMap = new Map<Id, XC_PersonalDocument__c>([SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_Country__c FROM XC_PersonalDocument__c WHERE XC_Account__c =: acc.Id /*AND XC_Country__c =: legalInfo.XC_Country__c*/ ORDER BY CreatedDate desc]);
            Boolean foundValidDocument = false;
            for(XC_PersonalDocument__c doc : documentsMap.values()) {
                if(validDocuments.contains(doc.XC_DocumentType__c) && (!foundValidDocument || (foundValidDocument && doc.XC_Country__c == legalInfo.XC_Country__c))) {
                    foundValidDocument = true;
                    docNif = doc.XC_DocumentType__c;
                    docNumber = doc.XC_DocumentNumber__c;
                    docCountry = doc.XC_Country__c;
                    expedition = (doc.XC_ReleaseDate__c != null) ? String.valueOf(personalDoc.XC_ReleaseDate__c) : '';
                    expiration = (doc.XC_ExpirationDate__c != null) ?String.valueOf(personalDoc.XC_ExpirationDate__c) : '';
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


    /*
    * Manage wrapper option info to send to zuora
    * @param Map<String, Object> - wrOptionMap 
    * @return XC_REST_Account_B.WrapperOption
    * @description method to manage wrapper options
    */
    public static XC_REST_Account_B.WrapperOption manageWrapperOption(Map<String, Object> wrOptionMap){

        XC_REST_Account_B.wrapperOption wrOptions = new XC_REST_Account_B.wrapperOption();

        Boolean invoiceEmail = (Boolean)wrOptionMap.get('invoiceEmail');
        Boolean invoicePrint = (Boolean)wrOptionMap.get('invoicePrint');
        Boolean splitPayment = (Boolean)wrOptionMap.get('splitPayment');
        String payment = (String)wrOptionMap.get('payment');
        String docNif = (String)wrOptionMap.get('docNif');
        String legalEntity = (String) wrOptionMap.get('LegalEntity');
        Map<String,Object> mapInfos = (Map<String,Object>)wrOptionMap.get('mapInfos');
        XC_CM_LegalEntity_Configuration__mdt legalInfo = (XC_CM_LegalEntity_Configuration__mdt) wrOptionMap.get('legalInfo');

        wrOptions.XC_isGuestReplace = (legalInfo != null && legalInfo.XC_SkipZuoraGuest__c) ? 'No' : ((String) mapInfos.get('isGuest'));
        if(wrOptions.XC_isGuestReplace == 'Yes') {
            wrOptions.SimplifiedInvoiceReplace = 'Yes';
        } else if (legalInfo != null && legalInfo.XC_SkipZuoraGuest__c) {
            wrOptions.SimplifiedInvoiceReplace = 'No';
        } else {
            wrOptions.SimplifiedInvoiceReplace = (String.isBlank(docNif)) ? 'Yes' : 'No';
        }

        //Start VAT GROUP TYPE SequenceSetIds
        String vatGroupTypeStr=(wrOptionMap.get('vatGroupType')!=null) ? (String)wrOptionMap.get('vatGroupType') : '';
        wrOptions.vatGroupSequenceSetId = (vatGroupTypeStr.equals('Gruppo IVA Enel') && String.isNotBlank(legalInfo.XC_VatGroup_SequenceSet__c)) ? legalInfo.XC_VatGroup_SequenceSet__c : null;
        //END VAT GROUP TYPE SequenceSetIds
        
        wrOptions.invoiceDeliveryPrefsEmail = invoiceEmail;
        wrOptions.invoiceDeliveryPrefsPrint = invoicePrint;
        wrOptions.paymentTerm = payment;
        //wrOptions.paymentTerm = (payment == 'Net 7' && !String.isBlank(legalEntity) && legalEntity == 'EnelXItalia') ? 'Net 10' : payment;
        //wrOptions.billCycleDay = 1;
        wrOptions.billCycleDay = 0;
        wrOptions.XC_SplitPaymentReplace = (splitPayment) ? 'Yes' : 'No';
        if(payment == 'Net 7' || payment == 'Net 15'){
            wrOptions.paymentGateway = 'SIA PH SDD';
        }

        if(!String.isBlank((String)wrOptionMap.get('batch'))){
            wrOptions.Batch = (String)wrOptionMap.get('batch');
        }
        
        if(!String.isBlank((String)wrOptionMap.get('commodityBillingCycleFrequency'))){
            wrOptions.XC_CommodityFrequencyReplace = (String)wrOptionMap.get('commodityBillingCycleFrequency');
        }

        if(!String.isBlank((String)wrOptionMap.get('commodityBP'))){
            wrOptions.XC_CommodityAccountIdReplace = (String)wrOptionMap.get('commodityBP');
        }

        wrOptions.zuoraSequenceSetId = (legalInfo != null && String.isNotBlank(legalInfo.XC_ZuoraSequenceSetId__c)) ? legalInfo.XC_ZuoraSequenceSetId__c : null;

        return wrOptions;
    }


    /**
    * @param paymentMethod - Map<String,Object>
    * @description Method to check if all credit card mandatory field are filled
    */
    public static Boolean checkMandatoryCCValues(Map<String,Object> paymentMethod){
            
        Boolean checkCC = true;
        List<String> mandatoryCCvalues = new List<String>{'TokenId', 'CreditCardNumber', 'CreditCardType', 'CreditCardExpirationMonth', 'CreditCardExpirationYear'};

        Boolean checkPayPal = true;
        List<String> mandatoryPayPalvalues = new List<String>{'TokenId', 'SecondTokenId', 'CreditCardType'};

        for(String value : paymentMethod.keySet()){
            if(mandatoryCCvalues.contains(value) && String.isBlank((String)paymentMethod.get(value))){
                checkCC = false;
            }
            if(mandatoryPayPalvalues.contains(value) && String.isBlank((String)paymentMethod.get(value))){
                checkPayPal = false;
            }
        }
        if(paymentMethod.get('CreditCardType') == null || String.isBlank((String)paymentMethod.get('CreditCardType'))) {
            checkCC = false;
            checkPayPal = false;
        }

        System.debug('paymentMethod: ' + paymentMethod);
        System.debug('checkCC: ' + checkCC);
        System.debug('checkPayPal: ' + checkPayPal);

        return checkCC || checkPayPal;
    }


    /**
    * @param paymentMethod - Map<String,Object>
    * @description Method to check if all commodity mandatory field are filled
    */
    /*public static Boolean checkMandatoryCBValues(Map<String,Object> paymentMethod){
            
        Boolean check = true;
        //List<String> mandatoryCBvalues = new List<String>{'CupsID', 'CommodityContractNum'};
        List<String> mandatoryCBvalues = new List<String>{'CommodityContractNum'};

        for(String value : paymentMethod.keySet()){
            if(mandatoryCBvalues.contains(value) && String.isBlank((String)paymentMethod.get(value))){
                check = false;
            }
        }


        
        
        return check;
    }*/
    
    
    /**
    * @param zuoraMap - Map<String,String>
    * @description Method to call Zuora
    */
    public static void callZuoraSync(Map<String,String> zuoraMap){
        List<XC_Integration_Log__c> integrationLogOutboundToInsert = new List<XC_Integration_Log__c>();     
        try{
        String account = zuoraMap.get('account');
        String legalEntity = zuoraMap.get('legalEntity');
        String options = zuoraMap.get('options');
        String billingProfLineItemId = zuoraMap.get('billingProfLineItemId');
        String zuoraPayment = zuoraMap.get('zuoraPayment');
        String mapPayment = zuoraMap.get('mapPayment');
        String billingProfId = zuoraMap.get('billingProfId');
        String bpli = zuoraMap.get('bpli');
        String country = zuoraMap.get('country');
		String trasactionId = zuoraMap.get('TransactionID');
        String isWaitingExtAct = zuoraMap.get('isWaitingExtAct');
        // BEGIN - [2021-11-24 :: TP :: Third Party Billing :: tpbcode]
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(zuoraPayment);
        String tpbCode = m.containsKey('tpbCode') ? String.valueOf(m.get('tpbCode')) : null;
        // END - [2021-11-24 :: TP :: Third Party Billing :: tpbcode]
        Account acc = (Account) JSON.Deserialize(account, Account.Class);

    
        Map<String,String> typeMap = new Map<String,String>{
                                                            'Cash' => 'Cash',
                                                            'Bank Transfer' => 'BankTransfer',
                                                            'Commodity Bill' => 'CommodityBill',
                                                            'Barcode' => 'Barcode',
                                                            'External Financing' => 'External Financing',
                                                            'Online' => 'Online'
                                                            };

            
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        Map<String,Object> paymentMethod = (Map<String,Object>) JSON.deserializeUntyped(mapPayment);
        system.debug('paymentMethod'+ paymentMethod);

        XC_BillingProfileLineItem__c bpliToCheck = (XC_BillingProfileLineItem__c) JSON.Deserialize(bpli, XC_BillingProfileLineItem__c.class);


        // serialize contact
        Map<String,String> contactSerializedMap = new Map<String,String>{
                                                            'bpli' => bpli,
                                                            'country' => country};
        manageContactSerialized(contactSerializedMap); 
        String billingContact = (String)contactSerializedMap.get('contactBillSerialized'); 
        String soldContact = (String)contactSerializedMap.get('contactSoldSerialized');



        // get zuora entity name by legal entity
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, acc.XC_Segment__c);
        if(String.isBlank(entityName)){
            XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
            logWr.httpMethod = 'POST'; 
            logWr.logIsSuccess = false;
            logWr.logIntegrationName = 'RetrieveZuoraEntityName';
            logWr.logMessage = 'Retrieve zuora entity name by legalEntity: ' + legalEntity;
            intLog.insertIntegReqOutboundLog(logWr);
            intLog.insertIntegRespOutboundLog(false,'ERROR. Unable to retrieve zuora entity name by legalEntity: '+ legalEntity, '500', 'Unable to retrieve zuora entity name by legalEntity: '+ legalEntity);
            return;
        }

        Map<Id, XC_BillingProfileLineItem__c> bpliMap = new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_CustomerAccount__c, XC_ZuoraId__c, XC_Status__c
                                                                                                    FROM XC_BillingProfileLineItem__c
                                                                                                    WHERE XC_Account__c =: acc.Id 
                                                                                                    AND XC_LegalEntity__c =: legalEntity 
                                                                                                    AND XC_BillingProfile__c =: billingProfId
                                                                                                    AND XC_BillToAddress__c =: bpliToCheck.XC_BillToAddress__c
                                                                                                    AND XC_SoldToAddress__c =: bpliToCheck.XC_SoldToAddress__c
                                                                                                    AND XC_CustomerAccount__c != null
                                                                                                    AND XC_TPBCode__c = :tpbCode LIMIT 1]);//[2021-11-24 :: TP :: Third Party Billing :: added tpbCode]
        
        XC_BillingProfileLineItem__c bpliToUpdate = new XC_BillingProfileLineItem__c(Id = billingProfLineItemId); 
        String accZuoraId;  
        if(bpliMap.isEmpty()) {
            //createUnlinkedZuoraAccount
            ZuoraWebService.CreateZuoraAccountResponse mapResult = (ZuoraWebService.CreateZuoraAccountResponse)JSON.deserialize(ZuoraBillingProfileCreationController.createUnlinkedZuoraAccount(account, billingContact, soldContact, entityName, options, billingProfLineItemId, zuoraPayment),ZuoraWebService.CreateZuoraAccountResponse.class);
            system.debug('MapResult -> ' + mapResult);
            mapResult.integrationLog.XC_Log_TransactionId__c = trasactionId;
            mapResult.integrationLog.XC_BillingProfileLineItem__c = billingProfLineItemId;
			integrationLogOutboundToInsert.add(mapResult.integrationLog);
            if(mapResult.success == 'true') {
                accZuoraId = mapResult.accountId;
            }else{
                // populate integration log - create unlinked ZuoraAccount
              /*  String entity = '%'+entityName+'%';
                String orgId = UserInfo.getOrganizationId();
                XC_CM_ZuoraOAuth__mdt authData = [SELECT  XC_Host__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE:entity AND XC_OrgId__c =: orgId][0];
                String msgRequest = 'Account: '+ account + ', BillingContact: ' + billingContact + ', SoldContact: ' + soldContact + ', EntityName: ' + entityName + ', Options: ' + options + ', BillingProfLineItemId: ' + billingProfLineItemId + ', ZuoraPayment: '+  zuoraPayment;
                XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
                logWr.logEndpoint = 'https://'+authData.XC_Host__c+ '/v1/accounts';
                logWr.httpMethod = 'POST'; 
                logWr.logIsSuccess = false;
                logWr.logIntegrationName = 'createUnlinkedZuoraAccount';
                logWr.logMessage = msgRequest;
                intLog.insertIntegReqOutboundLog(logWr);
                intLog.insertIntegRespOutboundLog(false,  JSON.serialize(mapResult), '500', JSON.serialize(mapResult.get('reasons'))); */
				if(!integrationLogOutboundToInsert.isEmpty()){
					XC_UTIL_Sobject.insertListRecords(integrationLogOutboundToInsert);
                    //BEGIN,neeraj.saini@accenture.com, Call Zuora refactoring
                    manageRetry(billingProfLineItemId,mapResult.integrationLog?.XC_Log_Response__c,System.Label.XC_CL_CreateUnlinkedZuoraAcc,System.Label.XC_CL_KOFromZuora);
                    //END,neeraj.saini@accenture.com, Call Zuora refactoring
				}
                return;
            }
        } else {
            accZuoraId = bpliMap.values()[0].XC_ZuoraId__c;
            bpliToUpdate.XC_CustomerAccount__c = bpliMap.values()[0].XC_CustomerAccount__c;
            bpliToUpdate.XC_Status__c = 'Active';
        }
            
        List<String> paymentList = new List<String>{'External Financing', 'Cash', 'Bank Transfer', 'Commodity Bill', 'Barcode', 'Online'};
        //linkAccountToExternalPaymentMethod
        if(paymentList.contains((String)paymentMethod.get('Type'))){
            system.debug('In linkAccountToExternalPaymentMethod');
            system.debug('PaymentMethodType'+ paymentMethod.get('Type'));
           Map<String,Object> linkExternalResult = ZuoraBillingProfileCreationController.linkAccountToExternalPaymentMethod(accZuoraId,typeMap.get((String)paymentMethod.get('Type')), entityName);
           
           if(linkExternalResult.containsKey('integrationLog')){
            XC_Integration_Log__c linkExternalMOPLog = (XC_Integration_Log__c) linkExternalResult.get('integrationLog');
            linkExternalMOPLog.XC_Log_TransactionId__c = trasactionId;
            linkExternalMOPLog.XC_BillingProfileLineItem__c = billingProfLineItemId;
            integrationLogOutboundToInsert.add(linkExternalMOPLog);
            //BEGIN,neeraj.saini@accenture.com, Call Zuora refactoring
            if(!linkExternalMOPLog.XC_Log_IsSuccess__c){
                manageRetry(billingProfLineItemId,linkExternalMOPLog?.XC_Log_Response__c,System.Label.XC_CL_linkAccToExternalPayment,System.Label.XC_CL_KOFromZuora);
                return;
            }
            //END,neeraj.saini@accenture.com, Call Zuora refactoring
           }

		} else {
			String paymentMethodSerialized;
			paymentMethod.put('AccountId', accZuoraId);

			if(paymentMethod.get('Type') == 'BankTransfer'){
                XC_BillingProfileLineItem__c bpliq = [SELECT id, XC_BillingProfile__r.XC_SepaMandate__c, XC_BillingProfile__r.XC_SepaMandateDate__c, XC_BillingProfile__r.XC_Token__c FROM XC_BillingProfileLineItem__c WHERE Id=: billingProfLineItemId][0];
                paymentMethod.put('MandateID', bpliq.XC_BillingProfile__r.XC_SepaMandate__c);
                paymentMethod.put('MandateCreationDate', bpliq.XC_BillingProfile__r.XC_SepaMandateDate__c);
                paymentMethod.put('BankTransferAccountNumber', bpliq.XC_BillingProfile__r.XC_Token__c);
                paymentMethod.put('TokenId', bpliq.XC_BillingProfile__r.XC_Token__c);
			}

            if(paymentMethod.get('SecondTokenId') != null && String.valueOf(paymentMethod.get('SecondTokenId')) != '') {
                paymentMethod.remove('CreditCardExpirationMonth');
                paymentMethod.remove('CreditCardExpirationYear');
                paymentMethod.remove('CreditCardType');
                paymentMethod.remove('CreditCardNumber');
                paymentMethod.remove('CreditCardHolderName');
            } else {
                paymentMethod.remove('SecondTokenId');
            }

            //createPaymentMethod
            system.debug('BeforeCreatePaymentMethod');
            system.debug('paymentMethodSerialized'+ JSON.Serialize(paymentMethod, true));
            
			ZuoraWebService.CreatePaymentMethodResponse mapResultPayment =  (ZuoraWebService.CreatePaymentMethodResponse)JSON.deserialize(ZuoraBillingProfileCreationController.createPaymentMethod(JSON.Serialize(paymentMethod, true), entityName),ZuoraWebService.CreatePaymentMethodResponse.class);
            system.debug('AfterCreatePayment'+ mapResultPayment);
            mapResultPayment.integrationLog.XC_Log_TransactionId__c = trasactionId;
            mapResultPayment.integrationLog.XC_BillingProfileLineItem__c = billingProfLineItemId;
			integrationLogOutboundToInsert.add(mapResultPayment.integrationLog);
            
			if(mapResultPayment.Success == 'true'){

                //linkPaymentMethodToAccount
                system.debug('Before linkPaymentMethodToAccount');
                ZuoraWebService.LinkPaymentMethodToAccountResponse mapResultLink =  (ZuoraWebService.LinkPaymentMethodToAccountResponse)JSON.deserialize(ZuoraBillingProfileCreationController.linkPaymentMethodToAccount(accZuoraId, mapResultPayment.Id, entityName), ZuoraWebService.LinkPaymentMethodToAccountResponse.class);
                system.debug('After linkPaymentMethodToAccount'+mapResultLink);
                mapResultLink.integrationLog.XC_Log_TransactionId__c = trasactionId;
                mapResultLink.integrationLog.XC_BillingProfileLineItem__c = billingProfLineItemId;
				integrationLogOutboundToInsert.add(mapResultLink.integrationLog);
				
				if(mapResultLink.Success != 'true'){ // populate integration log - link payment method to account
                    /*String entity = '%'+entityName+'%';
                    String orgId = UserInfo.getOrganizationId();
                    XC_CM_ZuoraOAuth__mdt authData = [SELECT  XC_Host__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE:entity AND XC_OrgId__c =: orgId][0];
                    String msgRequest = 'AccountZuoraId: '+ accZuoraId + ', PaymentMethodId: ' + (String)mapResultLink.get('paymentMethodId') + ', EntityName: ' + entityName;
                    XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
                    logWr.logEndpoint = 'https://'+authData.XC_Host__c+'/v1/object/account/'+ accZuoraId;
                    logWr.httpMethod = 'PUT'; 
                    logWr.logIsSuccess = false;
                    logWr.logIntegrationName = 'linkPaymentMethodToAccount';
                    logWr.logMessage = msgRequest;
                    intLog.insertIntegReqOutboundLog(logWr);
                    intLog.insertIntegRespOutboundLog(false,  JSON.serialize(mapResultLink), '500', JSON.serialize(mapResultLink.get('Errors')));*/
                    if(!integrationLogOutboundToInsert.isEmpty()){
                        //BEGIN,neeraj.saini@accenture.com, Call Zuora refactoring
                        manageRetry(billingProfLineItemId,mapResultLink.integrationLog?.XC_Log_Response__c,System.Label.XC_CL_CreatePaymentMethod,System.Label.XC_CL_KOFromZuora);
                        //END,neeraj.saini@accenture.com, Call Zuora refactoring
						XC_UTIL_Sobject.insertListRecords(integrationLogOutboundToInsert);
					}
					return;
                }
            }else{ // populate integration log - create payment method
                /*String entity = '%'+entityName+'%';
                String orgId = UserInfo.getOrganizationId();
                XC_CM_ZuoraOAuth__mdt authData = [SELECT  XC_Host__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE:entity AND XC_OrgId__c =: orgId][0];
                String msgRequest = 'PaymentMethod: ' + JSON.Serialize(paymentMethod, true) + ', EntityName: ' + entityName;
                XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
                logWr.logEndpoint = 'https://'+authData.XC_Host__c+'/v1/object/payment-method';
                logWr.httpMethod = 'POST'; 
                logWr.logIsSuccess = false;
                logWr.logIntegrationName = 'createPaymentMethod';
                logWr.logMessage = msgRequest;
                intLog.insertIntegReqOutboundLog(logWr);
                intLog.insertIntegRespOutboundLog(false,  JSON.serialize(mapResultPayment), '500', JSON.serialize(mapResultPayment.get('Errors'))); */
				if(!integrationLogOutboundToInsert.isEmpty()){
                    //BEGIN,neeraj.saini@accenture.com, Call Zuora refactoring
                    manageRetry(billingProfLineItemId,mapResultPayment.integrationLog?.XC_Log_Response__c,System.Label.XC_CL_LinkPaymentMethodToAcc,System.Label.XC_CL_KOFromZuora);
                    //END,neeraj.saini@accenture.com, Call Zuora refactoring
					XC_UTIL_Sobject.insertListRecords(integrationLogOutboundToInsert);
				}
                return;
            }
        }
		
		if(!integrationLogOutboundToInsert.isEmpty()){
			XC_UTIL_Sobject.insertListRecords(integrationLogOutboundToInsert);
		}
        
        Map<Id, XC_BillingProfileLineItem__c> bpliToCheckMap = new Map<Id, XC_BillingProfileLineItem__c>([SELECT XC_Status__c,XC_BillingProfile__c,XC_BillingProfile__r.XC_Status__c FROM XC_BillingProfileLineItem__c WHERE Id =: billingProfLineItemId]);
      
        if(bpliToCheckMap.get(billingProfLineItemId) != null && !String.isBlank(bpliToCheckMap.get(billingProfLineItemId).XC_BillingProfile__c) && bpliToCheckMap.get(billingProfLineItemId).XC_BillingProfile__r.XC_Status__c != Label.XC_CL_Billing_Active){
            NE__Billing_Profile__c bpToUpdate = new NE__Billing_Profile__c(Id = billingProfId, XC_Status__c = (isWaitingExtAct == 'Y') ? Label.XC_CL_BillingProfileWaiting : 'Sent To Zuora');
            XC_UTIL_Sobject.WrapperResult result = XC_UTIL_SObject.updateRecord(bpToUpdate);
            system.debug(result);
            if(!result.success){
                intLog.insertIntegReqInboundLog('UpdateBillingProfile: ', JSON.serialize(bpToUpdate));
                intLog.insertIntegRespInboundLog('500', false, 'INTERNAL ERROR: In Update Billing Profile to Sent to Zuora ' + result.errorMessage, 'INTERNAL ERROR: In Update Billing Profile to Sent to Zuora ' + result.errorMessage);
            }
        }
        
        if(bpliToCheckMap.get(billingProfLineItemId) != null && bpliToCheckMap.get(billingProfLineItemId).XC_Status__c != Label.XC_CL_Billing_Active){
            bpliToUpdate.XC_Status__c =  (isWaitingExtAct == 'Y') ?  Label.XC_CL_BillingProfileWaiting : 'Sent To Zuora';
            //BEGIN,neeraj.saini@accenture.com, Call Zuora refactoring
            bpliToUpdate.XC_ZuoraIntegrationAccountId__c = accZuoraId ;
            bpliToUpdate.XC_ZuoraIntegrationIsToRetry__c = false;
            //BEGIN,jeevani.donthala@accenture.com
            bpliToUpdate.XC_ZuoraIntegrationErrorLog__c  = '';
            //END,jeevani.donthala@accenture.com
            bpliToUpdate = saveSubStatus(System.Label.XC_CL_CompletedOK, bpliToUpdate);
            //END,neeraj.saini@accenture.com, Call Zuora refactoring
            XC_UTIL_Sobject.WrapperResult resultBpli = XC_UTIL_SObject.updateRecord(bpliToUpdate);
            system.debug(resultBpli);
            if(!resultBpli.success){
                intLog.insertIntegReqInboundLog('UpdateBillingProfile: ', JSON.serialize(bpliToUpdate));
                intLog.insertIntegRespInboundLog('500', false, 'INTERNAL ERROR: In Update Billing Profile Line Item to Sent to Zuora ' + resultBpli.errorMessage, 'INTERNAL ERROR: In Update Billing Profile to Sent to Zuora ' + resultBpli.errorMessage);
            }
        }
        
        //FIX for Waiting for External Activation BP that prevents the Activation if a new BPLI is generated 17/03/2022
        if(bpliToCheckMap.get(billingProfLineItemId) != null && isWaitingExtAct != 'Y' && bpliToCheckMap.get(billingProfLineItemId).XC_BillingProfile__c != null) {
            Map<Id, XC_BillingProfileLineItem__c> bpliBroToCheckMap = new Map<Id, XC_BillingProfileLineItem__c>([SELECT id, XC_Status__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bpliToCheckMap.get(billingProfLineItemId).XC_BillingProfile__c and id !=: billingProfLineItemId]);
            System.debug('In Waiting External Activation FIX. Query Result --> '+bpliBroToCheckMap);
            if(!bpliBroToCheckMap.isEmpty()){
                for(XC_BillingProfileLineItem__c tempBpli : bpliBroToCheckMap.values())
                {                   
                    if (tempBpli.XC_Status__c == Label.XC_CL_BillingProfileWaiting) {
                        bpliToUpdate.XC_Status__c = Label.XC_CL_BillingProfileWaiting;
                        XC_UTIL_Sobject.WrapperResult resultBpli = XC_UTIL_SObject.updateRecord(bpliToUpdate);
                        system.debug('resultBpli: '+resultBpli);
                        NE__Billing_Profile__c bpToUpdate = new NE__Billing_Profile__c(Id = bpliToCheckMap.get(billingProfLineItemId).XC_BillingProfile__c, XC_Status__c = Label.XC_CL_BillingProfileWaiting);
                        XC_UTIL_Sobject.WrapperResult resultBp = XC_UTIL_SObject.updateRecord(bpToUpdate);
                        system.debug('resultBp: '+resultBp);
                        if(!resultBpli.success || !resultBp.success){
                            intLog.insertIntegReqInboundLog('UpdateBillingProfileLineItem: ', JSON.serialize(bpliToUpdate));
                            intLog.insertIntegRespInboundLog('500', false, 'INTERNAL ERROR: In Update Billing Profile Line Item to Waiting External Activation ' + resultBpli.errorMessage, 'INTERNAL ERROR: In Update Billing Profile to Sent to Zuora ' + resultBp.errorMessage);
                        }                        
                        break;
                    }
                }
            }
        }
    }
    catch(Exception e){
        //BEGIN,neeraj.saini@accenture.com, Call Zuora refactoring
        System.debug(e.getMessage());
        //System.debug(zuoraMap.get('billingProfLineItemId'));
        List<XC_Integration_Log__c> integrationLogOutboundNotYetInserted = new List<XC_Integration_Log__c>();
        for(XC_Integration_Log__c ilog : integrationLogOutboundToInsert){
            if(ilog.id == null){
                integrationLogOutboundNotYetInserted.add(ilog);
            }
        }
        if(!integrationLogOutboundNotYetInserted.isEmpty()){
            XC_UTIL_Sobject.insertListRecords(integrationLogOutboundNotYetInserted);
        }
        manageRetry(zuoraMap.get('billingProfLineItemId'),e.getMessage() +' : '+e.getStackTraceString(),'',System.Label.XC_CL_ExceptionInvokingZuora);
        //END,neeraj.saini@accenture.com, Call Zuora refactoring
    }
        
    }



    /**
    * @param mapUtil - Map<String,Objetc>
    * @description Method to serializedContact
    */
    public static void manageContactSerialized(Map<String,String> mapUtil){

        String billingProfileLineItem = mapUtil.get('bpli');
        XC_BillingProfileLineItem__c bpli = (XC_BillingProfileLineItem__c) JSON.deserialize(billingProfileLineItem, XC_BillingProfileLineItem__c.Class);
        String country = mapUtil.get('country');

        
        String contactSoldSerialized;
        String contactBillSerialized;


        if(bpli.XC_SoldToAddress__c == bpli.XC_BillToAddress__c){
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrWr = ZuoraBillingProfileCreationController.prepareContactForZuora(bpli.XC_BillToContactId__c, bpli.XC_SoldToAddress__c, bpli.XC_LegalEntity__c);
            contactSoldSerialized = JSON.Serialize(conAddrWr);
            contactBillSerialized = JSON.Serialize(conAddrWr);
        }else{
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrBillWr = ZuoraBillingProfileCreationController.prepareContactForZuora(bpli.XC_BillToContactId__c,  bpli.XC_BillToAddress__c, bpli.XC_LegalEntity__c);
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrSoldWr = ZuoraBillingProfileCreationController.prepareContactForZuora(bpli.XC_SoldToContactId__c, bpli.XC_SoldToAddress__c, bpli.XC_LegalEntity__c);
            contactBillSerialized = JSON.Serialize(conAddrBillWr);
            contactSoldSerialized = JSON.Serialize(conAddrSoldWr);
        }

        mapUtil.put('contactBillSerialized', contactBillSerialized);
        mapUtil.put('contactSoldSerialized', contactSoldSerialized);

    }


    /*
    * @param info - String
    * @param billingProfile - NE__Billing_Profile__c
    * @description Method to create a billing profile 
    */
    public static void  createBillingProfile(String info, NE__Billing_Profile__c billingProfile){
                
        System.debug('@@@@Options Map' +info);
        String cardNumber;
        String subNumber;
        String accountNumber;
        String contractId;
        String siaToken;
        String payPalUsername;
        String billingStatus = String.isBlank(billingProfile.id) ? 'Draft' : null;
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(info);
        String paymentMethod = String.valueOf(optionsMap.get('paymentMethodType'));
        String accountId = String.valueOf(optionsMap.get('accountId'));
        Boolean fromBillingProfile = false;
        String totalName;
        if(optionsMap.containsKey('cardNumber')){
            cardNumber = String.valueOf(optionsMap.get('cardNumber'));
            subNumber ='  ****-****-****-'+cardNumber.substring(12);
        }
        if(optionsMap.containsKey('accountNumber')){
            accountNumber =  String.valueOf(optionsMap.get('accountNumber'));
        }
        if(optionsMap.containsKey('contractId')){
            contractId =  String.valueOf(optionsMap.get('contractId'));
        }
        if(optionsMap.containsKey('siaPayment')){
            String siaTokenToParse = String.valueOf(optionsMap.get('siaPayment'));
            if(siaTokenToParse != 'createZuoraCustomer'){
                Map<String, Object> siaTokenMap = (Map<String, Object>)JSON.deserializeUntyped(siaTokenToParse);
                siaToken = String.valueOf(siaTokenMap.get('debtorCode'));
            }    
        }
        if(optionsMap.containsKey('fromBillingProfile')){
            fromBillingProfile = Boolean.valueOf(optionsMap.get('fromBillingProfile'));  
        }
        if(optionsMap.containsKey('payPalUsername')){
            payPalUsername = String.valueOf(optionsMap.get('payPalUsername'));
        }

        String cardType = XC_UTIL_SObject.getPicklistValueIgnoreCase(String.valueOf(optionsMap.get('creditCardType')), 'NE__Billing_Profile__c', 'NE__Card_Type__c');
        
        if(paymentMethod != null || !String.isBlank(billingProfile.NE__Payment__c)){
            if((paymentMethod == 'Credit Card' || billingProfile.NE__Payment__c == 'Credit Card') && !String.isBlank(subNumber)){
                paymentMethod = (paymentMethod != null) ? paymentMethod : billingProfile.NE__Payment__c;
                totalName = ZuoraBillingProfileCreationController.billingName(paymentMethod,subNumber);
            } else if((paymentMethod == 'Credit Card' || billingProfile.NE__Payment__c == 'Credit Card') && !String.isBlank(cardType) && cardType.equalsIgnoreCase('PayPal')) {
                paymentMethod = (paymentMethod != null) ? paymentMethod : billingProfile.NE__Payment__c;
                totalName = (String.isBlank(payPalUsername)) ? ZuoraBillingProfileCreationController.billingName(paymentMethod, 'PayPal') : ZuoraBillingProfileCreationController.billingName(paymentMethod, 'PayPal - ' + payPalUsername);
            } else if((paymentMethod == 'Commodity Bill' || billingProfile.NE__Payment__c == 'Commodity Bill') && !String.isBlank(contractId)){
                paymentMethod = (paymentMethod != null) ? paymentMethod : billingProfile.NE__Payment__c;
                totalName = ZuoraBillingProfileCreationController.billingName(paymentMethod,contractId);
            }else if((paymentMethod == 'SEPA' || (billingProfile.Name!= null && billingProfile.Name.containsIgnoreCase('SEPA')))){ /* 20/09/2019*/
                billingProfile.XC_CreateMandate__c = true;
                paymentMethod = (paymentMethod != null) ?  'Direct Debt' : billingProfile.NE__Payment__c;
                if(!String.isBlank(accountNumber)){
                    totalName = ZuoraBillingProfileCreationController.billingName('SEPA', accountNumber);
                }else{
                    totalName = (!String.isBlank(billingProfile.Name)) ? billingProfile.Name: 'SEPA';
                }
            }else if((paymentMethod == 'Direct Debt' || (billingProfile.Name!= null && billingProfile.Name.containsIgnoreCase('Direct Debt')))){ /* 20/09/2019*/
                paymentMethod = (paymentMethod != null) ? paymentMethod : billingProfile.NE__Payment__c;
                if(!String.isBlank(accountNumber)){
                    totalName = ZuoraBillingProfileCreationController.billingName(paymentMethod, accountNumber);
                }else{
                    totalName = (!String.isBlank(billingProfile.Name)) ? billingProfile.Name: 'Direct Debt';
                }
            }else{
                totalName = (!String.isBlank(billingProfile.Id)) ? billingProfile.Name : paymentMethod;
            }
        }


        System.debug('accountId ='+accountId);
        System.debug('From BIlling='+fromBillingProfile);
        XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();

        String clientSystem = String.valueOf(optionsMap.get('clientSystem'));
        String mtype = String.valueOf(optionsMap.get('SEPAMandateType'));
        if(mtype=='Recurring' || (String.isBlank(mtype) && clientSystem == Label.XC_CL_CommoditySpainB2C && paymentMethod == Label.XC_CL_Commodity_Bill)){ 
            mtype = 'RECURRENT';
        } else if(mtype=='One time'){
            mtype = 'ONE_SHOT';
        }
 
        System.debug('@@TOTAL NAME ='+totalName);
        Map<String, Object> mapBillingProfileWrapper = new Map<String,Object>{'Name' => totalName, /*(totalName.containsIgnoreCase('Direct Debt')) ? totalName.replace('Direct Debt', 'SEPA') :  totalName  20/09/2019 */
                                                                            'NE__Payment__c' => paymentMethod,
                                                                            'NE__Account__c' => accountId,
                                                                            'NE__Card_Number__c' =>  cardNumber,
                                                                            'NE__Expiration__c' => String.valueOf(optionsMap.get('month')),
                                                                            'NE__Expiration_Year__c' => String.valueOf(optionsMap.get('year')),
                                                                            'XC_CommodityContractID__c' => String.valueOf(optionsMap.get('contractId')),
                                                                            'XC_CommodityCupsID__c' => String.valueOf(optionsMap.get('cupsId')),
                                                                            'XC_Status__c' => (String.isNotBlank(String.valueOf(optionsMap.get('Status'))) && !String.valueOf(optionsMap.get('Status')).equalsIgnoreCase(Label.XC_CL_BillingProfileActive)) ? String.valueOf(optionsMap.get('Status')) : billingStatus,
                                                                            'XC_Token__c' => siaToken,
                                                                            'XC_InvoiceDeliveryPref__c' =>  String.valueOf(optionsMap.get('invoiceDeliveryPref')),
                                                                            'XC_InvoicePreferredLanguage__c' => String.valueOf(optionsMap.get('invoicePreferredLanguage')),
                                                                            'NE__Mail_To__c' => String.valueOf(optionsMap.get('email')),
                                                                            'XC_ZipCode__c' => String.valueOf(optionsMap.get('postalCode')),
                                                                            'XC_City__c' => String.valueOf(optionsMap.get('city')),
                                                                            'XC_Province__c' => String.valueOf(optionsMap.get('state')),
                                                                            'NE__Iban__c' => String.valueOf(optionsMap.get('accountNumber')),
                                                                            'NE__Card_Type__c' => cardType,
                                                                            'XC_SepaMandate__c' => String.valueOf(optionsMap.get('SEPAMandateId')), 
                                                                            'XC_SepaMandateDate__c' => (String.isNotBlank(String.valueOf(optionsMap.get('SEPAMandateDate')))) ? Date.valueOf(String.valueOf(optionsMap.get('SEPAMandateDate'))) : null,
                                                                            'XC_BIC__c' => String.valueOf(optionsMap.get('SEPABIC')),
                                                                            'XC_MandateType__c' =>  mtype,
                                                                            'XC_LegalEntity__c' => (paymentMethod == Label.XC_CL_DirectDebt || paymentMethod == Label.XC_CL_Commodity_Bill) ? optionsMap.get('legal') : null,
                                                                            'XC_PayPalUsername__c' => payPalUsername, 
                                                                            'XC_CommodityBillingCycleFrequency__c' => (!String.isBlank(String.valueOf(optionsMap.get('commodityBillingCycleFrequency')))) ? String.valueOf(optionsMap.get('commodityBillingCycleFrequency')) : null,
                                                                            'XC_SAPBusinessPartner__c' => String.valueOf(optionsMap.get('SAPBusinessPartner')),
                                                                            'XC_StatusReason__c' => String.valueOf(optionsMap.get('Reason')),
                                                                            'XC_StatusReasonDetails__c' => String.valueOf(optionsMap.get('ReasonDetails')),
                                                                            'XC_LastEventDate__c' => (String.isNotBlank(String.valueOf(optionsMap.get('EventDate')))) ? Date.valueOf(String.valueOf(optionsMap.get('EventDate'))) : null,
                                                                            'XC_CommodityUsage__c' => String.valueOf(optionsMap.get('CommodityUsage')),
                                                                            'XC_ConsumptionNumber__c' => String.valueOf(optionsMap.get('ConsumptionNumber')),
                                                                            'XC_OPDocumentNumber__c' => String.valueOf(optionsMap.get('OPDocumentNumber')),
                                                                            'XC_OPDocumentType__c' => String.valueOf(optionsMap.get('OPDocumentType')),
                                                                            'XC_SkipDuplication__c' => String.isNotBlank(String.valueOf(optionsMap.get('SkipDuplication'))) ? Boolean.valueOf(optionsMap.get('SkipDuplication')) : null,
                                                                            'XC_isGuest__c' => String.isNotBlank(String.valueOf(optionsMap.get('SkipDuplication'))) ? (Boolean.valueOf(optionsMap.get('SkipDuplication')) == true ? 'true' : 'false') : null,
                                                                            'XC_CurrentActiveEmobApp__c' => String.isNotBlank(String.valueOf(optionsMap.get('CurrentActiveEmobApp'))) ? Boolean.valueOf(optionsMap.get('CurrentActiveEmobApp')) : null
                                                                            };
        
        System.debug('billingProfile'+ billingProfile);
        for(String key : mapBillingProfileWrapper.keySet()){
            if(mapBillingProfileWrapper.get(key) != null){
                billingProfile.put(key, mapBillingProfileWrapper.get(key));
            }
        }
    }


    /* @description the utilWrapper */
    public class utilWrapper{
        public Integer i;
        public XC_UTIL_BillingProfile.BillingProfileIFWrapper billProfileWr;
    }
    
    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description CallZuora queue Call
    */
    public static void callZuora(Map<String,String> zuoraMap){
        try{
            ID jobID = System.enqueueJob(new XC_QU002_CallZuora(zuoraMap,true));
        } catch(Exception e) {
            manageRetry(zuoraMap.get('billingProfLineItemId'),e.getMessage() +' : '+e.getStackTraceString(),'','ExceptionInvokingQueueZuora');
        }
            
    }

    
    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description Manage the retry for call zuora
    */
    public static void manageRetry(String bpliId, String errorLog, String apiName, String subStatus){
        XC_BillingProfileLineItem__c bpliUpdateRec = new XC_BillingProfileLineItem__c();
        bpliUpdateRec.id = bpliId;
        bpliUpdateRec.XC_ZuoraIntegrationIsToRetry__c = true;
        bpliUpdateRec = saveErrorLog(errorLog,bpliUpdateRec,apiName);
        bpliUpdateRec = saveSubStatus(subStatus,bpliUpdateRec);
        XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_SObject.updateRecord(bpliUpdateRec);
        XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }

    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description Save substatus on BPLI
    */
    public static XC_BillingProfileLineItem__c saveSubStatus(String substatus,XC_BillingProfileLineItem__c bpli){
        XC_BillingProfileLineItem__c bpliUpdateRec = bpli;
        bpliUpdateRec.XC_ZuoraIntegrationSubStatus__c   = substatus;
        system.debug(bpliUpdateRec);
        return bpliUpdateRec;
    }

    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description Save Zuora integration log on BPLI
    */
    public static XC_BillingProfileLineItem__c saveErrorLog(String log,XC_BillingProfileLineItem__c bpli, String apiName){
        XC_BillingProfileLineItem__c bpliUpdateRec = bpli;
        bpliUpdateRec.XC_ZuoraIntegrationErrorLog__c = (String.isBlank(apiName)? 'Generic Exception : ' : 'API '+ apiName +' invoked : ') + log;
        return bpliUpdateRec;
    }

    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description Save Zuora integration tech parameter on BPLI
    */
    public static XC_BillingProfileLineItem__c saveTechParameter(Map<String,String> zuoraMap, XC_BillingProfileLineItem__c bpli){
        XC_BillingProfileLineItem__c bpliUpdateRec = bpli;
        bpliUpdateRec.XC_ZuoralntegrationTechnicaParameter__c  = JSON.Serialize(zuoraMap);
        return bpliUpdateRec;
    }

    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description To callzuora from Retry 
    */
    public static void callZuoraFromRetrieveButton(List<id> bpliIdList){
        Map<Id, Map<String,String>> zuoraMapbulk = retrieveMap(bpliIdList);
        for(Map<String,String> Trace : zuoraMapbulk.values()){
            System.enqueueJob(new XC_QU002_CallZuora(Trace,false));
        } 
    }
        
  
  
    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description To retrive the map stored on BPLI
    */
    public static Map<Id, Map<String,String>> retrieveMap(List<Id> bpliIdList){
        
        List<XC_BillingProfileLineItem__c> bpliList = [Select id,XC_ZuoralntegrationTechnicaParameter__c from XC_BillingProfileLineItem__c where id in :bpliIdList];
        Map<Id, Map<String,String>> resultMap = New Map<Id, Map<String,String>>();
        for(XC_BillingProfileLineItem__c trace : bpliList){
            if(!string.isEmpty(Trace.XC_ZuoralntegrationTechnicaParameter__c))
            resultMap.put(trace.id,(Map<String,String>)JSON.deserialize(Trace.XC_ZuoralntegrationTechnicaParameter__c, Map<String,String>.class));
        }
        return resultMap;

    }

    /**
    @author Neeraj Saini - neeraj.saini@accenture.com
    @date 27/06/2022
    @description To retry Call zuora from record page
    */
    @AuraEnabled    
    public static void callZuoraFromRetrieveButton(String bpliIds){
        
        System.Debug(bpliIds);
        List<id> bpliIdList = bpliIds.split(',');
        System.Debug(bpliIdList);
        callZuoraFromRetrieveButton(bpliIdList);
    }

    
}