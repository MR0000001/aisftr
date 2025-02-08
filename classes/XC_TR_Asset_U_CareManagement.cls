/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date 27/10/2020
* @description XC_TR_Asset_U_CareManagement - Class to manage Case creation and Care management for Asset obj
**/
public without sharing class XC_TR_Asset_U_CareManagement {

    /**
     * @description Manage creations of Cases when Care management is needed
     * @param mapOld - Map<Id, Asset>
     * @param mapNew - Map<Id, Asset> 
    */
    public static void creationsForCareManagement(Map<Id, Asset> mapOld, Map<Id, Asset> mapNew) {  
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_ElectricalConnectionDate__c'}, mapOld, mapNew);
        List<Asset> assetsForPhotoRefund = new List<Asset>();
        for(Asset asset : listChanged) { 
            if((mapOld.get(asset.Id)).XC_ElectricalConnectionDate__c == null) {
                assetsForPhotoRefund.add(asset);
            }
        }
        if(assetsForPhotoRefund.isEmpty()){
            return;
        }
        
        //retrieve all caseTypeSettings needed
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsData = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PhotovoltaicRefund});
        //getting assignment rule info
        AssignmentRule ar = new AssignmentRule();
        ar = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.AssignmentRuleHeader.AssignmentRuleId = ar.Id;
        
        if(!assetsForPhotoRefund.isEmpty()){
            caseCreationForPhotovoltaicRefund(assetsForPhotoRefund, caseSettingsData.get(Label.XC_CL_PhotovoltaicRefund), opts);
        }
    }

    /**
     * @description case Creation For Photovoltaic Refund
     * @param assetsForPhotoRefund to create cases related
     * @param caseType type of Case to create from XC_CM_Case_Type_Setting__mdt
     * @param opts to run Case Assignment Rules
     */
    public static void caseCreationForPhotovoltaicRefund(List<Asset> assetsForPhotoRefund, XC_CM_Case_Type_Setting__mdt caseType,  Database.DMLOptions opts){
        List<Case> newCases = new List<Case>();
        Case caso;
        for(Asset asset : assetsForPhotoRefund){
            caso = XC_UTIL_Case.initCaseFromCaseSettings(caseType);
            caso.AssetId = asset.Id;
            caso.AccountId = asset.AccountId;
            caso.ContactId = asset.ContactId;
            caso.XC_LegalEntity__c = asset.XC_LegalEntity__c;
            caso.XC_Segment__c = asset.XC_Segment__c;
            caso.setOptions(opts);
            newCases.add(caso);
        }
        List<XC_UTIL_Sobject.WrapperResult> insertDMLres = XC_UTIL_DML.insertRecords(newCases);
    }

}