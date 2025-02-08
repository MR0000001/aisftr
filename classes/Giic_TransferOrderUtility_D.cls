/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderUtility_D – Util for Transfer Order Query.
*/
public without sharing class Giic_TransferOrderUtility_D {
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TransferOrderUtility_D');
/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification dd/mm/yyyy
* @description Method for select fields from Transfer Order
* @param setFields - List<Id>
* @return listResult - List<gii__TransferOrderLine__c>
*/
    public static List<gii__TransferOrderLine__c> getTransferOrderLineList(List<Id> toIdList){
        List<gii__TransferOrderLine__c> tolRevisedList= new List<gii__TransferOrderLine__c>();
        //system.debug('giic_SalesOrderLine__r.gii__SalesOrder__r.giic_FSLWorkOrder__c>>>'+giic_SalesOrderLine__r.gii__SalesOrder__r.giic_FSLWorkOrder__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'toIdList>>>>'+toIdList);
        if(Schema.sObjectType.gii__TransferOrderLine__c.isQueryable()){
            tolRevisedList=[SELECT Id,gii__TransferOrder__r.giic_NewDeliveryDate__c, gii__TransferOrder__c,
                                                        gii__TransferOrder__r.gii__ShipToCountry__c,
                                                        gii__TransferOrder__r.gii__FromWarehouse__c,
                                                        giic_SalesOrderLine__r.gii__SalesOrder__c, 
                                                        gii__TransferOrder__r.giic_LegalEntity__c,
                            							gii__TransferOrder__r.giic_SalesOrder__c,
                                                        giic_SalesOrderLine__r.gii__SalesOrder__r.giic_FSLWorkOrder__c,
                                                        giic_SalesOrderLine__r.gii__SalesOrder__r.giic_IsDelivery__c,
                            							gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber
                                                        FROM gii__TransferOrderLine__c
                                                        WHERE 
                                                        gii__TransferOrder__c IN:toIdList];// AND giic_SalesOrderLine__r.gii__SalesOrder__r.giic_FSLWorkOrder__c != null AND giic_SalesOrderLine__c != null and 
        }
        System.debug('TOL IN DAO '+tolRevisedList);
       XC_UTIL_Debug.debug(DEBUGACTIVE,'tolRevisedList>>>>>'+tolRevisedList);
        return tolRevisedList;
    } 
    
/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification dd/mm/yyyy
* @description Method for select fields from Service Appointment
* @param setFields - Set<Id>
* @return listResult - List<ServiceAppointment>
*/ 
    public static List<ServiceAppointment> getServiceAppoinmentList(Set<string> woNumbers){
        List<ServiceAppointment> sapList = new List<ServiceAppointment>();
          if(Schema.sObjectType.ServiceAppointment.isQueryable()){
            sapList=[Select Id, ParentRecordId,ParentRecord.Name, SchedStartTime, Status 
                                          FROM ServiceAppointment WHERE ParentRecord.Name IN:woNumbers 
                                       ]; //    AND (Status=:System.Label.giic_SAScheduledStatus OR Status=:System.Label.giic_SADispatchedStatus OR Status=:System.Label.giic_SANewStatus)
          }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'sapList>>>>>'+sapList);
        return sapList;
    }

/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 13/11/2019
* @date Modification dd/mm/yyyy
* @description Method for retrieve default pricebook entry
* @param setProductIds - product id set
* @param setSupplierIds - supplier id set
* @return List<gii__PriceBookEntry__c> price book entry list
*/
 public static List<gii__PriceBookEntry__c> getPriceBookEntries(set<Id> setProductIds,set<Id> setSupplierIds){
        List<gii__PriceBookEntry__c> lstPB= new List<gii__PriceBookEntry__c>();
           if(Schema.sObjectType.gii__PriceBookEntry__c.isQueryable()){
   lstPB=  [SELECT Id,name,giic_Default__c,gii__Product__c,gii__Product__r.gii__PrimarySupplier__c,gii__Product__r.name,gii__PriceBook__c,gii__PriceBook__r.name,
                                              gii__PriceBook__r.giic_Contract__c,gii__PriceBook__r.giic_Contract__r.AccountId,gii__PriceBook__r.giic_Contract__r.Status,
                                              gii__PriceBook__r.giic_Contract__r.EndDate 
                                              FROM gii__PriceBookEntry__c 
                                              WHERE gii__Product__c IN:setProductIds 
                                              AND gii__PriceBook__r.giic_Contract__r.AccountId<>null AND gii__PriceBook__r.giic_Contract__r.AccountId IN : setSupplierIds 
                                              AND gii__PriceBook__r.giic_Contract__r.StartDate <= :system.today() AND  gii__PriceBook__r.giic_Contract__r.EndDate >= :system.today() 
                                              AND giic_Default__c = true];
 }
        return lstPB; 
}   
    
/**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation 10/12/2020
* @date Modification dd/mm/yyyy
* @description Method for retrieve all tol from to
* @param toIdList - tol id list
* @return List<gii__TransferOrderLine__c> tolList tol list
*/

public static List<gii__TransferOrderLine__c> getTransferOrderLine(List<Id> toIdList){
    List<gii__TransferOrderLine__c> tolList= new List<gii__TransferOrderLine__c>();
    XC_UTIL_Debug.debug(DEBUGACTIVE,'toIdList>>>>'+toIdList);
    if(Schema.sObjectType.gii__TransferOrderLine__c.isQueryable()){
        tolList=[SELECT Id,gii__TransferOrder__c,gii__TransferOrder__r.gii__FromWarehouse__c,
                gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,
                gii__Product__c,gii__Warehouse__c,gii__Quantity__c,gii__TransferOrder__r.giic_Source__c, gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c
                FROM gii__TransferOrderLine__c WHERE gii__TransferOrder__c IN:toIdList ALL ROWS]; 
    }
    system.debug('toIdList: '+ toIdList);
    system.debug('tolList: '+ tolList);
   XC_UTIL_Debug.debug(DEBUGACTIVE,'tolList>>>>>'+tolList);
    return tolList;    
}
}