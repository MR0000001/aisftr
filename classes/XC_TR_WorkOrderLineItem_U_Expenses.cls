/**
* @author Andrea Di Cicco
* @date Creation 21/07/2020
* @description class for managing expenses records
*/
public without sharing class XC_TR_WorkOrderLineItem_U_Expenses {

    /**
    * @author Andrea Di Cicco
    * @date Creation 21/07/2020
    * @param mapNew
    * @param mapOld
    * @description class for managing expenses records
    */
    public static void expensesCreation(Map<Id, WorkOrderLineItem> mapNew, Map<Id, WorkOrderLineItem> mapOld){
        Map<Id, WorkOrderLineItem> woliMaterialSupply = new Map<Id, WorkOrderLineItem>(); 
        Map<Id, WorkOrderLineItem> woliPaymentExpenses = new Map<Id, WorkOrderLineItem>();
        Map<Id, WorkOrderLineItem> woliPartnerEngagement = new Map<Id, WorkOrderLineItem>();
        List<project_cloud__Expense2__c> expensesToInsert = new List<project_cloud__Expense2__c>();


        for(WorkOrderLineItem woli : mapNew.values()){
            if(woli.XC_WOLIType__c == 'Material Supply' && woli.Status== 'Completed' && mapOld.get(woli.id).Status!= 'Completed' ){
                woliMaterialSupply.put(woli.id, woli);
            }else if(woli.XC_WOLIType__c == 'Partner Engagement' && woli.Status== 'Completed' && mapOld.get(woli.id).Status!= 'Completed'){
                woliPartnerEngagement.put(woli.id, woli);
            }else if(woli.XC_WOLIType__c == 'Partner Payment' && woli.Status== 'Released' && mapOld.get(woli.id).Status!= 'Released'){
                woliPaymentExpenses.put(woli.id, woli); 
            }
        }
        expensesToInsert.addAll(createMaterialSupplyExpenses(woliMaterialSupply));
        expensesToInsert.addAll(createPaymentExpenses(woliPaymentExpenses));
        expensesToInsert.addAll(createPartnerEngagementExpenses(woliPartnerEngagement));

        XC_UTIL_SObject.insertListRecords(expensesToInsert);
    }

    private static List<project_cloud__Expense2__c> createMaterialSupplyExpenses(Map<Id, WorkOrderLineItem> woliMaterialSupply){
        List<project_cloud__Expense2__c> materialSupplyExpenses = new List<project_cloud__Expense2__c>();
        List<ProductRequired> relatedProductRequired = new List<ProductRequired>();
        Map<Id, project_cloud__Expense2__c> mapWoliToExpenses = new Map<Id, project_cloud__Expense2__c>();
        if(woliMaterialSupply.isEmpty() || !Schema.sObjectType.ProductRequired.isAccessible()){
            return materialSupplyExpenses;
        }

        relatedProductRequired = [SELECT XC_WorkOrderLineItem__c, QuantityRequired, XC_OrderQuantity__c , XC_PriceUnits__c, XC_WorkOrderId__r.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c, XC_WorkOrderId__r.XC_Project_Task__c, XC_WorkOrderLineItem__r.XC_Project_Task__c
                                FROM ProductRequired 
                                WHERE (XC_WorkOrderId__r.XC_Segment__c = 'B2B' 
                                OR XC_WorkOrderId__r.XC_Segment__c = 'B2G')
                                AND XC_WorkOrderLineItem__c IN: woliMaterialSupply.keySet()];
        if(relatedProductRequired.isEmpty()){
            return materialSupplyExpenses;
        }

        for(ProductRequired pr : relatedProductRequired){
            if(mapWoliToExpenses.get(pr.XC_WorkOrderLineItem__c) != null ){
                //mapWoliToExpenses.get(pr.XC_WorkOrderLineItem__c).project_cloud__Amount__c +=  pr.XC_PriceUnits__c * pr.QuantityRequired;
                mapWoliToExpenses.get(pr.XC_WorkOrderLineItem__c).project_cloud__Amount__c +=  pr.XC_PriceUnits__c * pr.XC_OrderQuantity__c;
            }else{
                project_cloud__Expense2__c expense = new project_cloud__Expense2__c();
                expense.project_cloud__Project__c = pr.XC_WorkOrderId__r.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c;
                expense.project_cloud__Project_Task__c = pr.XC_WorkOrderLineItem__r.XC_Project_Task__c;
                expense.project_cloud__Type__c = 'Budgeted';
                //expense.project_cloud__Amount__c = pr.XC_PriceUnits__c * pr.QuantityRequired;
                expense.project_cloud__Amount__c = pr.XC_PriceUnits__c * pr.XC_OrderQuantity__c;
                expense.project_cloud__Date__c = System.today();
                mapWoliToExpenses.put(pr.XC_WorkOrderLineItem__c, expense);
            }
        }
        materialSupplyExpenses = mapWoliToExpenses.values();
        return materialSupplyExpenses;
    }


    private static List<project_cloud__Expense2__c> createPaymentExpenses(Map<Id, WorkOrderLineItem> woliPaymentExpenses){
        List<project_cloud__Expense2__c> paymentExpenses = new List<project_cloud__Expense2__c>();
        List<XC_ProductConsumed__c> relatedProductConsumed = new List<XC_ProductConsumed__c>();
        Map<Id, project_cloud__Expense2__c> mapWoliToExpenses = new Map<Id, project_cloud__Expense2__c>();
        if(woliPaymentExpenses.isEmpty() || !Schema.sObjectType.XC_ProductConsumed__c.isAccessible()){
            return paymentExpenses;
        }

        relatedProductConsumed = [SELECT id, XC_WorkOrderLineItem__c, XC_QuantityConsumed__c, XC_UnitPrice__c,  
                                    XC_WorkOrder__r.XC_Project_Task__c, 
                                    XC_WorkOrder__r.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c 
                                    FROM XC_ProductConsumed__c  
                                WHERE (XC_WorkOrder__r.XC_Segment__c = 'B2B' 
                                OR XC_WorkOrder__r.XC_Segment__c = 'B2G')
                                AND XC_WorkOrderLineItem__c IN: woliPaymentExpenses.keySet()];
        if(relatedProductConsumed.isEmpty()){
            return paymentExpenses;
        }

        for(XC_ProductConsumed__c pc : relatedProductConsumed){
            if(mapWoliToExpenses.get(pc.XC_WorkOrderLineItem__c) != null ){
                mapWoliToExpenses.get(pc.XC_WorkOrderLineItem__c).project_cloud__Amount__c +=  (pc.XC_UnitPrice__c != null && pc.XC_QuantityConsumed__c != null) ? pc.XC_UnitPrice__c * pc.XC_QuantityConsumed__c : 0;
            }else{
                project_cloud__Expense2__c expense = new project_cloud__Expense2__c();
                expense.project_cloud__Project__c = pc.XC_WorkOrder__r.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c;
                expense.project_cloud__Project_Task__c = pc.XC_WorkOrder__r.XC_Project_Task__c;
                expense.project_cloud__Type__c = 'Actual';
                expense.project_cloud__Amount__c = (pc.XC_UnitPrice__c != null && pc.XC_QuantityConsumed__c != null) ? pc.XC_UnitPrice__c * pc.XC_QuantityConsumed__c : 0;
                expense.project_cloud__Date__c = System.today();
                mapWoliToExpenses.put(pc.XC_WorkOrderLineItem__c, expense);
            }
        }
        paymentExpenses = mapWoliToExpenses.values();
        return paymentExpenses;
    }

    private static List<project_cloud__Expense2__c> createPartnerEngagementExpenses(Map<Id, WorkOrderLineItem> woliPartnerEngagement){
        List<project_cloud__Expense2__c> partnerEngagementExpenses = new List<project_cloud__Expense2__c>();
        List<XC_RequiredPosition__c> relatedProductRequired = new List<XC_RequiredPosition__c>();
        Map<Id, project_cloud__Expense2__c> mapWoliToExpenses = new Map<Id, project_cloud__Expense2__c>();
        if(woliPartnerEngagement.isEmpty() || !Schema.sObjectType.XC_RequiredPosition__c.isAccessible()){
            return partnerEngagementExpenses;
        }

        relatedProductRequired = [SELECT XC_WorkOrderLineItem__c, XC_Quantity__c, XC_UnitPrice__c, 
        XC_WorkOrderLineItem__r.WorkOrder.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c, XC_WorkOrderLineItem__r.WorkOrder.XC_Project_Task__c, XC_WorkOrderLineItem__r.XC_Project_Task__c
                                FROM XC_RequiredPosition__c 
                                WHERE (XC_WorkOrderLineItem__r.WorkOrder.XC_Segment__c = 'B2B' 
                                OR XC_WorkOrderLineItem__r.WorkOrder.XC_Segment__c = 'B2G')
                                 AND XC_WorkOrderLineItem__c IN: woliPartnerEngagement.keySet()];
        if(relatedProductRequired.isEmpty()){
            return partnerEngagementExpenses;
        }

        for(XC_RequiredPosition__c pr : relatedProductRequired){
            if(mapWoliToExpenses.get(pr.XC_WorkOrderLineItem__c) != null ){
                mapWoliToExpenses.get(pr.XC_WorkOrderLineItem__c).project_cloud__Amount__c +=  pr.XC_UnitPrice__c * pr.XC_Quantity__c;
            }else{
                project_cloud__Expense2__c expense = new project_cloud__Expense2__c();
                expense.project_cloud__Project__c = pr.XC_WorkOrderLineItem__r.WorkOrder.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c;
                expense.project_cloud__Project_Task__c = pr.XC_WorkOrderLineItem__r.XC_Project_Task__c;
                expense.project_cloud__Type__c = 'Budgeted';
                expense.project_cloud__Amount__c = pr.XC_UnitPrice__c * pr.XC_Quantity__c;
                expense.project_cloud__Date__c = System.today();
                mapWoliToExpenses.put(pr.XC_WorkOrderLineItem__c, expense);
            }
        }
        partnerEngagementExpenses = mapWoliToExpenses.values();
        return partnerEngagementExpenses;
    }

}