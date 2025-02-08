/**
 * The Class XC_LCC242_ButtonCreationRepairWO_D.
 *
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 08/03/2021
 * @date Modification dd/mm/yyyy
 * @description DAO Util for the class XC_LCC242_ButtonCreationRepairWO
 */
public class XC_LCC242_ButtonCreationRepairWO_D {

    /**
     * @description retrieveInformationsFromCase
     * @param casesId cases Id Set
     * @return Query result map
     */
    public static Map<Id,Case> retrieveInformationsFromCase(Set<Id> casesId){
        Map<Id,Case> cases = new Map<Id,Case>([
            SELECT Id, Reason, SubCause__c, XC_Subtype__c, Status, XC_LegalEntity__c, XC_Segment__c, XC_Address__c, XC_AssetAttached__c, AssetId, Asset.XC_Product_Type__c, Asset.Status, Asset.XC_Address__c, (SELECT id FROM WorkOrders WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_Repair )
              FROM Case
             WHERE Id IN: casesId

        ]);
        return cases;
    }

    /**
     * @description retrieveRelatedCaseAssets
     * @param caseId the Case Id
     * @return result list of obj
     **/
    public static List<XC_CaseAsset__c> retrieveRelatedCaseAssets(Id caseId){
        Map<Id, XC_CaseAsset__c> joCaseAssetData = new Map<Id,XC_CaseAsset__c>(
            [SELECT Id, XC_Asset__c FROM XC_CaseAsset__c WHERE XC_Case__c =: caseId ]
        );
        return joCaseAssetData.values();
    }
}