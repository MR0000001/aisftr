/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_PurchaseOrderUtility_D – Util for Purchase Order Query.
*/
public without sharing class Giic_PurchaseOrderUtility_D {
/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification dd/mm/yyyy
* @description Method for select fields from Purchase Order and Purchase Order Line
* @param setFields - List<Id>
* @return listResult - List<gii__PurchaseOrderLine__c>
*/ 
 /*   public static List<gii__PurchaseOrderLine__c> getPurchaseOrderLineList(List<Id> poIdList){
         List<gii__PurchaseOrderLine__c> polRevisedList = new List<gii__PurchaseOrderLine__c>();
         if(Schema.sObjectType.gii__PurchaseOrderLine__c.isQueryable()){
            system.debug('poIdList>>>>>>'+poIdList);
            polRevisedList = [SELECT Id,gii__SalesOrder__c,giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__c, gii__PurchaseOrder__r.giic_NewDeliveryDate__c, gii__PurchaseOrder__c,
                              giic_SalesOrderLine__r.gii__SalesOrder__c, giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__r.WorkType.Name, 
                              giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__r.AccountId, giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__r.ContactId  
                              FROM gii__PurchaseOrderLine__c
                              WHERE giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__r.WorkType.Name=:System.Label.giic_WorkTypeName AND 
                              gii__PurchaseOrder__c IN:poIdList];
        }
        return polRevisedList;
    }*/
/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification dd/mm/yyyy
* @description Method for select fields from Service Appointment
* @param setFields - Set<Id>
* @return listResult - List<ServiceAppointment>
*/ 
   /* public static List<ServiceAppointment> getServiceAppoinmentList(Set<Id> woIds){
        List<ServiceAppointment> sapList = new List<ServiceAppointment>();
        if(Schema.sObjectType.ServiceAppointment.isQueryable()){
            sapList = [Select Id, ParentRecordId, SchedStartTime, Status 
                       FROM ServiceAppointment WHERE ParentRecordId IN:woIds 
                       AND (Status=:System.Label.giic_SAScheduledStatus OR Status=:System.Label.giic_SADispatchedStatus OR Status=:System.Label.giic_SANewStatus)];
        }
        return sapList;
    }*/
    /**
    * @author FirstName :Pradeep Kumar
    * @date Creation 05/07/2019
    * @date Modification 13/11/2019 sara.miozza@nttdata.com 
    * @description return default pricebook entries
    * @param setProductIds - product id set
    * @param setSupplierIds - supplier id set
    * @return List<gii__PriceBookEntry__c> price book entry list
*/
    public static List<gii__PriceBookEntry__c> getPriceBookEntries(set<Id> setProductIds,set<Id> setSupplierIds){
        List< gii__PriceBookEntry__c> listPBE = new List<gii__PriceBookEntry__c>();
        List<gii__PriceBookEntry__c> lstPB= new List<gii__PriceBookEntry__c>( [select id,name,gii__Product__c,giic_Default__c,gii__Product__r.gii__PrimarySupplier__c,gii__Product__r.name,gii__PriceBook__c,gii__PriceBook__r.name,
                                                                               gii__PriceBook__r.giic_Contract__c,gii__PriceBook__r.giic_Contract__r.AccountId,gii__PriceBook__r.giic_Contract__r.Status,
                                                                               gii__PriceBook__r.giic_Contract__r.StartDate, gii__PriceBook__r.giic_Contract__r.EndDate , gii__PriceBook__r.giic_Contract__r.XC_Type__c, giic_MinimumOrderQuantity__c
                                                                               FROM gii__PriceBookEntry__c
                                                                               WHERE gii__Product__c IN:setProductIds 
                                                                               AND gii__PriceBook__r.giic_Contract__r.AccountId <> null 
                                                                               AND gii__PriceBook__r.giic_Contract__r.AccountId in : setSupplierIds 
                                                                               AND gii__PriceBook__r.giic_Contract__r.StartDate <= :system.today() 
                                                                               AND  gii__PriceBook__r.giic_Contract__r.EndDate >= :system.today() 
                                                                               AND giic_Default__c = true
                                                                               ]);
        if(lstPB.isEmpty()){ return listPBE;}
        for(gii__PriceBookEntry__c pbe : lstPB){
            if(pbe.gii__PriceBook__r.giic_Contract__r.XC_Type__c == null ||( pbe.gii__PriceBook__r.giic_Contract__r.XC_Type__c != null && pbe.gii__PriceBook__r.giic_Contract__r.XC_Type__c.substring(0,3) != 'ZCC' )){    
                listPBE.add(pbe);
            }
        }
        
        return listPBE;
    }
}