/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_OrderItemCompl_U_UpdateStatus 
*/
public without sharing class XC_TR_OrderItemCompl_U_UpdateStatus {

      /**
    * @description updateStatus - When change Status of OrderItemCompliance populate his brothers and father   
    * @author Valeria Martino - valeria.martino@nttdata.com  
    * @param listNew - List<XC_OrderItemCompliance__c
    * @param mapOld - Map<Id,XC_OrderItemCompliance__c>
    * @param mapNew - Map<Id,XC_OrderItemCompliance__c> 
    */
    public static void afterUpdateStatus(List<XC_OrderItemCompliance__c> listNew, Map<Id,XC_OrderItemCompliance__c> mapOld,   Map<Id,XC_OrderItemCompliance__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_OrderItemCompliance__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
         if(!Schema.SObjectType.XC_OrderItemCompliance__c.isAccessible() || !Schema.sObjectType.XC_OrderItemCompliance__c.isUpdateable()) { 
            return;
        }
        List<XC_OrderItemCompliance__c> listConfItemListChanged = [SELECT Id, XC_ComplianceVerificationStatus__c, XC_Status__c, XC_KoReason__c, XC_KoCriticality__c, XC_RecoveryResponsible__c FROM XC_OrderItemCompliance__c WHERE Id IN :confItemListChanged];
        copyFields(listConfItemListChanged);       
    }
    /**
    * @description  updateStatus - When change Status of OrderItemCompliance populate himself  
    * @author Valeria Martino - valeria.martino@nttdata.com  
    * @param listNew - List<XC_OrderItemCompliance__c> 
    * @param mapOld - Map<Id, XC_OrderItemCompliance__c> 
    * @param mapNew - Map<Id, XC_OrderItemCompliance__c>
    */
    public static void beforeUpdateStatus(List<XC_OrderItemCompliance__c> listNew, Map<Id,XC_OrderItemCompliance__c> mapOld,   Map<Id,XC_OrderItemCompliance__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_OrderItemCompliance__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
         if(!Schema.SObjectType.XC_OrderItemCompliance__c.isAccessible() || !Schema.sObjectType.XC_OrderItemCompliance__c.isUpdateable()) { 
            return;
        }
        populateOrderItemCompliance(confItemListChanged);
        trackStatus(confItemListChanged);      
    }
    /**
    * @description populateOrderItemCompliance - populate KoCritically and RecoveryResponsible of OrderItemCompliance by custom metadata 
    * @author Valeria Martino - valeria.martino@nttdata.com  
    * @param confItemListChanged - List<XC_OrderItemCompliance__c>
    */
    public static void populateOrderItemCompliance(List<XC_OrderItemCompliance__c> confItemListChanged ) {
        Map<String, String> mapObjectFieldKoCritically = new Map<String, String>(); 
        Map<String, String> mapObjectFieldRecoveryResponsible = new Map<String, String>(); 
        List<String> listKoReasonChanged = new List<String>();
        Map<String,String> mapComplianceTypeChanged = new Map<String,String>();
        List<XC_OrderItemCompliance__c> listOrderItemComplianceToUpdate= new List<XC_OrderItemCompliance__c>();
        for(XC_OrderItemCompliance__c orderItemCompliance : confItemListChanged) {
                listKoReasonChanged.add(orderItemCompliance.XC_KoReason__c);
                mapComplianceTypeChanged.put(orderItemCompliance.id, orderItemCompliance.XC_ComplianceType__c);           
        }
        Map<String, String> mapCountry = getCountryByOrderItemCompliance(mapComplianceTypeChanged.keySet());
       
        List<XC_CM_ComplianceMapping__mdt> listFieldsMapping = new List<XC_CM_ComplianceMapping__mdt>([SELECT Id, XC_KoCriticality__c, XC_Country__c, XC_ComplianceType__c,  XC_RecoveryResponsible__c, XC_KoReason__c FROM XC_CM_ComplianceMapping__mdt WHERE XC_Country__c IN :mapCountry.values() AND XC_KoReason__c  IN :listKoReasonChanged]); 
        for(XC_CM_ComplianceMapping__mdt cm : listFieldsMapping) {
            for(String orderItemComplianceId : mapComplianceTypeChanged.keySet()) {
                if(mapComplianceTypeChanged.get(orderItemComplianceId) == cm.XC_ComplianceType__c && mapCountry.get(orderItemComplianceId) == cm.XC_Country__c ) {
                    mapObjectFieldKoCritically.put(orderItemComplianceId, cm.XC_KoCriticality__c);
                    mapObjectFieldRecoveryResponsible.put(orderItemComplianceId, cm.XC_RecoveryResponsible__c);
                }
            }
        }
        if(!listFieldsMapping.isEmpty()) {
            for(XC_OrderItemCompliance__c orderItemCompliance : confItemListChanged) {
                //If KOReason is Populated and OrderItemCompliance met the condition: if ComplianceType cointained in Custom Metadata 
                if(!String.isBlank(orderItemCompliance.XC_KoReason__c) && (mapObjectFieldRecoveryResponsible.keyset()).contains(orderItemCompliance.id)) {
                   orderItemCompliance.XC_KoCriticality__c =  mapObjectFieldKoCritically.get(orderItemCompliance.id);
                   orderItemCompliance.XC_RecoveryResponsible__c =  mapObjectFieldRecoveryResponsible.get(orderItemCompliance.id);
                   listOrderItemComplianceToUpdate.add(orderItemCompliance);
                }
            }
            XC_UTIL_Sobject.updateListRecords(listOrderItemComplianceToUpdate);  
        }
    }
    /**
    * @description copyFields - populate Status and KoReason of Father and Status, KoReason, KoCriticality, RecoveryResponsible of Brothers of OrderItemCompliance  
    * @author Valeria Martino - valeria.martino@nttdata.com 
    * @param listConfItemListChanged - List<XC_OrderItemCompliance__c> 
    */
    public static void copyFields(List<XC_OrderItemCompliance__c> listConfItemListChanged){
        Boolean stopRecursive = false;       
        List<XC_ComplianceVerificationStatus__c> listComplVerificationToUpdate = new List<XC_ComplianceVerificationStatus__c>();
        Map<String, String> listChangedFather = new Map<String, String>();
        for(XC_OrderItemCompliance__c listconfItemCompliance : listConfItemListChanged) {
 
            //Son/Father of confItemListChanged
            listChangedFather.put(listconfItemCompliance.id, listconfItemCompliance.XC_ComplianceVerificationStatus__c );
        }
        System.debug('@@@@@ -> listChangedFather' + listChangedFather);
        List<XC_ComplianceVerificationStatus__c> listComplVerificationToMap = new List<XC_ComplianceVerificationStatus__c>([SELECT Id, XC_ComplianceStatus__c, XC_KoReason__c, 
                                                                                                                                (SELECT Id, XC_Status__c, XC_ComplianceVerificationStatus__r.id, XC_ComplianceVerificationStatus__r.XC_ComplianceStatus__c , XC_KoReason__c, XC_KoCriticality__c, XC_RecoveryResponsible__c FROM Order_Item_Compliance__r)                                                                                                                                
                                                                                                                            FROM XC_ComplianceVerificationStatus__c 
                                                                                                                            WHERE Id IN :listChangedFather.values()]);     
        
        //Sons of confItemListChanged
        List<XC_OrderItemCompliance__c> orderItemComplianceSons = new List<XC_OrderItemCompliance__c>();
        for(XC_ComplianceVerificationStatus__c orderItemCompliance:  listComplVerificationToMap) {
            orderItemComplianceSons.addAll(orderItemCompliance.Order_Item_Compliance__r);
        }
        Map<String, XC_ComplianceVerificationStatus__c>  mapComplVerificationToUpdate = new Map<String, XC_ComplianceVerificationStatus__c>();
        List<XC_OrderItemCompliance__c> listOrderComplianceBrothers = new List<XC_OrderItemCompliance__c>();
        for(XC_OrderItemCompliance__c listconfItemComplianceVerification : orderItemComplianceSons) {
            mapComplVerificationToUpdate.put(listconfItemComplianceVerification.id,listconfItemComplianceVerification.XC_ComplianceVerificationStatus__r);
        }
        for(XC_OrderItemCompliance__c listconfItemCompliance : listConfItemListChanged) {      
            if((mapComplVerificationToUpdate.get(listconfItemCompliance.id)) !=null) {
                //Populate father
                (mapComplVerificationToUpdate.get(listconfItemCompliance.id)).XC_KoReason__c = listconfItemCompliance.XC_KoReason__c;
                //if Status 
                populateFatherComplianceStatus(mapComplVerificationToUpdate,listconfItemCompliance);
                listComplVerificationToUpdate.add(mapComplVerificationToUpdate.get(listconfItemCompliance.id));                         
                for(XC_OrderItemCompliance__c confItemComplianceorderItemComplianceBrother : orderItemComplianceSons) {
                    //If Same Father
                    if(listChangedFather.get(listconfItemCompliance.id) == mapComplVerificationToUpdate.get(confItemComplianceorderItemComplianceBrother.id).id && confItemComplianceorderItemComplianceBrother.id != listconfItemCompliance.id) {                                    
                        confItemComplianceorderItemComplianceBrother.XC_Status__c = listconfItemCompliance.XC_Status__c;
                        confItemComplianceorderItemComplianceBrother.XC_KoReason__c = listconfItemCompliance.XC_KoReason__c;
                        confItemComplianceorderItemComplianceBrother.XC_KoCriticality__c = listconfItemCompliance.XC_KoCriticality__c;
                        confItemComplianceorderItemComplianceBrother.XC_RecoveryResponsible__c = listconfItemCompliance.XC_RecoveryResponsible__c;
                        listOrderComplianceBrothers.add(confItemComplianceorderItemComplianceBrother);                    
                    }
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(listComplVerificationToUpdate); 
        XC_UTIL_Sobject.updateListRecords(listOrderComplianceBrothers);
        System.debug('@@@@ -> listComplVerificationToUpdate:' + listComplVerificationToUpdate);
        System.debug('@@@@ -> listOrderComplianceBrothers:' + listOrderComplianceBrothers);         
    }
    /**
    * @description populateFatherComplianceStatus - Populate Status of ComplianceVerificationStatus  by Status of OrderItemCompliance
    * @author Valeria Martino - valeria.martino@nttdata.com 
    * @param mapComplVerificationToUpdate - Map<String, XC_ComplianceVerificationStatus__c>
    * @param listconfItemCompliance - XC_OrderItemCompliance__c
    */
    public static void populateFatherComplianceStatus(Map<String, XC_ComplianceVerificationStatus__c>  mapComplVerificationToUpdate, XC_OrderItemCompliance__c listconfItemCompliance ) {
        if(listconfItemCompliance.XC_Status__c == Label.XC_CL_OK) {
            (mapComplVerificationToUpdate.get(listconfItemCompliance.id)).XC_ComplianceStatus__c = listconfItemCompliance.XC_Status__c.touppercase();                   
        }
        else if(listconfItemCompliance.XC_Status__c == Label.XC_CL_KO && listconfItemCompliance.XC_KoCriticality__c == Label.XC_CL_Priority_High) {
            (mapComplVerificationToUpdate.get(listconfItemCompliance.id)).XC_ComplianceStatus__c = Label.XC_CL_ComplianceVerificationStatus_KoFinal;                  
        }
    }

    private static void trackStatus(List<XC_OrderItemCompliance__c> confItemListChanged){
        for(XC_OrderItemCompliance__c oic : confItemListChanged){
            if(String.isBlank(oic.XC_FirstKOReason__c)){
                oic.XC_FirstKOReason__c = oic.XC_KoReason__c;
            }
            if(String.isBlank(oic.XC_FirstRecoveryResponsible__c)){
                oic.XC_FirstRecoveryResponsible__c = oic.XC_RecoveryResponsible__c;
            }
        }
    }
    private static Map<String, String> getCountryByOrderItemCompliance(Set<String> listIdsOrderItemCompliance) {
        List<XC_OrderItemCompliance__c> listOrderItemCompliance = new List<XC_OrderItemCompliance__c>([SELECT Id, XC_Case__r.Country__c FROM XC_OrderItemCompliance__c WHERE Id IN :listIdsOrderItemCompliance]);
        Map<String, String> mapCountry = new Map<String, String>();
        for(XC_OrderItemCompliance__c orderItem: listOrderItemCompliance) {
            mapCountry.put(orderItem.Id, orderItem.XC_Case__r.Country__c);
        }
        return mapCountry;
    }
	

}