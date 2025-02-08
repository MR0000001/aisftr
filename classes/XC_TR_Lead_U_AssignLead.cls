/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 29/08/2018
 * @date Modification 23/05/2019 - monica.cutillo@nttdata.com
 * @date Modification 12/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_Lead_U_AssignLead – Handler for assignment of the lead when the owner changes
 */

public class XC_TR_Lead_U_AssignLead {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_U_AssignLead');

    /** @description PopulateUtilWrapper */
    private class PopulateUtilWrapper {
        Map<Id, Lead> mapOld = new Map<Id, Lead>();
        List<Lead> ownedByQueueList = new List<Lead>();
        List<Lead> ownedByUserList = new List<Lead>();
        List<Lead> ownedByWebToLead = new List<Lead>();
        List<Id> queueIdList = new List<Id>();
        List<Id> newOwnerIdList = new List<Id>();
    }

    /** @description Util Wrapper */
    public class UtilWrapper {
        public List<Lead> listLead;
        public List<Id> queueIdList;
        public List<Id> newOwnerIdList;
        public Map<Id, Lead> mapOld; 
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param listLead the list lead
    * @description    
    */
    public static void onBeforeInsert(List<Lead> listLead) {
        XC_UTIL_LeadAssignment.assignLead(listLead);
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param listLead the list lead
    * @param mapOld the map old
    * @param mapNew the map new
    * @description    
    */
    /*public static void onBeforeUpdate (List<Lead> listLead, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
        List<String> fieldList = new List<String>{'Email', 'XC_LeadPhone__c', 'XC_Address__c', 'XC_Channel__c', 'XC_ProductCategoryOfInterest__c', 'XC_Country__c', 'XC_City__c', 'XC_ZipCode__c', 'XC_MainLegalEntity__c'};
        List<Lead> leadChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<Lead> listLeadToManage = new List<Lead>();
        for(Lead ld : leadChanged) {
            if(ld.Status != Label.XC_CL_Lead_TakeCharge || ld.Status != Label.XC_CL_Lead_CustomerContacted) {
                listLeadToManage.add(ld); 
            }
        }
        if(!listLeadToManage.isEmpty()) {
            XC_UTIL_LeadAssignment.assignLead(listLeadToManage); 
        }
    }*/

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param listLead the list lead
    * @param mapOld the map old
    * @param mapNew the map new
    * @description    The method divides the lead in two categories: ones that have owner or status changed, ones that
    *                 have not these changes. Then it is called the function to process them.
    */
    public static void assignLeadChanged (List<Lead> listLead, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN CLASS XC_TR_Lead_U_AssignLead@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN assignLeadChanged@@@');
        List<String> fieldList = new List<String>{'OwnerId','Status'};
        List<sObject> leadChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!leadChanged.isEmpty()) {
            assignLead(leadChanged, mapOld, mapNew);
        }
    }
    
    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @modification Salvatore Agrillo - salvatore.agrillo@nttdata.com - 12/08/2019
     * @param listLead the list lead
     * @param mapOld the map old
     * @param mapNew the map new
     * @description The method divides the lead in two categories: ones owned by a queue, ones owned by a user.4
     *              Then it is called the function to process them.
     */
    public static void assignLead(List<Lead> listLead, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN assignLead@@@');
        if(System.isBatch()) {
            return;
        }

        Integer indexOfTask;
        Id currentUserId = UserInfo.getUserId(); 
        List<Lead> ownedByQueueList = new List<Lead>();         //List of leads owned by a queue
        List<Lead> ownedByUserList = new List<Lead>();          //List of leads owned by a user
        List<Lead> ownedByWebToLead = new List<Lead>();         //List of leads coming from web to lead
        List<Id> queueIdList = new List<Id>();
        List<Id> newOwnerIdList = new List<Id>();
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@listLead-->'+ listLead);
        for(Lead ld : listLead) {
            String ownerObjectType;
            Lead oldLead = mapOld.get(ld.Id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ oldlead.ownerId' + oldlead.OwnerId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ newlead.ownerId' + ld.OwnerId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ oldlead.status' + oldlead.Status);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ newlead.status' + ld.Status);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ oldlead' + oldlead);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ld' + ld);

            /******** Check if lead is owned by a user or a queue **********/
            if(oldLead.OwnerId != null) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@oldLead.OwnerId != null');
                ownerObjectType = XC_UTIL_Sobject.getObjectType(oldLead.OwnerId);
                Boolean ownedByQueue = (ownerObjectType == 'User') ? false : true;
                if(!ownedByQueue) {
                    ownedByUserList.add(ld);
                } else {
                    ownedByQueueList.add(ld);
                    queueIdList.add(oldLead.OwnerId);
                    newOwnerIdList.add(ld.OwnerId);
                }
            } else {
                ownedByWebToLead.add(ld);
            }
            //***************************************************************  
        }        

