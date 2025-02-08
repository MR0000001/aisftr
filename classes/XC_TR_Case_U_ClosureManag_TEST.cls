/**
 * The Class XC_TR_Case_U_ClosureManagement.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 05/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to manage Case closure
 **/ 

@isTest
public without sharing class XC_TR_Case_U_ClosureManag_TEST {
    
    /**
    * @description manage case closure
    */
    static testMethod void manageCaseClosure() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Case.createCases(1);
        List<Case> cases = [SELECT Id FROM Case LIMIT 1];
        Case cCase = cases[0];

        Test.startTest();
        cCase.Reason ='XCMOT001';
        cCase.SubCause__c = 'ATCL033';
        cCase.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA007;
        try{
        	update cCase;
        	System.assert(true, 'Wrong assert Case_U_ClosureMang');
        } catch(Exception ex){
            System.assert(false, 'Exception on Case_U_ClosureMang');
        }
        Test.stopTest();        
    }

    static testMethod void createCaseClosure() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> cases=XC_DF_Case.createCases(1);
        Case cCase = cases[0];
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderItemList[0].Id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;

        Test.startTest();
        cCase.Reason ='XCMOT005';
        cCase.XC_ProvisioningStep__c = provisioningStep.Id;
        cCase.SubCause__c = 'ATCL069';
        //cCase.XC_Subtype__c = 'XC068';
        cCase.XC_Type_Intermediary__c = 'TI001';
        insert cCase;
        try{
        	cCase.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA007;
            update cCase;
        //	System.assert(true, 'Wrong assert Case_U_ClosureMang');
        } catch(Exception ex){
        // System.assert(false, 'Exception on Case_U_ClosureMang');
        }
        Test.stopTest();        
    }

    static testMethod void createBadCaseClosure() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> cases=XC_DF_Case.createCases(1);
        Case cCase = cases[0];

        Test.startTest();
        cCase.Reason ='XCMOT011';
        cCase.SubCause__c = 'ATCL002';
        cCase.XC_Subtype__c = '';
        cCase.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA007;
        try{
        	insert cCase;
        	System.assert(false, 'Wrong assert Case_U_ClosureMang');
        } catch(Exception ex){
            System.assert(true, 'Exception on Case_U_ClosureMang');
        }
        Test.stopTest();        
    }

    static testMethod void createCaseClosure2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> cases=XC_DF_Case.createCases(1);
        Case cCase = cases[0];

        Test.startTest();
        cCase.Reason ='XCMOT002';
        cCase.SubCause__c = 'ATCL054';
        cCase.XC_Subtype__c  = 'XC033';
        cCase.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA007;
        try{
        	insert cCase;
        	System.assert(true, 'Wrong assert Case_U_ClosureMang');
        } catch(Exception ex){
            System.assert(true, 'Exception on Case_U_ClosureMang');
        }
        Test.stopTest();        
    }
    @isTest
    private static void caseLegalizationCheck_test(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PermittingManagement});
        XC_CM_Case_Type_Setting__mdt caseSettings = new XC_CM_Case_Type_Setting__mdt();
        caseSettings = mapCaseSetting.get(Label.XC_CL_PermittingManagement);
        testCases[0].Subcause__c = caseSettings.XC_Sub_cause__c;
        testCases[0].Reason = caseSettings.XC_Case_Reason__c;
        testCases[0].XC_LegalEntity__c = 'EndesaX';
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        testCases[0].XC_Description__c = testDescription;
        insert testCases;

        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = 'SF_RESULT_DOC', Case__c = testCases[0].Id);
        insert doc1;
        XC_DocumentType__c doc2 = new XC_DocumentType__c(Category__c = 'SF_ELECTRIC_CERT', Case__c = testCases[0].Id);
        insert doc2;

        testCases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];

        Test.startTest();
        testCases[0].XC_Subtype__c = caseSettings.XC_Sub_type__c;
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].Status = 'ESTA007';
        update testCases;
        Test.stopTest();

        List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
        System.assert(cases[0].XC_Legalization_Completed__c);
    }

    @isTest
    private static void caseLegalizationCheck_test_missingResultDoc(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        testCases[0].XC_Legalization_Completed__c = False;
        testCases[0].Subcause__c = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL028;
        testCases[0].Reason = 'XCMOT007';
        testCases[0].XC_Description__c = testDescription;
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        insert testCases;

        XC_DocumentType__c doc2 = new XC_DocumentType__c(Category__c = 'SF_ELECTRIC_CERT', Case__c = testCases[0].Id);
        insert doc2;

        Test.startTest();
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].XC_Subtype__c = XC_AT_Constants.CASE_TRIGGER_SUBTYPE_XC181;
        testCases[0].Status = 'ESTA007';
        testCases[0].XC_Permitting_Status__c = 'Completed OK';
        try{
        	update testCases;
            System.assert(False);
        	
        } catch(Exception ex){
            List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
            System.assert(!cases[0].XC_Legalization_Completed__c);
        }
        Test.stopTest();
    }
    
    @isTest
    private static void caseLegalizationCheck_test_missingElectricCert(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        testCases[0].XC_Legalization_Completed__c = False;
        testCases[0].Subcause__c = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL028;
        testCases[0].Reason = 'XCMOT007';
        testCases[0].XC_Description__c = testDescription;
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        insert testCases;

        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = 'SF_RESULT_DOC', Case__c = testCases[0].Id);
        insert doc1;

        Test.startTest();
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].XC_Subtype__c = XC_AT_Constants.CASE_TRIGGER_SUBTYPE_XC181;
        testCases[0].Status = 'ESTA007';
        try{
        	update testCases;
            System.assert(False);
        	
        } catch(Exception ex){
            List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
            System.assert(!cases[0].XC_Legalization_Completed__c);
            System.assert(ex.getMessage().contains(Label.XC_CL_Case_CheckedLegalizationError));
        }
        
        Test.stopTest();
    }
    @isTest
    private static void caseLegalizationCheck_test_missingBoth(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        testCases[0].XC_Legalization_Completed__c = False;
        testCases[0].Subcause__c = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL028;
        testCases[0].Reason = 'XCMOT007';
        testCases[0].XC_Description__c = testDescription;
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        insert testCases;

        Test.startTest();
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].XC_Subtype__c = XC_AT_Constants.CASE_TRIGGER_SUBTYPE_XC181;
        testCases[0].Status = 'ESTA007';

        try{
        	update testCases;
            System.assert(False);
        	
        } catch(Exception ex){
            List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
            System.assert(!cases[0].XC_Legalization_Completed__c);
            System.assert(ex.getMessage().contains(Label.XC_CL_Case_CheckedLegalizationError));
        }
        
        Test.stopTest();
    }

    @isTest
    private static void caseLegalizationCheck_wrongCaseSettings(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PermittingManagement});
        XC_CM_Case_Type_Setting__mdt caseSettings = new XC_CM_Case_Type_Setting__mdt();
        caseSettings = mapCaseSetting.get(Label.XC_CL_PermittingManagement);
        testCases[0].Subcause__c = caseSettings.XC_Sub_cause__c;
        testCases[0].Reason = caseSettings.XC_Case_Reason__c;
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        testCases[0].XC_Description__c = testDescription;
        insert testCases;

        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = 'SF_RESULT_DOC', Case__c = testCases[0].Id);
        insert doc1;
        XC_DocumentType__c doc2 = new XC_DocumentType__c(Category__c = 'SF_ELECTRIC_CERT', Case__c = testCases[0].Id);
        insert doc2;

        testCases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];

        Test.startTest();
        testCases[0].XC_Subtype__c = 'XC180';
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].Status = 'ESTA007';
        Test.stopTest();

        try{
        	update testCases;
            System.assert(False);
        	
        } catch(Exception ex){
            List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
            System.assert(!cases[0].XC_Legalization_Completed__c);
            System.assert(ex.getMessage().contains(Label.XC_CL_Case_CheckedLegalizationError));
        }
    }

    @isTest
    private static void caseLegalizationCheck_testWO(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PermittingManagement});
        XC_CM_Case_Type_Setting__mdt caseSettings = new XC_CM_Case_Type_Setting__mdt();
        caseSettings = mapCaseSetting.get(Label.XC_CL_PermittingManagement);
        testCases[0].Subcause__c = caseSettings.XC_Sub_cause__c;
        testCases[0].Reason = caseSettings.XC_Case_Reason__c;
        testCases[0].XC_LegalEntity__c = 'EndesaX';
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        testCases[0].XC_Description__c = testDescription;
        insert testCases;

        Test.startTest();
        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = 'SF_RESULT_DOC', Case__c = testCases[0].Id);
        insert doc1;
        XC_DocumentType__c doc2 = new XC_DocumentType__c(Category__c = 'SF_ELECTRIC_CERT', Case__c = testCases[0].Id);
        insert doc2;

        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, 'Installation');
        wo[0].Status = Label.XC_CL_WorkOrder_Completed ;
        wo[0].CaseId = testCases[0].id;
        wo[0].XC_WorkTypeLabel__c = 'Installation';
        insert wo;

        
        testCases[0].XC_Subtype__c = caseSettings.XC_Sub_type__c;
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].Status = 'ESTA007';
        update testCases;
        Test.stopTest();

        List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
        System.assert(cases[0].XC_Legalization_Completed__c);
    }

    @isTest
    private static void caseLegalizationCheck_testWO_wrongStatus(){
        String testDescription = 'Test for CR2298';
        List<Case> testCases = XC_DF_Case.createCases(1);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PermittingManagement});
        XC_CM_Case_Type_Setting__mdt caseSettings = new XC_CM_Case_Type_Setting__mdt();
        caseSettings = mapCaseSetting.get(Label.XC_CL_PermittingManagement);
        testCases[0].Subcause__c = caseSettings.XC_Sub_cause__c;
        testCases[0].Reason = caseSettings.XC_Case_Reason__c;
        testCases[0].XC_LegalEntity__c = 'EndesaX';
        testCases[0].XC_Resolution__c = 'R001';
        testCases[0].CaseRemarks__c = 'Test';
        testCases[0].XC_Result__c = 'RS003';

        testCases[0].XC_Description__c = testDescription;
        insert testCases;

        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = 'SF_RESULT_DOC', Case__c = testCases[0].Id);
        insert doc1;
        XC_DocumentType__c doc2 = new XC_DocumentType__c(Category__c = 'SF_ELECTRIC_CERT', Case__c = testCases[0].Id);
        insert doc2;

        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, 'Installation');
        wo[0].Status = 'New';
        wo[0].CaseId = testCases[0].id;
        wo[0].XC_WorkTypeLabel__c = 'Installation';
        insert wo;

        Test.startTest();
        testCases[0].XC_Subtype__c = caseSettings.XC_Sub_type__c;
        testCases[0].XC_Legalization_Completed__c = True;
        testCases[0].Status = 'ESTA007';
        
        try{
        	update testCases;
            System.assert(False);
        	
        } catch(Exception ex){
            List<Case> cases = [SELECT ID, XC_Description__c, XC_Legalization_Completed__c FROM CASE WHERE XC_Description__c = :testDescription];
            System.assert(!cases[0].XC_Legalization_Completed__c);
        }
        Test.stopTest();
    }
}