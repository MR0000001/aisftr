/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 28/08/2019
*@date Modification dd/mm/yyyy
*@description controller for custom lightning component select Payment method
*/

public without sharing class XC_LCC103_ConfItemEditForm {


    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description checkPrepayment
    *@param confItemId String
    *@return  XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkPrepayment(String confItemId) {
        NE__OrderItem__c oi = null;
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            oi = [
                    SELECT id,NE__Account__c, NE__Account__r.XC_RecordTypeDeveloperName__c, NE__OrderId__r.XC_Segment__c,
                            XC_NumPrepayment__c,NE__OrderId__r.XC_LegalEntity__c, NE__Account__r.XC_SohoType__c, XC_BillingModel__c
                    FROM NE__OrderItem__c
                    WHERE Id = :confItemId
            ];
        }

        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        List<String> paymentMethodOld = XC_UTIL_Sobject.getPicklistValues('NE__Billing_Profile__c', 'NE__Payment__c');
        Map<String,List<String>> dependendentValues1 = getPaymentMethodValues(oi.NE__OrderId__r.XC_Segment__c);
        paymentMethodOld.clear();

        paymentMethodOld.addAll(dependendentValues1.get(oi.XC_BillingModel__c));
        List<String> paymentMethod = filterMopWithLegalEntity(XC_UTIL_User.getLegalEntityFromUser(), oi.NE__OrderId__r.XC_Segment__c, paymentMethodOld);
    
        if (oi.XC_NumPrepayment__c == 0 ) {
            wr.success = false;
        } else {
            wr.success = true;
            paymentMethod.clear();
            Map<String,List<String>> dependendentValues = getPaymentMethodValues(oi.NE__OrderId__r.XC_Segment__c);
            List<XC_DocumentByPaymentMethod__mdt> paymentMetadataMethods = new List<XC_DocumentByPaymentMethod__mdt>();
            if (Schema.sObjectType.XC_DocumentByPaymentMethod__mdt.isAccessible()) {
                paymentMetadataMethods = [SELECT id, XC_PaymenMethod__c, XC_PrePayment__c,XC_Legal_Entity__c FROM XC_DocumentByPaymentMethod__mdt WHERE XC_PrePayment__c = 'Y' AND XC_Legal_Entity__c = :oi.NE__OrderId__r.XC_LegalEntity__c];
            }
            for (XC_DocumentByPaymentMethod__mdt dpm : paymentMetadataMethods) {
                if(dependendentValues.get(oi.XC_BillingModel__c).contains(dpm.XC_PaymenMethod__c)){
                    paymentMethod.add(dpm.XC_PaymenMethod__c);
                }
            }

        }
        
        checkSohoWithDifferentSohoType(oi, paymentMethod, wr);
        wr.fieldName = JSON.serialize(paymentMethod);

        return wr;
    }


    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description checkSohoWithDifferentSohoType
    *@param orderItem NE__OrderItem__c
    *@param paymentMethod List<String>
    *@param wr XC_UTIL_ResultWrapper
    */
    public static void checkSohoWithDifferentSohoType(NE__OrderItem__c orderItem, List<String> paymentMethod, XC_UTIL_ResultWrapper wr) {
        if (orderItem.NE__Account__r.XC_RecordTypeDeveloperName__c == 'XC_GLO_Account_Soho' && (orderItem.NE__Account__r.XC_SohoType__c != 'Soho' || orderItem.NE__Account__r.XC_SohoType__c != null)) {
            wr.success = true;
            System.debug('payment method wrfalse'+paymentMethod);
            Integer j = 0;

            /*while (j < paymentMethod.size()) {
                if (paymentMethod.get(j) == 'Commodity Bill') {
                    paymentMethod.remove(j);
                } else {
                    j++;
                }
            }*/
        }
    }


    /**
    * @author dpalamides
    *@description checkOrderStatus
    *@param confItemId the record id
    *@return Boolean
    */
    @AuraEnabled
    public static Boolean checkOrderStatus(String confItemId) {
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            NE__OrderItem__c oi = [
                    SELECT id, NE__OrderId__r.XC_Status__c
                    FROM NE__OrderItem__c
                    WHERE Id = :confItemId
            ];

            if (oi.NE__OrderId__r.XC_Status__c == 'In Progress' || oi.NE__OrderId__r.XC_Status__c == 'To be validated' || oi.NE__OrderId__r.XC_Status__c == 'Draft' || oi.NE__OrderId__r.XC_Status__c == 'Notified to client') {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    /**
    * @author dpalamides
    *@description checkOrderStatus
    *@param confItemId the record id
    *@return Boolean
    */
    @AuraEnabled
    public static Boolean checkImpliedInterest(String confItemId) {
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            NE__OrderItem__c oi = [
                    SELECT id, NE__OrderId__r.XC_Status__c, NE__OrderId__r.NE__OptyId__r.XC_InvoiceType__c
                    FROM NE__OrderItem__c
                    WHERE Id = :confItemId
            ];

            if (oi.NE__OrderId__r.NE__OptyId__r.XC_InvoiceType__c == 'Invoice Accrued interest - Implied interest share') {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }


    /**
    *@description return the payment method values from billing model field
    *@return Map<String,List<String>> 
    **/
    /*@AuraEnabled
    public static Map<String,List<String>> getPaymentMethodValues(){
        System.debug('ORDER PAYMENT 103'+XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c').pickListMap);
        Map<String,List<String>> dependPaymentByBillingProfile = XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c').pickListMap;
        Map<String,List<String>> dependPaymentByLegalEntity = filterMopWithLegalEntityWrFalse(XC_UTIL_User.getLegalEntityFromUser(),dependPaymentByBillingProfile);
        System.debug('ORDER PAYMENT 103'+dependPaymentByLegalEntity);
        return dependPaymentByLegalEntity;
        //return XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c').pickListMap;
    }


    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    **/
    /*private static Map<String,List<String>> filterMopWithLegalEntityWrFalse(String legalEntity,Map<String,List<String>> mp){
        Map<String,List<String>> paymeeListFiltered = new Map<String,List<String>>();
        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE DeveloperName = :legalEntity LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mp;
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mp;
        }

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();

        for(String s : mp.keySet()){
            for(String ss: mp.get(s)){
                if(!excludedMopsSet.contains(ss)){
                    paymeeListFiltered.put(s,mp.get(s));
                }
            }
        }

        return !paymeeListFiltered.isEmpty() ? paymeeListFiltered : mp;
    }


    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    **/
    /*private static List<String> filterMopWithLegalEntity(String legalEntity,List<String> mopsToString){


        if(String.isBlank(legalEntity)){
            return mopsToString;
        }

        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE DeveloperName = :legalEntity LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mopsToString;
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mopsToString;
        }

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();

        for(String inputMop : mopsToString){
            //check if the mop is in the excluded mop set
            if(!excludedMopsSet.contains(inputMop)){
                newMopList.add(inputMop);
            }
        }

        return !newMopList.isEmpty() ? newMopList : mopsToString;
    }


    /**
    *@description return the payment method values from billing model field
    *@return Map<String,List<String>> 
    *@modifieddate 2020-04-30 by Nicola Mariniello - nmariniello@deloitte.it
    *@param stream - String
    *@return Map<String,List<String>>
    **/
    @AuraEnabled
    public static Map<String,List<String>> getPaymentMethodValues(String stream){
        System.debug('ORDER PAYMENT 103'+XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c').pickListMap);
        Map<String,List<String>> dependPaymentByBillingProfile = XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c').pickListMap;
        Map<String,List<String>> dependPaymentByLegalEntity = filterMopWithLegalEntityWrFalse(XC_UTIL_User.getLegalEntityFromUser(), stream, dependPaymentByBillingProfile);
        System.debug('ORDER PAYMENT 103'+dependPaymentByLegalEntity);
        return dependPaymentByLegalEntity;
        //return XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c').pickListMap;
    }


    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    *@modifieddate 2020-04-30 by Nicola Mariniello - nmariniello@deloitte.it
    *@param legalEntity - String
    *@param stream - String
    *@param mp - Map<String,List<String>>
    *@return Map<String,List<String>>
    **/
    private static Map<String,List<String>> filterMopWithLegalEntityWrFalse(String legalEntity, String stream, Map<String,List<String>> mp){
        Map<String,List<String>> paymeeListFiltered = new Map<String,List<String>>();
        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE XC_LegalEntity__c = :legalEntity AND XC_Stream__c =: stream AND XC_BillingModel__c = null LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mp;
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mp;
        }

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();

        for(String s : mp.keySet()){
            for(String ss: mp.get(s)){
                if(!excludedMopsSet.contains(ss)){
                    paymeeListFiltered.put(s,mp.get(s));
                }
            }
        }

        return !paymeeListFiltered.isEmpty() ? paymeeListFiltered : mp;
    }


    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    *@modifieddate 2020-04-30 by Nicola Mariniello - nmariniello@deloitte.it
    *@param legalEntity - String
    *@param stream - String
    *@param mopsToString - List<String>
    *@return List<String>
    **/
    private static List<String> filterMopWithLegalEntity(String legalEntity, String stream, List<String> mopsToString){

        if(String.isBlank(legalEntity) || String.isBlank(stream)){
            return mopsToString;
        }

        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE XC_LegalEntity__c = :legalEntity AND XC_Stream__c = :stream LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mopsToString;
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mopsToString;
        }

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();

        for(String inputMop : mopsToString){
            //check if the mop is in the excluded mop set
            if(!excludedMopsSet.contains(inputMop)){
                newMopList.add(inputMop);
            }
        }

        return !newMopList.isEmpty() ? newMopList : mopsToString;
    }

    //Start EA TPB 13/10/2021
     /**
    * @author ElioAdami
    *@description checkOrderStatus
    *@param confItemId the record id
    *@return String
    */
    @AuraEnabled
    public static String checkPartnerCode(String confItemId) {
        String neValue ='';
        system.debug('EA checkPartnerCode start neValue='+neValue);
       // if (Schema.sObjectType.NE__Order_Item_Attribute__c.isAccessible()) {
            List<NE__Order_Item_Attribute__c> oiaList = new List<NE__Order_Item_Attribute__c>();
           
            oiaList = [
                    SELECT Id,name,NE__Value__c
                    FROM NE__Order_Item_Attribute__c
                    WHERE NE__Order_Item__r.id= :confItemId and Name = 'Partner Code'
            ];

            if(!oiaList.isEmpty()){
                neValue= oiaList.get(0).NE__Value__c;
                system.debug('EA checkPartnerCode !oiaList neValue='+neValue);
                return neValue;
            }

            else{
                system.debug('EA checkPartnerCode oiaList neValue='+neValue);
                return neValue;
            }
        /*    
        } else {
            system.debug('EA checkPartnerCode end neValue='+neValue);
            return neValue;
        }
        */
    }
    //End EA TPB 13/10/2021

    /**
    * @description get orderitem attributes installment plan details
    * @author  Gaurav Tejpalgaurav.tejpal@accenture.com
    * @param confItemId
    * @return string
    **/
    @AuraEnabled
    public static  string  getFieldOfAttributes(String confItemId){
        Map<string,string> fieldAttributes=new Map<string,string>();
        List<NE__Order_Item_Attribute__c> ordItemAttributes = [select id,name,ne__value__c from NE__Order_Item_Attribute__c where ((name = 'Installment Plan Type' or name = 'Tipologia di Interesse') or name = 'Number of installments' or (name = 'Installment Frequency' or name = 'Frequenza delle Rate')) and NE__Order_Item__c = : confitemId]; //Gaurav Tejpalgaurav.tejpal@accenture.com NR2187 - Added more conditions with OR - 06/01
        if(!ordItemAttributes.isEmpty()){
            for(NE__Order_Item_Attribute__c ordItemAttr: ordItemAttributes)
            {
                if(ordItemAttr.Name=='Installment Plan Type' || ordItemAttr.Name=='Tipologia di Interesse')
                {
                    fieldAttributes.put('Installment_Plan_Type', ordItemAttr.ne__value__c);
                }
                else  if(ordItemAttr.Name=='Number of installments')
                {
                    fieldAttributes.put('Number_Of_Installments', ordItemAttr.ne__value__c);
                }
                else if(ordItemAttr.Name=='Installment Frequency' || ordItemAttr.Name=='Frequenza delle Rate')
                {
                    fieldAttributes.put('Installment_Frequency', ordItemAttr.ne__value__c);
                }
            }
        }
               return JSON.serialize(fieldAttributes);
    }

}