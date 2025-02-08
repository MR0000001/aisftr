/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 11/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_LeadAssignmentMaster_U_AddErrors – Methods to add errors on insert and update of lead assignment master records.
*/
public without sharing class XC_TR_LeadAssignmentMaster_U_AddErrors { 
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_LeadAssignmentMaster_U_AddErrors');
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 11/07/2019
    * @description Methods to add errors on lam
    * @param listNew - List of Leads in input from trigger
    **/
    public static void onBeforeInsert(List<XC_LeadAssignmentMaster__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_TR_LeadAssignmentMaster_U_AddErrors onBeforeInsert');
        addErrorOnLAM(listNew);
    }
 
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 11/07/2019
    * @description Methods to add errors on lam
    * @param mapOld
    * @param mapNew 
    **/
    public static void onBeforeUpdate(Map<Id, XC_LeadAssignmentMaster__c> mapOld, Map<Id, XC_LeadAssignmentMaster__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_TR_LeadAssignmentMaster_U_AddErrors onBeforeInsert');
        List<String> fieldList = new List<String>{'XC_Status__c','XC_ProductCategoryOfInterest__c','XC_Address__c','XC_AssignedToCreator__c'};
        List<sObject> leadsAssignmentMasterChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!leadsAssignmentMasterChanged.isEmpty()) {
            addErrorOnLAM(leadsAssignmentMasterChanged);
        }
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description Method to add an error on the lead assignment master when trying to add/update a record with status Pending Scheduled
                   but commercial visit not required. 
    * @param listLeadAssignment list Leads in input
    */
    private static void addErrorOnLAM(List<XC_LeadAssignmentMaster__c> listLeadAssignment){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_TR_LeadAssignmentMaster_U_AddErrors addErrorOnLAM');
        Map<XC_LeadAssignmentMaster__c,String> leadLamMap = new Map<XC_LeadAssignmentMaster__c,String>();
        List<String> listProducts = new List<String>();
        for(XC_LeadAssignmentMaster__c lam : listLeadAssignment){
            listProducts.add(lam.XC_ProductCategoryOfInterest__c);
            if(!String.isEmpty(lam.XC_AssignedToQueue__c)){
                leadLamMap.put(lam, lam.XC_AssignedToQueue__c);
            }
        }
        System.debug('leadLamMap --->'+ leadLamMap);
        Map<XC_LeadAssignmentMaster__c, Boolean> checkQueueMap = checkQueue(leadLamMap);
        Map<String, Boolean> mapProductBoolean = checkIfCommercialVisitRequired(listProducts);
        for(XC_LeadAssignmentMaster__c lam : listLeadAssignment){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_TR_LeadAssignmentMaster STATUS -> '+lam.XC_Status__c+ ' ADDRESS--> '+ lam.XC_Address__c + ' ASSUGNEDTOCREATOR-->' + lam.XC_AssignedToCreator__c + ' REQUIRE COMMERCIAL VISIT--> '+ mapProductBoolean.get(lam.XC_ProductCategoryOfInterest__c));
            if(checkConditions(lam, mapProductBoolean)){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ LEAD ASSIGNMENT CORRECTLY INSERTD/UPDATED ->' + lam);
                if(checkIfCommercialVisitNotRequired(lam, mapProductBoolean)){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ LEAD ASSIGNMENT CORRECTLY INSERTD/UPDATED ->' + lam);
                } else {
                    lam.addError(Label.XC_CL_LeadAssignmentMaster_CommercialVisitNotRequired);
                }
            } else {
                lam.addError(Label.XC_CL_LeadAssignmentMaster_ProductError);
            }
  
            if(!leadLamMap.isEmpty()){
                if(checkQueueMap.containsKey(lam) && !checkQueueMap.get(lam)){
                    lam.addError(Label.XC_CL_LeadAssignmentMaster_QueueError);
                }
            }
        }
    }

    private static Boolean checkConditions(XC_LeadAssignmentMaster__c lam, Map<String, Boolean> mapProductBoolean ){
        if(!mapProductBoolean.containsKey(lam.XC_ProductCategoryOfInterest__c) && lam.XC_Status__c == Label.XC_CL_Lead_Assigned) {
            return true;
        } else if(!mapProductBoolean.containsKey(lam.XC_ProductCategoryOfInterest__c) && lam.XC_Status__c != Label.XC_CL_Lead_Assigned){
            return false;
        }
        Boolean commercialVisitRequired = mapProductBoolean.get(lam.XC_ProductCategoryOfInterest__c);
        Boolean existsAddress = lam.XC_Address__c == Label.XC_CL_YesText;
        if(checkConditionOnLam(lam, commercialVisitRequired, existsAddress)) {
            return true;
        } 
        return false;
    }

    private static Boolean checkIfCommercialVisitNotRequired (XC_LeadAssignmentMaster__c lam, Map<String, Boolean> mapProductBoolean){
        if(!mapProductBoolean.containsKey(lam.XC_ProductCategoryOfInterest__c) && lam.XC_Status__c == Label.XC_CL_Lead_Assigned) {
            return true;
        } else if(!mapProductBoolean.containsKey(lam.XC_ProductCategoryOfInterest__c) && lam.XC_Status__c != Label.XC_CL_Lead_Assigned){
            return false;
        }
        Boolean commercialVisitRequired = mapProductBoolean.get(lam.XC_ProductCategoryOfInterest__c);
        if((lam.XC_Status__c == Label.XC_CL_Lead_Assigned && !commercialVisitRequired ) || commercialVisitRequired) {
            return true;
        }
        return false; 
    }

    private static Boolean checkConditionOnLam(XC_LeadAssignmentMaster__c lam, Boolean commercialVisitRequired, Boolean existsAddress){
        return ((lam.XC_Status__c == Label.XC_CL_Lead_PendingScheduling && commercialVisitRequired && existsAddress && lam.XC_AssignedToCreator__c) || 
            lam.XC_Status__c == Label.XC_CL_Lead_Assigned || lam.XC_Status__c == '' || !commercialVisitRequired);
    }
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description Method to check the boolean Commercial Visit
    * @param listProducts
    * @return Map<String, Boolean> mapProductBoolean
    */
    private static Map<String, Boolean> checkIfCommercialVisitRequired(List<String> listProducts){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_TR_LeadAssignmentMaster_U_AddErrors checkIfCommercialVisitRequired');
        Map<String, Boolean> mapProductBoolean = new Map<String, Boolean>();
        List<XC_ProductCategoryOfInterest__c> productCategoryList = new List<XC_ProductCategoryOfInterest__c>([SELECT Id,Name, XC_CommercialVisit__c 
                                                                                                                FROM XC_ProductCategoryOfInterest__c 
                                                                                                                WHERE Name IN: listProducts]);
        for(XC_ProductCategoryOfInterest__c product : productCategoryList){
            mapProductBoolean.put(product.Name, product.XC_CommercialVisit__c);
        }
        return mapProductBoolean;
    }



    /**
    * @description check inf the Queue exists
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param  leadLamMap Map<XC_LeadAssignmentMaster__c, String>
    * @return checkQueueMap Map<XC_LeadAssignmentMaster__c, Boolean>
    */
    private static Map<XC_LeadAssignmentMaster__c, Boolean> checkQueue(Map<XC_LeadAssignmentMaster__c,String> leadLamMap){
        System.debug('QUEUE ASSIGNED --->' + leadLamMap.values());
        Map<XC_LeadAssignmentMaster__c, Boolean> checkQueueMap = new Map<XC_LeadAssignmentMaster__c, Boolean>();
        Map<Id, Group> groupMap = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN: leadLamMap.values()]);
        Boolean queueExisting = false;
        for(XC_LeadAssignmentMaster__c lam : leadLamMap.keyset()){
            for(Group queue : groupMap.values()){
                if(lam.XC_AssignedToQueue__c == queue.Name){
                    checkQueueMap.put(lam, true);
                    queueExisting = true;
                    break;
                }
            }
            if(!queueExisting){
                checkQueueMap.put(lam, false);
            } 
        }       
        return checkQueueMap;
    }
	

}