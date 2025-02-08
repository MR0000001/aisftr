/**
 * The Class XC_TR_BillingProfileLineItem_U_Address.
 *
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 29/04/2019
 * @date Modification 09/10/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description XC_TR_BillingProfileLineItem_U_Address – Update the fields Billing Address Copy and Sold Address Copy when a Billing Profile Line Item is created or updated.
 */

public without sharing class XC_TR_BillingProfileLineItem_U_Address {
    
    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfileLineItem_U_Address');
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
 	 * @date Creation 29/04/2019 
     * @description method to update XC_BillingAddressCopy__c and XC_SoldToAddressCopy__c fields.
     * @param billingProfLineItems a list of XC_BillingProfileLineItem__c objects
     */
    public static void updateAdressFields(List<XC_BillingProfileLineItem__c> billingProfLineItems){
        for(XC_BillingProfileLineItem__c billProfLineItem : billingProfLineItems){
            billProfLineItem.XC_BillingAddressCopy__c = billProfLineItem.XC_BillToAddress__c;
            billProfLineItem.XC_SoldToAddressCopy__c = billProfLineItem.XC_SoldToAddress__c;
        }
        
    }


    /**
     * ChangeBillingAddressOnZuora.
     * 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param the mapmapOld old
     * @param mapNew the map new
     * @description Call Zuora when BillingAddress is changed
     */
    public static void changeBillingAddressOnZuora(Map<Id, XC_BillingProfileLineItem__c> mapOld, Map<Id, XC_BillingProfileLineItem__c> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_BillingProfileLineItem_U_Address.changeBillingAddressOnZuora');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + mapNew.values());
        List<String> fieldList = new List<String>{'XC_BillToAddress__c', 'XC_SoldToAddress__c'};
        List<XC_BillingProfileLineItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);
        for(XC_BillingProfileLineItem__c bpli : listChanged) {
            if((String.isNotBlank(mapOld.get(bpli.Id).XC_BillToAddress__c) || String.isNotBlank(mapOld.get(bpli.Id).XC_SoldToAddress__c)) && String.isNotBlank(bpli.XC_ZuoraId__c)) {
                callZuoraAndCreateCase(JSON.serialize(bpli), mapOld.get(bpli.Id).XC_BillToAddress__c, mapOld.get(bpli.Id).XC_SoldToAddress__c);
            }
		}
    }


    /**
     * CallZuoraAndCreateCase.
     * 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param bpliString the bpli
     * @param oldBillAddressId the oldBillAddressId
     * @description Call Zuora when BillingAddress is changed
     */
    @future(callout=true)
    private static void callZuoraAndCreateCase(String bpliString, String oldBillAddressId, String oldSoldAddressID) {

        XC_BillingProfileLineItem__c bpli = (XC_BillingProfileLineItem__c) JSON.deserialize(bpliString, XC_BillingProfileLineItem__c.class);

        Map<String, String> parametersMap = new Map<String, String>{'zuoraAccountId' => bpli.XC_ZuoraId__c,
                                                                    'billToId' => bpli.XC_BillToContactId__c,
                                                                    'soldToId' => bpli.XC_SoldToContactId__c,
                                                                    'billAddrId' => bpli.XC_BillToAddress__c,
                                                                    'soldAddrId' => bpli.XC_SoldToAddress__c,
                                                                    'legalEntity' => bpli.XC_LegalEntity__c};

        ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bpli.XC_Segment__c));
        ZuoraWebService.CreateZuoraAccountResponse responseUpdateAccount = zws.updateZuoraAccount(parametersMap);

        if(oldBillAddressId != bpli.XC_BillToAddress__c){
            
            Map<Id, XC_Address__c> addressMap = new Map<Id, XC_Address__c>([SELECT Id, Name, XC_Account__c FROM XC_Address__c WHERE Id =: oldBillAddressId OR Id =: bpli.XC_BillToAddress__c]);

            Map<String, XC_CM_Case_Type_Setting__mdt> caseTypeSettings = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_ChangeBillingAddress', 'XC_DisalignmentZuoraBillAddress'});

            Map<String,String> labelParameters = new Map<String,String>();
            labelParameters.put('<1>', addressMap.get(oldBillAddressId).Name);
            labelParameters.put('<2>', addressMap.get(bpli.XC_BillToAddress__c).Name);
            labelParameters.put('<Dirección de Facturación>', Schema.XC_BillingProfileLineItem__c.fields.XC_BillToAddress__c.getDescribe().getLabel());

            Case cFather = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeSettings.get('XC_ChangeBillingAddress'));
            //cFather.Origin = 'CAN001';
            cFather.AccountId = addressMap.get(bpli.XC_BillToAddress__c).XC_Account__c;
            cFather.ContactId = bpli.XC_BillToContactId__c;
            cFather.XC_LegalEntity__c = bpli.XC_LegalEntity__c;
            cFather.XC_Resolution__c = caseTypeSettings.get('XC_ChangeBillingAddress').XC_Resolution__c;
            cFather.XC_Result__c = caseTypeSettings.get('XC_ChangeBillingAddress').XC_Result__c;
            cFather.CaseRemarks__c = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseTypeSettings.get('XC_ChangeBillingAddress'), bpli.XC_LegalEntity__c, labelParameters);
            //cFather.CaseRemarks__c =  (objectFields.contains(caseRemarks.toLowerCase())) ? ((String)caseTypeSettings.get('XC_ChangeBillingAddress').get(caseRemarks)).replace('<1>', addressMap.get(oldBillAddressId).Name).replace('<2>', addressMap.get(bpli.XC_BillToAddress__c).Name) : (caseTypeSettings.get('XC_ChangeBillingAddress').XC_CaseRemarks__c).replace('<1>', addressMap.get(oldBillAddressId).Name).replace('<2>', addressMap.get(bpli.XC_BillToAddress__c).Name).replace('<Dirección de Facturación>', Schema.XC_BillingProfileLineItem__c.fields.XC_BillToAddress__c.getDescribe().getLabel());
            XC_UTIL_Sobject.WrapperResult resultFather = XC_UTIL_Sobject.insertRecord(cFather);
            
            if(responseUpdateAccount.success == 'false' && resultFather.success) {
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true;

                Case cChild = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeSettings.get('XC_DisalignmentZuoraBillAddress'));
                //cChild.Origin = 'CAN002';
                cChild.AccountId = addressMap.get(bpli.XC_BillToAddress__c).XC_Account__c;
                cChild.ContactId = bpli.XC_BillToContactId__c;
                cChild.ParentId = cFather.Id;
                cChild.XC_LegalEntity__c = bpli.XC_LegalEntity__c;
                cChild.Comments = (responseUpdateAccount.reasons.isEmpty()) ? '' : responseUpdateAccount.reasons[0].message;
                cChild.setOptions(dmlOpts);
                XC_UTIL_Sobject.insertRecord(cChild);
            }
        }
        
    }

}