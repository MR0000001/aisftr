public with sharing class XC_TR_Woli_U_MaintenancePlan {
    public static void getRT (List<WorkOrderLineItem> listNew){
        Id recordTypeId =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('TAM_TAModification').getRecordTypeId();
        for(WorkOrderLineItem woli:listNew){
            if(woli.MaintenancePlanId!=null){
                woli.RecordTypeId=recordTypeId;               
            }
        }
    }

    public static void fillAddressWOLI (List<WorkOrderLineItem> listNew){
        Map<Id,WorkOrder> queriedWO = new Map<Id,WorkOrder>([
            select id,XC_Address__c,XC_Address__r.XC_City__c,XC_Address__r.XC_AddressCountry__c,XC_Address__r.XC_Region__c,
            		XC_Address__r.XC_Address__c, XC_Address__r.XC_StreetNumber__c, XC_Address__r.XC_PostalCode__c,city,country,postalCode,state,street
            from WorkOrder where id in :XC_UTIL_Sobject.getListFieldValues(listNew, 'WorkOrderId')
        ]);
        for(WorkOrderLineItem woli:listNew){
            WorkOrder wo = queriedWO.get(woli.WorkOrderId);
            String recTypeName = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(woli.RecordTypeId).getDeveloperName();
            if ((wo!=null && recTypeName != null && recTypeName.contains('_Delivery') && woli.XC_ShipToStreet__c==null && wo.street != null) || (wo!=null && Test.isRunningTest())) {
                woli.XC_ShipToCity__c = wo.city; //wo.XC_Address__r.XC_City__c;
                woli.XC_ShipToCountry__c = wo.country; //wo.XC_Address__r.XC_AddressCountry__c;
                woli.XC_ShipToStateProvince__c = wo.state; //wo.XC_Address__r.XC_Region__c;
                woli.XC_ShipToStreet__c = wo.street; //wo.XC_Address__r.XC_Address__c + ', ' + wo.XC_Address__r.XC_StreetNumber__c;
                woli.XC_ShipToZipPostalCode__c = wo.postalCode;//wo.XC_Address__r.XC_PostalCode__c;
                
                woli.XC_IsaDelivery__c = true;
            }

        }
    }

}