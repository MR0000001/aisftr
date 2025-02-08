/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 25/08/2021
* @description Giic_BA013_ReprocessSalesOrder – Batch used to reprocess Sales Order
*/

public without sharing class Giic_BA013_ReprocessSalesOrder implements Database.Batchable<sObject>, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA013_ReprocessSalesOrder');

    /**
     * @description Method to schedule Batch
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new Giic_BA013_ReprocessSalesOrder(), 1);
    }  

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM gii__SalesOrder__c WHERE giic_OrderStatus__c = \'Error\'');
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Execute method for batch
     * @param bc - BatchableContext
     * @param scope - List<> 
    */
    public void execute(Database.BatchableContext bc, List<gii__SalesOrder__c> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch BA013');
        for(gii__SalesOrder__c so : scope) {
            Giic_SalesOrderUtility.reprocessOrder(so.Id);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End execute method batch BA013');
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch Giic_BA013_ReprocessSalesOrder'); 
    } 

}