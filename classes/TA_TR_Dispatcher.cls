/**
* @author Benjamin Geronimo WR
* @date Creation 12/04/2021
* @date Modification dd/mm/yyyy
* @description XC_TR_Dispatcher - Dispatcher for generic Trigger
*/ 

public class TA_TR_Dispatcher {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('TA_TR_Dispatcher');

    /**
     * @author Benjamin Geronimo - WR 
     * @description Method to init Dispatcher of Trigger Handlers
     * @param handler Instance of the Trigger handler
     * @param triggerEvent type of Trigger event
     * @param objName string
    */

    public static void init(XC_I_TriggerHandler handler, System.TriggerOperation triggerEvent,String objName){        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### In TA_TR_Dispatcher.init ### ' );
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
}