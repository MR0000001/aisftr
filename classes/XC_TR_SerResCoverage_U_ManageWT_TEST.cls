/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 04/02/2020
* @description XC_TR_SerResCoverage_U_ManageWT_TEST – Test Class for XC_TR_ServiceResourceCoverage_U_ManageWT
*/

@isTest
private class XC_TR_SerResCoverage_U_ManageWT_TEST {

    @TestSetup
    private static void makeData(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        WorkType worktype = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Repair);
        insert worktype;
        // Service Resource Manager:
        List<ServiceResource> listServiceResourceManager = XC_DF_ServiceResource.createServiceResources(1);
        listServiceResourceManager[0].XC_IsManager__c = true;
        listServiceResourceManager[0].XC_LegalEntity__c  = Label.XC_CL_EndesaX;
        update listServiceResourceManager;
        
        // Service Resource No Manager:
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Id != :listServiceResourceManager[0].RelatedRecordId];
        ServiceResource serviceResNoManager = new ServiceResource();
        serviceResNoManager.Name = 'NoManager';
        serviceResNoManager.XC_Account__c = listServiceResourceManager[0].XC_Account__c;
        serviceResNoManager.IsActive = true;
        serviceResNoManager.IsCapacityBased = false;
        serviceResNoManager.XC_IsManager__c = false;
        serviceResNoManager.RelatedRecordId = usersList[0].Id; 
        serviceResNoManager.XC_LegalEntity__c  = Label.XC_CL_EndesaX;
        insert serviceResNoManager;
        // Create a Service Territory:
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        ServiceTerritory st = new ServiceTerritory(
            Name = 'TestSRC',
            XC_AccountId__c = listServiceResourceManager[0].XC_Account__c,
            OperatingHoursId = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'][0].Id,
            IsActive = true
        );
        insert st;
        ServiceTerritoryMember stmManager = new ServiceTerritoryMember(
            EffectiveStartDate = Datetime.now(),
            ServiceTerritoryId = st.Id,
            ServiceResourceId = listServiceResourceManager[0].Id);
        
        insert stmManager;
        ServiceTerritoryMember stmNoManager = new ServiceTerritoryMember(
            EffectiveStartDate = Datetime.now(),
            ServiceTerritoryId = st.Id,
            ServiceResourceId = serviceResNoManager.Id);
        
        insert stmNoManager;

        // Create Zip Code Work Type:
        List<WorkType> listWorkType = new List<WorkType>([SELECT Id FROM WorkType LIMIT 1]);
        XC_ZipCodeWorkType__c zipCodeWt = new XC_ZipCodeWorkType__c(
            XC_ZipCode__c = '28011',
            XC_WorkType__c = listWorkType[0].Id,
            XC_ExternalId__c = '28011_'+listWorkType[0].Id );
       
        insert zipCodeWt;
    }

    @isTest
    private static void onUpdateManager() {
        List<WorkType> listWorkType = new List<WorkType>([SELECT Id FROM WorkType LIMIT 1]);
        XC_ZipCodeWorkType__c zipCodeWt = new XC_ZipCodeWorkType__c(
            XC_ZipCode__c = '28012',
            XC_WorkType__c = listWorkType[0].Id,
            XC_ExternalId__c = '28012_'+listWorkType[0].Id );
       
        insert zipCodeWt;
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c(
            XC_Account__c = new List<ServiceResource>([SELECT Id, XC_Account__c FROM ServiceResource WHERE XC_IsManager__c = true LIMIT 1])[0].XC_Account__c, 
            XC_ZipCodeWorkType__c = zipCodeWt.Id,
            XC_WorkType__c = listWorkType[0].Id,
            XC_ZipCode__c = '28012');
        insert pc;
        
        List<XC_ServiceResourceCoverage__c> listSrc = new List<XC_ServiceResourceCoverage__c>([
            SELECT Id, XC_ServiceResourceId__c, XC_ZipCodeWorkTypeId__c, XC_ZipCode__c, XC_WorkType__c, XC_InheritedFromParent__c, XC_ZipCodeText__c, XC_WorkTypeId__c, XC_ExternalIdForDuplication__c
            FROM XC_ServiceResourceCoverage__c
            WHERE XC_ZipCode__c = '28012']);
        
        delete listSrc;
        for(XC_ServiceResourceCoverage__c src : listSrc) {
            src.Id = null;
            src.XC_ZipCodeText__c = '28011';
            src.XC_ZipCodeWorkTypeId__c = new List<XC_ZipCodeWorkType__c>([SELECT Id FROM XC_ZipCodeWorkType__c WHERE XC_ZipCode__c = '28011' LIMIT 1])[0].Id;
        }
        insert listSrc;
        List<XC_ServiceResourceCoverage__c> listSrcToUpdate = new List<XC_ServiceResourceCoverage__c>();
        for(XC_ServiceResourceCoverage__c src : listSrc) {
            listSrcToUpdate.add(new XC_ServiceResourceCoverage__c(
                Id = src.Id,
                XC_InheritedFromParent__c = false,
                XC_ZipCodeText__c = '28011'));
            
        }
        update listSrc;
    }

    @isTest
    private static void onInsert() {
        XC_ServiceResourceCoverage__c srcNoManager = new XC_ServiceResourceCoverage__c(
            XC_ServiceResourceId__c = new List<ServiceResource>([SELECT Id FROM ServiceResource WHERE XC_IsManager__c = false LIMIT 1])[0].Id, 
            XC_ZipCodeWorkTypeId__c = new List<XC_ZipCodeWorkType__c>([SELECT Id FROM XC_ZipCodeWorkType__c LIMIT 1])[0].Id
        );

        Test.startTest();
        insert srcNoManager;
        System.assertNotEquals(null, srcNoManager.Id);
        List<WorkType> listWorkType = new List<WorkType>([SELECT Id FROM WorkType LIMIT 1]);
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c(
            XC_Account__c = new List<ServiceResource>([SELECT Id, XC_Account__c FROM ServiceResource WHERE XC_IsManager__c = true LIMIT 1])[0].XC_Account__c, 
            XC_ZipCodeWorkType__c = new List<XC_ZipCodeWorkType__c>([SELECT Id FROM XC_ZipCodeWorkType__c LIMIT 1])[0].Id,
            XC_WorkType__c = listWorkType[0].Id,
            XC_ZipCode__c = '28012'
        );
        insert pc;
        delete srcNoManager;
        List<XC_ServiceResourceCoverage__c> srcAll = new List<XC_ServiceResourceCoverage__c>([
            SELECT Id   
            FROM XC_ServiceResourceCoverage__c ]);
       
        update srcAll;
        delete srcAll;
        XC_ServiceResourceCoverage__c srcManager = new XC_ServiceResourceCoverage__c(
            XC_ServiceResourceId__c = new List<ServiceResource>([SELECT Id FROM ServiceResource WHERE XC_IsManager__c = true LIMIT 1])[0].Id, 
            XC_ZipCodeWorkTypeId__c = new List<XC_ZipCodeWorkType__c>([SELECT Id FROM XC_ZipCodeWorkType__c WHERE XC_ZipCode__c = '28012' LIMIT 1])[0].Id
        );
        insert srcManager;

        List<ServiceResource> listSrUtility = new List<ServiceResource>([
            SELECT Id,
                (SELECT Id, XC_ServiceResourceId__c, XC_ServiceResourceId__r.XC_Account__c, XC_ZipCodeWorkTypeId__c, XC_ZipCode__c, XC_WorkType__c, XC_InheritedFromParent__c, XC_ZipCodeText__c, XC_WorkTypeId__c, XC_ExternalIdForDuplication__c
                FROM ServiceResourceCoverages__r)   
            FROM ServiceResource WHERE XC_IsManager__c = true
        ]);
        XC_TR_ServiceResCoverage_U_ManageWT_U.getMapSrZipCodeWorkType(listSrUtility);
        List<XC_ServiceResourceCoverage__c> listSrcToUpdate = listSrUtility[0].ServiceResourceCoverages__r;
        XC_TR_ServiceResCoverage_U_ManageWT_U.filterForInheritedFromParent(listSrcToUpdate);
        XC_TR_ServiceResCoverage_U_ManageWT_U.populateZipCodeWorkTypeFromFields(listSrcToUpdate);
        listSrcToUpdate[0].XC_ZipCodeText__c = '00055';
        XC_PartnerCoverage__c newPc = new XC_PartnerCoverage__c(
            XC_Account__c = listSrcToUpdate[0].XC_ServiceResourceId__r.XC_Account__c,
            XC_WorkType__c = listSrcToUpdate[0].XC_WorkTypeId__c,
            XC_ZipCode__c = '00055' );
       
        insert newPc;
        update listSrcToUpdate;
        Test.stopTest();
    }

    @isTest
    private static void onDelete() {
        List<WorkType> listWorkType = new List<WorkType>([SELECT Id FROM WorkType LIMIT 1]);
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c(
            XC_Account__c = new List<ServiceResource>([SELECT Id, XC_Account__c FROM ServiceResource WHERE XC_IsManager__c = true LIMIT 1])[0].XC_Account__c, 
            XC_ZipCodeWorkType__c = new List<XC_ZipCodeWorkType__c>([SELECT Id FROM XC_ZipCodeWorkType__c LIMIT 1])[0].Id,
            XC_WorkType__c = listWorkType[0].Id,
            XC_ZipCode__c = '28011');
        
        insert pc;

        Test.startTest();
        XC_ServiceResourceCoverage__c src = new XC_ServiceResourceCoverage__c(
            Id = new List<XC_ServiceResourceCoverage__c>([SELECT Id, XC_ServiceResourceId__c, XC_ZipCodeWorkTypeId__c, XC_ZipCode__c, XC_WorkType__c FROM XC_ServiceResourceCoverage__c WHERE XC_ServiceResourceId__r.XC_IsManager__c = true LIMIT 1])[0].Id,
            XC_InheritedFromParent__c = false  );
      
        update src;
        delete src;
        System.assertNotEquals(src, null);
        Test.stopTest();
    }

}