/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 17/03/2020
 * @description XC_SC027_CreateCaseBarCode - Batch to create a Case for Payment Type Barcode by SA
 */

public without sharing class XC_SC027_CreateCaseBarCode implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC027_CreateCaseBarCode');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC027_CreateCaseBarCode());
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch XC_SC027_CreateCaseBarCode');
        String stringBarcode = Label.XC_CL_Barcode;
        List<String> stringStatusSa = new List<String>{Label.XC_CL_ServiceAppointment_OnHold, Label.XC_CL_ServiceAppointment_Scheduled};
        String stringDeliveryInstallation = Label.XC_CL_WorkType_DeliveryInstallation;
        return Database.getQueryLocator('SELECT Id, XC_LegalEntity__c, XC_Configuration_Item__c, ParentRecordId, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__Account__c FROM ServiceAppointment WHERE Status IN :stringStatusSa AND (SchedStartTime = NEXT_N_DAYS:2 or SchedStartTime = TODAY) AND XC_Payment_Type__c = :stringBarcode AND XC_WorkTypeCategory__c = :stringDeliveryInstallation');
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch XC_SC027_CreateCaseBarCode');
        // Create a list of Work Order to manage:
        Map<String, ServiceAppointment> mapConfItemServiceAppointment = new Map<String, ServiceAppointment>();
        for(ServiceAppointment sa : scope) {
            mapConfItemServiceAppointment.put(sa.XC_Configuration_Item__c, sa);
        }
        List<XC_Provisioning_Step__c> listProvisioningStep = new List<XC_Provisioning_Step__c>([
            SELECT Id, XC_Configuration_Item__c
            FROM XC_Provisioning_Step__c  
            WHERE XC_Configuration_Item__c IN :mapConfItemServiceAppointment.keySet() AND XC_Flow_API_Name__c = :Label.XC_CL_ProvisioningPaymentCheck_Flow AND XC_Status__c = :Label.XC_CL_Provisioning_Step_InProgress
        ]);
        if(listProvisioningStep.isEmpty()) {
            return;
        }
        List<String> listConfItemToManage = XC_UTIL_Sobject.getListFieldValues(listProvisioningStep, 'XC_Configuration_Item__c');
        List<ServiceAppointment> listSaToManage = new List<ServiceAppointment>();
        for(String confItemId : mapConfItemServiceAppointment.keySet()) {
            if(listConfItemToManage.contains(confItemId)) {
                listSaToManage.add(mapConfItemServiceAppointment.get(confItemId));
            }
        }

        // Create Case:
        if(listSaToManage.isEmpty()) {
            return;
        }
        createCase(listSaToManage);
    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End batch XC_SC027_CreateCaseBarCode');
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 17/03/2020
     * @param listServiceAppointment - List<ServiceAppointment> 
     * @description Create a case for Work Order in input
    */
    public void createCase(List<ServiceAppointment> listServiceAppointment) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Create case for batch XC_SC027_CreateCaseBarCode');
        // Retrieve Work Order info:
        List<String> listWorkOrderIds = XC_UTIL_Sobject.getListFieldValues(listServiceAppointment, 'ParentRecordId');
        Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>([
            SELECT Id, AccountId, ContactId
            FROM WorkOrder
            WHERE ID IN :listWorkOrderIds
        ]);

        // Retrieve Case info:
        String templateName = 'XC_PaymentType_BarCode';
        Map<String,XC_CM_Case_Type_Setting__mdt> caseSettings = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{templateName});
        if(caseSettings.values().isEmpty()) {
            return;
        }

        // Populate new Case:
        List<Case> listCaseToInsert = new List<Case>();
        for(ServiceAppointment sa : listServiceAppointment) {
            Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings.get(templateName));
            newCase.XC_WorkOrder__c = sa.ParentRecordId;
            newCase.AccountId = mapWo.get(sa.ParentRecordId).AccountId;
            newCase.ContactId = mapWo.get(sa.ParentRecordId).ContactId;
            newCase.XC_Order__c = sa.XC_Configuration_Item__r.NE__OrderId__c;
            newCase.XC_LegalEntity__c = sa.XC_LegalEntity__c;
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId(); //temp
            listCaseToInsert.add(newCase);
        }
        XC_UTIL_Sobject.insertListRecords(listCaseToInsert, false);

        // For assignment of new cases:
        List<AssignmentRule> asgnRule = new List<AssignmentRule>([
            SELECT Id
            FROM AssignmentRule
            WHERE SobjectType = 'Case' AND Active = true
        ]);
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = asgnRule[0].Id;
        List<Case> listCaseToUpdate = new List<Case>();
        for(Case csInserted : listCaseToInsert) {
            if(String.isNotBlank(csInserted.Id)) {
                csInserted.setOptions(dmlOpts);
                listCaseToUpdate.add(csInserted);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listCaseToUpdate, false);
    }    

}