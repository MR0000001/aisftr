public without sharing class Giic_TR_POReceipt_UTIL {
    
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_POReceipt_UTIL');
    
     public static void checkIfDeliveryChange(List<gii__PurchaseOrderReceipt__c > listNew, Map<Id, gii__PurchaseOrderReceipt__c > mapOld ,  Map<Id, gii__PurchaseOrderReceipt__c > mapNew){
      
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkIfDeliveryChange');
        List<String> fieldToCheck = new List<String> {'giic_DeliveryDate__c','giic_DeliveryDocumentID__c'};
	    listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        Set<Id> porIds = XC_UTIL_Sobject.getSetIds(listNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In porIds' + porIds);
        rebaltOnWo(porIds);
 
    }
    
    public static void rebaltOnWo(Set<Id> porIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In rebaltOnWo');
        List<Workorder> woToUpdate = new List<Workorder>(); 
        List<WorkOrderLineItem> woliToUpdate = new List<WorkOrderLineItem>(); 
        map<Id,gii__PurchaseOrderReceipt__c> porMap = new  map<Id,gii__PurchaseOrderReceipt__c>([SELECT Id, giic_DeliveryDate__c, giic_DeliveryDocumentID__c,gii__PurchaseOrder__c, gii__PurchaseOrder__r.gii__SalesOrder__c,
                                                                                                 gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrder__c, gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c,
                                                                                                 gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrder__r.XC_WorkTypeCategory__c,gii__PurchaseOrder__r.gii__SalesOrder__r.giic_IsDelivery__c
                                                                                                 FROM gii__PurchaseOrderReceipt__c
                                                                                                 WHERE Id IN: porIds 
                                                                                                 ]);
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In porMap');
        if(!porMap.values().isEmpty()){
            for(gii__PurchaseOrderReceipt__c por : porMap.values()){
                if(por.gii__PurchaseOrder__r.gii__SalesOrder__c!=null && por.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrder__c!=null){
                    if(por.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c!=null){  // B2B CASE
                        //NR2122if(por.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_IsDelivery__c){
                        	WorkOrderLineItem woli = new WorkOrderLineItem(Id = por.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c,  XC_DeliveryId__c=por.giic_DeliveryDocumentID__c,   XC_EffectiveDeliveryDate__c=por.giic_DeliveryDate__c);
                        	woliToUpdate.add(woli); 
                        //NR2122}
                    }else{ // B2C CASE
                        Workorder wo = new Workorder(Id=por.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrder__c,  XC_DeliveryId__c=por.giic_DeliveryDocumentID__c,  XC_EffectiveDeliveryDate__c=por.giic_DeliveryDate__c);
                        woToUpdate.add(wo);
                    }
                }
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In woToUpdate'+woToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In woliToUpdate' +woliToUpdate);
        XC_UTIL_SObject.updateListRecords(woToUpdate);
        XC_UTIL_SObject.updateListRecords(woliToUpdate);
        
    }
    
     public static void sendPoReceiptForApprovalInUpdate(List<gii__PurchaseOrderReceipt__c> listNew,Map<Id, gii__PurchaseOrderReceipt__c > mapOld,Map<Id, gii__PurchaseOrderReceipt__c > mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'sendPoReceiptForApprovalInUpdate');
         List<String> fieldList = new List<String>{'giic_DeliveryDate__c','giic_DeliveryDocumentID__c'};
        List<gii__PurchaseOrderReceipt__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);         
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In sendPoReceiptForApprovalInUpdate');
        sendPoReceiptForApproval(listChanged);
        
    }
    
    
    
    public static void sendPoReceiptForApproval(List<gii__PurchaseOrderReceipt__c> listNew ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In sendPoReceiptForApproval');

        /* NR2626 ex NR2246* */
        Boolean isActiveNR2626 = false;
        List<giic_enable_NR2246__c> listCS = giic_enable_NR2246__c.getAll().values();
        if(listCS !=null && !listCS.isEmpty()){
            for(gii__PurchaseOrderReceipt__c por : listNew){
                for(giic_enable_NR2246__c cs : listCS){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'porLegalEntity: ' + por.giic_LegalEntity__c);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'csLegalEntity: ' + cs.LegalEntity__c);
                    if(por.giic_LegalEntity__c == cs.LegalEntity__c){
                        isActiveNR2626 = true;
                        break;
                    }
                }
            }
        }

        if(isActiveNR2626 == true){
            return;
        }

        for(gii__PurchaseOrderReceipt__c por : listNew){
            if(por.giic_Status__c=='New' && por.giic_DeliveryDate__c!=null && por.giic_DeliveryDocumentID__c!=null && por.giic_LegalEntity__c != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'DENTRO IF');
                System.debug('LE = '+por.giic_LegalEntity__c);
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Purchase Order Receipt submitted for approval. Please approve.');
                req.setObjectId(por.Id);
               // List<Id> approvers = new List<Id>();
                //approvers.add(Id.valueOf('0050D000002uJlgQAE'));
                //req.setNextApproverIds(approvers);
                // submit the approval request for processing
                Approval.ProcessResult result = Approval.process(req);
                // display if the reqeust was successful
                System.debug('Submitted for approval successfully: '+result.isSuccess());
            }
        }
        
    }
    
    /** NR2626*/
    public static Boolean checkSendGoodReceiptSAP(gii__PurchaseOrderReceipt__c por){

        Boolean isActiveNR2626 = false;
        List<giic_enable_NR2246__c> listCS = giic_enable_NR2246__c.getAll().values();
        if(listCS !=null && !listCS.isEmpty()){
                for(giic_enable_NR2246__c cs : listCS){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'porLegalEntity: ' + por.giic_LegalEntity__c);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'csLegalEntity: ' + cs.LegalEntity__c);
                    if(por.giic_LegalEntity__c == cs.LegalEntity__c){isActiveNR2626 = true; break; }
                }
        }

        return isActiveNR2626;


    }

    /** 2626  */
    public static void checkIftoSetApprove(List<gii__PurchaseOrderReceipt__c> porList){

        String legalEntity;

        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(porList, 'gii__PurchaseOrder__c');
        map<Id,gii__PurchaseOrder__c> p2Maps = new  map<Id,gii__PurchaseOrder__c> ([SELECT Id, giic_LegalEntity__c FROM gii__PurchaseOrder__c WHERE Id IN: poIds ]);
        System.debug('p2Maps = '+p2Maps.values());
        for(gii__PurchaseOrderReceipt__c por : porList){   
             for(gii__PurchaseOrder__c w : p2Maps.values()){
                 if(por.gii__PurchaseOrder__c == w.Id && w.giic_LegalEntity__c != null){
                    	legalEntity = w.giic_LegalEntity__c; 
                 }
             }
            
        }

        Boolean isActiveNR2626 = false;
        List<giic_enable_NR2246__c> listCS = giic_enable_NR2246__c.getAll().values();
        if(listCS !=null && !listCS.isEmpty()){
                for(giic_enable_NR2246__c cs : listCS){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'csLegalEntity: ' + cs.LegalEntity__c);
                    if(legalEntity != null && legalEntity != '' && legalEntity == cs.LegalEntity__c){isActiveNR2626 = true; break; }
                }
        }

        if(isActiveNR2626){
            for(gii__PurchaseOrderReceipt__c pr : porList){
                pr.giic_Status__c = 'Approved';
                pr.giic_ApprovedDate__c = System.today(); //fix INC000091382636
            }
        }
    }
   
    /** 2626, rendere i campi read only per enel Sole  */

    public static void preventUpateQualityFields(List<gii__PurchaseOrderReceipt__c> purchaseOrderReceiptList, Map<Id, gii__PurchaseOrderReceipt__c> MapOld, Map<Id, gii__PurchaseOrderReceipt__c> MapNew){

        List<String> poIds = XC_Util_Sobject.getListFieldValues(purchaseOrderReceiptList, 'Id');
        //List<gii__PurchaseOrderReceipt__c> newPORList = new List<gii__PurchaseOrderReceipt__c>([select id, giic_NoteQualityCheck__c, giic_QualityCheckKONOEMFlag__c, XC_Quality_Check__c, giic_MaterialReceiptDate__c, gii__ReceiptDate__c from gii__PurchaseOrderReceipt__c]);
        List<giic_enable_NR2246__c> cs2246 = giic_enable_NR2246__c.getAll().values();

        List<Profile> profileName = [SELECT id, name FROM Profile WHERE id = :UserInfo.getProfileId()];
        

        for(gii__purchaseOrderReceipt__c por : MapNew.values()){
            for(giic_enable_NR2246__c cs : cs2246){
                for(Profile p : profileName){
        
                    if(cs.LegalEntity__c == por.giic_legalEntity__c && p.Name != 'System Administrator'){

                        if(mapNew.get(por.Id).giic_NoteQualityCheck__c != mapOld.get(por.Id).giic_NoteQualityCheck__c || mapNew.get(por.Id).giic_QualityCheckKONOEMFlag__c != mapOld.get(por.Id).giic_QualityCheckKONOEMFlag__c || mapNew.get(por.Id).XC_Quality_Check__c != mapOld.get(por.Id).XC_Quality_Check__c || mapNew.get(por.Id).giic_MaterialReceiptDate__c != mapOld.get(por.Id).giic_MaterialReceiptDate__c || mapNew.get(por.Id).gii__ReceiptDate__c != mapOld.get(por.Id).gii__ReceiptDate__c ){
                        
                            por.addError('You Can not edit the field');
                        }
                    }
                }
            }
        }
    }
}