/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 20/05/2019 
* @date Modification 21/04/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_WorkType_TEST – Test class for XC_UTIL_WorkType
*/

@isTest
private class XC_UTIL_WorkType_TEST {
    
    @isTest
    static void onInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
        User user = XC_DF_User.createUserAdmin();
        insert user;
        ServiceResource servRes = new ServiceResource(
            Name = Label.XC_CL_NoCandidateFound, 
            XC_Account__c = accList[0].Id, 
            isCapacityBased = true,
            RelatedRecordId = user.Id, 
            isActive = true 
        );
        insert servRes;
        
        List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation));
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair));
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance));
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Return));
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Substitution));
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation));
        insert listWorkOrder;
       
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, XC_LegalEntity__c, XC_WorkTypeLabel__c, XC_WorkTypeCategory__c FROM WorkOrder];
        List<WorkType> woTypeList = [SELECT Id, Name, XC_WorkTypeCategory__c, XC_LegalEntity__c, XC_Segment__c FROM WorkType];
        List<String> woTypeName = XC_UTIL_Sobject.getListFieldValues(woTypeList, 'Name');
        List<String> woTypeId = XC_UTIL_Sobject.getListFieldValues(woTypeList, 'Id');

        XC_UTIL_WorkType.getWorkTypeByName(woTypeName[0]);
        XC_UTIL_WorkType.retrieveWorkTypeByNameOrId(woTypeName, woTypeId);
        XC_UTIL_WorkType.getMapWorkTypeNameId(woTypeName); 
        XC_UTIL_WorkType.getMapAssignToPartnerByWorkTypeName(woTypeName);
        XC_UTIL_WorkType.getWorkTypeByNameAndLE(Label.XC_CL_WorkType_Installation, listInsertedWorkOrders[0].XC_LegalEntity__c);
        XC_UTIL_WorkType.getMapAssignToPartnerByWorkTypeId(new List<String>{woTypeList[0].Id});
        Test.startTest();
        XC_UTIL_WorkType.splitWorkOrders(listInsertedWorkOrders);
        XC_UTIL_WorkType.filterWOByWorkTypeCategory(listInsertedWorkOrders, Label.XC_CL_WorkType_DeliveryInstallation);
        XC_UTIL_WorkType.filterWOByWorkTypeCategory(new List<ServiceAppointment>{new ServiceAppointment(ParentRecordId=listInsertedWorkOrders[0].Id, XC_WorkTypeCategory__c=listInsertedWorkOrders[0].XC_WorkTypeCategory__c)}, Label.XC_CL_WorkType_DeliveryInstallation);
        XC_UTIL_WorkType.getMapWorkTypeNameLEToId(new List<String>{Label.XC_CL_WorkType_DeliveryInstallation}, new List<String>{'EndesaX'});
        Test.stopTest();        
    }

}