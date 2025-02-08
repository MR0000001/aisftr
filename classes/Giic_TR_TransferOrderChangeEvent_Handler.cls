/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TR_TransferOrderChangeEvent_Handler – Handler for Change Event Trigger for INtegration User Stories.
*/
public class Giic_TR_TransferOrderChangeEvent_Handler {
    /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com 
* @date Creation 03/07/2019
* @description method for sending a Purchase Order to SAP Procurement System
* @param lstTOChangeEvent list<gii__TransferOrder__ChangeEvent>
*/	
    public static Void getReadyToIntegrateReceipt(List<gii__TransferOrder__ChangeEvent> lstTOChangeEvent){
        list<Id> lstPOIds=new list<Id>();
        for(gii__TransferOrder__ChangeEvent event : lstTOChangeEvent) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            lstPOIds.addall(header.recordIds);
        }
        map<Id,gii__TransferOrder__C> mapTransferOrders=new map<Id,gii__TransferOrder__C>([select id,giic_TargetSystem__c,gii__FromWarehouse__r.Giic_Is3PLWarehouse__c,giic_IntegrationOperation__c,giic_Approved__c from gii__TransferOrder__C where id in :lstPOIds]);
        for (gii__TransferOrder__ChangeEvent event : lstTOChangeEvent) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if (header.changetype == 'UPDATE' ){
                if(event.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate
                   && mapTransferOrders.get(header.recordIds[0]).giic_TargetSystem__c==System.Label.giic_TargetSystem3PL
                   && mapTransferOrders.get(header.recordIds[0]).giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate
                   && mapTransferOrders.get(header.recordIds[0]).gii__FromWarehouse__r.Giic_Is3PLWarehouse__c==true
                    && mapTransferOrders.get(header.recordIds[0]).giic_Approved__c == true ){ 
                       for(Id recordId:header.recordIds){
                          // XC_REST_TransferOrder.sendCreateTransferOrder3PL(recordId);
                       }
                   }
            } 
        }
    }
    
}