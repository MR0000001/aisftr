/**
* @author Valeria Martino valeria.martino@nttdata.com
* @date Creation  02/08/2019 
* @date Modification 16/01/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_WorkOrder_U_ManageBooking_TEST – Test class for XC_TR_WorkOrder_U_ManageBooking
*/ 

@isTest
public class XC_TR_WorkOrder_U_ManageBooking_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;   
    } 

    @isTest
    static void onAfterInsert() {
        List<WorkOrder> childWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        childWorkOrder[0].XC_NumberWorkOrdersDI__c = 1;
        childWorkOrder[0].PostalCode = '28080';
        List<ServiceResource> noCandidatesFound =  XC_DF_ServiceResource.createServiceResources(1);
        noCandidatesFound[0].Name = Label.XC_CL_NoCandidateFound;
        update noCandidatesFound;
        insert childWorkOrder;
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWorkOrder[0].ParentWorkOrderId = childWorkOrder[0].id;
        listWorkOrder[0].XC_NumberWorkOrdersDI__c = 1;
        Product2 p2 = new Product2(Name = 'TestProduct2');
        insert p2;
        List<ProductRequired> listPr = new List<ProductRequired>();
        List<WorkOrder> allWo = new List<WorkOrder>();
        allWo.addAll(childWorkOrder);
        //allWo.addAll(listWorkOrder);
        for(WorkOrder wo : allWo) {
            ProductRequired pr = new ProductRequired(
                ParentRecordId = wo.Id, 
                XC_Mode__c = 'Add',
                XC_ProcurementType__c = 'Purchase', 
                QuantityRequired = 1,
                Product2Id = p2.Id
            );
            listPr.add(pr);
        }
        insert listPr;
        List<Id> listids = XC_UTIL_Sobject.getIds(allWo);
        insert listWorkOrder;
        XC_TR_WorkOrder_U_ManageBooking.getConcatAsset('a', 'b'); 
    }

}