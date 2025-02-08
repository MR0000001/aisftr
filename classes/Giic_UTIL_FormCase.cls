/**
 * @author      	  : Milko Fatiga
 * @date Creation 	  : 04/05/2022
 * @description 	  : UTIL Class for the FormCase object
 */
public without sharing class Giic_UTIL_FormCase {
	 
	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_UTIL_FormCase');
	
    public static void checkIfRMALineChange(List<XC_FormCase__c> listNew,Map<Id,XC_FormCase__c> mapOld, Map<Id,XC_FormCase__c> mapNew){
        List<String> fieldList = new List<String>{'XC_RMA_Line__c'};
        List<XC_FormCase__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        SetStatusToBeApproved(listChanged);
    }
		
    public static void SetStatusToBeApproved(List<XC_FormCase__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In SetStatusToBeApproved');
        for(XC_FormCase__c fc : listNew){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ status = '+fc.XC_Status__c);
            if(fc.XC_Status__c=='New'){              
                fc.XC_Status__c = 'To be Approved';
            }
        }
    }
    
    public static void checkIfStatusChange(List<XC_FormCase__c> listNew,Map<Id,XC_FormCase__c> mapOld, Map<Id,XC_FormCase__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_FormCase__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        sendForApproval(listChanged);
    }
	
    public static void sendForApproval(List<XC_FormCase__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In sendForApproval');
        for(XC_FormCase__c fc : listNew){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ status = '+fc.XC_Status__c);
            if(fc.XC_Status__c=='To be Approved' && String.isNotBlank(fc.XC_RMA_Line__c)){
			
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Approving...');
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Legal Entity: ' + fc.XC_Legal_Entity__c);
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Form Case submitted for approval. Please approve.');
                req.setObjectId(fc.Id);

                //Submit the approval request for processing:
                Approval.ProcessResult result = Approval.process(req);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Submitted for approval successfully: ' + result.isSuccess());
				
            }
        }
    }
    
}