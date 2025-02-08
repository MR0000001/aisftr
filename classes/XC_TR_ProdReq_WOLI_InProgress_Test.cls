/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 21/12/2020
* @description  – XC_TR_ProductRequired_WOLI_InProgress -  
*/ 
@istest(SeeAllData=false)
public class XC_TR_ProdReq_WOLI_InProgress_Test {
    static testMethod void setInProgressWOLI(){
     insert XC_DF_OneOrg.createOneOrg('Spain');
     //WorkOrder
        List<WorkOrder> createWorkOrders=XC_DF_WorkOrder.createWorkOrders(1,'Installation');
        insert createWorkOrders;
        //Work Order Line Item
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= createWorkOrders[0].Id;
        woli.XC_WOLIType__c='Partner Engagement';
         Id rtIdwoli =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
         woli.RecordTypeId=rtIdwoli;      
        system.debug('woliRt'+' '+woli.RecordTypeId);
        insert woli;
      //product2
       Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain'
        );
      insert p2;
     //ProductRequired
     Id rtIdProdReq =Schema.SObjectType.ProductRequired.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_PartnerEngagement').getRecordTypeId();
  /* ProductRequired pr = new ProductRequired(
            ParentRecordId = woli.id,
            RecordTypeId=rtIdProdReq,
            Product2Id = p2.Id,
            XC_ProcurementType__c = 'Transfer',
            QuantityRequired = 1,
            XC_Mode__c = 'Add',
            XC_ConcatenatedWBE__c = 'AAAAAAAAAAAAAAAAAA',
            XC_ConcatenatedCostCenter__c = 'AAAAAAAA'
        );
        insert pr;*/    
     productRequired pr=new productRequired();
     pr.ParentRecordId= woli.id;
     pr.Product2Id=p2.Id;
     insert pr;
    }
}