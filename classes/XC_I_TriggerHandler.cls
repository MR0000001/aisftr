/**
* @author Francesco Gargiulo - fgargiulo@deloitte.it
* @date Creation 05/04/2019
* @date Modification 
* @description XC_I_TriggerHandler - Interface for Trigger Handlers
*/

public interface XC_I_TriggerHandler {
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface method to stop recursion  
     * @return Boolean 
    */

    Boolean stopRecursion();
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface method to set Trigger as executed 
    */

    void executedTrigger();

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for before insert
     * @param listNew - list of new values of records
    */
    
    void onBeforeInsert(List<SObject> listNew);
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for before update
     * @param mapOld - map Id -> old value of record* 
     * @param mapNew - map Id -> new value of record
    */

    void onBeforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew);
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for before delete
     * @param mapOld - map Id -> old value of record
    */

    void onBeforeDelete(Map<Id, SObject> mapOld);
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for after insert
     * @param mapNew - map Id -> new value of record
    */

    void onAfterInsert(Map<Id, SObject> mapNew);

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for after update
     * @param mapOld - map Id -> old value of record* 
     * @param mapNew - map Id -> new value of record
    */
    
    void onAfterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew);
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for after delete
     * @param mapOld - map Id -> old value of record
    */    
    
    void onAfterDelete(Map<Id, SObject> mapOld);
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Interface Method for after undelete
     * @param mapOld - map Id -> old value of record
    */

    void onAfterUndelete(Map<Id, SObject> mapOld);    
}