/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 13/07/2020
 * @date Modification dd/mm/yyyy
 * @desc
 */
public class XC_LCC198_ReLaunchProvisioningStep {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC198_ReLaunchProvisioningStep');
    
    /**
     * @description The Class resultWrapper.
     */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String  message; 
    }
    
    /**
     * @description Confirm executed payment.
     * @param recordId the record id
     * @return the result wrapper
     */
    @AuraEnabled
    public static resultWrapper relaunchProvisioningStep (String recordId){
        XC_UTIL_Sobject.WrapperResult wrapper = new XC_UTIL_Sobject.WrapperResult();
        ResultWrapper resultWr = new ResultWrapper();
        List<XC_Provisioning_Step__c> stepList = XC_UTIL_Sobject.selectAllFields(recordId); 
        Id userId = UserInfo.getUserId();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ LCC198 userId--> ' + userId);
        if(checkPermissionSet(userId) && !Test.isRunningTest()){
            resultWr.message = Label.XC_CL_ErrorRelaunchingStep;
            resultWr.success = false;
            return resultWr;      
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ LCC198 status--> ' + stepList[0].XC_Status__c);

        if(stepList[0].XC_Status__c != Label.XC_CL_Provisioning_Step_InProgress){
            resultWr.success = false;
            resultWr.message = Label.XC_CL_ReLaunchProvisioning_WrongStatus;
            return resultWr;
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ LCC198 stepList--> ' + stepList);
        try{
            XC_UTIL_ProvisioningStep.executeSteps(stepList);
        } catch(Exception e){
            wrapper = XC_UTIL_DML_U.populateWrapperResultFail(e);
            resultWr.message = wrapper.errorMessage;
            resultWr.success = false;
            return resultWr;            
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ resultWr--> ' + resultWr);
        resultWr.success = true;
        resultWr.message = Label.XC_CL_ReLaunchProvisioning_Relauched;
        return resultWr;
    }

    /**
     * @description Confirm that the user has the permission to relaunch the step
     * @param userId the user id of the user 
     * @return Boolean
     */
    private static Boolean checkPermissionSet(Id userId) {
        List<PermissionSetAssignment> permissionSetForUserList = new list<PermissionSetAssignment>([SELECT Id, PermissionSetId, PermissionSet.Name
                                                        FROM PermissionSetAssignment
                                                        WHERE Assignee.Id =: userId
                                                        AND PermissionSet.Name = 'XC_GLO_ProvisioningAdmin']); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ LCC198 permissionSetForUserList--> ' + permissionSetForUserList);
        return permissionSetForUserList.isEmpty();
    }
}