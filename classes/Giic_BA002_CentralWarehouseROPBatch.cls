/**
* @author FirstName : Anil Giri
* @date Creation 10/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_BA002_CentralWarehouseROPBatch – This is a batch used to created purchase order from Product inventory.
*/
public class  Giic_BA002_CentralWarehouseROPBatch implements Database.Batchable<sObject>,Schedulable{
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA002_CentralWarehouseROPBatch');
    
    public String strQuery;
    /**
    * @author Name : Anil Giri anil.giri@in.fujitsu.com
    * @date 10/07/2019
    * @description This is a constructor use to create dynamic query.
    */
    public Giic_BA002_CentralWarehouseROPBatch(){
        string strPlanningPolicy = system.Label.giic_PlanningPolicy;//'Reorder Point';
        string strWhType = system.Label.giic_WarehouseTypeCentral;//'Central';
       	strQuery = 'select id,gii__Product__r.gii__ProductCode__c,gii__Product__r.giic_EndDate__c,gii__Product__c,gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,gii__OrderQuantityMultiple__c,gii__Product__r.gii__PrimarySupplier__c,gii__Product__r.gii__PlanningPolicy__c,gii__Warehouse__c,gii__Warehouse__r.name,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__OrderPointQuantity__c,gii__AvailableQuantity__c,giic_AvailableQty__c from gii__ProductInventory__c where gii__Product__r.gii__PlanningPolicy__c=\''+strPlanningPolicy+'\'  and gii__Warehouse__r.giic_WarehouseType__c=\''+strWhType+'\' and gii__OrderPointQuantity__c<>null and gii__OrderPointQuantity__c!=0';
        //strQuery +=' and id in (\'a7L9E00000064gP\',\'a7L9E00000064fq\') ';
    }
    
    /**
    * @author Name : Anil Giri anil.giri@in.fujitsu.com
    * @date 10/07/2019
    * @description This a start method : retrieve the record based on query .
    * @param bc Database.BatchableContext
    * @return Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'strQuery:::'+strQuery);
        return Database.getQueryLocator(strQuery);
    }              
    /**
    * @author Name : Anil Giri anil.giri@in.fujitsu.com
    * @date 10/07/2019
    * @description This a execute method : This method used for process on records which are comming from start method.
    * @param bc Database.BatchableContext
    * @param lstPI product inventory list
    */
    public void execute(Database.BatchableContext bc, List<gii__ProductInventory__c> lstPI){
        giic_PurchaseOrderUtility.runROPForCentralWarehouse(lstPI);  
    }
    /**
    * @author Name : Anil Giri anil.giri@in.fujitsu.com
    * @date 10/07/2019
    * @description This a Finish method : This method ise for run the last process, its execute once in all process
    * @param bc Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Finish method gets execute.');
    }
    /**
    * @author Name :  Anil Giri anil.giri@in.fujitsu.com
    * @date 10/07/2019
    * @description : This method will be used for scheduling this batch class
    * @param ctx SchedulableContext 
    */
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA002_CentralWarehouseROPBatch(), 200);
    }
      
}