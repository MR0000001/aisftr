/**
 * The Class XC_LCC270_CreateReturnMaterial_D.
 *
 * @author      	  : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 	  : 18/02/2022
 * @date Modification : 
 * @description 	  : DAO for XC_LCC270_CreateReturnMaterial 
 */
public class XC_LCC270_CreateReturnMaterial_D {

    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
     * @description retrieve the info of WorkOrderLineItem
     * @param woliId the woli ID
     * @return the wolis
     */
    public static List<WorkOrderLineItem> retrieveWOLIinfo(String recordId) {

        String objName = 'WorkOrderLineItem';
        String fields = XC_UTIL_Sobject.selectAllFieldsGetSelect(objName);
        String query = String.escapeSingleQuotes(fields); 
        query += ',RecordType.DeveloperName, WorkOrder.XC_LegalEntity__c';
        query += String.escapeSingleQuotes(' FROM ' + objName +' WHERE Id =:recordId');
        List<WorkOrderLineItem> wolis = Database.query(query); 
        return wolis;
    }


    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
     * @description retrieve the productsConsumed
     * @param woliId the woli ID
     * @return the products
     */
    public static List<XC_ProductConsumed__c> retrieveProducts(String recordId) {

        String objName = 'XC_ProductConsumed__c';
        String fields = XC_UTIL_Sobject.selectAllFieldsGetSelect(objName);
        String query = String.escapeSingleQuotes(fields); 
        query += String.escapeSingleQuotes(' FROM ' + objName +' WHERE XC_WorkOrderLineItem__c =:recordId');
        List<XC_ProductConsumed__c> products = Database.query(query); 
        return products;
    }

}