/**
 * The Class XC_LCC270_CreateReturnMaterial.
 *
 * @author      	  : Eleni Tsiolaki - etsiolaki@deloitte.gr && Dimitris Karnavas - dkarnavas@deloitte.gr
 * @date Creation 	  : 18/02/2022
 * @date Modification : 
 * @description 	  : UTIL Class for the FormCase object
 */
public without sharing class XC_UTIL_FormCase {


    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.gr && Dimitris Karnavas - dkarnavas@deloitte.gr
     * @description retrieve the info of WorkOrderLineItem
     * @param List<XC_UTIL_Sobject.WrapperResult> the productsConsumedResult
     * @param WorkOrderLineItem the woli 
     * @return the FormCases to be inserted
     */
    public static List<XC_FormCase__c> createFormCasesFromProductsConsumed(List<XC_UTIL_Sobject.WrapperResult> insertProducts, WorkOrderLineItem woli){
        List<XC_FormCase__c> formCasesToInsert = new List<XC_FormCase__c>();
        List<String> productIds = new List<String>();
        for(XC_UTIL_Sobject.WrapperResult p : insertProducts) {
            productIds.add(p.recordId);
        } 

        Map<String,XC_ProductConsumed__c> productsMap = new Map<String,XC_ProductConsumed__c>([SELECT Id, XC_QuantityConsumed__c FROM XC_ProductConsumed__c WHERE Id IN :productIds]);
        System.debug('products created: ' +  productsMap);
        for(String p: productsMap.keySet()){
            Integer quantity = Integer.valueOf(productsMap.get(p).XC_QuantityConsumed__c);
            System.debug('quantity ' + quantity);
            
            for(Integer i=0; i<quantity; i++){
                XC_FormCase__c formCase = new XC_FormCase__c();
                formCase.XC_Return_Material__c = woli.Id;
                formCase.XC_Product_Consumed__c = p; 
                formCase.XC_Country__c = woli.Country;

                if(woli.XC_Form_Type__c == 'RMA')
                    formCase.RecordTypeID = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId();
                else
                    formCase.RecordTypeID = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('NC').getRecordTypeId();

                formCasesToInsert.add(formCase);
            }
        }
        System.debug('form cases to insert: ' +  formCasesToInsert);
        return formCasesToInsert;

    }
}