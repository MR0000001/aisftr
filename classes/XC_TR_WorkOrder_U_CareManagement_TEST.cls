/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  05/06/2019 
* @description XC_TR_WorkOrder_U_CareManagement_TEST – Test class for XC_TR_WorkOrder_U_CareManagement
*/
@isTest
public class XC_TR_WorkOrder_U_CareManagement_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    @isTest
	static void manageWorkOrderToValidateTEST(){
    	
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<WorkOrder> wlist = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        wlist[0].AccountId = accList[0].Id;
        insert wlist;
        XC_TR_WorkOrder_U_CareManagement.manageWorkOrderToValidate(wlist);
        List<Case> cs = XC_DF_Case.createCases(1);
        insert cs;
        List<Asset> ass = XC_DF_Asset.createAssets(1);
        insert ass;
        Set<Id> csid = new Set<Id>();
        csid.add(cs[0].id);
        Set<Id> asid = new Set<Id>();
        asid.add(ass[0].id);
        Map<Id,Set<Id>> assetsToAttach = new Map<Id,Set<Id>>();
        assetsToAttach.put(wlist[0].id, asid);
        XC_TR_WorkOrder_U_CareManagement.insertAllCaseAssetRelations(csid, assetsToAttach);
        Test.stopTest();   
    }
    
    @isTest
	static void checkValidationWOConditionTEST(){
    	
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        XC_TR_WorkOrder_U_CareManagement.CheckWOValidationInput checkInputWrapper = new XC_TR_WorkOrder_U_CareManagement.CheckWOValidationInput();
        List<WorkOrder> wlist = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        wlist[0].AccountId = accList[0].Id;        
        insert wlist;
		List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(wlist);
        checkInputWrapper.woToValidate = wlist[0];
        checkInputWrapper.activeSA = sa[0];
        XC_ComplianceMaster__c cm = new XC_ComplianceMaster__c();
        checkInputWrapper.validationWORule = cm;
        XC_TR_WorkOrder_U_CareManagement.checkValidationWOCondition(checkInputWrapper);
        Test.stopTest();   
    }
    
    @isTest
	static void probabilityAndCheckTEST(){
    	
        Test.startTest();
        Integer x = 10;
		XC_TR_WorkOrder_U_CareManagement.probabilityEvaluation(x);
        String a = 'pippo';
        String b = 'pluto';
    	XC_TR_WorkOrder_U_CareManagement.checkCommercialCode(a, b);
        Test.stopTest();   
    }
    
    @isTest
	static void manageCaseForSiteInspectionTEST(){
    	
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Site Inspection');
        listWorkOrder[0].AccountId = accList[0].Id;
        listWorkOrder[0].XC_WorkTypeLabel__c = Label.XC_CL_WorkType_SIPhotovoltaic;
        listWorkOrder[0].RecordTypeId = recordTypeId;
        listWorkOrder[0].status = Label.XC_CL_OnHold;
        insert listWorkOrder;
        XC_TR_WorkOrder_U_CareManagement.manageCaseStatusOnUpdateLogic(listWorkOrder);
        Test.stopTest();   
    }
    
    @isTest
	static void manageCheckExtraWorkAndExtraKm(){
        
        Test.startTest();
        User u =createUser();
        System.runAs(u){         
            List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
            insert accList;
            List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
            conList[0].XC_CountryLegalEntity__c = 'ITALY';
            conList[0].XC_MainLegalEntity__c = 'EnelXItalia';
            insert conList;
            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
            woList[0].XC_LegalEntity__c = 'EnelXItalia';
            woList[0].XC_Address__c = null;
            woList[0].Street = null;
            woList[0].Status = Label.XC_CL_WorkOrder_Completed;
            woList[0].AccountId = accList[0].Id;
            woList[0].ContactId = conList[0].Id;
            insert woList;            
            woList[0].XC_ExtraKm__c = true; 
            woList[0].XC_ValidationStatus__c = null;
            update woList;
            woList[0].Status = Label.XC_CL_WorkOrder_Cancelled;
            update woList;
            Test.stopTest();
        }
    }
    
    private static User createUser(){
        
        List<String> l = new List<String>{'EndesaX','EnelX','Codensa','EnelDistribucion','EnelXItalia','EnelSole','EnelXMobility'};
        User user = new User();
        user.Username = 'Digrationitab2bg@exprod.com';
        user.FirstName ='TestUser';
        user.LastName ='testUserProva';
        user.Email = 'pablo@test.com';
        user.Alias = 'TestTry';
        user.ProfileId = [SELECT Id, UserLicenseId FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        user.LocaleSidKey = 'it_IT';
        user.TimeZoneSidKey = 'GMT';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.IsActive = true;
        user.Country__c = 'Italy';
        user.CompanyP__c = 'Italy';
        user.XC_LegalEntity__c = 'EnelXItalia';
        //user.XC_LegalEntities__c = l;
        return user;
	}
    
    @isTest
	static void supportMethodsTEST(){
    	
        Test.startTest();
        XC_ComplianceMaster__c validationWORule = new XC_ComplianceMaster__c();
        Id commercialProductId = 'a5L0D000000LZRKUA4';
		Boolean value1 = XC_TR_WorkOrder_U_CareManagement.subCheckCommercialProduct(validationWORule, commercialProductId);
        Boolean value2 = XC_TR_WorkOrder_U_CareManagement.subCheckCatalogCategory(validationWORule, commercialProductId);
        Decimal num = 12.3;
        Boolean value3 = XC_TR_WorkOrder_U_CareManagement.subCheckAdditionalAmount(num, num);           
        Test.stopTest();   
    }
    
}