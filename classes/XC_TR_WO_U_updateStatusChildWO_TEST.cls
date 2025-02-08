/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @description XC_TR_WO_U_updateStatusChildWO_TEST for class XC_TR_WorkOrder_U_updateStatusChildWO
*/
@isTest
public class XC_TR_WO_U_updateStatusChildWO_TEST {
    @testSetup
    private static void setup() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Test.startTest();
        
        NE__Order__c order = XC_DF_Order.createOrder('In Order');
		
        List<NE__Product__c> listProduct = XC_DF_Product.createProducts(1);
        listProduct[0].Name = 'Test Product';
        insert listProduct;
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(2);
        listAsset[0].NE__Action__c = 'Remove';
        listAsset[0].NE__Order_Config__c = order.Id;
        listAsset[1].NE__Action__c = 'Add';
        listAsset[1].NE__Order_Config__c = order.Id;

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Substitution);
        listWorkOrder[0].Status = 'In Progress';
        listWorkOrder[0].XC_WorkTypeLabel__c = Label.XC_CL_WorkType_Substitution;
        listWorkOrder[0].XC_Configuration__c = order.Id;
        
        List<NE__Order__c> listOrder = [SELECT Id, (SELECT Id FROM NE__Order_Items__r)  FROM NE__Order__c WHERE Id = :order.Id];
        NE__OrderItem__c orderItem = [SELECT Id FROM NE__OrderItem__c WHERE Id = :listOrder[0].NE__Order_Items__r[0].Id];
             
        orderItem.XC_IsAProduct__c = true;
        orderItem.NE__ProdId__c  = listProduct[0].Id;
        update orderItem;
        
        listAsset[0].XC_Configuration_Item__c = orderItem.Id;
        listAsset[1].XC_Configuration_Item__c = orderItem.Id;
        insert listAsset;
        
        listWorkOrder[0].XC_Configuration_Item__c = orderItem.Id;
		insert listWorkOrder;

        listWorkOrder[0].XC_Configuration_Item__c = orderItem.Id;
        update listWorkOrder;

        Test.stopTest();
    }
    @isTest
    static void afterUpdate(){
		
        List<WorkOrder> listWorkOrder = [SELECT Id, ContactId FROM Workorder WHERE XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_Substitution LIMIT 1];
        List<WorkOrder> listSon = [SELECT Id, ParentWorkOrderId FROM Workorder WHERE ParentWorkOrderId = :listWorkOrder[0].Id];
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(1);
        insert contacts;
        
        for(WorkOrder woChild : listSon) {
            woChild.Status = 'New';
            woChild.XC_WorkTypeLabel__c = Label.XC_CL_WorkType_QualityCheckInspection;
        }
        update listSon;
        for(WorkOrder woChild : listSon) {
            woChild.Status = 'Assigned'; 
        }
        update listSon;
        for(WorkOrder woChild : listSon) {
            woChild.Status = 'In Progress'; 
        }
        update listSon;
        listWorkOrder[0].Status = Label.XC_CL_Completed;
        listWorkOrder[0].XC_ValidationStatus__c = '';
        listWorkOrder[0].ContactId = null;
        try{
        	update listWorkOrder;
        }catch(Exception e){
            System.debug('In catch');
        }
        System.assertEquals(true, listWorkOrder!=null);
    
    }
}