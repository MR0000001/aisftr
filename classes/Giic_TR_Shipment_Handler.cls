/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 14/11/2019
* @date Modification dd/mm/yyyy
* @description Giic_TR_Shipment.
*/ 
public class Giic_TR_Shipment_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_Shipment_Handler');
      /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In stopRecursion');
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        
    }
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In executedTrigger');
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<gii__Shipment__c> listNew){ 
          XC_UTIL_Debug.debug(DEBUGACTIVE,'In onBeforeInsert');
      	  for(gii__Shipment__c Ship : listNew){
        	    if(Ship.giic_IntegrationStatus__c == null && Ship.gii__TransferOrder__c!=null){
            	    Ship.giic_IntegrationStatus__c = System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                	Ship.giic_IntegrationOperation__c = System.Label.giic_IntegrationOperationCreate;
            	} 
        	} 
    }
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
       XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
       
    }
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
         List<Id> shipId=new List<Id>();
         for(gii__Shipment__c objSHPDet : (list<gii__Shipment__c>)mapOld.values()){ shipId.add(objSHPDet.Id); }
         if(shipId.size()>0){ Giic_IntegrationUtility.createShipmentStaging(shipId); }
    }
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
		Map<Id, gii__Shipment__c > mapNew = (Map<Id, gii__Shipment__c >) mapNewS;
		List<gii__Shipment__c > listNew = mapNew.values();

        for(gii__Shipment__c Ship : listNew){
            if( Ship.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate &&
               Ship.giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate &&
               Ship.gii__TransferOrder__c!=null  ){  
                  XC_REST_GoodIssueTO.callSendCreateGoodIssue4PL(Ship.Id); 
              }   
        }
           
    }
    /**
     * @authorRoberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
   public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        Map<Id, gii__Shipment__c > mapOld = (Map<Id, gii__Shipment__c >) mapOldS; 
        Map<Id, gii__Shipment__c > mapNew = (Map<Id, gii__Shipment__c >) mapNewS;
        List<gii__Shipment__c > listNew = mapNew.values();
        Giic_TR_Shipment_UTIL.checkIfDeliveryChange(listNew,mapOld,mapNew);
    }
 
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
       
    } 

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        
    }

}