/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Roberta Cossiga - rcossiga@deloitte.com
* @date Creation 13/09/2019
* @description XC_LCC114_MassWorktypeZipcode – Custom Controller for XC_LCP114_MassiveAssignmentWorktypeZipCode 
*/
 
public without sharing class XC_LCC114_MassWorktypeZipcode {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC114_MassWorktypeZipcode');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 13/09/2019
     * @description Method to retrieve data for selected Partner
     * @param idAssignedPartner - Id Assigned Resource
     * @return resultWrapper - ResultByPartnerWrapper
    */
    @AuraEnabled
    public static XC_LCC114_MassAssWorktypeZipCode_W.ResultByPartnerWrapper getResultWrapperByPartner(String idAssignedPartner) {
        XC_LCC114_MassAssWorktypeZipCode_W.ResultByPartnerWrapper resultWrapper = new XC_LCC114_MassAssWorktypeZipCode_W.ResultByPartnerWrapper();

        resultWrapper.listZipCodeWorkType = new List<XC_PartnerCoverage__c>([
            SELECT Id, XC_Account__c, XC_ZipCode__c, XC_WorkType__c, XC_ZipCodeWorkType__c, XC_WorkTypeName__c
            FROM XC_PartnerCoverage__c 
            WHERE XC_Account__c = :idAssignedPartner
        ]);
        List<Account> acc = new List<Account>([
            SELECT Country__c 
            FROM Account 
            WHERE Id = :idAssignedPartner
        ]);

        List<User> listUser = new List<User>([
            SELECT Id, Country__c, XC_LegalEntity__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);

        resultWrapper.listWorkType = new List<WorkType>([
            SELECT Id, Name
            FROM WorkType 
            WHERE XC_LegalEntity__c = :listUser[0].XC_LegalEntity__c
        ]);
		
        if(!acc.isEmpty()) {
        	resultWrapper.country = listUser[0].Country__c;
        }
        return resultWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 13/09/2019
     * @description Method to populate Tables in order to operation
     * @param listWorkType - List<WorkType>
     * @param listZipCodeWorkType - List<XC_PartnerCoverage__c>
     * @return listOutput - List<WorkType>
    */
    /*@AuraEnabled
    public static List<WorkType> populateTableByAddOperation(List<WorkType> listWorkType, List<XC_PartnerCoverage__c> listZipCodeWorkType) {
        List<WorkType> listOutput = new List<WorkType>();
        List<String> listWtIds = XC_UTIL_Sobject.getListFieldValues(listZipCodeWorkType, 'XC_WorkType__c');
        for(WorkType wt : listWorkType) {
            if(!listWtIds.contains(wt.Id) && !listOutput.contains(wt)) {
                listOutput.add(wt);
            }
        }
        return listOutput;
    }*/ 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 13/09/2019
     * @description Add work type to selected Postal Code 
     * @param idOriginPartner - String
     * @param listSelectedWorkType - List<WorkType>
     * @param listSelectedZipCode - List<String> 
     * @param listExistingZipCodeWorkType - List<XC_PartnerCoverage__c>
     * @return XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper
    */ 
    @AuraEnabled 
    public static XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper addOperation(String idOriginPartner, List<WorkType> listSelectedWorkType, List<String> listSelectedZipCode, List<XC_PartnerCoverage__c> listExistingZipCodeWorkType) {
        XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper outputWrapper = new XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper();

        List<XC_PartnerCoverage__c> listPartnerCoverageWrapper = new List<XC_PartnerCoverage__c>();

        try{
            List<String> listExistingZipCodeWorkTypeKeys = new List<String>();
            for(XC_PartnerCoverage__c existingPc : listExistingZipCodeWorkType){
                listExistingZipCodeWorkTypeKeys.add(existingPc.XC_ExternalIdForDuplication__c);
            }

            for(WorkType wt : listSelectedWorkType) {
                for(String zipCode : listSelectedZipCode) {
                    Boolean found = false;
                    String key = idOriginPartner+'_'+zipCode+'_'+wt.Id;
                    /*if(!listExistingZipCodeWorkTypeKeys.isEmpty() && listExistingZipCodeWorkTypeKeys.contains(key)){
                        found = true;
                        break;
                    }*/
                    /*for(XC_PartnerCoverage__c existingPc : listExistingZipCodeWorkType) {
                        if(existingPc.XC_ExternalIdForDuplication__c == key) {
                            found = true;
                            break;
                        }
                    }*/
                    //if(!found) {
                    if(listExistingZipCodeWorkTypeKeys.isEmpty() || !listExistingZipCodeWorkTypeKeys.contains(key)){
                        XC_PartnerCoverage__c newPc = new XC_PartnerCoverage__c();
                        newPc.XC_Account__c = idOriginPartner;
                        newPc.XC_WorkType__c = wt.Id;
                        newPc.XC_ZipCode__c = zipCode;
                        listPartnerCoverageWrapper.add(newPc);
                    }
                }
            }
        } catch(Exception e){
            outputWrapper.resultMessage = e.getMessage();
            return outputWrapper;
        }

        List<XC_PartnerCoverage__c> listFilteredToInsert = distinctCoveragesToInsert(listPartnerCoverageWrapper);
        List<XC_UTIL_Sobject.WrapperResult> listRes = XC_UTIL_Sobject.insertListRecords(listFilteredToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(listRes)) {
            outputWrapper.resultMessage = listRes[0].errorMessage;
            return outputWrapper;
        }
        outputWrapper.success = true;
        return outputWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 13/09/2019
     * @description Remove work type to selected Postal Code 
     * @param listPartnerCoverageIds - List<String>
     * @return XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper
    */ 
    @AuraEnabled 
    public static XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper removeOperation(List<String> listPartnerCoverageIds) {
        List<XC_PartnerCoverage__c> listPartnerCoverage = new List<XC_PartnerCoverage__c>();
        for(String idPc : listPartnerCoverageIds) {
            XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c();
            pc.Id = idPc;
            listPartnerCoverage.add(pc);
        }
        XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper outputWrapper = new XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper();
        List<XC_UTIL_Sobject.WrapperResult> listRes = XC_UTIL_Sobject.deleteListRecords(listPartnerCoverage);
        if(!XC_UTIL_Sobject.checkDMLResults(listRes)) {
            outputWrapper.resultMessage = listRes[0].errorMessage;
            return outputWrapper;
        }
        outputWrapper.success = true;
        return outputWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 13/09/2019
     * @description Transfer work type 
     * @param listPartnerCoverage - List<XC_PartnerCoverage__c>
     * @param idDestinationPartner - String
     * @return XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper
    */ 
    @AuraEnabled 
    public static XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper transferOperation(List<XC_PartnerCoverage__c> listPartnerCoverage, String idDestinationPartner) {        
        SavePoint savePoint = Database.setSavepoint();
        XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper outputWrapper = new XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper();

        // Insert records for Destination Partner     
        List<XC_PartnerCoverage__c> listPartnerCoverageToInsert = new List<XC_PartnerCoverage__c>();
        for(XC_PartnerCoverage__c pc : listPartnerCoverage) {
            XC_PartnerCoverage__c pcToInsert = new XC_PartnerCoverage__c();
            pcToInsert.XC_Account__c = idDestinationPartner;
            pcToInsert.XC_ZipCode__c = pc.XC_ZipCode__c;
            pcToInsert.XC_Worktype__c = pc.XC_Worktype__c;
            listPartnerCoverageToInsert.add(pcToInsert);
        }
        System.debug('@@@ listPartnerCoverageToInsert -> ' + listPartnerCoverageToInsert);

        List<XC_PartnerCoverage__c> listFilteredToInsert = distinctCoveragesToInsert(listPartnerCoverageToInsert);
        List<XC_UTIL_Sobject.WrapperResult> listResInsert = XC_UTIL_Sobject.insertListRecords(listFilteredToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(listResInsert)) {
            outputWrapper.resultMessage = listResInsert[0].errorMessage;
            Database.rollback(savePoint);
            return outputWrapper;
        }      

        // Delete records of Origin Partner
        List<XC_UTIL_Sobject.WrapperResult> listResDelete = XC_UTIL_Sobject.deleteListRecords(listPartnerCoverage);
        if(!XC_UTIL_Sobject.checkDMLResults(listResDelete)) {
            outputWrapper.resultMessage = listResDelete[0].errorMessage;
            Database.rollback(savePoint);
            return outputWrapper;
        }

        outputWrapper.success = true;
        return outputWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 10/06/2020
     * @description Method to delete Coverage already exist in the system
     * @param listPartnerCoverageWrapper - List<XC_PartnerCoverage__c>
     * @return List<XC_PartnerCoverage__c>
    */ 
    private static List<XC_PartnerCoverage__c> distinctCoveragesToInsert(List<XC_PartnerCoverage__c> listPartnerCoverageWrapper) {
        List<String> listKeyToCheck = new List<String>();
        for(XC_PartnerCoverage__c pc : listPartnerCoverageWrapper) {
            listKeyToCheck.add(pc.XC_Account__c+'_'+pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c);
        }
        List<XC_PartnerCoverage__c> listExistingPC = new List<XC_PartnerCoverage__c>([
            SELECT Id, XC_WorkType__c, XC_ZipCode__c, XC_Account__c
            FROM XC_PartnerCoverage__c
            WHERE XC_ExternalIdForDuplication__c IN :listKeyToCheck
        ]);

        List<XC_PartnerCoverage__c> outputList = new List<XC_PartnerCoverage__c>();
        Set<String> setExternalIdForDuplication = new Set<String>();
        for(XC_PartnerCoverage__c pcToInsert : listPartnerCoverageWrapper) {
            Boolean found = false;
            for(XC_PartnerCoverage__c existingPc : listExistingPC) {
                if(pcToInsert.XC_WorkType__c == existingPc.XC_WorkType__c && pcToInsert.XC_ZipCode__c == existingPc.XC_ZipCode__c && pcToInsert.XC_Account__c == existingPc.XC_Account__c) {
                    found = true;
                    break;
                }
            }
            if(!found) {
                String newExternalId = pcToInsert.XC_Account__c+'_'+pcToInsert.XC_ZipCode__c+'_'+pcToInsert.XC_WorkType__c;
                if(!setExternalIdForDuplication.contains(newExternalId)) {
                    setExternalIdForDuplication.add(newExternalId);
                    outputList.add(pcToInsert);
                }
            }
        }
        return outputList;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 14/07/2020
     * @description Method to manage Coverage to show for Remove/Transfer operation 
     * @param listWorkTypePartner - List<WorkType>
     * @param listPartnerCoverage - List<XC_PartnerCoverage__c>
     * @return List<Map<String, String>>
    */ 
    @AuraEnabled 
    public static List<Map<String, String>> populateWorkTypesForRemoveTransfer(List<WorkType> listWorkTypePartner, List<XC_PartnerCoverage__c> listPartnerCoverage) {
        List<Map<String, String>> listWorkTypeOutput = new List<Map<String, String>>();
        List<String> listIdsInserted = new List<String>();
        for(XC_PartnerCoverage__c pc : listPartnerCoverage) {
			for(WorkType wt : listWorkTypePartner) {
				if(wt.Name == pc.XC_WorkTypeName__c && !listIdsInserted.contains(wt.Id)) {
                    Map<String, String> tempObject = new Map<String, String>{
						'Id' => wt.Id,
						'Name' => wt.Name
					};
					listWorkTypeOutput.add(tempObject);
					listIdsInserted.add(wt.Id);
					break;
				}
			}
		}
        return listWorkTypeOutput;
    }

}