/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TR_ReceiptQueueChangeEvent_Handler – Handler for Change Event Trigger for INtegration User Stories.
*/
public class Giic_TR_ReceiptQueueChangeEvent_Handler {
  /**
    * @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com 
    * @date Creation 03/07/2019
    * @description method for sending a Purchase Order to SAP Procurement System
    * @param lstReceiptQueueChangeEvent list<gii__ReceiptQueue__ChangeEvent>
    */	
    public static Void getReadyToIntegrateReceipt(List<gii__ReceiptQueue__ChangeEvent> lstReceiptQueueChangeEvent){
        list<Id> lstPOIds=new list<Id>();
        for(gii__ReceiptQueue__ChangeEvent event : lstReceiptQueueChangeEvent) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            lstPOIds.addall(header.recordIds);
        }
  map<Id,gii__ReceiptQueue__C> mapReceipt=new map<Id,gii__ReceiptQueue__C>([select id,giic_TargetSystem__c,giic_IntegrationOperation__c from gii__ReceiptQueue__C where id in :lstPOIds]);
 
        for(gii__ReceiptQueue__ChangeEvent event : lstReceiptQueueChangeEvent) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if (header.changetype == 'CREATE' ){
                Giic_IntegrationUtility.setReceiptQueueStatusReadytoIntegrate(header.recordIds);
            }
           
        }
        
    }
}