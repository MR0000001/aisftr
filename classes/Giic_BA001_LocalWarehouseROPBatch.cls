/**
* @author Shubee Tyagi Shubee.Tyagi@in.fujitsu.comhttps://enelx-ci--exdev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
* @date Creation 10/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_BA001_LocalWarehouseROPBatch – Batch to maintain the quantity for local warehouse
*/
public class Giic_BA001_LocalWarehouseROPBatch implements Database.batchable<Sobject>,Schedulable {
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA001_LocalWarehouseROPBatch');
    public String query;
       /**
      * @author Name : Shubee Tyagi Shubee.Tyagi@in.fujitsu.com
      * @date 10/07/2019
      * @description This is a constructor use to create dynamic query.
      */
     public Giic_BA001_LocalWarehouseROPBatch(){     
        query='SELECT gii__Product__c, giic_LegalEntity__c, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EndDate__c,gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c, gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c, gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c,gii__Warehouse__r.gii__WareHouseCountry__c, gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c  FROM gii__ProductInventory__c WHERE gii__Warehouse__r.giic_WarehouseType__c=\''+System.Label.giic_WarehouseTypeLocal+'\' AND gii__Product__r.gii__PlanningPolicy__c=\''+System.Label.giic_PlanningPolicy+'\' AND gii__OrderPointQuantity__c!=null AND gii__OrderPointQuantity__c!=0 AND gii__Warehouse__r.gii__Account__c!=NULL ';
     } 
     /**
     * @author Shubee Tyagi -  Shubee.Tyagi@in.fujitsu.com
     * @date 10/07/2019
     * @description retrieve the record based on query 
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator queryLocator records to the execute method
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    } 
    /**
    * @author Name : Shubee Tyagi Shubee.Tyagi@in.fujitsu.com
    * @date 10/07/2019
    * @description This a execute method : This method used for process on records which are comming from start method.
    * @param bc Database.BatchableContext
    * @param piList List<gii__ProductInventory__c> product inventory list
    */
    public void execute(Database.BatchableContext bc, List<gii__ProductInventory__c> piList){
        if(!Test.isRunningTest()) {
            giic_TransferOrderUtility.runROPForLocalWarehouse(piList);
        }
    } 
    /**
    * @author Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
    * @date 10/07/2019
    * @description This a Finish method : This method ise for run the last process, its execute once in all process
    * @param bc Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Finish method gets execute.');
    }    
     /**
    * @author Name : Shubee Tyagi Shubee.Tyagi@in.fujitsu.com
    * @date 10/07/2019
    * @description this method will be used for scheduling this batch class
    * @param ctx SchedulableContext
    */
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA001_LocalWarehouseROPBatch(), 200);
    }
}