        PopulateUtilWrapper populateWrapper = new PopulateUtilWrapper();
        populateWrapper.mapOld = mapOld;
        populateWrapper.ownedByQueueList = ownedByQueueList;
        populateWrapper.ownedByUserList = ownedByUserList;
        populateWrapper.ownedByWebToLead = ownedByWebToLead;
        populateWrapper.queueIdList = queueIdList;
        populateWrapper.newOwnerIdList = newOwnerIdList;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@opopulateWrapper-->'+ populateWrapper);
        getUtilWrapper(populateWrapper);
    }

    /**
    * @modification Salvatore Agrillo - salvatore.agrillo@nttdata.com - 12/08/2019
    * @description Check if Old Lead has not current user Id
    * @param populateWrapper - PopulateUtilWrapper
    * @return UtilWrapper
    */
    private static UtilWrapper getUtilWrapper(PopulateUtilWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN getUtilWrapper@@@');
        UtilWrapper wrapper = new UtilWrapper();
        if(populateWrapper.ownedByUserList.size() > 0) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, Logginglevel.finest, '###1 ' + populateWrapper.ownedByUserList );
            wrapper.listLead = populateWrapper.ownedByUserList;
            wrapper.queueIdList = populateWrapper.queueIdList;
            wrapper.newOwnerIdList = populateWrapper.newOwnerIdList; 
            wrapper.mapOld = populateWrapper.mapOld;
            XC_TR_Lead_U_AssignLead.processLeadUser(wrapper);
        }
        if(populateWrapper.ownedByQueueList.size() > 0) {
            //XC_UTIL_Debug.debug(DEBUGACTIVE, Logginglevel.finest, '###2 ' + populateWrapper.ownedByQueueList );
            wrapper.listLead = populateWrapper.ownedByQueueList;
            wrapper.queueIdList = populateWrapper.queueIdList;
            wrapper.newOwnerIdList = populateWrapper.newOwnerIdList;
            wrapper.mapOld = populateWrapper.mapOld;
            XC_TR_Lead_U_AssignLead.processLeadQueue(wrapper);
        }
        if(populateWrapper.ownedByWebToLead.size() > 0) {
            wrapper.listLead = populateWrapper.ownedByWebToLead;
            wrapper.queueIdList = populateWrapper.queueIdList;
            wrapper.newOwnerIdList = populateWrapper.newOwnerIdList;
            wrapper.mapOld = populateWrapper.mapOld;
            //XC_TR_Lead_U_AssignLead.processLeadWTL(wrapper);       
        }   
        return wrapper;
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @modification Salvatore Agrillo - salvatore.agrillo@nttdata.com - 12/08/2019
     * @param wrapper - UtilWrapper 
     * @description The method processes the lead owned by a user
     */
    private static void processLeadUser(UtilWrapper wrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN processLeadUser@@@');
        //Map<Id, List<Id>> mapUserQueue = XC_TR_Lead_U_AssignLead_D.getGroupMemberByQueueId(queueIdList, newOwnerIdList);
        List<Lead> listLead = wrapper.listLead;
        List<Id> queueIdList = wrapper.queueIdList;
        List<Id> newOwnerIdList = wrapper.newOwnerIdList;
        Map<Id, Lead> mapOld = wrapper.mapOld;
        String currentUserId = UserInfo.getUserId();
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@listLead-->'+ listLead);
        for(Lead ld : listLead) {
            Lead oldLead = mapOld.get(ld.Id);
            Id queueId = oldLead.OwnerId; 
            //if(oldlead.OwnerId != currentUserId) {
            //    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ld ownerId->' + oldlead.OwnerId); 
            //} else {
                //Could be commented if reassignment to queue, or to be reviewed
                /*if( (oldlead.OwnerId != ld.OwnerId) &&
                    (XC_UTIL_Sobject.getObjectType(ld.OwnerId) != 'User') )
                        ld.addError(Label.XC_CL_CantEditLead);*/
                if(oldlead.OwnerId != ld.OwnerId) {
                    if(oldLead.Status == Label.XC_CL_Lead_TakeCharge || oldLead.Status == Label.XC_CL_Lead_CustomerContacted) { 
                        ld.Status = Label.XC_CL_Lead_Assigned;
                    }
                    else if((oldLead.Status == Label.XC_CL_Lead_PendingScheduling && ld.Status == Label.XC_CL_Lead_AppointmentScheduling) ||
                            (oldLead.Status == Label.XC_CL_Lead_Assigned && ld.Status == Label.XC_CL_Lead_Assigned)){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Owner changed for Assigned Resource');
                    }
                    else if(oldLead.Status == Label.XC_CL_Lead_PendingScheduling){
                        ld.Status = Label.XC_CL_Lead_Assigned;
                    }else {
                        ld.addError(Label.XC_CL_Lead_CannotChangeOwner);                        
                    }
                }
            //}  
        }
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @param wrapper - UtilWrapper
     * @description    The method processes the lead owned by a queue OR lead coming from Web to Lead
     */
    @TestVisible
    private static void processLeadQueue(UtilWrapper wrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN processLeadQueue@@@');
        List<Lead> listLead = wrapper.listLead;
        List<Id> queueIdList = wrapper.queueIdList;
        List<Id> newOwnerIdList = wrapper.newOwnerIdList;
        Map<Id, Lead> mapOld = wrapper.mapOld;
        Map<Id, List<Id>> mapUserQueue = XC_TR_Lead_U_AssignLead_D.getGroupMemberByQueueId(queueIdList, newOwnerIdList);
        String currentUserId = UserInfo.getUserId();
        List<Id> listUserId;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapUserQueue-->'+ mapUserQueue);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@listLead-->'+ listLead);
        for(Lead ld : listLead) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, mapUserQueue);
            Lead oldLead = mapOld.get(ld.Id);
            Id queueId = oldLead.OwnerId;  
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ' + mapUserQueue.get(oldLead.OwnerId));
            Boolean returned = addErrorForPermission(mapUserQueue, ld, oldLead);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@returned-->'+ returned);
            if(returned) {
                return;
            }
            if(oldLead.OwnerId == ld.OwnerId) {
                if(oldLead.Status == Label.XC_CL_Lead_Assigned && ld.Status == Label.XC_CL_Lead_WorkingNotContacted){
                    ld.OwnerId = currentUserId;
                }
            } else {
                if(!(mapUserQueue.get(oldLead.OwnerId)).contains(ld.OwnerId) &&
                    !(mapUserQueue.get(oldLead.OwnerId)).contains(currentUserId)) {
                        //If both the running user and the new owner are in the queue
                        ld.addError(Label.XC_CL_Lead_NotMemberQueue); //Label.XC_CL_Lead_NotSameQueue
                } else {
                    if(oldLead.Status == Label.XC_CL_Lead_TakeCharge) {
                            ld.Status = Label.XC_CL_Lead_Assigned;
                    }
                }
            }
        }   
    }

    /**
     * @param mapUserQueue - Map<Id, List<Id>>
     * @param ld - Lead
     * @param oldLead - Lead
     * @description Add error if user is not member of the queue
     * @return Boolean
     */
    private static Boolean addErrorForPermission(Map<Id, List<Id>> mapUserQueue, Lead ld, Lead oldLead) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN addErrorForPermission@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapUserQueue -->'+ mapUserQueue);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@oldLead -->'+ oldLead);
        if(mapUserQueue.isEmpty() || !mapUserQueue.containsKey(oldLead.OwnerId)) {
            ld.addError(Label.XC_CL_Lead_NotMemberQueue);
            return true;
        }
        else {
            List<Id> listIds = mapUserQueue.get(oldLead.OwnerId);
            if(listIds.isEmpty() && !listIds.contains(UserInfo.getUserId())) {
                //'You are not member of this queue'
                ld.addError(Label.XC_CL_Lead_NotMemberQueue);
                return true;
            }
        }
        return false;
    }

    /**
     * @author         Federico Amici - federico.amici@nttdata.com
     * @param wrapper - UtilWrapper
     * @description    The method processes the lead coming from the web to lead
     */
    /*@TestVisible
    private static void processLeadWTL(UtilWrapper wrapper) {
        List<Lead> listLead = wrapper.listLead;
        List<Id> queueIdList = wrapper.queueIdList;
        List<Id> newOwnerIdList = wrapper.newOwnerIdList;
        Map<Id, Lead> mapOld = wrapper.mapOld;
        for(Lead ld : listLead) {
            Lead oldLead = mapOld.get(ld.Id);
            Id queueId = oldLead.OwnerId;  
            if(!XC_UTIL_Lead.isSourceWeb(oldlead)){ 
                ld.addError(Label.XC_CL_CantEditLead);
            } else {
                if( (oldlead.OwnerId != ld.OwnerId) && (oldLead.Status == Label.XC_CL_Lead_TakeCharge)) {
                        ld.Status = Label.XC_CL_Lead_Assigned;
                }
            }
        }
    }*/

    /**
    * @description Check if Old Lead has not current user Id
    * @param ld - Lead
    * @param oldLead - Lead
    * @param currentUserId - Id
    * @return Boolean
    */
    /*private static Boolean processLeadUser(Lead ld, Lead oldLead, Id currentUserId) {
        if(oldLead.OwnerId != currentUserId){            //If the running user is not the owner of the lead
            ld.addError(Label.XC_CL_CantEditLead);  
            return false;
        } else {
            return true;
        }
    }*/

    /**
    * @author Dario Tramontin dtramontin@deloitte.it
    * @date Creation 04/12/2019
    * @description Encrypt Id
    * @param listNew - List Lead
    */
    public static void encryptLeadIds(List<Lead> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ENTER IN encryptLeadIds@@@');
        
        List<Lead> ldToUpdate = new List<Lead>();
        for(Lead ld: listNew){
            Lead ldUpdate= new Lead(Id=ld.Id);
            ldUpdate.XC_EncryptedId__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(ld.Id);
            ldToUpdate.add(ldUpdate);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ldToUpdate-->' + ldToUpdate);
        XC_UTIL_Sobject.updateListRecords(ldToUpdate); 
    }

}