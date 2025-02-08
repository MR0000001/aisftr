/**
* @author Roberta Cossiga - rcossiga@deloitte.it 
* @date Creation 06/09/2018
* @date Modification 26/05/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Lead_U_HandleMapping – Handle standard Lead Field Mapping
*/

public without sharing class XC_TR_Lead_U_HandleMapping {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_U_HandleMapping');
    
    /**
    * @description Method to detect record to handle mapping
    * @param listLead - List<Lead>
    * @param mapOld - Map<Id, Lead>
    * @param mapNew - Map<Id, Lead>
    */
    public static void handleCustomMapping(List<Lead> listLead, Map<Id,Lead> mapOld, Map<Id,Lead> mapNew) {
        List<String> fieldsToMap=new List<String>{'Email','MobilePhone', 'Salutation'};
        List<Lead> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToMap,mapOld,mapNew);
        if(!listChanged.isEmpty()){
            mapLeadFields(listChanged);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Records changed: ' + listChanged);
        }
    }
    
    /**
    * @description Method to map fields
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listLead - List<Lead>
    */
    public static void mapLeadFields(List<Lead> listLead){
        List<String> listRecordTypeToCheck = new List<String>{Label.XC_CL_Lead_GLOB2B, Label.XC_CL_Lead_GLOB2G};
        for(Lead ld : listLead) {
            if(!listRecordTypeToCheck.contains(ld.XC_LeadRecordType__c)) {
                ld.XC_EmailCustom__c = ld.Email;
            }
            ld.XC_MobileCustom__c = ld.MobilePhone; 
            ld.XC_Salutation__c = ld.Salutation;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Salutation: ' + ld.XC_Salutation__c);
        }
    }
    
    /**
    * @description Manage Commercial Visit Required
    * @param listLead - List<Lead>
    * @param mapOld - Map<Id, Lead>
    * @param mapNew - Map<Id, Lead>
    */
    public static void getCommercialVisitRequired(List<Lead> listLead, Map<Id,Lead> mapOld, Map<Id,Lead> mapNew){
        List<String> fieldsToMap=new List<String>{'XC_ProductCategoryOfInterest__c'};
        List<Lead> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToMap,mapOld,mapNew);
        if(!listChanged.isEmpty()){
            getProductCategoryCommercialVisit(listChanged);
        }
    }
    
    /**
    * @description Manage Product Category
    * @param listNew - List<Lead> 
    */
    public static void getProductCategoryCommercialVisit(List<Lead> listNew){
        List<String> listProductCategoryNames = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_ProductCategoryOfInterest__c');
        List<XC_ProductCategoryOfInterest__c> productsOfInterest= XC_TR_Lead_U_CheckDuplicates_D.retrieveProductCategoriesFromNames(listProductCategoryNames);
        for(Lead ld : listNew){
            for (XC_ProductCategoryOfInterest__c prodInt : productsOfInterest){
                if(ld.XC_ProductCategoryOfInterest__c == prodInt.Name){
                    ld.XC_CommercialVisitRequired__c = prodInt.XC_CommercialVisit__c ;
                }
            }    
        }
    }
    
    /**
    * @description Handle Mapping Owner
    * @param listLead - List<Lead>
    * @param mapOld - Map<Id, Lead>
    * @param mapNew - Map<Id, Lead>
    */
    public static void handleOwnerMapping(List<Lead> listLead, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew){
        List<String> fieldsToMap=new List<String>{'OwnerId'};
        List<Lead> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToMap,mapOld,mapNew);
        if(!listChanged.isEmpty()){
            mapLeadOwner(listChanged);
        }
    }
    
    /**
    * @description Handle Mapping Owner
    * @param listLead - List<Lead>
    */
    public static void mapLeadOwner(List<Lead> listLead){
        Boolean queryOnUser = false;
        Map<String, String> mapOwnerObject = new Map<String, String>();
        List<Id> leadOwner = XC_UTIL_Sobject.getListFieldValues(listLead, 'OwnerId');
        List<String> leadOwnerUser = new List<String>();
        List<String> leadOwnerGroup = new List<String>();
        for (Id owner : leadOwner){
            String objectName = owner.getSObjectType().getDescribe().getName();
            mapOwnerObject.put(owner, objectName);
        }
        for(String owner : mapOwnerObject.keySet()){
            if(mapOwnerObject.get(owner) == 'User'){
                queryOnUser = true;
                leadOwnerUser.add(owner);
            }
            else{
                queryOnUser= false;
                leadOwnerGroup.add(owner);
            }
        }
        Map<Id,String> userNameMap = new Map<Id, String>();
        List<Group> gList;
        List<User>  uList;
        String nameGroup;
        String username;
        if(queryOnUser /*|| queryOnUser == false*/){
            Map<Id,User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN: leadOwnerUser]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, LOGGINGLEVEL.DEBUG,'userMap#'+userMap);
            for(User u : userMap.values()){
                userNameMap.put(u.Id, u.Name);
                uList = userMap.values();
                username =  u.Name;
            }
        } else{
            Map<Id,Group> groupMap = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Id IN: leadOwnerGroup]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@groupMap'+groupMap);
            for(Group u : groupMap.values()){
                userNameMap.put(u.Id, u.Name);                
                gList = groupMap.values();
                nameGroup = u.Name;
            }
        }        
        String ownername = username;
        String ownernameX = nameGroup;
        for(Lead ld : listLead){
            if(String.isBlank(nameGroup)){
                XC_UTIL_Debug.debug(DEBUGACTIVE, logginglevel.fine,'1 ####');
                ld.XC_Owner__c= ownername; 
            } else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, logginglevel.fine,'2 ######');
                ld.XC_Owner__c= ownernameX; 
            }
        }
    }
    
}