/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 07/05/2019
* @description XC_UTIL_Trigger – Util class for Trigger methods
*/ 

public class XC_UTIL_Trigger{

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Trigger');
    public static Boolean stopTriggerInTestClass = false;

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to check and populate mapNew
     * @param operationType - System.TriggerOperation
     * @param mapNewS -  Map<Id, SObject>
     * @param mapEventRecordsToBeReProcessed - Map<System.TriggerOperation, Map<String, Object>>
     * @return Map<Id, SObject> 
    */ 
    public static Map<Id, SObject> checkMapNew(System.TriggerOperation operationType, Map<Id, SObject> mapNewS, Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed) {
        if(mapEventRecordsToBeReProcessed.containsKey(Trigger.operationType) && !mapEventRecordsToBeReProcessed.get(Trigger.operationType).isEmpty()){
            mapNewS = XC_UTIL_Trigger.filterMapNew(mapNewS, mapEventRecordsToBeReProcessed.get(Trigger.operationType));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapNewS ' + mapNewS );
        } 
        return mapNewS;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to filter mapNew by considering only records of mapRecordsToBeReProcessed
     * @param mapNew - map Id -> new value of record
     * @param mapRecordsToBeReProcessed - map Id -> record
     * @return the filtered map
    */
    public static Map<Id, SObject> filterMapNew(Map<Id, SObject> mapNew, Map<String, Object> mapRecordsToBeReProcessed){
        Map<Id, SObject> filteredMap = new Map<Id, SObject>();
        for(String key : mapRecordsToBeReProcessed.keySet()){
            if(mapNew.containsKey(key)){
                filteredMap.put(key, mapNew.get(key));
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'filteredMap ' + filteredMap ); 
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'filteredMap ' + filteredMap ); 
        return filteredMap;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @param operationType - TriggerOperation
     * @param mapTriggerStopped - Map (TriggerOperation -> Boolean)
     * @param mapEventRecordsToBeReProcessed - Map(TriggerOperation -> Map<String, Object>)
     * @return Boolean true if recursion must be stopped
    */ 
    public static Boolean stopRecursion(System.TriggerOperation operationType, Map<System.TriggerOperation, Boolean> mapTriggerStopped, Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed) {
        if(!Test.isRunningTest() && Trigger.isUpdate && mapTriggerStopped.containsKey(operationType) && mapTriggerStopped.get(operationType)){
            if(mapEventRecordsToBeReProcessed.containsKey(operationType) && !mapEventRecordsToBeReProcessed.get(operationType).isEmpty()){ 
                return false;  
            }
            System.debug('TR-> Trigger event ' + operationType + ' recursion stopped'); 
            return true; 
        } else if(Test.isRunningTest() && stopTriggerInTestClass && mapTriggerStopped.containsKey(operationType) && mapTriggerStopped.get(operationType)){
            return true; 
        }
        return false;
    }

}