/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Salvatore Agrillo salvatore.agrillo@nttdata.com
* @date Creation 19/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_LeadAssignment_U – Methods for XC_UTIL_LeadAssignment
*/

public without sharing class XC_UTIL_LeadAssignment_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_LeadAssignment');
 
    /** @description AssignLeadWrapper */
    public class AssignLeadWrapper {
        public List<XC_UTIL_LeadAssignment.LeadAssignmentWrapperResult> listResultWrapper = new List<XC_UTIL_LeadAssignment.LeadAssignmentWrapperResult>();
        public List<Lead> listLeadWithNoMatch = new List<Lead>();
    }

    /** @description Assign Group Wrapper */
    public class AssignGroupWrapper {
        public String genericQueueId;
        public String usernameOrGroupId;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Assign Lead
    * @param listLeadWrapper - List<LeadAssignmentWrapper>
    * @param listAssignment - List<XC_LeadAssignmentMaster__c>
    * @return assignWrapper - AssignLeadWrapper
    **/   
    public static AssignLeadWrapper assignLead(List<XC_UTIL_LeadAssignment.LeadAssignmentWrapper> listLeadWrapper, List<XC_LeadAssignmentMaster__c> listAssignment) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_LeadAssignment_U  assignLead');
        AssignLeadWrapper assignWrapper = new AssignLeadWrapper();
        XC_UTIL_LeadAssignment.CheckMatchLeadWrapper matchWrapper = new XC_UTIL_LeadAssignment.CheckMatchLeadWrapper();
        for(XC_UTIL_LeadAssignment.LeadAssignmentWrapper leadWrapper : listLeadWrapper){ 
            List<XC_UTIL_LeadAssignment.LeadAssignmentWrapper> leadSkippedWrapper = new List<XC_UTIL_LeadAssignment.LeadAssignmentWrapper>();            
            matchWrapper = XC_UTIL_LeadAssignment.checkLeadAssignmentMasterMatch(leadWrapper, listAssignment, leadWrapper.consentLegalEntity);
            if(!matchWrapper.isSkipped) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ IS NOT SKIPPED For Lead To Check  ->' + matchWrapper.resultWrapper);
                assignWrapper.listResultWrapper.add(matchWrapper.resultWrapper);
                continue; //break;
            } else {  
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Lead To Check (No Exact Match)');
                matchWrapper = XC_UTIL_LeadAssignment.checkLeadAssignmentMasterWildCardMatch(leadWrapper, listAssignment, leadWrapper.consentLegalEntity); 
                if(!matchWrapper.isSkipped) {
                    assignWrapper.listResultWrapper.add(matchWrapper.resultWrapper);
                    if(!assignWrapper.listLeadWithNoMatch.isEmpty()){
                        assignWrapper.listLeadWithNoMatch.clear();
                    }
                    continue; //break;
                } else {
                    assignWrapper.listLeadWithNoMatch.add(leadWrapper.lead);
                } 
            }   
        } 
        return assignWrapper;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Assign Lead
    * @param listOwnerId - List<String>
    * @return assignGroup - AssignGroupWrapper
    **/    
    public static AssignGroupWrapper assignGroup(List<String> listOwnerId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_LeadAssignment_U  assignGroup');
        List<Group>  listGroup = new List<Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name =: Label.XC_CL_Lead_GenericQueue LIMIT 1]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Assignment@ assignGroup -> '+ listGroup);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Assignment@ listNameGroup -> ' + listOwnerId);
        AssignGroupWrapper assignGroup = new AssignGroupWrapper();
        
        if(listOwnerId.isEmpty() && !listGroup.isEmpty()){
           assignGroup.genericQueueId = listGroup[0].Id;
        } else {
            assignGroup.usernameOrGroupId = listOwnerId[0];
        }
        return assignGroup;
    }

    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description search the correct queue for assignment
    * @param queueNameList - name of the product
    * @return Map<String,String> queue to be assigned
    **/  
    public static Map<String,String> searchForCorrectQueue(List<String> queueNameList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS@@ OWNER queueNameList -->' + queueNameList);
        Map<String,String> queueNameMap = new Map<String,String>(); 
        Map<Id, Group> groupMap = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN: queueNameList]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS@@ OWNER groupMap -->' + groupMap);
        if(!groupMap.isEmpty()){
            for(Group gr : groupMap.values()){
                queueNameMap.put(gr.Name, gr.Id);
            }
        }
        return queueNameMap;
    }

    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description set dateTime based On Status
    * @param ld
    **/  
    public static void setDateTime(Lead ld){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_LeadAssignment_U  setDateTime');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS@@ Lead Assingnment DateTime Setting  -->' + ld.Status);
        if(ld.Status == Label.XC_CL_Lead_Assigned){
            ld.XC_AssignedTime__c = Datetime.now();
        } else if(ld.Status == Label.XC_CL_Lead_PendingScheduling){
            ld.XC_PendingSchedulingTime__c = Datetime.now();
        }
    }
  
    /** 
    * @author
    * @description generic Queue Scenario
    * @param populateWrapper - wrapper
    **/ 
    public static void genericQueueScenario(XC_UTIL_LeadAssignment.PopulateLeadWrapper populateWrapper){
        system.debug('@@@@Start genericQueueScenario');
        List<Group>  listGroupCHL=  new List<Group>([SELECT Id, Name,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName =: Label.XC_CL_LeadCHL_GenericQueue LIMIT 1]);
        List<Group>  listGroupCOL=  new List<Group>([SELECT Id, Name,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName =: Label.XC_CL_LeadCOL_GenericQueue limit 1]);
        List<Group>  listGroupItaB2B=  new List<Group>([select id,name,DeveloperName from group where type='Queue' and DeveloperName='XC_ITA_Italian_Candidates_B2B' limit 1]);
        List<Group>  listGroupItaB2G=  new List<Group>([select id,name,DeveloperName from group where type='Queue' and DeveloperName='XC_ITA_Italian_Candidates_B2G' limit 1]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_LeadAssignment_U  genericQueueScenario');
        if(!populateWrapper.listLeadWithNoMatch.isEmpty() && populateWrapper.genericQueueId != ''/* && !Test.isRunningTest()*/){
            for(Lead ld : populateWrapper.listLeadWithNoMatch ){
                if(ld.XC_MainLegalEntity__c==Constants.ENEL_X_CHILE ||
                   ld.XC_MainLegalEntity__c==Constants.ENEL_DISTRIBUCION_CHILE ||
                   ld.XC_MainLegalEntity__c=='EnelXMobilityChile'){
                   ld.OwnerId=listGroupCHL[0].id;      
                   }else if(ld.XC_MainLegalEntity__c==Constants.CODENSA){
                    ld.OwnerId=listGroupCOL[0].id;     
                   }else if((ld.XC_MainLegalEntity__c=='EnelXItalia' || 
                             ld.XC_MainLegalEntity__c=='EnelXMobilityItalia') && 
                             ld.XC_Segment__c=='B2B'){
                       ld.OwnerId=listGroupItaB2B[0].id;      
                   }else if ((ld.XC_MainLegalEntity__c=='EnelXItalia' || 
                             ld.XC_MainLegalEntity__c=='EnelXMobilityItalia') && 
                             ld.XC_Segment__c=='B2G'){
                                ld.OwnerId=listGroupItaB2G[0].id;  
                             }
                   else{
                   ld.OwnerId = populateWrapper.genericQueueId;
                   }
                system.debug('Queue Id'+' '+populateWrapper.genericQueueId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @@SS@@ LEAD NO PRODUCT NO MATCH ld.Status-->' + ld.Status);
                ld.Status = Label.XC_CL_Lead_Assigned; 
                setDateTime(ld);
            }
        }
    }
}