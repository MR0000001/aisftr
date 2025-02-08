/**
* @author Francesco Gargiulo - frgargiulo@deloitte.it
* @date Creation 05/04/2019
* @date Modification 05/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Dispatcher - Dispatcher for generic Trigger
*/

public class XC_TR_Dispatcher{
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Dispatcher');
    /**
     * @author Francesco Gargiulo - frgargiulo@deloitte.it 
     * @description Method to init Dispatcher of Trigger Handlers
     * @param handler Instance of the Trigger handler
     * @param triggerEvent type of Trigger event
    */

    public static void init(XC_I_TriggerHandler handler, System.TriggerOperation triggerEvent){        
    XC_UTIL_Debug.debug(DEBUGACTIVE, '### In XC_TR_Dispatcher.init ### ' );
        if(handler.stopRecursion()){ 
            return;
        }
         
        switch on triggerEvent {
            when BEFORE_INSERT {
                handler.onBeforeInsert(Trigger.new);
            } when BEFORE_UPDATE {
                handler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
            } when BEFORE_DELETE {
                handler.onBeforeDelete(Trigger.oldMap);
            } when AFTER_INSERT {
                handler.onAfterInsert(Trigger.newMap);
            } when AFTER_UPDATE {
                handler.onAfterUpdate(Trigger.oldmap, Trigger.newMap);
            } when AFTER_DELETE {
                handler.onAfterDelete(Trigger.oldMap); 
            } when AFTER_UNDELETE {
                handler.onAfterUndelete(Trigger.newMap);
            }
        }  

        handler.executedTrigger();
    }
        /**
     * @author Nicola Arrigo - narrigo@deloitte.it 
     * @description Method to init Dispatcher of Trigger Handlers
     * @param handler Instance of the Trigger handler
     * @param triggerEvent type of Trigger event
     * @param objName string
    */

    public static void init(XC_I_TriggerHandler handler, System.TriggerOperation triggerEvent,String objName){        
    XC_UTIL_Debug.debug(DEBUGACTIVE, '### In XC_TR_Dispatcher.init ### ' );
        if(handler.stopRecursion() || ( String.isNotBlank(objName) && XC_UTIL_SkipTrigger.checkObjToSKip(objName))){ 
            return;
        }
         
        switch on triggerEvent {
            when BEFORE_INSERT {
                handler.onBeforeInsert(Trigger.new);
            } when BEFORE_UPDATE {
                handler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
            } when BEFORE_DELETE {
                handler.onBeforeDelete(Trigger.oldMap);
            } when AFTER_INSERT {
                handler.onAfterInsert(Trigger.newMap);
            } when AFTER_UPDATE {
                handler.onAfterUpdate(Trigger.oldmap, Trigger.newMap);
            } when AFTER_DELETE {
                handler.onAfterDelete(Trigger.oldMap); 
            } when AFTER_UNDELETE {
                handler.onAfterUndelete(Trigger.newMap);
            }
        }  

        handler.executedTrigger();
    }

    /**
     * @author Nicola Arrigo - narrigo@deloitte.it 
     * @description Method to init Dispatcher of Trigger Handlers
     * @param handler Instance of the Trigger handler
     * @param triggerEvent type of Trigger event
     * @param objName string
    */

    public static void init(XC_I_TriggerHandler handler, System.TriggerOperation triggerEvent,String objName, String isSFMObject){        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### In XC_TR_Dispatcher.init ### ' );
            if(handler.stopRecursion() || ( String.isNotBlank(objName) && XC_UTIL_SkipTrigger.checkObjToSKip(objName))){ 
                return;
            }
             
            if(Trigger.new != null && !Trigger.new.isEmpty() && Trigger.new.get(0).get('XC_SFMTechnicalField__c') == 'SFM'){
                return;
            }
            if(Trigger.old != null && !Trigger.old.isEmpty() && Trigger.old.get(0).get('XC_SFMTechnicalField__c') == 'SFM'){
                return;
            }
            switch on triggerEvent {
                when BEFORE_INSERT {
                    handler.onBeforeInsert(Trigger.new);
                } when BEFORE_UPDATE {
                    handler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
                } when BEFORE_DELETE {
                    handler.onBeforeDelete(Trigger.oldMap);
                } when AFTER_INSERT {
                    handler.onAfterInsert(Trigger.newMap);
                } when AFTER_UPDATE {
                    handler.onAfterUpdate(Trigger.oldmap, Trigger.newMap);
                } when AFTER_DELETE {
                    handler.onAfterDelete(Trigger.oldMap); 
                } when AFTER_UNDELETE {
                    handler.onAfterUndelete(Trigger.newMap);
                }
            }  
    
            handler.executedTrigger();
        }

       /* public static Boolean skipSFMObject(List<sObject> listObj, String objectType){
            Boolean isSFMObjList = false;
            if(listObj.isEmpty()){
                return isSFMObjList;
            }
            if(listObj.get(0).get('XC_SFMTechnicalField__c')!= null){
                return true;
            }else if( listObj.get(0).get('id')== null ){
                return false;
            } else if(Schema.sObjectType.Opportunity.fields.XC_SFMTechnicalField__c.isAccessible()) {
                String recordId = String.valueOf(listObj.get(0).get('id'));
                String query = String.escapeSingleQuotes('SELECT XC_SFMTechnicalField__c FROM ' + objectType + ' WHERE id =: recordId  ');
                List<SObject> obj =  Database.query(query);
                return obj[0].get('XC_SFMTechnicalField__c')!= null;
            }else{
                return false;
            }
        } */

        /**
         * @author Andrea Di Cicco
         * @description Method to init Dispatcher of Trigger Handlers
         * @param mapObj 
         * @return map without SFM obj
        */
        public static Map<Id, Opportunity> skipSFMObject(Map<Id, SObject> mapObj){
            Map<Id, Opportunity> mapWithoutSFMObj = new Map<Id, Opportunity> ();
            Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) mapObj;
            for(Opportunity opp : mapNew.values()){
                if(opp.get('XC_SFMTechnicalField__c')== null){
                    mapWithoutSFMObj.put(opp.id,opp );
                }
            }
            return mapWithoutSFMObj;
        } 

        /**
         * @author Andrea Di Cicco
         * @description Method to init Dispatcher of Trigger Handlers
         * @param listObj 
         * @return list without SFM obj
        */
        public static List< sObject> skipSFMObject(List< sObject> listObj){
            List< sObject> listWithoutSFMObj = new List< sObject> ();
            for(sObject sObj : listObj){
                if(sObj.get('XC_SFMTechnicalField__c')== null){
                    listWithoutSFMObj.add(sObj );
                }
            }
            return listWithoutSFMObj;
        } 
}