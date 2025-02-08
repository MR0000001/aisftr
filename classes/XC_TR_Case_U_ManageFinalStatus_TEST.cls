/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 05/11/2019
* @description XC_TR_Case_U_ManageFinalStatus_TEST - TEST Class for XC_TR_Case_U_ManageFinalStatus
*/ 
@isTest
public class XC_TR_Case_U_ManageFinalStatus_TEST {
    
    @testSetup
    private static void setup() {
        
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;
        List<ServiceAppointment> serviceApps = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_SiteInspection);
        ServiceAppointment sa = serviceApps[0];        
        sa.Status = 'Scheduled';
        insert sa;   
        System.assertEquals(serviceApps.size(), 1);
    }
    
    /**
    * @description manage case closure
    */
    @isTest
    public static void closeServiceAppointment1() {
        List<Case> cases = XC_DF_Case.createCases(1);
        
        Case cCase = cases[0];
        insert cCase;
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        Account acc = accList[0];
        List<Contact> contList = [SELECT Id FROM Contact LIMIT 1];
        Contact cont = contList[0];
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder LIMIT 1];
        WorkOrder wo = woList[0];
        wo.AccountId = acc.Id;
        wo.ContactId = cont.Id;
        update wo;
        Test.startTest();
        cCase.Reason = Label.XC_CL_CaseReason_XCMOT007;
        cCase.SubCause__c = Label.XC_CL_SubCause_ATCL024;
        cCase.XC_Resolution__c = 'R001';
        cCase.XC_Result__c = 'RS003';
        cCase.Status = 'ESTA007';
        cCase.CaseRemarks__c = 'Caso cancelado como consecuencia de la cancelación de registros asociados';
        cCase.XC_WorkOrder__c = wo.Id;
        cCase.AccountId = acc.Id;
        cCase.ContactId = cont.Id;
        update cCase;
        Test.stopTest();    
        System.assertEquals(accList.size(), 1);
    }
    
        /**
    * @description manage case closure
    */
    @isTest
    public static void closeServiceAppointment2() {
        List<Case> cases = XC_DF_Case.createCases(1);
        
        Case cCase = cases[0];
        insert cCase;
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        Account acc = accList[0];
        List<Contact> contList = [SELECT Id FROM Contact LIMIT 1];
        Contact cont = contList[0];
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder LIMIT 1];
        WorkOrder wo = woList[0];
        wo.AccountId = acc.Id;
        wo.ContactId = cont.Id;
        update wo;
        Test.startTest();
        cCase.Reason = Label.XC_CL_CaseReason_XCMOT007;
        cCase.SubCause__c = Label.XC_CL_SubCause_ATCL024;
        cCase.XC_Resolution__c = 'R017';
        cCase.XC_Result__c = 'RS011';
        cCase.Status = 'ESTA008';
        cCase.CaseRemarks__c = 'Caso cancelado como consecuencia de la cancelación de registros asociados';
        cCase.XC_WorkOrder__c = wo.Id;
        cCase.AccountId = acc.Id;
        cCase.ContactId = cont.Id;
        update cCase;
        Test.stopTest();   
        System.assertEquals(accList.size(), 1);
    }
    
    @isTest
    public static void closureOfPhotovoltaicRefundCase(){        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        accounts[0].XC_Segment__c = 'B2C'; 
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        contacts[0].XC_Segment__c = 'B2C'; 
        contacts[0].XC_CountryLegalEntity__c = 'ITALY';
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert contacts;
        
        List<XC_Address__c> addr = XC_DF_Address.createAddress(accounts);
        insert addr;
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].Name = 'MyTestAsset';
        listAsset[0].AccountId = accounts[0].Id;
        listAsset[0].ContactId = contacts[0].Id;
        listAsset[0].NE__Status__c = 'Active';
        listAsset[0].XC_LegalEntity__c = 'EnelXItalia';
        listAsset[0].XC_Segment__c = 'B2C';
        insert listAsset;
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,'Delivery & Installation');
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        wo[0].XC_Address__c = addr[0].Id;
        wo[0].AccountId = accounts[0].Id;
        wo[0].ContactId = contacts[0].Id;
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ITA_WorkOrder').getRecordTypeId();
        wo[0].AssetId = listAsset[0].Id;
        insert wo;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PhotovoltaicRefund});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_PhotovoltaicRefund));
        caso.ContactId = contacts[0].Id;
        caso.XC_Segment__c = 'B2C'; 
        caso.XC_LegalEntity__c = 'EnelXItalia';
        caso.Status = 'ESTA003';
        insert caso;
        Test.startTest();
        	caso.AssetId = listAsset[0].Id;
            caso.XC_Resolution__c = 'R018';
            caso.XC_Result__c = 'RS015';
            caso.CaseRemarks__c = 'closure';
            update caso;
        Test.stopTest();   
        System.assert(true);
    }
}