/**
 * The Class XC_LCC270_CreateReturnMaterial.
 *
 * @author      	  : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 	  : 18/02/2022
 * @date Modification : 
 * @description 	  : Controller of the XC_LCP270_CreateReturnMaterial component
 */

 public without sharing  class XC_LCC270_CreateReturnMaterial {


    /**
    * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createReturnMaterial(String recordId) {
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.success = true;

        List<WorkOrderLineItem> woGoodIssues = XC_LCC270_CreateReturnMaterial_D.retrieveWOLIinfo(recordId);
        WorkOrderLineItem woReturnMaterial = new WorkOrderLineItem();
        woReturnMaterial.Country = woGoodIssues[0].Country;
        woReturnMaterial.XC_AccountId__c = woGoodIssues[0].XC_AccountId__c;
        woReturnMaterial.WorkOrderId = woGoodIssues[0].WorkOrderId;
        woReturnMaterial.XC_Form_Type__c = woGoodIssues[0].XC_Form_Type__c;
		woReturnMaterial.XC_WOLIType__c = 'Return Material';
        
        if(woGoodIssues[0].RecordType.DeveloperName.contains('B2B')) {
            woReturnMaterial.RecordTypeID = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXMobility_ReturnMaterial').getRecordTypeId();
        } else if(woGoodIssues[0].RecordType.DeveloperName.contains('B2G')) {
            woReturnMaterial.RecordTypeID = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXMobility_ReturnMaterial').getRecordTypeId();
        }
        
        List<XC_UTIL_Sobject.WrapperResult> insertWOLI = XC_UTIL_DML.insertRecords(new List<Sobject>{woReturnMaterial});
        String woliCreatedId = insertWOLI[0].recordId;
    

        if(insertWOLI[0].success) {
            result.recordId = woliCreatedId;
            List<XC_ProductConsumed__c> products = XC_LCC270_CreateReturnMaterial_D.retrieveProducts(recordId);
           

            List<XC_ProductConsumed__c> newProducts =  new List<XC_ProductConsumed__c>();

            for(XC_ProductConsumed__c p : products) {
                XC_ProductConsumed__c newProduct = p.clone(false,false,false,false);
                newProduct.XC_WorkOrderLineItem__c = woliCreatedId;
                newProducts.add(newProduct);
            }
            List<XC_UTIL_Sobject.WrapperResult> insertProducts = XC_UTIL_DML.insertRecords(newProducts);
            XC_UTIL_Sobject.WrapperResult globalResProducts= XC_UTIL_Sobject.getGlobalDMLResults(insertProducts);
            result.success = globalResProducts.success;

            if(!result.success) {
                result.resultMessage = globalResProducts.errorMessage;
                return result;
            } else { 
                String formType = woReturnMaterial.XC_Form_Type__c;
                System.debug('form type: ' + formType);
                if(formType != null) {
                    List<WorkOrderLineItem> woliCreated = XC_LCC270_CreateReturnMaterial_D.retrieveWOLIinfo(woliCreatedId);
                    List<XC_FormCase__c> formCases = XC_UTIL_FormCase.createFormCasesFromProductsConsumed(insertProducts, woliCreated[0]);

                    XC_TR_FormCase_Handler.bypassBeforeInsert = false;
                    List<XC_UTIL_Sobject.WrapperResult> insertFormCases = XC_UTIL_DML.insertRecords(formCases);
                    XC_UTIL_Sobject.WrapperResult globalResForm= XC_UTIL_Sobject.getGlobalDMLResults(insertFormCases);
                    result.success = globalResForm.success;

                    if(!result.success) {
                        result.resultMessage = globalResForm.errorMessage;
                        return result;
                    }
                }
            }
            
        } else {
            result.success = false;
            result.resultMessage = insertWOLI[0].errorMessage;
        }
        return result;
    }
}