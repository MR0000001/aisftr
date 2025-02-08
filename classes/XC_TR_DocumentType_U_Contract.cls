/**
     * @author Dario Tramontin dtramontin@deloitte.it  
    * @date Creation 23/10/2020
    * @date Modification 
    * @description XC_TR_DocumentType_U_Contract – Manage Contract Document Type for XC_TR_DocumentType Trigger
    */  

public without sharing class XC_TR_DocumentType_U_Contract { 

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentType_U_Contract');

    public static List<String> listOfDocCategory = new List<String>{Label.XC_CL_Document_ContractSigned, Label.XC_CL_LoanAgreementValue};

    /*public static void updateSignatureDateOnOrderOnUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        List<XC_DocumentType__c> listDocumentTypeChanged = XC_UTIL_SObject.getListChanged(new List<String>{'numberOfFiles__c','XC_DoxeeUrl__c'}, mapOld, mapNew);
        if(!listDocumentTypeChanged.isEmpty()) {
            updateSignatureDateOnOrder(listDocumentTypeChanged);
        }
    }*/
    /**
    * @description updateSignatureDateOnOrder
    * @param listNew - List<XC_DocumentType__c>
    **/
    public static void updateSignatureDateOnOrder(List<XC_DocumentType__c> listNew) {
        
        Map<String, String> mapIdConfCategory = new Map<String, String>();
        for( XC_DocumentType__c doc : listNew){
            if(listOfDocCategory.contains(doc.Category__c) && doc.XC_Configuration__c != null){
                mapIdConfCategory.put(doc.XC_Configuration__c, doc.Category__c);
            }
        }
        if(!mapIdConfCategory.isEmpty()){
            updateSignatureDateonOrder(mapIdConfCategory);
        }
       
    }
    
    private static void updateSignatureDateonOrder(Map<String, String> mapIdConfCategory) {
        List<NE__Order__c> confList = new List<NE__Order__c>(); 
        Map<Id,NE__Order__c> ordertoUpdate = new Map<Id,NE__Order__c>([SELECT XC_SignatureDate__c, XC_FinancialSignatureDate__c  FROM NE__Order__c where Id IN : mapIdConfCategory.keySet()]);
        for(NE__Order__c order : ordertoUpdate.values()) {
            String categoryDoc = mapIdConfCategory.get(order.Id);
            if(categoryDoc.equals(Label.XC_CL_Document_ContractSigned)){
                if(order.XC_SignatureDate__c==null) {
                    order.XC_SignatureDate__c= Date.today();
                    confList.add(order);
                }
            }else if(categoryDoc.equals(Label.XC_CL_LoanAgreementValue)){
                if(order.XC_FinancialSignatureDate__c==null) {
                    order.XC_FinancialSignatureDate__c= Date.today();
                    confList.add(order);
                }
            }

        }
        XC_UTIL_Sobject.updateListRecords(confList);   
    }
}