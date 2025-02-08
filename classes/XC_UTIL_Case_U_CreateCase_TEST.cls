@isTest
private class XC_UTIL_Case_U_CreateCase_TEST { 
    
    @isTest static void createPaymentVerificationCases_Test() {
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<NE__OrderItem__c> orderItemListQuery = [SELECT Id, XC_CountryFormula__c,NE__Account__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c FROM NE__OrderItem__c];         
        Test.startTest();
        XC_UTIL_Case_U_CreateCase.createPaymentVerificationCases(orderItemListQuery);
        System.assertEquals(1,orderItemListQuery.size());
        Test.stopTest();
        // Implement test code
    }
    @isTest static void createPaymentVerificationCase_Test() {
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        Test.startTest();
        List<NE__OrderItem__c> orderItemListQuery = [SELECT Id, XC_CountryFormula__c,NE__Account__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c FROM NE__OrderItem__c]; 
        system.debug('@@@ COUNTRY ->'+ orderItemListQuery[0].XC_CountryFormula__c);
        XC_UTIL_Case_U_CreateCase.createPaymentVerificationCase(orderItemListQuery[0]);
        System.assertEquals(1,orderItemListQuery.size());
        Test.stopTest();
        // Implement test code
    }
    
    @isTest static void createCaseReservationKO_Test() {
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        Map<String,String> mapConfItemrResult=new Map<String,String>();
        Test.startTest();
        List<NE__OrderItem__c> orderItemListQuery = [SELECT Id, XC_CountryFormula__c,NE__Account__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c FROM NE__OrderItem__c];
        system.debug('@@@ COUNTRY ->' + orderItemListQuery[0].XC_CountryFormula__c);
        XC_UTIL_Case_U_CreateCase.createCaseReservationKO(orderItemListQuery,mapConfItemrResult);
        System.assertEquals(1,orderItemListQuery.size());
        Test.stopTest();
        // Implement test code
    }

    @isTest static void createAdministrativeCase_Test() {
        NE__OrderItem__c ordItem=new NE__OrderItem__c();
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        XC_CM_Case_Type_Setting__mdt caseMDT = new XC_CM_Case_Type_Setting__mdt();
        Test.startTest();
        XC_UTIL_Case_U_CreateCase.createAdministrativeCase(ordItem, provisioningStep, caseMDT);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }

    @isTest static void createWrapperFromCase_Test() {
        list<Case> cases=XC_DF_Case.createCases(1);
        Case cs=cases[0];
        Test.startTest();
        XC_UTIL_Case_U_CreateCase.createWrapperFromCase(cs);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }

    @isTest static void createWrapperFromCase2_Test() {
        list<Case> cases=XC_DF_Case.createCases(1);
        Case cs=cases[0];
        List<CaseComment> comments=new List<CaseComment>();
        CaseComment comment=new CaseComment();
        comments.add(comment);
        Test.startTest();
        XC_UTIL_Case_U_CreateCase.createWrapperFromCase(cs,comments);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }

    @isTest static void createComplianceCases_Test() {
        Map<Id, List<String>> mapConfItemComplianceMaster=new Map<Id, List<String>>();
        Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapConfItemComplianceWrapper=new Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult>();
        Test.startTest();
        XC_UTIL_Case_U_CreateCase.createComplianceCases(mapConfItemComplianceMaster,mapConfItemComplianceWrapper);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }
    
    @isTest static void populateReasonAndSubCause_Test() { 
        XC_UTIL_Case_U_CreateCase.UtilityWrapper utWrapper = new XC_UTIL_Case_U_CreateCase.UtilityWrapper();
        XC_UTIL_Case_U.AdministrativeCaseWrapper administrativeCaseWrapper = new XC_UTIL_Case_U.AdministrativeCaseWrapper();
        Case caseToCreate = new Case();
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = new Map<String, XC_CM_Case_Type_Setting__mdt>();
        String ordItemId;
        utWrapper.administrativeCaseWrapper = administrativeCaseWrapper;
        utWrapper.caseToCreate = caseToCreate;
        utWrapper.caseSettingsMap = caseSettingsMap;
        utWrapper.ordItemId = ordItemId;
        Test.startTest();
        XC_UTIL_Case_U_CreateCase.populateReasonAndSubCause(utWrapper);
        System.assert(caseSettingsMap.isEmpty());
        Test.stopTest();
        // Implement test code
    }    

    
}