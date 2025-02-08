/**
*@author: francesco imperioli - fimperioli@deloitte.it
*@description : apex controller for LCC155 lightning utility bar component
*@history: 21-11-2019 creation
*/
public without sharing class XC_LCC155_OmniChannelAssignWork {


    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description: update parent case status if owner is different from just accepted child case
    *@param: String parentCaseId
    *@return: the boolean
    */
    @AuraEnabled
    public static Boolean updateParentCaseStatus(String parentCaseId){

        if(String.isBlank(parentCaseId)){
            return true;
        }

        String currentUserId = UserInfo.getUserId();
        Case parentCase = [SELECT Id,Status,OwnerId FROM Case WHERE Id = : parentCaseId LIMIT 1];

        if(currentUserId!=parentCase.OwnerId){
            parentCase.Status=Label.XC_CL_Case_Pending;
            XC_UTIL_Sobject.WrapperResult updateResult= XC_UTIL_Sobject.updateRecord(parentCase);
            return updateResult.success;
        }
        return true;
    }



}