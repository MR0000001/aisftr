public without sharing class Giic_LCC023_PurchaseOrderPath {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC023_PurchaseOrderPath');
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveStatus(String recordId, String stepName){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN saveStatus' ); 
        gii__PurchaseOrder__c po = [SELECT Id, giic_status__c FROM gii__PurchaseOrder__c WHERE Id =: recordId LIMIT 1];
        System.debug('In saveStatus con '+stepName);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Boolean approver = true;
        User currentUser = [SELECT Id, XC_EnabledToSkip__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        
        if(po.giic_status__c == 'Closed' && !currentUser.XC_EnabledToSkip__c){
             rw.success = false;
             rw.resultMessage = 'This Purchase Order is Closed!';
             return rw;
        }
        if(stepName=='Approved'){
            approver = checkIfApprover(recordId,currentUser);
        }
        po.giic_status__c = stepName;
        po.gii__Status__c = stepName;
        if(approver){
            System.debug('in update PO con status '+stepName);
        	rw = XC_UTIL_Glovia.updateRecord(po);
            String resultMessage = rw.resultMessage;
            String strr = resultMessage.replace('giic_',' ');
            String finalMessage = strr.replace('__c',' ');
            rw.resultMessage = finalMessage;

        }else{
             rw.success = false;
             rw.resultMessage = 'You cannot approve this Purchase Order!';
        }
        return rw;
        
    }
    
    
    public static Boolean checkIfApprover(String recordId ,  User currentUser){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN checkIfApprover' ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN checkIfApprover' ); 
        gii__PurchaseOrder__c po = [SELECT Id, giic_LegalEntity__c FROM gii__PurchaseOrder__c WHERE Id =:recordId LIMIT 1];
        String correctQueue; 
      
        if(currentUser.XC_EnabledToSkip__c){
            return true;
        }
        List<GroupMember> myGroups = [SELECT Group.Name, Group.DeveloperName FROM GroupMember where UserOrGroupId =: UserInfo.getUserId() AND Group.Type = 'Queue'];
        if(po.giic_LegalEntity__c == 'EndesaX'){
          correctQueue = 'giic_GloviaApprovalProcessESP';
		}else if(po.giic_LegalEntity__c == 'EnelXItalia'){
          correctQueue = 'giic_GloviaApprovalProcessITA';
        }else if(po.giic_LegalEntity__c == 'EnelX'){
          correctQueue = 'giic_GloviaApprovalProcessCHI';
        }else if(po.giic_LegalEntity__c == 'Codensa'){
          correctQueue = 'giic_GloviaApprovalProcessCOL';
        }else if(po.giic_LegalEntity__c == 'EnelXMobility'){
          correctQueue = 'giic_GloviaApprovalProcessEmobility';
        }else if(po.giic_LegalEntity__c == 'EnelSole'){
          correctQueue = 'giic_GloviaApprovalProcessEnelSole';
        }
       
        for(GroupMember gm : myGroups){
            if(gm.Group.DeveloperName == correctQueue){
                return true;
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END checkIfApprover' ); 
        return false;
    }
    
    

}